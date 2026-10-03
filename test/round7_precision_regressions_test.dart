import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/exact_constant.dart';
import 'package:crisp_math/engine/matrix_evaluator.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoRoundedNativeEngine extends CalculatorEngine {
  @override
  bool get isNativeAvailable => throw StateError('Exact constant reached CAS');
}

void main() {
  test('scientific literals retain rational values before native conversion', () {
    final engine = _NoRoundedNativeEngine();
    final denominator = BigInt.from(10).pow(160);
    for (final entry in {
      '1e308*1e-308': '1',
      'sqrt(1e-320)': '1/$denominator',
      'sqrt(4E-320)': '1/${denominator ~/ BigInt.two}',
      '2.5e-2+.75E-1': '1/10',
      '-1.25e+2': '-125',
      '1e+2^2': '10000',
      'floor(-1e-320)': '-1',
      'ceiling(-1e-320)': '0',
    }.entries) {
      expect(engine.evaluate(entry.key), entry.value, reason: entry.key);
      expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.exact);
    }
  });

  test('scientific constant proof declines invalid or excessive inputs', () {
    for (final source in [
      '1e', '1e+', '1E--3', '1e100000000', '1e-10000',
      'sqrt(1e-319)', 'sin(1e2)', '1e2+x', '1e2/0',
    ]) {
      expect(ExactConstantEvaluator.evaluate(source), isNull, reason: source);
    }
  });

  test('matrix FFI cells preserve near singular decimal perturbations', () {
    expect(MatrixEvaluator.canonicalCell('1.0000000000000001'),
        '10000000000000001/10000000000000000');
    expect(MatrixEvaluator.canonicalCell('9007199254740993'),
        '9007199254740993');
    expect(MatrixEvaluator.canonicalCell('1e-16'), '1/10000000000000000');
    expect(MatrixEvaluator.canonicalCell(' 2.5E-1 '), '1/4');
    for (final source in ['x', 'sqrt(2)', '1+I', 'sin(t)', '1/0']) {
      expect(MatrixEvaluator.canonicalCell(source), source);
    }
  });
}
