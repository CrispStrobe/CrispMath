import 'dart:math' as math;

import 'exact_constant.dart';
import 'numeric_fallback.dart';
import 'polynomial.dart';
import 'symbolic_web.dart';
import 'symbolic_input_budget.dart';

/// Small real-domain proofs, rather than snapping sampled values to zero.
class RealCalculusProofs {
  /// Rationalize a matched quadratic radical and affine term at infinity.
  /// Exact matching of leading coefficients proves cancellation; unmatched
  /// divergent/complex branches decline rather than using large-number samples.
  static String? quadraticRadicalLimit(String source, String variable, String point) {
    final direction = ['oo', 'inf', 'infinity', r'\infty'].contains(point.trim())
        ? 1 : ['-oo', '-inf', '-infinity'].contains(point.trim()) ? -1 : 0;
    if (source.length > 512 || direction == 0) {
      return null;
    }
    final body = strip(source).replaceAll(' ', '');
    var depth = 0, difference = -1;
    for (var i = 0; i < body.length; i++) {
      if (body[i] == '(') depth++;
      if (body[i] == ')') depth--;
      if (body[i] == '-' && depth == 0 && i > 0 &&
          !'+-*/^('.contains(body[i - 1])) {
        if (difference >= 0) {
          return null;
        }
        difference = i;
      }
    }
    if (difference < 0 || depth != 0) {
      return null;
    }
    final left = strip(body.substring(0, difference));
    final right = strip(body.substring(difference + 1));
    final reverse = right.startsWith('sqrt(') && right.endsWith(')');
    final radical = reverse ? right : left;
    if (!radical.startsWith('sqrt(') || !radical.endsWith(')')) {
      return null;
    }
    final q = polynomial(radical.substring(5, radical.length - 1), variable);
    final line = polynomial(reverse ? left : right, variable);
    if (q == null || q.degree != 2 || line == null || line.degree != 1) {
      return null;
    }
    final slope = line.coeffs[1];
    if (slope.sign != direction || q.coeffs[2].sign <= 0 ||
        slope * slope != q.coeffs[2]) {
      return null;
    }
    final result = q.coeffs[1] / (Rational.fromInt(2) * slope) - line.coeffs[0];
    return (reverse ? -result : result).toString();
  }

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
    if (source.length > 512 || !boundedSymbolicLiterals(source)) {
      return null;
    }
    final expanded = SymbolicWeb.expand(source);
    final p = expanded == null ? null : Polynomial.tryParse(expanded);
    return p == null || (p.degree > 0 && p.variable != variable) ? null : p;
  }

  static String _explicitCoefficients(String source, String variable) {
    // Polynomial pretty-printing uses rational coefficients such as 3x and
    // 1/2x. Restore explicit multiplication before substituting a parenthesis.
    return source.replaceAllMapped(
        RegExp('([0-9])\\s*(${RegExp.escape(variable)})(?![A-Za-z_0-9])'),
        (m) => '${m[1]}*${m[2]}');
  }

  static String? at(String source, String variable, String point) {
    if (source.length > 512) {
      return null;
    }
    final explicit = _explicitCoefficients(source, variable);
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
    if (inner == null || inner.degree < 1 || inner.degree > 8 ||
        outer == null || outer.degree > 16) {
      return null;
    }
    return (inner: inner, outer: outer);
  }

  /// Exact real first derivative of P(x)*abs(Q(x)), including polynomial
  /// zeros whose multiplicity may smooth an otherwise absolute-value cusp.
  static String? absoluteDerivative(String source, String variable, String point) {
    final parsed = _absoluteProduct(source, variable);
    if (parsed == null) {
      return null;
    }
    final value = at(parsed.inner.toString(), variable, point);
    if (value == null) {
      return null;
    }
    if (value == '0') {
      final local = absoluteLocalPolynomial(source, variable, point);
      if (local != null) {
        final p = polynomial(local, variable);
        return p == null ? null : at(p.derivative().toString(), variable, point);
      }
      return cuspDerivative(source, variable, point);
    }
    final expression = '(${parsed.outer.derivative()})*(${parsed.inner})'
        '+(${parsed.outer})*(${parsed.inner.derivative()})';
    final result = at(expression, variable, point);
    return result == null ? null : value.startsWith('-')
        ? ExactConstantEvaluator.evaluate('-($result)') : result;
  }

  /// A nonzero polynomial value or an even-order zero has a constant sign in
  /// a neighborhood, so abs(Q) has the ordinary polynomial branch +/-Q.
  static String? absoluteLocalPolynomial(String source, String variable, String point) {
    final parsed = _absoluteProduct(source, variable);
    if (parsed == null) {
      return null;
    }
    final value = at(parsed.inner.toString(), variable, point);
    if (value == null) {
      return null;
    }
    var signValue = value;
    if (value == '0') {
      var derivative = parsed.inner;
      var multiplicity = 0;
      while (signValue == '0' && !derivative.isZero) {
        derivative = derivative.derivative();
        multiplicity++;
        final coefficient = at(derivative.toString(), variable, point);
        if (coefficient == null) {
          return null;
        }
        signValue = coefficient;
      }
      if (multiplicity.isOdd || signValue == '0') {
        return null;
      }
    }
    final sign = signValue.startsWith('-') ? '-1' : '1';
    final local = SymbolicWeb.expand('($sign)*(${parsed.outer})*(${parsed.inner})');
    return local == null ? null : _explicitCoefficients(local, variable);
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
    var innerDerivative = parsed.inner;
    var innerMultiplicity = 0;
    while (!innerDerivative.isZero) {
      final coefficient = at(innerDerivative.toString(), variable, point);
      if (coefficient == null) {
        return null;
      }
      if (coefficient != '0') {
        break;
      }
      innerMultiplicity++;
      innerDerivative = innerDerivative.derivative();
    }
    // An even-order zero does not change Q's sign: abs(Q) has an ordinary
    // polynomial branch here, handled by absoluteLocalPolynomial instead.
    if (innerMultiplicity.isEven) {
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
    return derivative.isZero || order < multiplicity + innerMultiplicity
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
    final body = strip(source).replaceAll(' ', '').replaceAll('**', '^');
    final call = RegExp(r'^(1/)?(sqrt|ln|log)\((.*)\)(?:\^(\d+)|\^\((\d+)\))?$').firstMatch(body);
    if (call == null || (call[1] != null && call[2] != 'sqrt')) {
      return null;
    }
    final power = int.tryParse(call[4] ?? call[5] ?? '1');
    if (power == null || power > 8 ||
        (call[2] == 'sqrt' && (call[4] != null || call[5] != null))) {
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
        if (u == 0) {
          return 0;
        }
        final logarithm = math.log(u);
        var primitive = u;
        for (var degree = 1; degree <= power; degree++) {
          primitive = u * math.pow(logarithm, degree) - degree * primitive;
        }
        return primitive / slope;
      }
      return call[1] == null
          ? 2 * u * math.sqrt(u) / (3 * slope)
          : 2 * math.sqrt(u) / slope;
    }
    final result = antiderivative(to) - antiderivative(from);
    return result.isFinite ? (value: result, error: null) : null;
  }
}
