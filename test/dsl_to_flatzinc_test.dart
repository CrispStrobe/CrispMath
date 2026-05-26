// test/dsl_to_flatzinc_test.dart
//
// Round E.3 — DSL → FlatZinc transpiler. We assert both:
//   * Structural shape of the output (correct FlatZinc builtin
//     names per DSL operator, output_var annotations on every
//     declared variable, solve directive shape).
//   * Round-trip semantics — every emitted .fzn is fed back into
//     dart_csp's FlatZinc.solve so we know the translation
//     produces a parseable + solvable model. This is the load-
//     bearing guarantee: if a DSL program solves locally, its
//     FlatZinc export must also solve.

import 'package:crisp_calc/engine/csp_solver.dart';
import 'package:dart_csp/dart_csp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DslToFlatZinc.export — structural', () {
    test('declares each variable with output_var', () {
      final r = DslToFlatZinc.export('vars: x, y in 1..9');
      expect(r.ok, isTrue);
      expect(r.source, contains('var 1..9: x :: output_var;'));
      expect(r.source, contains('var 1..9: y :: output_var;'));
    });

    test('allDifferent → all_different_int', () {
      final r = DslToFlatZinc.export('''vars: a, b, c in 1..9
allDifferent(a, b, c)''');
      expect(r.ok, isTrue);
      expect(r.source, contains('constraint all_different_int([a, b, c]);'));
    });

    test('linear equality → int_lin_eq with bound on RHS', () {
      final r = DslToFlatZinc.export('''vars: x, y in 0..10
2*x + 3*y == 12''');
      expect(r.ok, isTrue);
      expect(r.source!, contains('constraint int_lin_eq([2, 3], [x, y], 12);'));
    });

    test('strict < lowers bound by 1', () {
      final r = DslToFlatZinc.export('''vars: x in 0..10
x < 5''');
      expect(r.ok, isTrue);
      // x < 5 ⇒ int_lin_le([1], [x], 4)
      expect(r.source, contains('constraint int_lin_le([1], [x], 4);'));
    });

    test('>= negates coefficients to fit int_lin_le', () {
      final r = DslToFlatZinc.export('''vars: x in 0..10
x >= 3''');
      expect(r.ok, isTrue);
      // x >= 3 ⇒ -x <= -3 ⇒ int_lin_le([-1], [x], -3)
      expect(r.source, contains('constraint int_lin_le([-1], [x], -3);'));
    });

    test('!= uses int_lin_ne', () {
      final r = DslToFlatZinc.export('''vars: x, y in 0..10
x != y''');
      expect(r.ok, isTrue);
      expect(r.source, contains('int_lin_ne'));
    });

    test('noOverlap → disjunctive', () {
      final r = DslToFlatZinc.export('''vars: s1, s2 in 0..10
noOverlap(s1=4, s2=3)''');
      expect(r.ok, isTrue);
      expect(r.source, contains('constraint disjunctive([s1, s2], [4, 3]);'));
    });

    test('cumulative passes capacity through', () {
      final r = DslToFlatZinc.export('''vars: s1, s2 in 0..10
cumulative(s1=2@2, s2=3@1; capacity=3)''');
      expect(r.ok, isTrue);
      expect(r.source,
          contains('constraint cumulative([s1, s2], [2, 3], [2, 1], 3);'));
    });

    test('minimize binds __obj__ and emits solve minimize', () {
      final r = DslToFlatZinc.export('''vars: x in 0..5
vars: y in 0..5
minimize x + y''');
      expect(r.ok, isTrue);
      expect(r.source, contains('var 0..10: __obj__ :: output_var;'));
      expect(r.source,
          contains('constraint int_lin_eq([1, 1, -1], [x, y, __obj__], 0);'));
      expect(r.source, contains('solve minimize __obj__;'));
    });

    test('maximize uses solve maximize', () {
      final r = DslToFlatZinc.export('''vars: x in 0..5
maximize x''');
      expect(r.ok, isTrue);
      expect(r.source, contains('solve maximize __obj__;'));
    });

    test('no objective → solve satisfy', () {
      final r = DslToFlatZinc.export('vars: x in 0..5');
      expect(r.ok, isTrue);
      expect(r.source, contains('solve satisfy;'));
    });

    test('comments / blank lines tolerated', () {
      final r = DslToFlatZinc.export('''# header comment
vars: x in 0..3

x >= 1   # inline comment''');
      expect(r.ok, isTrue);
      expect(r.source, contains('int_lin_le([-1], [x], -1);'));
    });
  });

  group('DslToFlatZinc.export — errors', () {
    test('no variables → friendly error', () {
      // Use a blank / comment-only source so the export reaches the
      // end-of-input "no variables" check rather than tripping over
      // an earlier "undeclared" rejection.
      final r = DslToFlatZinc.export('# header only\n');
      expect(r.ok, isFalse);
      expect(r.error, contains('No variables'));
    });

    test('duplicate vars declaration → friendly error', () {
      final r = DslToFlatZinc.export('''vars: x in 0..5
vars: x in 0..10''');
      expect(r.ok, isFalse);
      expect(r.error, contains('already declared'));
    });

    test('non-linear constraint → friendly error', () {
      // Two * on the same term — not handled by the linear parser.
      final r = DslToFlatZinc.export('''vars: x, y in 0..5
x * y == 6''');
      expect(r.ok, isFalse);
      expect(r.error, contains('not a linear constraint'));
    });

    test('reserved __obj__ rejected', () {
      final r = DslToFlatZinc.export('vars: __obj__ in 0..5');
      expect(r.ok, isFalse);
      expect(r.error, contains('reserved'));
    });

    test('allDifferent on undeclared variable → friendly error', () {
      final r = DslToFlatZinc.export('''vars: x in 0..5
allDifferent(x, y)''');
      expect(r.ok, isFalse);
      expect(r.error, contains('undeclared'));
    });
  });

  group('DslToFlatZinc.export — round-trip through FlatZinc.solve', () {
    Future<void> expectFlatZincSolves(String dsl) async {
      final r = DslToFlatZinc.export(dsl);
      expect(r.ok, isTrue,
          reason: 'export failed: ${r.error}\n--- DSL ---\n$dsl');
      final out = await FlatZinc.solve(r.source!);
      expect(out, isNot(contains('=====UNSATISFIABLE=====')),
          reason: 'FlatZinc.solve reported unsat for export:\n${r.source}');
    }

    test('magic-sum DSL exports to a solvable FlatZinc', () async {
      await expectFlatZincSolves('''vars: x, y, z in 1..9
allDifferent(x, y, z)
x + y + z == 15''');
    });

    test('coin-change minimize exports to a solvable FlatZinc', () async {
      await expectFlatZincSolves('''vars: pennies in 0..17
vars: nickels in 0..3
vars: dimes in 0..1
pennies + 5*nickels + 10*dimes == 17
minimize pennies + nickels + dimes''');
    });

    test('scheduling DSL exports to a solvable FlatZinc', () async {
      await expectFlatZincSolves('''vars: s1, s2, s3 in 0..9
vars: makespan in 0..9
noOverlap(s1=4, s2=3, s3=2)
s1 + 4 <= makespan
s2 + 3 <= makespan
s3 + 2 <= makespan
minimize makespan''');
    });
  });
}
