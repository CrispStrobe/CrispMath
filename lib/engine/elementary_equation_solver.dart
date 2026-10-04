import 'polynomial.dart';
import 'real_calculus_proofs.dart';
import 'symbolic_expr.dart';
import 'symbolic_input_budget.dart';

/// Certified real solutions for affine logarithms and exact rational powers.
/// Unsupported identities and nonintegral logarithmic ratios decline safely.
class ElementaryEquationSolver {
  static List<String>? solve(String source, String variable) {
    if (source.length > 512 ||
        !boundedSymbolicLiterals(source) ||
        !RegExp(r'^[A-Za-z_][A-Za-z_0-9]*$').hasMatch(variable)) {
      return null;
    }
    final sides = source.split('=');
    if (sides.length != 2 || sides.any((side) => side.trim().isEmpty)) {
      return null;
    }
    try {
      final left = SymParser(sides[0]).parse().simplify();
      final right = SymParser(sides[1]).parse().simplify();
      bool logarithm(SymExpr node) =>
          node is SymCall &&
          (node.name == 'log' || node.name == 'ln') &&
          node.args.length == 1;
      if (logarithm(left) && logarithm(right)) {
        final a = _affine((left as SymCall).args.single, variable);
        final b = _affine((right as SymCall).args.single, variable);
        if (a == null || b == null) return null;
        final slope = a.$2 - b.$2;
        final intercept = a.$1 - b.$1;
        if (slope.isZero) return intercept.isZero ? null : <String>[];
        final root = -intercept / slope;
        // Injectivity applies only on the intersection of both real domains.
        if ((a.$1 + a.$2 * root).sign <= 0 || (b.$1 + b.$2 * root).sign <= 0) {
          return <String>[];
        }
        return [root.toString()];
      }
      List<String>? power(SymExpr node, SymExpr target) {
        if (node is! SymPow || node.base is! SymNum || target is! SymNum) {
          return null;
        }
        final base = (node.base as SymNum).value;
        final value = target.value;
        if (base.sign <= 0 || base == Rational.one) return null;
        final exponent = _affine(node.exponent, variable);
        if (exponent == null || exponent.$2.isZero) return null;
        if (value.sign <= 0) return <String>[];
        Rational positive = Rational.one, negative = Rational.one;
        for (var n = 0; n <= 96; n++) {
          if (positive == value) {
            return [
              ((Rational.fromInt(n) - exponent.$1) / exponent.$2).toString(),
            ];
          }
          if (negative == value) {
            return [
              ((Rational.fromInt(-n) - exponent.$1) / exponent.$2).toString(),
            ];
          }
          if (n == 96 || !_bounded(positive) || !_bounded(negative)) break;
          positive = positive * base;
          negative = negative / base;
        }
        return null;
      }

      return power(left, right) ?? power(right, left);
    } catch (_) {
      return null;
    }
  }

  static bool _bounded(Rational value) =>
      value.numerator.abs().bitLength <= 2048 &&
      value.denominator.bitLength <= 2048;

  static (Rational, Rational)? _affine(SymExpr node, String variable) {
    final p = RealCalculusProofs.polynomial(renderSymExpr(node), variable);
    if (p == null || p.degree > 1 || p.coeffs.any((c) => !_bounded(c))) {
      return null;
    }
    return (
      p.coeffs.isEmpty ? Rational.zero : p.coeffs[0],
      p.coeffs.length < 2 ? Rational.zero : p.coeffs[1],
    );
  }
}
