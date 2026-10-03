import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/multivariate_poly.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:crisp_math/engine/polynomial_quotient_cancellation.dart';
import 'package:crisp_math/engine/real_calculus_proofs.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('multivariate exact cancellation retains original denominator restriction', () {
    final engine = CalculatorEngine();
    final result = engine.simplify('(x^2-y^2)/(x-y)');
    final compiled = NumericFallbackEvaluator.compile(result)!;
    expect(compiled.evaluate({'x': 5, 'y': 2}), 7);
    expect(compiled.evaluate({'x': -3, 'y': 4}), 1);
    expect(engine.lastResultEvidence?.sourceDomain, contains('x-y'));
    expect(engine.lastResultEvidence?.sourceDomain, contains('≠ 0'));
    final rational = engine.simplify('(x^2-y^2)/(2*x-2*y)');
    expect(NumericFallbackEvaluator.compile(rational)!.evaluate({'x': 5, 'y': 2}), 3.5);
    expect(PolynomialQuotientCancellation.simplify('(x^2+y^2)/(x-y)'), isNull);
    expect(PolynomialQuotientCancellation.simplify('(x-y)/(x-y)+z'), isNull);
    expect(PolynomialQuotientCancellation.simplify('(x^2-y^2)/0'), isNull);
  });

  test('multivariate parser declines excessive powers and coefficient growth', () {
    expect(MultivariatePolynomial.tryParse('(x+y)^100000'), isNull);
    expect(MultivariatePolynomial.tryParse('((2^128)^128)^128+x+y'), isNull);
    expect(MultivariatePolynomial.tryParse(
        '${List.filled(40, '(').join()}x+y${List.filled(40, ')').join()}'), isNull);
  });

  test('convergent real singular endpoints use analytic antiderivative limits', () {
    final engine = CalculatorEngine();
    expect(engine.integrate('1/sqrt(x)', 'x', '0', '1'), '2');
    expect(engine.lastResultEvidence?.method, ComputationMethod.fundamentalTheorem);
    expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.approximate);
    expect(engine.integrate('1/sqrt(x)', 'x', '1', '0'), '-2');
    expect(engine.integrate('ln(x)', 'x', '0', '1'), '-1');
    expect(engine.integrate('ln(x)', 'x', '1', '0'), '1');
    expect(engine.integrate('1/sqrt(2*x)', 'x', '0', '2'), '2');
    expect(engine.integrate('ln(1-x)', 'x', '0', '1'), '-1');
    expect(engine.integrate('sqrt(x)', 'x', '0', '9'), '18');
  });

  test('endpoint repair cannot cross real-domain boundaries or rational poles', () {
    final engine = CalculatorEngine();
    expect(engine.integrate('ln(x)', 'x', '-1', '1'), startsWith('Error:'));
    expect(engine.lastResultEvidence, isNull);
    expect(engine.integrate('1/sqrt(x)', 'x', '-1', '1'), startsWith('Error:'));
    expect(engine.integrate('1/x', 'x', '-1', '0'), contains('divergent pole'));
    expect(engine.integrate('1/(x-1)', 'x', '0', '2'), contains('divergent pole'));
    expect(RealCalculusProofs.definite('ln(x^2)', 'x', '-1', '1'), isNull);
    expect(RealCalculusProofs.definite('1/sqrt(x)^2', 'x', '0', '1'), isNull);
  });

  test('oscillatory zero is proved by a vanishing polynomial envelope', () {
    final engine = CalculatorEngine();
    expect(engine.limit('x*sin(1/x)', 'x', '0'), '0');
    expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.symbolic);
    expect(engine.limit('(x-2)*cos(1/(x-2))', 'x', '2'), '0');
    expect(engine.limit('x^2*sin(1/x^3)', 'x', '0'), '0');
    expect(RealCalculusProofs.squeezedZero('sin(1/x)', 'x', '0'), isFalse);
    expect(RealCalculusProofs.squeezedZero('(x+1)*sin(1/x)', 'x', '0'), isFalse);
    expect(RealCalculusProofs.squeezedZero('x*sin(1/0)', 'x', '0'), isFalse);
    expect(RealCalculusProofs.squeezedZero('x*sin(y/x)', 'x', '0'), isFalse);
    expect(RealCalculusProofs.squeezedZero('x*sin(x^0.5)', 'x', '0'), isFalse);
  });

  test('two-sided nonsmooth limits reject unequal directional values', () {
    final engine = CalculatorEngine();
    expect(engine.limit('abs(x)/x', 'x', '0'), contains('left and right limits differ'));
    expect(engine.lastResultEvidence, isNull);
  });

  test('shared real point derivatives and Taylor centers respect cusp order', () {
    final engine = CalculatorEngine();
    expect(engine.differentiateAt('abs(x)', 'x', '0'), contains('derivative does not exist'));
    expect(engine.lastResultEvidence, isNull);
    expect(engine.differentiateAt('x*abs(x)', 'x', '0'), '0');
    expect(engine.differentiateAt('abs(x)', 'x', '2'), '1');
    expect(engine.differentiateAt('abs(x)', 'x', '-2'), '-1');
    expect(engine.differentiateAt('x*abs(x)', 'x', '-2'), '4');
    expect(engine.differentiateAt('abs(2*x-4)', 'x', '3'), '2');
    expect(engine.differentiateAt('abs(2*x-4)', 'x', '1'), '-2');
    expect(engine.differentiateAt('(x-2)*abs(3*x-6)', 'x', '2'), '0');
    expect(engine.series('abs(x)', 'x', order: 2), startsWith('Error:'));
    expect(engine.series('x*abs(x)', 'x', order: 2), '0');
    expect(engine.series('x*abs(x)', 'x', order: 3), startsWith('Error:'));
    expect(engine.series('x^2*abs(x)', 'x', order: 3), '0');
    expect(engine.series('x^2*abs(x)', 'x', order: 4), startsWith('Error:'));
    expect(RealCalculusProofs.cuspDerivative('abs(x^2)', 'x', '0'), isNull);
    expect(RealCalculusProofs.cuspDerivative('abs(y)', 'x', '0'), isNull);
  });
}
