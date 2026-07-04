// Shared logic for the CAS regression corpus (roadmap C1).
//
// The corpus lives in test/data/cas_corpus.json; every expected value is
// certified against SymPy by tool/cas_corpus_verify.py, which embeds the
// JSON into test/cas_corpus_data.dart. Two runners consume this module:
//
//   test/cas_corpus_test.dart              — pure-Dart fallback paths
//   integration_test/cas_corpus_native_test.dart — real SymEngine bridge
//
// Results are compared by numeric sampling (NumericFallbackEvaluator),
// so format differences between SymEngine, SymbolicWeb, and the corpus
// never cause false failures — only wrong mathematics does.

import 'dart:convert';

import 'package:crisp_calc/engine/calculator_engine.dart';
import 'package:crisp_calc/engine/numeric_fallback.dart';

import 'cas_corpus_data.dart';

class CorpusCase {
  final String id;
  final String op;
  final String? input;
  final String? variable;
  final List<String> vars;
  final String? value;
  final String? point;
  final String? lo;
  final String? hi;
  final List<String>? args;
  final dynamic expected; // String, or List<String> for roots
  final List<String> runners;
  final String check;

  /// Non-null when the engine is KNOWN to get this case wrong (with the
  /// reason + roadmap pointer). Runners assert the failure still happens,
  /// so a fix flips the test and forces the flag's removal.
  final String? knownGap;

  CorpusCase(Map<String, dynamic> m)
      : id = m['id'] as String,
        op = m['op'] as String,
        input = m['input'] as String?,
        variable = m['var'] as String?,
        vars = (m['vars'] as List?)?.cast<String>() ??
            [if (m['var'] != null) m['var'] as String],
        value = m['value'] as String?,
        point = m['point'] as String?,
        lo = m['lo'] as String?,
        hi = m['hi'] as String?,
        args = (m['args'] as List?)?.cast<String>(),
        expected = m['expected'],
        runners = (m['runners'] as List).cast<String>(),
        check = m['check'] as String,
        knownGap = m['knownGap'] as String?;
}

List<CorpusCase> loadCorpus() {
  final decoded = jsonDecode(kCasCorpusJson) as Map<String, dynamic>;
  return (decoded['cases'] as List)
      .map((c) => CorpusCase(c as Map<String, dynamic>))
      .toList();
}

/// Normalize an engine/corpus expression string for comparison and for
/// NumericFallbackEvaluator (which expects `^` powers and ASCII
/// operators — StepEngine prints `·` for multiplication, and pretty
/// printers may emit U+2212 for minus).
String norm(String s) => s
    .replaceAll(' ', '')
    .replaceAll('**', '^')
    .replaceAll('·', '*')
    .replaceAll('−', '-');

/// Run the corpus case through the engine facade. Headless, this exercises
/// the pure-Dart fallbacks; under integration_test it hits native SymEngine.
String runOp(CalculatorEngine engine, CorpusCase c) {
  switch (c.op) {
    case 'evaluate':
      return engine.evaluate(c.input!);
    case 'expand':
      return engine.expand(c.input!);
    case 'factor':
      return engine.factor(c.input!);
    case 'simplify':
      return engine.simplify(c.input!);
    case 'solve':
      return engine.solve(c.input!, c.variable!);
    case 'differentiate':
      return engine.differentiate(c.input!, c.variable!);
    case 'substitute':
      return engine.substitute(c.input!, c.variable!, c.value!);
    case 'gcd':
      return engine.gcd(c.args![0], c.args![1]);
    case 'lcm':
      return engine.lcm(c.args![0], c.args![1]);
    case 'integrate':
      return engine.integrate(c.input!, c.variable!);
    case 'integrate_def':
      return engine.integrate(c.input!, c.variable!, c.lo!, c.hi!);
    case 'limit':
      return engine.limit(c.input!, c.variable!, c.point!);
    default:
      throw ArgumentError('unknown corpus op ${c.op}');
  }
}

const _samplePoints = [0.7, 1.3, 2.6];
const _relTol = 1e-9;

Map<String, double> _assignment(List<String> vars, double base) => {
      for (var i = 0; i < vars.length; i++) vars[i]: base + i * 0.6,
    };

double? _evalAt(String expr, Map<String, double> vars) =>
    NumericFallbackEvaluator.evalNumeric(norm(expr), vars);

final _complexResult = RegExp(r'^(.*?)([+-][^+-]*)\*I$');

/// Parse a numeric result string, accepting SymEngine's complex format
/// ("1.5 + 0.0*I") as long as the imaginary part is negligible.
double? parseValue(String s) {
  final direct = _evalAt(s, const {});
  if (direct != null) return direct;
  final m = _complexResult.firstMatch(norm(s));
  if (m == null) return null;
  final re = _evalAt(m.group(1)!, const {});
  final im = _evalAt(m.group(2)!, const {});
  if (re == null || im == null) return null;
  return im.abs() <= 1e-9 * [1.0, re.abs()].reduce((a, b) => a > b ? a : b)
      ? re
      : null; // genuinely complex — not a real value
}

bool _close(double a, double b, [double tol = _relTol]) {
  final scale = [1.0, a.abs(), b.abs()].reduce((x, y) => x > y ? x : y);
  return (a - b).abs() <= tol * scale;
}

/// Numeric-sampling equivalence of two expressions in [vars]. Requires at
/// least two sample points where both sides evaluate to finite values.
bool numericEquiv(String a, String b, List<String> vars) {
  var checked = 0;
  for (final p in _samplePoints) {
    final env = _assignment(vars, p);
    final va = _evalAt(a, env), vb = _evalAt(b, env);
    if (va == null || vb == null || !va.isFinite || !vb.isFinite) continue;
    if (!_close(va, vb)) return false;
    checked++;
  }
  return checked >= (vars.isEmpty ? 1 : 2);
}

/// Two antiderivatives are equivalent iff their difference is constant.
bool antiderivativeEquiv(String got, String expected, String variable) {
  final diffs = <double>[];
  for (final p in _samplePoints) {
    final env = {variable: p};
    final vg = _evalAt(got, env), ve = _evalAt(expected, env);
    if (vg == null || ve == null || !vg.isFinite || !ve.isFinite) continue;
    diffs.add(vg - ve);
  }
  if (diffs.length < 2) return false;
  return diffs.every((d) => _close(d, diffs.first, 1e-8));
}

/// Parse the engine's solve output ("x = {2, -2}", "x = 3",
/// "x = (no solutions)") into a list of root strings.
List<String>? parseSolveOutput(String out) {
  final eq = out.indexOf('=');
  if (eq < 0) return null;
  var rhs = out.substring(eq + 1).trim();
  if (rhs == '(no solutions)') return [];
  if (rhs.startsWith('{') && rhs.endsWith('}')) {
    rhs = rhs.substring(1, rhs.length - 1);
    return _splitTopLevel(rhs).map((s) => s.trim()).toList();
  }
  return [rhs];
}

/// Split on commas that are not nested inside parentheses.
List<String> _splitTopLevel(String s) {
  final parts = <String>[];
  var depth = 0, start = 0;
  for (var i = 0; i < s.length; i++) {
    final ch = s[i];
    if (ch == '(') depth++;
    if (ch == ')') depth--;
    if (ch == ',' && depth == 0) {
      parts.add(s.substring(start, i));
      start = i + 1;
    }
  }
  parts.add(s.substring(start));
  return parts;
}

/// Roots match iff same count and each expected root is numerically equal
/// to exactly one got root (pairwise greedy matching).
bool rootsMatch(List<String> got, List<String> expected) {
  if (got.length != expected.length) return false;
  final remaining = [...got];
  for (final e in expected) {
    final ve = _evalAt(e, const {});
    if (ve == null) return false;
    final idx = remaining.indexWhere((g) {
      final vg = _evalAt(g, const {});
      return vg != null && _close(vg, ve, 1e-8);
    });
    if (idx < 0) return false;
    remaining.removeAt(idx);
  }
  return true;
}

/// Verdict for one corpus case; null means pass, otherwise a reason.
String? checkCase(CalculatorEngine engine, CorpusCase c, String got) {
  if (got.startsWith('Error')) return 'engine returned "$got"';

  switch (c.check) {
    case 'exact':
      return norm(got) == norm(c.expected as String)
          ? null
          : 'expected ${c.expected}, got $got';

    case 'equiv':
      final expected = c.expected as String;
      if (!numericEquiv(got, expected, c.vars)) {
        return 'not equivalent to ${c.expected}: got $got';
      }
      // A factor result must actually be factored, not just equivalent —
      // returning the (expanded) input unchanged would pass numerically.
      if (c.op == 'factor' && norm(got) == norm(engine.expand(c.input!))) {
        return 'result is the expanded form, not a factorization: $got';
      }
      return null;

    case 'antiderivative':
      var stripped = norm(got);
      if (stripped.endsWith('+C')) {
        stripped = stripped.substring(0, stripped.length - 2);
      }
      return antiderivativeEquiv(stripped, c.expected as String, c.variable!)
          ? null
          : 'd/d${c.variable} mismatch: expected ${c.expected}, got $got';

    case 'roots':
      final roots = parseSolveOutput(got);
      if (roots == null) return 'unparseable solve output: $got';
      return rootsMatch(roots, (c.expected as List).cast<String>())
          ? null
          : 'roots $roots do not match ${c.expected}';

    case 'value':
      final vg = parseValue(got);
      final ve = parseValue(c.expected as String);
      if (vg == null || ve == null) return 'unparseable value: got $got';
      return _close(vg, ve, 1e-6) ? null : 'expected ${c.expected}, got $got';

    default:
      return 'unknown check kind ${c.check}';
  }
}
