import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/elementary_equation_solver.dart';
import 'package:crisp_math/engine/improper_exponential_integral.dart';
import 'package:crisp_math/engine/multivariate_poly.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('explicit polynomial equality uses both sides on every platform', () {
    final engine = CalculatorEngine();
    expect(engine.solve('(x-4)^2=25', 'x'), anyOf('x = {9, -1}', 'x = {-1, 9}'));
    expect(engine.solve('(t+2)^2=9', 't'), anyOf('t = {1, -5}', 't = {-5, 1}'));
    expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.exact);
    expect(engine.solve('3*x+1=10', 'x'), 'x = 3');
    expect(engine.solve('3*x+1=11', 'x'), 'x = 10/3');
  });

  test('affine exponents use exact rational powers and monotonicity', () {
    expect(ElementaryEquationSolver.solve('2^(x+1)=32', 'x'), ['4']);
    expect(ElementaryEquationSolver.solve('27=3^(2*x-1)', 'x'), ['2']);
    expect(ElementaryEquationSolver.solve('(1/2)^(x-1)=8', 'x'), ['-2']);
    expect(ElementaryEquationSolver.solve('5^(2*x)=1/25', 'x'), ['-1']);
    expect(ElementaryEquationSolver.solve('2^x=-3', 'x'), isEmpty);
    expect(ElementaryEquationSolver.solve('2^x=0', 'x'), isEmpty);
    for (final source in ['2^x=3', '1^x=1', '(-2)^x=4', '2^(x*x)=16', '2^x=4=8']) {
      expect(ElementaryEquationSolver.solve(source, 'x'), isNull, reason: source);
    }
    final engine = CalculatorEngine();
    expect(engine.solve('2^(x+1)=32', 'x'), 'x = 4');
    expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.exact);
  });

  test('real logarithm roots satisfy both strictly positive arguments', () {
    expect(ElementaryEquationSolver.solve('log(x-2)=log(7-x)', 'x'), ['9/2']);
    expect(ElementaryEquationSolver.solve('ln(3*t+1)=ln(10-t)', 't'), ['9/4']);
    expect(ElementaryEquationSolver.solve('log(x)=log(-x)', 'x'), isEmpty);
    expect(ElementaryEquationSolver.solve('log(x-5)=log(2-x)', 'x'), isEmpty);
    expect(ElementaryEquationSolver.solve('log(x)=log(x)', 'x'), isNull);
    expect(ElementaryEquationSolver.solve('log(x*x)=log(4)', 'x'), isNull);
    expect(ElementaryEquationSolver.solve('log(a*x)=log(3-x)', 'x'), isNull);
    final engine = CalculatorEngine();
    expect(engine.solve('log(x-2)=log(7-x)', 'x'), 'x = 9/2');
    expect(engine.solve('log(x)=log(-x)', 'x'), 'x = (no solutions)');
  });

  test('ordinary exponential half-line integrals retain exact moments and signs', () {
    expect(ImproperExponentialIntegral.definite('x*exp(-2*x)', 'x', '0', 'oo'), '1/4');
    expect(ImproperExponentialIntegral.definite('(x^2+3*x+2)*exp(-2*x)', 'x', '0', 'inf'), '2');
    expect(ImproperExponentialIntegral.definite('x*exp(-2*x)', 'x', 'oo', '0'), '-1/4');
    expect(ImproperExponentialIntegral.definite('x*exp(2*x)', 'x', '-oo', '0'), '-1/4');
    expect(ImproperExponentialIntegral.definite('x*exp(2*x)', 'x', '0', '-oo'), '1/4');
    expect(ImproperExponentialIntegral.definite('exp(-3*t)', 't', '0', '+infinity'), '1/3');
    final engine = CalculatorEngine();
    expect(engine.integrate('x*exp(-2*x)', 'x', '0', 'oo'), '1/4');
    expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.exact);
  });

  test('growth is divergent and unsupported improper forms do not gain exact proofs', () {
    expect(ImproperExponentialIntegral.definite('x*exp(2*x)', 'x', '0', 'oo'), contains('divergent'));
    expect(ImproperExponentialIntegral.definite('exp(-x)', 'x', '-oo', '0'), contains('divergent'));
    for (final source in ['exp(-x^2)', 'sin(x)*exp(-x)', 'x*exp(-x+1)', 'x^9*exp(-x)']) {
      expect(ImproperExponentialIntegral.definite(source, 'x', '0', 'oo'), isNull, reason: source);
    }
    expect(ImproperExponentialIntegral.definite('x*exp(-2*x)', 'x', '1', 'oo'), isNull);
    final engine = CalculatorEngine();
    expect(engine.integrate('x*exp(2*x)', 'x', '0', 'oo'), contains('divergent'));
    expect(engine.lastResultEvidence, isNull);
  });

  test('Sophie Germain factoring returns genuine quadratic factors', () {
    final engine = CalculatorEngine();
    for (final source in ['x^4+4*y^4', '16*a^4+4*b^4', 'x^4/16+4*y^4']) {
      final factors = engine.factor(source);
      expect(factors, contains('('));
      expect(factors, isNot(contains('^4')));
      expect(MultivariatePolynomial.tryParse(factors), MultivariatePolynomial.tryParse(source));
    }
    // Neighboring quartic coefficients must not receive the identity's factors.
    final neighbor = engine.factor('x^4+5*y^4');
    expect(MultivariatePolynomial.tryParse(neighbor), MultivariatePolynomial.tryParse('x^4+5*y^4'));
    expect(MultivariatePolynomial.tryParse(neighbor), isNot(MultivariatePolynomial.tryParse('x^4+4*y^4')));
  });
}
