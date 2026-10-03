import 'dart:math' as math;

import 'package:crisp_math/engine/distributions.dart';
import 'package:crisp_math/engine/hypothesis_tests.dart';
import 'package:crisp_math/engine/unit_expression.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normal probabilities use accurate direct tails', () {
    test('independently frozen translated CDF', () {
      expect(const Normal(mean: 2, stddev: 3).cdf(0),
          closeTo(0.2524925375469229, 1e-14));
    });
    test('unit standardized CDF references and reflection', () {
      expect(standardNormal.cdf(1), closeTo(0.8413447460685429, 1e-14));
      expect(standardNormal.cdf(-1), closeTo(0.15865525393145707, 1e-14));
      expect(standardNormal.cdf(0), 0.5);
      expect(standardNormal.sf(0), 0.5);
      expect(standardNormal.sf(-1), closeTo(standardNormal.cdf(1), 1e-14));
    });
    test('representable positive and negative extreme tails remain nonzero', () {
      const eight = 6.220960574271784e-16;
      const ten = 7.619853024160526e-24;
      expect(standardNormal.sf(8) / eight, closeTo(1, 1e-13));
      expect(standardNormal.cdf(-8) / eight, closeTo(1, 1e-13));
      expect(standardNormal.sf(10) / ten, closeTo(1, 1e-13));
      expect(standardNormal.cdf(-10) / ten, closeTo(1, 1e-13));
    });
    test('standardization does not overflow a finite z', () {
      const normal = Normal(mean: -1e308, stddev: 1e308);
      expect(normal.cdf(1e308), closeTo(0.9772498680518208, 1e-14));
      expect(normal.sf(1e308), closeTo(0.02275013194817921, 1e-14));
    });
    test('large standard deviation retains finite nonzero density', () {
      final expected = (1 / math.sqrt(2 * math.pi)) / 1e308;
      expect(const Normal(stddev: 1e308).pdf(0) / expected, closeTo(1, 1e-13));
    });
    test('inverse CDF uses standardized bounds and safe physical conversion', () {
      expect(standardNormal.quantile(0.8413447460685429), closeTo(1, 1e-11));
      const normal = Normal(mean: 1e308, stddev: 1e308);
      expect(normal.quantile(.5), 1e308);
      expect(normal.quantile(0.02275013194817921) / 1e308,
          closeTo(-1, 1e-11));
      expect(standardNormal.quantile(7.619853024160526e-24), closeTo(-10, 1e-10));
      expect(standardNormal.quantile(.975), closeTo(1.959963984540054, 1e-11));
      final deep = standardNormal.quantile(1e-100);
      expect(deep, closeTo(-21.273453560965322, 1e-10));
      expect(standardNormal.cdf(deep) / 1e-100, closeTo(1, 1e-10));
    });
    test('support endpoints NaN and invalid parameters are explicit', () {
      expect(standardNormal.cdf(double.infinity), 1);
      expect(standardNormal.cdf(double.negativeInfinity), 0);
      expect(standardNormal.sf(double.infinity), 0);
      expect(standardNormal.sf(double.negativeInfinity), 1);
      expect(standardNormal.cdf(1e308), 1);
      expect(standardNormal.cdf(-1e308), 0);
      expect(standardNormal.cdf(double.nan).isNaN, isTrue);
      const extreme = Normal(mean: 1e308, stddev: 1e-300);
      expect(extreme.cdf(double.infinity), 1);
      expect(extreme.cdf(double.negativeInfinity), 0);
      expect(extreme.sf(double.infinity), 0);
      expect(extreme.sf(double.negativeInfinity), 1);
      for (final deviation in [0.0, -1.0, double.infinity, double.nan]) {
        expect(() => Normal(stddev: deviation).cdf(0), throwsArgumentError);
      }
      expect(() => const Normal(mean: double.infinity).cdf(0), throwsArgumentError);
    });
  });

  group('rank-sum direct normal tails', () {
    // Two tied groups of size n have z=sqrt(2n-1) under the existing
    // tie-corrected, no-continuity-correction approximation. n=41 gives z=9;
    // Phi(-9)=erfc(9/sqrt(2))/2=1.1285884059538324e-19 independently.
    const tail = 1.1285884059538324e-19;
    test('large positive z preserves upper and two-sided probability', () {
      final result = HypothesisTests.wilcoxonRankSum(
          sample1: List.filled(41, 1.0), sample2: List.filled(41, 0.0));
      expect(result.u1, 1681);
      expect(result.rankSum1, 2542);
      expect(result.z, closeTo(9, 1e-13));
      expect(result.pValueOneSidedUpper / tail, closeTo(1, 1e-12));
      expect(result.pValueTwoSided / (2 * tail), closeTo(1, 1e-12));
    });
    test('reversed ranks preserve reflected lower and two-sided tails', () {
      final result = HypothesisTests.wilcoxonRankSum(
          sample1: List.filled(41, 0.0), sample2: List.filled(41, 1.0));
      expect(result.u1, 0);
      expect(result.z, closeTo(-9, 1e-13));
      expect(result.pValueOneSidedLower / tail, closeTo(1, 1e-12));
      expect(result.pValueTwoSided / (2 * tail), closeTo(1, 1e-12));
    });
  });

  group('product and quotient unit grammar', () {
    for (final conversion in [
      ['1 N * 1 s in kg*m/s', '1 kg*m/s'],
      ['1 kg*m/s in N*s', '1 N*s'],
      ['1 kN*s in kg*cm/ms', '100 kg*cm/ms'],
      ['1 N·s in kg*m/s', '1 kg*m/s'],
      ['1 kg/m/s in Pa*s', '1 Pa*s'],
      ['1 kg*m/s² in N', '1 N'],
      ['1 kg*m/s^2 in N', '1 N'],
      ['1 J/s in kg*m²/s³', '1 kg*m²/s³'],
      ['1 J / 2 kg in erg/g', '5000 erg/g'],
      ['1 m * 2 m in m²', '2 m²'],
    ]) {
      test(conversion.first, () {
        expect(UnitExpressionEvaluator.tryEvaluate(conversion.first), conversion.last);
      });
    }
    test('successive division is left associative and dimensions stay strict', () {
      expect(UnitExpressionEvaluator.tryEvaluate('1 kg/m/s in N*s'),
          startsWith('Error: cannot convert result'));
      expect(UnitExpressionEvaluator.tryEvaluate('1 kg*m/s in J'),
          startsWith('Error: cannot convert result'));
    });
    test('offset temperature products and malformed words are rejected', () {
      for (final expression in [
        '1 kg*°C/s in J', '1 N*s in kg*°F/s', '1 kg*unknown/s in N*s',
        '1 N*s in kg**m/s', '1 N*s in kg*m//s',
      ]) {
        expect(UnitExpressionEvaluator.tryEvaluate(expression), isNull,
            reason: expression);
      }
      expect(UnitExpressionEvaluator.tryEvaluate('0 °C in °F'), '32 °F');
    });
    test('compound grammar bounds excessive factors and unrepresentable scale', () {
      final tooMany = List.filled(17, 'm').join('*');
      expect(UnitExpressionEvaluator.tryEvaluate('1 $tooMany'), isNull);
      final overflow = List.filled(5, 'Ym³').join('*');
      expect(UnitExpressionEvaluator.tryEvaluate('1 $overflow'), isNull);
    });
  });
}
