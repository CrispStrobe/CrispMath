import 'multivariate_poly.dart';
import 'polynomial.dart';

/// Exact whole-quotient division over Q with bounded multivariate polynomials.
/// The returned restriction describes the source, including cancelled holes.
class PolynomialQuotientCancellation {
  static ({String expression, String condition})? simplify(String source) {
    if (source.length > 512) {
      return null;
    }
    var body = source.trim();
    while (body.startsWith('(') && body.endsWith(')')) {
      var depth = 0;
      var whole = true;
      for (var i = 0; i < body.length; i++) {
        if (body[i] == '(') {
          depth++;
        }
        if (body[i] == ')') {
          depth--;
        }
        if (depth == 0 && i < body.length - 1) {
          whole = false;
        }
      }
      if (!whole || depth != 0) {
        break;
      }
      body = body.substring(1, body.length - 1).trim();
    }
    var depth = 0;
    var division = -1;
    for (var i = 0; i < body.length; i++) {
      if (body[i] == '(') {
        depth++;
      }
      if (body[i] == ')') {
        depth--;
      }
      if (depth < 0) {
        return null;
      }
      if ((body[i] == '+' || body[i] == '-') && depth == 0 && i > 0) {
        final previous = body.substring(0, i).trimRight();
        if (previous.isNotEmpty &&
            !'+-*/^('.contains(previous[previous.length - 1])) {
          return null;
        }
      }
      if (body[i] == '/' && depth == 0) {
        if (division >= 0) {
          return null;
        }
        division = i;
      }
    }
    if (division < 0 || depth != 0) {
      return null;
    }
    final numerator = MultivariatePolynomial.tryParse(body.substring(0, division));
    final denominatorSource = body.substring(division + 1);
    final denominator = MultivariatePolynomial.tryParse(denominatorSource);
    if (numerator == null || denominator == null || denominator.isZero ||
        numerator.termCount > 64 || denominator.termCount > 64 ||
        numerator.totalDegree > 16 || denominator.totalDegree > 16) {
      return null;
    }
    if ([...numerator.terms, ...denominator.terms].any((term) =>
        term.$2.numerator.bitLength > 4096 ||
        term.$2.denominator.bitLength > 4096)) {
      return null;
    }
    final names = {...numerator.variables, ...denominator.variables}.toList()..sort();
    if (names.length < 2 || names.length > 4) {
      return null;
    }
    Map<String, Rational> align(MultivariatePolynomial p) => {
      for (final (exponents, coefficient) in p.terms)
        [for (final name in names)
          p.variables.contains(name) ? exponents[p.variables.indexOf(name)] : 0]
            .join(','): coefficient,
    };
    List<int> exponents(String key) => key.split(',').map(int.parse).toList();
    String leading(Map<String, Rational> terms) => terms.keys.reduce((a, b) {
      final ae = exponents(a), be = exponents(b);
      for (var i = 0; i < ae.length; i++) {
        if (ae[i] != be[i]) {
          return ae[i] > be[i] ? a : b;
        }
      }
      return a;
    });
    final remainder = align(numerator), divisor = align(denominator);
    final divisorLead = leading(divisor), de = exponents(divisorLead);
    final quotient = <String, Rational>{};
    for (var steps = 0; remainder.isNotEmpty; steps++) {
      if (steps >= 256 || remainder.length > 128 || quotient.length > 64) {
        return null;
      }
      final key = leading(remainder), re = exponents(key);
      if (List.generate(names.length, (i) => re[i] < de[i]).any((v) => v)) {
        return null;
      }
      final power = List.generate(names.length, (i) => re[i] - de[i]);
      final coefficient = remainder[key]! / divisor[divisorLead]!;
      if (coefficient.numerator.bitLength > 4096 ||
          coefficient.denominator.bitLength > 4096) {
        return null;
      }
      quotient[power.join(',')] = coefficient;
      for (final term in divisor.entries) {
        final te = exponents(term.key);
        final target = List.generate(names.length, (i) => te[i] + power[i]).join(',');
        final previous = remainder[target] ?? Rational.zero;
        final next = previous - coefficient * term.value;
        if (next.numerator.bitLength > 4096 || next.denominator.bitLength > 4096) {
          return null;
        }
        if (next.isZero) {
          remainder.remove(target);
        } else {
          remainder[target] = next;
        }
      }
    }
    final terms = StringBuffer();
    for (final entry in quotient.entries) {
      final powers = exponents(entry.key);
      final factors = <String>[];
      final magnitude = entry.value.abs;
      if (magnitude != Rational.one || powers.every((power) => power == 0)) {
        factors.add(magnitude.toString());
      }
      for (var i = 0; i < names.length; i++) {
        if (powers[i] > 0) {
          factors.add(powers[i] == 1 ? names[i] : '${names[i]}^${powers[i]}');
        }
      }
      if (entry.value.sign < 0) {
        terms.write('-');
      } else if (terms.isNotEmpty) {
        terms.write('+');
      }
      terms.write(factors.join('*'));
    }
    return (expression: terms.isEmpty ? '0' : terms.toString(),
      condition: '($denominatorSource) ≠ 0');
  }
}
