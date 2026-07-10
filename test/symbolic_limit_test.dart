// test/symbolic_limit_test.dart
//
// Unit tests for the pure-Dart symbolic limit engine.
// These run without the native bridge — they test the ratio parser
// and the result model.

import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_math/engine/symbolic_limit.dart';

void main() {
  group('SymbolicLimit ratio parser', () {
    test('parses simple ratio a/b', () {
      final r = SymbolicLimit.parseRatioForTest('x^2 / (x - 1)');
      expect(r, isNotNull);
      expect(r!.numerator, 'x^2');
      expect(r.denominator, 'x - 1');
    });

    test('parses ratio with outer parens on numerator', () {
      final r = SymbolicLimit.parseRatioForTest('(x^2 - 1) / (x - 1)');
      expect(r, isNotNull);
      expect(r!.numerator, 'x^2 - 1');
      expect(r.denominator, 'x - 1');
    });

    test('rejects expression without top-level slash', () {
      final r = SymbolicLimit.parseRatioForTest('x^2 + 1');
      expect(r, isNull);
    });

    test('rejects multiple top-level slashes', () {
      final r = SymbolicLimit.parseRatioForTest('a / b / c');
      expect(r, isNull);
    });

    test('slash inside parens is not top-level', () {
      final r = SymbolicLimit.parseRatioForTest('sin(x/2)');
      expect(r, isNull);
    });

    test('parses deeply nested numerator/denominator', () {
      final r =
          SymbolicLimit.parseRatioForTest('(sin(x) + cos(x)) / (x^2 + 1)');
      expect(r, isNotNull);
      expect(r!.numerator, 'sin(x) + cos(x)');
      expect(r.denominator, 'x^2 + 1');
    });

    test('handles whitespace around slash', () {
      final r = SymbolicLimit.parseRatioForTest('  a  /  b  ');
      expect(r, isNotNull);
      expect(r!.numerator, 'a');
      expect(r.denominator, 'b');
    });

    test('empty parts rejected', () {
      expect(SymbolicLimit.parseRatioForTest('/x'), isNull);
      expect(SymbolicLimit.parseRatioForTest('x/'), isNull);
    });
  });

  group('SymbolicLimitResult', () {
    test('carries value and method', () {
      const r = SymbolicLimitResult('42', method: 'direct');
      expect(r.value, '42');
      expect(r.method, 'direct');
    });

    test('method is optional', () {
      const r = SymbolicLimitResult('0');
      expect(r.method, isNull);
    });
  });
}
