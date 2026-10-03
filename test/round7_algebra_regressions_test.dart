import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/exact_complex_constant.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:crisp_math/engine/polynomial.dart';
import 'package:crisp_math/engine/polynomial_domain_proofs.dart';
import 'package:crisp_math/engine/rational_equation_solver.dart';
import 'package:crisp_math/engine/rational_integral_domain.dart';
import 'package:crisp_math/engine/real_calculus_proofs.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:crisp_math/engine/symbolic_input_budget.dart';
import 'package:crisp_math/engine/symbolic_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Gaussian conjugation retains both signs and handles complex quotients', () {
    expect(ExactComplexConstant.conjugation('conjugate((2+3*I)/(1-2*I))'), '-4/5-7/5*I');
    expect(ExactComplexConstant.conjugation('conjugate(3-4*I)'), '3+4*I');
    expect(ExactComplexConstant.conjugation('conjugate(conjugate(3-4*I))'), '3-4*I');
    expect(ExactComplexConstant.conjugation('2+conjugate(I)'), '2-1*I');
    expect(ExactComplexConstant.conjugation('conjugate(2/3)'), '2/3');
    for (final source in ['conjugate(x+I)', 'conjugate(i)', 'conjugate(1/0)',
      'conjugate(sqrt(2)+I)', 'conjugate(2^100000000)', 'conjugate(1e100000000)']) {
      expect(ExactComplexConstant.conjugation(source), isNull, reason: source);
    }
  });

  test('principal negative powers are transformed throughout constant arithmetic', () {
    for (final source in ['(-8)^(1/3)', '2+(-8)^(1/3)', '(-8)^(-1/3)']) {
      final polar = ExactComplexConstant.principalPower(source);
      expect(polar, isNotNull, reason: source);
      expect(polar, contains('cos('));
      expect(polar, contains('sin('));
      expect(polar, contains('I'));
      expect(ExactComplexConstant.principalPower(polar!), isNull,
          reason: 'The rewrite must terminate without another negative base');
    }
    for (final source in ['(-8)^3', '8^(1/3)', '(-x)^(1/3)', '(-8)^(1/x)',
      '(-8)^(1/129)', '(-1e100000000)^(1/3)', '(-1e-100000000)^(1/3)',
      '(-8)^((2^128)^128)', '1+2']) {
      expect(ExactComplexConstant.principalPower(source), isNull, reason: source);
    }
  });

  test('symbolic literal budgets guard exponent allocation before parsing', () {
    expect(boundedSymbolicLiterals('1e1024+1e-1024'), isTrue);
    for (final source in ['1e1025', '1e-1025', '0.1e-1024',
      '1e999999999999999999999999999', '1e-9223372036854775808']) {
      expect(boundedSymbolicLiterals(source), isFalse, reason: source);
    }
    expect(RationalEquationSolver.solve('1e100000000/(x-1)', 'x'), isNull);
    expect(RationalEquationSolver.solve('x^((2^128)^128)/(x-1)', 'x'), isNull);
    expect(RationalIntegralDomain.containsPole('1/(x-1e100000000)', 'x', '0', '1'), isNull);
    expect(RealCalculusProofs.polynomial('x+1e100000000', 'x'), isNull);
  });

  test('original denominator factors exclude every repeated or irrational root', () {
    final engine = CalculatorEngine();
    expect(engine.solve('(x-1)^2*(x+2)/(x-1)', 'x'), 'x = -2');
    expect(engine.solve('(x-1)^2*(x+2)*(x-1)^(-1)', 'x'), 'x = -2');
    expect(engine.solve('(x^2-2)^2/(x^2-2)', 'x'), 'x = (no solutions)');
    expect(engine.solve('(x^2+1)^2/(x^2+1)', 'x'), 'x = (no solutions)');
    expect(RationalEquationSolver.candidateEquation('(x-1)^2*(x+2)^3/(x-1)', 'x'),
        'x^3 + 6x^2 + 12x + 8');
    final roots = RationalEquationSolver.solve('(x^2-2)*(x-1)/(x-1)', 'x')!;
    expect(roots, hasLength(2));
    final numeric = roots.map((s) => NumericFallbackEvaluator.evalNumeric(s)!).toList()..sort();
    expect(numeric.first, closeTo(-1.4142135623730951, 1e-12));
    expect(numeric.last, closeTo(1.4142135623730951, 1e-12));
  });

  test('Sturm proof finds irrational and repeated poles without sample hits', () {
    final quartic = Polynomial.tryParse('x^4-2')!;
    expect(PolynomialDomainProofs.rootInInterval(quartic, Rational.fromInt(-2), Rational.fromInt(2)), isTrue);
    expect(PolynomialDomainProofs.rootInInterval(quartic, Rational.zero, Rational.one), isFalse);
    final repeated = Polynomial.tryParse(SymbolicWeb.expand('(x^4-2)^2')!)!;
    expect(PolynomialDomainProofs.rootInInterval(repeated, Rational.fromInt(2), Rational.fromInt(-2)), isTrue);
    expect(PolynomialDomainProofs.rootInInterval(Polynomial.tryParse('x^4+1')!, Rational.fromInt(-2), Rational.fromInt(2)), isFalse);
    expect(PolynomialDomainProofs.rootInInterval(Polynomial.tryParse('x^17-2')!, Rational.fromInt(-2), Rational.fromInt(2)), isNull);
    expect(RationalIntegralDomain.containsPole('1/(x^4-2)', 'x', '-2', '2'), isTrue);
    expect(RationalIntegralDomain.containsPole('(x^4-2)/(x^4-2)', 'x', '-2', '2'), isFalse);
    expect(RationalIntegralDomain.containsPole('1/(y^4-2)', 'x', '-2', '2'), isNull);
    final engine = CalculatorEngine();
    expect(engine.integrate('1/(x^4-2)', 'x', '-2', '2'), contains('divergent pole'));
    expect(engine.lastResultEvidence, isNull);
    expect(engine.integrate('(x^4-2)/(x^4-2)', 'x', '-2', '2'), '4');
  });

  test('logarithm powers use convergent limiting endpoint primitives', () {
    final engine = CalculatorEngine();
    expect(engine.integrate('ln(x)^2', 'x', '0', '1'), '2');
    expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.approximate);
    expect(engine.lastResultEvidence?.method, ComputationMethod.fundamentalTheorem);
    expect(engine.integrate('ln(x)^2', 'x', '1', '0'), '-2');
    expect(engine.integrate('ln(2*x)^2', 'x', '0', '1/2'), '1');
    expect(engine.integrate('ln(x)^3', 'x', '0', '1'), '-6');
    expect(engine.integrate('ln(x)^4', 'x', '0', '1'), '24');
    expect(engine.integrate('ln(1-x)^2', 'x', '0', '2'), contains('real integrand domain'));
    expect(RealCalculusProofs.definite('ln(x)^2)', 'x', '0', '1'), isNull);
    expect(RealCalculusProofs.definite('ln(x)^9', 'x', '0', '1'), isNull);
    expect(RealCalculusProofs.definite('ln(x)^(-1)', 'x', '0', '1'), isNull);
  });

  test('polynomial inner signs and root multiplicity govern real abs derivatives', () {
    final engine = CalculatorEngine();
    expect(engine.differentiateAt('abs(x^2-1)', 'x', '0'), '0');
    expect(engine.differentiateAt('abs(x^2-1)', 'x', '1/2'), '-1');
    expect(engine.differentiateAt('abs(x^2-1)', 'x', '2'), '4');
    expect(engine.differentiateAt('abs(x^2-1)', 'x', '1'), contains('does not exist'));
    expect(engine.differentiateAt('abs(x^3)', 'x', '0'), '0');
    expect(engine.differentiateAt('abs(-x^2)', 'x', '0'), '0');
    expect(RealCalculusProofs.absoluteLocalPolynomial('abs(x^2-1)', 'x', '0'), '-x^2 + 1');
    expect(RealCalculusProofs.absoluteLocalPolynomial('abs(-x^2)', 'x', '0'), 'x^2');
    expect(RealCalculusProofs.absoluteLocalPolynomial('abs(x^3)', 'x', '0'), isNull);
    expect(engine.series('abs(x^3)', 'x', order: 3), '0');
    expect(engine.series('abs(x^3)', 'x', order: 4), contains('does not exist'));
    expect(RealCalculusProofs.absoluteDerivative('abs(y^2-1)', 'x', '0'), isNull);
    expect(RealCalculusProofs.absoluteLocalPolynomial('abs(x^2-1)', 'x', '1'), isNull);
  });

  test('quadratic radical infinity cancellation is exact and branch-sensitive', () {
    final engine = CalculatorEngine();
    expect(engine.limit('sqrt(x^2+3*x)-x', 'x', 'oo'), '3/2');
    expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.symbolic);
    expect(engine.limit('x-sqrt(x^2+3*x)', 'x', 'oo'), '-3/2');
    expect(engine.limit('sqrt(x^2+3*x)-(-x)', 'x', '-oo'), '-3/2');
    expect(engine.limit('sqrt(4*x^2+8*x+1)-(2*x+3)', 'x', 'oo'), '-1');
    expect(RealCalculusProofs.quadraticRadicalLimit('sqrt(x^2+3*x)-2*x', 'x', 'oo'), isNull);
    expect(RealCalculusProofs.quadraticRadicalLimit('sqrt(x^2+3*x)-x', 'x', '-oo'), isNull);
    expect(RealCalculusProofs.quadraticRadicalLimit('sqrt(-x^2+3*x)-x', 'x', 'oo'), isNull);
    expect(RealCalculusProofs.quadraticRadicalLimit('sqrt(y^2+3*y)-x', 'x', 'oo'), isNull);
  });
}
