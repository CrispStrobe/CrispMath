import 'polynomial.dart';
import 'symbolic_web.dart';

/// Canonicalize only bounded exact univariate polynomials. Native series may
/// retain a shifted basis such as 2-(2+x); expanding it makes the actual output
/// readable without reinterpreting functions, foreign variables or errors.
String normalizePolynomialTaylorValue(String value, String variable) {
  if (value.length > 512 || invalidSymbolicTaylorValue(value)) return value;
  final expanded = SymbolicWeb.expand(value);
  final polynomial = expanded == null ? null : Polynomial.tryParse(expanded);
  return polynomial != null &&
          (polynomial.degree <= 0 || polynomial.variable == variable)
      ? polynomial.toString()
      : value;
}

/// Exact Taylor coefficients computed through symbolic CAS operations.
/// Used by native libraries that expose differentiation but not series().
bool invalidSymbolicTaylorValue(String value) => value.startsWith('Error') ||
    RegExp(r'\b(nan|zoo|oo|inf|infinity|complexinfinity)\b',
        caseSensitive: false).hasMatch(value) ||
    RegExp(r'\b(?:Derivative|Subs)\s*\(', caseSensitive: false).hasMatch(value);

String symbolicTaylorSeries(
  String expression,
  String variable, {
  required String point,
  required int order,
  required String Function(String) simplify,
  required String Function(String, String) differentiate,
  required String Function(String, String, String) substitute,
}) {
  if (order < 1 || order > 64) {
    return 'Error: order must be in 1..64';
  }
  String checked(String value) {
    if (invalidSymbolicTaylorValue(value)) {
      throw FormatException('not expandable at this point: $value');
    }
    return value;
  }

  try {
    var derivative = checked(simplify(expression));
    var factorial = BigInt.one;
    final terms = <String>[];
    for (var degree = 0; degree < order; degree++) {
      final value = checked(substitute(derivative, variable, '($point)'));
      final coefficient = checked(simplify('($value)/$factorial'));
      terms.add('($coefficient)*(($variable)-($point))^$degree');
      if (degree + 1 < order) {
        derivative = checked(differentiate(derivative, variable));
        if (derivative == '0') break;
        factorial *= BigInt.from(degree + 1);
      }
    }
    return normalizePolynomialTaylorValue(
        checked(simplify(terms.join('+'))), variable);
  } catch (error) {
    return 'Error: series failed: $error';
  }
}
