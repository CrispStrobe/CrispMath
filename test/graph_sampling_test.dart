import 'package:crisp_math/engine/graph_sampling.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> request(List<String> functions) => {
      'functions': functions,
      'mode': 'cartesian',
      'width': 800.0,
      'scale': 1.0,
      'xMin': -4.0,
      'xMax': 4.0,
      'yMin': -4.0,
      'yMax': 4.0,
      'coarse': false,
      'annotations': true,
    };

void main() {
  test(
      'compiled expressions bind fresh values without replacing function names',
      () {
    final expression = NumericFallbackEvaluator.compile('exp(x) + 2x');
    expect(expression!.evaluate({'x': 0}), 1);
    expect(expression.evaluate({'x': 1}), closeTo(4.718281828, 1e-8));
    expect(expression.evaluate(), isNull);
    expect(
        identical(expression, NumericFallbackEvaluator.compile('exp(x) + 2x')),
        isTrue);
    expect(NumericFallbackEvaluator.compile('-2^2')!.evaluate(), -4);
    expect(NumericFallbackEvaluator.compile('2^-3')!.evaluate(), 0.125);
  });

  test('sampling finds roots and extrema without marking poles as roots', () {
    final samples = sampleGraph(request(['x^2 - 1', '1/x']));
    final roots = samples.markers.first.where((m) => m.kind == 'root').toList();
    expect(roots.length, 2);
    expect(roots.first.x, closeTo(-1, 1e-6));
    expect(roots.last.x, closeTo(1, 1e-6));
    expect(
        samples.markers.first.any((m) => m.kind == 'min' && m.x.abs() < 0.02),
        isTrue);
    expect(samples.markers.last.where((m) => m.kind == 'root'), isEmpty);
  });

  test('coarse gestures use fewer samples and omit annotations', () {
    final full = sampleGraph(request(['sin(x)']));
    final coarse = sampleGraph({
      ...request(['sin(x)']),
      'coarse': true
    });
    expect(coarse.curves.first.length, lessThan(full.curves.first.length));
    expect(coarse.markers.first, isEmpty);
  });

  test('surface sampling and worker transport retain gaps and coordinates', () {
    final surface =
        sampleSurface({'expression': 'x^2 + y', 'range': 2.0, 'grid': 4});
    expect(surface[0][0], 2);
    expect(surface[2][2], 0);
    final original = sampleGraph(request(['sqrt(x)']));
    final restored = GraphSamples.fromJson(original.toJson());
    expect(restored.curves, original.curves);
    expect(restored.curves.first.first.ok, isFalse);
  });
}
