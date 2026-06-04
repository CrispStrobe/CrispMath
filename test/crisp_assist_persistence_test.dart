import 'package:crisp_calc/engine/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // Reset singleton state between tests.
    final s = AppState();
    s.history.clear();
    s.userVariables.clear();
  });

  group('CrispAssist AppState persistence', () {
    test('defaults are empty / default model', () async {
      SharedPreferences.setMockInitialValues({});
      final s = AppState();
      await s.load(force: true);
      expect(s.crispAssistApiUrl, isEmpty);
      expect(s.crispAssistApiKey, isEmpty);
      expect(s.crispAssistModel, 'claude-sonnet-4-20250514');
      expect(s.crispAssistEnabled, isFalse);
    });

    test('load() picks up stored values', () async {
      SharedPreferences.setMockInitialValues({
        'crisp.copilot.apiUrl': 'https://api.anthropic.com/v1/messages',
        'crisp.copilot.apiKey': 'sk-ant-test-key',
        'crisp.copilot.model': 'claude-haiku-4-5-20251001',
      });
      final s = AppState();
      await s.load(force: true);
      expect(s.crispAssistApiUrl,
          'https://api.anthropic.com/v1/messages');
      expect(s.crispAssistApiKey, 'sk-ant-test-key');
      expect(s.crispAssistModel, 'claude-haiku-4-5-20251001');
      expect(s.crispAssistEnabled, isTrue);
    });

    test('setCrispAssistApiUrl() writes through', () async {
      SharedPreferences.setMockInitialValues({});
      final s = AppState();
      await s.load(force: true);
      s.setCrispAssistApiUrl('https://api.openai.com/v1/chat/completions');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('crisp.copilot.apiUrl'),
          'https://api.openai.com/v1/chat/completions');
    });

    test('setCrispAssistApiKey() writes through', () async {
      SharedPreferences.setMockInitialValues({});
      final s = AppState();
      await s.load(force: true);
      s.setCrispAssistApiKey('sk-test-123');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('crisp.copilot.apiKey'), 'sk-test-123');
    });

    test('setCrispAssistModel() writes through', () async {
      SharedPreferences.setMockInitialValues({});
      final s = AppState();
      await s.load(force: true);
      s.setCrispAssistModel('gpt-4o');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('crisp.copilot.model'), 'gpt-4o');
    });

    test('crispAssistEnabled requires both URL and key', () async {
      SharedPreferences.setMockInitialValues({});
      final s = AppState();
      await s.load(force: true);

      // Only URL → disabled
      s.setCrispAssistApiUrl('https://api.anthropic.com/v1/messages');
      expect(s.crispAssistEnabled, isFalse);

      // URL + key → enabled
      s.setCrispAssistApiKey('sk-test');
      expect(s.crispAssistEnabled, isTrue);

      // Clear key → disabled again
      s.setCrispAssistApiKey('');
      expect(s.crispAssistEnabled, isFalse);
    });

    test('setters are no-op when value unchanged', () async {
      SharedPreferences.setMockInitialValues({});
      final s = AppState();
      await s.load(force: true);
      int notifyCount = 0;
      s.addListener(() => notifyCount++);

      s.setCrispAssistApiUrl('https://test.com');
      expect(notifyCount, 1);
      s.setCrispAssistApiUrl('https://test.com'); // same value
      expect(notifyCount, 1); // no extra notification

      s.setCrispAssistApiKey('key1');
      expect(notifyCount, 2);
      s.setCrispAssistApiKey('key1');
      expect(notifyCount, 2);

      s.setCrispAssistModel('model1');
      expect(notifyCount, 3);
      s.setCrispAssistModel('model1');
      expect(notifyCount, 3);

      s.removeListener(() {}); // cleanup
    });

    test('load(force: true) resets to defaults then reads', () async {
      SharedPreferences.setMockInitialValues({
        'crisp.copilot.apiUrl': 'https://first.com',
        'crisp.copilot.apiKey': 'key-1',
      });
      final s = AppState();
      await s.load(force: true);
      expect(s.crispAssistApiUrl, 'https://first.com');

      // Now load with different values
      SharedPreferences.setMockInitialValues({
        'crisp.copilot.apiUrl': 'https://second.com',
        'crisp.copilot.apiKey': 'key-2',
        'crisp.copilot.model': 'custom-model',
      });
      await s.load(force: true);
      expect(s.crispAssistApiUrl, 'https://second.com');
      expect(s.crispAssistApiKey, 'key-2');
      expect(s.crispAssistModel, 'custom-model');
    });
  });
}
