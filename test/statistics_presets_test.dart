import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_calc/engine/statistics_presets.dart';

void main() {
  group('StatisticsPresets catalog', () {
    test('has 13 presets', () {
      expect(StatisticsPresets.all.length, 13);
    });

    test('all presets have non-empty ids', () {
      for (final id in StatisticsPresets.all.keys) {
        expect(id.isNotEmpty, true, reason: 'preset id should not be empty');
      }
    });

    test('all presets have a valid tab', () {
      const validTabs = {'descriptive', 'regression', 'distributions', 'tests'};
      for (final entry in StatisticsPresets.all.entries) {
        expect(validTabs.contains(entry.value.tab), true,
            reason: '${entry.key} has invalid tab "${entry.value.tab}"');
      }
    });

    test('tests-tab presets have a testId', () {
      for (final entry in StatisticsPresets.all.entries) {
        if (entry.value.tab == 'tests') {
          expect(entry.value.testId, isNotNull,
              reason: '${entry.key} on tests tab should have a testId');
          expect(entry.value.testId!.isNotEmpty, true);
        }
      }
    });

    test('non-tests-tab presets have no testId', () {
      for (final entry in StatisticsPresets.all.entries) {
        if (entry.value.tab != 'tests') {
          expect(entry.value.testId, isNull,
              reason:
                  '${entry.key} on ${entry.value.tab} tab should have null testId');
        }
      }
    });

    test('all presets have at least one field', () {
      for (final entry in StatisticsPresets.all.entries) {
        expect(entry.value.fields.isNotEmpty, true,
            reason: '${entry.key} should have fields');
      }
    });

    test('all field values are non-empty strings', () {
      for (final entry in StatisticsPresets.all.entries) {
        for (final field in entry.value.fields.entries) {
          expect(field.value.isNotEmpty, true,
              reason: '${entry.key}.${field.key} should be non-empty');
        }
      }
    });

    test('numeric field values parse as numbers', () {
      // All field values should contain parseable numbers (possibly
      // comma/space/newline separated)
      for (final entry in StatisticsPresets.all.entries) {
        for (final field in entry.value.fields.entries) {
          final value = field.value;
          // Split on comma, space, newline
          final tokens = value.split(RegExp(r'[,\s\n]+'))
            ..removeWhere((s) => s.isEmpty);
          for (final token in tokens) {
            expect(double.tryParse(token), isNotNull,
                reason:
                    '${entry.key}.${field.key} token "$token" is not numeric');
          }
        }
      }
    });

    test('testId values are unique', () {
      final testIds = StatisticsPresets.all.values
          .where((p) => p.testId != null)
          .map((p) => p.testId!)
          .toList();
      expect(testIds.length, testIds.toSet().length,
          reason: 'testId values should be unique');
    });

    test('specific presets route to correct tabs', () {
      expect(StatisticsPresets.all['statsDescriptive']!.tab, 'descriptive');
      expect(StatisticsPresets.all['statsLinearRegression']!.tab, 'regression');
      expect(
          StatisticsPresets.all['statsNormalDist']!.tab, 'distributions');
      expect(
          StatisticsPresets.all['statsWelchTwoSample']!.tab, 'tests');
    });

    test('alpha field is present on all tests-tab presets', () {
      for (final entry in StatisticsPresets.all.entries) {
        if (entry.value.tab == 'tests') {
          expect(entry.value.fields.containsKey('alpha'), true,
              reason: '${entry.key} should have alpha field');
          final alpha = double.tryParse(entry.value.fields['alpha']!);
          expect(alpha, isNotNull);
          expect(alpha! > 0 && alpha < 1, true,
              reason: '${entry.key} alpha should be between 0 and 1');
        }
      }
    });
  });
}
