// CAS regression corpus — native runner (roadmap C1).
//
// Runs the FULL SymPy-certified corpus against the real SymEngine bridge
// (FLINT/GMP/MPFR). Plain `flutter test` is headless and has no bridge,
// so run this on a native target:
//
//   flutter test integration_test/cas_corpus_native_test.dart -d macos
//
// Companion to cas_native_test.dart (which spot-checks bridge-specific
// behaviors); this file asserts independently verified mathematics for
// every corpus case.

import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/cas_corpus_shared.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final engine = CalculatorEngine();
  final cases = loadCorpus();

  group('CAS corpus (native SymEngine bridge)', () {
    setUpAll(() {
      expect(
        engine.isNativeAvailable,
        isTrue,
        reason: 'native bridge not loaded — run with `-d macos` (or '
            'another native device).',
      );
    });

    for (final c in cases.where((c) => c.runners.contains('native'))) {
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
