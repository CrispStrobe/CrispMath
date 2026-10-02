import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:crisp_math/engine/rational_integral_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('substitution keeps identifier boundaries, precedence and numeric tokens',
      () {
    final engine = CalculatorEngine();
    expect(engine.substitute('x^2+x1+axis+exp(x)', 'x', '1+2'),
        '(1+2)^2+x1+axis+exp((1+2))');
    expect(engine.substitute('1e-3+e', 'e', '2'), '1e-3+(2)');
    expect(engine.substitute('x(x+1)', 'x', '2'), '(2)((2)+1)');
    expect(engine.substitute('sin(x)+sin', 'sin', '2'), 'sin(x)+(2)');
    expect(engine.substitute('x+1', 'x)', '2'), startsWith('Error:'));
    expect(engine.substitute('x+1', 'x', ''), startsWith('Error:'));
    expect(NumericFallbackEvaluator.evalNumeric(
        engine.substitute('x^2+1', 'x', '-3')), 10);
  });

  test('rational pole checks include endpoints and reversed bounds', () {
    expect(RationalIntegralDomain.polesWithin('1/(x-1)', 'x', '0', '2'), [1]);
    expect(RationalIntegralDomain.polesWithin('1/(x-1)', 'x', '2', '0'), [1]);
    expect(RationalIntegralDomain.polesWithin('((1/(x-1)))', 'x', '0', '2'),
        [1]);
    expect(RationalIntegralDomain.polesWithin('1/x', 'x', '0', '1'), [0]);
    expect(RationalIntegralDomain.polesWithin('1/(x^2-1)', 'x', '-2', '2'),
        unorderedEquals([-1, 1]));
    expect(RationalIntegralDomain.polesWithin('1/(x-3)', 'x', '0', '2'),
        isEmpty);
  });

  test('exact cancellation separates removable holes from divergent poles', () {
    expect(RationalIntegralDomain.polesWithin('(x^2-1)/(x-1)', 'x', '0', '2'),
        isEmpty);
    expect(RationalIntegralDomain.polesWithin('0/(x-1)', 'x', '0', '2'),
        isEmpty);
    expect(
        RationalIntegralDomain.polesWithin('(x-1)/(x-1)^2', 'x', '0', '2'),
        [1]);
    expect(RationalIntegralDomain.polesWithin('1/(x^2+1)', 'x', '-2', '2'),
        isEmpty);
    expect(RationalIntegralDomain.polesWithin('1/sin(x)', 'x', '0', '2'),
        isNull); // Unsupported is never a claim that the domain is safe.
    expect(RationalIntegralDomain.polesWithin('(y-1)/(x-1)', 'x', '0', '2'),
        isNull);
    expect(RationalIntegralDomain.polesWithin('1/(x-1)', 'y', '0', '2'),
        isNull);
    expect(RationalIntegralDomain.polesWithin('1/(x-1)', 'x)', '0', '2'),
        isNull);
  });

  test('ordinary definite integral never returns an interior-pole principal value',
      () {
    final engine = CalculatorEngine();
    expect(engine.integrate('1/(x-1)', 'x', '0', '2'),
        startsWith('Error: integration interval contains a divergent pole'));
    expect(engine.lastResultEvidence, isNull);
    expect(engine.integrate('1/x', 'x', '0', '1'),
        startsWith('Error: integration interval contains a divergent pole'));
  });
}
