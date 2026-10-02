import 'dart:convert';
import 'dart:io';

import 'package:crisp_math/diagnostics/workflow_tasks.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final corpus = jsonDecode(
      File('test/fixtures/round2_workflow_tasks.json').readAsStringSync()) as Map;
  for (final raw in (corpus['tasks'] as List)) {
    final task = Map<String, dynamic>.from(raw as Map);
    if (task['kind'] != 'graph') continue;
    test('${task['id']}: ${task['title']}', () async {
      final report = await WorkflowTasks(CalculatorEngine()).run([task]);
      expect(report['failed'], 0, reason: jsonEncode(report));
      expect(report['passed'], 1, reason: jsonEncode(report));
    });
  }
}
