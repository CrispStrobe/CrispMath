import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:crisp_math/engine/rational_equation_solver.dart';
import 'package:crisp_math/engine/rational_domain.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:crisp_math/engine/symbolic_limit.dart';
import 'package:crisp_math/engine/symbolic_web.dart';
import 'package:flutter_test/flutter_test.dart';

class ComplexFormattedLimitEngine extends CalculatorEngine {
  // This controlled bridge substitute implements every operation exercised by
  // the test. Expose that capability even when CI has no native shared library.
  @override
  bool get isNativeAvailable => true;

  final differentiated = <String>[];

  @override
  String evaluate(String expression) {
    final value = NumericFallbackEvaluator.evalNumeric(expression);
    return value == null || !value.isFinite ? 'NaN' : '$value + 0.0*I';
  }

  @override
  String substitute(String expression, String variable, String value) =>
      expression.replaceAll(
          RegExp('\\b${RegExp.escape(variable)}\\b'), '($value)');

  @override
  String differentiate(String expression, String variable) {
    differentiated.add(expression);
    return {
          '1-cos(x)': 'sin(x)',
          'sin(x)': 'cos(x)',
          'x^2': '2*x',
          '2*x': '2'
        }[expression] ??
        'Error: unsupported test derivative';
  }
}

class NativeLessArithmeticEngine extends CalculatorEngine {
  @override
  bool get isNativeAvailable => false;
}

void main() {
  test('whole-quotient domain evidence never consumes additive tails', () {
    expect(RationalDomain.inspect('x^3/3+C'), isNull);
    expect(RationalDomain.inspect('(x-1)/(x+2)-2'), isNull);
    expect(RationalDomain.inspect('(x^2-9)/(x^2+x-6)')?.excluded,
        unorderedEquals(['-3', '2']));
    expect(RationalDomain.inspect('-3/x')?.excluded, ['0']);
    expect(RationalDomain.inspect('1/(-x+2)')?.excluded, ['2']);
  });
  test('exact arithmetic preserves small answers after huge cancellation', () {
    final engine = CalculatorEngine();
    for (final pair in [
      ['(2^127-1)-(2^127-2)', '1'],
      ['(2^80+1)-2^80', '1'],
      ['10^30+7-10^30', '7'],
      ['1/6+1/10+1/15', '1/3'],
      ['2^(-3)+4^(-2)', '3/16'],
      ['abs(-3/7)/(9/14)', '2/3'],
      ['1+1/3+1/9+1/27', '40/27'],
    ]) {
      expect(engine.evaluate(pair[0]), pair[1]);
      expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.exact);
    }
    expect(engine.evaluate('1/0'), isNot('0'));
  });

  test('negative-power exact rewrite preserves right-associative exponents', () {
    final engine = NativeLessArithmeticEngine();
    expect(engine.evaluate('2^(-3)^2'), '512');
    expect(engine.evaluate('2^(-3) ^ 0'), '2');
    expect(engine.evaluate('-2^(-3)^2'), '-512');
    expect(engine.evaluate('(2^(-3))^2'), '1/64');
    expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.exact);
  });

  test('constant powers have a coefficient budget independent of degree', () {
    // The first powers are small; guards must decline the next operation
    // before constructing its huge coefficient, not compute then inspect it.
    expect(SymbolicWeb.expand('((9^256)^256)^256'), isNull);
    expect(SymbolicWeb.expand('(1/(9^256))^256'), isNull);
    expect(RationalEquationSolver.solve('(((((9^8)^8)^8)^8)^8)/1+x', 'x'),
        isNull);
    expect(SymbolicWeb.expand('2^127'),
        '170141183460469231731687303715884105728');
    expect(RationalEquationSolver.solve('x/(2^100)-1', 'x'),
        isNull); // Exponent 100 remains outside this solver's degree-8 grammar.
    expect(RationalEquationSolver.solve('x/(2^8)-1', 'x'), ['256']);
    expect(SymbolicWeb.expand('1/0'), isNull);
    expect(SymbolicWeb.expand('1/(2-2)'), isNull);
  });

  for (final entry in <String, List<String>>{
    '(x-1)/(x+2)-2': ['-5'],
    '(x-1)/(x+2)=2': ['-5'],
    '(x^2-1)/(x-1)': ['-1'],
    '(x^2-4)/(x+2)': ['2'],
    '1/x=0': [],
    'x/(x-1)=1': [],
    '1/(1/x)': [],
    '(x^2-1)/(x+3)': ['1', '-1'],
  }.entries) {
    test('rational solve retains original exclusions: ${entry.key}', () {
      expect(RationalEquationSolver.solve(entry.key, 'x'),
          unorderedEquals(entry.value));
    });
  }
  test('bounded rational fallback declines unsupported syntax and identities',
      () {
    for (final expression in [
      'sin(x)/x',
      '(x+y)/x',
      'x/x=1',
      '1/(x-x)',
      'x^9/(x+1)',
      'sqrt(x)/x'
    ]) {
      expect(RationalEquationSolver.solve(expression, 'x'), isNull);
    }
  });
  test('native zero imaginary formatting permits both LHopital steps', () {
    final engine = ComplexFormattedLimitEngine();
    final result = SymbolicLimit.compute(
        engine: engine,
        expression: '(1-cos(x))/x^2',
        variable: 'x',
        point: '0');
    expect(result?.method, 'lhopital');
    expect(double.parse(result!.value), closeTo(0.5, 1e-14));
    expect(engine.differentiated, ['1-cos(x)', 'x^2', 'sin(x)', '2*x']);
  });
}
