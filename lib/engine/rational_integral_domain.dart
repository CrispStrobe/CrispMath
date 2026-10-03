import 'numeric_fallback.dart';
import 'polynomial.dart';
import 'rational_domain.dart';
import 'symbolic_web.dart';

/// Bounded, exact cancellation before checking real rational integral poles.
/// Null means unsupported; an empty list certifies no pole for this grammar.
class RationalIntegralDomain {
  static List<double>? polesWithin(
      String source, String variable, String lower, String upper) {
    final a = NumericFallbackEvaluator.evalNumeric(lower);
    final b = NumericFallbackEvaluator.evalNumeric(upper);
    if (a == null || b == null || !a.isFinite || !b.isFinite) return null;
    final quotient = _reducedQuotient(source, variable);
    if (quotient == null) return null;
    final reduced = quotient.denominator;
    if (reduced.degree == 0) return <double>[];
    final roots = SymbolicWeb.solveList(reduced.toString(), variable);
    if (roots == null) return null;
    final from = a < b ? a : b;
    final to = a < b ? b : a;
    final poles = <double>[];
    for (final root in roots) {
      if (RegExp(r'\b[Ii]\b').hasMatch(root)) continue; // Nonreal root.
      final value = NumericFallbackEvaluator.evalNumeric(root);
      if (value == null || !value.isFinite) return null;
      if (value >= from && value <= to) poles.add(value);
    }
    return poles;
  }

  /// Continuous extension through exactly cancelled rational holes.
  /// Only definite integration may use this after checking genuine poles;
  /// the original expression still defines its own excluded input points.
  /// Null preserves the source when unsupported or no common factor exists.
  static String? reducedExpression(String source, String variable) {
    final quotient = _reducedQuotient(source, variable);
    if (quotient == null || !quotient.cancelled) return null;
    final numerator = quotient.numerator;
    final denominator = quotient.denominator;
    if (denominator.degree == 0) {
      return numerator
          .scale(Rational.one / denominator.coeffs.single)
          .toString();
    }
    return '($numerator)/($denominator)';
  }

  static ({Polynomial numerator, Polynomial denominator, bool cancelled})?
      _reducedQuotient(String source, String variable) {
    if (source.length > 512 ||
        !RegExp(r'^[A-Za-z_][A-Za-z_0-9]*$').hasMatch(variable)) {
      return null;
    }
    var quotient = source.trim();
    while (quotient.startsWith('(') && quotient.endsWith(')')) {
      var depth = 0;
      var wholeWrapper = true;
      for (var i = 0; i < quotient.length; i++) {
        if (quotient[i] == '(') depth++;
        if (quotient[i] == ')') depth--;
        if (depth < 0) return null;
        if (depth == 0 && i < quotient.length - 1) {
          wholeWrapper = false;
          break;
        }
      }
      if (!wholeWrapper || depth != 0) break;
      quotient = quotient.substring(1, quotient.length - 1).trim();
    }
    final domain = RationalDomain.inspect(quotient, variable: variable);
    if (domain == null) return null;
    var depth = 0;
    var division = -1;
    for (var i = 0; i < quotient.length; i++) {
      if (quotient[i] == '(') depth++;
      if (quotient[i] == ')') depth--;
      if (quotient[i] == '/' && depth == 0) division = i;
    }
    if (division < 0) return null;
    final numerator = SymbolicWeb.expand(quotient.substring(0, division));
    final denominator = SymbolicWeb.expand(domain.denominator);
    if (numerator == null || denominator == null) return null;
    final n = Polynomial.tryParse(numerator);
    final d = Polynomial.tryParse(denominator);
    if (n == null ||
        d == null ||
        d.isZero ||
        d.degree > 2 ||
        (n.degree > 0 && n.variable != variable) ||
        d.variable != variable) {
      return null;
    }
    final num = Polynomial.fromCoeffs(n.coeffs, variable);
    final den = Polynomial.fromCoeffs(d.coeffs, variable);
    final common = Polynomial.gcd(num, den);
    return (
      numerator: num.divmod(common).quotient,
      denominator: den.divmod(common).quotient,
      cancelled: common.degree > 0,
    );
  }
}
