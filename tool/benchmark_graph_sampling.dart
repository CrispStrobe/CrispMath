// Run with dart run tool/benchmark_graph_sampling.dart. This CPU microbenchmark
// complements profile-mode frame traces; it does not measure presentation FPS.
import '../lib/engine/graph_sampling.dart';
import '../lib/engine/numeric_fallback.dart';

void main() {
  const expression = 'sin(x)*cos(x)+exp(-x^2/10)';
  final compiled = NumericFallbackEvaluator.compile(expression)!;
  for (var i = 0; i < 10000; i++) {
    compiled.evaluate({'x': i / 1000});
  }
  for (final mode in ['cartesian', 'implicit', 'vectorField']) {
    final request = <String, dynamic>{
      'mode': mode,
      'functions': mode == 'cartesian' ? [expression] : <String>[],
      'width': 1000.0,
      'scale': 1.0,
      'xMin': -10.0,
      'xMax': 10.0,
      'yMin': -10.0,
      'yMax': 10.0,
      'coarse': false,
      'annotations': true,
      'implicitF': 'x^2+y^2-25',
      'vfU': '-y',
      'vfV': 'x',
    };
    for (var i = 0; i < 10; i++) {
      sampleGraph(request);
    }
    final times = <int>[];
    for (var i = 0; i < 30; i++) {
      final timer = Stopwatch()..start();
      sampleGraph(request);
      timer.stop();
      times.add(timer.elapsedMicroseconds);
    }
    times.sort();
    print(
        '$mode sampling: median ${(times[15] / 1000).toStringAsFixed(2)}ms, p95 ${(times[28] / 1000).toStringAsFixed(2)}ms');
  }
}
