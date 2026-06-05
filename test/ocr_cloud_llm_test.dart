import 'dart:typed_data';

import 'package:crisp_calc/engine/ocr_cloud_llm.dart';
import 'package:crisp_calc/engine/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CloudLlmOcrProvider', () {
    late CloudLlmOcrProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await AppState().load(force: true);
      provider = CloudLlmOcrProvider();
    });

    test('name identifies the provider', () {
      expect(provider.name, contains('Cloud'));
    });

    test('requiresNetwork is true', () {
      expect(provider.requiresNetwork, isTrue);
    });

    test('requiresApiKey is true', () {
      expect(provider.requiresApiKey, isTrue);
    });

    test('isAvailable is false without API key', () {
      expect(provider.isAvailable, isFalse);
    });

    test('isAvailable is true with API key configured', () async {
      SharedPreferences.setMockInitialValues({
        'crisp.copilot.apiUrl': 'https://api.anthropic.com/v1/messages',
        'crisp.copilot.apiKey': 'sk-test',
      });
      await AppState().load(force: true);
      expect(provider.isAvailable, isTrue);
    });

    test('recognize returns null when not available', () async {
      final result = await provider.recognize(
        Uint8List.fromList([0, 0, 0]),
        1,
        1,
      );
      expect(result, isNull);
    });
  });
}
