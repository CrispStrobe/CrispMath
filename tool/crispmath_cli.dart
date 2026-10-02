import 'dart:convert';
import 'dart:io';
import 'package:crisp_math/diagnostics/workflow_tasks.dart';
import 'package:crisp_math/diagnostics/taylor_compatibility.dart';
import 'package:crisp_math/engine/calculator_engine.dart';

Future<void> main(List<String> args) async {
  try {
    String? option(String name) {
      final index = args.indexOf(name);
      if (index < 0) return null;
      if (index + 1 >= args.length || args[index + 1].startsWith('--')) {
        throw FormatException('Missing value for $name');
      }
      return args[index + 1];
    }

    for (var i = 0; i < args.length; i++) {
      if (['--tasks', '--report', '--task'].contains(args[i])) {
        option(args[i]);
        i++;
      } else if (![
        '--list',
        '--require-native',
        '--help',
        '--check-series-compatibility'
      ].contains(args[i])) {
        throw FormatException('Unknown option: ${args[i]}');
      }
    }
    if (args.contains('--help')) {
      stdout.writeln(
          'dart run tool/crispmath_cli.dart [--tasks FILE] [--task ID] [--list] [--report FILE] [--require-native] [--check-series-compatibility]');
      return;
    }
    if (args.contains('--check-series-compatibility')) {
      final report = checkTaylorCompatibility(CalculatorEngine());
      stdout.writeln(const JsonEncoder.withIndent('  ').convert(report));
      exitCode = report['passed'] == true ? 0 : 1;
      return;
    }
    final input = jsonDecode(
        await File(option('--tasks') ?? 'test/fixtures/workflow_tasks.json')
            .readAsString()) as Map;
    var tasks = input['tasks'] as List;
    final selected = option('--task');
    if (selected != null) {
      tasks = tasks.where((t) => t['id'] == selected).toList();
    }
    if (tasks.isEmpty) throw const FormatException('No matching tasks');
    if (args.contains('--list')) {
      for (final task in tasks) {
        stdout.writeln('${task['id']}\t${task['kind']}\t${task['title']}');
      }
      return;
    }
    final runner = WorkflowTasks(CalculatorEngine());
    final report = await runner.run(tasks);
    final output = const JsonEncoder.withIndent('  ').convert(report);
    final reportPath = option('--report');
    if (reportPath != null) {
      final file = File(reportPath);
      await file.parent.create(recursive: true);
      await file.writeAsString('$output\n');
    }
    stdout.writeln(output);
    if (report['failed'] != 0 ||
        report['unsupported'] != 0 ||
        (args.contains('--require-native') && report['nativeBridge'] != true)) {
      exitCode = 1;
    }
  } catch (e) {
    stderr.writeln('CrispMath batch: $e');
    exitCode = 2;
  }
}
