// lib/engine/symbolic_web.dart
//
// Pure-Dart symbolic CAS for the web (and any other native-less) build —
// the symbolic counterpart to numeric_fallback.dart.
//
// SymEngine is C++/FFI and does not run on the web target, so on the
// browser build every CAS op (`expand`, `differentiate`, `solve`, …)
// used to return "requires native library". This module resolves the
// *single-variable polynomial* subset entirely in Dart, so the most
// common school/teaching cases work in the browser:
//
//   expand((x+1)^2)   → x^2 + 2x + 1
//   diff(x^3)         → 3x^2
//   solve(x^2 - 4)    → {2, -2}
//   solve(x^2 - x - 1)→ {1/2 + 1/2*sqrt(5), 1/2 - 1/2*sqrt(5)}
//
// It deliberately does NOT attempt anything outside that grammar:
// transcendental functions (`sin`, `ln`), several variables, rational
// functions (`1/x`), and degree > 2 equations all return null, and the
// caller (CalculatorEngine) falls through to the native-only path that
// surfaces the "get the app" message. Correct-or-silent: it never
// returns a wrong symbolic answer.
//
// Output format mirrors the native SymEngine/Polynomial convention used
// across the app: `^` for powers, juxtaposed integer coefficients
// (`2x`), exact rational coefficients (`1/2`), high-degree-first.
//
// This is the interim path; the eventual complete web CAS is SymEngine
// compiled to WebAssembly (see PLAN.md "Symbolic-stack survey" → #2).
// Built so the WASM-backed impl can supersede it without UI changes.

import 'polynomial.dart';

class SymbolicWeb {
  /// Expand [input] (parentheses, products, integer powers) into a
  /// canonical single-variable polynomial string, or null when [input]
  /// is outside the supported grammar.
  static String? expand(String input) {
    final p = _parsePolynomial(input);
    if (p == null) return null;
    return p.toString();
  }

  /// Differentiate [input] with respect to [variable]. Returns the
  /// derivative as a polynomial string, or null when [input] isn't a
  /// supported polynomial. A polynomial in a *different* variable
  /// differentiates to 0.
  static String? differentiate(String input, String variable) {
    final p = _parsePolynomial(input);
    if (p == null) return null;
    if (p.degree >= 1 && p.variable != variable) return '0';
    return p.derivative().toString();
  }

  /// Solve `input = 0` (or `lhs = rhs`) for [variable]. Returns the list
  /// of solution strings (possibly surd/complex), an empty list for no
  /// solution, or null when unsupported (degree > 2, wrong variable,
  /// non-polynomial). The caller formats the list.
  static List<String>? solveList(String input, String variable) {
    Polynomial? poly;
    final eq = input.indexOf('=');
    if (eq >= 0) {
      // Guard against ==, <=, >= leaking in from a relational form.
      final lhs = _parsePolynomial(input.substring(0, eq));
      final rhs = _parsePolynomial(input.substring(eq + 1));
      if (lhs == null || rhs == null) return null;
      poly = lhs - rhs;
    } else {
      poly = _parsePolynomial(input);
    }
    if (poly == null) return null;

    final deg = poly.degree;
    if (deg <= 0) {
      // Constant: `5 = 0` has no solution; `0 = 0` is unsupported here.
      return poly.isZero ? null : <String>[];
    }
    if (poly.variable != variable) return null;

    if (deg == 1) {
      // a*x + b = 0  →  x = -b/a
      final a = poly.coeffs[1];
      final b = poly.coeffs[0];
      return [(-b / a).toString()];
    }
    if (deg == 2) {
      return _solveQuadratic(poly.coeffs[2], poly.coeffs[1], poly.coeffs[0]);
    }
    return null; // degree > 2 → native only
  }

  /// Indefinite integral of a single-variable polynomial with respect to
  /// [variable] (the caller appends "+ C"). Exact rational coefficients;
  /// `∫ aᵢxⁱ dx = aᵢ/(i+1) · xⁱ⁺¹`. Returns null outside the polynomial
  /// grammar (the C wrapper stubs integrate(), so this is the web/native-
  /// less answer for the common polynomial case).
  static String? integrate(String input, String variable) {
    final p = _parsePolynomial(input);
    if (p == null) return null;
    // A non-constant polynomial in a *different* variable would integrate
    // to `poly · variable`, which the single-variable model can't hold.
    if (p.degree >= 1 && p.variable != variable) return null;
    if (p.isZero) return '0';

    final v = Polynomial.variable(variable);
    var result = Polynomial.zero(variable);
    for (var i = 0; i < p.coeffs.length; i++) {
      if (p.coeffs[i].isZero) continue;
      final c = p.coeffs[i] / Rational.fromInt(i + 1);
      result = result + Polynomial.constant(c, variable) * v.pow(i + 1);
    }
    return result.toString();
  }

  /// Definite integral of a polynomial over [lower]..[upper] when both
  /// bounds are exact rationals: `F(upper) − F(lower)`. Returns null when
  /// the integrand is non-polynomial or a bound isn't a plain rational
  /// (e.g. `pi`), so the caller can fall through.
  static String? definiteIntegral(
      String input, String variable, String lower, String upper) {
    final p = _parsePolynomial(input);
    if (p == null) return null;
    if (p.degree >= 1 && p.variable != variable) return null;
    final lo = _parseBound(lower);
    final hi = _parseBound(upper);
    if (lo == null || hi == null) return null;

    // Antiderivative coefficients: F has degree+1 terms, F[i+1]=a_i/(i+1).
    final f = <Rational>[Rational.zero];
    for (var i = 0; i < p.coeffs.length; i++) {
      f.add(p.coeffs[i] / Rational.fromInt(i + 1));
    }
    Rational evalF(Rational x) {
      var acc = Rational.zero;
      for (var i = f.length - 1; i >= 0; i--) {
        acc = acc * x + f[i];
      }
      return acc;
    }

    return (evalF(hi) - evalF(lo)).toString();
  }

  static Rational? _parseBound(String s) {
    final t = s.trim();
    final frac = RegExp(r'^(-?\d+)/(\d+)$').firstMatch(t);
    if (frac != null) {
      return Rational(
          BigInt.parse(frac.group(1)!), BigInt.parse(frac.group(2)!));
    }
    final neg = t.startsWith('-');
    final r = _PolyExprParser._rationalFromDecimal(neg ? t.substring(1) : t);
    if (r == null) return null;
    return neg ? -r : r;
  }

  /// Factor a single-variable polynomial over ℚ. Extracts the leading
  /// coefficient and every rational linear factor (with multiplicity) via
  /// the Rational Root Theorem + exact division; any remaining factor with
  /// no rational roots is left intact (it is reported correctly, just not
  /// necessarily fully split — e.g. `x^4 + 4` stays as-is). Returns null
  /// for anything outside the polynomial grammar (multivariate,
  /// transcendental, rational functions), so the caller can fall through.
  ///
  /// This exists because the native C wrapper aliases `factor` to `expand`
  /// (a known correctness bug); doing real factoring in Dart fixes the
  /// common cases on every platform, web included.
  static String? factor(String input) {
    final p = _parsePolynomial(input);
    if (p == null) return null;
    if (p.isZero) return '0';
    final variable = p.variable;
    if (p.degree == 0) return p.coeffs[0].toString();

    final candidates = _rationalRootCandidates(p);
    if (candidates == null) return null; // coefficients too large for RRT

    final c = p.leading;
    var m = p.monic();
    final factors = <({Rational root, int mult})>[];
    for (final r in candidates) {
      var mult = 0;
      final lin = Polynomial.variable(variable) -
          Polynomial.constant(r, variable); // (x - r)
      while (m.degree >= 1 && _evalAt(m, r).isZero) {
        final qr = m.divmod(lin);
        if (!qr.remainder.isZero) break; // defensive; shouldn't happen
        m = qr.quotient;
        mult++;
      }
      if (mult > 0) factors.add((root: r, mult: mult));
    }
    factors.sort((a, b) => (a.root - b.root).sign);
    return _formatFactorization(c, factors, m, variable);
  }

  /// Horner evaluation of [p] at the rational [r].
  static Rational _evalAt(Polynomial p, Rational r) {
    var acc = Rational.zero;
    for (var i = p.coeffs.length - 1; i >= 0; i--) {
      acc = acc * r + p.coeffs[i];
    }
    return acc;
  }

  /// Candidate rational roots p/q (both signs) from the Rational Root
  /// Theorem: p divides the lowest non-zero coefficient, q divides the
  /// leading coefficient. Includes 0 when the constant term is 0. Returns
  /// null when a coefficient is too large to enumerate divisors cheaply.
  static Set<Rational>? _rationalRootCandidates(Polynomial p) {
    final ints = _integerize(p);
    final an = ints.last.abs();
    final lowIdx = ints.indexWhere((v) => v != BigInt.zero);
    final aLow = ints[lowIdx].abs();

    final numDivs = _divisors(aLow);
    final denDivs = _divisors(an);
    if (numDivs == null || denDivs == null) return null;

    final out = <Rational>{};
    if (lowIdx > 0) out.add(Rational.zero); // constant term is 0 → root 0
    for (final num in numDivs) {
      for (final den in denDivs) {
        final r = Rational(num, den);
        out.add(r);
        out.add(-r);
      }
    }
    return out;
  }

  /// Clear denominators: return integer coefficients (low-degree-first)
  /// proportional to [p].
  static List<BigInt> _integerize(Polynomial p) {
    var l = BigInt.one;
    for (final c in p.coeffs) {
      l = _lcm(l, c.denominator);
    }
    return [for (final c in p.coeffs) c.numerator * (l ~/ c.denominator)];
  }

  /// Positive divisors of [n] (n > 0), or null when [n] is too large to
  /// enumerate by trial division.
  static Set<BigInt>? _divisors(BigInt n) {
    if (n <= BigInt.zero) return {BigInt.one};
    if (n > BigInt.from(1000000000000)) return null; // 1e12 cap
    final divs = <BigInt>{};
    var i = BigInt.one;
    while (i * i <= n) {
      if (n % i == BigInt.zero) {
        divs.add(i);
        divs.add(n ~/ i);
      }
      i += BigInt.one;
    }
    return divs;
  }

  static BigInt _gcd(BigInt a, BigInt b) =>
      b == BigInt.zero ? a : _gcd(b, a % b);
  static BigInt _lcm(BigInt a, BigInt b) => a ~/ _gcd(a, b) * b;

  /// Render `c · ∏(x - rᵢ)^mᵢ · remaining` with the app's conventions.
  static String _formatFactorization(
    Rational c,
    List<({Rational root, int mult})> factors,
    Polynomial remaining,
    String variable,
  ) {
    final parts = <String>[];

    String linear(Rational r) {
      if (r.isZero) return variable;
      if (r.sign < 0) return '($variable + ${(-r)})';
      return '($variable - $r)';
    }

    for (final f in factors) {
      final base = linear(f.root);
      parts.add(f.mult > 1 ? '$base^${f.mult}' : base);
    }
    if (remaining.degree >= 1) {
      // Parens only when it sits in a product (other factors or a scalar);
      // a lone irreducible polynomial prints bare (`x^2 + 1`, not `(x^2+1)`).
      final sole = factors.isEmpty && c == Rational.one;
      parts.add(sole ? remaining.toString() : '($remaining)');
    }

    if (parts.isEmpty) return c.toString(); // fully constant
    if (c == Rational.one) return parts.join('*');
    if (c == Rational.fromInt(-1)) return '-${parts.join('*')}';
    return '$c*${parts.join('*')}';
  }

  // --- quadratic ---------------------------------------------------------

  /// Exact roots of `a*x^2 + b*x + c = 0` (a ≠ 0): a single string for a
  /// double root, two for distinct rational / surd / complex roots.
  static List<String> _solveQuadratic(Rational a, Rational b, Rational c) {
    final disc = b * b - Rational.fromInt(4) * a * c;
    final twoA = Rational.fromInt(2) * a;
    final real = -b / twoA;

    if (disc.isZero) return [real.toString()];

    // sqrt(disc) = sqrt(|n|*d) / d  with disc = n/d in lowest terms.
    final n = disc.numerator; // signed
    final d = disc.denominator; // > 0
    final m = n.abs() * d;
    final (sq, k) = _squareDecompose(m);
    // coefficient multiplying sqrt(k): sq/d, then divided by 2a.
    final coef = Rational(sq, d) / twoA;
    final negative = disc.sign < 0;

    if (k == BigInt.one) {
      if (!negative) {
        // Perfect square → two rational roots.
        return [(real + coef).toString(), (real - coef).toString()];
      }
      // Pure imaginary.
      return [
        _surd(real, coef, 'I'),
        _surd(real, -coef, 'I'),
      ];
    }
    final radical = negative ? 'sqrt($k)*I' : 'sqrt($k)';
    return [
      _surd(real, coef, radical),
      _surd(real, -coef, radical),
    ];
  }

  /// Render `real + coef*radical` with the app's coefficient conventions
  /// (drop a zero real part, drop a unit magnitude, sign-aware joiner).
  static String _surd(Rational real, Rational coef, String radical) {
    final buf = StringBuffer();
    final hasReal = !real.isZero;
    if (hasReal) buf.write(real.toString());
    if (coef.isZero) return hasReal ? buf.toString() : '0';

    final neg = coef.sign < 0;
    final mag = coef.abs;
    if (hasReal) {
      buf.write(neg ? ' - ' : ' + ');
    } else if (neg) {
      buf.write('-');
    }
    if (mag != Rational.one) {
      buf.write(mag.toString());
      buf.write('*');
    }
    buf.write(radical);
    return buf.toString();
  }

  /// Decompose a non-negative integer `m` as `sq^2 * k` with `k`
  /// square-free, so `sqrt(m) = sq*sqrt(k)`.
  static (BigInt, BigInt) _squareDecompose(BigInt m) {
    if (m <= BigInt.one) return (BigInt.one, m);
    var sq = BigInt.one;
    var k = m;
    var p = BigInt.two;
    while (p * p <= k) {
      var e = 0;
      while (k % p == BigInt.zero) {
        k = k ~/ p;
        e++;
      }
      if (e > 0) {
        sq *= p.pow(e ~/ 2);
        if (e.isOdd) k *= p; // one factor of p stays in the radicand
      }
      p += BigInt.one;
    }
    // Whatever remains in k is a single prime (square-free).
    return (sq, k);
  }

  // --- polynomial expression parser -------------------------------------

  /// Parse a full polynomial expression — parentheses, `+ - *`, division
  /// by a constant, and non-negative integer powers — into an expanded
  /// [Polynomial]. Returns null on anything outside that grammar.
  static Polynomial? _parsePolynomial(String input) {
    final s = input.replaceAll('**', '^').replaceAll(' ', '');
    if (s.isEmpty || s.contains('=')) return null;
    try {
      final parser = _PolyExprParser(s);
      final p = parser.parseExpr();
      if (!parser.atEnd) return null;
      return p;
    } on _PolyBail {
      return null;
    }
  }
}

class _PolyBail implements Exception {}

/// Recursive-descent parser producing an expanded [Polynomial]. Bails
/// (throws [_PolyBail]) on any unsupported construct.
class _PolyExprParser {
  _PolyExprParser(this.src);
  final String src;
  int _pos = 0;
  String? _variable;

  bool get atEnd => _pos >= src.length;
  String? get _peek => _pos < src.length ? src[_pos] : null;

  String get _variableName => _variable ?? 'x';

  // expr := ('+'|'-')? term (('+'|'-') term)*
  Polynomial parseExpr() {
    var negate = false;
    if (_peek == '+') {
      _pos++;
    } else if (_peek == '-') {
      _pos++;
      negate = true;
    }
    var value = _parseTerm();
    if (negate) value = value.scale(Rational.fromInt(-1));
    while (true) {
      final c = _peek;
      if (c == '+') {
        _pos++;
        value = value + _parseTerm();
      } else if (c == '-') {
        _pos++;
        value = value - _parseTerm();
      } else {
        return value;
      }
    }
  }

  // term := factor (('*' factor) | ('/' const-factor) | implicit-factor)*
  Polynomial _parseTerm() {
    var value = _parseFactor();
    while (true) {
      final c = _peek;
      if (c == '*') {
        _pos++;
        value = value * _parseFactor();
      } else if (c == '/') {
        _pos++;
        final divisor = _parseFactor();
        if (divisor.degree != 0) throw _PolyBail(); // rational function
        value = value.scale(Rational.one / divisor.coeffs[0]);
      } else if (_startsFactor(c)) {
        // Implicit multiplication: 2x, x(x+1), (x+1)(x-1).
        value = value * _parseFactor();
      } else {
        return value;
      }
    }
  }

  bool _startsFactor(String? c) {
    if (c == null) return false;
    return _isDigit(c) || c == '.' || c == '(' || _isLetter(c);
  }

  // factor := base ('^' nonneg-int)?
  Polynomial _parseFactor() {
    var base = _parseBase();
    if (_peek == '^') {
      _pos++;
      base = base.pow(_parseExponent());
    }
    return base;
  }

  // base := number | variable | '(' expr ')'
  Polynomial _parseBase() {
    final c = _peek;
    if (c == null) throw _PolyBail();
    if (c == '(') {
      _pos++;
      final v = parseExpr();
      if (_peek != ')') throw _PolyBail();
      _pos++;
      return v;
    }
    if (_isDigit(c) || c == '.') return _parseNumber();
    if (_isLetter(c)) return _parseVariable();
    throw _PolyBail();
  }

  Polynomial _parseNumber() {
    final start = _pos;
    while (_pos < src.length && _isDigit(src[_pos])) {
      _pos++;
    }
    if (_pos < src.length && src[_pos] == '.') {
      _pos++;
      while (_pos < src.length && _isDigit(src[_pos])) {
        _pos++;
      }
    }
    final text = src.substring(start, _pos);
    final r = _rationalFromDecimal(text);
    if (r == null) throw _PolyBail();
    return Polynomial.constant(r, _variableName);
  }

  Polynomial _parseVariable() {
    final c = src[_pos];
    // A run of two or more letters is a function/constant name (sin, pi,
    // …) — out of scope. Only single-letter variables are polynomial.
    if (_pos + 1 < src.length && _isLetter(src[_pos + 1])) throw _PolyBail();
    _pos++;
    if (_variable != null && _variable != c) throw _PolyBail(); // multivar
    _variable ??= c;
    return Polynomial.variable(c);
  }

  // exponent := nonneg-int | '(' nonneg-int ')'
  int _parseExponent() {
    if (_peek == '(') {
      _pos++;
      final v = _parseExponent();
      if (_peek != ')') throw _PolyBail();
      _pos++;
      return v;
    }
    final start = _pos;
    while (_pos < src.length && _isDigit(src[_pos])) {
      _pos++;
    }
    if (_pos == start) throw _PolyBail(); // x^-2, x^x, x^1.5 → unsupported
    final v = int.tryParse(src.substring(start, _pos));
    if (v == null) throw _PolyBail();
    return v;
  }

  static Rational? _rationalFromDecimal(String s) {
    if (RegExp(r'^\d+$').hasMatch(s)) {
      return Rational(BigInt.parse(s), BigInt.one);
    }
    final dec = RegExp(r'^(\d*)\.(\d+)$').firstMatch(s);
    if (dec != null) {
      final intPart = dec.group(1)!.isEmpty ? '0' : dec.group(1)!;
      final frac = dec.group(2)!;
      final digits = BigInt.parse('$intPart$frac');
      final den = BigInt.from(10).pow(frac.length);
      return Rational(digits, den);
    }
    return null;
  }

  static bool _isDigit(String c) {
    final u = c.codeUnitAt(0);
    return u >= 48 && u <= 57;
  }

  static bool _isLetter(String c) {
    final u = c.codeUnitAt(0);
    return (u >= 65 && u <= 90) || (u >= 97 && u <= 122);
  }
}
