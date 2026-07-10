import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_math/utils/latex_conversion_utils.dart';

void main() {
  group('fromLatex — roots and fractions', () {
    test('\\sqrt{x} -> sqrt(x)', () {
      expect(
          LatexConversionUtils.fromLatex(r'\sqrt{x+1}'), equals('sqrt(x+1)'));
    });

    test('\\sqrt[3]{x} -> (x)^(1/3)', () {
      expect(
          LatexConversionUtils.fromLatex(r'\sqrt[3]{x}'), equals('(x)^(1/3)'));
    });

    test('\\frac{a}{b} -> (a)/(b)', () {
      expect(LatexConversionUtils.fromLatex(r'\frac{a}{b}'), equals('(a)/(b)'));
    });
  });

  group('fromLatex — trig and inverse trig', () {
    test('plain function braces unwrap', () {
      expect(LatexConversionUtils.fromLatex(r'\sin{x}'), equals('sin(x)'));
      expect(LatexConversionUtils.fromLatex(r'\cos{x}'), equals('cos(x)'));
    });

    test('arc-prefix maps to a-prefix', () {
      expect(LatexConversionUtils.fromLatex(r'\arcsin{x}'), equals('asin(x)'));
      expect(LatexConversionUtils.fromLatex(r'\arctan{x}'), equals('atan(x)'));
    });

    test('hyperbolic and inverse hyperbolic', () {
      expect(LatexConversionUtils.fromLatex(r'\sinh{x}'), equals('sinh(x)'));
      expect(LatexConversionUtils.fromLatex(r'\asinh{x}'), equals('asinh(x)'));
    });

    test('function-paren forms strip the backslash', () {
      expect(LatexConversionUtils.fromLatex(r'\sin(x)'), equals('sin(x)'));
    });

    test('bare-argument \\sin x (CROHME style)', () {
      expect(LatexConversionUtils.fromLatex(r'\sin x'), equals('sin(x)'));
      expect(LatexConversionUtils.fromLatex(r'\cos x'), equals('cos(x)'));
    });
  });

  group('fromLatex — logs', () {
    test('\\ln{x} and \\log{x}', () {
      expect(LatexConversionUtils.fromLatex(r'\ln{x}'), equals('ln(x)'));
      expect(LatexConversionUtils.fromLatex(r'\log{x}'), equals('log(x)'));
    });

    test('logarithm with base', () {
      expect(
        LatexConversionUtils.fromLatex(r'\log_{2}{8}'),
        equals('log(8)/log(2)'),
      );
    });

    test('bare-argument \\log x and \\ln x', () {
      expect(LatexConversionUtils.fromLatex(r'\log x'), equals('log(x)'));
      expect(LatexConversionUtils.fromLatex(r'\ln x'), equals('ln(x)'));
    });

    test('\\log_{base} bare arg (CROHME style)', () {
      expect(
        LatexConversionUtils.fromLatex(r'\log_{a} x'),
        equals('log(x)/log(a)'),
      );
    });
  });

  group('fromLatex — powers and subscripts', () {
    test('single-char power keeps braces off', () {
      expect(LatexConversionUtils.fromLatex(r'x^{2}'), equals('x^2'));
    });

    test('multi-char power keeps parens', () {
      expect(LatexConversionUtils.fromLatex(r'x^{2y}'), equals('x^(2y)'));
    });

    test('subscript braces collapse', () {
      expect(LatexConversionUtils.fromLatex(r'x_{1}'), equals('x_1'));
    });
  });

  group('fromLatex — constants and symbols', () {
    test('\\pi -> pi', () {
      expect(LatexConversionUtils.fromLatex(r'2\pi r'), contains('pi'));
    });

    test('\\infty -> oo', () {
      expect(LatexConversionUtils.fromLatex(r'\infty'), equals('oo'));
    });

    test('\\cdot, \\times -> *', () {
      expect(LatexConversionUtils.fromLatex(r'2 \cdot x'), equals('2*x'));
      expect(LatexConversionUtils.fromLatex(r'2 \times x'), equals('2*x'));
    });
  });

  group('fromLatex — integrals and limits', () {
    test('indefinite integral', () {
      expect(
        LatexConversionUtils.fromLatex(r'\int x dx'),
        equals('integrate(x, x)'),
      );
    });

    test('definite integral', () {
      final out = LatexConversionUtils.fromLatex(r'\int_{0}^{1} x dx');
      expect(out, equals('integrate(x, (x, 0, 1))'));
    });

    test('basic limit', () {
      final out = LatexConversionUtils.fromLatex(r'\lim_{x \to 0} sin(x)/x');
      expect(out, equals('limit(sin(x)/x, x, 0)'));
    });

    test('limit with \\rightarrow (CROHME style)', () {
      final out =
          LatexConversionUtils.fromLatex(r'\lim_{x \rightarrow 0} f(x)');
      expect(out, equals('limit(f(x), x, 0)'));
    });

    test('limit to +infinity', () {
      final out = LatexConversionUtils.fromLatex(r'\lim_{x \to +\infty} f(x)');
      expect(out, contains('oo'));
      expect(out, contains('limit'));
    });

    test('limit to -infinity', () {
      final out = LatexConversionUtils.fromLatex(r'\lim_{x \to -\infty} f(x)');
      expect(out, equals('limit(f(x), x,-oo)'));
    });

    test('directional limit from right', () {
      final out = LatexConversionUtils.fromLatex(r'\lim_{x \to 0^+} f(x)');
      expect(out, equals("limit(f(x), x, 0, '+')"));
    });

    test('directional limit from left', () {
      final out = LatexConversionUtils.fromLatex(r'\lim_{x \to 0^-} f(x)');
      expect(out, equals("limit(f(x), x, 0, '-')"));
    });
  });

  group('fromLatex — absolute value and norms', () {
    test('|x| -> abs(x)', () {
      expect(LatexConversionUtils.fromLatex(r'|x+1|'), equals('abs(x+1)'));
    });

    test('||x|| double-pipe norm -> abs(x)', () {
      expect(LatexConversionUtils.fromLatex('||x||'), equals('abs(x)'));
    });

    test('\\|x\\| LaTeX norm -> abs(x)', () {
      expect(LatexConversionUtils.fromLatex(r'\|x\|'), equals('abs(x)'));
    });
  });

  // Note: pipe characters used to be unconditionally stripped (under the
  // assumption that they were cursor markers from textWithCursor). That broke
  // |x| -> abs(x). Pipes are now content; the cursor marker lives in the
  // controller's selection state, not in the text itself.

  // =========================================================================
  // Differentiation (d/dx)
  // =========================================================================

  group('fromLatex — differentiation', () {
    test('\\frac{d}{dx} with bare parens', () {
      expect(
        LatexConversionUtils.fromLatex(r'\frac{d}{dx}(x^2)'),
        equals('d/dx(x^2)'),
      );
    });

    test('\\frac{d}{dy} with braces', () {
      expect(
        LatexConversionUtils.fromLatex(r'\frac{d}{dy}{y^3}'),
        equals('d/dy(y^3)'),
      );
    });

    test('second-order derivative d²y/dx²', () {
      expect(
        LatexConversionUtils.fromLatex(r'\frac{d^2 y}{dx^2}'),
        equals('diff(diff(y, x), x)'),
      );
    });

    test('second-order derivative with trailing expr', () {
      expect(
        LatexConversionUtils.fromLatex(r'\frac{d^2}{dx^2} f(x)'),
        equals('diff(diff(f(x), x), x)'),
      );
    });

    test('third-order derivative', () {
      expect(
        LatexConversionUtils.fromLatex(r'\frac{d^3 y}{dx^3}'),
        equals('diff(diff(diff(y, x), x), x)'),
      );
    });
  });

  // =========================================================================
  // Sized delimiters
  // =========================================================================

  group('fromLatex — sized delimiters', () {
    test('\\left( and \\right) are stripped', () {
      expect(
        LatexConversionUtils.fromLatex(r'\left(x+1\right)'),
        equals('(x+1)'),
      );
    });

    test('\\bigg( and \\bigg) are stripped', () {
      expect(
        LatexConversionUtils.fromLatex(r'\bigg(a+b\bigg)'),
        equals('(a+b)'),
      );
    });

    test('\\left[ and \\right] are stripped', () {
      expect(
        LatexConversionUtils.fromLatex(r'\left[x\right]'),
        equals('[x]'),
      );
    });

    test('\\left\\{ and \\right\\} are stripped', () {
      expect(
        LatexConversionUtils.fromLatex(r'\left\{x\right\}'),
        equals('{x}'),
      );
    });

    test('sized delimiter with space before bracket is normalized', () {
      // \\bigg ( with a space should be collapsed to \\bigg( then stripped.
      expect(
        LatexConversionUtils.fromLatex(r'\bigg (x\bigg )'),
        equals('(x)'),
      );
    });
  });

  // =========================================================================
  // Greek letters and constants
  // =========================================================================

  group('fromLatex — Greek letters and constants', () {
    test('\\e -> E', () {
      expect(LatexConversionUtils.fromLatex(r'\e'), equals('E'));
    });

    test('\\gamma -> EulerGamma', () {
      expect(LatexConversionUtils.fromLatex(r'\gamma'), equals('EulerGamma'));
    });

    test('\\Gamma -> gamma', () {
      expect(LatexConversionUtils.fromLatex(r'\Gamma'), equals('gamma'));
    });

    test('\\alpha -> alpha', () {
      expect(LatexConversionUtils.fromLatex(r'\alpha'), equals('alpha'));
    });

    test('\\theta -> theta', () {
      expect(LatexConversionUtils.fromLatex(r'\theta'), equals('theta'));
    });

    test('\\lambda -> lambda', () {
      expect(LatexConversionUtils.fromLatex(r'\lambda'), equals('lambda'));
    });

    test('\\omega -> omega', () {
      expect(LatexConversionUtils.fromLatex(r'\omega'), equals('omega'));
    });

    test('\\infinity -> oo', () {
      expect(LatexConversionUtils.fromLatex(r'\infinity'), equals('oo'));
    });
  });

  // =========================================================================
  // Operators
  // =========================================================================

  group('fromLatex — operators', () {
    test('\\div -> /', () {
      expect(LatexConversionUtils.fromLatex(r'a \div b'), equals('a/b'));
    });

    test('\\ast -> *', () {
      expect(LatexConversionUtils.fromLatex(r'a \ast b'), equals('a*b'));
    });

    test('\\pm -> +-', () {
      expect(LatexConversionUtils.fromLatex(r'a \pm b'), equals('a+-b'));
    });

    test('\\mp -> -+', () {
      expect(LatexConversionUtils.fromLatex(r'a \mp b'), equals('a-+b'));
    });

    test('\\bmod -> mod', () {
      expect(LatexConversionUtils.fromLatex(r'a \bmod b'), equals('a mod b'));
    });

    test('\\leq -> <=', () {
      expect(LatexConversionUtils.fromLatex(r'x \leq 5'), equals('x <= 5'));
    });

    test('\\geq -> >=', () {
      expect(LatexConversionUtils.fromLatex(r'x \geq 0'), equals('x >= 0'));
    });

    test('\\neq -> !=', () {
      expect(LatexConversionUtils.fromLatex(r'x \neq 1'), equals('x != 1'));
    });

    test('\\le and \\ge short forms', () {
      expect(LatexConversionUtils.fromLatex(r'x \le 5'), equals('x <= 5'));
      expect(LatexConversionUtils.fromLatex(r'x \ge 0'), equals('x >= 0'));
    });

    test('\\approx -> ≈', () {
      expect(LatexConversionUtils.fromLatex(r'x \approx 3'), equals('x ≈ 3'));
    });
  });

  // =========================================================================
  // Summation and product
  // =========================================================================

  group('fromLatex — summation and product', () {
    test('summation', () {
      final out = LatexConversionUtils.fromLatex(r'\sum_{i=1}^{10} i^2');
      expect(out, equals('Sum(i^2, (i, 1, 10))'));
    });

    test('product', () {
      final out = LatexConversionUtils.fromLatex(r'\prod_{k=1}^{n} k');
      expect(out, equals('Product(k, (k, 1, n))'));
    });

    test('sum without upper limit defaults to oo', () {
      final out = LatexConversionUtils.fromLatex(r'\sum_{i=1} a_i');
      expect(out, equals('Sum(a_i, (i, 1, oo))'));
    });

    test('sum with variable only', () {
      final out = LatexConversionUtils.fromLatex(r'\sum_{i} x_i');
      expect(out, equals('Sum(x_i, i)'));
    });

    test('product without upper limit defaults to oo', () {
      final out = LatexConversionUtils.fromLatex(r'\prod_{k=1} a_k');
      expect(out, equals('Product(a_k, (k, 1, oo))'));
    });
  });

  // =========================================================================
  // Spacing cleanup
  // =========================================================================

  group('fromLatex — spacing cleanup', () {
    test('multiple spaces collapse to single space', () {
      expect(
        LatexConversionUtils.fromLatex('a   b'),
        equals('a b'),
      );
    });

    test('spaces around operators are removed', () {
      expect(
        LatexConversionUtils.fromLatex('a + b * c'),
        equals('a+b*c'),
      );
    });
  });

  // =========================================================================
  // latexToReadable — additional coverage
  // =========================================================================

  group('latexToReadable', () {
    test('\\cdot back to *', () {
      expect(LatexConversionUtils.latexToReadable(r'2\cdot x'), equals('2*x'));
    });

    test('\\frac{a}{b} back to parenthesized fraction', () {
      expect(
        LatexConversionUtils.latexToReadable(r'\frac{a}{b}'),
        equals('(a)/(b)'),
      );
    });

    test('strips function backslashes', () {
      expect(LatexConversionUtils.latexToReadable(r'\sin'), equals('sin'));
    });

    test('\\times back to *', () {
      expect(LatexConversionUtils.latexToReadable(r'2\times x'), equals('2*x'));
    });

    test('\\div back to /', () {
      expect(LatexConversionUtils.latexToReadable(r'a\div b'), equals('a/b'));
    });

    test('sized delimiters stripped in readable output', () {
      expect(
        LatexConversionUtils.latexToReadable(r'\left(x\right)'),
        equals('(x)'),
      );
      expect(
        LatexConversionUtils.latexToReadable(r'\bigg(a\bigg)'),
        equals('(a)'),
      );
    });

    test('\\ln and \\log stripped', () {
      expect(LatexConversionUtils.latexToReadable(r'\ln'), equals('ln'));
      expect(LatexConversionUtils.latexToReadable(r'\log'), equals('log'));
    });
  });
}
