import 'package:crisp_calc/engine/polynomial.dart';
import 'package:crisp_calc/engine/multivariate_poly.dart';
import 'package:flutter_test/flutter_test.dart';

MultivariatePolynomial _mp(Map<List<int>, Rational> terms) =>
    MultivariatePolynomial(['x', 'y'], terms);

final _r0 = Rational.zero;
final _r1 = Rational.one;
final _r2 = Rational.fromInt(2);
final _rn1 = Rational.fromInt(-1);

/// Helper to get coefficient for an exponent vector.
Rational? _coeff(MultivariatePolynomial p, List<int> exps) {
  for (final (e, c) in p.terms) {
    if (e.length == exps.length) {
      var match = true;
      for (var i = 0; i < e.length; i++) {
        if (e[i] != exps[i]) {
          match = false;
          break;
        }
      }
      if (match) return c;
    }
  }
  return null;
}

void main() {
  group('MultivariatePolynomial arithmetic', () {
    test('addition of like terms', () {
      // (x + y) + (x + y) = 2x + 2y
      final a = _mp({
        [1, 0]: _r1, // x
        [0, 1]: _r1, // y
      });
      final sum = a + a;
      expect(sum.termCount, 2);
      expect(_coeff(sum, [1, 0]), _r2);
      expect(_coeff(sum, [0, 1]), _r2);
    });

    test('addition with cancellation', () {
      // (x + y) + (-x + y) = 2y
      final a = _mp({
        [1, 0]: _r1,
        [0, 1]: _r1,
      });
      final b = _mp({
        [1, 0]: _rn1,
        [0, 1]: _r1,
      });
      final sum = a + b;
      expect(sum.termCount, 1);
      expect(_coeff(sum, [0, 1]), _r2);
      expect(_coeff(sum, [1, 0]), isNull); // cancelled
    });

    test('subtraction', () {
      final a = _mp({
        [2, 0]: _r1, // x^2
        [0, 0]: _r1, // 1
      });
      final b = _mp({
        [2, 0]: _r1,
        [0, 0]: _rn1,
      });
      final diff = a - b;
      // x^2 cancels, constant = 1 - (-1) = 2.
      expect(diff.termCount, 1);
      expect(_coeff(diff, [0, 0]), _r2);
    });

    test('multiplication (x+y)(x-y) = x^2 - y^2', () {
      final a = _mp({
        [1, 0]: _r1,
        [0, 1]: _r1,
      });
      final b = _mp({
        [1, 0]: _r1,
        [0, 1]: _rn1,
      });
      final prod = a * b;
      expect(_coeff(prod, [2, 0]), _r1); // x^2
      expect(_coeff(prod, [0, 2]), _rn1); // -y^2
      expect(_coeff(prod, [1, 1]), isNull); // xy terms cancel
    });

    test('scale by zero produces zero polynomial', () {
      final a = _mp({
        [1, 0]: _r1,
        [0, 1]: _r2,
      });
      final scaled = a.scale(_r0);
      expect(scaled.isZero, isTrue);
      expect(scaled.termCount, 0);
    });

    test('scale by one is identity', () {
      final a = _mp({
        [1, 0]: _r1,
        [0, 1]: _r2,
      });
      final scaled = a.scale(_r1);
      expect(scaled.termCount, 2);
      expect(_coeff(scaled, [1, 0]), _r1);
      expect(_coeff(scaled, [0, 1]), _r2);
    });

    test('totalDegree of x^3*y^2 term is 5', () {
      final a = _mp({
        [3, 2]: _r1,
        [1, 0]: _r1,
      });
      expect(a.totalDegree, 5);
    });

    test('totalDegree of constant is 0', () {
      final a = _mp({
        [0, 0]: _r2,
      });
      expect(a.totalDegree, 0);
    });

    test('isZero for empty polynomial', () {
      final a = MultivariatePolynomial(['x', 'y'], {});
      expect(a.isZero, isTrue);
    });

    test('degreeIn(0) returns max exponent of first variable', () {
      final a = _mp({
        [3, 2]: _r1,
        [1, 4]: _r1,
      });
      expect(a.degreeIn(0), 3);
      expect(a.degreeIn(1), 4);
    });

    test('zero terms are not stored', () {
      final a = _mp({
        [1, 0]: _r0, // zero coefficient
        [0, 1]: _r1,
      });
      expect(a.termCount, 1); // zero term excluded
    });
  });

  group('MultivariatePolynomial.terms', () {
    test('iterates all terms', () {
      final a = _mp({
        [1, 0]: _r1,
        [0, 1]: _r2,
      });
      final termList = a.terms.toList();
      expect(termList.length, 2);
    });
  });
}
