import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/definite_antiderivative.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:crisp_math/engine/rational_integral_domain.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

class RejectNativeRoutingEngine extends CalculatorEngine {
  @override
  bool get isNativeAvailable => throw StateError('Native route reached');
}

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

  test('composed real antiderivatives evaluate safely without native FFI', () {
    expect(DefiniteAntiderivative.evaluate('ln(abs(1+x^3))/3', 'x', '0', '1'),
        closeTo(0.23104906018664842, 1e-14));
    expect(DefiniteAntiderivative.evaluate('sqrt(1+x^2)', 'x', '0', 'sqrt(3)'),
        closeTo(1, 1e-14));
    expect(DefiniteAntiderivative.evaluate('x*ln(x)-x', 'x', '1', '2'),
        closeTo(0.3862943611198906, 1e-14));
    expect(DefiniteAntiderivative.evaluate(
        'x/2+sin(2*x)/4', 'x', '-pi/2', 'pi/2'),
        closeTo(1.5707963267948966, 1e-14));
  });

  test('finite real FTC rejects unresolved symbols and undefined endpoints', () {
    expect(DefiniteAntiderivative.evaluate('ln(abs(x))', 'x', '0', '1'),
        isNull);
    expect(DefiniteAntiderivative.evaluate('sqrt(x)', 'x', '-1', '1'), isNull);
    expect(DefiniteAntiderivative.evaluate('x+y', 'x', '0', '1'), isNull);
    expect(DefiniteAntiderivative.evaluate('x^2', 'x', 'missing', '1'), isNull);
  });

  test('finite compound log constants bypass native routing with honest evidence',
      () {
    final engine = RejectNativeRoutingEngine();
    for (final expression in ['ln(abs(-2))', 'log(abs(-2))']) {
      expect(double.parse(engine.evaluate(expression)),
          closeTo(0.6931471805599453, 1e-14));
      expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.approximate);
      expect(engine.lastResultEvidence?.method, ComputationMethod.numericFallback);
    }
    expect(double.parse(engine.evaluate('ln(abs(1e-3))')),
        closeTo(-6.907755278982137, 1e-13));
    for (final expression in ['ln(abs(0))', 'ln(abs(1/(1-1)))']) {
      expect(engine.evaluate(expression), startsWith('Error:'));
      expect(engine.lastResultEvidence, isNull);
    }
  });

  test('compound expressions with free or complex symbols retain CAS routing',
      () {
    final engine = RejectNativeRoutingEngine();
    expect(() => engine.evaluate('ln(abs(x))'), throwsStateError);
    expect(() => engine.evaluate('ln(abs(-2))+q'), throwsStateError);
    expect(() => engine.evaluate('ln(abs(-2))+I'), throwsStateError);
  });
}
