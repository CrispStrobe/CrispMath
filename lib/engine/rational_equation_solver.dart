import 'polynomial.dart';
import 'symbolic_expr.dart';
import 'symbolic_web.dart';

/// Bounded exact rational equations; preserves original denominator conditions.
class RationalEquationSolver {
  static const _maxCoefficientBits = 16384;

  // Bound rational coefficients independently of polynomial degree. A constant
  // has degree zero even after a nested power grows its BigInt exponentially.
  static int _coefficientCost(Polynomial polynomial) {
    var numeratorBits = 0;
    var denominatorBits = 0;
    for (final coefficient in polynomial.coeffs) {
      final bits = coefficient.numerator.abs().bitLength;
      if (bits > numeratorBits) numeratorBits = bits;
      denominatorBits += coefficient.denominator.bitLength;
    }
    return numeratorBits + denominatorBits + polynomial.coeffs.length.bitLength;
  }

  static List<String>? solve(String source, String variable) {
    if (source.length > 512 || !source.contains('/')) return null;
    try {
      final parts = source.split('=');
      if (parts.length > 2) return null;
      final expression =
          parts.length == 2 ? '(${parts[0]})-(${parts[1]})' : source;
      final denominators = <Polynomial>[];
      var nodes = 0;
      Polynomial constant(Rational value) =>
          Polynomial.fromCoeffs([value], variable);
      Polynomial multiply(Polynomial a, Polynomial b) {
        if (a.degree + b.degree > 8 ||
            _coefficientCost(a) + _coefficientCost(b) > _maxCoefficientBits) {
          throw const FormatException('Degree bound');
        }
        return a * b;
      }

      (Polynomial, Polynomial) walk(SymExpr node, int depth) {
        if (depth > 32 || ++nodes > 256) {
          throw const FormatException('Expression bound');
        }
        if (node is SymNum) {
          return (constant(node.value), constant(Rational.one));
        }
        if (node is SymSym && node.name == variable) {
          return (
            Polynomial.fromCoeffs([Rational.zero, Rational.one], variable),
            constant(Rational.one)
          );
        }
        if (node is SymAdd || node is SymMul) {
          var n = constant(node is SymAdd ? Rational.zero : Rational.one);
          var d = constant(Rational.one);
          final children =
              node is SymAdd ? node.terms : (node as SymMul).factors;
          for (final child in children) {
            final (cn, cd) = walk(child, depth + 1);
            n = node is SymAdd
                ? multiply(n, cd) + multiply(cn, d)
                : multiply(n, cn);
            d = multiply(d, cd);
          }
          return (n, d);
        }
        if (node is SymPow) {
          final exp = node.exponent.simplify();
          if (exp is! SymNum ||
              !exp.value.isInteger ||
              exp.value.numerator.abs() > BigInt.from(8)) {
            throw const FormatException('Unsupported exponent');
          }
          final (n, d) = walk(node.base, depth + 1);
          final power = exp.value.numerator.toInt();
          if (n.degree * power.abs() > 8 ||
              d.degree * power.abs() > 8 ||
              _coefficientCost(n) * power.abs() > _maxCoefficientBits ||
              _coefficientCost(d) * power.abs() > _maxCoefficientBits) {
            throw const FormatException('Degree bound');
          }
          if (power < 0) {
            denominators.add(n);
            return (d.pow(-power), n.pow(-power));
          }
          return (n.pow(power), d.pow(power));
        }
        throw const FormatException('Not a rational polynomial');
      }

      final (numerator, denominator) = walk(SymParser(expression).parse(), 0);
      if (denominator.isZero || numerator.isZero) return null;
      denominators.add(denominator);
      final roots = SymbolicWeb.solveList(numerator.toString(), variable);
      if (roots == null) return null;
      Rational evaluate(Polynomial poly, Rational x) =>
          poly.coeffs.reversed.fold(Rational.zero, (v, c) => v * x + c);
      final valid = <String>[];
      for (final root in roots) {
        final m = RegExp(r'^(-?\d+)(?:/(\d+))?$').firstMatch(root);
        if (m == null) {
          return null; // Native CAS handles irrational/complex cases.
        }
        final value = Rational(BigInt.parse(m[1]!), BigInt.parse(m[2] ?? '1'));
        if (denominators.every((p) => !evaluate(p, value).isZero)) {
          valid.add(root);
        }
      }
      return valid;
    } catch (_) {
      return null;
    }
  }
}
