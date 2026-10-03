import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:crisp_math/services/engine_dispatch.dart';
import 'package:crisp_math/services/engine_op.dart';
import 'package:flutter_test/flutter_test.dart';

// Exercise the real symbolic limit algorithm without requiring a native
// library in unit CI. Its bridge operations expose an independently known
// derivative sequence; each evaluation deliberately records intermediate
// arithmetic evidence, reproducing the metadata leak observed in Playwright.
class IntermediateEvidenceLimitEngine extends CalculatorEngine {
  @override
  bool get isNativeAvailable => true;

  @override
  String evaluate(String expression) {
    lastResultEvidence = const ResultEvidence(
        ResultAccuracy.exact, ComputationMethod.integerArithmetic);
    final value = NumericFallbackEvaluator.evalNumeric(expression);
    return value == null || !value.isFinite ? 'NaN' : '$value + 0.0*I';
  }

  @override
  String substitute(String expression, String variable, String value) =>
      expression.replaceAll(
          RegExp('\\b${RegExp.escape(variable)}\\b'), '($value)');

  @override
  String differentiate(String expression, String variable) =>
      {
        '1-cos(x)': 'sin(x)',
        'sin(x)': 'cos(x)',
        'x^2': '2*x',
        '2*x': '2',
      }[expression] ??
      'Error: unsupported controlled derivative';
}

void main() {
  test('completed LHopital limit replaces intermediate integer evidence', () {
    final result = runEngineOpDetailed(IntermediateEvidenceLimitEngine(),
        const EngineOp('limit', '(1-cos(x))/x^2', 'x', '0'));
    expect(double.parse(result.value), 0.5);
    expect(result.evidence?.accuracy, ResultAccuracy.symbolic);
    expect(result.evidence?.method, ComputationMethod.symbolicEvaluation);
    final restored = ComputedResult.fromJson(result.toJson());
    expect(restored.evidence?.accuracy, ResultAccuracy.symbolic);
    expect(restored.evidence?.method, ComputationMethod.symbolicEvaluation);
  });

  test('exact rational roots record their checked arithmetic provenance', () {
    final engine = CalculatorEngine();
    engine.evaluate('2^80');
    final result = runEngineOpDetailed(
        engine, const EngineOp('solve', '(x-1)/(x+2)-2', 'x'));
    expect(result.value, 'x = -5');
    expect(result.evidence?.accuracy, ResultAccuracy.exact);
    expect(result.evidence?.method, ComputationMethod.symbolicEvaluation);
  });

  test('exact rational infeasibility does not inherit prior method', () {
    final engine = CalculatorEngine();
    engine.evaluate('123');
    expect(engine.solve('(x-1)/(x-1)', 'x'), 'x = (no solutions)');
    expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.exact);
    expect(engine.lastResultEvidence?.method, ComputationMethod.symbolicEvaluation);
  });

  test('failed limit never persists intermediate arithmetic metadata', () {
    final engine = IntermediateEvidenceLimitEngine();
    final result = runEngineOpDetailed(
        engine, const EngineOp('limit', 'undefined(x)', 'x', 'not-a-point'));
    expect(result.value, startsWith('Error:'));
    expect(engine.lastResultEvidence, isNull);
    expect(result.evidence?.accuracy, isNot(ResultAccuracy.exact));
  });
}
