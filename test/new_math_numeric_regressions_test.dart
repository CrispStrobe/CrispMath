import 'package:crisp_math/engine/csp_solver.dart';
import 'package:crisp_math/engine/unit_expression.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('signed quantities', () {
    for (final pair in [
      ['-40 °C in °F', '-40 °F'],
      ['-40 °F in °C', '-40 °C'],
      ['-10 °C in K', '263.15 K'],
      ['-273.15 °C in K', '0 K'],
      ['-4 °F in °C', '-20 °C'],
      ['+20 °C in K', '293.15 K'],
      ['-250 cm in m', '-2.5 m'],
      ['-2 m + 50 cm in m', '-1.5 m'],
      ['2 m - -50 cm in m', '2.5 m'],
      ['-2 * 3 m in cm', '-600 cm'],
      ['3 m * -2 in m', '-6 m'],
      ['-1e-2 km in m', '-10 m'],
    ]) {
      test(pair.first, () {
        expect(UnitExpressionEvaluator.tryEvaluate(pair.first), pair.last);
      });
    }
    test('binary subtraction and offset arithmetic policy remain intact', () {
      expect(UnitExpressionEvaluator.tryEvaluate('3 m - 50 cm in m'), '2.5 m');
      expect(UnitExpressionEvaluator.tryEvaluate('-10 °C + 5 °C'),
          startsWith('Error: temperature arithmetic is ambiguous'));
      expect(UnitExpressionEvaluator.tryEvaluate('-foo m in cm'), isNull);
    });
  });

  group('repeated product factors', () {
    for (final example in [
      ('x*x == 4', <int>{-2, 2}),
      ('x*x == 0', <int>{0}),
      ('x*x == -1', <int>{}),
      ('x*x < 4', <int>{-1, 0, 1}),
      ('x*x != 4', <int>{-3, -1, 0, 1, 3}),
      ('x*x*x == -8', <int>{-2}),
    ]) {
      test(example.$1, () async {
        final result =
            await CspSolver.solveDsl('vars: x in -3..3\n${example.$1}');
        expect(result.ok, isTrue, reason: result.error);
        expect(result.truncated, isFalse);
        expect(result.solutions.map((s) => s['x']).toSet(), example.$2);
        expect(result.solutions, hasLength(example.$2.length));
      });
    }
    test('mixed repeated factors retain multiplicity with two distinct names',
        () async {
      final result =
          await CspSolver.solveDsl('vars: x, y in -2..2\nx*x*y == 4');
      expect(result.ok, isTrue, reason: result.error);
      expect(result.solutions, hasLength(2));
      expect(result.solutions.map((s) => '${s['x']},${s['y']}').toSet(),
          {'-2,1', '2,1'});
    });
    test('ordinary signed multiplication keeps all four solutions', () async {
      final result = await CspSolver.solveDsl('vars: x, y in -2..2\nx*y == -2');
      expect(result.ok, isTrue, reason: result.error);
      expect(result.solutions, hasLength(4));
      expect(result.solutions.map((s) => '${s['x']},${s['y']}').toSet(),
          {'-2,1', '-1,2', '1,-2', '2,-1'});
    });
    test('signed linear multiplication keeps its existing exact solution',
        () async {
      final result = await CspSolver.solveDsl('vars: x in -3..3\n2*x == -4');
      expect(result.ok, isTrue, reason: result.error);
      expect(result.solutions, [
        {'x': -2}
      ]);
    });
    test('minimization uses the same multiplicity-preserving constraints',
        () async {
      final result =
          await CspSolver.solveDsl('vars: x in -3..3\nx*x == 4\nminimize x');
      expect(result.ok, isTrue, reason: result.error);
      expect(result.solutions, [
        {'x': -2}
      ]);
    });
  });
}
