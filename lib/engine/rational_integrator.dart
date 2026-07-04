// Exact integration of rational functions P(x)/Q(x) (roadmap C3).
//
//   ∫ (x^3+1)/x^2      -> x^2/2 - 1/x
//   ∫ 1/(x^2 - 1)      -> 1/2*log(x - 1) - 1/2*log(x + 1)
//   ∫ 1/(x^2 + x + 1)  -> 2/sqrt(3)*atan((2*x + 1)/sqrt(3))
//   ∫ 1/(x - 1)^2      -> -1/(x - 1)
//
// Algorithm (complete for its input class, all in exact ℚ arithmetic):
//   1. polynomial division      P/Q = S + R/Q, deg R < deg Q
//   2. Yun squarefree decomposition of Q = ∏ Dᵢ^i
//   3. partial fractions across the coprime moduli Dᵢ^i
//   4. Hermite-style power reduction via Bézout (1 = σD + τD′) until
//      every remaining integrand is A/D with D squarefree
//   5. split D into ℚ-irreducible factors — native FLINT factor when the
//      bridge is loaded, rational-root extraction otherwise — and emit
//      c·log(x−a) for linear factors and
//      (u/2)·log(q) + κ·atan(…) / κ·log-quotient for quadratics
//      (Δ < 0 / Δ > 0), with exact sqrt(Δ) endpoints.
//
// Irreducible factors of degree ≥ 3 need algebraic logarithms
// (Lazard–Rioboo–Trager) — out of scope here; we return null and the
// caller falls through to the rule walker / numeric path.

import 'calculator_engine.dart';
import 'polynomial.dart';
import 'symbolic_web.dart';

class RationalIntegrator {
  /// Antiderivative of [expression] (a univariate rational function in
  /// [variable]) as an engine-syntax string, or null if the input is not
  /// a rational function this integrator supports.
  static String? integrate(
      CalculatorEngine engine, String expression, String variable) {
    final parts = _splitTopLevelDivision(expression);
    if (parts == null) return null;
    final num = _parsePoly(parts.$1, variable);
    final den = _parsePoly(parts.$2, variable);
    if (num == null || den == null || den.isZero) return null;
    if (den.degree == 0) return null; // plain polynomial — poly path owns it

    // Normalize to monic denominator: P/(c·Qm) = (P/c)/Qm.
    final lc = den.leading;
    final q = den.monic();
    var p = num.scale(Rational.one / lc);

    final out = _Sum(variable);

    // 1. Polynomial part.
    final dm = p.divmod(q);
    out.addPolynomialIntegral(dm.quotient);
    p = dm.remainder;
    if (p.isZero) return out.render();

    // 2. Squarefree decomposition q = ∏ dᵢ^i.
    final sqf = _yun(q);

    // 3. Partial fractions across the coprime moduli dᵢ^i.
    final moduli = <(Polynomial, int)>[];
    for (var i = 0; i < sqf.length; i++) {
      if (sqf[i].degree > 0) moduli.add((sqf[i], i + 1));
    }
    for (final (d, k) in moduli) {
      final m = d.pow(k);
      final rest = _divideExact(q, m);
      // pᵢ = p · rest⁻¹ mod m
      final inv = _modInverse(rest, m);
      if (inv == null) return null; // shouldn't happen (coprime)
      final pi = _mod(p * inv, m);
      if (!_integrateOverPower(engine, out, pi, d, k)) return null;
    }
    return out.render();
  }

  /// ∫ a/d^k with d squarefree, deg a < deg d^k. Returns false when the
  /// final log part needs unsupported (deg ≥ 3 irreducible) factors.
  static bool _integrateOverPower(
      CalculatorEngine engine, _Sum out, Polynomial a, Polynomial d, int k) {
    var cur = a;
    var power = k;
    while (power > 1) {
      // Bézout: 1 = σ·d + τ·d′  (d squarefree ⇒ gcd(d, d′) = 1).
      final bez = _extendedGcd(d, d.derivative());
      if (bez == null) return false;
      final (sigma, tau) = bez;
      // cur/d^power = cur·σ/d^(power-1) + cur·τ·d′/d^power, and the
      // second term integrates by parts:
      //   ∫ cur·τ·d′/d^power = −cur·τ/((power−1)·d^(power−1))
      //                        + ∫ (cur·τ)′/((power−1)·d^(power−1))
      final ct = _mod(cur * tau, d.pow(power)); // keep degrees sane
      final w = Rational.one / Rational.fromInt(power - 1);
      out.addRationalTerm(ct.scale(-w), d, power - 1);
      cur = _mod(cur * sigma + ct.derivative().scale(w), d.pow(power - 1));
      power--;
    }
    // Now ∫ cur/d: split off any polynomial part, then logs.
    final dm = cur.divmod(d);
    out.addPolynomialIntegral(dm.quotient);
    final r = dm.remainder;
    if (r.isZero) return true;
    return _logPart(engine, out, r, d);
  }

  /// ∫ r/d with d squarefree monic, deg r < deg d: split d into
  /// ℚ-irreducible monic factors and emit log/atan terms.
  static bool _logPart(
      CalculatorEngine engine, _Sum out, Polynomial r, Polynomial d) {
    final factors = _irreducibleFactors(engine, d);
    if (factors == null) return false;
    for (final f in factors) {
      final rest = _divideExact(d, f);
      Polynomial rj;
      if (rest.degree == 0) {
        rj = r.scale(Rational.one / rest.coeffs[0]);
      } else {
        final inv = _modInverse(rest, f);
        if (inv == null) return false;
        rj = _mod(r * inv, f);
      }
      if (rj.isZero) continue;
      if (f.degree == 1) {
        // f = x + a  (monic) → c·log(x + a), c = rj (a constant).
        out.addLog(rj.coeffs[0], f);
      } else if (f.degree == 2) {
        out.addQuadraticLogAtan(rj, f);
      } else {
        return false; // needs Lazard–Rioboo–Trager
      }
    }
    return true;
  }

  // --- ℚ[x] helper algorithms -------------------------------------------

  /// Yun's squarefree decomposition: returns [a1, a2, …] with
  /// input = ∏ aᵢ^i (monic input assumed; factors monic).
  static List<Polynomial> _yun(Polynomial p) {
    final result = <Polynomial>[];
    var g = Polynomial.gcd(p, p.derivative());
    if (g.degree == 0) return [p];
    var b = _divideExact(p, g);
    var c = _divideExact(p.derivative(), g);
    var d = c - b.derivative();
    while (true) {
      final a = Polynomial.gcd(b, d);
      result.add(a);
      b = _divideExact(b, a);
      if (b.degree == 0) break;
      c = _divideExact(d, a);
      d = c - b.derivative();
    }
    return result;
  }

  /// Extended Euclid on monic-friendly ℚ[x]: returns (s, t) with
  /// s·a + t·b = 1, or null if gcd(a, b) ≠ 1.
  static (Polynomial, Polynomial)? _extendedGcd(Polynomial a, Polynomial b) {
    final v = a.variable;
    var r0 = a, r1 = b;
    var s0 = Polynomial.constant(Rational.one, v), s1 = Polynomial.zero(v);
    var t0 = Polynomial.zero(v), t1 = Polynomial.constant(Rational.one, v);
    while (!r1.isZero) {
      final dm = r0.divmod(r1);
      final q = dm.quotient;
      (r0, r1) = (r1, dm.remainder);
      (s0, s1) = (s1, s0 - q * s1);
      (t0, t1) = (t1, t0 - q * t1);
    }
    if (r0.degree != 0) return null; // non-trivial gcd
    final inv = Rational.one / r0.coeffs[0];
    return (s0.scale(inv), t0.scale(inv));
  }

  /// a⁻¹ mod m, or null when not coprime.
  static Polynomial? _modInverse(Polynomial a, Polynomial m) {
    final bez = _extendedGcd(_mod(a, m), m);
    return bez?.$1;
  }

  static Polynomial _mod(Polynomial a, Polynomial m) => a.divmod(m).remainder;

  /// Exact division (throws-by-assert if not exact — callers only divide
  /// known divisors).
  static Polynomial _divideExact(Polynomial a, Polynomial b) {
    final dm = a.divmod(b);
    assert(dm.remainder.isZero, 'non-exact polynomial division');
    return dm.quotient;
  }

  /// Split d (squarefree monic) into ℚ-irreducible monic factors.
  /// Native: FLINT factor via the bridge. Fallback: rational-root
  /// extraction + a deg ≤ 2 remainder. Null when neither succeeds.
  static List<Polynomial>? _irreducibleFactors(
      CalculatorEngine engine, Polynomial d) {
    if (d.degree == 1) return [d];

    if (engine.isNativeAvailable) {
      final parsed = _factorViaEngine(engine, d);
      if (parsed != null) return parsed;
    }

    // Fallback: strip rational roots via the pure-Dart factorer.
    final factored = SymbolicWeb.factor(_renderPoly(d));
    if (factored != null) {
      final parsed = _parseFactorProduct(factored, d);
      if (parsed != null) return parsed;
    }
    return d.degree <= 2 ? [d] : null;
  }

  static List<Polynomial>? _factorViaEngine(
      CalculatorEngine engine, Polynomial d) {
    // FLINT factors over ℤ — clear denominators first.
    var lcm = BigInt.one;
    for (final c in d.coeffs) {
      lcm = lcm * (c.denominator ~/ lcm.gcd(c.denominator));
    }
    final cleared = d.scale(Rational(lcm, BigInt.one));
    final out = engine.factor(_renderPoly(cleared));
    if (out.startsWith('Error')) return null;
    return _parseFactorProduct(out, d);
  }

  /// Parse "(2*x - 1)*(x + 3)^2*5" into monic factors, checking the
  /// product matches [expected] up to a constant.
  static List<Polynomial>? _parseFactorProduct(
      String product, Polynomial expected) {
    final v = expected.variable;
    final factors = <Polynomial>[];
    for (final piece in _splitTopLevelStars(product.replaceAll(' ', ''))) {
      var body = piece;
      var exp = 1;
      final pm = RegExp(r'^\((.*)\)\^(\d+)$').firstMatch(body);
      if (pm != null) {
        body = pm.group(1)!;
        exp = int.parse(pm.group(2)!);
      } else if (body.startsWith('(') && body.endsWith(')')) {
        body = body.substring(1, body.length - 1);
      }
      final poly = Polynomial.tryParse(body);
      if (poly == null) return null;
      if (poly.degree == 0) continue; // constant — absorbed by monic form
      if (poly.variable != v && poly.degree > 0) return null;
      for (var i = 0; i < exp; i++) {
        factors.add(poly.monic());
      }
    }
    // Verify: ∏ factors == expected (both monic).
    var prod = Polynomial.constant(Rational.one, v);
    for (final f in factors) {
      prod = prod * f;
    }
    if (_renderPoly(prod) != _renderPoly(expected.monic())) return null;
    return factors;
  }

  static List<String> _splitTopLevelStars(String s) {
    final parts = <String>[];
    var depth = 0, start = 0;
    for (var i = 0; i < s.length; i++) {
      final ch = s[i];
      if (ch == '(') depth++;
      if (ch == ')') depth--;
      if (ch == '*' && depth == 0) {
        // `^` exponents keep their `*`-free form, so a bare top-level
        // star is always a factor separator here.
        parts.add(s.substring(start, i));
        start = i + 1;
      }
    }
    parts.add(s.substring(start));
    return parts.where((p) => p.isNotEmpty).toList();
  }

  // --- input parsing ------------------------------------------------------

  static (String, String)? _splitTopLevelDivision(String s) {
    var depth = 0;
    int? slash;
    for (var i = 0; i < s.length; i++) {
      final ch = s[i];
      if (ch == '(' || ch == '[') depth++;
      if (ch == ')' || ch == ']') depth--;
      if (ch == '/' && depth == 0) {
        if (slash != null) return null; // a/b/c — not supported
        slash = i;
      }
    }
    if (slash == null) return null;
    final num = s.substring(0, slash).trim();
    final den = s.substring(slash + 1).trim();
    if (num.isEmpty || den.isEmpty) return null;
    return (num, den);
  }

  static Polynomial? _parsePoly(String s, String variable) {
    var t = s.trim();
    while (t.startsWith('(') && t.endsWith(')')) {
      // strip if the parens match each other
      var depth = 0;
      var wraps = true;
      for (var i = 0; i < t.length; i++) {
        if (t[i] == '(') depth++;
        if (t[i] == ')') depth--;
        if (depth == 0 && i < t.length - 1) {
          wraps = false;
          break;
        }
      }
      if (!wraps) break;
      t = t.substring(1, t.length - 1).trim();
    }
    var p = Polynomial.tryParse(t);
    if (p == null) {
      // Parenthesized / product forms: expand to the canonical string
      // first (pure Dart; null for anything non-polynomial).
      final expanded = SymbolicWeb.expand(t);
      if (expanded == null) return null;
      p = Polynomial.tryParse(expanded);
    }
    if (p == null) return null;
    if (p.degree > 0 && p.variable != variable) return null;
    return Polynomial.fromCoeffs(p.coeffs, variable);
  }

  static String _renderPoly(Polynomial p) => _Sum.renderPoly(p);
}

/// Accumulates the answer's terms and renders the final string.
class _Sum {
  final String v;
  final List<String> _terms = [];
  _Sum(this.v);

  static String fmtRational(Rational r) =>
      r.isInteger ? r.numerator.toString() : '${r.numerator}/${r.denominator}';

  /// "x^2/2 + 3*x" style polynomial rendering (descending powers).
  static String renderPoly(Polynomial p) {
    if (p.isZero) return '0';
    final parts = <String>[];
    for (var i = p.degree; i >= 0; i--) {
      final c = p.coeffs[i];
      if (c.isZero) continue;
      final mag = c.abs;
      final coeffStr = fmtRational(mag);
      String term;
      if (i == 0) {
        term = coeffStr;
      } else {
        final x = i == 1 ? p.variable : '${p.variable}^$i';
        term = mag == Rational.one ? x : '$coeffStr*$x';
      }
      if (parts.isEmpty) {
        parts.add(c.sign < 0 ? '-$term' : term);
      } else {
        parts.add(c.sign < 0 ? '- $term' : '+ $term');
      }
    }
    return parts.join(' ');
  }

  void _add(String term, {required bool negative}) {
    if (_terms.isEmpty) {
      _terms.add(negative ? '-$term' : term);
    } else {
      _terms.add(negative ? '- $term' : '+ $term');
    }
  }

  /// ∫ poly dx, added term by term.
  void addPolynomialIntegral(Polynomial p) {
    for (var i = 0; i <= p.degree && !p.isZero; i++) {
      final c = p.coeffs[i];
      if (c.isZero) continue;
      final integrated = c / Rational.fromInt(i + 1);
      final mag = integrated.abs;
      final x = i == 0 ? v : '$v^${i + 1}';
      final term = mag == Rational.one ? x : '${fmtRational(mag)}*$x';
      _add(term, negative: integrated.sign < 0);
    }
  }

  /// numer/denomPoly^power (the Hermite rational part).
  void addRationalTerm(Polynomial numer, Polynomial denom, int power) {
    if (numer.isZero) return;
    // Pull a leading sign out for readability when the numerator is a
    // negative constant.
    var n = numer;
    var negative = false;
    if (n.degree == 0 && n.coeffs[0].sign < 0) {
      negative = true;
      n = n.scale(Rational.fromInt(-1));
    }
    final numStr =
        n.degree == 0 ? fmtRational(n.coeffs[0]) : '(${renderPoly(n)})';
    final denStr =
        power == 1 ? '(${renderPoly(denom)})' : '(${renderPoly(denom)})^$power';
    _add('$numStr/$denStr', negative: negative);
  }

  /// c·log(f) for a linear (or any) monic factor f.
  void addLog(Rational c, Polynomial f) {
    if (c.isZero) return;
    final mag = c.abs;
    final logStr = 'log(${renderPoly(f)})';
    final term = mag == Rational.one ? logStr : '${fmtRational(mag)}*$logStr';
    _add(term, negative: c.sign < 0);
  }

  /// ∫ (u·x + w)/f for monic irreducible quadratic f = x² + b·x + c:
  ///   (u/2)·log(f) + κ·atan((2x+b)/√(−Δ))        (Δ < 0)
  ///   (u/2)·log(f) + κ′·log((2x+b−√Δ)/(2x+b+√Δ)) (Δ > 0)
  /// with Δ = b² − 4c and κ = (w − u·b/2)·2/√(−Δ), κ′ = (w − u·b/2)/√Δ.
  void addQuadraticLogAtan(Polynomial r, Polynomial f) {
    final u = r.degree >= 1 ? r.coeffs[1] : Rational.zero;
    final w = r.coeffs.isNotEmpty ? r.coeffs[0] : Rational.zero;
    final b = f.coeffs[1];
    final c = f.coeffs[0];
    final half = Rational(BigInt.one, BigInt.two);

    final logCoeff = u * half;
    addLog(logCoeff, f);

    final rest = w - u * b * half; // coefficient of ∫ 1/f
    if (rest.isZero) return;
    final delta = b * b - Rational.fromInt(4) * c;
    final lin = '(${renderPoly(Polynomial.fromCoeffs([
          b,
          Rational.fromInt(2),
        ], f.variable))})'; // (2x + b) rendered via poly for exact b

    if (delta.sign < 0) {
      final negDelta = -delta;
      final root = _sqrtString(negDelta);
      final k = rest * Rational.fromInt(2);
      final mag = k.abs;
      final term = '${_coeffOverRoot(mag, root)}atan($lin/$root)';
      _add(term, negative: k.sign < 0);
    } else {
      final root = _sqrtString(delta);
      final mag = rest.abs;
      final term =
          '${_coeffOverRoot(mag, root)}log(($lin - $root)/($lin + $root))';
      _add(term, negative: rest.sign < 0);
    }
  }

  /// "c/sqrt(d)*" (or "1/sqrt(d)*" collapsed) prefix for atan/log terms.
  static String _coeffOverRoot(Rational mag, String root) =>
      mag == Rational.one ? '1/$root*' : '${fmtRational(mag)}/$root*';

  /// Exact sqrt string; extracts perfect-square parts of the rational.
  static String _sqrtString(Rational r) {
    // sqrt(p/q) = sqrt(p*q)/q
    final scaled = r.numerator * r.denominator;
    final root = _isqrt(scaled);
    if (root * root == scaled) {
      return fmtRational(Rational(root, r.denominator));
    }
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

  String render() => _terms.isEmpty ? '0' : _terms.join(' ');
}
