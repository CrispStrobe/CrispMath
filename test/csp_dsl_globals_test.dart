// test/csp_dsl_globals_test.dart
//
// Round 108: coverage for the new constraint-DSL keywords wired onto
// dart_csp 2.2.0 global constraints — logic combinators (atLeast /
// atMost / exactly / implies), global cardinality (gcc / among /
// nvalue), a regular-language shift rule (atMostInARow), and value
// symmetry breaking (valuePrecedence). Each is exercised against a
// small problem with a hand-checked solution set.

import 'package:crisp_math/engine/csp_solver.dart';
import 'package:flutter_test/flutter_test.dart';

const _t = Timeout(Duration(seconds: 15));

void main() {
  group('logic combinators', () {
    test('atMost(1, …) — at most one condition holds', () async {
      final r = await CspSolver.solveDsl('''
vars: a, b, c in 0..1
atMost(1, a=1, b=1, c=1)
''');
      expect(r.ok, isTrue, reason: r.error);
      expect(r.solutions, hasLength(4)); // 000, 100, 010, 001
      for (final s in r.solutions) {
        final ones = [s['a'], s['b'], s['c']].where((v) => v == 1).length;
        expect(ones, lessThanOrEqualTo(1));
      }
    }, timeout: _t);

    test('atLeast(2, …) — at least two conditions hold', () async {
      final r = await CspSolver.solveDsl('''
vars: a, b, c in 0..1
atLeast(2, a=1, b=1, c=1)
''');
      expect(r.ok, isTrue, reason: r.error);
      expect(r.solutions, hasLength(4)); // 110, 101, 011, 111
      for (final s in r.solutions) {
        final ones = [s['a'], s['b'], s['c']].where((v) => v == 1).length;
        expect(ones, greaterThanOrEqualTo(2));
      }
    }, timeout: _t);

    test('exactly(1, …) — exactly one condition holds', () async {
      final r = await CspSolver.solveDsl('''
vars: a, b, c in 0..1
exactly(1, a=1, b=1, c=1)
''');
      expect(r.ok, isTrue, reason: r.error);
      expect(r.solutions, hasLength(3));
    }, timeout: _t);

    test('conditions can target non-boolean values', () async {
      // a in 0..2; exactly one of {a=2, b=2} holds.
      final r = await CspSolver.solveDsl('''
vars: a, b in 0..2
exactly(1, a=2, b=2)
''');
      expect(r.ok, isTrue, reason: r.error);
      for (final s in r.solutions) {
        final hits = [s['a'] == 2, s['b'] == 2].where((x) => x).length;
        expect(hits, 1);
      }
    }, timeout: _t);

    test('implies(a=1, b=2) — material implication', () async {
      final r = await CspSolver.solveDsl('''
vars: a, b in 0..2
implies(a=1, b=2)
''');
      expect(r.ok, isTrue, reason: r.error);
      expect(r.solutions, hasLength(7)); // a=1→b=2 (1); a∈{0,2}→b free (6)
      for (final s in r.solutions) {
        if (s['a'] == 1) expect(s['b'], 2);
      }
    }, timeout: _t);

    test('reified bool vars never leak into the solution rows', () async {
      final r = await CspSolver.solveDsl('''
vars: a, b in 0..1
atLeast(1, a=1, b=1)
''');
      expect(r.ok, isTrue, reason: r.error);
      for (final s in r.solutions) {
        expect(s.keys.every((k) => !k.startsWith('__')), isTrue,
            reason: 'synthetic var leaked: ${s.keys}');
        expect(s.keys.toSet(), {'a', 'b'});
      }
    }, timeout: _t);
  });

  group('global cardinality', () {
    test('gcc — each value used an exact number of times ⇒ permutations',
        () async {
      final r = await CspSolver.solveDsl('''
vars: x, y, z in 1..3
gcc(x, y, z; 1=1, 2=1, 3=1)
''');
      expect(r.ok, isTrue, reason: r.error);
      expect(r.solutions, hasLength(6)); // 3! permutations of {1,2,3}
      for (final s in r.solutions) {
        expect({s['x'], s['y'], s['z']}, {1, 2, 3});
      }
    }, timeout: _t);

    test('among — count of vars taking an in-set value', () async {
      final r = await CspSolver.solveDsl('''
vars: x, y in 0..1
vars: c in 0..2
among(x, y; values=1; count=c)
''');
      expect(r.ok, isTrue, reason: r.error);
      expect(r.solutions, hasLength(4));
      for (final s in r.solutions) {
        final inSet = [s['x'], s['y']].where((v) => v == 1).length;
        expect(s['c'], inSet);
      }
    }, timeout: _t);

    test('nvalue + minimize — chromatic number of a 4-cycle is 2', () async {
      final r = await CspSolver.solveDsl('''
vars: a, b, c, d in 1..4
vars: n in 1..4
a != b
b != c
c != d
d != a
nvalue(a, b, c, d; count=n)
minimize n
''');
      expect(r.ok, isTrue, reason: r.error);
      expect(r.objective, 2);
      // Optimum assignment uses exactly two distinct colours.
      final s = r.solutions.single;
      expect({s['a'], s['b'], s['c'], s['d']}.length, 2);
      expect(s.keys.every((k) => !k.startsWith('__')), isTrue);
    }, timeout: _t);
  });

  group('regular — shift patterns', () {
    test('atMostInARow — no run of >2 consecutive 1s', () async {
      final r = await CspSolver.solveDsl('''
vars: a, b, c, d in 0..1
atMostInARow(a, b, c, d; value=1; max=2)
''');
      expect(r.ok, isTrue, reason: r.error);
      // 16 length-4 binary strings minus the 3 with a run of ≥3 ones
      // (1110, 0111, 1111) = 13.
      expect(r.solutions, hasLength(13));
      for (final s in r.solutions) {
        final seq = [s['a'], s['b'], s['c'], s['d']];
        var run = 0;
        for (final v in seq) {
          run = v == 1 ? run + 1 : 0;
          expect(run, lessThanOrEqualTo(2));
        }
      }
    }, timeout: _t);

    test('atMostInARow max=1 forbids any two adjacent 1s', () async {
      final r = await CspSolver.solveDsl('''
vars: a, b, c in 0..1
atMostInARow(a, b, c; value=1; max=1)
''');
      expect(r.ok, isTrue, reason: r.error);
      for (final s in r.solutions) {
        final seq = [s['a'], s['b'], s['c']];
        for (var i = 0; i + 1 < seq.length; i++) {
          expect(seq[i] == 1 && seq[i + 1] == 1, isFalse);
        }
      }
    }, timeout: _t);
  });

  group('valuePrecedence — symmetry breaking', () {
    test('first variable is pinned to the first canonical value', () async {
      final r = await CspSolver.solveDsl('''
vars: a, b, c in 1..3
valuePrecedence(a, b, c; order=1,2,3)
''');
      expect(r.ok, isTrue, reason: r.error);
      // Value 2 may not precede 1, nor 3 precede 2, so position 0 can
      // only hold value 1; and the whole set is strictly smaller than
      // the un-broken 3^3 = 27.
      expect(r.solutions, isNotEmpty);
      expect(r.solutions.length, lessThan(27));
      for (final s in r.solutions) {
        expect(s['a'], 1);
      }
    }, timeout: _t);
  });

  // These are the exact programs wired into the DSL worked-example
  // gallery (constraints_screen.dart). Testing the literal strings keeps
  // the gallery from shipping a broken example.
  group('gallery examples solve', () {
    test('logicGrid — implies + exactly prune the pet assignment', () async {
      final r =
          await CspSolver.solveDsl('''# Ann, Bob, Cy each pick a different pet.
# 1 = cat, 2 = dog, 3 = fish.
vars: ann, bob, cy in 1..3
allDifferent(ann, bob, cy)
ann != 3
implies(bob=1, cy=2)
exactly(1, ann=1, bob=1)''');
      expect(r.ok, isTrue, reason: r.error);
      expect(r.solutions, isNotEmpty);
      for (final s in r.solutions) {
        expect(s['ann'], isNot(3));
        if (s['bob'] == 1) expect(s['cy'], 2);
        expect([s['ann'] == 1, s['bob'] == 1].where((x) => x).length, 1);
      }
    }, timeout: _t);

    test('nurseRostering — run limits + days-off count', () async {
      final r = await CspSolver.solveDsl(
          '''# One nurse's 5-day plan. 0 = off, 1 = day, 2 = night.
vars: d1, d2, d3, d4, d5 in 0..2
atMostInARow(d1, d2, d3, d4, d5; value=1; max=2)
atMostInARow(d1, d2, d3, d4, d5; value=2; max=1)
gcc(d1, d2, d3, d4, d5; 0=2)''');
      expect(r.ok, isTrue, reason: r.error);
      expect(r.solutions, isNotEmpty);
      for (final s in r.solutions) {
        final seq = [s['d1'], s['d2'], s['d3'], s['d4'], s['d5']];
        expect(seq.where((v) => v == 0).length, 2);
        var dayRun = 0;
        for (final v in seq) {
          dayRun = v == 1 ? dayRun + 1 : 0;
          expect(dayRun, lessThanOrEqualTo(2));
        }
      }
    }, timeout: _t);

    test('menuPairing — table lists exactly the offered combos', () async {
      final r = await CspSolver.solveDsl(
          '''# Café menu — only these (main, side) pairings are offered.
# main: 1 soup / 2 salad / 3 pasta   side: 1 bread / 2 fries / 3 fruit
vars: main, side in 1..3
table(main, side; (1,1), (1,3), (2,2), (2,3), (3,1), (3,2))''');
      expect(r.ok, isTrue, reason: r.error);
      final got = {for (final s in r.solutions) '${s['main']},${s['side']}'};
      expect(got, {'1,1', '1,3', '2,2', '2,3', '3,1', '3,2'});
    }, timeout: _t);

    test('chromaticNumber — odd 5-cycle needs 3 colours', () async {
      final r = await CspSolver.solveDsl(
          '''# Fewest colours for a 5-cycle (odd cycle ⇒ 3).
vars: a, b, c, d, e in 1..5
vars: colors in 1..5
a != b
b != c
c != d
d != e
e != a
nvalue(a, b, c, d, e; count=colors)
minimize colors''');
      expect(r.ok, isTrue, reason: r.error);
      expect(r.objective, 3);
    }, timeout: _t);
  });

  group('relational constraints', () {
    test('table — solutions are exactly the allowed tuples', () async {
      final r = await CspSolver.solveDsl('''
vars: x, y in 1..3
table(x, y; (1,2), (2,3), (3,1))
''');
      expect(r.ok, isTrue, reason: r.error);
      final got = {for (final s in r.solutions) '${s['x']},${s['y']}'};
      expect(got, {'1,2', '2,3', '3,1'});
    }, timeout: _t);

    test('element — list[idx] == value (0-based)', () async {
      final r = await CspSolver.solveDsl('''
vars: idx in 0..2
vars: v in 10..30
element(idx; list=10,20,30; value=v)
''');
      expect(r.ok, isTrue, reason: r.error);
      expect(r.solutions, hasLength(3));
      const list = [10, 20, 30];
      for (final s in r.solutions) {
        expect(s['v'], list[s['idx']!]);
      }
    }, timeout: _t);

    test('element composes with an objective (min cost of a choice)', () async {
      final r = await CspSolver.solveDsl('''
vars: idx in 0..2
vars: cost in 0..100
element(idx; list=40,15,30; value=cost)
minimize cost
''');
      expect(r.ok, isTrue, reason: r.error);
      expect(r.objective, 15);
      expect(r.solutions.single['idx'], 1);
    }, timeout: _t);
  });

  group('error handling', () {
    test('table tuple length must match the variable count', () async {
      final r = await CspSolver.solveDsl('''
vars: x, y in 1..3
table(x, y; (1,2,3))
''');
      expect(r.ok, isFalse);
      expect(r.error, contains('variable'));
    });

    test('element value variable must be declared', () async {
      final r = await CspSolver.solveDsl('''
vars: idx in 0..1
element(idx; list=1,2; value=ghost)
''');
      expect(r.ok, isFalse);
      expect(r.error, contains('not declared'));
    });

    test('condition references an undeclared variable', () async {
      final r = await CspSolver.solveDsl('''
vars: a in 0..1
atMost(1, a=1, ghost=1)
''');
      expect(r.ok, isFalse);
      expect(r.error, contains('undeclared'));
    });

    test('k larger than the number of conditions', () async {
      final r = await CspSolver.solveDsl('''
vars: a, b in 0..1
atLeast(3, a=1, b=1)
''');
      expect(r.ok, isFalse);
      expect(r.error, contains('only 2 condition'));
    });

    test('implies needs exactly two conditions', () async {
      final r = await CspSolver.solveDsl('''
vars: a, b, c in 0..1
implies(a=1, b=1, c=1)
''');
      expect(r.ok, isFalse);
      expect(r.error, contains('two conditions'));
    });

    test('gcc count clause must be value=count', () async {
      final r = await CspSolver.solveDsl('''
vars: x, y in 1..2
gcc(x, y; 1)
''');
      expect(r.ok, isFalse);
      expect(r.error, contains('value=count'));
    });

    test('among count variable must be declared', () async {
      final r = await CspSolver.solveDsl('''
vars: x, y in 0..1
among(x, y; values=1; count=missing)
''');
      expect(r.ok, isFalse);
      expect(r.error, contains('not declared'));
    });

    test('variable names starting with "__" are reserved', () async {
      final r = await CspSolver.solveDsl('vars: __x in 0..1');
      expect(r.ok, isFalse);
      expect(r.error, contains('reserved'));
    });
  });
}
