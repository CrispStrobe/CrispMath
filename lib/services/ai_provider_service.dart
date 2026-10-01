import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../engine/app_state.dart';
import 'ai_service_interface.dart';

class AiProviderConfig {
  final String endpoint, model, apiKey;
  final Duration timeout;
  const AiProviderConfig(
      {required this.endpoint,
      required this.model,
      this.apiKey = '',
      this.timeout = const Duration(seconds: 45)});
  bool get configured {
    final uri = Uri.tryParse(endpoint);
    return uri != null &&
        ['http', 'https'].contains(uri.scheme) &&
        uri.host.isNotEmpty &&
        model.trim().isNotEmpty;
  }

  factory AiProviderConfig.fromSettings() {
    final state = AppState();
    return AiProviderConfig(
        endpoint: state.crispAssistApiUrl,
        model: state.crispAssistModel,
        apiKey: state.crispAssistApiKey);
  }
}

class AiRequestCancelled implements Exception {
  @override
  String toString() => 'Request cancelled';
}

class AiClarificationRequired implements Exception {
  const AiClarificationRequired(this.question);
  final String question;
  @override
  String toString() => question;
}

/// Uses the configured provider to translate language into a reviewable CAS
/// expression. The calculator, rather than the language model, computes it.
class ProviderAiService implements AiService {
  final AiProviderConfig Function() config;
  final http.Client Function() clientFactory;
  void Function()? _cancelActive;
  ProviderAiService(
      {AiProviderConfig Function()? config,
      http.Client Function()? clientFactory})
      : config = config ?? AiProviderConfig.fromSettings,
        clientFactory = clientFactory ?? http.Client.new;
  @override
  bool get isReady => config().configured;
  @override
  Future<void> initializeOptionalAi() async {
    if (!isReady) {
      throw StateError(
          'Configure the provider endpoint and model in CrispAssist settings.');
    }
  }

  void cancel() => _cancelActive?.call();
  @override
  Future<String> processMathNLP(String text) async {
    final settings = config();
    if (!settings.configured) {
      throw StateError(
          'Configure the provider endpoint and model in CrispAssist settings.');
    }
    if (text.trim().isEmpty) {
      throw ArgumentError('Enter a math question.');
    }
    cancel();
    final client = clientFactory();
    final cancelled = Completer<String>();
    void cancelThis() {
      if (!cancelled.isCompleted) {
        cancelled.completeError(AiRequestCancelled());
      }
      client.close();
    }

    _cancelActive = cancelThis;
    const prompt =
        'Translate the user request into ONE CrispMath CAS expression. Return only the expression, without prose or Markdown. Do not compute its result. Syntax: + - * / ^, sin(x), cos(x), sqrt(x), log(x), integrate(expression,x), diff(expression,x), solve(equation,x). If the request is ambiguous, return CLARIFY: followed by the missing information question instead of inventing an expression.';
    final anthropic = Uri.parse(settings.endpoint).path.endsWith('/messages');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (settings.apiKey.isNotEmpty && !anthropic)
        'Authorization': 'Bearer ${settings.apiKey}',
      if (anthropic) 'anthropic-version': '2023-06-01',
      if (anthropic && settings.apiKey.isNotEmpty) 'x-api-key': settings.apiKey,
    };
    final body = <String, dynamic>{
      'model': settings.model,
      'max_tokens': 512,
      if (anthropic) 'system': prompt,
      'messages': [
        if (!anthropic) {'role': 'system', 'content': prompt},
        {'role': 'user', 'content': text.trim()}
      ],
    };
    Future<String> send() async {
      final response = await client.post(Uri.parse(settings.endpoint),
          headers: headers, body: jsonEncode(body));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError(
            'Provider request failed (HTTP ${response.statusCode}). Check endpoint, credentials and model.');
      }
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('Invalid provider response.');
      }
      final dynamic entries = decoded[anthropic ? 'content' : 'choices'];
      if (entries is! List || entries.isEmpty || entries.first is! Map) {
        throw const FormatException('Provider returned no expression.');
      }
      final Map entry = entries.first as Map;
      if ((!anthropic && entry['finish_reason'] == 'length') ||
          (anthropic && decoded['stop_reason'] == 'max_tokens')) {
        throw const FormatException(
            'Provider response was truncated. Retry with a shorter request or a different model.');
      }
      final dynamic message = entry['message'];
      final dynamic content = anthropic
          ? entry['text']
          : message is Map
              ? message['content']
              : null;
      if (content is! String || content.trim().isEmpty) {
        throw const FormatException('Provider returned no expression.');
      }
      var expression = content.trim();
      if (RegExp(r'</?think>', caseSensitive: false).hasMatch(expression)) {
        throw const FormatException(
            'Provider returned reasoning instead of an expression. Use a model that returns a final answer within the request limit.');
      }
      if (expression.startsWith('```')) {
        expression = expression
            .replaceFirst(RegExp(r'^```[^\n]*\n'), '')
            .replaceFirst(RegExp(r'\n?```$'), '')
            .trim();
      }
      if (expression.isEmpty || expression.length > 4000) {
        throw const FormatException('Provider returned an invalid expression.');
      }
      if (expression.startsWith('CLARIFY:') ||
          (expression.endsWith('?') &&
              RegExp(r'^(what|which|how|please|can|could|provide|specify)\b',
                      caseSensitive: false)
                  .hasMatch(expression))) {
        throw AiClarificationRequired(
            expression.replaceFirst(RegExp(r'^CLARIFY:\s*'), ''));
      }
      return expression;
    }

    try {
      return await Future.any<String>([send(), cancelled.future])
          .timeout(settings.timeout, onTimeout: () {
        client.close();
        throw TimeoutException(
            'Provider timed out. Retry or change the endpoint.');
      });
    } finally {
      if (identical(_cancelActive, cancelThis)) {
        _cancelActive = null;
      }
      client.close();
    }
  }
}
