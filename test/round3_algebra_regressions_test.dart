import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/rational_integral_domain.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('definite integration extends removable holes with exact arithmetic', () {
    final engine = CalculatorEngine();
    // (x^2-4)/(x-2) = x+2 away from x=2. Its improper integral
    // from 1 to 3 is [x^2/2+2x]_1^3 = 8, not a Simpson 0/0 failure.
    expect(engine.integrate('(x^2-4)/(x-2)', 'x', '1', '3'), '8');
    expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.exact);
    expect(engine.integrate('(x^2-4)/(x-2)', 'x', '3', '1'), '-8');
    // A removable hole at an endpoint also has a convergent integral.
    expect(engine.integrate('(x^2-4)/(x-2)', 'x', '2', '3'), '9/2');
    // Cancellation must retain rational coefficients, including denominator 2.
    expect(engine.integrate('(x^2-4)/(2*x-4)', 'x', '1', '3'), '4');
    expect(engine.integrate('0/(x-2)', 'x', '1', '3'), '0');
  });

  test('cancellation cannot hide a remaining or irrational divergent pole', () {
    final engine = CalculatorEngine();
    expect(engine.integrate('(x-2)/(x^2-4)', 'x', '-3', '3'),
        startsWith('Error: integration interval contains a divergent pole'));
    expect(engine.lastResultEvidence, isNull);
    expect(engine.integrate('1/(x^2-2)', 'x', '0', '2'),
        startsWith('Error: integration interval contains a divergent pole'));
    expect(engine.lastResultEvidence, isNull);
    expect(engine.integrate('(x-2)/(x-2)^2', 'x', '1', '3'),
        startsWith('Error: integration interval contains a divergent pole'));
  });

  test('rational extension preserves the declared variable and grammar bounds',
      () {
    expect(RationalIntegralDomain.reducedExpression('(x^2-4)/(x-2)', 'y'),
        isNull);
    expect(RationalIntegralDomain.reducedExpression('1/sin(x)', 'x'), isNull);
    expect(RationalIntegralDomain.reducedExpression('1/(x^2+1)', 'x'), isNull);
    expect(RationalIntegralDomain.reducedExpression('(x^2-4)/(x-2)', 'x'),
        'x + 2');
  });
}
