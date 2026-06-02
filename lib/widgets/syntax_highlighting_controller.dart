// lib/widgets/syntax_highlighting_controller.dart
//
// Notepad V2: lightweight syntax highlighting for math expressions.
//
// Overrides [TextEditingController.buildTextSpan] to return a colored
// [TextSpan] tree instead of a plain string. The lexer is deliberately
// simple (regex-based, single-pass) — it catches the common cases
// without the overhead of a real parser.
//
// Token kinds:
//   - comments:   `//` or `#` to EOL — dimmed italic
//   - numbers:    integer or decimal literals — accent color
//   - strings:    quoted strings (rare in math, but FlatZinc uses them)
//   - functions:  known CAS / math function names — bold
//   - keywords:   `use`, `total`, `subtotal`, `average`, `count`,
//                 `and`, `or`, `not`, `xor`, `if`, `true`, `false` — keyword color
//   - operators:  `+`, `-`, `*`, `/`, `^`, `=`, `<`, `>`, `!`, `%` — operator color
//   - headings:   `## ` prefix — primary, bold (matches the heading
//                 input-field styling)
//   - plain text: everything else — default style

import 'package:flutter/material.dart';

class SyntaxHighlightingController extends TextEditingController {
  SyntaxHighlightingController({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final text = this.text;
    if (text.isEmpty) {
      return TextSpan(text: '', style: style);
    }

    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final commentStyle = (style ?? const TextStyle()).copyWith(
      color: Colors.grey,
      fontStyle: FontStyle.italic,
    );
    final numberStyle = (style ?? const TextStyle()).copyWith(
      color: isDark ? Colors.lightBlue[200] : Colors.blue[700],
    );
    final functionStyle = (style ?? const TextStyle()).copyWith(
      color: isDark ? Colors.purple[200] : Colors.purple[700],
      fontWeight: FontWeight.w600,
    );
    final keywordStyle = (style ?? const TextStyle()).copyWith(
      color: isDark ? Colors.orange[200] : Colors.orange[800],
      fontWeight: FontWeight.w600,
    );
    final operatorStyle = (style ?? const TextStyle()).copyWith(
      color: isDark ? Colors.teal[200] : Colors.teal[700],
    );
    final headingStyle = (style ?? const TextStyle()).copyWith(
      color: scheme.primary,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );

    // Check for heading prefix.
    if (text.trimLeft().startsWith('## ')) {
      return TextSpan(text: text, style: headingStyle);
    }

    // Check for full-line comment.
    final trimmed = text.trimLeft();
    if (trimmed.startsWith('//') || trimmed.startsWith('#')) {
      return TextSpan(text: text, style: commentStyle);
    }

    // Tokenize with a combined regex. Order matters: longer patterns
    // first; the first branch that matches wins at each position.
    final spans = <TextSpan>[];
    var lastEnd = 0;

    for (final match in _tokenPattern.allMatches(text)) {
      // Plain text before this token.
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: style,
        ));
      }

      final token = match.group(0)!;
      TextStyle tokenStyle;

      if (match.group(1) != null) {
        // Group 1: inline comment.
        tokenStyle = commentStyle;
      } else if (match.group(2) != null) {
        // Group 2: number literal.
        tokenStyle = numberStyle;
      } else if (match.group(3) != null) {
        // Group 3: known function name.
        tokenStyle = functionStyle;
      } else if (match.group(4) != null) {
        // Group 4: keyword.
        tokenStyle = keywordStyle;
      } else if (match.group(5) != null) {
        // Group 5: operator.
        tokenStyle = operatorStyle;
      } else {
        tokenStyle = style ?? const TextStyle();
      }

      spans.add(TextSpan(text: token, style: tokenStyle));
      lastEnd = match.end;
    }

    // Trailing plain text.
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: style));
    }

    return TextSpan(children: spans, style: style);
  }

  // --- Token pattern ---

  static final _functionNames = [
    'solve', 'expand', 'simplify', 'factor', 'diff', 'integrate',
    'limit', 'subst', 'gcd', 'lcm', 'factorial', 'fibonacci',
    'sin', 'cos', 'tan', 'asin', 'acos', 'atan',
    'sinh', 'cosh', 'tanh', 'asinh', 'acosh', 'atanh',
    'exp', 'log', 'ln', 'log10', 'sqrt', 'cbrt', 'abs',
    'floor', 'ceil', 'round', 'sign', 'gamma', 'zeta', 'erf',
    'lambertw', 'beta', 'besselj', 'bessely',
    'isprime', 'nextprime', 'prevprime', 'factorint',
    'divisors', 'totient', 'modpow', 'modinv', 'jacobi',
    'cfrac', 'convergent', 'polygcd', 'polyfactor',
    'evalf', 'cevalf', 'det', 'inv', 'transpose', 'rref',
    'Matrix', 'dot', 'cross', 'norm', 'unit',
    'pi', 'Pi', 'min', 'max', 'mod',
  ];

  static final _keywords = [
    'use', 'total', 'subtotal', 'average', 'count',
    'and', 'or', 'not', 'xor', 'if',
    'true', 'false', 'Ans', 'fzn',
  ];

  static final RegExp _tokenPattern = RegExp(
    '('
    // Group 1: inline comment (// or # to EOL).
    r'(?://|#).*$'
    ')|('
    // Group 2: number literal (integer or decimal, optional leading sign
    // only when preceded by an operator or start of string).
    r'(?<![a-zA-Z_])(\d+\.?\d*(?:[eE][+-]?\d+)?)'
    ')|('
    // Group 3: known function name (word-bounded).
    r'(?<![a-zA-Z_])(?:' +
        _functionNames.join('|') +
        r')(?![a-zA-Z_0-9])'
        ')|('
        // Group 4: keyword.
        r'(?<![a-zA-Z_])(?:' +
        _keywords.join('|') +
        r')(?![a-zA-Z_0-9])'
        ')|('
        // Group 5: operators.
        r'[+\-*/^=<>!%≠≤≥]+'
        ')',
    multiLine: true,
  );
}
