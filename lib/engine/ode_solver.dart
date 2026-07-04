// Linear constant-coefficient ODE solver (roadmap C3 — education subset).
//
//   dsolve(y' = 3*y)              -> y = C1*exp(3*x)
//   dsolve(y'' + 3*y' + 2*y = 0)  -> y = C1*exp(-x) + C2*exp(-2*x)
//   dsolve(y'' + y = 0)           -> y = C1*cos(x) + C2*sin(x)
//   dsolve(y'' - 2*y' + y = 0)    -> y = (C1 + C2*x)*exp(x)
//   dsolve(y' + y = x^2)          -> y = C1*exp(-x) + x^2 - 2*x + 2
//
// Scope: a·y'' + b·y' + c·y = q(x) with rational a, b, c and q a sum of
//   * polynomials in x,
//   * k·exp(m·x),
//   * k·sin(w·x) / k·cos(w·x),
// solved exactly — homogeneous part via the characteristic equation
// (distinct real / double / complex-conjugate roots, exact surds kept),
// particular part via undetermined coefficients with resonance handling
// for polynomial and exponential forcing. `y' = f(x)` (no y term)
// delegates to engine.integrate. Everything else returns an error.

import 'calculator_engine.dart';
import 'polynomial.dart';

class OdeSolver {
  /// Solve an ODE given as an equation string, e.g. "y'' + 3*y' + 2*y = 0".
  /// The unknown function is `y`, the independent variable `x`.
  /// Returns "y = …" or an Error string.
  static String solve(CalculatorEngine engine, String equation) {
    final eq = equation.trim();
    final eqIdx = _topLevelEquals(eq);
    final lhs = eqIdx < 0 ? eq : eq.substring(0, eqIdx);
    final rhs = eqIdx < 0 ? '0' : eq.substring(eqIdx + 1);

    // Collect L[y] coefficients and forcing terms.
    var a2 = Rational.zero, a1 = Rational.zero, a0 = Rational.zero;
    final forcingTerms = <String>[];

    for (final (term, sign) in [
      ..._terms(lhs).map((t) => (t.$1, t.$2)),
      ..._terms(rhs).map((t) => (t.$1, -t.$2)),
    ]) {
      final y = _parseYTerm(term);
      if (y == null) {
        // x-only term: forcing accumulates with OPPOSITE sign (moved to
        // the right-hand side of L[y] = q).
        final s = sign < 0 ? '' : '-';
        forcingTerms.add('$s($term)');
        continue;
      }
      if (y.coeff == null) {
        return 'Error: dsolve supports constant coefficients only '
            '(term "$term")';
      }
      final c = sign < 0 ? -y.coeff! : y.coeff!;
      switch (y.order) {
        case 2:
          a2 = a2 + c;
        case 1:
          a1 = a1 + c;
        default:
          a0 = a0 + c;
      }
    }

    if (a2.isZero && a1.isZero) {
      return a0.isZero
          ? 'Error: no y term found — not an ODE'
          : 'Error: dsolve needs a derivative of y';
    }

    final q = _classifyForcing(forcingTerms.join(' + '));

    // y' = f(x) with no y-term: plain integration.
    if (a2.isZero && a0.isZero) {
      if (q == null) {
        // Try the engine's integrator on the raw forcing.
        final f = forcingTerms.isEmpty
            ? '0'
            : forcingTerms.join(' + ').replaceAll('-(', '-1*(');
        final anti = engine.integrate(_scaleExpr(f, a1), 'x');
        if (anti.startsWith('Error')) {
          return 'Error: dsolve could not integrate the right-hand side';
        }
        return 'y = ${anti.replaceAll(' + C', '')} + C1';
      }
    }
    if (q == null) {
      return 'Error: dsolve supports polynomial, exp and sin/cos '
          'right-hand sides';
    }

    final vp = _particular(a2, a1, a0, q);
    if (vp == null) {
      return 'Error: dsolve could not find a particular solution '
          '(resonant trig forcing is not supported yet)';
    }

    final homog = _homogeneous(a2, a1, a0);
    final parts = <String>[homog];
    if (vp.isNotEmpty && vp != '0') parts.add(vp);
    var result = parts.join(' + ');
    result = result.replaceAll('+ -', '- ');
    return 'y = $result';
  }

  // --- homogeneous solution ----------------------------------------------

  static String _homogeneous(Rational a2, Rational a1, Rational a0) {
    if (a2.isZero) {
      // a1 y' + a0 y = 0 -> y = C1 exp(-a0/a1 x)
      final r = -(a0 / a1);
      if (r.isZero) return 'C1';
      return 'C1*${_expOf(_fmt(r))}';
    }
    final delta = a1 * a1 - Rational.fromInt(4) * a2 * a0;
    final twoA2 = Rational.fromInt(2) * a2;
    if (delta.isZero) {
      final r = -(a1 / twoA2);
      return '(C1 + C2*x)*${_expOf(_fmt(r))}';
    }
    if (delta.sign > 0) {
      final sq = _sqrtRational(delta);
      if (sq != null) {
        // Rational roots.
        final r1 = (-a1 + sq) / twoA2;
        final r2 = (-a1 - sq) / twoA2;
        return 'C1*${_expOf(_fmt(r1))} + C2*${_expOf(_fmt(r2))}';
      }
      // Irrational real roots — exact surd strings.
      final root = _sqrtString(delta);
      final r1 = '(${_fmt(-a1)} + $root)/${_fmt(twoA2)}';
      final r2 = '(${_fmt(-a1)} - $root)/${_fmt(twoA2)}';
      return 'C1*exp(($r1)*x) + C2*exp(($r2)*x)';
    }
    // Complex pair α ± βi.
    final alpha = -(a1 / twoA2);
    final negDelta = -delta;
    final sqNeg = _sqrtRational(negDelta);
    final beta = sqNeg != null
        ? _fmt(sqNeg / twoA2)
        : '${_sqrtString(negDelta)}/${_fmt(twoA2)}';
    final osc = 'C1*cos(${_mulX(beta)}) + C2*sin(${_mulX(beta)})';
    if (alpha.isZero) return osc;
    return '${_expOf(_fmt(alpha))}*($osc)';
  }

  // --- particular solution (undetermined coefficients) --------------------

  static String? _particular(
      Rational a2, Rational a1, Rational a0, _Forcing q) {
    final parts = <String>[];
    if (q.poly != null && !q.poly!.isZero) {
      final p = _polyParticular(a2, a1, a0, q.poly!);
      if (p == null) return null;
      if (!p.isZero) parts.add(_renderPoly(p));
    }
    for (final e in q.exps.entries) {
      final s = _expParticular(a2, a1, a0, e.key, e.value);
      if (s == null) return null;
      parts.add(s);
    }
    for (final t in q.trigs.entries) {
      final s = _trigParticular(a2, a1, a0, t.key, t.value.$1, t.value.$2);
      if (s == null) return null;
      parts.add(s);
    }
    return parts.join(' + ');
  }

  /// Polynomial forcing: solve L[p] = q coefficient-wise.
  static Polynomial? _polyParticular(
      Rational a2, Rational a1, Rational a0, Polynomial q) {
    if (a0.isZero) {
      // Substitute z = y': a2 z' + a1 z = q, then y_p = ∫ z.
      if (a1.isZero) {
        // a2 y'' = q — integrate twice.
        return _integratePoly(_integratePoly(q.scale(Rational.one / a2)));
      }
      final z = _polyParticular(Rational.zero, a2, a1, q);
      return z == null ? null : _integratePoly(z);
    }
    final n = q.degree;
    final p = List<Rational>.filled(n + 1, Rational.zero);
    for (var i = n; i >= 0; i--) {
      var rhs = i <= q.degree ? q.coeffs[i] : Rational.zero;
      if (i + 1 <= n) {
        rhs = rhs - a1 * Rational.fromInt(i + 1) * p[i + 1];
      }
      if (i + 2 <= n) {
        rhs = rhs - a2 * Rational.fromInt((i + 2) * (i + 1)) * p[i + 2];
      }
      p[i] = rhs / a0;
    }
    return Polynomial.fromCoeffs(p, q.variable);
  }

  static Polynomial _integratePoly(Polynomial p) {
    final out = List<Rational>.filled(p.degree + 2, Rational.zero);
    for (var i = 0; i <= p.degree && !p.isZero; i++) {
      out[i + 1] = p.coeffs[i] / Rational.fromInt(i + 1);
    }
    return Polynomial.fromCoeffs(out, p.variable);
  }

  /// k·exp(m·x) forcing with resonance: char(m) = 0 → A·x·e^{mx},
  /// double resonance → A·x²·e^{mx}.
  static String? _expParticular(
      Rational a2, Rational a1, Rational a0, Rational m, Rational k) {
    final chi = a2 * m * m + a1 * m + a0;
    if (!chi.isZero) {
      return _coeffTimes(k / chi, _expOf(_fmt(m)));
    }
    final chiPrime = Rational.fromInt(2) * a2 * m + a1;
    if (!chiPrime.isZero) {
      return _coeffTimes(k / chiPrime, 'x*${_expOf(_fmt(m))}');
    }
    // Double root: χ'' = 2a2.
    return _coeffTimes(
        k / (Rational.fromInt(2) * a2), 'x^2*${_expOf(_fmt(m))}');
  }

  /// (ks·sin(wx) + kc·cos(wx)) forcing:
  ///   L[P sin + Q cos] = [(c−aw²)P − bwQ]·sin + [bwP + (c−aw²)Q]·cos.
  static String? _trigParticular(Rational a2, Rational a1, Rational a0,
      Rational w, Rational ks, Rational kc) {
    final d = a0 - a2 * w * w;
    final e = a1 * w;
    final det = d * d + e * e;
    if (det.isZero) return null; // resonance — v2
    final p = (d * ks + e * kc) / det;
    final qq = (d * kc - e * ks) / det;
    final parts = <String>[];
    if (!p.isZero) parts.add(_coeffTimes(p, 'sin(${_mulX(_fmt(w))})'));
    if (!qq.isZero) parts.add(_coeffTimes(qq, 'cos(${_mulX(_fmt(w))})'));
    return parts.join(' + ');
  }

  // --- equation parsing ----------------------------------------------------

  static int _topLevelEquals(String s) {
    var depth = 0;
    for (var i = 0; i < s.length; i++) {
      final ch = s[i];
      if (ch == '(') depth++;
      if (ch == ')') depth--;
      if (ch == '=' && depth == 0) return i;
    }
    return -1;
  }

  /// Split into (term, sign) at top-level + and -.
  static List<(String, int)> _terms(String s) {
    final out = <(String, int)>[];
    var depth = 0, start = 0, sign = 1;
    var t = s.trim();
    if (t.isEmpty) return out;
    if (t.startsWith('+')) t = t.substring(1);
    if (t.startsWith('-')) {
      sign = -1;
      t = t.substring(1);
    }
    for (var i = 0; i < t.length; i++) {
      final ch = t[i];
      if (ch == '(') depth++;
      if (ch == ')') depth--;
      if ((ch == '+' || ch == '-') && depth == 0 && i > start) {
        // Not part of e.g. `e-3` exponent (we don't expect those here).
        out.add((t.substring(start, i).trim(), sign));
        sign = ch == '-' ? -1 : 1;
        start = i + 1;
      }
    }
    out.add((t.substring(start).trim(), sign));
    return out.where((e) => e.$1.isNotEmpty).toList();
  }

  /// Parse a term containing y, y' or y''. Returns null for x-only terms;
  /// `coeff == null` flags a non-constant coefficient (unsupported).
  static ({int order, Rational? coeff})? _parseYTerm(String term) {
    final t = term.replaceAll(' ', '');
    String token;
    int order;
    if (t.contains("y''")) {
      token = "y''";
      order = 2;
    } else if (t.contains("y'")) {
      token = "y'";
      order = 1;
    } else if (RegExp(r'(?<![a-zA-Z])y(?![a-zA-Z])').hasMatch(t)) {
      token = 'y';
      order = 0;
    } else {
      return null;
    }
    final idx = t.indexOf(token);
    var pre = t.substring(0, idx);
    var post = t.substring(idx + token.length);
    if (pre.endsWith('*')) pre = pre.substring(0, pre.length - 1);

    Rational coeff;
    if (pre.isEmpty) {
      coeff = Rational.one;
    } else {
      final c = _parseRationalToken(pre);
      if (c == null) return (order: order, coeff: null);
      coeff = c;
    }
    if (post.isNotEmpty) {
      if (post.startsWith('/')) {
        final c = _parseRationalToken(post.substring(1));
        if (c == null || c.isZero) return (order: order, coeff: null);
        coeff = coeff / c;
      } else if (post.startsWith('*')) {
        final c = _parseRationalToken(post.substring(1));
        if (c == null) return (order: order, coeff: null);
        coeff = coeff * c;
      } else {
        return (order: order, coeff: null);
      }
    }
    return (order: order, coeff: coeff);
  }

  static Rational? _parseRationalToken(String s) {
    final p = Polynomial.tryParse(s);
    if (p == null || p.degree != 0) return null;
    return p.coeffs[0];
  }

  // --- forcing classification ---------------------------------------------

  static _Forcing? _classifyForcing(String forcing) {
    final f = _Forcing();
    if (forcing.trim().isEmpty) return f;
    // Terms arrive as "±(term)" — normalize and re-split.
    var polyAcc = Polynomial.zero('x');
    for (final (raw, sign) in _terms(forcing)) {
      var t = raw.replaceAll(' ', '');
      // Strip a single full wrap of parentheses.
      while (t.startsWith('(') && t.endsWith(')') && _wraps(t)) {
        t = t.substring(1, t.length - 1);
      }
      var s = sign;
      while (t.startsWith('-')) {
        s = -s;
        t = t.substring(1);
      }
      if (t == '0' || t.isEmpty) continue;

      final poly = Polynomial.tryParse(t);
      if (poly != null && (poly.degree == 0 || poly.variable == 'x')) {
        final signed = s < 0 ? poly.scale(Rational.fromInt(-1)) : poly;
        polyAcc = polyAcc + Polynomial.fromCoeffs(signed.coeffs, 'x');
        continue;
      }

      final expM = RegExp(r'^([0-9/]*)\*?exp\(([^()]*)\)$').firstMatch(t);
      if (expM != null) {
        final k = _coeffOrOne(expM.group(1)!);
        final m = _linearArg(expM.group(2)!);
        if (k == null || m == null) return null;
        final kk = s < 0 ? -k : k;
        f.exps[m] = (f.exps[m] ?? Rational.zero) + kk;
        continue;
      }

      final trigM =
          RegExp(r'^([0-9/]*)\*?(sin|cos)\(([^()]*)\)$').firstMatch(t);
      if (trigM != null) {
        final k = _coeffOrOne(trigM.group(1)!);
        final w = _linearArg(trigM.group(3)!);
        if (k == null || w == null || w.sign <= 0) return null;
        final kk = s < 0 ? -k : k;
        final cur = f.trigs[w] ?? (Rational.zero, Rational.zero);
        f.trigs[w] = trigM.group(2) == 'sin'
            ? (cur.$1 + kk, cur.$2)
            : (cur.$1, cur.$2 + kk);
        continue;
      }
      return null; // unsupported forcing term
    }
    if (!polyAcc.isZero) f.poly = polyAcc;
    return f;
  }

  static bool _wraps(String t) {
    var depth = 0;
    for (var i = 0; i < t.length; i++) {
      if (t[i] == '(') depth++;
      if (t[i] == ')') depth--;
      if (depth == 0 && i < t.length - 1) return false;
    }
    return true;
  }

  static Rational? _coeffOrOne(String s) {
    if (s.isEmpty) return Rational.one;
    return _parseRationalToken(s);
  }

  /// "x" -> 1, "-x" -> -1, "3*x"/"3x" -> 3, "x/2" -> 1/2.
  static Rational? _linearArg(String s) {
    final p = Polynomial.tryParse(s);
    if (p == null || p.degree != 1 || !p.coeffs[0].isZero) {
      // allow x/2 form
      final m = RegExp(r'^(-?)x/(\d+)$').firstMatch(s.replaceAll(' ', ''));
      if (m != null) {
        final r = Rational(BigInt.one, BigInt.parse(m.group(2)!));
        return m.group(1)! == '-' ? -r : r;
      }
      return null;
    }
    return p.coeffs[1];
  }

  // --- rendering ------------------------------------------------------------

  static String _fmt(Rational r) =>
      r.isInteger ? r.numerator.toString() : '${r.numerator}/${r.denominator}';

  static String _expOf(String k) {
    if (k == '0') return '1';
    if (k == '1') return 'exp(x)';
    if (k == '-1') return 'exp(-x)';
    return 'exp(${_mulXStr(k)})';
  }

  static String _mulX(String k) => _mulXStr(k);

  static String _mulXStr(String k) {
    if (k == '1') return 'x';
    if (k == '-1') return '-x';
    return '$k*x';
  }

  static String _coeffTimes(Rational c, String term) {
    if (c == Rational.one) return term;
    if (c == -Rational.one) return '-$term';
    return '${_fmt(c)}*$term';
  }

  static String _renderPoly(Polynomial p) {
    final parts = <String>[];
    for (var i = p.degree; i >= 0; i--) {
      final c = p.coeffs[i];
      if (c.isZero) continue;
      final mag = c.abs;
      String term;
      if (i == 0) {
        term = _fmt(mag);
      } else {
        final x = i == 1 ? 'x' : 'x^$i';
        term = mag == Rational.one ? x : '${_fmt(mag)}*$x';
      }
      if (parts.isEmpty) {
        parts.add(c.sign < 0 ? '-$term' : term);
      } else {
        parts.add(c.sign < 0 ? '- $term' : '+ $term');
      }
    }
    return parts.isEmpty ? '0' : parts.join(' ');
  }

  static String _scaleExpr(String expr, Rational a) {
    if (a == Rational.one) return expr;
    return '(${_fmt(Rational.one / a)})*($expr)';
  }

  /// Exact rational square root, or null when irrational.
  static Rational? _sqrtRational(Rational r) {
    if (r.sign < 0) return null;
    final n = _isqrt(r.numerator);
    final d = _isqrt(r.denominator);
    if (n * n == r.numerator && d * d == r.denominator) {
      return Rational(n, d);
    }
    return null;
  }

  static String _sqrtString(Rational r) {
    final scaled = r.numerator * r.denominator;
    if (r.isInteger) return 'sqrt(${r.numerator})';
    return '(sqrt($scaled)/${r.denominator})';
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

class _Forcing {
  Polynomial? poly;
  final Map<Rational, Rational> exps = {}; // m -> k  (k·e^{mx})
  final Map<Rational, (Rational, Rational)> trigs =
      {}; // w -> (sinCoeff, cosCoeff)
}
