// Native (dart:io) implementation of the headless diagnostic self-test.
//
// Invoked with CRISPMATH_DIAGNOSTIC=matrix|steps|workflows on a desktop binary: it
// runs the matrix / step battery against the native bridge, prints
// PASS/FAIL lines, and exits with a non-zero code on any failure (so CI
// can assert on it). Selected by the conditional import in main.dart on
// platforms that have dart:io; the web build gets the no-op stub.

import 'dart:convert';
import 'dart:io';

import 'diagnostics/workflow_tasks.dart';

import 'engine/calculator_engine.dart';
import 'engine/matrix_diagnostics.dart';
import 'engine/step_diagnostics.dart';

/// Runs the diagnostic battery if CRISPMATH_DIAGNOSTIC is set on a
/// desktop platform, then exits the process. Returns normally (a no-op)
/// otherwise. Never returns on web — the stub variant handles that.
Future<void> runDiagnosticsIfRequested() async {
  final diag = Platform.environment['CRISPMATH_DIAGNOSTIC'];
  if (!(Platform.isMacOS || Platform.isLinux || Platform.isWindows) ||
      diag == null) {
    return;
  }
  if (diag == 'workflows') {
    try {
      final inputPath = Platform.environment['CRISPMATH_TASKS_FILE'] ??
          'test/fixtures/workflow_tasks.json';
      final inputText = inputPath == '-'
          ? await stdin.transform(utf8.decoder).join()
          : await File(inputPath).readAsString();
      final input = jsonDecode(inputText) as Map;
      final report =
          await WorkflowTasks(CalculatorEngine()).run(input['tasks'] as List);
      final path = Platform.environment['CRISPMATH_TASK_REPORT'];
      final json = const JsonEncoder.withIndent('  ').convert(report);
      if (path == '-') {
        stdout.writeln('CRISPMATH_WORKFLOW_REPORT_BEGIN');
        stdout.writeln(json);
        stdout.writeln('CRISPMATH_WORKFLOW_REPORT_END');
      } else if (path != null) {
        final file = File(path);
        await file.parent.create(recursive: true);
        await file.writeAsString('$json\n');
      }
      stdout.writeln(
          '${report['passed']} of ${report['total']} workflow tasks passed; '
          '${report['failed']} failed; ${report['unsupported']} unsupported; '
          'native bridge: ${report['nativeBridge']}');
      for (final result in report['results'] as List) {
        if (result['status'] != 'passed') {
          stdout.writeln(
              '${result['id']}: ${result['status']} ${result['error'] ?? result['actual']}');
        }
      }
      exit(report['failed'] == 0 &&
              report['unsupported'] == 0 &&
              report['nativeBridge'] == true
          ? 0
          : 1);
    } catch (error) {
      stderr.writeln('CrispMath workflow audit: $error');
      exit(2);
    }
  }
  if (diag == 'matrix') {
    final results = MatrixDiagnostics.run(CalculatorEngine());
    var anyFailed = false;
    for (final r in results) {
      stdout.writeln('${r.passed ? "PASS" : "FAIL"}  ${r.name}');
      stdout.writeln('  expr:     ${r.expression}');
      stdout.writeln('  expected: ${r.expected}');
      stdout.writeln('  actual:   ${r.actual}');
      if (!r.passed) anyFailed = true;
    }
    final passed = results.where((r) => r.passed).length;
    stdout.writeln('---');
    stdout.writeln('$passed of ${results.length} checks passed');
    exit(anyFailed ? 1 : 0);
  }
  if (diag == 'steps') {
    final results = StepDiagnostics.run(CalculatorEngine());
    var anyFailed = false;
    for (final r in results) {
      stdout.writeln(
          '${r.passed ? "PASS" : "FAIL"}  [${r.operation}]  ${r.name}');
      stdout.writeln('  expr:     ${r.expression}');
      stdout.writeln('  expected: ${r.expected}');
      stdout.writeln('  actual:   ${r.actual}');
      if (!r.passed) anyFailed = true;
    }
    final passed = results.where((r) => r.passed).length;
    stdout.writeln('---');
    stdout.writeln('$passed of ${results.length} checks passed');
    exit(anyFailed ? 1 : 0);
  }
}
