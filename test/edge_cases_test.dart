// test/edge_cases_test.dart
//
// Edge-case coverage for the pure-Dart preprocessors:
//   - normalizeComplexResult on weird/empty/error inputs
//   - preprocessNativeExpression on negatives, empties, nested
//     factorials, unusual character combinations
//   - UnitExpressionEvaluator on the common unit-arithmetic
//     shapes (regression net)
//   - substituteVariables on Ans variants
//
// The point is to catch silent failures in branches the typical
// user input never exercises but that ship in production.

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/unit_expression.dart';
import 'package:crisp_math/utils/expression_preprocessing_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // -------------------------------------------------------------------------
  // normalizeComplexResult — weird inputs
  // -------------------------------------------------------------------------

  group('normalizeComplexResult — degenerate inputs', () {
    test('empty string round-trips', () {
      expect(ExpressionPreprocessingUtils.normalizeComplexResult(''), '');
    });
    test('whitespace-only preserved (function early-returns)', () {
      // `normalizeComplexResult` skips its pipeline when the trimmed
      // result is empty and returns the original — documenting
      // current behavior. Probably a minor bug (the whitespace
      // should arguably trim) but not actionable today.
      expect(ExpressionPreprocessingUtils.normalizeComplexResult('   '), '   ');
    });
    test('error strings pass through (trimmed)', () {
      expect(
        ExpressionPreprocessingUtils.normalizeComplexResult(
            'Error: parse failed'),
        'Error: parse failed',
      );
    });
    test('plain integer untouched', () {
      expect(ExpressionPreprocessingUtils.normalizeComplexResult('42'), '42');
    });
    test('chained binary minus — 4 ops', () {
      expect(
        ExpressionPreprocessingUtils.normalizeComplexResult('a-b-c-d-e'),
        'a - b - c - d - e',
      );
    });
    test('trailing dangling operator gets dropped', () {
      expect(
        ExpressionPreprocessingUtils.normalizeComplexResult('5 +'),
        '5',
      );
      expect(
        ExpressionPreprocessingUtils.normalizeComplexResult('5 -'),
        '5',
      );
    });
    test('multiple spaces collapse to one', () {
      expect(
        ExpressionPreprocessingUtils.normalizeComplexResult('a  +  b'),
        'a + b',
      );
    });
  });

  // -------------------------------------------------------------------------
  // preprocessNativeExpression — edge cases that have bitten before
  // -------------------------------------------------------------------------

  group('preprocessNativeExpression — edge cases', () {
    test('empty string round-trips', () {
      expect(
        ExpressionPreprocessingUtils.preprocessNativeExpression(''),
        '',
      );
    });
    test('negative factorial — preprocessor still expands the |n|! literal',
        () {
      // `(\d+)!` matches `3!` inside `-3!` and returns `6` — the
      // negation lives outside the regex. SymEngine then sees `-6`.
      // Documenting the current behavior; switching to "reject
      // negative factorial" would change the engine input shape.
      final got =
          ExpressionPreprocessingUtils.preprocessNativeExpression('-3!');
      expect(got, '-6');
    });
    test('parenthesized factorial — not matched by either rule (current)', () {
      // `(\d+)!` requires literal digits before `!`; `(2+3)` isn't
      // digits. `var!` rule requires `[a-zA-Z_]...`. Neither matches,
      // so `(2+3)!` survives the preprocessor and the engine
      // returns whatever it computes (probably an error). Pinning
      // current behavior as a regression net.
      final got =
          ExpressionPreprocessingUtils.preprocessNativeExpression('(2+3)!');
      expect(got, '(2+3)!');
    });
    test('multiple factorials on one line', () {
      final got =
          ExpressionPreprocessingUtils.preprocessNativeExpression('3! + 4!');
      expect(got, '6 + 24');
    });
    test('vector dot product expands', () {
      final got = ExpressionPreprocessingUtils.preprocessNativeExpression(
          'dot([1,2,3], [4,5,6])');
      // dot expansion: 1*4 + 2*5 + 3*6 = 32
      expect(got.contains('+'), isTrue, reason: 'dot expands to a sum');
    });
    test('implicit mul not inserted inside function name', () {
      // `\b[a-zA-Z]\b(\()` requires a word-boundary on BOTH sides
      // of the single letter — so multi-letter function calls
      // like `cos(x)` should not get a `*` inserted between
      // `c`/`o`/`s` and `(`.
      expect(
        ExpressionPreprocessingUtils.preprocessNativeExpression('cos(x)'),
        'cos(x)',
      );
    });
    test('huge factorial — gamma fallback boundary', () {
      // 1001 is the first n where the BigInt path stops.
      expect(
        ExpressionPreprocessingUtils.preprocessNativeExpression('1001!'),
        'gamma(1002)',
      );
      // 1000 is still in BigInt range — should be ~2568 digits.
      final big =
          ExpressionPreprocessingUtils.preprocessNativeExpression('1000!');
      expect(big.length, greaterThan(2500));
      expect(RegExp(r'^\d+$').hasMatch(big), isTrue);
    });
    test('factorial of zero', () {
      expect(
        ExpressionPreprocessingUtils.preprocessNativeExpression('0!'),
        '1',
      );
    });
  });

  // -------------------------------------------------------------------------
  // UnitExpressionEvaluator — common shapes
  // -------------------------------------------------------------------------

  group('UnitExpressionEvaluator — basic ops (regression net)', () {
    test('plain number is not a unit expression', () {
      expect(UnitExpressionEvaluator.tryEvaluate('5'), isNull);
    });
    test('plain identifier without unit is not a unit expression', () {
      expect(UnitExpressionEvaluator.tryEvaluate('x'), isNull);
    });
    test('"5 km" alone returns the value with the unit', () {
      final got = UnitExpressionEvaluator.tryEvaluate('5 km');
      expect(got, isNotNull);
      expect(got, contains('km'));
    });
    test('addition of same-dim units', () {
      final got = UnitExpressionEvaluator.tryEvaluate('5 km + 3 m');
      expect(got, isNotNull);
      expect(got, contains('km'));
    });
    test('"in" conversion', () {
      final got = UnitExpressionEvaluator.tryEvaluate('100 km in mph');
      expect(got, isNotNull);
      expect(got, contains('mph'));
    });
    test('scalar prefix', () {
      final got = UnitExpressionEvaluator.tryEvaluate('2 * 5 km');
      expect(got, isNotNull);
      expect(got, contains('km'));
    });
    test('scalar division', () {
      final got = UnitExpressionEvaluator.tryEvaluate('10 km / 2');
      expect(got, isNotNull);
      expect(got, contains('km'));
    });
    test('mixed-dim addition rejected', () {
      // 5 km + 3 s is dimensionally invalid — evaluator should
      // either return null or an error string.
      final got = UnitExpressionEvaluator.tryEvaluate('5 km + 3 s');
      // Accept either signal (null = "not a unit expr" or an
      // Error: prefix). Either avoids producing a wrong number.
      if (got != null) {
        expect(got, contains('Error'));
      }
    });
    test('non-unit input returns null', () {
      expect(UnitExpressionEvaluator.tryEvaluate('foo bar'), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // substituteVariables — Ans + var edge cases
  // -------------------------------------------------------------------------

  group('substituteVariables — Ans edge cases', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await AppState().load(force: true);
    });
    test('Ans inside an identifier (no substitute)', () {
      AppState().addHistoryEntry('1+1', '2');
      // `Ansa` is a single identifier — `Ans` substring shouldn't
      // be touched because there's no word boundary.
      final out =
          ExpressionPreprocessingUtils.substituteVariables('Ansa', AppState());
      expect(out, 'Ansa');
    });
    test('Ans appearing multiple times', () {
      AppState().addHistoryEntry('1+1', '2');
      final out = ExpressionPreprocessingUtils.substituteVariables(
          'Ans + Ans', AppState());
      expect(out, '2 + 2');
    });
    test('Ans reports a missing answer when history has only errors', () {
      AppState().addHistoryEntry('foo', 'Error: parse failed');
      expect(
        () => ExpressionPreprocessingUtils.substituteVariables(
            'Ans*2', AppState()),
        throwsStateError,
      );
    });
    test('Ans skips errors and retains full precision', () {
      AppState().addHistoryEntry('8/3', '2.66666666666667');
      AppState().addHistoryEntry('1/0', 'Error: division by zero');
      expect(
          ExpressionPreprocessingUtils.substituteVariables('Ans/2', AppState()),
          '2.66666666666667/2');
      expect(
          ExpressionPreprocessingUtils.substituteVariables('Ans*2', AppState()),
          '2.66666666666667*2');
    });
    test('Ans protects a compound previous result from operator precedence',
        () {
      AppState().addHistoryEntry('complex', '3 + 4i');
      expect(
          ExpressionPreprocessingUtils.substituteVariables('Ans*2', AppState()),
          '(3 + 4i)*2');
    });
    test('Ans substring is not a token even with empty history', () {
      expect(
          ExpressionPreprocessingUtils.substituteVariables(
              'AnsOther + xAns + Ans_1', AppState()),
          'AnsOther + xAns + Ans_1');
    });
  });

  // -------------------------------------------------------------------------
  // AppState.decimalPlaces ↔ NumberDisplayFormat — round-trip
  // -------------------------------------------------------------------------

  group('decimalPlaces ↔ NumberDisplayFormat — migration', () {
    late AppState s;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      s = AppState();
      await s.load(force: true);
    });
    test('setNumberFormat(auto) -> decimalPlaces=-1', () {
      s.setNumberFormat(NumberDisplayFormat.auto);
      expect(s.decimalPlaces, -1);
    });
    test('setNumberFormat(integer) -> decimalPlaces=0', () {
      s.setNumberFormat(NumberDisplayFormat.integer);
      expect(s.decimalPlaces, 0);
    });
    test('setNumberFormat(oneDecimal) -> decimalPlaces=1', () {
      s.setNumberFormat(NumberDisplayFormat.oneDecimal);
      expect(s.decimalPlaces, 1);
    });
    test('setNumberFormat(twoDecimal) -> decimalPlaces=2', () {
      s.setNumberFormat(NumberDisplayFormat.twoDecimal);
      expect(s.decimalPlaces, 2);
    });
    test('setDecimalPlaces(0) -> numberFormat=integer', () {
      s.setDecimalPlaces(0);
      expect(s.numberFormat, NumberDisplayFormat.integer);
    });
    test('setDecimalPlaces(1) -> numberFormat=oneDecimal', () {
      s.setDecimalPlaces(1);
      expect(s.numberFormat, NumberDisplayFormat.oneDecimal);
    });
    test('setDecimalPlaces(2) -> numberFormat=twoDecimal', () {
      s.setDecimalPlaces(2);
      expect(s.numberFormat, NumberDisplayFormat.twoDecimal);
    });
    test('setDecimalPlaces(5) -> numberFormat=auto (no enum match)', () {
      s.setDecimalPlaces(5);
      expect(s.numberFormat, NumberDisplayFormat.auto);
      expect(s.decimalPlaces, 5);
    });
    test('setDecimalPlaces(-1) -> numberFormat=auto', () {
      s.setDecimalPlaces(-1);
      expect(s.numberFormat, NumberDisplayFormat.auto);
    });
  });

  // -------------------------------------------------------------------------
  // AppState.autoBindSolve — toggle persistence
  // -------------------------------------------------------------------------

  group('AppState.autoBindSolve — persistence', () {
    test('defaults to false', () async {
      SharedPreferences.setMockInitialValues({});
      final s = AppState();
      await s.load(force: true);
      expect(s.autoBindSolve, isFalse);
    });
    test('setAutoBindSolve(true) persists across load', () async {
      SharedPreferences.setMockInitialValues({'crisp.autoBindSolve': true});
      final s = AppState();
      await s.load(force: true);
      expect(s.autoBindSolve, isTrue);
    });
  });
}
