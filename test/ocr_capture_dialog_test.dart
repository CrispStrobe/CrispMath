// test/ocr_capture_dialog_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_calc/engine/ocr_provider.dart';

void main() {
  group('OcrProviders integration', () {
    test('active provider starts null', () {
      expect(OcrProviders.active, isNull);
    });

    test('available list is empty without providers', () {
      // In test environment, no providers are registered
      expect(OcrProviders.available, isEmpty);
    });
  });

  group('postProcessOcrText integration', () {
    test('processes Unicode math to engine syntax', () {
      expect(postProcessOcrText('x² + 2x + 1'), 'x^2 + 2x + 1');
    });

    test('converts operators', () {
      expect(postProcessOcrText('5 × 3 ÷ 2'), '5 * 3 / 2');
    });
  });

  group('latexToEngineSyntax integration', () {
    test('converts frac to division', () {
      expect(latexToEngineSyntax(r'\frac{1}{2}'), '(1)/(2)');
    });

    test('converts sqrt', () {
      expect(latexToEngineSyntax(r'\sqrt{x}'), 'sqrt(x)');
    });
  });
}
