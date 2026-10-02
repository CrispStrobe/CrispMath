import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_math/diagnostics/workflow_tasks.dart';
import 'package:crisp_math/engine/calculator_engine.dart';

class FixtureEngine extends CalculatorEngine {
  @override
  String evaluate(String expression) => expression;
}

void main() {
  test('corpus has 50 unique tasks across engine, document, graph and export',
      () {
    final corpus =
        jsonDecode(File('test/fixtures/workflow_tasks.json').readAsStringSync())
            as Map;
    final tasks = corpus['tasks'] as List;
    expect(tasks.length, 50);
    expect(tasks.map((t) => t['id']).toSet().length, 50);
    expect(tasks.map((t) => t['kind']).toSet(),
        {'engine', 'document', 'graph', 'export'});
  });
  test(
      'independent comparison accepts notation but rejects wrong and complex answers',
      () async {
    final report = await WorkflowTasks(FixtureEngine()).run([
      for (final pair in [
        ['23.0 + 0.0*I', '23'],
        ['x**2 + 2*x + 1', '(x+1)^2'],
        ['9.0 - 2.20436423846524e-15*I', '9'],
        ['23.0 + 1.0*I', '23'],
        ['x^2+1', 'x^2+2'],
        ['4', '5'],
        ['x+C', 'x']
      ])
        {
          'id': '${pair[0]}:${pair[1]}',
          'kind': 'engine',
          'operation': 'evaluate',
          'args': [pair[0]],
          'expected': pair[1]
        }
    ]);
    expect((report['results'] as List).map((r) => r['status']),
        ['passed', 'passed', 'passed', 'failed', 'failed', 'failed', 'failed']);
  });
  test('duplicate IDs and unknown routes fail before execution', () async {
    final runner = WorkflowTasks(FixtureEngine());
    await expectLater(
        runner.run([
          {'id': 'a', 'kind': 'engine'},
          {'id': 'a', 'kind': 'engine'}
        ]),
        throwsFormatException);
    await expectLater(
        runner.run([
          {'id': 'a', 'kind': 'invented'}
        ]),
        throwsFormatException);
  });
  test('one malformed task is reported without losing subsequent results',
      () async {
    final report = await WorkflowTasks(FixtureEngine()).run([
      {
        'id': 'bad',
        'kind': 'engine',
        'operation': 'evaluate',
        'args': [],
        'expected': '1'
      },
      {
        'id': 'good',
        'kind': 'engine',
        'operation': 'evaluate',
        'args': ['2'],
        'expected': '2'
      }
    ]);
    expect(report['failed'], 1);
    expect(report['passed'], 1);
    expect((report['results'] as List).first['error'], isNotEmpty);
  });
  test('real graph sampler rejects domain holes and retains valid samples',
      () async {
    final corpus =
        jsonDecode(File('test/fixtures/workflow_tasks.json').readAsStringSync())
            as Map;
    final graphs =
        (corpus['tasks'] as List).where((t) => t['kind'] == 'graph').toList();
    final report = await WorkflowTasks(FixtureEngine()).run(graphs);
    expect(report['passed'], 5);
    expect(report['failed'], 0);
  });
  test('inline document functions pass through the actual app engine',
      () async {
    final corpus =
        jsonDecode(File('test/fixtures/workflow_tasks.json').readAsStringSync())
            as Map;
    final task =
        (corpus['tasks'] as List).singleWhere((t) => t['id'] == 'task-39');
    final report = await WorkflowTasks(CalculatorEngine()).run([task]);
    expect(report['failed'], 0);
    expect(report['passed'], 1);
    expect((report['results'] as List).single['actual'], ['x^2+1', '10']);
  });
  test(
      'equivalent but unchanged expressions fail requested transformation checks',
      () async {
    final report = await WorkflowTasks(FixtureEngine()).run([
      {
        'id': 'factor-shape',
        'kind': 'engine',
        'operation': 'evaluate',
        'args': ['x^2-9'],
        'expected': '(x-3)*(x+3)',
        'resultPattern': r'\([^)]*\)\s*\*?\s*\('
      },
      {
        'id': 'cancel-shape',
        'kind': 'engine',
        'operation': 'evaluate',
        'args': ['(x^2-1)/(x-1)'],
        'expected': 'x+1',
        'resultPattern': r'^x\s*\+\s*1$'
      }
    ]);
    expect(report['failed'], 2);
    expect(report['passed'], 0);
  });
  test('export rejects wrong source results before claiming a PDF pass',
      () async {
    final report = await WorkflowTasks(FixtureEngine()).run([
      {
        'id': 'wrong-export',
        'kind': 'export',
        'format': 'pdf',
        'lines': ['3'],
        'expectedResults': ['4']
      }
    ]);
    expect(report['failed'], 1);
    expect((report['results'] as List).single['error'],
        contains('source calculations'));
  });
}
