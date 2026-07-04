// Unit tests for the exact rational-function integrator (roadmap C3).
// Headless: factoring falls back to rational-root extraction + deg ≤ 2
// remainders. Results are validated structurally here; the SymPy-certified
// corpus checks the mathematics (difference-is-constant sampling).

import 'package:crisp_calc/engine/calculator_engine.dart';
import 'package:crisp_calc/engine/numeric_fallback.dart';
import 'package:crisp_calc/engine/rational_integrator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final engine = CalculatorEngine();

  String? integrate(String expr) =>
      RationalIntegrator.integrate(engine, expr, 'x');

  /// d/dx of [anti] at [x], via central difference on the numeric parser.
  double dNum(String anti, double x) {
    const h = 1e-6;
    double at(double t) =>
        NumericFallbackEvaluator.evalNumeric(anti, {'x': t}) ?? double.nan;
    return (at(x + h) - at(x - h)) / (2 * h);
  }

  /// The integrator's own correctness oracle: derivative of the result
  /// must match the integrand numerically wherever both are defined.
  void expectAntiderivative(String integrand, {List<double>? points}) {
    final anti = integrate(integrand);
    expect(anti, isNotNull, reason: 'no result for $integrand');
    var checked = 0;
    for (final x in points ?? const [0.3, 1.7, 2.9]) {
      final d = dNum(anti!, x);
      final f = NumericFallbackEvaluator.evalNumeric(integrand, {'x': x}) ??
          double.nan;
      if (d.isNaN || f.isNaN) continue;
      expect((d - f).abs(), lessThan(1e-4 * (1 + f.abs())),
          reason: '$integrand: d/dx($anti) at $x gave $d, expected $f');
      checked++;
    }
    expect(checked, greaterThanOrEqualTo(2),
        reason: 'too few checkable points for $integrand -> $anti');
  }

  group('RationalIntegrator', () {
    test('distinct linear factors -> logs', () {
      final r = integrate('1/(x^2 - 1)')!;
      // Term order follows the factor enumeration (differs between the
      // native FLINT and headless RRT paths) — assert both terms.
      expect(r, contains('1/2*log(x - 1)'));
      expect(r, contains('1/2*log(x + 1)'));
      expect(r, contains('-')); // one of them is negative
    });

    test('irreducible quadratic -> atan', () {
      expect(integrate('1/(x^2 + x + 1)'), '2/sqrt(3)*atan((2*x + 1)/sqrt(3))');
    });

    test('double root -> pure rational part (Hermite)', () {
      expect(integrate('1/(x^2 - 2*x + 1)'), '-1/(x - 1)');
    });

    test('polynomial part is split off', () {
      final r = integrate('(x^3 + 1)/x^2');
      expect(r, contains('1/2*x^2'));
      expectAntiderivative('(x^3 + 1)/x^2');
    });

    test('mixed log + atan numerator', () {
      expectAntiderivative('(2*x + 3)/(x^2 + x + 1)');
      expect(integrate('(2*x + 3)/(x^2 + x + 1)'), contains('atan'));
      expect(
          integrate('(2*x + 3)/(x^2 + x + 1)'), contains('log(x^2 + x + 1)'));
    });

    test('real irrational quadratic -> log quotient with exact surd', () {
      final r = integrate('1/(x^2 - 1/3)');
      expect(r, isNotNull);
      expect(r, contains('log'));
      expect(r, contains('sqrt'));
      expectAntiderivative('1/(x^2 - 1/3)', points: [0.8, 1.5, 2.5]);
    });

    test('repeated factor with nontrivial numerator', () {
      expectAntiderivative('x/(x^2 - 2*x + 1)', points: [1.5, 2.2, 3.0]);
    });

    test('higher multiplicity', () {
      expectAntiderivative('1/(x - 2)^3', points: [2.5, 3.1, 4.0]);
      expectAntiderivative('(x + 1)/(x^3 + 2*x^2 + x)',
          points: [0.5, 1.5, 2.5]); // x(x+1)^2
    });

    test('Rothstein-Trager: log of an irreducible cubic denominator', () {
      // numerator = D' → ∫ D'/D = log D, even though D is irreducible.
      expect(integrate('(3*x^2 + 1)/(x^3 + x + 1)'), 'log(x^3 + x + 1)');
      expectAntiderivative('(3*x^2 + 1)/(x^3 + x + 1)',
          points: [0.4, 1.2, 2.3]);
    });

    test('Rothstein-Trager: quartic denominator', () {
      expect(integrate('(4*x^3 + 1)/(x^4 + x + 5)'), 'log(x^4 + x + 5)');
      expectAntiderivative('(4*x^3 + 1)/(x^4 + x + 5)',
          points: [0.5, 1.5, 2.5]);
    });

    test('genuinely algebraic (RootSum) case falls through to null', () {
      // 1/(x^3 + x + 1): irreducible cubic, numerator ≠ c·D' → the log
      // coefficients are algebraic (RootSum), a documented non-goal.
      expect(integrate('1/(x^3 + x + 1)'), isNull);
    });

    test('non-rational input returns null (falls through)', () {
      expect(integrate('sin(x)/x'), isNull);
      expect(integrate('x^2'), isNull); // pure poly — poly path owns it
      expect(integrate('1/(x^3 - 2)'), isNull); // needs LRT (deg-3 irred.)
    });

    test('degree growth stays exact: 1/(x^4 - 1) headless', () {
      // x^4-1 = (x-1)(x+1)(x^2+1): RRT strips the linear factors, the
      // remaining quadratic is irreducible — solvable without FLINT.
      final r = integrate('1/(x^4 - 1)');
      expect(r, isNotNull);
      expect(r, contains('atan'));
      expectAntiderivative('1/(x^4 - 1)', points: [1.4, 2.0, 3.0]);
    });
  });
}
