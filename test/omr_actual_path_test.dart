import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:crispembed/crispembed.dart';
import 'package:image/image.dart' as img;

import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/utils/latex_conversion_utils.dart';

void main() {
  test('E2E OCR and Math Evaluation using exact app path', () {
    final modelPath = '/tmp/pix2tex.gguf';
    final imagePath = '/tmp/math2.png'; // Contains "5 + 7"

    // 1. OCR Step (matches what OcrProviders.active does)
    final ocr = CrispEmbedOcr(modelPath);
    final imageBytes = File(imagePath).readAsBytesSync();
    final image = img.decodeImage(imageBytes)!;
    final rgbaBytes = image.getBytes(order: img.ChannelOrder.rgba);
    
    print('1. Running OCR...');
    final latex = ocr.recognizeRaw(rgbaBytes, image.width, image.height, 4);
    ocr.dispose();
    
    expect(latex, isNotNull);
    print('-> Raw OCR LaTeX: $latex');

    // 2. Pre-processing Step (matches Handwriting Dialog to Notepad pipeline)
    print('2. Converting LaTeX to SymEngine math string (App Path)...');
    final mathExpr = LatexConversionUtils.fromLatex(latex!);
    print('-> App Math String: $mathExpr');

    // 3. Evaluation Step (matches CalculatorEngine execution)
    print('3. Evaluating via CalculatorEngine (App Path)...');
    final engine = CalculatorEngine();
    
    // In native test, bridge is synchronous.
    final result = engine.evaluate(mathExpr);
    print('-> App Evaluation Result: $result');
    
    // The image /tmp/math2.png has 5+7
    // So evaluating it should yield 12.
    expect(result, contains('12'));
  });
}
