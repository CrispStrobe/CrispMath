import 'dart:math' as math;

import 'exact_constant.dart';
import 'numeric_fallback.dart';
import 'polynomial.dart';
import 'symbolic_web.dart';

/// Small real-domain proofs, rather than snapping sampled values to zero.
class RealCalculusProofs {
  static String strip(String source) {
    var value = source.trim();
    while (value.startsWith('(') && value.endsWith(')')) {
      var depth = 0;
      var whole = true;
      for (var i = 0; i < value.length; i++) {
        if (value[i] == '(') {
          depth++;
        }
        if (value[i] == ')') {
          depth--;
        }
        if (depth == 0 && i < value.length - 1) {
          whole = false;
        }
      }
      if (!whole || depth != 0) {
        break;
      }
      value = value.substring(1, value.length - 1).trim();
    }
    return value;
  }

  static List<String>? product(String source) {
    final value = strip(source);
    var depth = 0;
    var split = -1;
    for (var i = 0; i < value.length; i++) {
      if (value[i] == '(') {
        depth++;
      }
      if (value[i] == ')') {
        depth--;
      }
      if (value[i] == '*' && depth == 0) {
        if (split >= 0 || (i + 1 < value.length && value[i + 1] == '*')) {
          return null;
        }
        split = i;
      }
    }
    return split < 0 ? null : [value.substring(0, split), value.substring(split + 1)];
  }

  static Polynomial? polynomial(String source, String variable) {
    if (source.length > 512) {
      return null;
    }
    final expanded = SymbolicWeb.expand(source);
    final p = expanded == null ? null : Polynomial.tryParse(expanded);
    return p == null || (p.degree > 0 && p.variable != variable) ? null : p;
  }

  static String? at(String source, String variable, String point) {
    if (source.length > 512) {
      return null;
    }
    // Polynomial pretty-printing uses rational coefficients such as 3x and
    // 1/2x. Restore explicit multiplication before substituting a parenthesis.
    final explicit = source.replaceAllMapped(
        RegExp('([0-9])\\s*(${RegExp.escape(variable)})(?![A-Za-z_0-9])'),
        (m) => '${m[1]}*${m[2]}');
    final replaced = explicit.replaceAllMapped(RegExp(r'[A-Za-z_][A-Za-z_0-9]*'),
        (m) => m[0] == variable ? '($point)' : m[0]!);
    return ExactConstantEvaluator.evaluate(replaced);
  }

  /// Polynomial amplitude vanishes while a real rational-phase sin/cos stays
  /// bounded by one on a punctured neighborhood: the squeeze theorem gives 0.
  static bool squeezedZero(String source, String variable, String point) {
    if (source.length > 512 || !RegExp(r'^[A-Za-z]$').hasMatch(variable)) {
      return false;
    }
    final factors = product(source);
    if (factors == null) {
      return false;
    }
    for (var i = 0; i < 2; i++) {
      final wave = strip(factors[i]);
      final call = RegExp(r'^(?:sin|cos)\((.*)\)$').firstMatch(wave);
      if (call == null) {
        continue;
      }
      final amplitude = polynomial(factors[1 - i], variable);
      if (amplitude == null || at(amplitude.toString(), variable, point) != '0') {
        continue;
      }
      final phase = call[1]!;
      if (!RegExp('^[0-9.\\s()+*/^\\-${RegExp.escape(variable)}]+\$').hasMatch(phase)) {
        continue;
      }
      // Integer powers keep the phase rational and real on either side.
      final powers = RegExp(r'\^\s*(?:\([+-]?\d+\)|[+-]?\d+)(?![\d.])')
          .allMatches(phase).length;
      if ('^'.allMatches(phase).length != powers) {
        continue;
      }
      final compiled = NumericFallbackEvaluator.compile(phase);
      final center = NumericFallbackEvaluator.evalNumeric(point);
      if (compiled == null || center == null || !center.isFinite) {
        continue;
      }
      final left = compiled.evaluate({variable: center - 0.125});
      final right = compiled.evaluate({variable: center + 0.125});
      if (left != null && right != null && left.isFinite && right.isFinite) {
        return true;
      }
    }
    return false;
  }

  static ({Polynomial inner, Polynomial outer})? _absoluteProduct(
      String source, String variable) {
    if (source.length > 512) {
      return null;
    }
    final body = strip(source);
    var amplitude = '1';
    var absolute = body;
    final factors = product(body);
    if (factors != null) {
      if (strip(factors[0]).startsWith('abs(')) {
        absolute = strip(factors[0]); amplitude = factors[1];
      } else {
        absolute = strip(factors[1]); amplitude = factors[0];
      }
    }
    final call = RegExp(r'^abs\((.*)\)$').firstMatch(absolute);
    if (call == null) {
      return null;
    }
    final inner = polynomial(call[1]!, variable);
    final outer = polynomial(amplitude, variable);
    if (inner == null || inner.degree != 1 || outer == null) {
      return null;
    }
    return (inner: inner, outer: outer);
  }

  /// Exact real first derivative of P(x)*abs(a*x+b), including its domain.
  static String? absoluteDerivative(String source, String variable, String point) {
    final parsed = _absoluteProduct(source, variable);
    if (parsed == null) return null;
    final value = at(parsed.inner.toString(), variable, point);
    if (value == null) return null;
    if (value == '0') return cuspDerivative(source, variable, point);
    final slope = parsed.inner.coeffs[1];
    final expression = '(${parsed.outer.derivative()})*(${parsed.inner})'
        '+(${parsed.outer})*($slope)';
    final result = at(expression, variable, point);
    return result == null ? null : value.startsWith('-')
        ? ExactConstantEvaluator.evaluate('-($result)') : result;
  }

  /// A real absolute-value cusp in a polynomial multiple. At its zero an
  /// amplitude of zero removes the derivative jump; otherwise no derivative.
  static String? cuspDerivative(String source, String variable, String point,
      {int order = 1}) {
    final parsed = _absoluteProduct(source, variable);
    if (parsed == null || at(parsed.inner.toString(), variable, point) != '0') {
      return null;
    }
    if (order < 0 || order > 64) {
      return null;
    }
    var derivative = parsed.outer;
    var multiplicity = 0;
    while (!derivative.isZero) {
      final coefficient = at(derivative.toString(), variable, point);
      if (coefficient == null) {
        return null;
      }
      if (coefficient != '0') {
        break;
      }
      multiplicity++;
      derivative = derivative.derivative();
    }
    return derivative.isZero || order <= multiplicity
        ? '0'
        : 'Error: derivative does not exist at $variable = $point (order $order)';
  }

  /// Established antiderivatives for affine real sqrt/log families. Endpoint
  /// limits are analytic: u*ln(u)->0 and sqrt(u)->0 as u approaches 0 from above.
  static ({double? value, String? error})? definite(
      String source, String variable, String lower, String upper) {
    if (source.length > 512) {
      return null;
    }
    final body = strip(source).replaceAll(' ', '');
    final call = RegExp(r'^(1/)?(sqrt|ln|log)\((.*)\)$').firstMatch(body);
    if (call == null || (call[1] != null && call[2] != 'sqrt')) {
      return null;
    }
    final linear = polynomial(call[3]!, variable);
    if (linear == null || linear.degree != 1) {
      return null;
    }
    final a = NumericFallbackEvaluator.evalNumeric(lower);
    final b = NumericFallbackEvaluator.evalNumeric(upper);
    final slope = linear.coeffs[1].numerator.toDouble() /
        linear.coeffs[1].denominator.toDouble();
    final offset = linear.coeffs[0].numerator.toDouble() /
        linear.coeffs[0].denominator.toDouble();
    if (a == null || b == null || !a.isFinite || !b.isFinite ||
        !slope.isFinite || slope == 0 || !offset.isFinite) {
      return null;
    }
    final from = slope * a + offset, to = slope * b + offset;
    if (!from.isFinite || !to.isFinite) {
      return null;
    }
    if (from < 0 || to < 0 || (from == 0 && to == 0)) {
      return (value: null, error: 'Error: integration interval leaves the real integrand domain');
    }
    double antiderivative(double u) {
      if (call[2] == 'ln' || call[2] == 'log') {
        return (u == 0 ? 0 : u * math.log(u) - u) / slope;
      }
      return call[1] == null
          ? 2 * u * math.sqrt(u) / (3 * slope)
          : 2 * math.sqrt(u) / slope;
    }
    final result = antiderivative(to) - antiderivative(from);
    return result.isFinite ? (value: result, error: null) : null;
  }
}
