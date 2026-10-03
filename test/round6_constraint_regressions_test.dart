import 'package:crisp_math/engine/csp_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('quadratic minimum is the interior optimum, not a sampled endpoint',
      () async {
    final result = await CspSolver.solveDsl('''
vars: x in -3..3
minimize x*x
''');
    expect(result.ok, isTrue, reason: result.error);
    expect(result.objective, 0);
    expect(result.solutions.single['x'], 0);
    expect(result.truncated, isFalse);
  });

  test('signed products optimize jointly with a linear constraint', () async {
    final result = await CspSolver.solveDsl('''
vars: x, y in -3..3
x + y == 1
maximize x*y
''');
    expect(result.ok, isTrue, reason: result.error);
    expect(result.objective, 0);
    final solution = result.solutions.single;
    expect(solution['x']! + solution['y']!, 1);
    expect(solution['x']! * solution['y']!, 0);
  });

  test('sums of repeated products retain coefficients and constants', () async {
    final result = await CspSolver.solveDsl('''
vars: x, y in -2..2
x != y
minimize 2*x*x + y*y - 4*x + 3
''');
    expect(result.ok, isTrue, reason: result.error);
    expect(result.objective, 1);
    expect(result.solutions.single, {'x': 1, 'y': 0});
  });

  test('polynomial objective and polynomial constraints share exact factors',
      () async {
    final result = await CspSolver.solveDsl('''
vars: x, y in -3..3
x*x + y*y == 5
maximize x*y
''');
    expect(result.ok, isTrue, reason: result.error);
    expect(result.objective, 2);
    final solution = result.solutions.single;
    final x = solution['x']!, y = solution['y']!;
    expect(x * x + y * y, 5);
    expect(x * y, 2);
  });

  test('allDifferent overlay survives nonlinear objective binding', () async {
    final result = await CspSolver.solveDsl('''
vars: x, y in -2..2
allDifferent(x, y)
maximize x*x + y*y
''');
    expect(result.ok, isTrue, reason: result.error);
    expect(result.objective, 8);
    final solution = result.solutions.single;
    expect(solution['x'], isNot(solution['y']));
    expect(solution['x']!.abs(), 2);
    expect(solution['y']!.abs(), 2);
  });

  test('negative cubic coefficient has a correctly bounded maximum', () async {
    final result = await CspSolver.solveDsl('''
vars: x in -3..3
maximize -2*x*x*x + 5
''');
    expect(result.ok, isTrue, reason: result.error);
    expect(result.objective, 59);
    expect(result.solutions.single['x'], -3);
  });

  test('infeasible constrained objective does not return an unconstrained value',
      () async {
    final result = await CspSolver.solveDsl('''
vars: x in -2..2
x*x == 3
minimize x*x
''');
    expect(result.ok, isFalse);
    expect(result.solutions, isEmpty);
  });

  test('linear optimization retains its existing fast path', () async {
    final result = await CspSolver.solveDsl('''
vars: a, b in 0..10
2*a + b <= 10
a + 3*b <= 15
maximize 3*a + 5*b
''');
    expect(result.ok, isTrue, reason: result.error);
    expect(result.objective, 29);
    expect(result.solutions.single, {'a': 3, 'b': 4});
  });

  test('unsupported polynomial grammars fail explicitly', () async {
    for (final expression in ['x^2', 'x*x/2',
      'sin(x)', 'x*missing', 'x x', '1.5*x*x']) {
      final result = await CspSolver.solveOptimization(
        variables: {'x': (min: -3, max: 3)},
        constraints: const [],
        minimize: true,
        objectiveExpr: expression,
      );
      expect(result.ok, isFalse, reason: expression);
      expect(result.error, contains('Could not parse'), reason: expression);
    }
  });

  test('grouped shifted factors find their exact global minimum', () async {
    final result = await CspSolver.solveOptimization(
      variables: {'x': (min: -3, max: 3)},
      constraints: const [],
      minimize: true,
      objectiveExpr: '(x-1)*(x-1)',
    );
    expect(result.ok, isTrue, reason: result.error);
    expect(result.objective, 0);
    expect(result.solutions.single, {'x': 1});
  });

  test('large objective domains fail before an expensive search', () async {
    final result = await CspSolver.solveOptimization(
      variables: {'x': (min: -100, max: 100)},
      constraints: const [],
      minimize: true,
      objectiveExpr: 'x*x',
    );
    expect(result.ok, isFalse);
    expect(result.error, contains('bounded resource limit'));
  });

  test('combined search domain is guarded even with a small objective',
      () async {
    final result = await CspSolver.solveOptimization(
      variables: {
        'x': (min: -1, max: 1),
        'y': (min: 0, max: 1000),
        'z': (min: 0, max: 1000),
      },
      constraints: const [],
      minimize: true,
      objectiveExpr: 'x*x',
    );
    expect(result.ok, isFalse);
    expect(result.error, contains('combined domain size'));
  });

  test('exact coefficients outside interoperable integer range are rejected',
      () async {
    final result = await CspSolver.solveOptimization(
      variables: {'x': (min: 0, max: 1)},
      constraints: const [],
      minimize: true,
      objectiveExpr: '9007199254740992*x*x',
    );
    expect(result.ok, isFalse);
    expect(result.error, contains('safe integer values'));
  });

  test('oversized grammar is rejected instead of partially parsed', () async {
    final result = await CspSolver.solveOptimization(
      variables: {'x': (min: -1, max: 1)},
      constraints: const [],
      minimize: true,
      objectiveExpr: List.filled(65, 'x*x').join('+'),
    );
    expect(result.ok, isFalse);
    expect(result.error, contains('Could not parse'));
  });
}
