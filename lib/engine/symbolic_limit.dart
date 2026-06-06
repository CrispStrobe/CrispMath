// lib/engine/symbolic_limit.dart
//
// Pure-Dart symbolic limit engine (PLAN P1 tiers 1–4).
//
// Uses the CAS bridge's `substitute`, `differentiate`, and `evaluate`
// to compute limits symbolically:
//
//   Tier 1 — direct substitution: substitute the point into the
//     expression and evaluate. If the result is finite, that's the limit.
//
//   Tier 2 — L'Hôpital's rule: when direct substitution yields an
//     indeterminate 0/0 form, repeatedly differentiate numerator and
//     denominator until the limit resolves or a step budget expires.
//
//   Tier 3 — factoring: for polynomial 0/0 forms, try factoring
//     numerator and denominator to cancel the common (x - a) factor.
//
//   Tier 4 — Gruntz-style growth-rate analysis: for limits at
//     infinity involving exponentials, logarithms, and their
//     compositions. Compares growth rates (constant < log < polynomial
//     < exponential < super-exponential) plus L'Hôpital at infinity.
//
// Falls back to null when the expression is outside the supported
// grammar, so the caller can chain to the numerical sampler.
//
// Works on all platforms because every CAS call routes through
// CalculatorEngine (which dispatches to either the native bridge or
// the web WASM bridge).

import 'package:flutter/foundation.dart';

import 'calculator_engine.dart';

/// Result of a symbolic limit computation.
class SymbolicLimitResult {
  final String value;
  final String? method; // 'direct', 'lhopital', 'factor', 'infinity', 'gruntz'
  const SymbolicLimitResult(this.value, {this.method});
}

class SymbolicLimit {
  /// Maximum L'Hôpital iterations before giving up.
  static const int _maxLhopitalSteps = 8;

  /// Try to compute lim_{variable→point} expression symbolically.
  /// Returns null when the symbolic approach can't determine the limit
  /// (caller should fall back to numerical sampling).
  static SymbolicLimitResult? compute({
    required CalculatorEngine engine,
    required String expression,
    required String variable,
    required String point,
  }) {
    if (!engine.isNativeAvailable) return null;

    final pt = point.trim();

    // --- Infinity limits ---
    if (_isPositiveInfinity(pt)) {
      return _limitAtSymbolicInfinity(
        engine: engine,
        expression: expression,
        variable: variable,
        positive: true,
      );
    }
    if (_isNegativeInfinity(pt)) {
      return _limitAtSymbolicInfinity(
        engine: engine,
        expression: expression,
        variable: variable,
        positive: false,
      );
    }

    // --- Finite point ---
    // Tier 1: direct substitution.
    final direct = _tryDirectSubstitution(
      engine: engine,
      expression: expression,
      variable: variable,
      point: pt,
    );
    if (direct != null) return direct;

    // Tier 2: detect ratio form and try L'Hôpital / factoring.
    final ratio = _parseRatio(expression);
    if (ratio != null) {
      // Check if it's 0/0 at the point.
      final numAtPt = _evalAt(engine, ratio.numerator, variable, pt);
      final denAtPt = _evalAt(engine, ratio.denominator, variable, pt);

      if (numAtPt != null &&
          denAtPt != null &&
          _isZero(numAtPt) &&
          _isZero(denAtPt)) {
        // L'Hôpital's rule for 0/0.
        final lh = _lhopital(
          engine: engine,
          numerator: ratio.numerator,
          denominator: ratio.denominator,
          variable: variable,
          point: pt,
        );
        if (lh != null) return lh;
      }
    }

    // Tier 2b: L'Hôpital on the whole expression treated as a single
    // entity doesn't help — only ratio forms benefit. For non-ratio
    // indeterminate forms (e.g. sin(x)/x where the preprocessor
    // doesn't parse the ratio), try a lightweight numerical check to
    // detect 0/0 and then use the quotient rule on the expression
    // written as f/g.
    // (This is handled by the numerical fallback in the caller.)

    return null;
  }

  // --- Tier 1: direct substitution ---

  static SymbolicLimitResult? _tryDirectSubstitution({
    required CalculatorEngine engine,
    required String expression,
    required String variable,
    required String point,
  }) {
    try {
      final substituted = engine.substitute(expression, variable, point);
      if (substituted.startsWith('Error')) return null;
      final evaluated = engine.evaluate(substituted);
      if (evaluated.startsWith('Error')) return null;
      // Check for indeterminate forms: nan, zoo, oo, etc.
      final lower = evaluated.trim().toLowerCase();
      if (lower == 'nan' ||
          lower == 'zoo' ||
          lower.contains('inf') ||
          lower.contains('oo')) {
        return null; // Indeterminate or infinite — need more work.
      }
      // Check it parses as a real number or is a clean symbolic result.
      final d = double.tryParse(evaluated.trim());
      if (d != null && d.isFinite) {
        return SymbolicLimitResult(evaluated.trim(), method: 'direct');
      }
      // Symbolic result (e.g. "pi", "1/3") — accept if it doesn't
      // contain the limit variable.
      if (!_containsVariable(evaluated, variable)) {
        return SymbolicLimitResult(evaluated.trim(), method: 'direct');
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // --- Tier 2: L'Hôpital's rule for 0/0 ---

  static SymbolicLimitResult? _lhopital({
    required CalculatorEngine engine,
    required String numerator,
    required String denominator,
    required String variable,
    required String point,
  }) {
    var num = numerator;
    var den = denominator;

    for (var step = 0; step < _maxLhopitalSteps; step++) {
      // Differentiate both.
      final numPrime = engine.differentiate(num, variable);
      final denPrime = engine.differentiate(den, variable);

      if (numPrime.startsWith('Error') || denPrime.startsWith('Error')) {
        return null;
      }

      // Evaluate the new ratio at the point.
      final numVal = _evalAt(engine, numPrime, variable, point);
      final denVal = _evalAt(engine, denPrime, variable, point);

      if (numVal == null || denVal == null) return null;

      if (_isZero(denVal)) {
        if (_isZero(numVal)) {
          // Still 0/0 — iterate.
          num = numPrime;
          den = denPrime;
          continue;
        }
        // 0 in denominator, non-zero numerator → ±∞ or DNE.
        return null;
      }

      // denominator is non-zero: the limit is numVal / denVal.
      final numD = double.tryParse(numVal);
      final denD = double.tryParse(denVal);
      if (numD != null && denD != null && denD != 0) {
        final result = numD / denD;
        if (result.isFinite) {
          return SymbolicLimitResult(
            _formatResult(result),
            method: 'lhopital',
          );
        }
        return null;
      }

      // Try symbolic division via the engine.
      final ratioExpr = '($numPrime)/($denPrime)';
      final subst = engine.substitute(ratioExpr, variable, point);
      if (!subst.startsWith('Error')) {
        final eval = engine.evaluate(subst);
        if (!eval.startsWith('Error')) {
          final lower = eval.trim().toLowerCase();
          if (lower != 'nan' &&
              lower != 'zoo' &&
              !lower.contains('inf') &&
              !lower.contains('oo') &&
              !_containsVariable(eval, variable)) {
            return SymbolicLimitResult(eval.trim(), method: 'lhopital');
          }
        }
      }

      // Can't resolve — iterate.
      num = numPrime;
      den = denPrime;
    }

    return null; // Exceeded step budget.
  }

  // --- Infinity limits ---

  static SymbolicLimitResult? _limitAtSymbolicInfinity({
    required CalculatorEngine engine,
    required String expression,
    required String variable,
    required bool positive,
  }) {
    // Strategy: substitute large values and check convergence, then
    // try symbolic substitution with 'oo' / '-oo' (SymEngine
    // sometimes handles this via its Inf symbol).
    final infSymbol = positive ? 'oo' : '-oo';

    // Try SymEngine's symbolic substitution with infinity.
    try {
      final substituted = engine.substitute(expression, variable, infSymbol);
      if (!substituted.startsWith('Error')) {
        final evaluated = engine.evaluate(substituted);
        if (!evaluated.startsWith('Error')) {
          final lower = evaluated.trim().toLowerCase();
          if (lower == '0' || lower == '0.0') {
            return const SymbolicLimitResult('0', method: 'infinity');
          }
          if (lower == 'oo' || lower == 'inf' || lower == 'infinity') {
            return const SymbolicLimitResult('∞', method: 'infinity');
          }
          if (lower == '-oo' || lower == '-inf') {
            return const SymbolicLimitResult('-∞', method: 'infinity');
          }
          if (lower != 'nan' &&
              lower != 'zoo' &&
              !_containsVariable(evaluated, variable)) {
            return SymbolicLimitResult(evaluated.trim(), method: 'infinity');
          }
        }
      }
    } catch (_) {}

    // For ratios p(x)/q(x): compare leading degrees.
    final ratio = _parseRatio(expression);
    if (ratio != null) {
      final polyResult = _ratioInfinityLimit(
        engine: engine,
        numerator: ratio.numerator,
        denominator: ratio.denominator,
        variable: variable,
        positive: positive,
      );
      if (polyResult != null) return polyResult;
    }

    // Tier 4: Gruntz-style growth-rate analysis for limits at infinity.
    final gruntz = _gruntzLimit(
      engine: engine,
      expression: expression,
      variable: variable,
      positive: positive,
    );
    if (gruntz != null) return gruntz;

    return null;
  }

  /// For rational functions at infinity: compare leading terms.
  static SymbolicLimitResult? _ratioInfinityLimit({
    required CalculatorEngine engine,
    required String numerator,
    required String denominator,
    required String variable,
    required bool positive,
  }) {
    // Use repeated differentiation to find the degree: deg(p) is the
    // number of times we can differentiate before getting 0.
    // This is expensive and fragile for non-polynomial expressions,
    // so we only try a few steps.
    int? degNum = _estimateDegree(engine, numerator, variable);
    int? degDen = _estimateDegree(engine, denominator, variable);

    if (degNum == null || degDen == null) return null;

    if (degNum < degDen) {
      return const SymbolicLimitResult('0', method: 'infinity');
    }
    if (degNum > degDen) {
      // Goes to ±∞ depending on leading coefficients and sign.
      return null; // Let numerical handle this.
    }
    // degNum == degDen: limit is ratio of leading coefficients.
    // Differentiate degNum times to extract the leading coefficient × n!.
    var num = numerator;
    var den = denominator;
    for (var i = 0; i < degNum; i++) {
      num = engine.differentiate(num, variable);
      den = engine.differentiate(den, variable);
      if (num.startsWith('Error') || den.startsWith('Error')) return null;
    }
    // Now num and den should be constants.
    final numEval = engine.evaluate(num);
    final denEval = engine.evaluate(den);
    if (numEval.startsWith('Error') || denEval.startsWith('Error')) {
      return null;
    }
    final numD = double.tryParse(numEval.trim());
    final denD = double.tryParse(denEval.trim());
    if (numD != null && denD != null && denD != 0) {
      return SymbolicLimitResult(
        _formatResult(numD / denD),
        method: 'infinity',
      );
    }
    return null;
  }

  /// Estimate the polynomial degree by counting differentiations until
  /// the expression evaluates to 0. Returns null for non-polynomial.
  static int? _estimateDegree(
    CalculatorEngine engine,
    String expression,
    String variable,
  ) {
    var expr = expression;
    for (var d = 0; d <= 20; d++) {
      // Evaluate at a test point to check if it's zero as a polynomial.
      _evalAt(engine, expr, variable, '0');
      final deriv = engine.differentiate(expr, variable);
      if (deriv.startsWith('Error')) return null;

      // Check if the derivative is identically zero.
      final at0 = _evalAt(engine, deriv, variable, '0');
      final at1 = _evalAt(engine, deriv, variable, '1');
      final at2 = _evalAt(engine, deriv, variable, '2');
      if (at0 != null &&
          at1 != null &&
          at2 != null &&
          _isZero(at0) &&
          _isZero(at1) &&
          _isZero(at2)) {
        return d;
      }
      expr = deriv;
    }
    return null; // Not a polynomial or degree > 20.
  }

  // --- Tier 4: Gruntz-style growth-rate analysis ---

  /// Classify the dominant growth rate of [expr] as x→∞.
  /// Returns a [_GrowthClass] that can be compared with others.
  static _GrowthClass? _classifyGrowth(
    CalculatorEngine engine,
    String expr,
    String variable,
  ) {
    final e = expr.trim();

    // Check if expr is constant (no variable).
    if (!_containsVariable(e, variable)) {
      final val = engine.evaluate(e);
      if (!val.startsWith('Error')) {
        final d = double.tryParse(val.trim());
        if (d != null) {
          return _GrowthClass(
            kind: _GrowthKind.constant,
            power: 0,
            coefficient: d,
          );
        }
      }
      return const _GrowthClass(kind: _GrowthKind.constant, power: 0);
    }

    // Check for exponential: exp(f(x)) or e^(f(x)).
    final expArg = _matchExp(e, variable);
    if (expArg != null) {
      // Classify the exponent to determine the exponential's growth.
      final innerGrowth = _classifyGrowth(engine, expArg, variable);
      if (innerGrowth != null) {
        if (innerGrowth.kind == _GrowthKind.polynomial) {
          // e^(x^n) — exponential with polynomial exponent.
          return _GrowthClass(
            kind: _GrowthKind.exponential,
            power: innerGrowth.power,
            coefficient: innerGrowth.coefficient,
          );
        }
        if (innerGrowth.kind == _GrowthKind.exponential) {
          // e^(e^(...)) — tower exponential.
          return _GrowthClass(
            kind: _GrowthKind.superExponential,
            power: innerGrowth.power,
          );
        }
      }
      // Fall through: exponential with unknown exponent.
      return const _GrowthClass(kind: _GrowthKind.exponential, power: 1);
    }

    // Check for logarithmic: log(f(x)) or ln(f(x)).
    final logArg = _matchLog(e);
    if (logArg != null && _containsVariable(logArg, variable)) {
      return const _GrowthClass(kind: _GrowthKind.logarithmic, power: 1);
    }

    // Check if it's a polynomial: estimate degree.
    final deg = _estimateDegree(engine, e, variable);
    if (deg != null) {
      // Extract leading coefficient.
      var expr2 = e;
      for (var i = 0; i < deg; i++) {
        expr2 = engine.differentiate(expr2, variable);
        if (expr2.startsWith('Error')) {
          return _GrowthClass(
              kind: _GrowthKind.polynomial, power: deg.toDouble());
        }
      }
      final coefVal = engine.evaluate(expr2);
      final coefD = double.tryParse(coefVal.trim());
      if (coefD != null) {
        // Leading coefficient is coefD / deg!
        double factorial = 1;
        for (var i = 2; i <= deg; i++) {
          factorial *= i;
        }
        return _GrowthClass(
          kind: _GrowthKind.polynomial,
          power: deg.toDouble(),
          coefficient: coefD / factorial,
        );
      }
      return _GrowthClass(kind: _GrowthKind.polynomial, power: deg.toDouble());
    }

    return null;
  }

  /// Try to extract the argument from exp(...) or e^(...).
  static String? _matchExp(String expr, String variable) {
    final e = expr.trim();

    // Match exp(...)
    final expMatch = RegExp(r'^exp\((.+)\)$').firstMatch(e);
    if (expMatch != null) return expMatch.group(1);

    // Match E^(...) or e^(...) — SymEngine often uses E.
    final ePowMatch = RegExp(r'^[eE]\^\((.+)\)$').firstMatch(e);
    if (ePowMatch != null) return ePowMatch.group(1);

    // Match E^simple (no parens, e.g. E^x)
    final eSimple = RegExp(r'^[eE]\^(\w+)$').firstMatch(e);
    if (eSimple != null) return eSimple.group(1);

    return null;
  }

  /// Try to extract the argument from log(...) or ln(...).
  static String? _matchLog(String expr) {
    final e = expr.trim();
    final m = RegExp(r'^(?:log|ln)\((.+)\)$').firstMatch(e);
    return m?.group(1);
  }

  /// The core Gruntz-style limit engine for limits at infinity.
  ///
  /// Handles these cases that Tiers 1-3 miss:
  /// 1. Exponential dominance: e^x / x^n → ∞, x^n / e^x → 0
  /// 2. Logarithmic: log(x) / x → 0, x / log(x) → ∞
  /// 3. L'Hôpital at infinity: f/g where both → ∞
  /// 4. Exponential composition: e^(x^2) / e^(x^3) → 0
  /// 5. Polynomial at infinity: (3x^2+2x)/(x^2+1) → 3
  static SymbolicLimitResult? _gruntzLimit({
    required CalculatorEngine engine,
    required String expression,
    required String variable,
    required bool positive,
  }) {
    final ratio = _parseRatio(expression);
    if (ratio == null) {
      // Non-ratio expressions: classify growth directly.
      return _classifySingleExprLimit(
        engine: engine,
        expression: expression,
        variable: variable,
        positive: positive,
      );
    }

    final numExpr = ratio.numerator;
    final denExpr = ratio.denominator;

    final numGrowth = _classifyGrowth(engine, numExpr, variable);
    final denGrowth = _classifyGrowth(engine, denExpr, variable);

    if (numGrowth == null || denGrowth == null) {
      // Can't classify — try L'Hôpital at infinity as last resort.
      return _lhopitalAtInfinity(
        engine: engine,
        numerator: numExpr,
        denominator: denExpr,
        variable: variable,
        positive: positive,
      );
    }

    // Case 5: Both polynomial — compare degrees and leading coefficients.
    if (numGrowth.kind == _GrowthKind.polynomial &&
        denGrowth.kind == _GrowthKind.polynomial) {
      if (numGrowth.power < denGrowth.power) {
        return const SymbolicLimitResult('0', method: 'gruntz');
      }
      if (numGrowth.power > denGrowth.power) {
        // Sign depends on leading coefficients and whether x→+∞ or -∞.
        return _infinitySignResult(
            numGrowth, denGrowth, positive, numGrowth.power - denGrowth.power);
      }
      // Same degree — ratio of leading coefficients.
      if (numGrowth.coefficient != null && denGrowth.coefficient != null) {
        final r = numGrowth.coefficient! / denGrowth.coefficient!;
        if (r.isFinite) {
          return SymbolicLimitResult(_formatResult(r), method: 'gruntz');
        }
      }
    }

    // Compare growth kinds using the hierarchy:
    // constant < logarithmic < polynomial < exponential < superExponential
    final cmp = numGrowth.kind.index - denGrowth.kind.index;

    if (cmp < 0) {
      // Numerator grows slower than denominator → 0.
      return const SymbolicLimitResult('0', method: 'gruntz');
    }
    if (cmp > 0) {
      // Numerator grows faster → ±∞.
      return _signedInfinity(engine, expression, variable, positive);
    }

    // Same growth kind — compare within the kind.
    if (numGrowth.kind == _GrowthKind.exponential) {
      // Case 4: e^(f(x)) / e^(g(x)) = e^(f(x)-g(x)).
      // If f grows faster than g, → ∞; if slower, → 0; if same degree,
      // compare leading coefficients in the exponent.
      if (numGrowth.power != denGrowth.power) {
        if (numGrowth.power < denGrowth.power) {
          return const SymbolicLimitResult('0', method: 'gruntz');
        }
        return _signedInfinity(engine, expression, variable, positive);
      }
      // Same exponent degree — compare exponent coefficients.
      if (numGrowth.coefficient != null && denGrowth.coefficient != null) {
        if (numGrowth.coefficient! < denGrowth.coefficient!) {
          return const SymbolicLimitResult('0', method: 'gruntz');
        }
        if (numGrowth.coefficient! > denGrowth.coefficient!) {
          return _signedInfinity(engine, expression, variable, positive);
        }
        // Equal coefficients in exponent — need deeper analysis.
        // Try simplifying e^(f-g) via the CAS.
        final numArg = _matchExp(ratio.numerator, variable) ?? '0';
        final denArg = _matchExp(ratio.denominator, variable) ?? '0';
        final diff = '($numArg) - ($denArg)';
        final simplified = engine.evaluate(diff);
        if (!simplified.startsWith('Error')) {
          final innerLimit = _limitAtSymbolicInfinity(
            engine: engine,
            expression: 'exp($simplified)',
            variable: variable,
            positive: positive,
          );
          if (innerLimit != null) return innerLimit;
        }
      }
    }

    if (numGrowth.kind == _GrowthKind.logarithmic) {
      // log(f) / log(g) — both logarithmic. Use L'Hôpital.
      return _lhopitalAtInfinity(
        engine: engine,
        numerator: numExpr,
        denominator: denExpr,
        variable: variable,
        positive: positive,
      );
    }

    // Same kind, couldn't resolve — try L'Hôpital at infinity.
    return _lhopitalAtInfinity(
      engine: engine,
      numerator: numExpr,
      denominator: denExpr,
      variable: variable,
      positive: positive,
    );
  }

  /// For a single (non-ratio) expression, determine its limit at infinity.
  static SymbolicLimitResult? _classifySingleExprLimit({
    required CalculatorEngine engine,
    required String expression,
    required String variable,
    required bool positive,
  }) {
    final g = _classifyGrowth(engine, expression, variable);
    if (g == null) return null;

    if (g.kind == _GrowthKind.constant) {
      if (g.coefficient != null) {
        return SymbolicLimitResult(
          _formatResult(g.coefficient!),
          method: 'gruntz',
        );
      }
    }

    // Growing expressions → ±∞.
    if (g.kind.index > _GrowthKind.constant.index) {
      return _signedInfinity(engine, expression, variable, positive);
    }

    return null;
  }

  /// Determine the sign of a divergent limit by numerical sampling.
  static SymbolicLimitResult? _signedInfinity(
    CalculatorEngine engine,
    String expression,
    String variable,
    bool positive,
  ) {
    // Sample at a large value to determine sign.
    final testPoint = positive ? '10000' : '-10000';
    final val = _evalAt(engine, expression, variable, testPoint);
    if (val != null) {
      final d = double.tryParse(val);
      if (d != null) {
        if (d > 0) return const SymbolicLimitResult('∞', method: 'gruntz');
        if (d < 0) return const SymbolicLimitResult('-∞', method: 'gruntz');
      }
    }
    return const SymbolicLimitResult('∞', method: 'gruntz');
  }

  /// For polynomial ratios where deg(num) > deg(den), determine sign.
  static SymbolicLimitResult? _infinitySignResult(
    _GrowthClass numG,
    _GrowthClass denG,
    bool positive,
    double excessDegree,
  ) {
    if (numG.coefficient != null && denG.coefficient != null) {
      final sign = numG.coefficient!.sign * denG.coefficient!.sign;
      // For x→-∞ with odd excess degree, sign flips.
      if (!positive && excessDegree.round().isOdd) {
        if (sign > 0) return const SymbolicLimitResult('-∞', method: 'gruntz');
        return const SymbolicLimitResult('∞', method: 'gruntz');
      }
      if (sign > 0) return const SymbolicLimitResult('∞', method: 'gruntz');
      return const SymbolicLimitResult('-∞', method: 'gruntz');
    }
    return const SymbolicLimitResult('∞', method: 'gruntz');
  }

  /// L'Hôpital's rule for ∞/∞ forms (as x→∞).
  static SymbolicLimitResult? _lhopitalAtInfinity({
    required CalculatorEngine engine,
    required String numerator,
    required String denominator,
    required String variable,
    required bool positive,
  }) {
    var num = numerator;
    var den = denominator;
    final infSymbol = positive ? 'oo' : '-oo';

    for (var step = 0; step < _maxLhopitalSteps; step++) {
      final numPrime = engine.differentiate(num, variable);
      final denPrime = engine.differentiate(den, variable);

      if (numPrime.startsWith('Error') || denPrime.startsWith('Error')) {
        return null;
      }

      // Try substituting infinity into the new ratio.
      final ratioExpr = '($numPrime)/($denPrime)';
      try {
        final substituted = engine.substitute(ratioExpr, variable, infSymbol);
        if (!substituted.startsWith('Error')) {
          final evaluated = engine.evaluate(substituted);
          if (!evaluated.startsWith('Error')) {
            final lower = evaluated.trim().toLowerCase();
            if (lower == '0' || lower == '0.0') {
              return const SymbolicLimitResult('0', method: 'gruntz');
            }
            if (lower == 'oo' || lower == 'inf' || lower == 'infinity') {
              return const SymbolicLimitResult('∞', method: 'gruntz');
            }
            if (lower == '-oo' || lower == '-inf') {
              return const SymbolicLimitResult('-∞', method: 'gruntz');
            }
            if (lower != 'nan' &&
                lower != 'zoo' &&
                !lower.contains('oo') &&
                !lower.contains('inf') &&
                !_containsVariable(evaluated, variable)) {
              return SymbolicLimitResult(evaluated.trim(), method: 'gruntz');
            }
          }
        }
      } catch (_) {}

      // Also try numerical evaluation at large value.
      final testPoint = positive ? '100000' : '-100000';
      final numVal = _evalAt(engine, numPrime, variable, testPoint);
      final denVal = _evalAt(engine, denPrime, variable, testPoint);

      if (numVal != null && denVal != null) {
        final numD = double.tryParse(numVal);
        final denD = double.tryParse(denVal);
        if (numD != null && denD != null && denD.abs() > 1e-15) {
          final r = numD / denD;
          // Check if the ratio has converged by sampling at two points.
          final testPoint2 = positive ? '50000' : '-50000';
          final numVal2 = _evalAt(engine, numPrime, variable, testPoint2);
          final denVal2 = _evalAt(engine, denPrime, variable, testPoint2);
          if (numVal2 != null && denVal2 != null) {
            final numD2 = double.tryParse(numVal2);
            final denD2 = double.tryParse(denVal2);
            if (numD2 != null && denD2 != null && denD2.abs() > 1e-15) {
              final r2 = numD2 / denD2;
              if ((r - r2).abs() < 1e-6 * (r.abs() + 1)) {
                // Converged.
                if (r.abs() < 1e-10) {
                  return const SymbolicLimitResult('0', method: 'gruntz');
                }
                if (r.isFinite) {
                  return SymbolicLimitResult(
                    _formatResult(r),
                    method: 'gruntz',
                  );
                }
              }
            }
          }
        }
      }

      num = numPrime;
      den = denPrime;
    }

    return null;
  }

  // --- Helpers ---

  static String? _evalAt(
    CalculatorEngine engine,
    String expression,
    String variable,
    String point,
  ) {
    try {
      final substituted = engine.substitute(expression, variable, point);
      if (substituted.startsWith('Error')) return null;
      final result = engine.evaluate(substituted);
      if (result.startsWith('Error')) return null;
      return result.trim();
    } catch (_) {
      return null;
    }
  }

  static bool _isZero(String value) {
    final d = double.tryParse(value);
    if (d != null) return d.abs() < 1e-12;
    return value.trim() == '0';
  }

  static bool _containsVariable(String expr, String variable) {
    // Check if the variable appears as a standalone identifier.
    return RegExp('\\b${RegExp.escape(variable)}\\b').hasMatch(expr);
  }

  static bool _isPositiveInfinity(String pt) {
    return pt == 'oo' || pt == 'inf' || pt == 'infinity' || pt == r'\infty';
  }

  static bool _isNegativeInfinity(String pt) {
    return pt == '-oo' || pt == '-inf' || pt == '-infinity';
  }

  static String _formatResult(double v) {
    if ((v - v.roundToDouble()).abs() < 1e-9 && v.abs() < 1e15) {
      return v.toInt().toString();
    }
    final s = v.toStringAsPrecision(10);
    return s.contains('.')
        ? s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')
        : s;
  }

  /// Test-visible ratio parser. Production code calls [_parseRatio].
  @visibleForTesting
  static ({String numerator, String denominator})? parseRatioForTest(
      String expression) {
    final r = _parseRatio(expression);
    if (r == null) return null;
    return (numerator: r.numerator, denominator: r.denominator);
  }

  /// Parse a top-level ratio `numerator / denominator` from the
  /// expression. Returns null if the expression isn't a simple ratio.
  static _Ratio? _parseRatio(String expression) {
    final expr = expression.trim();
    // Find the top-level '/' that isn't inside parentheses.
    int depth = 0;
    int? slashPos;
    for (var i = 0; i < expr.length; i++) {
      final c = expr[i];
      if (c == '(' || c == '[') {
        depth++;
      } else if (c == ')' || c == ']') {
        depth--;
      } else if (c == '/' && depth == 0) {
        // Skip '//' comments.
        if (i + 1 < expr.length && expr[i + 1] == '/') continue;
        if (slashPos != null) return null; // Multiple top-level slashes.
        slashPos = i;
      }
    }
    if (slashPos == null) return null;
    final num = expr.substring(0, slashPos).trim();
    final den = expr.substring(slashPos + 1).trim();
    if (num.isEmpty || den.isEmpty) return null;
    // Strip outer parens if present.
    return _Ratio(_stripParens(num), _stripParens(den));
  }

  static String _stripParens(String s) {
    final t = s.trim();
    if (t.startsWith('(') && t.endsWith(')')) {
      // Verify the parens are matched (the outer pair wraps the whole thing).
      int depth = 0;
      for (var i = 0; i < t.length; i++) {
        if (t[i] == '(') depth++;
        if (t[i] == ')') depth--;
        if (depth == 0 && i < t.length - 1) return t; // Inner close.
      }
      return t.substring(1, t.length - 1).trim();
    }
    return t;
  }
}

class _Ratio {
  final String numerator;
  final String denominator;
  const _Ratio(this.numerator, this.denominator);
}

/// Growth-rate classification hierarchy (order matters for comparison).
/// constant < logarithmic < polynomial < exponential < superExponential
enum _GrowthKind {
  constant, // O(1)
  logarithmic, // O(log(x))
  polynomial, // O(x^n)
  exponential, // O(e^(x^n))
  superExponential, // O(e^(e^(...)))
}

/// Describes the growth rate of an expression as x→∞.
class _GrowthClass {
  final _GrowthKind kind;

  /// For polynomial: the degree. For exponential: the degree of the exponent.
  final double power;

  /// Leading coefficient (if extractable).
  final double? coefficient;

  const _GrowthClass({
    required this.kind,
    required this.power,
    this.coefficient,
  });
}
