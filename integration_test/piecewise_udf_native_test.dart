// Piecewise UDF end-to-end on real SymEngine (roadmap C5.4):
// f(x) = piecewise(x<0, -x, x) is inlined by the preprocessor and the
// condition folds through the engine to select the branch.
//   flutter test integration_test/piecewise_udf_native_test.dart -d macos

import 'package:crisp_calc/engine/app_state.dart';
import 'package:crisp_calc/engine/calculator_engine.dart';
import 'package:crisp_calc/utils/expression_preprocessing_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final engine = CalculatorEngine();

  Future<double?> foldCall(AppState s, String call) async {
    final expanded = ExpressionPreprocessingUtils.preprocessExpression(call, s);
    final folded = await ExpressionPreprocessingUtils.tryFoldPiecewise(
      expanded,
      (cond) async => engine.evaluate(cond),
    );
    if (folded == null) return null;
    // The fold returns the chosen branch VALUE expression (absx(-3) ->
    // '-(-3)'); evaluate it through the engine to a number.
    final out = engine.evaluate(folded);
    return double.tryParse(
        out.replaceAll(RegExp(r'\s*\+\s*-?0(\.0*)?\*?I$'), '').trim());
  }

  test('piecewise UDF folds through real SymEngine', () async {
    expect(engine.isNativeAvailable, isTrue, reason: 'run with -d macos');
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    // abs via piecewise
    s.setUserFunction(UserFunction(
        name: 'absx', params: ['x'], body: 'piecewise(x < 0, -x, x)'));
    // sign via 3-branch piecewise with else
    s.setUserFunction(UserFunction(
        name: 'sgn', params: ['x'], body: 'piecewise(x < 0, -1, x > 0, 1, 0)'));

    expect(await foldCall(s, 'absx(-3)'), 3.0);
    expect(await foldCall(s, 'absx(4)'), 4.0);
    expect(await foldCall(s, 'sgn(-5)'), -1.0);
    expect(await foldCall(s, 'sgn(5)'), 1.0);
    expect(await foldCall(s, 'sgn(0)'), 0.0);
  });
}
