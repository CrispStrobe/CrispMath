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
      '1/0',
      '0^-1',
      '3%0',
      '(1/2)%3',
      '2^(1/2)',
      '2^100000000',
      '(2^1024)^1024',
      '${List.filled(40, '(').join()}1${List.filled(40, ')').join()}',
      'sin(1)',
      '1.2%1',
      'x+1',
      '1 trailing',
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
      '19/2': '9.5',
      '1e-3*3': '0.003',
      '4/2': '2',
    }.entries) {
      expect(calc(entry.key), entry.value, reason: entry.key);
    }
    expect(terminatingDecimal(Rational(BigInt.one, BigInt.from(3))), isNull);
  });

  test('fraction results are answered in decimal, exact form kept', () {
    ExactConstantResult? calc(String s) =>
        ExactConstantEvaluator.evaluateDetailed(s, decimalInput: true);
    final long = calc('1+2*3-4/5+6*7-8+9*10-11/12+13*14-15+16*17-18/19+20*21')!;
    expect(long.text, '987.3359649122807');
    expect(long.exactFraction, '1125563/1140');
    expect(long.approximate, isTrue);
    expect(calc('1/3')!.text, '0.33333333333333333');
    expect(calc('2/3')!.text, '0.66666666666666667');
    expect(calc('-1/7')!.text, '-0.14285714285714286');
    expect(calc('0.1/3')!.text, '0.033333333333333333');
    final half = calc('19/2')!;
    expect(half.text, '9.5');
    expect(half.exactFraction, '19/2');
    expect(half.approximate, isFalse);
    // Integers stay exact and carry no fraction.
    expect(calc('6/3')!.exactFraction, isNull);
    expect(calc('2^127')!.text, '170141183460469231731687303715884105728');
    // Too many places to print exactly: rounded, scientific notation.
    expect(calc('sqrt(1e-320)')!.text, '1e-160');
    // Internal callers keep the exact text.
    expect(ExactConstantEvaluator.evaluate('19/2'), '19/2');
  });

  test('approximateDecimal rounds correctly in both notations', () {
    Rational r(int n, int d) => Rational(BigInt.from(n), BigInt.from(d));
    expect(approximateDecimal(r(1, 3), digits: 5), '0.33333');
    expect(approximateDecimal(r(2, 3), digits: 5), '0.66667');
    expect(approximateDecimal(r(999995, 1000000), digits: 5), '1');
    expect(approximateDecimal(r(123456789, 1), digits: 4), '123500000');
    expect(approximateDecimal(r(1, 30000000), digits: 4), '3.333e-8');
    expect(approximateDecimal(r(1, 3000000), digits: 4), '0.0000003333');
    expect(
        approximateDecimal(Rational(BigInt.from(10).pow(22), BigInt.from(3)),
            digits: 4),
        '3.333e+21');
    expect(approximateDecimal(r(-5, 4), digits: 17), '-1.25');
    expect(approximateDecimal(r(0, 1)), '0');
  });
}
