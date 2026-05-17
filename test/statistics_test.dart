// test/statistics_test.dart
//
// Descriptive statistics + linear regression. Numerical correctness
// against known answers, plus edge cases (single element, identical
// elements, all-x-equal regression).

import 'dart:math' as math;

import 'package:crisp_calc/engine/statistics.dart';
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
      expect(Statistics.describe(const [1, 2, 3, 4]).median,
          closeTo(2.5, _eps));
    });

    test('median is order-insensitive', () {
      expect(Statistics.describe(const [5, 1, 3]).median,
          closeTo(Statistics.describe(const [1, 3, 5]).median, _eps));
    });

    test('mode finds the most frequent value', () {
      expect(
          Statistics.describe(const [1, 2, 2, 3]).modes, equals([2.0]));
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
      expect(s.sampleStddev,
          closeTo(math.sqrt(s.sampleVariance), _eps));
      expect(s.populationStddev,
          closeTo(math.sqrt(s.populationVariance), _eps));
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
}
