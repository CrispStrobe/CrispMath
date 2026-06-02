// test/syntax_highlighting_test.dart
//
// Tests for the SyntaxHighlightingController's token pattern.

import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_calc/widgets/syntax_highlighting_controller.dart';

void main() {
  group('SyntaxHighlightingController', () {
    test('can be constructed with empty text', () {
      final c = SyntaxHighlightingController(text: '');
      expect(c.text, '');
      c.dispose();
    });

    test('can be constructed with math text', () {
      final c = SyntaxHighlightingController(text: 'sin(x) + 42');
      expect(c.text, 'sin(x) + 42');
      c.dispose();
    });

    test('setting text works', () {
      final c = SyntaxHighlightingController();
      c.text = 'solve(x^2 - 1, x)';
      expect(c.text, 'solve(x^2 - 1, x)');
      c.dispose();
    });
  });
}
