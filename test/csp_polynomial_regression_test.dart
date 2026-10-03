import 'package:crisp_math/engine/csp_solver.dart';
import 'package:flutter_test/flutter_test.dart';

Set<String> pairs(DiophantineResult result) =>
    result.solutions.map((s) => '${s['x']},${s['y']}').toSet();

void main() {
  group('Integer polynomial constraint routing', () {
    test('sum of squares preserves all signed roots', () async {
      final result = await CspSolver.solveDsl(
          'vars: x, y in -2..2\nx*x + y*y == 2');
      expect(result.ok, isTrue, reason: result.error);
      expect(pairs(result), {'-1,-1', '-1,1', '1,-1', '1,1'});
    });

    test('signed coefficients, constants and products on both sides', () async {
      final result = await CspSolver.solveDsl(
          'vars: x, y in -2..2\n-2*x*x + 3*y*y + 1 == x*y - 2');
      expect(result.ok, isTrue, reason: result.error);
      final expected = <String>{};
      for (var x = -2; x <= 2; x++) {
        for (var y = -2; y <= 2; y++) {
          if (-2 * x * x + 3 * y * y + 1 == x * y - 2) {
            expected.add('$x,$y');
          }
        }
      }
      expect(expected, isNotEmpty);
      expect(pairs(result), expected);
    });

    for (final op in ['==', '!=', '<', '<=', '>', '>=']) {
      test('comparison $op retains signed polynomial meaning', () async {
        final result = await CspSolver.solveDsl(
            'vars: x, y in -2..2\nx*x + y*y $op 2');
        expect(result.ok, isTrue, reason: result.error);
        final expected = <String>{};
        for (var x = -2; x <= 2; x++) {
          for (var y = -2; y <= 2; y++) {
            final sum = x * x + y * y;
            final satisfies = switch (op) {
              '==' => sum == 2,
              '!=' => sum != 2,
              '<' => sum < 2,
              '<=' => sum <= 2,
              '>' => sum > 2,
              _ => sum >= 2,
            };
            if (satisfies) {
              expected.add('$x,$y');
            }
          }
        }
        expect(pairs(result), expected);
      });
    }

    test('one and three variable predicates retain multiplicity', () async {
      final unary = await CspSolver.solveDsl('vars: x in -3..3\nx*x <= 1');
      expect(unary.ok, isTrue, reason: unary.error);
      expect(unary.solutions.map((s) => s['x']).toSet(), {-1, 0, 1});
      final ternary = await CspSolver.solveDsl(
          'vars: x, y, z in -1..1\nx*x + y*y + z*z == 1');
      expect(ternary.ok, isTrue, reason: ternary.error);
      expect(ternary.solutions, hasLength(6));
      for (final s in ternary.solutions) {
        expect(s.values.fold<int>(0, (a, b) => a + b * b), 1);
      }
    });

    test('integer coefficients do not round to the same double', () async {
      final result = await CspSolver.solveDsl(
          'vars: x in -1..1\n9007199254740993*x*x == 9007199254740992');
      expect(result.ok, isTrue, reason: result.error);
      expect(result.solutions, isEmpty);
    });

    test('optimizer uses the same polynomial constraints', () async {
      final result = await CspSolver.solveDsl(
          'vars: x, y in -2..2\nx*x + y*y == 2\nminimize x + y');
      expect(result.ok, isTrue, reason: result.error);
      expect(result.objective, -2);
      expect(pairs(result), {'-1,-1'});
    });

    test('trace follows a real polynomial solution', () async {
      final trace = await CspSolver.traceDsl(
          'vars: x, y in -2..2\nx*x + y*y == 2');
      expect(trace.ok, isTrue, reason: trace.error);
      expect(trace.solved, isTrue);
      expect(trace.steps, isNotEmpty);
      final solution = trace.solution!;
      expect(solution['x']! * solution['x']! +
          solution['y']! * solution['y']!, 2);
      expect(trace.initialDomains['x'], [-2, -1, 0, 1, 2]);
    });

    test('both explanation routes preserve polynomial labels', () async {
      const variables = {'x': (min: -2, max: 2), 'y': (min: -2, max: 2)};
      const constraints = ['x*x + y*y == 2', 'x == 0'];
      final direct = await CspSolver.explainDiophantine(
          variables: variables, constraints: constraints);
      final dsl = await CspSolver.explainDsl(
          'vars: x, y in -2..2\nx*x + y*y == 2\nx == 0');
      for (final explanation in [direct, dsl]) {
        expect(explanation.error, isNull);
        expect(explanation.wasSatisfiable, isFalse);
        expect(explanation.entries, isNotEmpty);
        expect(explanation.entries.any((e) => e.label.contains('x*x + y*y')),
            isTrue);
      }
    });

    test('unsupported and undeclared factors are not silently reinterpreted',
        () async {
      for (final source in [
        'x*x + 0.5*y*y == 2',
        'x*x + missing*missing == 2',
        'x**x + y*y == 2',
      ]) {
        final result = await CspSolver.solveDsl('vars: x, y in -2..2\n$source');
        expect(result.ok, isFalse, reason: source);
        expect(result.error, isNotEmpty, reason: source);
      }
    });
  });
}
