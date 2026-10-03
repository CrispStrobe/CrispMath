import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

// Supported real numerical limits use the Dart evaluator when the native
// bridge is unavailable. Mathematical rejection and approximate evidence
// remain distinct from exact polynomial integration.

void main() {
  final engine = CalculatorEngine();

  group('limit() — fallback when native unavailable', () {
    test('returns an error string (not a crash)', () {
      final result = engine.limit('1/x', 'x', '0');
      expect(result, isA<String>());
      expect(result, startsWith('Error'));
    });

    test('reciprocal tends to zero at positive infinity with approximate evidence', () {
      final result = engine.limit('1/x', 'x', 'oo');
      expect(result, '0');
      expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.approximate);
      expect(engine.lastResultEvidence?.method, ComputationMethod.numericFallback);
    });

    test('reciprocal tends to zero at negative infinity with approximate evidence', () {
      final result = engine.limit('1/x', 'x', '-oo');
      expect(result, '0');
      expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.approximate);
      expect(engine.lastResultEvidence?.method, ComputationMethod.numericFallback);
    });
  });

  group('integrate() — fallback / validation', () {
    test('polynomial definite integral resolves without the native bridge', () {
      // The C wrapper stubs integrate(); the polynomial case is computed
      // exactly in Dart, so a definite integral works even with no bridge.
      final result = engine.integrate('x', 'x', '0', '1');
      expect(result, '1/2'); // ∫₀¹ x dx
    });

    test('indefinite integral resolves without the native bridge', () {
      // Exact Dart antiderivative for polynomials, plus the StepEngine rule
      // walker for standard trig/exp — all bridge-free. Only non-elementary
      // integrands (no antiderivative rule) still error.
      expect(engine.integrate('x', 'x'), '1/2x^2 + C');
      expect(engine.integrate('sin(x)', 'x'), '-cos(x) + C');
      if (!engine.isNativeAvailable) {
        expect(engine.integrate('exp(x^2)', 'x'), startsWith('Error'));
      }
    });

    test(
        'definite integration returns a string (numerical fallback or '
        'symbolic FTC)', () {
      // Bridge isn't loaded in tests — the helper returns the "requires
      // native library" sentinel. The point of this test is to make sure
      // the new code path doesn't throw.
      final result = engine.integrate('x^2', 'x', '0', '1');
      expect(result, isA<String>());
      expect(result, isNotEmpty);
    });
  });
}
