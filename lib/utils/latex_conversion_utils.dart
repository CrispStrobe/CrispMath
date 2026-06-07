// lib/utils/latex_conversion_utils.dart
//
// LaTeX <-> engine-syntax conversion. The keypad inserts LaTeX commands;
// SymEngine wants plain operator syntax. Pure-Dart, no IO.

class LatexConversionUtils {
  /// Converts the LaTeX string from the input field to SymEngine-compatible syntax.
  static String fromLatex(String latex) {
    String result = latex;

    // === STEP 1: Handle complex structures first (order matters!) ===

    // Handle nth roots: \sqrt[n]{expr} -> (expr)^(1/n)
    result =
        result.replaceAllMapped(RegExp(r'\\sqrt\[([^\]]+)\]\{([^}]+)\}'), (m) {
      final n = m.group(1)!;
      final expr = m.group(2)!;
      return '($expr)^(1/$n)';
    });

    // Handle square roots: \sqrt{expr} -> sqrt(expr)
    result = result.replaceAllMapped(RegExp(r'\\sqrt\{([^}]+)\}'), (m) {
      return 'sqrt(${m.group(1)})';
    });

    // Sized-delimiter normalization — LaTeX accepts `\bigg (` or
    // `\bigg(` interchangeably (command + optional whitespace +
    // argument), and the LatexController sometimes stores the
    // form-with-space. Collapse the optional space FIRST so the
    // d/dx detection patterns below can use plain literals.
    result = result.replaceAllMapped(
      RegExp(
          r'\\(left|right|big|Big|bigg|Bigg|bigl|bigr|Bigl|Bigr|biggl|biggr|Biggl|Biggr)\s+(?=[(){}\[\]])'),
      (m) => '\\${m[1]!}',
    );

    // Differentiation detection MUST run before the generic
    // `\frac{num}{den}` rewrite below — otherwise `\frac{d}{dx}`
    // collapses into `(d)/(dx)` and the d/dx pattern never gets a
    // chance to match. Try the sized-delimiter forms first, then
    // bare parens / braces.
    final dPatterns = ['left', 'Big', 'bigg', 'Bigg', 'Bigl', 'Bigr'];
    for (final p in dPatterns) {
      final close = p == 'left' ? 'right' : (p == 'Bigl' ? 'Bigr' : p);
      result = result.replaceAllMapped(
        RegExp('\\\\frac\\{d\\}\\{d([a-zA-Z])\\}\\\\$p\\((.*?)\\\\$close\\)'),
        (m) => 'd/d${m.group(1)}(${m.group(2)})',
      );
    }
    // Higher-order derivatives: \frac{d^n f}{dx^n} → diff(diff(...f, x), x)
    // Must run before first-order and generic fraction rules.
    result = result.replaceAllMapped(
        RegExp(
            r'\\frac\{d\^(\d+)\s*([a-zA-Z]?)\}\{d([a-zA-Z])\^(\d+)\}\s*(.*)'),
        (m) {
      final order = int.tryParse(m.group(1)!) ?? 2;
      final funcInNum = m.group(2)!; // e.g. "y" from d^2y
      final variable = m.group(3)!;
      final trailing = m.group(5)!.trim();
      // The function is either in the numerator (d^2y) or trailing (d^2/dx^2 f(x))
      final func = funcInNum.isNotEmpty ? funcInNum : trailing;
      var expr = func;
      for (var i = 0; i < order; i++) {
        expr = 'diff($expr, $variable)';
      }
      // If func came from trailing, consume it; otherwise keep trailing
      if (funcInNum.isNotEmpty && trailing.isNotEmpty) {
        return '$expr $trailing';
      }
      return expr;
    });

    // Bare-paren and braced forms (manually typed or older keypad
    // emissions).
    result = result.replaceAllMapped(
        RegExp(r'\\frac\{d\}\{d([a-zA-Z])\}\(([^)]+)\)'), (m) {
      return 'd/d${m.group(1)}(${m.group(2)})';
    });
    result = result.replaceAllMapped(
        RegExp(r'\\frac\{d\}\{d([a-zA-Z])\}\{([^}]+)\}'), (m) {
      return 'd/d${m.group(1)}(${m.group(2)})';
    });

    // NOW the generic fraction rewrite — any remaining `\frac{a}{b}`
    // wasn't a derivative pattern, so safe to fold into `(a)/(b)`.
    result =
        result.replaceAllMapped(RegExp(r'\\frac\{([^}]+)\}\{([^}]+)\}'), (m) {
      return '(${m.group(1)})/(${m.group(2)})';
    });

    // Generic sized-delimiter strip — keep just the underlying
    // bracket character. Covers anything pasted in or future
    // templates that use the LaTeX sizing commands.
    result = result.replaceAll(r'\left(', '(').replaceAll(r'\right)', ')');
    result = result.replaceAll(r'\left[', '[').replaceAll(r'\right]', ']');
    result = result.replaceAll(r'\left\{', '{').replaceAll(r'\right\}', '}');
    result = result
        .replaceAll(r'\bigl(', '(')
        .replaceAll(r'\bigr)', ')')
        .replaceAll(r'\Bigl(', '(')
        .replaceAll(r'\Bigr)', ')')
        .replaceAll(r'\biggl(', '(')
        .replaceAll(r'\biggr)', ')')
        .replaceAll(r'\Biggl(', '(')
        .replaceAll(r'\Biggr)', ')')
        .replaceAll(r'\big(', '(')
        .replaceAll(r'\big)', ')')
        .replaceAll(r'\Big(', '(')
        .replaceAll(r'\Big)', ')')
        .replaceAll(r'\bigg(', '(')
        .replaceAll(r'\bigg)', ')')
        .replaceAll(r'\Bigg(', '(')
        .replaceAll(r'\Bigg)', ')');

    // === STEP 2: Handle function notation with braces ===

    // Trig power with parens: \sin^{n}(expr) -> sin(expr)^n
    result = result.replaceAllMapped(
        RegExp(r'\\(sin|cos|tan|csc|sec|cot)\s*\^\{([^}]+)\}\s*\(([^)]+)\)'),
        (m) {
      return '${m.group(1)}(${m.group(3)})^(${m.group(2)})';
    });

    // Trig power with braces: \sin^{n}{expr} -> sin(expr)^n
    result = result.replaceAllMapped(
        RegExp(r'\\(sin|cos|tan|csc|sec|cot)\s*\^\{([^}]+)\}\{([^}]+)\}'), (m) {
      return '${m.group(1)}(${m.group(3)})^(${m.group(2)})';
    });

    // Trigonometric functions: \sin{expr} -> sin(expr)
    result = result.replaceAllMapped(
        RegExp(r'\\(sin|cos|tan|csc|sec|cot)\{([^}]+)\}'), (m) {
      return '${m.group(1)}(${m.group(2)})';
    });

    // Inverse trigonometric functions: \arcsin{expr} -> asin(expr)
    result = result.replaceAllMapped(
        RegExp(r'\\arc(sin|cos|tan|csc|sec|cot)\{([^}]+)\}'), (m) {
      final func = m.group(1)!;
      final expr = m.group(2)!;
      return 'a$func($expr)';
    });

    // Hyperbolic functions: \sinh{expr} -> sinh(expr)
    result = result.replaceAllMapped(
        RegExp(r'\\(sinh|cosh|tanh|csch|sech|coth)\{([^}]+)\}'), (m) {
      return '${m.group(1)}(${m.group(2)})';
    });

    // Inverse hyperbolic functions: \asinh{expr} -> asinh(expr)
    result = result.replaceAllMapped(
        RegExp(r'\\a(sinh|cosh|tanh|csch|sech|coth)\{([^}]+)\}'), (m) {
      return 'a${m.group(1)}(${m.group(2)})';
    });

    // Logarithmic functions: \ln{expr} -> ln(expr), \log{expr} -> log(expr)
    result = result.replaceAllMapped(RegExp(r'\\(ln|log)\{([^}]+)\}'), (m) {
      return '${m.group(1)}(${m.group(2)})';
    });

    // Logarithm with base: \log_{base}{expr} -> log(expr)/log(base)
    result =
        result.replaceAllMapped(RegExp(r'\\log_\{([^}]+)\}\{([^}]+)\}'), (m) {
      final base = m.group(1)!;
      final expr = m.group(2)!;
      return 'log($expr)/log($base)';
    });

    // Logarithm with base, bare arg: \log_{base} expr -> log(expr)/log(base)
    // (OCR/CROHME: \log_{a} x or \log_{a}x — no braces around argument)
    result = result
        .replaceAllMapped(RegExp(r'\\log_\{([^}]+)\}\s*([a-zA-Z0-9]+)'), (m) {
      final base = m.group(1)!;
      final expr = m.group(2)!;
      return 'log($expr)/log($base)';
    });

    // === STEP 3: Handle function notation with parentheses (already correct) ===

    // These are already in correct format: \sin(expr) -> sin(expr)
    result = result.replaceAllMapped(
        RegExp(
            r'\\(sin|cos|tan|csc|sec|cot|sinh|cosh|tanh|csch|sech|coth|ln|log|sqrt|abs)\('),
        (m) {
      return '${m.group(1)}(';
    });

    // Inverse trig with parentheses: \arcsin(expr) -> asin(expr)
    result = result
        .replaceAllMapped(RegExp(r'\\arc(sin|cos|tan|csc|sec|cot)\('), (m) {
      return 'a${m.group(1)}(';
    });

    // Bare-argument functions (OCR output): \sin x -> sin(x), \log x -> log(x)
    // Must come after brace/paren forms. Captures a single token (letter,
    // digit, or Greek-letter identifier) that follows the command.
    result = result.replaceAllMapped(
        RegExp(
            r'\\(sin|cos|tan|csc|sec|cot|sinh|cosh|tanh|csch|sech|coth|ln|log)\s+([a-zA-Z0-9]+)'),
        (m) {
      return '${m.group(1)}(${m.group(2)})';
    });

    // === STEP 4: Handle integrals, limits, sums/products BEFORE power/subscript
    //              rewriting. They depend on literal ^{...} and _{...} groups
    //              that the power/subscript rules would consume.

    // Definite integral: \int_{a}^{b} expr dx -> integrate(expr, (x, a, b))
    // Allows 'd x' (space-separated) as CROHME/OCR produce.
    result = result.replaceAllMapped(
        RegExp(
            r'\\int_\{([^}]+)\}\^\{([^}]+)\}\s*(.+?)\s*\\?,?\s*d\s*([a-zA-Z])'),
        (m) {
      final lower = m.group(1)!;
      final upper = m.group(2)!;
      final expr = m.group(3)!.trim();
      final variable = m.group(4)!;
      return 'integrate($expr, ($variable, $lower, $upper))';
    });

    // Indefinite integral: \int expr dx -> integrate(expr, x)
    // Uses lazy (.+?) to avoid consuming the 'd x' differential.
    result = result.replaceAllMapped(
        RegExp(r'\\int\s*(.+?)\s*\\?,?\s*d\s+([a-zA-Z])\b'), (m) {
      final expr = m.group(1)!.trim();
      final variable = m.group(2)!;
      return 'integrate($expr, $variable)';
    });

    // Indefinite integral (no space): \int expr dx -> integrate(expr, x)
    result = result.replaceAllMapped(
        RegExp(r'\\int\s*(.+?)\s*\\?,?\s*d([a-zA-Z])\b'), (m) {
      final expr = m.group(1)!.trim();
      final variable = m.group(2)!;
      return 'integrate($expr, $variable)';
    });

    // Normalize \rightarrow → \to (OCR models often emit \rightarrow)
    result = result.replaceAll(r'\rightarrow', r'\to');

    // Basic limit: \lim_{x \to a} expr -> limit(expr, x, a)
    // Handles directional limits (a^+, a^-) and +\infty/-\infty.
    result = result.replaceAllMapped(
        RegExp(r'\\lim_\{([a-zA-Z])\s*\\to\s*([^}]+)\}\s*(.+)'), (m) {
      final variable = m.group(1)!;
      var approaches = m.group(2)!.trim();
      final expr = m.group(3)!;

      // Detect directional limit (a^+ or a^-)
      String? direction;
      if (approaches.endsWith('^+')) {
        direction = '+';
        approaches = approaches.substring(0, approaches.length - 2).trim();
      } else if (approaches.endsWith('^-')) {
        direction = '-';
        approaches = approaches.substring(0, approaches.length - 2).trim();
      }

      // Normalize infinity variants
      approaches = approaches
          .replaceAll(r'+\infty', r'\infty')
          .replaceAll(r'-\infty', '-oo')
          .replaceAll(r'\infty', 'oo')
          .replaceAll(r'\infinity', 'oo');

      if (direction != null) {
        return "limit($expr, $variable, $approaches, '$direction')";
      }
      return 'limit($expr, $variable, $approaches)';
    });

    // Expression capture for sum/product: stop at '=' or next
    // top-level \sum/\prod/\int/\lim to handle multiple in one line.
    const spExpr = r'(.+?)(?=\s*(?:=|\\sum|\\prod|\\int|\\lim)|$)';

    // Summation: \sum_{i=1}^{n} expr -> Sum(expr, (i, 1, n))
    result = result.replaceAllMapped(
        RegExp('\\\\sum_\\{([a-zA-Z])=([^}]+)\\}\\^\\{([^}]+)\\}\\s*$spExpr'),
        (m) {
      final variable = m.group(1)!;
      final start = m.group(2)!;
      final end = m.group(3)!;
      final expr = m.group(4)!.trim();
      return 'Sum($expr, ($variable, $start, $end))';
    });

    // Product: \prod_{i=1}^{n} expr -> Product(expr, (i, 1, n))
    result = result.replaceAllMapped(
        RegExp('\\\\prod_\\{([a-zA-Z])=([^}]+)\\}\\^\\{([^}]+)\\}\\s*$spExpr'),
        (m) {
      final variable = m.group(1)!;
      final start = m.group(2)!;
      final end = m.group(3)!;
      final expr = m.group(4)!.trim();
      return 'Product($expr, ($variable, $start, $end))';
    });

    // Partial-limit sum: \sum_{i=a} expr (no upper) → Sum(expr, (i, a, oo))
    result = result.replaceAllMapped(
        RegExp('\\\\sum_\\{([a-zA-Z])=([^}]+)\\}\\s*$spExpr'), (m) {
      final variable = m.group(1)!;
      final start = m.group(2)!;
      final expr = m.group(3)!.trim();
      return 'Sum($expr, ($variable, $start, oo))';
    });

    // Variable-only sum: \sum_{i} expr → Sum(expr, i)
    result = result
        .replaceAllMapped(RegExp('\\\\sum_\\{([a-zA-Z])\\}\\s*$spExpr'), (m) {
      final variable = m.group(1)!;
      final expr = m.group(2)!.trim();
      return 'Sum($expr, $variable)';
    });

    // Bare sum: \sum expr → Sum(expr)
    result = result.replaceAllMapped(RegExp('\\\\sum\\s+$spExpr'), (m) {
      final expr = m.group(1)!.trim();
      return 'Sum($expr)';
    });

    // Partial-limit product: \prod_{i=a} expr (no upper) → Product(expr, (i, a, oo))
    result = result.replaceAllMapped(
        RegExp('\\\\prod_\\{([a-zA-Z])=([^}]+)\\}\\s*$spExpr'), (m) {
      final variable = m.group(1)!;
      final start = m.group(2)!;
      final expr = m.group(3)!.trim();
      return 'Product($expr, ($variable, $start, oo))';
    });

    // Variable-only product: \prod_{i} expr → Product(expr, i)
    result = result
        .replaceAllMapped(RegExp('\\\\prod_\\{([a-zA-Z])\\}\\s*$spExpr'), (m) {
      final variable = m.group(1)!;
      final expr = m.group(2)!.trim();
      return 'Product($expr, $variable)';
    });

    // === STEP 5: Handle power and subscript notation ===

    // Powers with braces: x^{expr} -> x^(expr)
    result = result.replaceAllMapped(RegExp(r'\^\{([^}]+)\}'), (m) {
      final exp = m.group(1)!;
      // If it's a single character/number, parentheses aren't needed
      if (RegExp(r'^[a-zA-Z0-9]$').hasMatch(exp)) {
        return '^$exp';
      }
      return '^($exp)';
    });

    // Subscripts with braces: x_{expr} -> x_expr (though SymEngine may not need this)
    result = result.replaceAllMapped(RegExp(r'_\{([^}]+)\}'), (m) {
      return '_${m.group(1)}';
    });

    // === STEP 5: Handle constants and symbols ===

    // Greek letters and constants
    result = result.replaceAll(r'\pi', 'pi');
    result = result.replaceAll(r'\Pi', 'Pi');
    result = result.replaceAll(r'\e', 'E');
    result = result.replaceAll(r'\gamma', 'EulerGamma');
    result = result.replaceAll(r'\Gamma', 'gamma');
    result = result.replaceAll(r'\alpha', 'alpha');
    result = result.replaceAll(r'\beta', 'beta');
    result = result.replaceAll(r'\delta', 'delta');
    result = result.replaceAll(r'\Delta', 'Delta');
    result = result.replaceAll(r'\theta', 'theta');
    result = result.replaceAll(r'\Theta', 'Theta');
    result = result.replaceAll(r'\lambda', 'lambda');
    result = result.replaceAll(r'\Lambda', 'Lambda');
    result = result.replaceAll(r'\mu', 'mu');
    result = result.replaceAll(r'\sigma', 'sigma');
    result = result.replaceAll(r'\Sigma', 'Sigma');
    result = result.replaceAll(r'\phi', 'phi');
    result = result.replaceAll(r'\Phi', 'Phi');
    result = result.replaceAll(r'\omega', 'omega');
    result = result.replaceAll(r'\Omega', 'Omega');

    // Ellipsis
    result = result.replaceAll(r'\ldots', '...');
    result = result.replaceAll(r'\cdots', '...');
    result = result.replaceAll(r'\dots', '...');

    // Special constants
    result = result.replaceAll(r'\infty', 'oo');
    result = result.replaceAll(r'\infinity', 'oo');

    // === STEP 6: Handle operators ===

    // Multiplication symbols
    result = result.replaceAll(r'\cdot', '*');
    result = result.replaceAll(r'\times', '*');
    result = result.replaceAll(r'\ast', '*');

    // Division symbols (though we prefer \frac)
    result = result.replaceAll(r'\div', '/');

    // Comparison operators
    result = result.replaceAll(r'\leq', '<=');
    result = result.replaceAll(r'\le', '<=');
    result = result.replaceAll(r'\geq', '>=');
    result = result.replaceAll(r'\ge', '>=');
    result = result.replaceAll(r'\neq', '!=');
    result = result.replaceAll(r'\ne', '!=');
    result = result.replaceAll(r'\approx', '≈');

    // Plus/minus
    result = result.replaceAll(r'\pm', '+-');
    result = result.replaceAll(r'\mp', '-+');

    // Modulo operations: \bmod -> mod (FIXED)
    result = result.replaceAll(r'\bmod', ' mod ');
    result = result.replaceAll(r'\\bmod', ' mod ');

    // === STEP 7: Handle absolute values and norms ===

    // Normalize \| (LaTeX double-pipe) → || before matching norms
    result = result.replaceAll(r'\|', '||');

    // Double-pipe norms: ||expr|| → abs(expr)
    // (SymEngine has no separate norm — use abs as approximation)
    result = result.replaceAllMapped(RegExp(r'\|\|([^|]+)\|\|'), (m) {
      return 'abs(${m.group(1)})';
    });

    // Absolute values: |expr| -> abs(expr)
    // This is tricky because we need to match paired pipes
    result = result.replaceAllMapped(RegExp(r'\|([^|]+)\|'), (m) {
      return 'abs(${m.group(1)})';
    });

    // === STEP 11: Handle braces (convert to parentheses where needed) ===

    // Convert remaining \{ and \} to regular braces (for grouping)
    result = result.replaceAll(r'\{', '{');
    result = result.replaceAll(r'\}', '}');

    // === STEP 12: Clean up spacing ===

    // LaTeX non-breaking space (tilde) → regular space
    result = result.replaceAll('~', ' ');

    // Remove extra spaces around operators
    result = result.replaceAll(RegExp(r'\s*\*\s*'), '*');
    result = result.replaceAll(RegExp(r'\s*\+\s*'), '+');
    result = result.replaceAll(RegExp(r'\s*-\s*'), '-');
    result = result.replaceAll(RegExp(r'\s*/\s*'), '/');
    result = result.replaceAll(RegExp(r'\s*\^\s*'), '^');

    // Remove multiple spaces
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();

    return result;
  }

  /// Converts LaTeX back to readable format for history display
  static String latexToReadable(String latex) {
    String readable = latex;

    // Convert LaTeX operators back to readable symbols
    readable = readable.replaceAll(r'\cdot ', '*');
    readable = readable.replaceAll(r'\cdot', '*');
    readable = readable.replaceAll(r'\times ', '*');
    readable = readable.replaceAll(r'\times', '*');
    readable = readable.replaceAll(r'\div ', '/');
    readable = readable.replaceAll(r'\div', '/');

    // Convert fractions back to parentheses
    readable =
        readable.replaceAllMapped(RegExp(r'\\frac\{([^}]+)\}\{([^}]+)\}'), (m) {
      return '(${m.group(1)})/(${m.group(2)})';
    });

    // Remove LaTeX function formatting
    readable = readable.replaceAll(r'\sin', 'sin');
    readable = readable.replaceAll(r'\cos', 'cos');
    readable = readable.replaceAll(r'\tan', 'tan');
    readable = readable.replaceAll(r'\ln', 'ln');
    readable = readable.replaceAll(r'\log', 'log');

    // Sized delimiters: strip the LaTeX command, keep the bracket.
    // Match the `fromLatex` strip pass so the readable history
    // display doesn't carry `\bigg(` etc. through to the user.
    readable = readable.replaceAllMapped(
      RegExp(
          r'\\(left|right|big|Big|bigg|Bigg|bigl|bigr|Bigl|Bigr|biggl|biggr|Biggl|Biggr)\s*(?=[(){}\[\]])'),
      (_) => '',
    );

    return readable;
  }
}
