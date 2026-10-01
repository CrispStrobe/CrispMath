// Isolate dependency-evaluator cost from UI, browser and worker round trips.
// This is a Dart JIT measurement with a numeric dispatcher, not app latency.
import 'dart:convert';
import 'dart:io';

import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';

Future<void> main(List<String> arguments) async {
  final sizes =
      arguments.isEmpty ? [100, 500, 2000] : arguments.map(int.parse).toList();
  if (sizes.any((size) => size < 1)) {
    throw ArgumentError('Document sizes must be positive.');
  }
  final measurements = <Map<String, Object?>>[];
  for (final size in sizes) {
    final document = NotepadDocument.fresh(name: 'Dependency benchmark');
    document.lines
      ..clear()
      ..addAll(List.generate(
          size,
          (index) => NotepadLine.fresh(
              source: index == 0 ? 'v0 = 1' : 'v$index = v${index - 1} + 1')));
    final evaluator = NotepadEvaluator(dispatcher: (expression) async {
      final value = NumericFallbackEvaluator.evalNumeric(expression, {});
      if (value == null || !value.isFinite) {
        throw StateError('Invalid numeric expression: $expression');
      }
      return value.toInt().toString();
    });
    final watch = Stopwatch()..start();
    await evaluator.evaluateAll(document);
    final initialMs = watch.elapsedMicroseconds / 1000;
    if (document.lines.last.cachedResult != '$size') {
      throw StateError(
          'Initial dependency evaluation produced a wrong result.');
    }
    document.lines.first.source = 'v0 = 2';
    watch.reset();
    await evaluator.evaluateFrom(document, 0);
    final editMs = watch.elapsedMicroseconds / 1000;
    if (document.lines.last.cachedResult != '${size + 1}') {
      throw StateError('Dependent edit produced a wrong result.');
    }
    measurements.add({
      'rows': size,
      'evaluate_all_ms': initialMs,
      'dependent_edit_ms': editMs,
      'last_result': document.lines.last.cachedResult,
    });
  }
  stdout.writeln(jsonEncode({
    'measurement': 'Dart JIT dependency evaluator with numeric dispatcher',
    'includes_ui_or_worker_latency': false,
    'documents': measurements,
  }));
}
