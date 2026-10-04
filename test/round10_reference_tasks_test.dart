import 'dart:convert';
import 'dart:io';

import 'package:crisp_math/diagnostics/workflow_tasks.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<Map<String, dynamic>> load(String area) {
    final fixture = jsonDecode(
      File('test/fixtures/round10_${area}_tasks.json').readAsStringSync(),
    ) as Map;
    return (fixture['tasks'] as List)
        .map((task) => Map<String, dynamic>.from(task as Map))
        .toList();
  }

  test('tenth independent references retain fifty distinct question IDs', () {
    final algebra = load('algebra');
    final numeric = load('numeric');
    expect(algebra, hasLength(25));
    expect(numeric, hasLength(25));
    expect(
      [...algebra, ...numeric].map((task) => task['id']).toSet(),
      hasLength(50),
    );
  });

  test('tenth numeric references exercise actual pure Dart modules', () async {
    final tasks = load('numeric')
        .where((task) => task['kind'] == 'module')
        .toList();
    expect(tasks, isNotEmpty);
    final report = await WorkflowTasks(CalculatorEngine()).run(tasks);
    expect(report['failed'], 0, reason: jsonEncode(report['results']));
    expect(report['passed'], tasks.length);
    expect(report['unsupported'], 0);
  });
}
