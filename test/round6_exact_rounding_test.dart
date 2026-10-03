import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/exact_constant.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

class _RejectRoundedNativeEngine extends CalculatorEngine {
  @override
  bool get isNativeAvailable => throw StateError('Exact rounding reached CAS');
}

void main() {
  test('rational floor and ceiling preserve signs and exact integer boundaries', () {
    final engine = _RejectRoundedNativeEngine();
    for (final entry in {
      'floor(-7/3)': '-3',
      'ceiling(-7/3)': '-2',
      'ceil(7/3)': '3',
      'floor(7/3)': '2',
      'floor(-6/3)': '-2',
      'ceiling(-6/3)': '-2',
      'floor(0)': '0',
      'ceiling(0)': '0',
      'floor(-0.001)': '-1',
      'ceiling(-0.001)': '0',
      'floor(ceiling(7/3)/2)': '1',
    }.entries) {
      expect(engine.evaluate(entry.key), entry.value, reason: entry.key);
      expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.exact);
      expect(engine.lastResultEvidence?.method, ComputationMethod.symbolicEvaluation);
    }
  });

  test('integer rounding never converts large rational inputs to doubles', () {
    final engine = _RejectRoundedNativeEngine();
    expect(engine.evaluate('floor(9007199254740993.9)'), '9007199254740993');
    expect(engine.evaluate('ceiling(9007199254740993.1)'), '9007199254740994');
    expect(engine.evaluate('floor(-9007199254740993.1)'), '-9007199254740994');
    expect(engine.evaluate('ceiling(-9007199254740993.9)'), '-9007199254740993');
    expect(engine.evaluate('floor(2^100+1/3)'), BigInt.two.pow(100).toString());
  });

  test('unsupported rounding operands retain normal CAS routing and budgets', () {
    for (final source in [
      'floor(x)', 'ceil(pi)', 'ceiling(sqrt(2))', 'floor(1/0)',
      'floor(1,2)', 'flooring(2)', 'ceiling()', 'floor((2^1024)^1024)',
    ]) {
      expect(ExactConstantEvaluator.evaluate(source), isNull, reason: source);
    }
  });
}
