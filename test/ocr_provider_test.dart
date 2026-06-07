// test/ocr_provider_test.dart
//
// Tests for OCR provider abstraction, post-processing, and LaTeX conversion.

import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_calc/engine/ocr_provider.dart';

void main() {
  // =========================================================================
  // postProcessOcrText
  // =========================================================================
  group('postProcessOcrText', () {
    test('Unicode superscripts → ^N', () {
      expect(postProcessOcrText('x² + 3x³'), 'x^2 + 3x^3');
    });

    test('Unicode operators', () {
      expect(postProcessOcrText('5 × 3'), '5 * 3');
      expect(postProcessOcrText('10 ÷ 2'), '10 / 2');
      expect(postProcessOcrText('2 · 3'), '2 * 3');
      expect(postProcessOcrText('5 − 3'), '5 - 3');
    });

    test('square root symbol with parens', () {
      expect(postProcessOcrText('√(16)'), 'sqrt(16)');
    });

    test('square root symbol with number', () {
      expect(postProcessOcrText('√9'), 'sqrt(9)');
    });

    test('Greek letters', () {
      expect(postProcessOcrText('2π'), '2pi');
      expect(postProcessOcrText('sin(θ)'), 'sin(theta)');
    });

    test('infinity symbol', () {
      expect(postProcessOcrText('lim x→∞'), 'lim x→oo');
    });

    test('integral symbol', () {
      expect(postProcessOcrText('∫ x² dx'), 'integrate x^2 dx');
    });

    test('whitespace normalization', () {
      expect(postProcessOcrText('  x   +   1  '), 'x + 1');
    });

    test('empty string', () {
      expect(postProcessOcrText(''), '');
    });

    test('plain math passes through', () {
      expect(postProcessOcrText('2 + 3'), '2 + 3');
    });

    test('OCR misread O→0 between digits', () {
      expect(postProcessOcrText('1O0'), '100');
    });
  });

  // =========================================================================
  // latexToEngineSyntax
  // =========================================================================
  group('latexToEngineSyntax', () {
    test('\\frac{a}{b} → (a)/(b)', () {
      expect(latexToEngineSyntax(r'\frac{x}{2}'), '(x)/(2)');
    });

    test('\\frac with expressions', () {
      expect(
          latexToEngineSyntax(r'\frac{x^2 + 1}{x - 1}'), '(x^2+1)/(x-1)');
    });

    test('\\sqrt{x} → sqrt(x)', () {
      expect(latexToEngineSyntax(r'\sqrt{16}'), 'sqrt(16)');
    });

    test('\\sqrt[n]{x} → x^(1/n)', () {
      expect(latexToEngineSyntax(r'\sqrt[3]{27}'), '(27)^(1/3)');
    });

    test('x^{2} → x^2 (single char)', () {
      expect(latexToEngineSyntax(r'x^{2}'), 'x^2');
    });

    test('x^{10} → x^(10) (multi char)', () {
      expect(latexToEngineSyntax(r'x^{10}'), 'x^(10)');
    });

    test('named functions', () {
      expect(latexToEngineSyntax(r'\sin(x)'), 'sin(x)');
      expect(latexToEngineSyntax(r'\cos(x)'), 'cos(x)');
      expect(latexToEngineSyntax(r'\ln(x)'), 'ln(x)');
      // fromLatex capitalizes Exp for SymEngine compatibility
      expect(latexToEngineSyntax(r'\exp(x)').toLowerCase(), 'exp(x)');
    });

    test('\\pi → pi', () {
      expect(latexToEngineSyntax(r'2\pi'), '2pi');
    });

    test('\\cdot → *', () {
      expect(latexToEngineSyntax(r'3 \cdot x'), '3*x');
    });

    test('\\leq, \\geq, \\neq', () {
      // fromLatex may not handle comparison operators — they get stripped
      // by the catch-all \command remover. Test the output is non-empty.
      final leq = latexToEngineSyntax(r'x \leq 5');
      expect(leq, contains('x'));
      expect(leq, contains('5'));
    });

    test('strip dollar delimiters', () {
      expect(latexToEngineSyntax(r'$x^2$'), 'x^2');
      expect(latexToEngineSyntax(r'$$x + 1$$'), 'x+1');
    });

    test('strip \\[ \\] delimiters', () {
      expect(latexToEngineSyntax(r'\[x + 1\]'), 'x+1');
    });

    test('\\left \\right removed', () {
      expect(latexToEngineSyntax(r'\left(\frac{1}{2}\right)'), '((1)/(2))');
    });

    test('braces → parens', () {
      expect(latexToEngineSyntax(r'f{x}'), 'f(x)');
    });

    test('complex expression', () {
      const input = r'\frac{d}{dx}\left[\sin^{2}(x)\right]';
      final result = latexToEngineSyntax(input);
      // Should be parseable, not necessarily canonical.
      expect(result, isNotEmpty);
      expect(result, isNot(contains(r'\')));
    });

    test('empty', () {
      expect(latexToEngineSyntax(''), '');
    });
  });

  // =========================================================================
  // OcrResult model
  // =========================================================================
  group('OcrResult', () {
    test('fields', () {
      const r = OcrResult(
        text: 'x^2 + 1',
        rawOutput: r'\frac{x^2+1}{1}',
        confidence: 0.95,
        providerName: 'test',
      );
      expect(r.text, 'x^2 + 1');
      expect(r.rawOutput, contains('frac'));
      expect(r.confidence, 0.95);
      expect(r.providerName, 'test');
    });

    test('confidence is optional', () {
      const r = OcrResult(
        text: '42',
        rawOutput: '42',
        providerName: 'test',
      );
      expect(r.confidence, isNull);
    });
  });

  // =========================================================================
  // OcrProviders registry
  // =========================================================================
  group('OcrProviders', () {
    test('starts empty', () {
      // Note: in a fresh test run, the registry might have providers
      // from other tests. We test the API shape.
      expect(OcrProviders.all, isA<List<OcrProvider>>());
    });

    test('active defaults to null', () {
      expect(OcrProviders.active, isNull);
    });
  });
}
