// test/statistics_test.dart
//
// Descriptive statistics + linear regression. Numerical correctness
// against known answers, plus edge cases (single element, identical
// elements, all-x-equal regression).

import 'dart:math' as math;

import 'package:crisp_math/engine/statistics.dart';
import 'package:flutter_test/flutter_test.dart';

const _eps = 1e-9;

void main() {
  group('Statistics.describe — central tendency', () {
    test('mean of small dataset', () {
      final s = Statistics.describe(const [1, 2, 3, 4, 5]);
      expect(s.mean, closeTo(3.0, _eps));
    });

    test('sum is mean × count', () {
      final s = Statistics.describe(const [2, 4, 6, 8]);
      expect(s.sum, closeTo(20.0, _eps));
      expect(s.count, equals(4));
    });

    test('median of odd-length list is the middle element', () {
      expect(Statistics.describe(const [1, 3, 5]).median, closeTo(3.0, _eps));
    });

    test('median of even-length list averages the middle two', () {
      expect(
          Statistics.describe(const [1, 2, 3, 4]).median, closeTo(2.5, _eps));
    });

    test('median is order-insensitive', () {
      expect(Statistics.describe(const [5, 1, 3]).median,
          closeTo(Statistics.describe(const [1, 3, 5]).median, _eps));
    });

    test('mode finds the most frequent value', () {
      expect(Statistics.describe(const [1, 2, 2, 3]).modes, equals([2.0]));
    });

    test('mode finds all ties', () {
      final modes = Statistics.describe(const [1, 1, 2, 2, 3]).modes;
      expect(modes, equals([1.0, 2.0]));
    });

    test('no mode when every value appears once', () {
      expect(Statistics.describe(const [1, 2, 3, 4]).modes, isEmpty);
    });
  });

  group('Statistics.describe — spread', () {
    test('range = max - min', () {
      final s = Statistics.describe(const [3, 1, 4, 1, 5, 9, 2, 6]);
      expect(s.min, closeTo(1.0, _eps));
      expect(s.max, closeTo(9.0, _eps));
      expect(s.range, closeTo(8.0, _eps));
    });

    test('sample variance on textbook list', () {
      // For [2,4,4,4,5,5,7,9]: mean=5, sumSq=32, sampleVar=32/7≈4.5714
      final s = Statistics.describe(const [2, 4, 4, 4, 5, 5, 7, 9]);
      expect(s.mean, closeTo(5.0, _eps));
      expect(s.sampleVariance, closeTo(32.0 / 7.0, _eps));
    });

    test('population vs sample variance differ by Bessel correction', () {
      final s = Statistics.describe(const [1, 2, 3, 4, 5]);
      // pop var = 2, sample var = 2.5
      expect(s.populationVariance, closeTo(2.0, _eps));
      expect(s.sampleVariance, closeTo(2.5, _eps));
    });

    test('stddev = sqrt(variance)', () {
      final s = Statistics.describe(const [2, 4, 4, 4, 5, 5, 7, 9]);
      expect(s.sampleStddev, closeTo(math.sqrt(s.sampleVariance), _eps));
      expect(
          s.populationStddev, closeTo(math.sqrt(s.populationVariance), _eps));
    });

    test('variance is zero when all values are identical', () {
      final s = Statistics.describe(const [7, 7, 7, 7]);
      expect(s.populationVariance, closeTo(0.0, _eps));
      expect(s.sampleVariance, closeTo(0.0, _eps));
    });

    test('single-element list has well-defined stats', () {
      final s = Statistics.describe(const [42]);
      expect(s.mean, closeTo(42.0, _eps));
      expect(s.median, closeTo(42.0, _eps));
      expect(s.populationVariance, closeTo(0.0, _eps));
      expect(s.sampleVariance, closeTo(0.0, _eps));
    });
  });

  group('Statistics.describe — quartiles', () {
    // Verifying Excel/R type-7 linear interpolation. Reference values
    // computed by hand for [1,2,3,4,5,6,7,8,9]:
    //   Q1 = 3, Q3 = 7 (positions 2 and 6 in 0-indexed sorted array).
    test('quartiles of evenly-spaced data', () {
      final s = Statistics.describe(const [1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(s.q1, closeTo(3.0, _eps));
      expect(s.q3, closeTo(7.0, _eps));
      expect(s.iqr, closeTo(4.0, _eps));
    });

    test('Q1 and Q3 interpolate for non-integer positions', () {
      // For [1..10] linear interp: Q1 = 1 + 0.25*9 = 3.25, Q3 = 7.75.
      final s = Statistics.describe(const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      expect(s.q1, closeTo(3.25, _eps));
      expect(s.q3, closeTo(7.75, _eps));
      expect(s.iqr, closeTo(4.5, _eps));
    });
  });

  group('Statistics.describe — error handling', () {
    test('empty input throws', () {
      expect(() => Statistics.describe(const []), throwsArgumentError);
    });
  });

  group('Statistics.linearFit', () {
    test('perfect line y = 2x + 1', () {
      final f = Statistics.linearFit(
        const [0, 1, 2, 3, 4],
        const [1, 3, 5, 7, 9],
      );
      expect(f.slope, closeTo(2.0, _eps));
      expect(f.intercept, closeTo(1.0, _eps));
      expect(f.rSquared, closeTo(1.0, _eps));
    });

    test('flat line y = 3 has slope 0 and R² = 1', () {
      // R² is undefined when y is constant; we return 1 (perfect fit
      // by convention since slope=0 exactly matches the data).
      final f = Statistics.linearFit(
        const [1, 2, 3, 4],
        const [3, 3, 3, 3],
      );
      expect(f.slope, closeTo(0.0, _eps));
      expect(f.intercept, closeTo(3.0, _eps));
      expect(f.rSquared, closeTo(1.0, _eps));
    });

    test('all xs equal returns NaN slope (undefined)', () {
      final f = Statistics.linearFit(
        const [5, 5, 5, 5],
        const [1, 2, 3, 4],
      );
      expect(f.slope.isNaN, isTrue);
    });

    test('noisy fit recovers approximate slope', () {
      // y = 2x + small perturbation
      final f = Statistics.linearFit(
        const [0, 1, 2, 3, 4, 5],
        const [0.1, 1.9, 4.1, 5.95, 8.05, 10.0],
      );
      expect(f.slope, closeTo(2.0, 0.05));
      expect(f.intercept, closeTo(0.0, 0.1));
      expect(f.rSquared, greaterThan(0.99));
    });

    test('length mismatch throws', () {
      expect(
        () => Statistics.linearFit(const [1, 2], const [1, 2, 3]),
        throwsArgumentError,
      );
    });

    test('fewer than 2 points throws', () {
      expect(
        () => Statistics.linearFit(const [1], const [2]),
        throwsArgumentError,
      );
    });
  });

  group('Statistics.polynomialFit', () {
    test('linear data with degree 1 matches linearFit', () {
      final p = Statistics.polynomialFit(
        const [0, 1, 2, 3, 4],
        const [1, 3, 5, 7, 9],
        1,
      );
      expect(p.coefficients.length, equals(2));
      expect(p.coefficients[0], closeTo(1.0, 1e-9)); // intercept
      expect(p.coefficients[1], closeTo(2.0, 1e-9)); // slope
      expect(p.rSquared, closeTo(1.0, 1e-9));
      expect(p.degree, equals(1));
    });

    test('quadratic fit recovers y = x²', () {
      final p = Statistics.polynomialFit(
        const [-2, -1, 0, 1, 2],
        const [4, 1, 0, 1, 4],
        2,
      );
      // y = 0 + 0·x + 1·x²
      expect(p.coefficients[0], closeTo(0.0, 1e-9));
      expect(p.coefficients[1], closeTo(0.0, 1e-9));
      expect(p.coefficients[2], closeTo(1.0, 1e-9));
      expect(p.rSquared, closeTo(1.0, 1e-9));
    });

    test('cubic fit recovers y = x³ - 2x', () {
      double f(double x) => x * x * x - 2 * x;
      const xs = [-2.0, -1.0, 0.0, 1.0, 2.0, 3.0];
      final ys = xs.map(f).toList();
      final p = Statistics.polynomialFit(xs, ys, 3);
      // expected: c0=0, c1=-2, c2=0, c3=1
      expect(p.coefficients[0], closeTo(0.0, 1e-9));
      expect(p.coefficients[1], closeTo(-2.0, 1e-9));
      expect(p.coefficients[2], closeTo(0.0, 1e-9));
      expect(p.coefficients[3], closeTo(1.0, 1e-9));
      expect(p.rSquared, closeTo(1.0, 1e-9));
    });

    test('evaluate(x) reconstructs the original y on the fit points', () {
      final p = Statistics.polynomialFit(
        const [0, 1, 2, 3, 4],
        const [1, 3, 5, 7, 9],
        1,
      );
      expect(p.evaluate(10), closeTo(21.0, 1e-9));
    });

    test('too few points throws', () {
      expect(
        () => Statistics.polynomialFit(const [0, 1], const [0, 1], 3),
        throwsArgumentError,
      );
    });

    test('singular system (all x equal) throws', () {
      expect(
        () => Statistics.polynomialFit(
          const [1, 1, 1, 1],
          const [1, 2, 3, 4],
          2,
        ),
        throwsArgumentError,
      );
    });
  });

  group('Statistics.expFit', () {
    test('exact y = 2 * exp(0.5 * x) recovers a and b', () {
      const xs = [0.0, 1.0, 2.0, 3.0, 4.0];
      final ys = [for (final x in xs) 2.0 * math.exp(0.5 * x)];
      final f = Statistics.expFit(xs, ys);
      expect(f.a, closeTo(2.0, 1e-9));
      expect(f.b, closeTo(0.5, 1e-9));
      expect(f.rSquared, closeTo(1.0, 1e-9));
      expect(f.count, equals(5));
    });
    test('exact y = 3 * exp(-0.2 * x) — negative b', () {
      const xs = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0];
      final ys = [for (final x in xs) 3.0 * math.exp(-0.2 * x)];
      final f = Statistics.expFit(xs, ys);
      expect(f.a, closeTo(3.0, 1e-9));
      expect(f.b, closeTo(-0.2, 1e-9));
      expect(f.rSquared, closeTo(1.0, 1e-9));
    });
    test('evaluate() reproduces y at the sample points', () {
      const xs = [0.0, 1.0, 2.0, 3.0];
      final ys = [for (final x in xs) 1.5 * math.exp(0.7 * x)];
      final f = Statistics.expFit(xs, ys);
      for (var i = 0; i < xs.length; i++) {
        expect(f.evaluate(xs[i]), closeTo(ys[i], 1e-9));
      }
    });
    test('non-positive y throws', () {
      expect(
        () => Statistics.expFit(const [1.0, 2.0], const [1.0, -1.0]),
        throwsArgumentError,
      );
      expect(
        () => Statistics.expFit(const [1.0, 2.0], const [1.0, 0.0]),
        throwsArgumentError,
      );
    });
    test('length mismatch throws', () {
      expect(
        () => Statistics.expFit(const [1.0, 2.0], const [1.0, 2.0, 3.0]),
        throwsArgumentError,
      );
    });
    test('single point throws', () {
      expect(
        () => Statistics.expFit(const [1.0], const [2.0]),
        throwsArgumentError,
      );
    });
    test('classic textbook example — bacterial growth', () {
      // Population doubles every hour: y = 100 * exp(ln(2) * t).
      const xs = [0.0, 1.0, 2.0, 3.0, 4.0];
      const ys = [100.0, 200.0, 400.0, 800.0, 1600.0];
      final f = Statistics.expFit(xs, ys);
      expect(f.a, closeTo(100.0, 1e-6));
      expect(f.b, closeTo(math.log(2), 1e-6));
      expect(f.rSquared, closeTo(1.0, 1e-9));
    });
  });
}
