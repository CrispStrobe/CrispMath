import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/exact_constant.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

class _RejectNativeExactRootEngine extends CalculatorEngine {
  @override
  bool get isNativeAvailable => throw StateError('Exact root reached native CAS');
}

void main() {
  test('actual evaluation keeps perfect-square rational radicals exact', () {
    final engine = _RejectNativeExactRootEngine();
    for (final entry in {
      'sqrt(49)/sqrt(121)': '7/11',
      'sqrt(49/121)': '7/11',
      'sqrt(0)': '0',
      'sqrt(1)': '1',
      'sqrt(0.0625)': '1/4',
      'sqrt((-7/11)^2)': '7/11',
      '-sqrt(49)/sqrt(121)': '-7/11',
      'sqrt(sqrt(81))': '3',
      'sqrt(49)+sqrt(121)': '18',
    }.entries) {
      expect(engine.evaluate(entry.key), entry.value, reason: entry.key);
      expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.exact);
      expect(engine.lastResultEvidence?.method,
          ComputationMethod.symbolicEvaluation);
    }
  });

  test('perfect-square roots preserve integers above double precision', () {
    final engine = _RejectNativeExactRootEngine();
    expect(engine.evaluate('sqrt(9007199254740993^2)'), '9007199254740993');
    expect(engine.evaluate('sqrt(2^1024)'), BigInt.two.pow(512).toString());
    expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.exact);
  });

  test('irrational, complex, symbolic and excessive roots retain CAS routing', () {
    for (final source in [
      'sqrt(2)',
      'sqrt(2/9)',
      'sqrt(-4)',
      'sqrt(-1/4)',
      'sqrt(x^2)',
      'sqrt(1/0)',
      'sqrt(9007199254740993^2+1)',
      'sqrt((2^1024)^1024)',
      '${List.filled(40, 'sqrt(').join()}1${List.filled(40, ')').join()}',
    ]) {
      expect(ExactConstantEvaluator.evaluate(source), isNull, reason: source);
    }
  });
}
