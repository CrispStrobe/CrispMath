import 'package:crisp_math/engine/exact_constant.dart';
import 'package:crisp_math/engine/polynomial.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('huge integer remainders never round through double', () {
    expect(ExactConstantEvaluator.evaluate('(10^40-1)%9'), '0');
    expect(ExactConstantEvaluator.evaluate('(2^200+3)%7'), '0');
    expect(ExactConstantEvaluator.evaluate('-10%3'), '2');
  });
  test('right associative powers preserve signs and exact reciprocals', () {
    for (final entry in {
      '2^(3^2)': '512',
      '(2^3)^2': '64',
      '(-3)^(-2)': '1/9',
      '(-2)^(-5)': '-1/32',
      '2^(-3)^2': '512',
      '(2^(-3))^2': '1/64',
      '-2^2': '-4',
      '(-2)^2': '4',
      '2^-3': '1/8',
      'abs(-11/13)+abs(2/13)': '1',
      '0.2+0.3': '1/2',
      '(0.125+0.375)^(-2)': '4',
    }.entries) {
      expect(ExactConstantEvaluator.evaluate(entry.key), entry.value,
          reason: entry.key);
    }
  });
  test('invalid domains and excessive work decline before powers allocate', () {
    for (final source in [
      '1/0', '0^-1', '3%0', '(1/2)%3', '2^(1/2)',
      '2^100000000', '(2^1024)^1024',
      '${List.filled(40, '(').join()}1${List.filled(40, ')').join()}',
      'sin(1)', '1.2%1', 'x+1', '1 trailing',
    ]) {
      expect(ExactConstantEvaluator.evaluate(source), isNull, reason: source);
    }
    expect(ExactConstantEvaluator.evaluate('2^127'),
        '170141183460469231731687303715884105728');
  });
  test('decimal input is answered in decimal on the calculator path', () {
    String? calc(String s) =>
        ExactConstantEvaluator.evaluate(s, decimalInput: true);
    for (final entry in {
      '9.5-2': '7.5',
      '2-9.5': '-7.5',
      '0.2+0.3': '0.5',
      '0.1*0.1': '0.01',
      '-0.05/4': '-0.0125',
      '9.5-1.5': '8',
      '19/2': '19/2',
      '1e-3*3': '0.003',
    }.entries) {
      expect(calc(entry.key), entry.value, reason: entry.key);
    }
    // Non-terminating decimal answers are left to the floating-point CAS.
    expect(calc('0.1/3'), isNull);
    expect(terminatingDecimal(Rational(BigInt.one, BigInt.from(3))), isNull);
  });
}
