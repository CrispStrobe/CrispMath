// CAS regression corpus — headless runner (roadmap C1).
//
// Runs the 'dart'-tagged subset of the SymPy-certified corpus against the
// pure-Dart fallback paths (SymbolicWeb, StepEngine, exact Polynomial):
// plain `flutter test` has no native bridge, which is exactly the
// environment the web build's fallbacks see. The full corpus runs against
// real SymEngine in integration_test/cas_corpus_native_test.dart.

import 'package:crisp_calc/engine/calculator_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cas_corpus_shared.dart';

void main() {
  final engine = CalculatorEngine();
  final cases = loadCorpus().where((c) => c.runners.contains('dart')).toList();

  group('CAS corpus (pure-Dart fallback paths)', () {
    test('corpus loads and has dart-tagged cases', () {
      expect(cases, isNotEmpty);
    });

    for (final c in cases) {
      test('${c.op}: ${c.id}', () {
        final got = runOp(engine, c);
        final verdict = checkCase(engine, c, got);
        if (c.knownGap != null) {
          expect(
            verdict,
            isNotNull,
            reason: '[${c.id}] known gap appears RESOLVED — remove its '
                'knownGap flag from the corpus. (${c.knownGap})',
          );
        } else {
          expect(verdict, isNull, reason: '[${c.id}] ${verdict ?? ''}');
        }
      });
    }
  });
}
