import 'graph_sampling.dart';
import 'numeric_fallback.dart';
import 'plot_types.dart';

/// A bounded, inclusive interval. Avoids cumulative floating-point drift.
List<double> graphTableCoordinates(double from, double to, double step) {
  if (!from.isFinite ||
      !to.isFinite ||
      !step.isFinite ||
      step <= 0 ||
      to < from) {
    throw ArgumentError('Use finite bounds, From ≤ To and Step > 0.');
  }
  final intervals = (to - from) / step;
  if (!intervals.isFinite ||
      intervals > 500 ||
      (from != to && from + step == from)) {
    throw ArgumentError('Choose a larger step: tables support up to 501 rows.');
  }
  final count = (intervals + 1e-10).floor() + 1;
  return List.generate(count, (i) => from + i * step);
}

List<List<double?>> sampleGraphValues(Map<String, dynamic> request,
    {GraphFallback? fallback}) {
  final expression = request['expression'] as String;
  final xs = (request['xs'] as List).cast<num>();
  if (xs.length > 501) throw ArgumentError('Too many table rows');
  final compiled = NumericFallbackEvaluator.compile(expression);
  return xs.map((x) {
    final vars = {'x': x.toDouble()};
    final y = compiled != null
        ? compiled.evaluate(vars)
        : fallback?.call(expression, vars);
    return [x.toDouble(), y != null && y.isFinite ? y : null];
  }).toList();
}

/// Snap to a sampled point. An invalid point stays invalid at discontinuities.
int? traceSampleIndex(List<PlotPt> points, double x) {
  if (points.isEmpty || !x.isFinite || x < points.first.x || x > points.last.x)
    return null;
  var lo = 0, hi = points.length - 1;
  while (lo < hi) {
    final mid = (lo + hi) ~/ 2;
    if (points[mid].x < x) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }
  if (lo > 0 && (points[lo - 1].x - x).abs() < (points[lo].x - x).abs()) lo--;
  return lo;
}

String graphValuesText(List<List<double?>> rows, {String separator = ','}) =>
    'x${separator}y\n${rows.map((r) => '${r[0]}$separator${r[1] ?? 'undefined'}').join('\n')}\n';
