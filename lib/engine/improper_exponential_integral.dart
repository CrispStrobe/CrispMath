import 'exact_constant.dart';
import 'polynomial.dart';
import 'real_calculus_proofs.dart';
import 'symbolic_expr.dart';
import 'symbolic_input_budget.dart';

/// Exact ordinary half-line integrals of bounded P(x)*exp(a*x).
/// Exponential decay proves convergence term by term; growth is rejected.
class ImproperExponentialIntegral {
  static String? definite(
    String source,
    String variable,
    String lower,
    String upper,
  ) {
    if (source.length > 512 || !boundedSymbolicLiterals(source)) return null;
    int infinity(String bound) {
      final text = bound.trim().toLowerCase();
      if ([
        'oo',
        '+oo',
        'inf',
        '+inf',
        'infinity',
        '+infinity',
        r'\infty',
      ].contains(text)) {
        return 1;
      }
      if (['-oo', '-inf', '-infinity', r'-\infty'].contains(text)) return -1;
      return 0;
    }

    final lo = infinity(lower), hi = infinity(upper);
    final lowerZero = ExactConstantEvaluator.evaluate(lower) == '0';
    final upperZero = ExactConstantEvaluator.evaluate(upper) == '0';
    if (!((lowerZero && hi != 0) || (upperZero && lo != 0))) return null;
    final direction = lowerZero ? hi : lo;
    final orientation = lowerZero ? direction : -direction;
    try {
      final parsed = SymParser(source).parse().simplify();
      final factors = parsed is SymMul ? parsed.factors : <SymExpr>[parsed];
      final exponentials = factors
          .whereType<SymCall>()
          .where((node) => node.name == 'exp' && node.args.length == 1)
          .toList();
      if (exponentials.length != 1) return null;
      final exponential = exponentials.single;
      final exponent = RealCalculusProofs.polynomial(
        renderSymExpr(exponential.args.single),
        variable,
      );
      if (exponent == null ||
          exponent.degree != 1 ||
          !exponent.coeffs[0].isZero) {
        return null;
      }
      final rest = factors
          .where((node) => !identical(node, exponential))
          .toList();
      final polynomial = RealCalculusProofs.polynomial(
        rest.isEmpty ? '1' : renderSymExpr(SymMul(rest)),
        variable,
      );
      if (polynomial == null || polynomial.degree > 8) return null;
      final rate = -exponent.coeffs[1] * Rational.fromInt(direction);
      if (polynomial.isZero) return '0';
      if (rate.sign <= 0) {
        return 'Error: divergent ordinary improper exponential integral';
      }
      if (rate.numerator.abs().bitLength > 2048 ||
          rate.denominator.bitLength > 2048 ||
          polynomial.coeffs.any(
            (c) =>
                c.numerator.abs().bitLength > 2048 ||
                c.denominator.bitLength > 2048,
          )) {
        return null;
      }
      var value = Rational.zero, factorial = Rational.one, ratePower = rate;
      for (var k = 0; k < polynomial.coeffs.length; k++) {
        if (k > 0) factorial = factorial * Rational.fromInt(k);
        final sign = direction < 0 && k.isOdd ? -Rational.one : Rational.one;
        value = value + sign * polynomial.coeffs[k] * factorial / ratePower;
        ratePower = ratePower * rate;
      }
      return (value * Rational.fromInt(orientation)).toString();
    } catch (_) {
      return null;
    }
  }
}
