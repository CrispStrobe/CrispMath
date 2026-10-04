import 'dart:convert';
import 'dart:io';

import 'package:crisp_math/services/integral_arguments.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<Map<String, dynamic>> load() =>
      ((jsonDecode(File('test/fixtures/round7_algebra_tasks.json')
          .readAsStringSync()) as Map)['tasks'] as List)
          .map((task) => Map<String, dynamic>.from(task as Map)).toList();

  test('seventh independent references retain fifty distinct frozen questions', () {
    final algebra = load();
    final numeric = (jsonDecode(File('test/fixtures/round7_numeric_tasks.json')
        .readAsStringSync()) as Map)['tasks'] as List;
    expect(numeric, hasLength(25));
    expect([...algebra, ...numeric].map((task) => task['id']).toSet(),
        hasLength(50));
  });

  test('seventh algebra references retain twenty-five unique frozen questions', () {
    final tasks = load();
    expect(tasks, hasLength(25));
    expect(tasks.map((task) => task['id']).toSet(), hasLength(25));
    expect(tasks.where((task) => task['kind'] == 'engine'), hasLength(22));
    expect(tasks.where((task) => task['kind'] == 'module'), hasLength(2));
    expect(tasks.where((task) => task['kind'] == 'document'), hasLength(1));
    final errors = tasks.where((task) => task.containsKey('errorContains')).toList();
    expect(errors, hasLength(3));
    expect(errors.every((task) => task['errorContains'] != 'Error'), isTrue);
  });

  test('Taylor document reference uses actual shared explicit operation syntax', () {
    final task = load().singleWhere((task) => task['kind'] == 'document');
    expect(parseSeriesArguments((task['lines'] as List).last as String),
        ['abs(x^2-p)', 'x', '0', '5']);
    expect(task['edit'], {'index': 0, 'source': 'p=4'});
    expect(task['expected'], ['4', '9', '4-x^2']);
  });
}
