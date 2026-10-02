import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:crisp_math/diagnostics/workflow_tasks.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/distributions.dart';
import 'package:crisp_math/engine/linear_system_solver.dart';
import 'package:crisp_math/engine/rational_domain.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:crisp_math/services/engine_dispatch.dart';
import 'package:crisp_math/services/engine_op.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tasks = (jsonDecode(
          File('test/fixtures/fresh_workflow_tasks.json').readAsStringSync())
      as Map)['tasks'] as List;
  test('fresh independently drafted corpus contains 50 distinct problems', () {
    expect(tasks, hasLength(50));
    expect(tasks.map((t) => t['id']).toSet(), hasLength(50));
  });
  test(
      'actual pure Dart statistics, dates, units, tables and CSP satisfy independent references',
      () async {
    final modules = tasks
        .where((t) =>
            t['kind'] == 'module' &&
            [
              'table',
              'describe',
              'regression',
              'oneSampleT',
              'pairedT',
              'chiSquare',
              'binomial',
              'unit',
              'date',
              'constraint'
            ].contains(t['operation']))
        .toList();
    final report = await WorkflowTasks(CalculatorEngine()).run(modules);
    expect(report['failed'], 0, reason: jsonEncode(report['results']));
    expect(report['passed'], modules.length);
  });
  test(
      'exact linear systems pivot, distinguish inconsistency and decline nonlinear syntax',
      () {
    expect(LinearSystemSolver.solve(['2*x+3*y=7', '4*x-y=5'], ['x', 'y']),
        'x = 11/7, y = 9/7');
    expect(LinearSystemSolver.solve(['y=2', 'x+y=3', '2*x+2*y=6'], ['x', 'y']),
        'x = 1, y = 2');
    expect(LinearSystemSolver.solve(['x+y=3', '2*x+2*y=7'], ['x', 'y']),
        contains('no solutions'));
    expect(LinearSystemSolver.solve(['x+y=3'], ['x', 'y']),
        contains('no unique solution'));
    expect(LinearSystemSolver.solve(['x*x=2'], ['x']), isNull);
    expect(LinearSystemSolver.solve(['x=2', '0=0'], ['x']), 'x = 2');
    expect(LinearSystemSolver.solve(['x=2', '0=1'], ['x']),
        contains('no solutions'));
    expect(LinearSystemSolver.solve(['x=2'], ['x', 'x']), startsWith('Error:'));
  });
  test('large integer powers retain every digit and exact evidence', () {
    final result = runEngineOpDetailed(
        CalculatorEngine(), const EngineOp('evaluate', '2^100'));
    expect(result.value, '1267650600228229401496703205376');
    expect(result.evidence?.accuracy, ResultAccuracy.exact);
    expect(CalculatorEngine().evaluate('(2^100+1)*3'),
        '3802951800684688204490109616131');
  });
  test('original denominator exclusions survive result persistence', () {
    final domain = RationalDomain.inspect('(x^2-9)/(x^2+x-6)');
    expect(domain?.excluded.toSet(), {'-3', '2'});
    expect(RationalDomain.inspect('sin(x)/cos(x)'), isNull);
    expect(RationalDomain.inspect('1/(x*y)'), isNull);
    final evidence = ResultEvidence(
        ResultAccuracy.symbolic, ComputationMethod.simplification,
        sourceDomain: domain!.description);
    expect(ResultEvidence.fromJson(evidence.toJson())?.sourceDomain,
        domain.description);
  });
  test(
      'Student t CDF retains the Cauchy tails outside the old integration interval',
      () {
    const distribution = TDistribution(df: 1);
    for (final x in [-1000.0, -50.0, -4.0, -.1, 0.0, .1, 4.0, 50.0, 1000.0]) {
      expect(distribution.cdf(x), closeTo(.5 + math.atan(x) / math.pi, 2e-13));
    }
    expect(distribution.quantile(.001),
        closeTo(math.tan(math.pi * (.001 - .5)), 1e-7));
  });
  test('paired t reference tail agrees to more than six digits', () {
    expect(const TDistribution(df: 4).cdf(-4.47213595499958) * 2,
        closeTo(.011056493393450067, 1e-12));
  });
}
