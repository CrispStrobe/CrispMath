// lib/services/crisp_assist_service.dart
//
// CrispAssist — AI assistant service, verifier-frontend, never solver.
//
// CrispAssist translates natural-language input into engine syntax,
// narrates step traces, and explains results. Hard guardrail: the LLM
// is never asked "what's the answer" — all computation goes through
// SymEngine. CrispAssist only describes, translates, and explains.
//
// Uses an OpenAI-compatible chat completions API (works with Claude,
// OpenAI, local servers like llama.cpp). User supplies their own key.
//
// Follows CrisperWeaver's patterns: config value objects passed at
// call time, cancellation tokens, per-call error handling.
// Renamed from "Copilot" to "CrispAssist" to avoid trademark issues.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../engine/step_engine.dart';

// ---------------------------------------------------------------------------
// Config
// ---------------------------------------------------------------------------

/// Immutable config for a CrispAssist API call. Constructed from AppState
/// settings at call time — the service itself is stateless.
class CrispAssistConfig {
  const CrispAssistConfig({
    required this.apiUrl,
    required this.apiKey,
    this.model = 'claude-sonnet-4-20250514',
    this.timeout = const Duration(seconds: 60),
    this.maxOutputTokens = 1024,
    this.temperature = 0.0,
  });

  final String apiUrl;
  final String apiKey;
  final String model;
  final Duration timeout;
  final int maxOutputTokens;
  final double temperature;

  /// Ready to make API calls?
  bool get enabled => apiUrl.isNotEmpty && apiKey.isNotEmpty;
}

// ---------------------------------------------------------------------------
// Cancellation
// ---------------------------------------------------------------------------

class CrispAssistCancelToken {
  bool cancelled = false;
  void cancel() => cancelled = true;
}

// ---------------------------------------------------------------------------
// Exceptions
// ---------------------------------------------------------------------------

class CrispAssistDisabledException implements Exception {
  final String reason;
  const CrispAssistDisabledException(this.reason);
  @override
  String toString() => 'CrispAssistDisabledException: $reason';
}

class CrispAssistHttpException implements Exception {
  final int statusCode;
  final String body;
  CrispAssistHttpException(this.statusCode, this.body);
  @override
  String toString() => 'CrispAssistHttpException(status=$statusCode): $body';
}

// ---------------------------------------------------------------------------
// System prompts — static, deterministic, verifier-only
// ---------------------------------------------------------------------------

class _Prompts {
  _Prompts._();

  /// Core identity. Every CrispAssist call includes this.
  static const system = '''
You are CrispAssist — a math assistant embedded in a CAS calculator app.

HARD RULES:
- You are a VERIFIER and EXPLAINER, never a solver.
- NEVER compute answers yourself. All computation is done by the SymEngine CAS.
- When asked to translate input, emit ONLY the engine expression — no commentary.
- When explaining, describe what the engine did and why, step by step.
- Be concise. Students read this on a phone screen.
- Use LaTeX notation (\\frac{}{}, \\sqrt{}, etc.) for math in explanations.
- If you are unsure about a translation, say so — do not guess.

ENGINE SYNTAX REFERENCE:
- Arithmetic: +, -, *, /, ^ (power), ! (factorial)
- Functions: sin, cos, tan, asin, acos, atan, exp, log (=ln), sqrt, abs
- Calculus: diff(expr, var), integrate(expr, var), limit(expr, var, point)
- Algebra: solve(expr, var), factor(expr), expand(expr), simplify(expr)
- Constants: pi, E (Euler), oo (infinity)
- Variables: single-letter (x, y, t, n) or multi-letter identifiers
- Implicit multiplication: "2x" = "2*x", "xy" = "x*y"
''';

  /// Prompt for translating natural language to engine syntax.
  static const translate = '''
Translate the user's natural-language math request into CrispMath engine syntax.
Respond with ONLY the engine expression — no explanation, no markdown fences, no commentary.
If the request is ambiguous, give the most likely interpretation.
If the request is not a math expression, respond with: ERROR: <brief reason>
''';

  /// Prompt for explaining a result.
  static const explain = '''
The user entered an expression into CrispMath and got a result from SymEngine.
Explain what the result means and how it was computed, in 2-4 sentences.
Use LaTeX for any math notation. Be concise and clear.
''';

  /// Prompt for narrating a step trace.
  static const narrate = '''
The user asked CrispMath for a step-by-step derivation. Below are the steps
produced by the step engine. Narrate them in clear, student-friendly language.
For each step, explain WHY that rule applies and WHAT it does to the expression.
Use LaTeX for math. Keep each step explanation to 1-2 sentences.
''';
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class CrispAssistService {
  CrispAssistService();

  HttpClient? _client;

  HttpClient get _http => _client ??= HttpClient();

  void dispose() {
    _client?.close();
    _client = null;
  }

  // ---- Public API --------------------------------------------------------

  /// Translate natural language to engine syntax.
  /// Returns the raw engine expression string.
  Future<String> translate({
    required String userInput,
    required CrispAssistConfig config,
  }) async {
    if (!config.enabled) {
      throw const CrispAssistDisabledException('apiUrl or apiKey is empty');
    }
    final messages = [
      {'role': 'system', 'content': _Prompts.system},
      {'role': 'system', 'content': _Prompts.translate},
      {'role': 'user', 'content': userInput},
    ];
    return _chatCompletion(messages: messages, config: config);
  }

  /// Explain a computation result.
  Future<String> explain({
    required String expression,
    required String result,
    required CrispAssistConfig config,
  }) async {
    if (!config.enabled) {
      throw const CrispAssistDisabledException('apiUrl or apiKey is empty');
    }
    final messages = [
      {'role': 'system', 'content': _Prompts.system},
      {'role': 'system', 'content': _Prompts.explain},
      {
        'role': 'user',
        'content': 'Expression: $expression\nResult: $result',
      },
    ];
    return _chatCompletion(messages: messages, config: config);
  }

  /// Narrate a step-by-step trace from the StepEngine.
  Future<String> narrateSteps({
    required String expression,
    required List<MathStep> steps,
    required CrispAssistConfig config,
  }) async {
    if (!config.enabled) {
      throw const CrispAssistDisabledException('apiUrl or apiKey is empty');
    }
    final stepsText = StringBuffer();
    for (var i = 0; i < steps.length; i++) {
      final s = steps[i];
      stepsText.writeln('Step ${i + 1}: ${s.rule}');
      if (s.formula.isNotEmpty) stepsText.writeln('  Rule: ${s.formula}');
      stepsText.writeln('  Before: ${s.before}');
      stepsText.writeln('  After: ${s.after}');
      if (s.note != null) stepsText.writeln('  Note: ${s.note}');
    }
    final messages = [
      {'role': 'system', 'content': _Prompts.system},
      {'role': 'system', 'content': _Prompts.narrate},
      {
        'role': 'user',
        'content': 'Original expression: $expression\n\nSteps:\n$stepsText',
      },
    ];
    return _chatCompletion(messages: messages, config: config);
  }

  /// Stream a chat completion (yields partial content chunks).
  /// Useful for showing progressive output in the UI.
  Stream<String> streamExplain({
    required String expression,
    required String result,
    required CrispAssistConfig config,
    CrispAssistCancelToken? cancel,
  }) {
    if (!config.enabled) {
      return Stream.error(
          const CrispAssistDisabledException('apiUrl or apiKey is empty'));
    }
    final messages = [
      {'role': 'system', 'content': _Prompts.system},
      {'role': 'system', 'content': _Prompts.explain},
      {
        'role': 'user',
        'content': 'Expression: $expression\nResult: $result',
      },
    ];
    return _streamChatCompletion(
      messages: messages,
      config: config,
      cancel: cancel,
    );
  }

  // ---- Private -----------------------------------------------------------

  /// One-shot chat completion (non-streaming).
  Future<String> _chatCompletion({
    required List<Map<String, String>> messages,
    required CrispAssistConfig config,
  }) async {
    final uri = Uri.parse(config.apiUrl);
    final isAnthropic = uri.host.contains('anthropic');

    final body = isAnthropic
        ? _buildAnthropicBody(messages, config)
        : _buildOpenAiBody(messages, config);

    final request = await _http.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    if (isAnthropic) {
      request.headers.set('x-api-key', config.apiKey);
      request.headers.set('anthropic-version', '2023-06-01');
    } else {
      request.headers.set('Authorization', 'Bearer ${config.apiKey}');
    }
    request.add(utf8.encode(body));

    final response = await request.close().timeout(config.timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorBody = await response.transform(utf8.decoder).join();
      throw CrispAssistHttpException(response.statusCode, errorBody);
    }

    final responseBody = await response.transform(utf8.decoder).join();
    final decoded = jsonDecode(responseBody);
    return _extractContent(decoded, isAnthropic);
  }

  /// Streaming chat completion — yields content delta strings.
  Stream<String> _streamChatCompletion({
    required List<Map<String, String>> messages,
    required CrispAssistConfig config,
    CrispAssistCancelToken? cancel,
  }) async* {
    final uri = Uri.parse(config.apiUrl);
    final isAnthropic = uri.host.contains('anthropic');

    final body = isAnthropic
        ? _buildAnthropicBody(messages, config, stream: true)
        : _buildOpenAiBody(messages, config, stream: true);

    final request = await _http.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    if (isAnthropic) {
      request.headers.set('x-api-key', config.apiKey);
      request.headers.set('anthropic-version', '2023-06-01');
    } else {
      request.headers.set('Authorization', 'Bearer ${config.apiKey}');
    }
    request.add(utf8.encode(body));

    final response = await request.close().timeout(config.timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorBody = await response.transform(utf8.decoder).join();
      throw CrispAssistHttpException(response.statusCode, errorBody);
    }

    // Parse SSE stream.
    await for (final chunk in response.transform(utf8.decoder)) {
      if (cancel?.cancelled ?? false) break;
      for (final line in chunk.split('\n')) {
        if (!line.startsWith('data: ')) continue;
        final data = line.substring(6).trim();
        if (data == '[DONE]') return;
        try {
          final event = jsonDecode(data);
          final delta = isAnthropic
              ? _extractAnthropicDelta(event)
              : _extractOpenAiDelta(event);
          if (delta.isNotEmpty) yield delta;
        } catch (_) {
          // Skip malformed SSE lines.
        }
      }
    }
  }

  // ---- Body builders -----------------------------------------------------

  String _buildOpenAiBody(
    List<Map<String, String>> messages,
    CrispAssistConfig config, {
    bool stream = false,
  }) {
    return jsonEncode(<String, dynamic>{
      'model': config.model,
      'messages': messages,
      'temperature': config.temperature,
      'max_tokens': config.maxOutputTokens,
      if (stream) 'stream': true,
    });
  }

  String _buildAnthropicBody(
    List<Map<String, String>> messages,
    CrispAssistConfig config, {
    bool stream = false,
  }) {
    // Anthropic Messages API: system is top-level, not in messages.
    final systemParts = <String>[];
    final userMessages = <Map<String, String>>[];
    for (final m in messages) {
      if (m['role'] == 'system') {
        systemParts.add(m['content']!);
      } else {
        userMessages.add(m);
      }
    }
    return jsonEncode(<String, dynamic>{
      'model': config.model,
      'system': systemParts.join('\n\n'),
      'messages': userMessages,
      'temperature': config.temperature,
      'max_tokens': config.maxOutputTokens,
      if (stream) 'stream': true,
    });
  }

  // ---- Response extraction -----------------------------------------------

  String _extractContent(Map<String, dynamic> decoded, bool isAnthropic) {
    if (isAnthropic) {
      final content = decoded['content'] as List?;
      if (content == null || content.isEmpty) {
        throw CrispAssistHttpException(200, 'no content in response');
      }
      return (content[0] as Map)['text'] as String? ?? '';
    }
    // OpenAI format
    final choices = decoded['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw CrispAssistHttpException(200, 'no choices in response');
    }
    final message = choices[0]['message'] as Map?;
    return message?['content'] as String? ?? '';
  }

  String _extractOpenAiDelta(Map<String, dynamic> event) {
    final choices = event['choices'] as List?;
    if (choices == null || choices.isEmpty) return '';
    final delta = choices[0]['delta'] as Map?;
    return delta?['content'] as String? ?? '';
  }

  String _extractAnthropicDelta(Map<String, dynamic> event) {
    final type = event['type'] as String?;
    if (type == 'content_block_delta') {
      final delta = event['delta'] as Map?;
      return delta?['text'] as String? ?? '';
    }
    return '';
  }
}
