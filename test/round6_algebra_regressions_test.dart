import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/multivariate_poly.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:crisp_math/engine/polynomial_quotient_cancellation.dart';
import 'package:crisp_math/engine/real_calculus_proofs.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:crisp_math/engine/symbolic_expr.dart';
import 'package:crisp_math/engine/symbolic_taylor.dart';
import 'package:crisp_math/engine/symbolic_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Taylor coefficient-only polynomials keep foreign symbols without native', () {
    final engine = CalculatorEngine();
    expect(engine.series('2-(2+y)', 'x', order: 3), '-y');
    expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.symbolic);
    expect(engine.series('2-(2+y)', 'x', point: '7/2', order: 64), '-y');
    expect(engine.series('3*t^2+1', 'x', point: '-2', order: 1), '3t^2 + 1');
    expect(engine.series('-3', 'x', order: 3), '-3');
    expect(engine.series('2-(2+y)', 'x', point: '1/0', order: 3), startsWith('Error:'));
    expect(engine.series('x+y', 'x', order: 3), startsWith('Error:'));
    expect(engine.series('x', 'x', order: 3), startsWith('Error:'));
    expect(engine.series('sin(y)', 'x', order: 3), startsWith('Error:'));
  });
  test('constant-first polynomial parsing retains actual non-x variables', () {
    expect(SymbolicWeb.expand('2-(2+y)'), '-y');
    expect(SymbolicWeb.expand('2*t+1'), '2t + 1');
    expect(SymbolicWeb.differentiate('2+y', 'y'), '1');
    expect(SymbolicWeb.differentiate('2+y', 'x'), '0');
    expect(SymbolicWeb.differentiate('3*(2+t)^2', 't'), '6t + 12');
    expect(SymbolicWeb.integrate('2+y', 'y'), '1/2y^2 + 2y');
    expect(SymbolicWeb.integrate('2+y', 'x'), isNull);
    expect(SymbolicWeb.definiteIntegral('2+t', 't', '0', '1'), '5/2');
    expect(SymbolicWeb.solveList('2+t', 't'), ['-2']);
    final engine = CalculatorEngine();
    expect(engine.integrate('2+y', 'y', '0', '1'), '5/2');
    expect(engine.differentiateAt('abs(2+y)', 'y', '0'), '1');
    expect(engine.differentiateAt('abs(2+y)', 'y', '-2'),
        contains('derivative does not exist'));
    expect(RealCalculusProofs.polynomial('2-(2+y)', 'x'), isNull);
    expect(RealCalculusProofs.polynomial('2-(2+y)', 'y')?.toString(), '-y');
  });
  test('Taylor shifted polynomial output is canonical without changing domains', () {
    expect(normalizePolynomialTaylorValue('2 - (2 + x)', 'x'), '-x');
    expect(normalizePolynomialTaylorValue('-4+4*(x+2)-(x+2)^2', 'x'), '-x^2');
    expect(normalizePolynomialTaylorValue('2-(2+y)', 'x'), '2-(2+y)');
    expect(normalizePolynomialTaylorValue('sin(x-2)', 'x'), 'sin(x-2)');
    expect(normalizePolynomialTaylorValue('Derivative(abs(x),x)', 'x'),
        'Derivative(abs(x),x)');
    expect(normalizePolynomialTaylorValue('x/(x-1)', 'x'), 'x/(x-1)');
    expect(normalizePolynomialTaylorValue('2-(2+x)+1', 'x'), '-x + 1');
  });
  test('absolute Taylor branches use local exact polynomial coefficients', () {
    expect(RealCalculusProofs.absoluteLocalPolynomial('abs(x)', 'x', '2'), 'x');
    expect(RealCalculusProofs.absoluteLocalPolynomial('abs(x)', 'x', '-2'), '-x');
    expect(RealCalculusProofs.absoluteLocalPolynomial('x*abs(x)', 'x', '-2'), '-x^2');
    expect(RealCalculusProofs.absoluteLocalPolynomial('abs(x)', 'x', '0'), isNull);
    final local = RealCalculusProofs.absoluteLocalPolynomial('x*abs(x)', 'x', '-2')!;
    final engine = CalculatorEngine();
    final tangent = symbolicTaylorSeries(local, 'x', point: '-2', order: 2,
        simplify: (s) => SymbolicExpressionEvaluator.tryEvaluate(s) ?? 'Error',
        differentiate: (s, v) => SymbolicWeb.differentiate(s, v) ?? 'Error',
        substitute: engine.substitute);
    for (final x in [-3.0, -2.0, -1.0]) {
      expect(NumericFallbackEvaluator.evalNumeric(tangent, {'x': x}),
          closeTo(4 * x + 4, 1e-12));
    }
  });

  test('Taylor coefficients reject unevaluated derivative and substitution forms', () {
    for (final formal in ['Derivative(abs(x),x)', 'Subs(f(x),x,2)']) {
      final value = symbolicTaylorSeries('abs(x)', 'x', point: '2', order: 3,
          simplify: (s) => s,
          differentiate: (s, v) => formal,
          substitute: (s, v, p) => s);
      expect(value, startsWith('Error: series'));
      expect(invalidSymbolicTaylorValue(formal), isTrue);
    }
    expect(invalidSymbolicTaylorValue('Derivative+Subs*x'), isFalse);
  });
  test('multivariate exact cancellation retains original denominator restriction', () {
    final engine = CalculatorEngine();
    final result = engine.simplify('(x^2-y^2)/(x-y)');
    expect(result, 'x+y');
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
    expect(engine.differentiateAt('abs(2*x-4)', 'x', '2'),
        contains('derivative does not exist'));
    expect(engine.differentiateAt('abs(x/2-1)', 'x', '3'), '1/2');
    expect(engine.differentiateAt('abs(x/2-1)', 'x', '1'), '-1/2');
    expect(engine.differentiateAt('(x-2)*abs(3*x-6)', 'x', '2'), '0');
    expect(engine.series('abs(x)', 'x', order: 2), startsWith('Error:'));
    expect(engine.series('x*abs(x)', 'x', order: 2), '0');
    expect(engine.series('x*abs(x)', 'x', order: 3), startsWith('Error:'));
    expect(engine.series('x^2*abs(x)', 'x', order: 3), '0');
    expect(engine.series('x^2*abs(x)', 'x', order: 4), startsWith('Error:'));
    expect(engine.series('(x-2)*abs(3*x-6)', 'x', point: '2', order: 2), '0');
    expect(engine.series('(x-2)*abs(3*x-6)', 'x', point: '2', order: 3),
        startsWith('Error:'));
    expect(RealCalculusProofs.cuspDerivative('abs(x^2)', 'x', '0'), isNull);
    expect(RealCalculusProofs.cuspDerivative('abs(y)', 'x', '0'), isNull);
  });
}
