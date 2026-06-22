// test/ocr_utils_test.dart
//
// Thorough edge-case tests for OCR utility functions:
//   - postProcessOcrText (Unicode normalization, misread correction)
//   - latexToEngineSyntax (LaTeX → engine syntax with OCR artifacts)

import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_calc/engine/ocr_provider.dart';

void main() {
  // ===========================================================================
  // postProcessOcrText — superscript handling
  // ===========================================================================
  group('postProcessOcrText — superscripts', () {
    test('x² + y³ → x^2 + y^3', () {
      expect(postProcessOcrText('x² + y³'), 'x^2 + y^3');
    });

    test('all superscript digits ⁰-⁹', () {
      expect(postProcessOcrText('a⁰b⁴c⁵d⁶e⁷f⁸g⁹'), 'a^0b^4c^5d^6e^7f^8g^9');
    });

    test('superscript n', () {
      expect(postProcessOcrText('xⁿ'), 'x^n');
    });

    test('multiple superscripts in sequence', () {
      expect(postProcessOcrText('x²y³z⁴'), 'x^2y^3z^4');
    });
  });

  // ===========================================================================
  // postProcessOcrText — operator replacement
  // ===========================================================================
  group('postProcessOcrText — operators', () {
    test('3×4÷2 → 3*4/2', () {
      expect(postProcessOcrText('3×4÷2'), '3*4/2');
    });

    test('middle dot → multiplication', () {
      expect(postProcessOcrText('a·b'), 'a*b');
    });

    test('minus sign U+2212 → hyphen-minus', () {
      expect(postProcessOcrText('5−3'), '5-3');
    });

    test('plus-minus sign', () {
      expect(postProcessOcrText('x±1'), 'x+/-1');
    });

    test('combined operators in expression', () {
      expect(postProcessOcrText('2×3 + 4÷2 − 1'), '2*3 + 4/2 - 1');
    });
  });

  // ===========================================================================
  // postProcessOcrText — Greek letters
  // ===========================================================================
  group('postProcessOcrText — Greek letters', () {
    test('π → pi', () {
      expect(postProcessOcrText('πr²'), 'pir^2');
    });

    test('alpha, beta, theta, lambda', () {
      expect(postProcessOcrText('α'), 'alpha');
      expect(postProcessOcrText('β'), 'beta');
      expect(postProcessOcrText('θ'), 'theta');
      expect(postProcessOcrText('λ'), 'lambda');
    });

    test('sigma sum and integral', () {
      expect(postProcessOcrText('Σ'), 'sum');
      expect(postProcessOcrText('∫'), 'integrate');
    });

    test('infinity', () {
      expect(postProcessOcrText('∞'), 'oo');
    });
  });

  // ===========================================================================
  // postProcessOcrText — square root
  // ===========================================================================
  group('postProcessOcrText — square root', () {
    test('√(16) → sqrt(16)', () {
      expect(postProcessOcrText('√(16)'), 'sqrt(16)');
    });

    test('√9 → sqrt(9)', () {
      expect(postProcessOcrText('√9'), 'sqrt(9)');
    });

    test('√(x+1) → sqrt(x+1)', () {
      expect(postProcessOcrText('√(x+1)'), 'sqrt(x+1)');
    });

    test('bare √ without argument → sqrt', () {
      expect(postProcessOcrText('√'), 'sqrt');
    });

    test('√ followed by multi-digit number', () {
      expect(postProcessOcrText('√25'), 'sqrt(25)');
    });
  });

  // ===========================================================================
  // postProcessOcrText — OCR misread correction
  // ===========================================================================
  group('postProcessOcrText — OCR misreads', () {
    test('1O1 → 101 (O between digits → 0)', () {
      expect(postProcessOcrText('1O1'), '101');
    });

    test('1O0 → 100', () {
      expect(postProcessOcrText('1O0'), '100');
    });

    test('O not replaced at word boundary', () {
      // O at start or end should not be replaced
      expect(postProcessOcrText('O + 1'), 'O + 1');
      expect(postProcessOcrText('1 + O'), '1 + O');
    });

    test('multiple O misreads in one string', () {
      expect(postProcessOcrText('1O0O1'), '10001');
    });
  });

  // ===========================================================================
  // postProcessOcrText — whitespace and edge cases
  // ===========================================================================
  group('postProcessOcrText — whitespace and edge cases', () {
    test('collapses multiple spaces', () {
      expect(postProcessOcrText('x   +   1'), 'x + 1');
    });

    test('trims leading/trailing whitespace', () {
      expect(postProcessOcrText('  x + 1  '), 'x + 1');
    });

    test('empty string', () {
      expect(postProcessOcrText(''), '');
    });

    test('only whitespace', () {
      expect(postProcessOcrText('   '), '');
    });

    test('plain ASCII passes through', () {
      expect(postProcessOcrText('2 + 3 * x'), '2 + 3 * x');
    });

    test('tabs and newlines treated as whitespace', () {
      expect(postProcessOcrText('x\t+\n1'), 'x + 1');
    });
  });

  // ===========================================================================
  // latexToEngineSyntax — BPE / delimiter stripping
  // ===========================================================================
  group('latexToEngineSyntax — preprocessing', () {
    test('strips BPE markers (U+0120)', () {
      expect(latexToEngineSyntax('\u0120x\u0120+\u01201'), 'x+1');
    });

    test('strips dollar delimiters', () {
      expect(latexToEngineSyntax(r'$x + 1$'), 'x+1');
      expect(latexToEngineSyntax(r'$$x^2$$'), 'x^2');
    });

    test(r'strips \[ \] delimiters', () {
      expect(latexToEngineSyntax(r'\[x^2\]'), 'x^2');
    });

    test(r'strips \( \) delimiters', () {
      expect(latexToEngineSyntax(r'\(x + 1\)'), 'x+1');
    });
  });

  // ===========================================================================
  // latexToEngineSyntax — formatting command stripping
  // ===========================================================================
  group('latexToEngineSyntax — formatting commands', () {
    test(r'\mathbf{x} → x', () {
      expect(latexToEngineSyntax(r'\mathbf{x}'), 'x');
    });

    test(r'\mathrm{sin} → sin', () {
      expect(latexToEngineSyntax(r'\mathrm{sin}'), 'sin');
    });

    test(r'\text{if} → if', () {
      expect(latexToEngineSyntax(r'\text{hello}'), 'hello');
    });

    test(r'nested formatting: \mathbf{\mathrm{x}} → x', () {
      expect(latexToEngineSyntax(r'\mathbf{\mathrm{x}}'), 'x');
    });

    test(r'\operatorname{lcm} → lcm', () {
      expect(latexToEngineSyntax(r'\operatorname{lcm}'), 'lcm');
    });

    test('spacing commands stripped', () {
      expect(latexToEngineSyntax(r'x \quad y'), 'x y');
      expect(latexToEngineSyntax(r'x \qquad y'), 'x y');
    });
  });

  // ===========================================================================
  // latexToEngineSyntax — fractions
  // ===========================================================================
  group('latexToEngineSyntax — fractions', () {
    test(r'simple \frac{a}{b} → (a)/(b)', () {
      expect(latexToEngineSyntax(r'\frac{a}{b}'), '(a)/(b)');
    });

    test('BTTR-style spaced braces', () {
      // BTTR/HMER outputs: \frac { a } { b }
      expect(latexToEngineSyntax(r'\frac { a } { b }'), '(a)/(b)');
    });

    test('nested fractions', () {
      final result = latexToEngineSyntax(r'\frac{\frac{1}{2}}{3}');
      expect(result, '((1)/(2))/(3)');
    });
  });

  // ===========================================================================
  // latexToEngineSyntax — roots
  // ===========================================================================
  group('latexToEngineSyntax — roots', () {
    test(r'\sqrt{x} → sqrt(x)', () {
      expect(latexToEngineSyntax(r'\sqrt{x}'), 'sqrt(x)');
    });

    test(r'\sqrt[3]{27} → (27)^(1/3)', () {
      expect(latexToEngineSyntax(r'\sqrt[3]{27}'), '(27)^(1/3)');
    });

    test(r'\sqrt{x^2 + 1}', () {
      expect(latexToEngineSyntax(r'\sqrt{x^2 + 1}'), 'sqrt(x^2+1)');
    });
  });

  // ===========================================================================
  // latexToEngineSyntax — special symbols and delimiters
  // ===========================================================================
  group('latexToEngineSyntax — symbols and delimiters', () {
    test('floor/ceil → parens', () {
      expect(latexToEngineSyntax(r'\lfloor x \rfloor'), '( x )');
      expect(latexToEngineSyntax(r'\lceil x \rceil'), '( x )');
    });

    test('angle brackets → parens', () {
      expect(latexToEngineSyntax(r'\langle x \rangle'), '( x )');
    });

    test(r'\mid → |', () {
      expect(latexToEngineSyntax(r'a \mid b'), 'a | b');
    });

    test(r'\prime → apostrophe', () {
      expect(latexToEngineSyntax(r"f\prime"), "f'");
    });

    test(r'\partial → d', () {
      expect(latexToEngineSyntax(r'\partial x'), 'd x');
    });

    test(r'\ell → l', () {
      expect(latexToEngineSyntax(r'\ell'), 'l');
    });
  });

  // ===========================================================================
  // latexToEngineSyntax — binom
  // ===========================================================================
  group('latexToEngineSyntax — binomial', () {
    test(r'\binom{n}{k} → binomial(n, k)', () {
      expect(latexToEngineSyntax(r'\binom{n}{k}'), 'binomial(n, k)');
    });

    test(r'\binom{5}{2} → binomial(5, 2)', () {
      expect(latexToEngineSyntax(r'\binom{5}{2}'), 'binomial(5, 2)');
    });

    test('nested binom', () {
      final result = latexToEngineSyntax(r'\binom{\binom{n}{2}}{k}');
      expect(result, 'binomial(binomial(n, 2), k)');
    });
  });

  // ===========================================================================
  // latexToEngineSyntax — arrows
  // ===========================================================================
  group('latexToEngineSyntax — arrows', () {
    test(r'\rightarrow maps to \to', () {
      final result = latexToEngineSyntax(r'x \rightarrow y');
      // \to is handled by fromLatex; should not contain backslash
      expect(result, isNot(contains(r'\')));
    });

    test(r'\Rightarrow → " -> "', () {
      final result = latexToEngineSyntax(r'A \Rightarrow B');
      expect(result, contains('->'));
    });

    test(r'\leftarrow → " -> "', () {
      final result = latexToEngineSyntax(r'A \leftarrow B');
      expect(result, contains('->'));
    });
  });

  // ===========================================================================
  // latexToEngineSyntax — extra Greek not in fromLatex
  // ===========================================================================
  group('latexToEngineSyntax — extra Greek', () {
    test(r'\epsilon → epsilon', () {
      expect(latexToEngineSyntax(r'\epsilon'), 'epsilon');
    });

    test(r'\tau → tau', () {
      expect(latexToEngineSyntax(r'\tau'), 'tau');
    });

    test(r'\psi → psi', () {
      expect(latexToEngineSyntax(r'\psi'), 'psi');
    });

    test(r'\chi → chi', () {
      expect(latexToEngineSyntax(r'\chi'), 'chi');
    });

    test(r'\Xi → Xi', () {
      expect(latexToEngineSyntax(r'\Xi'), 'Xi');
    });

    test(r'\kappa → kappa', () {
      expect(latexToEngineSyntax(r'\kappa'), 'kappa');
    });
  });

  // ===========================================================================
  // latexToEngineSyntax — dots
  // ===========================================================================
  group('latexToEngineSyntax — dots', () {
    test(r'\vdots → ...', () {
      expect(latexToEngineSyntax(r'\vdots'), '...');
    });

    test(r'\ddots → ...', () {
      expect(latexToEngineSyntax(r'\ddots'), '...');
    });
  });

  // ===========================================================================
  // latexToEngineSyntax — set notation
  // ===========================================================================
  group('latexToEngineSyntax — set notation', () {
    test(r'\in → in', () {
      expect(latexToEngineSyntax(r'x \in S'), 'x in S');
    });

    test(r'\notin → not in', () {
      expect(latexToEngineSyntax(r'x \notin S'), 'x not in S');
    });

    test(r'\subset → subset', () {
      expect(latexToEngineSyntax(r'A \subset B'), 'A subset B');
    });

    test(r'\in does not match \int or \infty', () {
      // \in should not corrupt \int
      final result = latexToEngineSyntax(r'\int x dx');
      expect(result, isNot(contains(' in ')));
    });
  });

  // ===========================================================================
  // latexToEngineSyntax — environments stripped
  // ===========================================================================
  group('latexToEngineSyntax — environments', () {
    test(r'\begin{array}...\end{array} stripped', () {
      final result =
          latexToEngineSyntax(r'\begin{array}{l} x \\ y \end{array}');
      expect(result, isNot(contains('begin')));
      expect(result, isNot(contains('end')));
      expect(result, isNot(contains(r'\\')));
    });

    test(r'\begin{matrix}...\end{matrix} stripped', () {
      final result = latexToEngineSyntax(r'\begin{matrix} a & b \end{matrix}');
      expect(result, isNot(contains('matrix')));
    });
  });

  // ===========================================================================
  // latexToEngineSyntax — decoration stripped
  // ===========================================================================
  group('latexToEngineSyntax — decoration stripped', () {
    test(r'\bullet stripped', () {
      expect(latexToEngineSyntax(r'\bullet x'), 'x');
    });

    test(r'\checkmark stripped', () {
      expect(latexToEngineSyntax(r'\checkmark'), '');
    });
  });

  // ===========================================================================
  // latexToEngineSyntax — catch-all backslash stripping
  // ===========================================================================
  group('latexToEngineSyntax — catch-all', () {
    test('remaining backslash commands stripped', () {
      final result = latexToEngineSyntax(r'\unknowncmd + 1');
      expect(result, isNot(contains(r'\')));
      expect(result, contains('+1'));
    });

    test('remaining braces → parens', () {
      expect(latexToEngineSyntax(r'f{x}'), 'f(x)');
    });

    test('empty input', () {
      expect(latexToEngineSyntax(''), '');
    });

    test('plain expression passes through', () {
      expect(latexToEngineSyntax('x + 1'), 'x+1');
    });
  });

  // ===========================================================================
  // latexToEngineSyntax — complex real-world OCR outputs
  // ===========================================================================
  group('latexToEngineSyntax — real-world OCR outputs', () {
    test('quadratic formula', () {
      final result =
          latexToEngineSyntax(r'\frac{-b \pm \sqrt{b^{2} - 4ac}}{2a}');
      expect(result, isNotEmpty);
      expect(result, isNot(contains(r'\')));
      expect(result, contains('sqrt'));
    });

    test('Euler identity', () {
      final result = latexToEngineSyntax(r'e^{i\pi} + 1 = 0');
      expect(result, isNotEmpty);
      expect(result, isNot(contains(r'\')));
      expect(result, contains('pi'));
    });

    test('integral with limits', () {
      final result = latexToEngineSyntax(r'\int_{0}^{1} x^2 dx');
      expect(result, isNotEmpty);
      expect(result, isNot(contains(r'\')));
    });

    test('summation', () {
      final result = latexToEngineSyntax(r'\sum_{i=1}^{n} i^2');
      expect(result, isNotEmpty);
      expect(result, isNot(contains(r'\')));
    });

    test('trig identity', () {
      final result = latexToEngineSyntax(r'\sin^{2}(x) + \cos^{2}(x) = 1');
      expect(result, isNotEmpty);
      expect(result, contains('sin'));
      expect(result, contains('cos'));
    });
  });
}
