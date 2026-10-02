import 'dart:convert';
import 'dart:io';

import 'package:crisp_math/diagnostics/workflow_tasks.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final corpus = jsonDecode(
      File('test/fixtures/round2_numeric_tasks.json').readAsStringSync()) as Map;
  final tasks = (corpus['tasks'] as List)
      .map((task) => Map<String, dynamic>.from(task as Map))
      .toList();

  test('second fresh numeric draft contains 40 unique challenges', () {
    expect(tasks, hasLength(40));
    expect(tasks.map((task) => task['id']).toSet(), hasLength(40));
  });

  // Independent mathematical references are fixed in the fixture. Boundary
  // cases remain failing findings if the real app returns a different value;
  // there is no expected-answer adaptation or skip based on app behavior.
  for (final task in tasks.where((task) => task['kind'] == 'module')) {
    test('${task['id']}: ${task['title']}', () async {
      final report = await WorkflowTasks(CalculatorEngine()).run([task]);
      final evidence = jsonEncode((report['results'] as List).single);
      expect(report['unsupported'], 0, reason: evidence);
      expect(report['failed'], 0, reason: evidence);
      expect(report['passed'], 1, reason: evidence);
    });
  }
}
