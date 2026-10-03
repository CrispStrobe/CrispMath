import 'dart:convert';
import 'dart:io';

import 'package:crisp_math/diagnostics/workflow_tasks.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final corpus = jsonDecode(
          File('test/fixtures/new_math_numeric_tasks.json').readAsStringSync())
      as Map;
  final tasks = (corpus['tasks'] as List)
      .map((task) => Map<String, dynamic>.from(task as Map))
      .toList();

  test('fresh numeric corpus contains 40 independently drafted unique problems',
      () {
    expect(tasks, hasLength(40));
    expect(tasks.map((task) => task['id']).toSet(), hasLength(40));
  });

  // These adapters execute the actual app statistics, distributions, unit
  // conversion and constraint solver. Exact integer and matrix engine cases
  // are exercised in the remote native/web corpus, where a bridge is present.
  final modules = tasks.where((task) =>
      task['kind'] == 'module' &&
      {
        'describe',
        'binomial',
        'normalCdf',
        'tInterval',
        'unit',
        'constraint',
      }.contains(task['operation']));

  for (final task in modules) {
    test('${task['id']}: ${task['title']}', () async {
      final report = await WorkflowTasks(CalculatorEngine()).run([task]);
      final result = (report['results'] as List).single as Map;
      final evidence = jsonEncode(result);
      expect(report['total'], 1, reason: evidence);
      expect(report['unsupported'], 0, reason: evidence);
      expect(report['failed'], 0, reason: evidence);
      expect(report['passed'], 1, reason: evidence);
      expect(result['status'], 'passed', reason: evidence);
    });
  }
}
