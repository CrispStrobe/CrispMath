// Unit tests for the piecewise fold (roadmap C5.4). The condition
// evaluator is mocked so these run headless; the end-to-end path through
// real SymEngine + a piecewise UDF is covered by the native integration
// test. The mock reads the lowered `Lt(a, b)` / `Gt(a, b)` form the fold
// produces and answers true/false, or returns the input unchanged to
// simulate a symbolic (unfoldable) condition.

import 'package:crisp_math/utils/expression_preprocessing_utils.dart';
import 'package:flutter_test/flutter_test.dart';

/// Evaluate a lowered relational like `Lt(-3, 0)` numerically.
Future<String> mockEval(String cond) async {
  final m = RegExp(r'^(Lt|Gt|Le|Ge|Eq|Ne)\((.+),\s*(.+)\)$')
      .firstMatch(cond.replaceAll(' ', ''));
  if (m == null) return cond; // stays symbolic
  final a =
      double.tryParse(m.group(2)!.replaceAll('(', '').replaceAll(')', ''));
  final b =
      double.tryParse(m.group(3)!.replaceAll('(', '').replaceAll(')', ''));
  if (a == null || b == null) return cond;
  final r = switch (m.group(1)!) {
    'Lt' => a < b,
    'Gt' => a > b,
    'Le' => a <= b,
    'Ge' => a >= b,
    'Eq' => a == b,
    'Ne' => a != b,
    _ => false,
  };
  return r ? 'true' : 'false';
}

Future<String?> fold(String input) =>
    ExpressionPreprocessingUtils.tryFoldPiecewise(input, mockEval);

void main() {
  group('tryFoldPiecewise', () {
    test('picks the first true branch', () async {
      expect(await fold('piecewise(-3 < 0, -3, 3)'), '-3');
      expect(await fold('piecewise(3 < 0, -3, 3)'), '3');
    });

    test('multiple branches, first match wins', () async {
      // sign(): piecewise(x<0, -1, x>0, 1, 0) with x = 5
      expect(await fold('piecewise(5 < 0, -1, 5 > 0, 1, 0)'), '1');
      expect(await fold('piecewise(-5 < 0, -1, -5 > 0, 1, 0)'), '-1');
    });

    test('else branch when no condition matches (odd arg count)', () async {
      expect(await fold('piecewise(0 < 0, -1, 0 > 0, 1, 0)'), '0');
    });

    test('no else and no match → null', () async {
      expect(await fold('piecewise(0 < 0, -1, 0 > 0, 1)'), isNull);
    });

    test('strips the paren wrap left by UDF inlining', () async {
      expect(await fold('(piecewise((-3) < 0, -3, 3))'), '-3');
    });

    test('non-piecewise input → null (left untouched)', () async {
      expect(await fold('2 + 3'), isNull);
      expect(await fold('sin(x)'), isNull);
      expect(await fold('if(x < 0, -x, x)'), isNull);
    });

    test('symbolic condition → null (not folded)', () async {
      // `x < 0` with x unbound stays symbolic → the mock returns it back.
      expect(await fold('piecewise(x < 0, -x, x)'), isNull);
    });

    test('branch value can be any expression', () async {
      expect(await fold('piecewise(1 < 2, sin(x) + 1, 0)'), 'sin(x) + 1');
    });
  });
}
