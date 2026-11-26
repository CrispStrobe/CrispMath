import 'dart:convert';

import 'package:crisp_math/engine/ai_output_attribution.dart';
import 'package:crisp_math/engine/ocr_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'portable provenance preserves exact content and excludes credentials',
    () {
      final attribution = AiOutputAttribution.fromResponse(
        kind: AiOutputKind.generatedText,
        endpoint: 'https://user:secret@example.test/private?key=secret',
        requestedModel: 'requested-model',
        responseModel: 'reported-model',
        receivedAt: DateTime.utc(2026, 1, 2, 3, 4, 5),
      );
      const content = 'An explanation.\n\n  x = 2\n';
      final encoded = attribution.exportJson(content, complete: false);
      final record = jsonDecode(encoded);
      expect(record['content'], content);
      expect(record['completion'], 'partial_or_unconfirmed');
      expect(record['provenance']['provider_host'], 'configured_endpoint');
      expect(record['provenance']['requested_model'], 'requested-model');
      expect(record['provenance']['response_model'], 'reported-model');
      expect(record['provenance']['origin'], 'ai_generated');
      expect(encoded, isNot(contains('secret')));
      expect(encoded, isNot(contains('/private')));
    },
  );

  test(
    'missing response model stays unknown and OCR payloads stay executable',
    () {
      final attribution = AiOutputAttribution.fromResponse(
        kind: AiOutputKind.assistedTranscription,
        endpoint: 'https://example.test/v1/messages',
        requestedModel: 'requested-only',
      );
      final result = OcrResult(
        text: 'sqrt(2)',
        rawOutput: r'\sqrt{2}',
        providerName: 'Cloud OCR',
        attribution: attribution,
      );
      expect(result.text, 'sqrt(2)');
      expect(result.rawOutput, r'\sqrt{2}');
      expect(result.attribution!.origin, 'ai_assisted_transcription');
      expect(
        result.attribution!.toJson().containsKey('response_model'),
        isFalse,
      );
      const local = OcrResult(
        text: '1+1',
        rawOutput: '1+1',
        providerName: 'Local OCR',
      );
      expect(local.attribution, isNull);
    },
  );
  test('private hosts and local model paths never enter portable metadata', () {
    final value = AiOutputAttribution.fromResponse(
      kind: AiOutputKind.generatedText,
      endpoint: 'https://tenant.internal.example/v1',
      requestedModel: '/home/person/private-model.gguf',
      responseModel: 'https://tenant.example/models/private?token=secret',
    );
    final exported = jsonEncode(value.toJson());
    expect(value.providerHost, 'configured_endpoint');
    expect(value.requestedModel, isNull);
    expect(value.responseModel, isNull);
    for (final privatePart in ['tenant', 'person', 'private', 'secret']) {
      expect(exported, isNot(contains(privatePart)));
    }
    final local = AiOutputAttribution.fromResponse(
      kind: AiOutputKind.generatedText,
      endpoint: 'http://localhost:8080',
      requestedModel: 'models/private-model',
    );
    expect(local.providerHost, 'local_endpoint');
    expect(local.requestedModel, isNull);
    final public = AiOutputAttribution.fromResponse(
      kind: AiOutputKind.generatedText,
      endpoint: 'https://api.tokenfactory.nebius.com/v1',
      requestedModel: 'meta-llama/Llama-3.3-70B-Instruct',
    );
    expect(public.providerHost, 'api.tokenfactory.nebius.com');
    expect(public.requestedModel, 'meta-llama/Llama-3.3-70B-Instruct');
  });
}
