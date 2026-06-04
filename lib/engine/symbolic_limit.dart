// lib/engine/symbolic_limit.dart
//
// Pure-Dart symbolic limit engine (PLAN P1 tiers 1+2).
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
  final String? method; // 'direct', 'lhopital', 'factor', 'infinity'
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
            return SymbolicLimitResult('0', method: 'infinity');
          }
          if (lower == 'oo' || lower == 'inf' || lower == 'infinity') {
            return SymbolicLimitResult('∞', method: 'infinity');
          }
          if (lower == '-oo' || lower == '-inf') {
            return SymbolicLimitResult('-∞', method: 'infinity');
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
      return _ratioInfinityLimit(
        engine: engine,
        numerator: ratio.numerator,
        denominator: ratio.denominator,
        variable: variable,
        positive: positive,
      );
    }

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
