// UDF V2 end-to-end on the native engine: a multi-parameter definition
// inlined by the preprocessor must evaluate to the right number through
// real SymEngine.  flutter test integration_test/udf_v2_native_test.dart -d macos

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/utils/expression_preprocessing_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final engine = CalculatorEngine();

  double? evalUdf(AppState s, String call) {
    final expanded = ExpressionPreprocessingUtils.preprocessNativeExpression(
      ExpressionPreprocessingUtils.preprocessExpression(call, s),
    );
    final out = engine.evaluate(expanded);
    return double.tryParse(
        out.replaceAll(RegExp(r'\s*\+\s*-?0(\.0*)?\*?I$'), '').trim());
  }

  test('multi-param UDF evaluates through native engine', () async {
    expect(engine.isNativeAvailable, isTrue, reason: 'run with -d macos');
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);

    s.setUserFunction(UserFunction(
        name: 'dist', params: ['a', 'b'], body: 'sqrt(a^2 + b^2)'));
    s.setUserFunction(
        UserFunction(name: 'add', params: ['a', 'b'], body: 'a + b'));

    expect(evalUdf(s, 'dist(3, 4)'), closeTo(5.0, 1e-9));
    expect(evalUdf(s, 'add(dist(3, 4), 10)'), closeTo(15.0, 1e-9));
    expect(evalUdf(s, 'add(2, 3)*dist(0, 1)'), closeTo(5.0, 1e-9));
  });
}
