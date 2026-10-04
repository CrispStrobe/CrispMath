import 'package:crisp_math/localization/workflow_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every supported locale translates every workflow label and placeholder',
      () {
    expect(WorkflowLocalizations.translations.keys.toSet(),
        {'en', 'de', 'fr', 'es'});
    for (final entry in WorkflowLocalizations.translations.entries) {
      expect(entry.value.keys.toSet(), WorkflowLabel.values.toSet(),
          reason: entry.key);
      for (final label in WorkflowLabel.values) {
        final value = WorkflowLocalizations(entry.key).text(label, 'a');
        expect(value.trim(), isNotEmpty);
        expect(value, isNot(contains('{value}')));
      }
      if (entry.key != 'en') {
        expect(
            entry.value.entries
                .where((item) =>
                    item.value !=
                    WorkflowLocalizations.translations['en']![item.key])
                .length,
            greaterThan(WorkflowLabel.values.length * .85),
            reason: entry.key);
      }
    }
    expect(const WorkflowLocalizations('it').text(WorkflowLabel.evaluate),
        'Evaluate');
  });
}
