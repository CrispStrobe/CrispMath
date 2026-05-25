// test/precision_test.dart
//
// Rounds 85 + 86 (precision arc) — end-to-end tests for pi(N),
// e(N), EulerGamma(N), sqrt(2, N). Exercises the three-repo chain
// (math-stack-ios-builder C wrapper → symbolic_math_bridge Dart
// FFI → CrispCalc engine binding) by asking for each constant at
// several precisions and verifying against known reference prefixes.
//
// Each test skips silently when the native bridge isn't available
// (Linux CI runs without the macOS xcframework). Detection: the
// engine method returns the standard double-precision fallback,
// which is the inlined `_*Fallback` constant for that test group.

import 'package:crisp_calc/engine/calculator_engine.dart';
import 'package:flutter_test/flutter_test.dart';

// Reference prefixes (≥ 100 decimal digits).
// Sources: https://oeis.org for π, e, γ; computed from MPFR for √2.
const _piRef = '3.141592653589793238462643383279502884197169399375105820974944'
    '5923078164062862089986280348253421170679';
const _piFallback = '3.141592653589793';

const _eRef = '2.7182818284590452353602874713526624977572470936999595749669676'
    '27724076630353547594571382178525166427';
const _eFallback = '2.718281828459045';

const _eulerGammaRef =
    '0.57721566490153286060651209008240243104215933593992359880576723'
    '48848677267776646709369470632917467495';
const _eulerGammaFallback = '0.5772156649015329';

// √2 ≈ 1.41421356... (computed with MPFR / OEIS A002193).
const _sqrt2Ref =
    '1.4142135623730950488016887242096980785696718753769480731766797'
    '37990732478462107038850387534327641573';
const _sqrt2Fallback = '1.4142135623730951';

void main() {
  final engine = CalculatorEngine();

  // Per-constant smoke test factory. [getter] takes the digit count
  // and returns the precision string; [ref] is the reference prefix;
  // [fallback] is the double-precision string returned when the
  // bridge isn't loaded — when [getter] returns it, we skip.
  void runPrecisionGroup({
    required String label,
    required String Function(int) getter,
    required String ref,
    required String fallback,
  }) {
    group('CalculatorEngine.get${label}WithPrecision', () {
      test('$label(50) returns the first 50 decimal digits', () {
        final result = getter(50);
        if (result == fallback) return; // headless skip
        expect(result.length, greaterThanOrEqualTo(51),
            reason: '$label(50) too short: $result');
        expect(result.substring(0, 52), ref.substring(0, 52),
            reason: '$label(50) prefix mismatch');
      });

      test('$label(100) returns the first 100 decimal digits', () {
        final result = getter(100);
        if (result == fallback) return;
        expect(result.length, greaterThanOrEqualTo(101),
            reason: '$label(100) too short: $result');
        expect(result.substring(0, 102), ref.substring(0, 102),
            reason: '$label(100) prefix mismatch');
      });

      test('$label(0) rejected with ArgumentError', () {
        expect(() => getter(0), throwsArgumentError);
      });

      test('$label(10001) rejected with ArgumentError', () {
        expect(() => getter(10001), throwsArgumentError);
      });
    });
  }

  // Round 85.
  runPrecisionGroup(
    label: 'pi',
    getter: engine.getPiWithPrecision,
    ref: _piRef,
    fallback: _piFallback,
  );

  // pi(500) — round-85 stress test, kept separate because it asserts
  // result-length-not-just-prefix.
  group('CalculatorEngine.getpiWithPrecision (extras)', () {
    test('pi(500) has enough digits and the first 100 still match', () {
      final result = engine.getPiWithPrecision(500);
      if (result == _piFallback) return;
      expect(result.length, greaterThanOrEqualTo(501),
          reason: 'pi(500) too short: $result');
      expect(result.substring(0, 102), _piRef.substring(0, 102),
          reason: 'pi(500) first 100 digits should still match pi');
    });
  });

  // Round 86.
  runPrecisionGroup(
    label: 'e',
    getter: engine.getEWithPrecision,
    ref: _eRef,
    fallback: _eFallback,
  );

  runPrecisionGroup(
    label: 'eulerGamma',
    getter: engine.getEulerGammaWithPrecision,
    ref: _eulerGammaRef,
    fallback: _eulerGammaFallback,
  );

  runPrecisionGroup(
    label: 'sqrt2',
    getter: engine.getSqrt2WithPrecision,
    ref: _sqrt2Ref,
    fallback: _sqrt2Fallback,
  );
}
