import 'dart:convert';

/// App-recorded provenance, separate from executable CAS and LaTeX strings.
/// This is neither a cryptographic signature nor proof of provider origin.
enum AiOutputKind { generatedText, assistedExpression, assistedTranscription }

const _publicProviderHosts = {
  'api.openai.com',
  'api.anthropic.com',
  'api.mistral.ai',
  'api.scaleway.ai',
  'api.tokenfactory.nebius.com',
  'api.studio.nebius.com',
  'api.groq.com',
  'api.cerebras.ai',
  'api.cohere.com',
  'api.cohere.ai',
  'generativelanguage.googleapis.com',
  'api.together.xyz',
  'inference.hetzner.com',
  'opencode.ai',
  'api.x.ai',
  'api.deepseek.com',
  'openrouter.ai',
  'api.perplexity.ai',
  'api.fireworks.ai',
};

String _publicEndpointLabel(String endpoint) {
  final host = Uri.tryParse(endpoint)?.host.toLowerCase() ?? '';
  if (_publicProviderHosts.contains(host)) return host;
  return {'localhost', '127.0.0.1', '::1', '[::1]'}.contains(host)
      ? 'local_endpoint'
      : 'configured_endpoint';
}

String? _publicModelId(Object? value, {bool allowNamespace = false}) {
  if (value is! String ||
      value.isEmpty ||
      value.trim() != value ||
      value.startsWith('/') ||
      value.startsWith('~') ||
      value.contains('\\') ||
      value.contains('://') ||
      (!allowNamespace && value.contains('/')) ||
      RegExp(r'^(file|https?|data|s3|gs):', caseSensitive: false)
          .hasMatch(value) ||
      value.contains('?') ||
      value.contains('#') ||
      value.split('/').length > 2 ||
      value.split('/').contains('..') ||
      value.split('/').contains('.') ||
      RegExp(r'^[A-Za-z]:[/\\]').hasMatch(value) ||
      RegExp(r'\.(gguf|ggml|bin|onnx|safetensors|pt|pth|tflite|mlx)$',
              caseSensitive: false)
          .hasMatch(value)) {
    return null;
  }
  return value;
}

class AiOutputAttribution {
  const AiOutputAttribution({
    required this.kind,
    required this.providerHost,
    required this.requestedModel,
    required this.receivedAt,
    this.responseModel,
  });

  factory AiOutputAttribution.fromResponse({
    required AiOutputKind kind,
    required String endpoint,
    required String requestedModel,
    Object? responseModel,
    DateTime? receivedAt,
  }) {
    final endpointLabel = _publicEndpointLabel(endpoint);
    final publicProvider = _publicProviderHosts.contains(endpointLabel);
    return AiOutputAttribution(
      kind: kind,
      // Private/custom hosts and local model paths stay on the device.
      providerHost: endpointLabel,
      requestedModel:
          _publicModelId(requestedModel, allowNamespace: publicProvider),
      responseModel:
          _publicModelId(responseModel, allowNamespace: publicProvider),
      receivedAt: (receivedAt ?? DateTime.now()).toUtc(),
    );
  }

  final AiOutputKind kind;
  final String providerHost;
  final String? requestedModel;
  final String? responseModel;
  final DateTime receivedAt;

  String get origin => switch (kind) {
        AiOutputKind.generatedText => 'ai_generated',
        AiOutputKind.assistedExpression => 'ai_assisted_expression',
        AiOutputKind.assistedTranscription => 'ai_assisted_transcription',
      };

  Map<String, Object?> toJson() => {
        'origin': origin,
        'provider_host': providerHost,
        if (requestedModel != null) 'requested_model': requestedModel,
        if (responseModel != null) 'response_model': responseModel,
        'received_at': receivedAt.toUtc().toIso8601String(),
        'recorded_by': 'CrispMath',
      };

  /// A portable record. The content is preserved exactly, including newlines.
  String exportJson(String content, {required bool complete}) =>
      const JsonEncoder.withIndent('  ').convert({
        'schema': 'crisp_math.ai_output.v1',
        'content': content,
        'completion': complete ? 'complete' : 'partial_or_unconfirmed',
        'provenance': toJson(),
      });
}
