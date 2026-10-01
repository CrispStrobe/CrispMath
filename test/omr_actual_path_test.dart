// Deterministic coverage of the OCR-to-calculator handoff. Native image
// recognition is exercised separately by native_test/ocr_native_test.dart.
import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/utils/latex_conversion_utils.dart';

void main() {
  for (final latex in [r'5 + 7', r'\frac{10}{2} + 7', r'\sqrt{25} + 7']) {
    test('OCR LaTeX handoff evaluates $latex exactly', () {
      final expression = LatexConversionUtils.fromLatex(latex);
      expect(CalculatorEngine().evaluate(expression), '12');
    });
  }
}
