// Polynomial inequality solver (roadmap C3).
//
// solve(x^2 - 4 > 0)  ->  x < -2 ∨ x > 2
// solve(x^2 - 4 <= 0) ->  -2 ≤ x ≤ 2
//
// Strategy: move everything to the left-hand side (f(x) ⋚ 0), find the
// real roots exactly (native SymEngine solve when available, pure-Dart
// SymbolicWeb otherwise — so this works on every platform including the
// pre-WASM web fallback), then decide each interval's sign by numeric
// sampling. Endpoints keep their exact root strings ("sqrt(2)", "-3/2")
// in the rendered answer; the numeric values are only used for ordering
// and sampling.
//
// Output is language-neutral mathematical notation: ∨ for union,
// ≤ / ≥ / ≠ / ∈ ℝ / ∈ ∅ as appropriate.

import 'calculator_engine.dart';
import 'numeric_fallback.dart';
import 'symbolic_web.dart';

class InequalitySolver {
  /// Solve a univariate inequality like "x^2 - 4 > 0" or "2x + 3 <= x".
  /// Returns a rendered solution set, or an Error string.
  static String solve(
      CalculatorEngine engine, String inequality, String variable) {
    final parsed = _splitOnOperator(inequality);
    if (parsed == null) {
      return 'Error: no inequality operator found (<, >, ≤, ≥)';
    }
    final (lhs, op, rhs) = parsed;
    final expr = (rhs.trim() == '0' || rhs.trim().isEmpty)
        ? lhs.trim()
        : '(${lhs.trim()}) - (${rhs.trim()})';

    // `f(x) < 0` is `-f(x) > 0`; normalize to > / >= so the sign logic
    // below only ever looks for POSITIVE intervals.
    final flipped = op == '<' || op == '<=';
    final normalizedExpr = flipped ? '-($expr)' : expr;
    final strict = op == '<' || op == '>';

    // --- Exact real roots of f(x) = 0 ---
    final roots = _realRoots(engine, expr, variable);
    if (roots == null) {
      return 'Error: could not solve the inequality (only polynomial '
          'inequalities are supported)';
    }
    roots.sort((a, b) => a.value.compareTo(b.value));
    // Merge numerically-equal roots (double roots reported twice).
    final unique = <_Root>[];
    for (final r in roots) {
      if (unique.isEmpty || (r.value - unique.last.value).abs() > 1e-10) {
        unique.add(r);
      }
    }

    // --- Sign sampling on each interval ---
    double f(double x) =>
        NumericFallbackEvaluator.evalNumeric(normalizedExpr, {variable: x}) ??
        double.nan;

    final samplePoints = <double>[];
    if (unique.isEmpty) {
      samplePoints.add(0);
    } else {
      samplePoints.add(unique.first.value - 1);
      for (var i = 0; i + 1 < unique.length; i++) {
        samplePoints.add((unique[i].value + unique[i + 1].value) / 2);
      }
      samplePoints.add(unique.last.value + 1);
    }
    final positive = <bool>[];
    for (final p in samplePoints) {
      final v = f(p);
      if (v.isNaN) return 'Error: could not evaluate the inequality';
      positive.add(v > 0);
    }

    // --- Compose the solution set ---
    // Intervals are (root[i-1], root[i]) with ±∞ at the ends. A root
    // itself satisfies the inequality iff it is non-strict (f(root)=0).
    final n = unique.length;
    final segments = <_Segment>[];
    for (var i = 0; i <= n; i++) {
      if (!positive[i]) continue;
      final lo = i == 0 ? null : unique[i - 1];
      final hi = i == n ? null : unique[i];
      segments.add(_Segment(lo, hi, !strict, !strict));
    }
    if (!strict) {
      // Isolated solutions: roots whose neighbours are both negative
      // (e.g. (x-1)^2 <= 0 -> x = 1).
      for (var i = 0; i < n; i++) {
        if (!positive[i] && !positive[i + 1]) {
          segments.add(_Segment(unique[i], unique[i], true, true));
        }
      }
      segments.sort((a, b) => (a.lo?.value ?? double.negativeInfinity)
          .compareTo(b.lo?.value ?? double.negativeInfinity));
      // Merge segments sharing an endpoint ([a,b] ∪ [b,c] -> [a,c]).
      for (var i = 0; i + 1 < segments.length;) {
        final cur = segments[i], next = segments[i + 1];
        if (cur.hi != null && next.lo != null && identical(cur.hi, next.lo)) {
          segments[i] = _Segment(cur.lo, next.hi, cur.loIncl, next.hiIncl);
          segments.removeAt(i + 1);
        } else {
          i++;
        }
      }
    }

    return _render(segments, unique, variable, strict);
  }

  /// True if [input] contains an inequality operator (used by the
  /// calculator dispatch to route bare inequalities here).
  static bool looksLikeInequality(String input) =>
      _splitOnOperator(input) != null;

  // --- helpers -----------------------------------------------------------

  static (String, String, String)? _splitOnOperator(String s) {
    // Normalize unicode operators, longest first so <= wins over <.
    final norm = s.replaceAll('≤', '<=').replaceAll('≥', '>=');
    for (final op in const ['<=', '>=', '<', '>']) {
      final i = norm.indexOf(op);
      if (i > 0) {
        // Reject `=` fragments of `==`/`!=` and multiple operators.
        final rest = norm.substring(i + op.length);
        if (rest.contains('<') || rest.contains('>')) return null;
        return (norm.substring(0, i), op, rest);
      }
    }
    return null;
  }

  /// Real roots of expr = 0: exact strings + numeric values.
  /// Native SymEngine solve when available, SymbolicWeb otherwise.
  /// Returns null when no solver can handle the expression.
  static List<_Root>? _realRoots(
      CalculatorEngine engine, String expr, String variable) {
    List<String>? rootStrings;
    if (engine.isNativeAvailable) {
      final out = engine.solve(expr, variable);
      if (!out.startsWith('Error')) rootStrings = _parseSolveOutput(out);
    }
    rootStrings ??= SymbolicWeb.solveList(expr, variable);
    if (rootStrings == null) return null;

    final roots = <_Root>[];
    for (final s in rootStrings) {
      // Skip non-real roots (SymEngine prints I, SymbolicWeb prints i).
      if (RegExp(r'(?<![a-zA-Z])[iI](?![a-zA-Z])').hasMatch(s)) continue;
      final v = NumericFallbackEvaluator.evalNumeric(
          s.replaceAll(' ', '').replaceAll('**', '^'), const {});
      if (v == null || !v.isFinite) return null; // can't order — bail
      roots.add(_Root(s.trim(), v));
    }
    return roots;
  }

  static List<String>? _parseSolveOutput(String out) {
    final eq = out.indexOf('=');
    if (eq < 0) return null;
    var rhs = out.substring(eq + 1).trim();
    if (rhs == '(no solutions)') return [];
    if (rhs.startsWith('{') && rhs.endsWith('}')) {
      rhs = rhs.substring(1, rhs.length - 1);
      final parts = <String>[];
      var depth = 0, start = 0;
      for (var i = 0; i < rhs.length; i++) {
        final ch = rhs[i];
        if (ch == '(') depth++;
        if (ch == ')') depth--;
        if (ch == ',' && depth == 0) {
          parts.add(rhs.substring(start, i));
          start = i + 1;
        }
      }
      parts.add(rhs.substring(start));
      return parts.map((s) => s.trim()).toList();
    }
    return [rhs];
  }

  static String _render(
      List<_Segment> segments, List<_Root> roots, String v, bool strict) {
    if (segments.isEmpty) return '$v ∈ ∅';
    if (segments.length == 1 &&
        segments.first.lo == null &&
        segments.first.hi == null) {
      return '$v ∈ ℝ';
    }
    // Full line minus isolated points: (-∞,a) ∪ (a,b) ∪ (b,∞) -> x ≠ a ∧ x ≠ b
    if (strict &&
        segments.first.lo == null &&
        segments.last.hi == null &&
        segments.length == roots.length + 1) {
      var chain = true;
      for (var i = 0; i + 1 < segments.length; i++) {
        if (!identical(segments[i].hi, segments[i + 1].lo)) chain = false;
      }
      if (chain) {
        return roots.map((r) => '$v ≠ ${r.text}').join(' ∧ ');
      }
    }
    return segments.map((s) => s.render(v)).join(' ∨ ');
  }
}

class _Root {
  final String text;
  final double value;
  _Root(this.text, this.value);
}

class _Segment {
  final _Root? lo; // null = -∞
  final _Root? hi; // null = +∞
  final bool loIncl;
  final bool hiIncl;
  _Segment(this.lo, this.hi, this.loIncl, this.hiIncl);

  String render(String v) {
    if (lo != null && hi != null && identical(lo, hi)) {
      return '$v = ${lo!.text}';
    }
    if (lo == null && hi == null) return '$v ∈ ℝ';
    if (lo == null) return hiIncl ? '$v ≤ ${hi!.text}' : '$v < ${hi!.text}';
    if (hi == null) return loIncl ? '$v ≥ ${lo!.text}' : '$v > ${lo!.text}';
    final l = loIncl ? '≤' : '<';
    final r = hiIncl ? '≤' : '<';
    return '${lo!.text} $l $v $r ${hi!.text}';
  }
}
