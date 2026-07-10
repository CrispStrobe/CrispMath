// Live integration test for CrispAssist with real API providers.
// Requires SCALEWAY_API_KEY or MISTRAL_API_KEY environment variable.
// Run with: dart test test/crisp_assist_live_test.dart
//
// Skipped in CI (no API keys). Run manually for live validation.
@Tags(['live'])
library;

import 'dart:io';

import 'package:crisp_math/services/crisp_assist_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final scalewayKey = Platform.environment['SCALEWAY_API_KEY'] ?? '';
  final mistralKey = Platform.environment['MISTRAL_API_KEY'] ?? '';

  final hasScaleway = scalewayKey.isNotEmpty;
  final hasMistral = mistralKey.isNotEmpty;

  group('CrispAssist live — Scaleway',
      skip: !hasScaleway ? 'no SCALEWAY_API_KEY' : null, () {
    late CrispAssistService service;
    late CrispAssistConfig config;

    setUp(() {
      service = CrispAssistService();
      config = CrispAssistConfig(
        apiUrl: 'https://api.scaleway.ai/v1/chat/completions',
        apiKey: scalewayKey,
        model: 'llama-3.1-8b-instruct',
        timeout: const Duration(seconds: 30),
      );
    });
    tearDown(() => service.dispose());

    test('translate: derivative of x squared', () async {
      final result = await service.translate(
        userInput: 'derivative of x squared',
        config: config,
      );
      expect(
          result.toLowerCase(),
          anyOf(
            contains('diff'),
            contains('2*x'),
            contains('2x'),
            contains('deriv'),
          ));
    });

    test('explain: x^2 = 4', () async {
      final result = await service.explain(
        expression: 'solve(x^2-4, x)',
        result: '{-2, 2}',
        config: config,
      );
      expect(result, isNotEmpty);
      expect(result.length, greaterThan(20));
    });
  });

  group('CrispAssist live — Mistral',
      skip: !hasMistral ? 'no MISTRAL_API_KEY' : null, () {
    late CrispAssistService service;
    late CrispAssistConfig config;

    setUp(() {
      service = CrispAssistService();
      config = CrispAssistConfig(
        apiUrl: 'https://api.mistral.ai/v1/chat/completions',
        apiKey: mistralKey,
        model: 'mistral-small-latest',
        timeout: const Duration(seconds: 30),
      );
    });
    tearDown(() => service.dispose());

    test('translate: integral of sin x', () async {
      final result = await service.translate(
        userInput: 'integral of sin x',
        config: config,
      );
      expect(
          result.toLowerCase(),
          anyOf(
            contains('integrate'),
            contains('int'),
            contains('-cos'),
          ));
    });

    test('translate: solve 3x plus 7 equals zero', () async {
      final result = await service.translate(
        userInput: 'solve 3x plus 7 equals zero',
        config: config,
      );
      expect(
          result.toLowerCase(),
          anyOf(
            contains('solve'),
            contains('3*x'),
            contains('3x'),
          ));
    });
  });
}
