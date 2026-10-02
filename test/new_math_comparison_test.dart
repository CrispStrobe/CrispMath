import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_math/diagnostics/workflow_tasks.dart';
import 'package:crisp_math/engine/calculator_engine.dart';

/// Provides the alleged answer verbatim, forcing the audit comparator to
/// independently reject it rather than relying on the engine's calculation.
class ComparisonEchoEngine extends CalculatorEngine {
  @override
  bool get isNativeAvailable => false;

  @override
  String evaluate(String expression) => expression;
}

Future<List<String>> comparePairs(
    CalculatorEngine engine, List<List<String>> pairs) async {
  final report = await WorkflowTasks(engine).run([
    for (var i = 0; i < pairs.length; i++)
      {
        'id': 'comparison-$i',
        'kind': 'engine',
        'operation': 'evaluate',
        'args': [pairs[i][0]],
        'expected': pairs[i][1]
      }
  ]);
  return (report['results'] as List).map((r) => r['status'] as String).toList();
}

void main() {
  test('unordered roots match by value while preserving multiplicity',
      () async {
    expect(
        await comparePairs(ComparisonEchoEngine(), [
          ['{2.0,1.0}', '{1,2}'],
          ['{1,1}', '{1,2}'],
          ['{I,-I}', '{-I,I}'],
          ['{I,I}', '{-I,I}'],
        ]),
        ['passed', 'failed', 'passed', 'failed']);
  });
  test('independent coordinates compare arbitrary symbols and integration C',
      () async {
    expect(
        await comparePairs(ComparisonEchoEngine(), [
          ['(u+v)^2', 'u^2+2*u*v+v^2'],
          ['u+v', 'u+u'],
          ['u-v', '0'],
          ['u^2+C', 'u^2'],
          ['ln(u)', 'log(u)'],
          ['sqrt(u^2)', 'u'],
          ['1/3x^3+C', 'x^3/3+C'],
          ['1/3x^3+C', 'x^3/4+C'],
          ['i+u', 'u+i'],
          ['i', 'I'],
          ['1/2e-3', '500'],
        ]),
        [
          'passed',
          'failed',
          'failed',
          'failed',
          'passed',
          'failed',
          'passed',
          'failed',
          'passed',
          'failed',
          'passed'
        ]);
  });

  test('errors and undefined answers cannot pass even identical comparisons',
      () async {
    expect(
        await comparePairs(ComparisonEchoEngine(), [
          ['Error: x = 3', 'x = 3'],
          ['Error: x = 3', 'Error: x = 3'],
          ['NaN', 'NaN'],
          ['zoo', 'zoo'],
          ['undefined', 'undefined'],
          ['0/0', '0/0'],
          ['1/0', '1/0'],
        ]),
        everyElement('failed'));
  });

  test('rational comparison retains excluded inputs and real domain holes',
      () async {
    expect(
        await comparePairs(ComparisonEchoEngine(), [
          ['u/u', '1'],
          ['(u^2-1)/(u-1)', 'u+1'],
          ['1/(u-1)', '-1/(1-u)'],
          ['sqrt(u)', 'sqrt(-u)'],
        ]),
        ['failed', 'failed', 'passed', 'failed']);
  });

  test('complex components cannot be dropped without a symbolic proof',
      () async {
    expect(
        await comparePairs(ComparisonEchoEngine(), [
          ['23.0 + 0.0*I', '23'],
          ['9.0 - 2.2e-15*I', '9'],
          ['23+I', '23'],
          ['3+4*I', '3-4*I'],
          ['3+4*I', '3+5*I'],
          ['I', '1'],
          ['I^2', '-1'],
          ['I^2', 'I*I'],
        ]),
        [
          'passed',
          'passed',
          'failed',
          'failed',
          'failed',
          'failed',
          'failed',
          'failed'
        ]);
  });

  final nativeEngine = CalculatorEngine();
  test('actual native CAS compares full complex values and rejects wrong parts',
      () async {
    expect(
        await comparePairs(nativeEngine, [
          ['(3+4*I)/(3-4*I)', '-7/25+24*I/25'],
          ['sqrt(-16)', '4*I'],
          ['ln(-1)', 'pi*I'],
          // Expected expression is deliberately unreduced, so the comparator
          // must prove a complex identity rather than match canonical strings.
          ['-7/25+24*I/25', '(3+4*I)/(3-4*I)'],
          ['-1', 'I^2'],
          ['(3+4*I)/(3-4*I)', '-7/25-24*I/25'],
          ['sqrt(-16)', '5*I'],
          ['ln(-1)', '-pi*I'],
          ['3.14159265358979*I', 'pi*I'],
          ['3.15159265358979*I', 'pi*I'],
          ['-3.14159265358979*I', 'pi*I'],
          ['3.14159265358979*I', 'pi*I+C'],
          ['u+3.14159265358979*I', 'u+pi*I'],
          ['eigenvalues(Matrix([[0,-1],[1,0]]))', '{-I,I}'],
          ['I', '0 + 1i'],
          ['-I', '0 - 1i'],
          ['I', '0 - 1i'],
          ['eigenvalues(Matrix([[0,-1],[1,0]]))', '{0 + 1i, 0 - 1i}'],
        ]),
        [
          'passed',
          'passed',
          'passed',
          'passed',
          'passed',
          'failed',
          'failed',
          'failed',
          'passed',
          'failed',
          'failed',
          'failed',
          'failed',
          'passed',
          'passed',
          'passed',
          'failed',
          'passed'
        ]);
  }, skip: !nativeEngine.isNativeAvailable);
}
