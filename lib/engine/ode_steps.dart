// Step-by-step traces for linear constant-coefficient ODEs (the education
// core — the most common textbook case). Produces a MathStep list showing
// the characteristic equation, its roots, the homogeneous solution, and —
// when the right-hand side is non-zero — the particular solution, ending
// with the general solution. The final answer line is taken verbatim from
// OdeSolver.solve so the trace can never disagree with the solver.
//
// Non-constant-coefficient forms (separable / linear-integrating-factor /
// Bernoulli / exact) return null: the caller shows the plain answer with a
// note that a full trace isn't available for those yet.

import 'calculator_engine.dart';
import 'ode_solver.dart';
import 'polynomial.dart';
import 'step_engine.dart';

class OdeStepEngine {
  /// Build a step trace for `a·y'' + b·y' + c·y = q(x)`, or null if the
  /// equation isn't a constant-coefficient linear ODE.
  static List<MathStep>? steps(CalculatorEngine engine, String equation) {
    final parsed = _parse(equation);
    if (parsed == null) return null;
    final (a2, a1, a0, forcing) = parsed;
    if (a2.isZero && a1.isZero) return null; // no derivative → not an ODE

    final answer = OdeSolver.solve(engine, equation);
    if (answer.startsWith('Error')) return null;

    final steps = <MathStep>[];
    final order = a2.isZero ? 1 : 2;
    final homogeneous = forcing.trim().isEmpty || forcing.trim() == '0';

    // 1. Characteristic equation.
    final charEq = _charEquation(a2, a1, a0);
    steps.add(MathStep(
      rule: 'Characteristic equation',
      formula: order == 2 ? r'a r^2 + b r + c = 0' : r'a r + b = 0',
      before: _lhsString(a2, a1, a0),
      after: '$charEq = 0',
      note: order == 2
          ? "Replace y'' → r², y' → r, y → 1 in the homogeneous "
              'equation.'
          : "Replace y' → r, y → 1 in the homogeneous equation.",
      noteI18n: StepNote('ode.characteristic', {'order': '$order'}),
    ));

    // 2. Roots.
    final rootInfo = _roots(a2, a1, a0);
    steps.add(MathStep(
      rule: 'Roots',
      formula:
          order == 2 ? r'r = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}' : r'r = -b/a',
      before: '$charEq = 0',
      after: rootInfo.display,
      note: rootInfo.note,
      noteI18n: StepNote('ode.roots', {'kind': rootInfo.kind}),
    ));

    // 3. Homogeneous solution — solve the homogeneous version (RHS = 0)
    // so the forced case shows y_h alone, not y_h + y_p.
    final homEq = _lhsString(a2, a1, a0); // "... = 0"
    final yhSolve = OdeSolver.solve(engine, homEq);
    final yh = yhSolve.startsWith('y = ') ? yhSolve.substring(4) : yhSolve;
    steps.add(MathStep(
      rule: 'Homogeneous solution',
      formula: rootInfo.modeFormula,
      before: rootInfo.display,
      after: 'y_h = $yh',
      note: rootInfo.modeNote,
      noteI18n: StepNote('ode.homogeneous', {'kind': rootInfo.kind}),
    ));

    // 4. Particular solution (only when forced).
    if (!homogeneous) {
      steps.add(MathStep(
        rule: 'Particular solution',
        formula: r'y_p:\ \text{ansatz of the same form as } q(x)',
        before: 'q(x) = ${forcing.trim()}',
        after: 'substitute the undetermined-coefficients ansatz and match',
        note: 'Try a trial function shaped like the right-hand side '
            '(polynomial / exponential / sinusoid), differentiate, and '
            'solve for its coefficients.',
        noteI18n: const StepNote('ode.particular'),
      ));
    }

    // 5. General solution (authoritative answer).
    steps.add(MathStep(
      rule: 'General solution',
      formula: homogeneous ? r'y = y_h' : r'y = y_h + y_p',
      before: homogeneous ? 'y_h = $yh' : 'y = y_h + y_p',
      after: answer,
      note: homogeneous
          ? 'The general solution is the homogeneous solution with '
              'arbitrary constants C1, C2.'
          : 'The general solution is y_h (with C1, C2) plus the '
              'particular solution y_p.',
      noteI18n: const StepNote('ode.general'),
    ));

    return steps;
  }

  // --- parsing (constant-coefficient linear only) ------------------------

  static (Rational, Rational, Rational, String)? _parse(String equation) {
    final eqIdx = _topEq(equation);
    final lhs = eqIdx < 0 ? equation : equation.substring(0, eqIdx);
    final rhs = eqIdx < 0 ? '0' : equation.substring(eqIdx + 1);

    var a2 = Rational.zero, a1 = Rational.zero, a0 = Rational.zero;
    final forcing = <String>[];

    for (final (term, sign) in [
      ..._terms(lhs).map((t) => (t.$1, t.$2)),
      ..._terms(rhs).map((t) => (t.$1, -t.$2)),
    ]) {
      final t = term.replaceAll(' ', '');
      if (t.isEmpty) continue;
      final order = _yOrder(t);
      if (order == null) {
        // x-only forcing term, moved to the RHS (opposite sign).
        forcing.add(sign < 0 ? t : '-($t)');
        continue;
      }
      final coeff = _coeff(t, order);
      if (coeff == null) return null; // non-constant coefficient
      final c = sign < 0 ? -coeff : coeff;
      switch (order) {
        case 2:
          a2 = a2 + c;
        case 1:
          a1 = a1 + c;
        default:
          a0 = a0 + c;
      }
    }
    return (a2, a1, a0, forcing.join(' + '));
  }

  static int _topEq(String s) {
    var depth = 0;
    for (var i = 0; i < s.length; i++) {
      if (s[i] == '(') depth++;
      if (s[i] == ')') depth--;
      if (s[i] == '=' && depth == 0) return i;
    }
    return -1;
  }

  static List<(String, int)> _terms(String s) {
    final out = <(String, int)>[];
    var t = s.trim();
    if (t.isEmpty) return out;
    var sign = 1, depth = 0, start = 0;
    if (t.startsWith('+')) t = t.substring(1);
    if (t.startsWith('-')) {
      sign = -1;
      t = t.substring(1);
    }
    for (var i = 0; i < t.length; i++) {
      final c = t[i];
      if (c == '(') depth++;
      if (c == ')') depth--;
      if ((c == '+' || c == '-') && depth == 0 && i > start) {
        out.add((t.substring(start, i).trim(), sign));
        sign = c == '-' ? -1 : 1;
        start = i + 1;
      }
    }
    out.add((t.substring(start).trim(), sign));
    return out.where((e) => e.$1.isNotEmpty).toList();
  }

  /// 2 for y'', 1 for y', 0 for y, null for an x-only term.
  static int? _yOrder(String t) {
    if (t.contains("y''")) return 2;
    if (t.contains("y'")) return 1;
    if (RegExp(r'(?<![a-zA-Z])y(?![a-zA-Z])').hasMatch(t)) return 0;
    return null;
  }

  static Rational? _coeff(String t, int order) {
    final token = order == 2 ? "y''" : (order == 1 ? "y'" : 'y');
    final idx = t.indexOf(token);
    var pre = t.substring(0, idx);
    final post = t.substring(idx + token.length);
    if (post.isNotEmpty) return null; // y followed by something → non-constant
    if (pre.endsWith('*')) pre = pre.substring(0, pre.length - 1);
    if (pre.isEmpty) return Rational.one;
    final p = Polynomial.tryParse(pre);
    if (p == null || p.degree != 0) return null;
    return p.coeffs[0];
  }

  // --- characteristic equation + roots -----------------------------------

  static String _charEquation(Rational a2, Rational a1, Rational a0) {
    final terms = <String>[];
    void add(Rational c, String pow) {
      if (c.isZero) return;
      final mag = c.abs;
      final s = mag == Rational.one && pow.isNotEmpty ? pow : '${_f(mag)}$pow';
      if (terms.isEmpty) {
        terms.add(c.sign < 0 ? '-$s' : s);
      } else {
        terms.add(c.sign < 0 ? '- $s' : '+ $s');
      }
    }

    if (!a2.isZero) add(a2, 'r^2');
    add(a1, 'r');
    add(a0, '');
    return terms.isEmpty ? '0' : terms.join(' ');
  }

  static String _lhsString(Rational a2, Rational a1, Rational a0) {
    final terms = <String>[];
    void add(Rational c, String y) {
      if (c.isZero) return;
      final mag = c.abs;
      final s = mag == Rational.one ? y : '${_f(mag)}*$y';
      if (terms.isEmpty) {
        terms.add(c.sign < 0 ? '-$s' : s);
      } else {
        terms.add(c.sign < 0 ? '- $s' : '+ $s');
      }
    }

    if (!a2.isZero) add(a2, "y''");
    add(a1, "y'");
    add(a0, 'y');
    return '${terms.isEmpty ? '0' : terms.join(' ')} = 0';
  }

  static _RootInfo _roots(Rational a2, Rational a1, Rational a0) {
    if (a2.isZero) {
      final r = -(a0 / a1);
      return _RootInfo(
        display: 'r = ${_f(r)}',
        kind: 'single',
        note: 'A first-order equation has one root.',
        modeFormula: r'y_h = C_1 e^{r x}',
        modeNote: 'The single root r gives y_h = C1·e^(r·x).',
      );
    }
    final delta = a1 * a1 - Rational.fromInt(4) * a2 * a0;
    final twoA = Rational.fromInt(2) * a2;
    if (delta.isZero) {
      final r = -(a1 / twoA);
      return _RootInfo(
        display: 'r = ${_f(r)} (double)',
        kind: 'double',
        note: 'Discriminant b² − 4ac = 0 → one repeated real root.',
        modeFormula: r'y_h = (C_1 + C_2 x) e^{r x}',
        modeNote: 'A double root r gives y_h = (C1 + C2·x)·e^(r·x).',
      );
    }
    if (delta.sign > 0) {
      final sq = _isqrtRat(delta);
      final rootStr = sq != null ? _f(sq) : 'sqrt(${_f(delta)})';
      final r1 = sq != null ? _f((-a1 + sq) / twoA) : null;
      final r2 = sq != null ? _f((-a1 - sq) / twoA) : null;
      return _RootInfo(
        display: r1 != null
            ? 'r = $r1, r = $r2'
            : 'r = (${_f(-a1)} ± $rootStr)/${_f(twoA)}',
        kind: 'distinct',
        note: 'Discriminant b² − 4ac > 0 → two distinct real roots.',
        modeFormula: r'y_h = C_1 e^{r_1 x} + C_2 e^{r_2 x}',
        modeNote: 'Distinct real roots give one exponential mode each.',
      );
    }
    final alpha = -(a1 / twoA);
    final negDelta = -delta;
    final sq = _isqrtRat(negDelta);
    final betaStr =
        sq != null ? _f(sq / twoA) : 'sqrt(${_f(negDelta)})/${_f(twoA)}';
    return _RootInfo(
      display: 'r = ${_f(alpha)} ± ${betaStr}i',
      kind: 'complex',
      note: 'Discriminant b² − 4ac < 0 → a complex-conjugate pair α ± βi.',
      modeFormula: r'y_h = e^{\alpha x}(C_1 \cos\beta x + C_2 \sin\beta x)',
      modeNote: 'A complex pair α ± βi gives '
          'e^(α·x)·(C1·cos(β·x) + C2·sin(β·x)).',
    );
  }

  // --- helpers ------------------------------------------------------------

  static String _f(Rational r) =>
      r.isInteger ? r.numerator.toString() : '${r.numerator}/${r.denominator}';

  static Rational? _isqrtRat(Rational r) {
    if (r.sign < 0) return null;
    final n = _isqrt(r.numerator), d = _isqrt(r.denominator);
    if (n * n == r.numerator && d * d == r.denominator) return Rational(n, d);
    return null;
  }

  static BigInt _isqrt(BigInt n) {
    if (n < BigInt.two) return n;
    var x = n, y = (x + BigInt.one) >> 1;
    while (y < x) {
      x = y;
      y = (x + n ~/ x) >> 1;
    }
    return x;
  }
}

class _RootInfo {
  final String display;
  final String kind;
  final String note;
  final String modeFormula;
  final String modeNote;
  _RootInfo({
    required this.display,
    required this.kind,
    required this.note,
    required this.modeFormula,
    required this.modeNote,
  });
}
