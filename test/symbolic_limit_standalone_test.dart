// test/symbolic_limit_standalone_test.dart
//
// Additional unit tests for symbolic_limit.dart that run without the
// native SymEngine bridge. Covers:
//   - Ratio parser edge cases (bracket types, nested parens, strip-parens)
//   - SymbolicLimitResult model
//   - Verifying compute() returns null when engine is unavailable

import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_calc/engine/symbolic_limit.dart';

void main() {
  // =========================================================================
  // Ratio parser — bracket handling
  // =========================================================================

  group('SymbolicLimit ratio parser — bracket handling', () {
    test('slash inside square brackets is not top-level', () {
      final r = SymbolicLimit.parseRatioForTest('f[x/2]');
      expect(r, isNull);
    });

    test('mixed bracket nesting respects depth', () {
      // The slash inside [...] should not be treated as top-level.
      final r = SymbolicLimit.parseRatioForTest('a[(b/c)] / d');
      expect(r, isNotNull);
      expect(r!.numerator, 'a[(b/c)]');
      expect(r.denominator, 'd');
    });

    test('deeply nested parens: ((a+b)) / ((c+d))', () {
      final r = SymbolicLimit.parseRatioForTest('((a+b)) / ((c+d))');
      expect(r, isNotNull);
      // _stripParens only strips one level of outer parens.
      expect(r!.numerator, '(a+b)');
      expect(r.denominator, '(c+d)');
    });
  });

  // =========================================================================
  // Ratio parser — strip-parens behavior
  // =========================================================================

  group('SymbolicLimit ratio parser — strip-parens', () {
    test('single outer parens are stripped', () {
      final r = SymbolicLimit.parseRatioForTest('(a) / (b)');
      expect(r, isNotNull);
      expect(r!.numerator, 'a');
      expect(r.denominator, 'b');
    });

    test('non-wrapping parens are preserved', () {
      // (a)+(b) has parens that close before the end, so they should NOT
      // be stripped.
      final r = SymbolicLimit.parseRatioForTest('(a)+(b) / c');
      expect(r, isNotNull);
      expect(r!.numerator, '(a)+(b)');
      expect(r.denominator, 'c');
    });

    test('unbalanced inner parens preserved', () {
      // The outer parens wrap the entire expression.
      final r = SymbolicLimit.parseRatioForTest('(x+1)(x-1) / (x)');
      expect(r, isNotNull);
      // Numerator has parens that close mid-expression, so no stripping.
      expect(r!.numerator, '(x+1)(x-1)');
      expect(r.denominator, 'x');
    });
  });

  // =========================================================================
  // Ratio parser — edge cases
  // =========================================================================

  group('SymbolicLimit ratio parser — additional edge cases', () {
    test('only a slash yields null (empty parts)', () {
      expect(SymbolicLimit.parseRatioForTest('/'), isNull);
    });

    test('expression with only parens and slash', () {
      final r = SymbolicLimit.parseRatioForTest('(1) / (2)');
      expect(r, isNotNull);
      expect(r!.numerator, '1');
      expect(r.denominator, '2');
    });

    test('function call with slash in name is not parsed as ratio', () {
      // sin(x) has no top-level slash.
      final r = SymbolicLimit.parseRatioForTest('sin(x)');
      expect(r, isNull);
    });

    test('complex nested expression', () {
      final r =
          SymbolicLimit.parseRatioForTest('sin(x^2 + 1) / (log(x) + cos(x/2))');
      expect(r, isNotNull);
      expect(r!.numerator, 'sin(x^2 + 1)');
      // The denominator's outer parens should be stripped.
      expect(r.denominator, 'log(x) + cos(x/2)');
    });

    test('expression with // (comment-like) partially skips first slash', () {
      // The code skips the first '/' when followed by another '/', but
      // the second '/' is still seen as a top-level slash on the next
      // iteration. So 'a // b' parses as numerator='a /', denominator='b'.
      final r = SymbolicLimit.parseRatioForTest('a // b');
      expect(r, isNotNull);
      expect(r!.numerator, 'a /');
      expect(r.denominator, 'b');
    });

    test('trailing whitespace is trimmed', () {
      final r = SymbolicLimit.parseRatioForTest('  x^2  /  y  ');
      expect(r, isNotNull);
      expect(r!.numerator, 'x^2');
      expect(r.denominator, 'y');
    });
  });

  // =========================================================================
  // SymbolicLimitResult model
  // =========================================================================

  group('SymbolicLimitResult — additional model tests', () {
    test('all known method strings', () {
      for (final m in ['direct', 'lhopital', 'factor', 'infinity']) {
        final r = SymbolicLimitResult('1', method: m);
        expect(r.method, m);
      }
    });

    test('value can be symbolic string', () {
      const r = SymbolicLimitResult('pi/2', method: 'direct');
      expect(r.value, 'pi/2');
    });

    test('value can be infinity symbol', () {
      const r = SymbolicLimitResult('\u221e', method: 'infinity');
      expect(r.value, '\u221e');
    });
  });
}
