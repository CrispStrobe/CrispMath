// test/percentage_preprocessor_test.dart
//
// Unit tests for the percentage preprocessing in
// ExpressionPreprocessingUtils.preprocessPercentage.

import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_calc/utils/expression_preprocessing_utils.dart';

void main() {
  String pct(String input) =>
      ExpressionPreprocessingUtils.preprocessPercentage(input);

  group('preprocessPercentage', () {
    // --- N% of M ---
    test('N% of M', () {
      expect(pct('20% of 150'), '(20)/100*(150)');
    });

    test('N% of M with decimal', () {
      expect(pct('8.5% of 200'), '(8.5)/100*(200)');
    });

    test('N% von M (German)', () {
      expect(pct('20% von 150'), '(20)/100*(150)');
    });

    test('N% de M (French/Spanish)', () {
      expect(pct('20% de 150'), '(20)/100*(150)');
    });

    // --- M + N% (markup) ---
    test('M + N% markup', () {
      expect(pct('150 + 20%'), '(150)*(1+(20)/100)');
    });

    test('M + N% with decimals', () {
      expect(pct('142.50 + 8.5%'), '(142.50)*(1+(8.5)/100)');
    });

    // --- M - N% (discount) ---
    test('M - N% discount', () {
      expect(pct('200 - 10%'), '(200)*(1-(10)/100)');
    });

    test('M - N% with decimal percent', () {
      expect(pct('99.99 - 15%'), '(99.99)*(1-(15)/100)');
    });

    // --- M * N% ---
    test('M * N%', () {
      expect(pct('500 * 20%'), '(500)*(20)/100');
    });

    // --- bare N% ---
    test('bare N%', () {
      expect(pct('25%'), '(25)/100');
    });

    test('bare N% with decimal', () {
      expect(pct('8.5%'), '(8.5)/100');
    });

    // --- what % of M is N ---
    test('what % of M is N', () {
      expect(pct('what % of 200 is 40'), '(40)/(200)*100');
    });

    test('what percent of M is N', () {
      expect(pct('what percent of 200 is 40'), '(40)/(200)*100');
    });

    test('wieviel prozent von M ist N (German)', () {
      expect(pct('wieviel prozent von 200 ist 40'), '(40)/(200)*100');
    });

    test('quel pourcent de M est N (French)', () {
      expect(pct('quel pourcent de 200 est 40'), '(40)/(200)*100');
    });

    test('qué por ciento de M es N (Spanish)', () {
      expect(pct('qué por ciento de 200 es 40'), '(40)/(200)*100');
    });

    // --- no-op cases ---
    test('plain arithmetic passes through', () {
      expect(pct('2 + 3'), '2 + 3');
    });

    test('expression without % passes through', () {
      expect(pct('sin(x) + cos(x)'), 'sin(x) + cos(x)');
    });

    test('mod expression passes through (no % in user input for mod)', () {
      expect(pct('17 mod 5'), '17 mod 5');
    });

    // --- assignment with percentage ---
    test('assignment with bare percent', () {
      // `tax = 8.5%` should become `tax = (8.5)/100`
      // The bare-percent regex catches this: prefix = `tax =`, N = `8.5`.
      expect(pct('tax = 8.5%'), 'tax = (8.5)/100');
    });
  });
}
