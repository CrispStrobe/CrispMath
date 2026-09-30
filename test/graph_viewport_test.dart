import 'package:crisp_math/engine/graph_viewport.dart';
import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/linked_graph.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('bounds validate independent axes and extreme grids stay bounded', () {
    final b = GraphBounds(-2, 8, -100, 100);
    expect(b.unitX(1000), 100);
    expect(b.unitY(400), 2);
    expect(() => GraphBounds(2, 1, -1, 1), throwsArgumentError);
    expect(() => GraphBounds(double.nan, 1, -1, 1), throwsArgumentError);
    for (final unit in [1e-12, 1e-3, 25.0, 1e12]) {
      expect(graphGridStep(unit) * unit, inInclusiveRange(80, 800));
    }
  });
  test('fit rejects undefined values, pads constants and trims isolated poles',
      () {
    expect(
        () => fittedGraphBounds(-5, 5, [null, double.nan]), throwsStateError);
    final constant = fittedGraphBounds(-5, 5, [2, 2, 2]);
    expect(constant.yMin, lessThan(2));
    expect(constant.yMax, greaterThan(2));
    final pole =
        fittedGraphBounds(-5, 5, [...List.generate(100, (i) => i / 100), 1e10]);
    expect(pole.yMax, lessThan(2));
  });
  test('undo is bounded and restores deleted graph parameters and links',
      () async {
    final history = GraphUndoHistory<int>(capacity: 2);
    history.record(1);
    history.record(2);
    history.record(3);
    expect(history.undo(), 3);
    expect(history.undo(), 2);
    expect(history.undo(), isNull);
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.load(force: true);
    state.updateFunction(0, 'a*x');
    state.setParameter(0, 'a', 4);
    final before = state.captureGraphWorkspace();
    state.clearFunction(0);
    state.restoreGraphWorkspace(before);
    expect(state.graphFunctions[0], 'a*x');
    expect(state.getParameter(0, 'a'), 4);
    expect(state.graphLinks, isEmpty);
  });
}
