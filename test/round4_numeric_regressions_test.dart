import 'package:crisp_math/engine/statistics.dart';
import 'package:crisp_math/engine/unit_expression.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('centered and scaled regression', () {
    test('large predictor offset retains slope, intercept and every residual', () {
      final xs = [1000000000.0, 1000000001.0, 1000000002.0];
      final ys = [1.0, 3.0, 5.0];
      final fit = Statistics.linearFit(xs, ys);
      expect(fit.slope, closeTo(2, 1e-12));
      expect(fit.intercept, closeTo(-1999999999, 1e-9));
      expect(fit.rSquared, closeTo(1, 1e-12));
      for (var i = 0; i < xs.length; i++) {
        expect(fit.slope * xs[i] + fit.intercept, closeTo(ys[i], 1e-9));
      }
    });

    test('large response offset retains centered variation and R squared', () {
      final fit = Statistics.linearFit([0, 1, 2],
          [1000000000, 1000000002, 1000000004]);
      expect(fit.slope, closeTo(2, 1e-12));
      expect(fit.intercept, closeTo(1000000000, 1e-9));
      expect(fit.rSquared, closeTo(1, 1e-12));
    });

    test('both offsets with negative slope retain the strict intercept', () {
      final fit = Statistics.linearFit([1e12, 1e12 + 1, 1e12 + 2],
          [1e12 + 7, 1e12 + 4, 1e12 + 1]);
      expect(fit.slope, closeTo(-3, 1e-12));
      expect(fit.intercept, closeTo(4e12 + 7, 1e-9));
      expect(fit.rSquared, closeTo(1, 1e-12));
    });

    test('large magnitudes do not overflow squared covariance', () {
      final fit = Statistics.linearFit([1e200, 2e200, 3e200],
          [-2e200, -4e200, -6e200]);
      expect(fit.slope, closeTo(-2, 1e-12));
      expect(fit.intercept.isFinite, isTrue);
      expect(fit.intercept.abs() / 1e200, lessThan(1e-12));
      expect(fit.rSquared, closeTo(1, 1e-12));
    });

    test('opposite extreme doubles can be fit without overflowing differences', () {
      final fit = Statistics.linearFit([-1e308, 0, 1e308], [-1e308, 0, 1e308]);
      expect(fit.slope, closeTo(1, 1e-12));
      expect(fit.intercept, 0);
      expect(fit.rSquared, closeTo(1, 1e-12));
    });

    test('uncorrelated centered observations retain zero R squared', () {
      final fit = Statistics.linearFit([-1, 0, 1], [1, -2, 1]);
      expect(fit.slope, 0);
      expect(fit.intercept, closeTo(0, 1e-12));
      expect(fit.rSquared, closeTo(0, 1e-12));
    });

    test('constant predictor and response retain their undefined contracts', () {
      final constantX = Statistics.linearFit([1e12, 1e12], [1, 2]);
      expect(constantX.slope.isNaN, isTrue);
      expect(constantX.intercept.isNaN, isTrue);
      expect(constantX.rSquared.isNaN, isTrue);
      final constantY = Statistics.linearFit([1e12, 1e12 + 1], [5.1, 5.1]);
      expect(constantY.slope, 0);
      expect(constantY.intercept, 5.1);
      expect(constantY.rSquared.isNaN, isTrue);
    });

    test('nonfinite observations are rejected before fit arithmetic', () {
      expect(() => Statistics.linearFit([0, double.infinity], [1, 2]),
          throwsArgumentError);
      expect(() => Statistics.linearFit([0, 1], [1, double.nan]),
          throwsArgumentError);
    });
  });

  group('compound conversion dimensions and prefixes', () {
    for (final example in [
      ['1 kPa in N/cm^2', '0.1 N/cm²'],
      ['1 kPa in N/cm²', '0.1 N/cm²'],
      ['1 N/mm² in MPa', '1 MPa'],
      ['2 kN/cm² in MPa', '20 MPa'],
      ['100 N/cm² in kPa', '1000 kPa'],
      ['1 J/s in W', '1 W'],
      ['1000 kg/m³ in g/cm³', '1 g/cm³'],
      ['1 m/s² in cm/s^2', '100 cm/s²'],
      ['2 μN/µm² in MPa', '2 MPa'],
    ]) {
      test(example.first, () {
        expect(UnitExpressionEvaluator.tryEvaluate(example.first), example.last);
      });
    }

    test('incompatible compound targets report a dimension error', () {
      expect(UnitExpressionEvaluator.tryEvaluate('1 kPa in N/cm³'),
          startsWith('Error: cannot convert result'));
      expect(UnitExpressionEvaluator.tryEvaluate('1 J in W/s'),
          startsWith('Error: cannot convert result'));
    });

    test('offset temperature and malformed compound targets are rejected', () {
      for (final source in [
        '1 kPa in °C/s',
        '1 kPa in N/°F',
        '1 kPa in N/cm^2/s',
        '1 kPa in N/cm^23',
        '1 kPa in N//cm²',
      ]) {
        final result = UnitExpressionEvaluator.tryEvaluate(source);
        expect(result == null || result.startsWith('Error:'), isTrue,
            reason: '$source => $result');
      }
    });
  });
}
