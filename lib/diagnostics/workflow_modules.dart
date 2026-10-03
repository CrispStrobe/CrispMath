import '../engine/calculator_engine.dart';
import '../engine/rational_domain.dart';
import '../engine/csp_solver.dart';
import '../engine/date_time_evaluator.dart';
import '../engine/distributions.dart';
import '../engine/graph_inspection.dart';
import '../engine/hypothesis_tests.dart';
import '../engine/statistics.dart';
import '../engine/unit_expression.dart';
import '../services/engine_dispatch.dart';
import '../services/engine_op.dart';

/// CLI adapters to the same modules used by the application screens.
Future<dynamic> runWorkflowModule(
    CalculatorEngine engine, Map<String, dynamic> task) async {
  List<double> numbers(String key) =>
      (task[key] as List).map((n) => (n as num).toDouble()).toList();
  switch (task['operation']) {
    case 'differentiateAt':
      final variable = task['variable'] as String? ?? 'x';
      return engine.differentiateAt(
          task['expression'], variable, task['point']);
    case 'normalCdf':
      return Normal(
              mean: (task['mean'] as num).toDouble(),
              stddev: (task['stddev'] as num).toDouble())
          .cdf((task['x'] as num).toDouble());
    case 'tInterval':
      final distribution = TDistribution(df: (task['df'] as num).toInt());
      return distribution.intervalProbability(
          (task['lower'] as num).toDouble(), (task['upper'] as num).toDouble());
    case 'rationalDomain':
      final domain = RationalDomain.inspect(task['expression'],
          variable: task['variable']);
      return {
        'value': runEngineOpDetailed(
                engine, EngineOp('simplify', task['expression']))
            .value,
        'excluded': domain == null ? null : (domain.excluded.toList()..sort())
      };
    case 'calculator':
      return engine.tryEvaluatePrecisionCall(task['expression']) ??
          engine.evaluate(task['expression']);
    case 'date':
      return DateTimeEvaluator.tryEvaluate(task['expression']);
    case 'unit':
      return UnitExpressionEvaluator.tryEvaluate(task['expression']);
    case 'table':
      return sampleGraphValues(
          {'expression': task['expression'], 'xs': task['xs']});
    case 'describe':
      final result = Statistics.describe(numbers('data'));
      return {
        'mean': result.mean,
        'median': result.median,
        // JSON cannot encode NaN; null preserves the undefined sample value.
        'sampleStddev': result.sampleStddev.isNaN ? null : result.sampleStddev
      };
    case 'regression':
      final result = Statistics.linearFit(numbers('xs'), numbers('ys'));
      return {
        'slope': result.slope.isFinite ? result.slope : null,
        'intercept': result.intercept.isFinite ? result.intercept : null,
        'rSquared': result.rSquared.isFinite ? result.rSquared : null
      };
    case 'oneSampleT':
    case 'pairedT':
      final result = task['operation'] == 'pairedT'
          ? HypothesisTests.pairedT(
              before: numbers('before'), after: numbers('after'))
          : HypothesisTests.oneSampleT(
              data: numbers('data'),
              hypothesizedMean: (task['mean'] as num).toDouble());
      return {
        'statistic': result.statistic,
        'df': result.df,
        'pValue': result.pValueTwoSided
      };
    case 'chiSquare':
      final result = HypothesisTests.chiSquareGof(
          observed: numbers('observed'), expected: numbers('counts'));
      return {
        'statistic': result.statistic,
        'df': result.df,
        'pValue': result.pValue
      };
    case 'binomial':
      return Binomial(n: task['n'], p: (task['p'] as num).toDouble())
          .pmf(task['k']);
    case 'constraintObjective':
      final result = await CspSolver.solveDsl(task['program']);
      if (!result.ok) {
        throw StateError(result.error ?? 'Constraint optimization failed');
      }
      if (result.objective == null || result.solutions.isEmpty) {
        throw StateError('Constraint optimization produced no proven optimum');
      }
      return result.objective;
    case 'constraint':
      final result =
          await CspSolver.solveDsl(task['program'], maxSolutions: 100);
      if (!result.ok || result.truncated) {
        throw StateError(result.error ?? 'Solution enumeration was truncated');
      }
      return result.solutions;
    case 'chain':
      var previous = '';
      final results = <String>[];
      for (final raw in task['steps'] as List) {
        final args = (raw['args'] as List)
            .cast<String>()
            .map((s) => s.replaceAll('@previous', previous))
            .toList();
        previous = runEngineOp(
            engine,
            EngineOp(
                raw['operation'],
                args[0],
                args.length > 1 ? args[1] : null,
                args.length > 2 ? args[2] : null,
                args.length > 3 ? args[3] : null));
        results.add(previous);
      }
      return results;
    default:
      throw FormatException('Unknown module operation: ${task['operation']}');
  }
}
