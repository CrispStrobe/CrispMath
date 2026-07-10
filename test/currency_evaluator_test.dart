// test/currency_evaluator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_math/engine/currency_evaluator.dart';

void main() {
  group('CurrencyEvaluator', () {
    test('100 USD in EUR', () {
      final r = CurrencyEvaluator.tryEvaluate('100 USD in EUR');
      expect(r, isNotNull);
      expect(r, contains('EUR'));
      // 100 * 0.92 = 92.00
      expect(r, '92.00 EUR');
    });

    test('100 EUR in USD', () {
      final r = CurrencyEvaluator.tryEvaluate('100 EUR in USD');
      expect(r, isNotNull);
      // 100 / 0.92 * 1.0 ≈ 108.70
      expect(r, contains('USD'));
    });

    test('1000 JPY in USD (zero-decimal target)', () {
      final r = CurrencyEvaluator.tryEvaluate('1000 USD in JPY');
      expect(r, isNotNull);
      // 1000 * 157.5 = 157500 — JPY is zero-decimal
      expect(r, '157500 JPY');
    });

    test('case insensitive', () {
      final r = CurrencyEvaluator.tryEvaluate('50 usd in eur');
      expect(r, isNotNull);
      expect(r, '46.00 EUR');
    });

    test('unknown currency returns null', () {
      expect(CurrencyEvaluator.tryEvaluate('100 XYZ in USD'), isNull);
    });

    test('non-currency expression returns null', () {
      expect(CurrencyEvaluator.tryEvaluate('sin(x)'), isNull);
      expect(CurrencyEvaluator.tryEvaluate('2 + 3'), isNull);
    });

    test('dollar prefix works', () {
      final r = CurrencyEvaluator.tryEvaluate(r'$100 USD in GBP');
      expect(r, isNotNull);
      expect(r, contains('GBP'));
    });

    test('knownCodes is non-empty', () {
      expect(CurrencyEvaluator.knownCodes, isNotEmpty);
      expect(CurrencyEvaluator.knownCodes.contains('USD'), true);
      expect(CurrencyEvaluator.knownCodes.contains('EUR'), true);
    });
  });
}
