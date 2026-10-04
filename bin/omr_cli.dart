import 'dart:io';
import 'package:args/args.dart';
import 'package:crispembed/crispembed.dart';
import 'package:image/image.dart' as img;

// Hook into actual app path
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/utils/latex_conversion_utils.dart';
// Just in case it's needed for evaluate output?

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption('model', abbr: 'm', help: 'Path to GGUF model')
    ..addOption('image', abbr: 'i', help: 'Path to image file');

  ArgResults results;
  try {
    results = parser.parse(args);
  } catch (e) {
    stdout.writeln(e);
    exit(1);
  }

  if (results['model'] == null || results['image'] == null) {
    stdout
        .writeln('Usage: dart bin/omr_cli.dart -m <model.gguf> -i <image.png>');
    exit(1);
  }

  final ocr = CrispEmbedOcr(results['model']);
  final imageBytes = File(results['image']).readAsBytesSync();
  final image = img.decodeImage(imageBytes)!;
  final rgbaBytes = image.getBytes(order: img.ChannelOrder.rgba);

  stdout.writeln('1. Running OCR...');
  final latex = ocr.recognizeRaw(rgbaBytes, image.width, image.height, 4);
  ocr.dispose();

  if (latex == null) {
    stdout.writeln('OCR failed to return a string.');
    exit(1);
  }

  stdout.writeln('-> Raw OCR LaTeX: $latex');

  stdout.writeln('2. Converting LaTeX to SymEngine math string (App Path)...');
  final mathExpr = LatexConversionUtils.fromLatex(latex);
  stdout.writeln('-> App Math String: $mathExpr');

  stdout.writeln('3. Evaluating via CalculatorEngine (App Path)...');
  final engine = CalculatorEngine();
  final result = engine.evaluate(mathExpr);
  stdout.writeln('-> App Evaluation Result: $result');
}
