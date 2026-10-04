import 'package:crisp_math/engine/graph_inspection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('table intervals are inclusive, bounded and stable', () {
    expect(graphTableCoordinates(0, .3, .1), hasLength(4));
    expect(graphTableCoordinates(2, 2, 1), [2]);
    for (final step in [0.0, -1.0, double.nan, double.infinity]) {
      expect(() => graphTableCoordinates(0, 1, step), throwsArgumentError);
    }
    expect(() => graphTableCoordinates(0, 1, .0001), throwsArgumentError);
    expect(() => graphTableCoordinates(2, 1, 1), throwsArgumentError);
  });
  test('undefined values and native fallback are explicit', () {
    final rows = sampleGraphValues({
      'expression': '1/x',
      'xs': [-1, 0, 1]
    });
    expect(rows, [
      [-1.0, -1.0],
      [0.0, null],
      [1.0, 1.0]
    ]);
    expect(graphValuesText(rows), contains('0.0,undefined'));
    expect(
        sampleGraphValues({
          'expression': 'besselj(0,x)',
          'xs': [0]
        }, fallback: (_, __) => 1),
        [
          [0.0, 1.0]
        ]);
  });
  test('tracing preserves discontinuities and steps to nearest sample', () {
    const points = [
      (x: -1.0, y: -1.0, ok: true),
      (x: 0.0, y: 0.0, ok: false),
      (x: 1.0, y: 1.0, ok: true)
    ];
    expect(traceSampleIndex(points, .1), 1);
    expect(traceSampleIndex(points, .8), 2);
    expect(traceSampleIndex(points, 3), isNull);
  });
}
