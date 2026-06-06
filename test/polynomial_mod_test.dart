import 'package:crisp_calc/engine/polynomial.dart';
import 'package:crisp_calc/engine/polynomial_mod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Build a polynomial from integer coefficients (low-degree-first).
/// E.g. _poly([-1, 0, 1]) → -1 + 0·x + 1·x² = x² - 1.
Polynomial _poly(List<int> coeffs, [String v = 'x']) =>
    Polynomial.fromCoeffs(coeffs.map(Rational.fromInt).toList(), v);

void main() {
  group('factorModP', () {
    test('x^2 - 1 mod 7 splits into two linear factors', () {
      // x^2 - 1 = [-1, 0, 1]
      final result = factorModP(_poly([-1, 0, 1]), 7);
      expect(result, isNotNull);
      expect(result!.prime, 7);
      expect(result.factors.length, 2);
      for (final f in result.factors) {
        expect(f.factor.length, 2); // linear (degree 1)
        expect(f.multiplicity, 1);
      }
    });

    test('x^2 + 1 mod 2 factors as (x+1)^2', () {
      // x^2 + 1 = [1, 0, 1]
      final result = factorModP(_poly([1, 0, 1]), 2);
      expect(result, isNotNull);
      // In F_2: x^2+1 = (x+1)^2.
      expect(result!.factors.length, 1);
      expect(result.factors[0].multiplicity, 2);
    });

    test('returns null for non-prime modulus', () {
      final p = _poly([1, 0, 1]);
      expect(factorModP(p, 4), isNull);
      expect(factorModP(p, 6), isNull);
      expect(factorModP(p, 1), isNull);
      expect(factorModP(p, 0), isNull);
    });

    test('linear polynomial mod p is itself', () {
      // x + 3 = [3, 1]
      final result = factorModP(_poly([3, 1]), 5);
      expect(result, isNotNull);
      expect(result!.factors.length, 1);
      expect(result.factors[0].multiplicity, 1);
      expect(result.factors[0].factor.length, 2);
    });

    test('constant polynomial has no factors', () {
      // 5 = [5]. After reducing to monic (dividing by lead=5), we get
      // a degree-0 poly [1] — no factorizable part.
      final result = factorModP(_poly([5]), 7);
      expect(result, isNotNull);
      expect(result!.factors, isEmpty);
      expect(result.leadingCoeff, 5);
    });

    test('x^3 - x mod 3 factors into three linear factors', () {
      // x^3 - x = [0, -1, 0, 1]
      final result = factorModP(_poly([0, -1, 0, 1]), 3);
      expect(result, isNotNull);
      expect(result!.factors.length, 3);
      for (final f in result.factors) {
        expect(f.multiplicity, 1);
      }
    });

    test('irreducible polynomial stays as single factor', () {
      // x^2 + 1 is irreducible over F_3.
      final result = factorModP(_poly([1, 0, 1]), 3);
      expect(result, isNotNull);
      expect(result!.factors.length, 1);
      expect(result.factors[0].factor.length, 3); // degree 2
      expect(result.factors[0].multiplicity, 1);
    });

    test('leading coefficient is preserved', () {
      // 3x^2 + 3 = [3, 0, 3]
      final result = factorModP(_poly([3, 0, 3]), 5);
      expect(result, isNotNull);
      expect(result!.leadingCoeff, 3);
    });

    test('zero polynomial returns null', () {
      final result = factorModP(_poly([0]), 5);
      expect(result, isNull);
    });

    test('variable name is preserved', () {
      final result = factorModP(_poly([0, 1], 't'), 5);
      expect(result, isNotNull);
      expect(result!.variable, 't');
    });
  });

  group('formatModFactorization', () {
    test('leading coefficient shown when not 1', () {
      const z = ModFactorization(7, 3, 'x', [
        ModFactor([1, 1], 1)
      ]);
      final s = formatModFactorization(z);
      expect(s, startsWith('3'));
    });

    test('multiplicity shown when > 1', () {
      const z = ModFactorization(2, 1, 'x', [
        ModFactor([1, 1], 3)
      ]);
      final s = formatModFactorization(z);
      expect(s, contains('^3'));
    });

    test('multiple factors joined by centered dot', () {
      const z = ModFactorization(5, 1, 'x', [
        ModFactor([1, 1], 1),
        ModFactor([2, 1], 1),
      ]);
      final s = formatModFactorization(z);
      expect(s, contains('\u00B7')); // ·
    });

    test('no factors gives leading coeff or 1', () {
      expect(
          formatModFactorization(const ModFactorization(5, 3, 'x', [])), '3');
      expect(
          formatModFactorization(const ModFactorization(5, 1, 'x', [])), '1');
    });
  });
}
