// Run explicitly after provisioning the native library and model:
// CRISPMATH_OCR_MODEL=/path/model.gguf CRISPMATH_OCR_LIBRARY=/path/library \
//   flutter test native_test/ocr_native_test.dart
// Missing dependencies are failures, never silent skips.
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:crispembed/crispembed.dart';
import 'package:image/image.dart' as img;
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/ocr_providers_init.dart';
import 'package:crisp_math/utils/latex_conversion_utils.dart';

void main() {
  test('native printed math recognition and calculator handoff', () {
    final modelPath = Platform.environment['CRISPMATH_OCR_MODEL'];
    final libraryPath = Platform.environment['CRISPMATH_OCR_LIBRARY'];
    expect(modelPath, isNotNull,
        reason: 'Set CRISPMATH_OCR_MODEL to a pix2tex GGUF model.');
    expect(libraryPath, isNotNull,
        reason: 'Set CRISPMATH_OCR_LIBRARY to the native CrispEmbed library.');
    expect(File(modelPath!).existsSync(), isTrue);
    expect(File(libraryPath!).existsSync(), isTrue);
    final image = img.decodePng(
        File('test/fixtures/ocr/five_plus_seven.png').readAsBytesSync())!;
    final pixels = image.getBytes(order: img.ChannelOrder.rgba);
    final ocr = CrispEmbedOcr(modelPath, libPath: libraryPath, nThreads: 2);
    try {
      final latex = ocr.recognizeGray(
          toGrayscaleForIsolate(pixels, image.width, image.height),
          image.width,
          image.height);
      expect(latex, isNotNull);
      expect(latex!.trim(), isNotEmpty);
      final expression = LatexConversionUtils.fromLatex(latex);
      expect(CalculatorEngine().evaluate(expression), '12',
          reason: 'Fixture is 5 + 7; recognized LaTeX was $latex.');
    } finally {
      ocr.dispose();
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}
