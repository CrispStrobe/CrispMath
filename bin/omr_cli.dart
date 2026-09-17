import 'dart:io';
import 'package:args/args.dart';
import 'package:crispembed/crispembed.dart';
import 'package:image/image.dart' as img;

// Hook into actual app path
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/utils/latex_conversion_utils.dart';
import 'package:crisp_math/engine/symbolic_expr.dart'; // Just in case it's needed for evaluate output? 

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption('model', abbr: 'm', help: 'Path to GGUF model')
    ..addOption('image', abbr: 'i', help: 'Path to image file');

  var results;
  try {
    results = parser.parse(args);
  } catch (e) {
    print(e);
    exit(1);
  }

  if (results['model'] == null || results['image'] == null) {
    print('Usage: dart bin/omr_cli.dart -m <model.gguf> -i <image.png>');
    exit(1);
  }

  final ocr = CrispEmbedOcr(results['model']);
  final imageBytes = File(results['image']).readAsBytesSync();
  final image = img.decodeImage(imageBytes)!;
  final rgbaBytes = image.getBytes(order: img.ChannelOrder.rgba);

  print('1. Running OCR...');
  final latex = ocr.recognizeRaw(rgbaBytes, image.width, image.height, 4);
  ocr.dispose();
  
  if (latex == null) {
    print('OCR failed to return a string.');
    exit(1);
  }
  
  print('-> Raw OCR LaTeX: $latex');

  print('2. Converting LaTeX to SymEngine math string (App Path)...');
  final mathExpr = LatexConversionUtils.fromLatex(latex);
  print('-> App Math String: $mathExpr');

  print('3. Evaluating via CalculatorEngine (App Path)...');
  final engine = CalculatorEngine();
  final result = engine.evaluate(mathExpr);
  print('-> App Evaluation Result: $result');
}
