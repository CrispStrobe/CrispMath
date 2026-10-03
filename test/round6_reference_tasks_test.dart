import 'dart:convert';
import 'dart:io';

import 'package:crisp_math/diagnostics/workflow_tasks.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<dynamic> load(String area) =>
      (jsonDecode(File('test/fixtures/round6_${area}_tasks.json')
          .readAsStringSync()) as Map)['tasks'] as List;

  test('sixth independent references retain fifty distinct task IDs', () {
    final algebra = load('algebra');
    final numeric = load('numeric');
    expect(algebra, hasLength(25));
    expect(numeric, hasLength(25));
    expect([...algebra, ...numeric].map((t) => t['id']).toSet(), hasLength(50));
  });

  test('sixth numeric references exercise the actual pure Dart modules', () async {
    final tasks = load('numeric').where((t) => t['kind'] == 'module').toList();
    expect(tasks, isNotEmpty);
    final report = await WorkflowTasks(CalculatorEngine()).run(tasks);
    expect(report['failed'], 0, reason: jsonEncode(report['results']));
    expect(report['passed'], tasks.length);
    expect(report['unsupported'], 0);
  });
}
