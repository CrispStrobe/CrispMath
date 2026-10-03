import 'dart:io';
import 'package:crisp_math/engine/worked_examples.dart';
import 'package:crisp_math/engine/calculator_engine.dart';

void main() {
  final engine = CalculatorEngine();
  int pass = 0, fail = 0;
  for (final e in WorkedExamples.all) {
    if (e.expression.startsWith('open:') || e.expression.startsWith('dsl:')) {
      continue;
    }
    try {
      final res = engine.evaluate(e.expression);
      if (res.contains('Error') ||
          res.contains('Exception') ||
          res.contains('Unknown')) {
        stdout.writeln('FAIL ${e.id}: ${e.expression} -> $res');
        fail++;
      } else {
        pass++;
      }
    } catch (err) {
      stdout.writeln('FAIL ${e.id}: ${e.expression} -> $err');
      fail++;
    }
  }
  stdout.writeln('Pass: $pass, Fail: $fail');
}
