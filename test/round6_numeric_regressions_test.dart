import 'dart:math' as math;

import 'package:crisp_math/engine/hypothesis_tests.dart';
import 'package:crisp_math/engine/statistics.dart';
import 'package:crisp_math/engine/unit_catalog.dart';
import 'package:crisp_math/engine/unit_expression.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('finite scaled descriptive moments', () {
    test('equal extreme observations retain mean median quartiles and zero SD', () {
      final result = Statistics.describe([1e308, 1e308]);
      expect(result.mean, 1e308);
      expect(result.median, 1e308);
      expect(result.q1, 1e308);
      expect(result.q3, 1e308);
      expect(result.sampleStddev, 0);
      expect(result.sampleVariance, 0);
      // The sum itself is mathematically outside the finite double range.
      expect(result.sum, double.infinity);
    });

    test('opposite extremes have finite SD even when variance cannot fit', () {
      final result = Statistics.describe([-1e308, 1e308]);
      expect(result.mean, 0);
      expect(result.median, 0);
      expect(result.sampleStddev.isFinite, isTrue);
      expect(result.sampleStddev / 1e308, closeTo(math.sqrt2, 1e-14));
      expect(result.populationStddev / 1e308, closeTo(1, 1e-14));
      expect(result.sampleVariance, double.infinity);
      expect(result.q1 / 1e308, closeTo(-0.5, 1e-14));
      expect(result.q3 / 1e308, closeTo(0.5, 1e-14));
    });

    for (final scale in [1e-200, 1e150, 1e200]) {
      test('SD preserves symmetric sample scale $scale', () {
        final result = Statistics.describe([-scale, 0, scale]);
        expect(result.mean, 0);
        expect(result.sampleStddev / scale, closeTo(1, 1e-14));
        expect(result.populationStddev / scale,
            closeTo(math.sqrt(2 / 3), 1e-14));
      });
    }

    test('compensated mean and sum retain a small cancellation residual', () {
      final result = Statistics.describe([-1e16, 1, 1e16]);
      expect(result.sum, closeTo(1, 1e-14));
      expect(result.mean, closeTo(1 / 3, 1e-14));
    });

    test('nearby values at a large offset retain their small deviation', () {
      final result = Statistics.describe([1e12, 1e12 + 1, 1e12 + 2]);
      expect(result.mean, 1e12 + 1);
      expect(result.sampleStddev, closeTo(1, 1e-14));
    });

    test('singleton sample SD remains undefined and nonfinite input rejected', () {
      final result = Statistics.describe([1e308]);
      expect(result.mean, 1e308);
      expect(result.sampleStddev.isNaN, isTrue);
      expect(result.populationStddev, 0);
      for (final invalid in [double.nan, double.infinity, double.negativeInfinity]) {
        expect(() => Statistics.describe([0, invalid]), throwsArgumentError);
      }
    });

    test('linear fit retains the shared centered variation', () {
      final fit = Statistics.linearFit([1e12, 1e12 + 1, 1e12 + 2], [1, 3, 5]);
      expect(fit.slope, closeTo(2, 1e-14));
      expect(fit.intercept, -1999999999999);
      expect(fit.rSquared, closeTo(1, 1e-14));
    });
  });

  group('hypothesis tests retain scale invariance', () {
    for (final scale in [1e-200, 1.0, 1e200]) {
      test('Welch statistic and degrees of freedom at scale $scale', () {
        final result = HypothesisTests.welchT(
            sample1: [scale, 2 * scale, 3 * scale],
            sample2: [2 * scale, 4 * scale, 6 * scale]);
        expect(result.statistic, closeTo(-2 * math.sqrt(3 / 5), 1e-13));
        expect(result.df, closeTo(50 / 17, 1e-13));
        expect(result.pValueTwoSided.isFinite, isTrue);
      });

      test('one-sample statistic at scale $scale', () {
        final result = HypothesisTests.oneSampleT(
            data: [scale, 2 * scale, 3 * scale], hypothesizedMean: 0);
        expect(result.statistic, closeTo(2 * math.sqrt(3), 1e-13));
        expect(result.df, 2);
      });

      test('ANOVA finite F and p at scale $scale', () {
        final result = HypothesisTests.anovaOneWay([
          [scale, 2 * scale, 3 * scale],
          [4 * scale, 5 * scale, 6 * scale],
        ]);
        expect(result.fStatistic, closeTo(13.5, 1e-12));
        expect(result.dfBetween, 1);
        expect(result.dfWithin, 4);
        final reference = HypothesisTests.anovaOneWay([[1, 2, 3], [4, 5, 6]]);
        expect(result.pValue, closeTo(reference.pValue, 1e-13));
        if (scale == 1e200) {
          expect(result.ssWithin, double.infinity);
          expect(result.ssBetween, double.infinity);
        }
      });
    }

    test('one-sample t avoids overflowing a finite statistic numerator', () {
      final result = HypothesisTests.oneSampleT(
          data: [5e307, 1.5e308], hypothesizedMean: -1e308);
      expect(result.statistic, closeTo(4, 1e-13));
    });

    test('Welch supports a sample whose SD itself exceeds double range', () {
      final result = HypothesisTests.welchT(
          sample1: [-1.7e308, 1.7e308], sample2: [-1e308, 1e308]);
      expect(result.statistic, 0);
      expect(result.df.isFinite, isTrue);
      expect(result.pValueTwoSided, closeTo(1, 1e-14));
    });

    test('nonfinite means and zero-variation samples remain rejected', () {
      expect(() => HypothesisTests.oneSampleT(
          data: [1, 2], hypothesizedMean: double.infinity), throwsArgumentError);
      expect(() => HypothesisTests.welchT(sample1: [1, 1], sample2: [1, 2]),
          throwsArgumentError);
      expect(() => HypothesisTests.anovaOneWay([[1, 1], [2, 2]]),
          throwsArgumentError);
    });
  });

  group('degree symbol alias', () {
    test('catalog and inline syntax share the degree definition', () {
      expect(UnitCatalog.bySymbol('deg'), UnitCatalog.bySymbol('°'));
      expect(UnitExpressionEvaluator.tryEvaluate('180 deg in rad'),
          '3.1415926536 rad');
      expect(UnitExpressionEvaluator.tryEvaluate('1 rad in deg'),
          '57.2957795131 °');
      expect(UnitExpressionEvaluator.tryEvaluate('90 deg + 90 ° in rad'),
          '3.1415926536 rad');
    });

    test('degree alias retains dimension checking and temperature spellings', () {
      expect(UnitExpressionEvaluator.tryEvaluate('1 deg in m'),
          startsWith('Error: cannot convert result'));
      expect(UnitExpressionEvaluator.tryEvaluate('0 degC in °F'), '32 °F');
    });
  });
}
