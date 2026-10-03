import 'dart:math' as math;
import 'package:crisp_math/engine/distributions.dart';
import 'package:crisp_math/engine/hypothesis_tests.dart';
import 'package:crisp_math/engine/unit_catalog.dart';
import 'package:crisp_math/engine/unit_expression.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Student t tails and intervals', () {
    const t = TDistribution(df: 2);
    test('frozen positive interval', () {
      expect(t.intervalProbability(1e10, 2e10) / 3.75e-21, closeTo(1, 1e-13));
    });
    test('negative interval reflection', () {
      expect(t.intervalProbability(-2e10, -1e10) / 3.75e-21, closeTo(1, 1e-13));
    });
    test('representable subnormal df2 survival', () {
      expect(t.sf(1e154) / 5e-309, closeTo(1, 1e-13));
    });
    test('Cauchy survives squared argument overflow', () {
      expect(const TDistribution(df: 1).sf(1e200) / (1e-200 / math.pi),
          closeTo(1, 1e-13));
    });
    test('tiny central intervals preserve nonzero mass', () {
      expect(t.intervalProbability(-1e-20, 1e-20) / (1e-20 / math.sqrt2),
          closeTo(1, 1e-13));
      expect(const TDistribution(df: 1).intervalProbability(-1e-20, 1e-20) /
          (2e-20 / math.pi), closeTo(1, 1e-13));
    });
    test('central and endpoint contracts', () {
      expect(t.intervalProbability(-2, 2), closeTo(2 / math.sqrt(6), 1e-13));
      expect(t.intervalProbability(2, 2), 0);
      expect(t.intervalProbability(double.negativeInfinity, double.infinity), 1);
      expect(t.sf(double.infinity), 0);
      expect(t.sf(double.negativeInfinity), 1);
      expect(t.sf(double.nan).isNaN, isTrue);
      expect(() => t.intervalProbability(2, 1), throwsArgumentError);
    });
    for (final degrees in [3, 10]) {
      test('general df $degrees tiny centered interval retains PDF mass', () {
        final distribution = TDistribution(df: degrees);
        // Smooth even density: error of replacing it by pdf(0) is O(x²).
        final density = degrees == 3 ? 2 / (math.pi * math.sqrt(3))
            : 315 / (256 * math.sqrt(10));
        final expected = 2e-20 * density;
        expect(distribution.intervalProbability(-1e-20, 1e-20) / expected,
            closeTo(1, 1e-13));
      });
      test('general df $degrees tiny positive adjacent interval', () {
        final distribution = TDistribution(df: degrees);
        final density = degrees == 3 ? 2 / (math.pi * math.sqrt(3))
            : 315 / (256 * math.sqrt(10));
        final expected = 1e-20 * density;
        expect(distribution.intervalProbability(1e-20, 2e-20) / expected,
            closeTo(1, 1e-13));
      });
    }
    test('narrow offset interval agrees with independent midpoint density', () {
      const distribution = TDistribution(df: 3);
      const lower = 5.0, upper = 5.0000000001;
      final midpoint = (lower + upper) / 2;
      final expected = (upper - lower) * 2 / (math.pi * math.sqrt(3)) /
          math.pow(1 + midpoint * midpoint / 3, 2);
      expect(distribution.intervalProbability(lower, upper) / expected,
          closeTo(1, 1e-13));
    });
    test('actual hypothesis test preserves upper and two-sided tails', () {
      // Mean=1e10, SD=1, n=3: t=sqrt(3)*1e10, df=2.
      final r = HypothesisTests.oneSampleT(
          data: [1e10 - 1, 1e10, 1e10 + 1], hypothesizedMean: 0);
      expect(r.pValueOneSidedUpper / (1 / 6e20), closeTo(1, 1e-13));
      expect(r.pValueTwoSided / (1 / 3e20), closeTo(1, 1e-13));
    });
  });
  group('chi square regularized gamma', () {
    test('df1 frozen erfc reference and finite CDF', () {
      const c = ChiSquare(df: 1);
      const tail = 0.0015654022580025497;
      expect(c.sf(10), closeTo(tail, 1e-15));
      expect(c.cdf(10), closeTo(1 - tail, 1e-14));
      expect(c.cdf(2), closeTo(0.8427007929497149, 1e-14));
    });
    test('df2 independent exponential tail', () {
      const c = ChiSquare(df: 2);
      expect(c.sf(1000) / math.exp(-500), closeTo(1, 1e-12));
      expect(c.cdf(2), closeTo(1 - math.exp(-1), 1e-14));
    });
    test('df4 independent polynomial exponential tail', () {
      expect(const ChiSquare(df: 4).sf(10), closeTo(6 * math.exp(-5), 1e-14));
    });
    test('smallest positive df1 input retains its square root CDF', () {
      const input = 5e-324;
      final expected = math.sqrt(input) * math.sqrt(2 / math.pi);
      expect(const ChiSquare(df: 1).cdf(input) / expected, closeTo(1, 1e-12));
    });
    test('support and nonfinite endpoint contracts', () {
      const c = ChiSquare(df: 1);
      expect(c.cdf(-1), 0);
      expect(c.cdf(0), 0);
      expect(c.sf(0), 1);
      expect(c.cdf(double.infinity), 1);
      expect(c.sf(double.infinity), 0);
      expect(c.cdf(double.nan).isNaN, isTrue);
    });
    test('actual GOF empty observed bin', () {
      final r = HypothesisTests.chiSquareGof(observed: [0, 10], expected: [5, 5]);
      expect(r.statistic, 10);
      expect(r.df, 1);
      expect(r.pValue, closeTo(0.0015654022580025497, 1e-15));
    });
    test('actual GOF deep df2 tail', () {
      final r = HypothesisTests.chiSquareGof(
          observed: [0, 0, 30], expected: [10, 10, 10]);
      expect(r.statistic, 60);
      expect(r.df, 2);
      expect(r.pValue / math.exp(-30), closeTo(1, 1e-13));
    });
    test('actual independence shares stable df1 survival', () {
      final r = HypothesisTests.chiSquareIndependence([[0, 10], [10, 0]]);
      expect(r.statistic, 20);
      expect(r.pValue, closeTo(0.000007744216431044084, 1e-17));
    });
    test('invalid count inputs rejected', () {
      for (final v in [-1.0, double.infinity, double.nan]) {
        expect(() => HypothesisTests.chiSquareGof(
            observed: [v, 10], expected: [5, 5]), throwsArgumentError);
        expect(() => HypothesisTests.chiSquareIndependence([[v, 10], [10, 0]]),
            throwsArgumentError);
      }
      expect(() => HypothesisTests.chiSquareGof(
          observed: [0, 10], expected: [0, 10]), throwsArgumentError);
    });
  });
  group('CGS energy and atmosphere definitions', () {
    test('scale and canonical SI formatting', () {
      final erg = DerivedUnits.bySymbol('erg')!;
      final atm = DerivedUnits.bySymbol('atm')!;
      expect(erg.toSi(10000000), 1);
      expect(atm.toSi(1), 101325);
      expect(DerivedUnits.matchingBaseDim(erg.dim)?.symbol, 'J');
      expect(DerivedUnits.matchingBaseDim(atm.dim)?.symbol, 'Pa');
    });
    for (final c in [
      ['10000000 erg in J', '1 J'], ['1 J in erg', '10000000 erg'],
      ['10 Merg in J', '1 J'], ['1 atm in bar', '1.01325 bar'],
      ['1 atm in Pa', '101325 Pa'], ['101325 Pa in atm', '1 atm'],
      ['1 atm / 1 bar', '1.01325 '], ['10000000 erg/s in W', '1 W'],
    ]) {
      test(c.first, () {
        expect(UnitExpressionEvaluator.tryEvaluate(c.first), c.last);
      });
    }
    test('dimensions and identifier boundaries stay strict', () {
      expect(UnitExpressionEvaluator.tryEvaluate('1 atm in J'),
          startsWith('Error: cannot convert result'));
      expect(UnitExpressionEvaluator.tryEvaluate('1 erg in Pa'),
          startsWith('Error: cannot convert result'));
      expect(UnitExpressionEvaluator.tryEvaluate('1 atmospheric in Pa'), isNull);
    });
  });
}
