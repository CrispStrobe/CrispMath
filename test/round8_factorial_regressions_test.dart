import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/exact_constant.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('factorial arithmetic is exact for function and postfix spellings', () {
    final engine = CalculatorEngine();
    final references = <String, String>{
      'factorial(30)/factorial(29)': '30',
      '30!/29!': '30',
      'factorial(0)+factorial(1)': '2',
      'factorial(30)': '265252859812191058636308480000000',
      'factorial(21)/factorial(20)': '21',
      'factorial(30)/(factorial(15)*factorial(15))': '155117520',
      'factorial(500)/factorial(499)': '500',
      'factorial(3+2)': '120',
      'factorial(6/2)': '6',
      'factorial(3!)': '720',
      '3!!': '720',
      '3!^2': '36',
      '5!^2': '14400',
      '2^3!': '64',
      '-3!': '-6',
      '(2+3)!': '120',
    };
    for (final entry in references.entries) {
      expect(engine.evaluate(entry.key), entry.value, reason: entry.key);
      expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.exact,
          reason: entry.key);
    }
  });

  test('factorial domains and construction budgets decline conservatively', () {
    for (final source in [
      'factorial(-1)', '(-3)!', 'factorial(3/2)', 'factorial(x)',
      'factorial(1/0)', 'factorial()', 'factorial(2,3)', 'factorialx(3)',
      'factorial(100000000)', 'factorial(2048)', 'factorial(2^1024)',
      'factorial(factorial(8))', '100000000!', 'factorial(1e100000000)',
    ]) {
      expect(ExactConstantEvaluator.evaluate(source), isNull, reason: source);
    }
    // Supporting postfix factorial must not consume inequality syntax.
    expect(ExactConstantEvaluator.evaluate('3!=4'), isNull);
  });
}
