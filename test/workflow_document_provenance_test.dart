import 'package:crisp_math/diagnostics/workflow_tasks.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:flutter_test/flutter_test.dart';

class UnclassifiedPiEngine extends CalculatorEngine {
  @override
  String evaluate(String expression) {
    if (expression.contains('pi')) return '3.14159265358979';
    return super.evaluate(expression);
  }
}

void main() {
  test('CLI documents clear previous exact evidence before an unclassified result',
      () async {
    final report = await WorkflowTasks(UnclassifiedPiEngine()).run([
      {
        'id': 'evidence-reset',
        'kind': 'document',
        'lines': ['a=3', 'p=pi', 'p*5'],
        'expected': ['3', 'pi', '5*pi'],
        'expectedAccuracy': ['exact', 'unknown', 'unknown'],
        'expectedResultPatterns': [null, null, r'^\d+\.\d+$'],
      }
    ]);
    expect(report['passed'], 1, reason: report.toString());
    expect(report['failed'], 0, reason: report.toString());
  });
}
