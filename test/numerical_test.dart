import 'dart:math' as math;

import 'package:crisp_math/engine/numerical.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('simpson', () {
    test('∫₀¹ x dx = 1/2', () {
      final v = simpson((x) => x, 0, 1);
      expect(v, isNotNull);
      expect(v!, closeTo(0.5, 1e-9));
    });

    test('∫₀¹ x² dx = 1/3', () {
      final v = simpson((x) => x * x, 0, 1);
      expect(v, isNotNull);
      expect(v!, closeTo(1.0 / 3.0, 1e-9));
    });

    test('∫₀^π sin(x) dx = 2', () {
      final v = simpson((x) => math.sin(x), 0, math.pi);
      expect(v, isNotNull);
      expect(v!, closeTo(2.0, 1e-6));
    });

    test('reversed limits flip the sign', () {
      final v = simpson((x) => x, 1, 0);
      expect(v, isNotNull);
      expect(v!, closeTo(-0.5, 1e-9));
    });

    test('a == b yields 0', () {
      expect(simpson((x) => x * x, 3, 3), equals(0));
    });

    test('non-finite integrand yields null', () {
      final v = simpson((x) => 1 / x, -1, 1);
      // 1/0 at the midpoint is non-finite.
      expect(v, isNull);
    });

    test('odd n is bumped to even (no off-by-one)', () {
      final v = simpson((x) => x * x, 0, 1, n: 7);
      expect(v, isNotNull);
      expect(v!, closeTo(1.0 / 3.0, 1e-3));
    });
  });

  group('oneSidedLimit', () {
    test('continuous function — converges to f(point)', () {
      final v = oneSidedLimit((x) => x * x + 1, 2);
      expect(v, isNotNull);
      expect(v!, closeTo(5.0, 1e-6));
    });

    test('removable singularity sin(x)/x at 0', () {
      double f(double x) => math.sin(x) / x;
      final v = oneSidedLimit(f, 0);
      expect(v, isNotNull);
      expect(v!, closeTo(1.0, 1e-6));
    });

    test('jump discontinuity — sides disagree → null', () {
      // sign(x): -1 for x<0, +1 for x>0.
      double f(double x) => x > 0 ? 1.0 : (x < 0 ? -1.0 : 0.0);
      final v = oneSidedLimit(f, 0);
      expect(v, isNull);
    });

    test('1/x at 0 — left and right disagree in sign → null', () {
      final v = oneSidedLimit((x) => 1 / x, 0);
      expect(v, isNull);
    });

    test('sin(1/x) at 0 — oscillatory essential singularity → null', () {
      final v = oneSidedLimit((x) => math.sin(1 / x), 0);
      expect(v, isNull);
    });

    test('1/x² at 0 — both sides agree (even pole), returns large value', () {
      final v = oneSidedLimit((x) => 1 / (x * x), 0);
      // f(±1e-7) = 1e14, both sides agree since x² is even.
      expect(v, isNotNull);
      expect(v!, greaterThan(1e12));
    });

    test('x² at regular point x=3 → 9.0', () {
      final v = oneSidedLimit((x) => x * x, 3);
      expect(v, isNotNull);
      expect(v!, closeTo(9.0, 1e-6));
    });
  });

  group('limitAtInfinity', () {
    test('1/x → 0', () {
      final v = limitAtInfinity((x) => 1 / x);
      expect(v, isNotNull);
      expect(v!.abs(), lessThan(1e-6));
    });

    test('non-convergent x doesn\'t converge', () {
      final v = limitAtInfinity((x) => x);
      expect(v, isNull);
    });

    test('constant function converges to that constant', () {
      final v = limitAtInfinity((x) => 7.0);
      expect(v, isNotNull);
      expect(v!, closeTo(7.0, 1e-9));
    });

    test('sin(x) at ∞ — oscillatory → null', () {
      final v = limitAtInfinity((x) => math.sin(x));
      expect(v, isNull);
    });

    test('1/x² at ∞ → 0', () {
      final v = limitAtInfinity((x) => 1 / (x * x));
      expect(v, isNotNull);
      expect(v!.abs(), lessThan(1e-6));
    });

    test('x² at ∞ — diverges → null', () {
      final v = limitAtInfinity((x) => x * x);
      expect(v, isNull);
    });

    test('exp(-x) at ∞ → 0', () {
      final v = limitAtInfinity((x) => math.exp(-x));
      expect(v, isNotNull);
      expect(v!, closeTo(0.0, 1e-9));
    });
  });
}
