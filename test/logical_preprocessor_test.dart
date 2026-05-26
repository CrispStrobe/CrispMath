// test/logical_preprocessor_test.dart
//
// Round 111 (P7) — logical-operator preprocessor.
//
// `not` / `and` / `or` / `xor` get rewritten into SymEngine's
// `Not(...)` / `And(...)` / `Or(...)` / `Xor(...)`. Precedence
// matches Python: `not` binds tighter than `and` binds tighter
// than `xor` binds tighter than `or`. Relational ops bind tighter
// than `not` so `not x == 5` reads as `Not(Eq(x, 5))`.
//
// SymEngine isn't loaded in headless `flutter test`, so we only
// pin the rewrite shape here — end-to-end folding through
// `And(True, True) → True` runs in the on-device builds.

import 'package:crisp_calc/utils/expression_preprocessing_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('preprocessLogicalOperators — simple', () {
    test('unary not at start', () {
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('not x'),
        'Not(x)',
      );
    });

    test('and infix → And(...)', () {
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('x and y'),
        'And(x, y)',
      );
    });

    test('or infix → Or(...)', () {
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('x or y'),
        'Or(x, y)',
      );
    });

    test('xor infix → Xor(...)', () {
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('a xor b'),
        'Xor(a, b)',
      );
    });

    test('chained `and` collapses to a single n-ary call', () {
      // SymEngine accepts arbitrary arity on And/Or/Xor — the
      // round-111 splitter takes advantage of that to keep the
      // rewrite shallow.
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators(
            'a and b and c'),
        'And(a, b, c)',
      );
    });

    test('chained `or` collapses similarly', () {
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('p or q or r'),
        'Or(p, q, r)',
      );
    });
  });

  group('preprocessLogicalOperators — precedence', () {
    test('`not x and y` reads as `(not x) and y`', () {
      // Python-style: `and` is split first (lower precedence),
      // then `not` wraps just its operand.
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('not x and y'),
        'And(Not(x), y)',
      );
    });

    test('`not (x and y)` parenthesizes the `and`', () {
      // Phase A descends into parens so the inner `and` lowers
      // first; phase B wraps the result in Not.
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators(
            'not (x and y)'),
        'Not((And(x, y)))',
      );
    });

    test('`a and b or c` reads as `(a and b) or c`', () {
      // `or` is the lowest-precedence split: outer call is Or.
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('a and b or c'),
        'Or(And(a, b), c)',
      );
    });

    test('`a or b and c` reads as `a or (b and c)`', () {
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('a or b and c'),
        'Or(a, And(b, c))',
      );
    });

    test('`a xor b and c` — `and` binds tighter than `xor`', () {
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators(
            'a xor b and c'),
        'Xor(a, And(b, c))',
      );
    });

    test('relational binds tighter than `not`', () {
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('not x == 5'),
        'Not(Eq(x, 5))',
      );
    });

    test('full mix: `isprime(17) and 17 < 20`', () {
      // The motivating example from the PLAN — relational rewrite
      // happens at the leaf after the `and` split.
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators(
            'isprime(17) and 17 < 20'),
        'And(isprime(17), Lt(17, 20))',
      );
    });

    test('double `not` nests', () {
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('not not x'),
        'Not(Not(x))',
      );
    });
  });

  group('preprocessLogicalOperators — word boundaries', () {
    test('identifiers containing `and` are not split', () {
      // `random` contains `and` but mustn't trigger a split. The
      // word-boundary check on both sides keeps this safe.
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('random + 1'),
        'random + 1',
      );
    });

    test('identifiers containing `or` not split', () {
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('factor(x)'),
        'factor(x)',
      );
    });

    test('identifiers starting with `not` not affected', () {
      // `notation` shouldn't get wrapped in Not — `not` must be
      // followed by whitespace (or be a standalone word).
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('notation'),
        'notation',
      );
    });

    test('whole-word `and` inside paren-group still recognized', () {
      // Phase A descends into the parens so the inner `and` lowers.
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('(x and y)'),
        '(And(x, y))',
      );
    });
  });

  group('preprocessLogicalOperators — relational integration', () {
    test('relational rewrite still fires at the leaf', () {
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('x < 5'),
        'Lt(x, 5)',
      );
    });

    test('plain arithmetic passes through unchanged', () {
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('x + 1'),
        'x + 1',
      );
    });

    test('single `=` not consumed', () {
      // Same guarantee as round 110: single-equal stays for the
      // assignment / bare-equation paths.
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('x = 5'),
        'x = 5',
      );
    });

    test('empty input handled', () {
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators(''),
        '',
      );
    });
  });

  group('preprocessLogicalOperators — defensive', () {
    test('trailing `and` collapses to no-op (drops empty operand)', () {
      // `x and ` with nothing after — splitter drops the empty
      // operand and the single remaining piece falls through to
      // relational rewrite, which is a no-op.
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('x and '),
        'x and ',
      );
    });

    test('unbalanced paren — descend gives up safely', () {
      // No exception, returns something parseable downstream (the
      // engine will surface the syntax error). We just shouldn't
      // throw.
      expect(
        () => ExpressionPreprocessingUtils.preprocessLogicalOperators(
            'not (x and'),
        returnsNormally,
      );
    });
  });

  group('preprocessLogicalOperators — paren-descent comma split (111b)', () {
    test('multi-arg function call with relational in one arg', () {
      // Pre-fix bug: the relational scan inside the descent walked
      // past the comma and produced `Min(Eq(2, 2, x + 1))`. With the
      // comma split each arg is rewritten independently.
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators(
            'Min(2 == 2, x + 1)'),
        'Min(Eq(2, 2), x + 1)',
      );
    });

    test('if(cond, t, e) shape rewrites condition in place', () {
      // Required for `tryFoldIfConditional` to find a clean
      // `Eq(...)` form in the first arg.
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators(
            'if(2 == 2, x^2, x + 1)'),
        'if(Eq(2, 2), x^2, x + 1)',
      );
    });

    test('three-arg call with one relational and one logical', () {
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators(
            'if(a and b, x < 5, x)'),
        'if(And(a, b), Lt(x, 5), x)',
      );
    });

    test('single-arg call still works', () {
      // No commas to split — degenerate case of the new splitter.
      expect(
        ExpressionPreprocessingUtils.preprocessLogicalOperators('isprime(17)'),
        'isprime(17)',
      );
    });
  });

  group('tryFoldIfConditional', () {
    Future<String> trueEvaluator(String _) async => 'True';
    Future<String> falseEvaluator(String _) async => 'False';
    Future<String> symbolicEvaluator(String s) async => 'Eq(x, 5)';

    test('returns then-branch when condition folds to true', () async {
      final r = await ExpressionPreprocessingUtils.tryFoldIfConditional(
        'if(Eq(2, 2), x^2, x + 1)',
        trueEvaluator,
      );
      expect(r, 'x^2');
    });

    test('returns else-branch when condition folds to false', () async {
      final r = await ExpressionPreprocessingUtils.tryFoldIfConditional(
        'if(Eq(2, 3), x^2, x + 1)',
        falseEvaluator,
      );
      expect(r, 'x + 1');
    });

    test('returns null when condition stays symbolic', () async {
      final r = await ExpressionPreprocessingUtils.tryFoldIfConditional(
        'if(Eq(x, 5), x^2, x + 1)',
        symbolicEvaluator,
      );
      expect(r, isNull);
    });

    test('returns null for non-if input', () async {
      final r = await ExpressionPreprocessingUtils.tryFoldIfConditional(
        'x + 1',
        trueEvaluator,
      );
      expect(r, isNull);
    });

    test('returns null for wrong arg count', () async {
      // `if(c, t)` — missing else.
      final r = await ExpressionPreprocessingUtils.tryFoldIfConditional(
        'if(Eq(1, 1), x)',
        trueEvaluator,
      );
      expect(r, isNull);
    });

    test('refuses partial-span if(...)', () async {
      // `if(...) + 1` — the closing `)` doesn't match the outer
      // `if(` opening because the call ends before the final
      // character. We don't fold this; let SymEngine handle it
      // (and report the error).
      final r = await ExpressionPreprocessingUtils.tryFoldIfConditional(
        'if(Eq(2, 2), x^2, x + 1) + 1',
        trueEvaluator,
      );
      expect(r, isNull);
    });

    test('lowercase true / false from normalizer also folds', () async {
      // The normalizer in production turns `True` → `true`, but the
      // fold should match either form so callers passing through
      // already-normalized evaluators still work.
      Future<String> lowerTrue(String _) async => 'true';
      final r = await ExpressionPreprocessingUtils.tryFoldIfConditional(
        'if(c, t, e)',
        lowerTrue,
      );
      expect(r, 't');
    });

    test('whitespace tolerated around the call', () async {
      final r = await ExpressionPreprocessingUtils.tryFoldIfConditional(
        '  if(Eq(2, 2), x^2, x + 1)  ',
        trueEvaluator,
      );
      expect(r, 'x^2');
    });
  });
}
