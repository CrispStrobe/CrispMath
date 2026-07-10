// test/worked_examples_localization_test.dart
//
// Every catalog entry must have a non-empty translated title and
// description in every non-English locale. EN intentionally returns
// null (the catalog itself is the source of truth for English text
// and the dialog falls back to it). A missing DE/FR/ES translation
// fails CI rather than silently shipping mixed-language UI.

import 'package:crisp_math/engine/worked_examples.dart';
import 'package:crisp_math/localization/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final locales = <String, AppLocalizations>{
    'de': const DeLocalizations(),
    'fr': const FrLocalizations(),
    'es': const EsLocalizations(),
  };

  for (final entry in locales.entries) {
    final tag = entry.key;
    final t = entry.value;

    group('$tag locale translates every worked-example entry', () {
      for (final e in WorkedExamples.all) {
        test('${e.id}: title', () {
          final title = t.workedExampleTitle(e.id);
          expect(title, isNotNull,
              reason: 'Locale $tag missing title for ${e.id}');
          expect(title!.trim(), isNotEmpty);
        });

        test('${e.id}: description', () {
          final desc = t.workedExampleDescription(e.id);
          expect(desc, isNotNull,
              reason: 'Locale $tag missing description for ${e.id}');
          expect(desc!.trim(), isNotEmpty);
        });
      }
    });
  }

  test('English returns null for unknown ids', () {
    const t = EnLocalizations();
    expect(t.workedExampleTitle('bogus'), isNull);
    expect(t.workedExampleDescription('bogus'), isNull);
  });
}
