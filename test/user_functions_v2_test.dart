// UDF V2 (2026-07-04): multi-letter names + multiple parameters.
// The preprocessor inlining is the load-bearing piece — these cover
// multi-arg substitution, arity checks, nesting, and legacy-load
// compatibility.

import 'package:crisp_calc/engine/app_state.dart';
import 'package:crisp_calc/utils/expression_preprocessing_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> _fresh() async {
  SharedPreferences.setMockInitialValues({});
  final s = AppState();
  await s.load(force: true);
  return s;
}

String expand(String expr, AppState s) =>
    ExpressionPreprocessingUtils.preprocessExpression(expr, s);

void main() {
  group('UDF V2 model', () {
    test('multi-param round-trips through JSON with new key', () async {
      final s = await _fresh();
      s.setUserFunction(UserFunction(
          name: 'dist', params: ['a', 'b'], body: 'sqrt(a^2 + b^2)'));
      final raw = (await SharedPreferences.getInstance())
          .getString('crisp.userFunctions');
      expect(raw, contains('"p":["a","b"]'));
      // reload
      final s2 = AppState();
      await s2.load(force: true);
      final fn = s2.userFunctions['dist']!;
      expect(fn.params, ['a', 'b']);
      expect(fn.arity, 2);
      expect(fn.paramVar, 'a'); // back-compat getter
    });

    test('legacy single-param JSON (v key) still loads', () async {
      SharedPreferences.setMockInitialValues({
        'crisp.userFunctions': '[{"n":"f","v":"t","b":"sin(t)"}]',
      });
      final s = AppState();
      await s.load(force: true);
      expect(s.userFunctions['f']!.params, ['t']);
      expect(s.userFunctions['f']!.arity, 1);
    });
  });

  group('UDF V2 expansion', () {
    test('two-parameter call substitutes positionally', () async {
      final s = await _fresh();
      s.setUserFunction(UserFunction(
          name: 'dist', params: ['a', 'b'], body: 'sqrt(a^2 + b^2)'));
      expect(expand('dist(3, 4)', s), '(sqrt((3)^2 + (4)^2))');
    });

    test('argument order matters and does not cross-contaminate', () async {
      final s = await _fresh();
      s.setUserFunction(
          UserFunction(name: 'sub', params: ['a', 'b'], body: 'a - b'));
      // Simultaneous substitution: the `b` in the first arg must not be
      // re-substituted by the second parameter.
      expect(expand('sub(b, 2)', s), '((b) - (2))');
    });

    test('multi-letter name inlines', () async {
      final s = await _fresh();
      s.setUserFunction(UserFunction(name: 'sq', params: ['x'], body: 'x*x'));
      expect(expand('sq(5)', s), '((5)*(5))');
    });

    test('nested args split at top level only', () async {
      final s = await _fresh();
      s.setUserFunction(
          UserFunction(name: 'add', params: ['a', 'b'], body: 'a + b'));
      s.setUserFunction(UserFunction(name: 'sq', params: ['x'], body: 'x^2'));
      expect(expand('add(sq(2), 3)', s), '((((2)^2)) + (3))');
    });

    test('arity mismatch leaves the call untouched', () async {
      final s = await _fresh();
      s.setUserFunction(
          UserFunction(name: 'add', params: ['a', 'b'], body: 'a + b'));
      // one arg for a two-arg function — not expanded
      expect(expand('add(5)', s), 'add(5)');
    });

    test('does not shadow built-ins with similar prefixes', () async {
      final s = await _fresh();
      s.setUserFunction(UserFunction(name: 'si', params: ['x'], body: 'x + 1'));
      // `sin(2)` must survive even though `si` is a UDF prefix.
      expect(expand('sin(2)', s), 'sin(2)');
      expect(expand('si(2)', s), '((2) + 1)');
    });
  });
}
