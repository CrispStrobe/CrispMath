import 'polynomial.dart';
import 'exact_constant.dart';
import 'symbolic_expr.dart';
import 'symbolic_web.dart';
import 'polynomial_domain_proofs.dart';
import 'symbolic_input_budget.dart';

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
    final candidates = _candidatePolynomial(source, variable);
    return candidates == null ? null :
        SymbolicWeb.solveList(candidates.toString(), variable);
  }

  /// Native higher-degree solving must use this domain-filtered polynomial,
  /// rather than resurrecting factors excluded by the original expression.
  static String? candidateEquation(String source, String variable) =>
      _candidatePolynomial(source, variable)?.toString();

  static Polynomial? _candidatePolynomial(String source, String variable) {
    if (source.length > 512 || !boundedSymbolicLiterals(source) ||
        (!source.contains('/') &&
            !RegExp(r'\^\s*\(?\s*-\d').hasMatch(source.replaceAll('**', '^')))) {
      return null;
    }
    try {
      final parts = source.split('=');
      if (parts.length > 2) {
        return null;
      }
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
          final exact = ExactConstantEvaluator.evaluate(renderSymExpr(node.exponent));
          final exponent = exact == null ? null : BigInt.tryParse(exact);
          if (exponent == null || exponent.abs() > BigInt.from(8)) {
            throw const FormatException('Unsupported exponent');
          }
          final (n, d) = walk(node.base, depth + 1);
          final power = exponent.toInt();
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
      if (denominator.isZero || numerator.isZero) {
        return null;
      }
      denominators.add(denominator);
      var candidates = numerator;
      // Original denominators own their exclusions even after cancellation.
      // Remove every multiplicity of a forbidden factor before asking for
      // roots, so repeated, irrational and complex holes cannot reappear.
      for (final excluded in denominators) {
        if (excluded.isZero) {
          return null;
        }
        for (var degree = 0; degree < 8; degree++) {
          final common = PolynomialDomainProofs.gcd(candidates, excluded);
          if (common == null) {
            return null;
          }
          if (common.degree <= 0) {
            break;
          }
          candidates = candidates.divmod(common).quotient;
        }
      }
      return candidates;
    } catch (_) {
      return null;
    }
  }
}
