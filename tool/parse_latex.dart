// tool/parse_latex.dart — CLI wrapper for latexToEngineSyntax.
// Usage: dart run tool/parse_latex.dart '\frac{x}{2}'
// Reads from argv or stdin (one per line), prints engine syntax.

import 'dart:io';
import 'package:crisp_calc/engine/ocr_provider.dart';

void main(List<String> args) {
  if (args.isNotEmpty) {
    for (final arg in args) {
      stdout.writeln(latexToEngineSyntax(arg));
    }
  } else {
    // Read from stdin, one LaTeX per line
    String? line;
    while ((line = stdin.readLineSync()) != null) {
      stdout.writeln(latexToEngineSyntax(line!));
    }
  }
}
