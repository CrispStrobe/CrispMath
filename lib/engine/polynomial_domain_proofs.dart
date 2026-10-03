import 'exact_constant.dart';
import 'polynomial.dart';

/// Exact bounded polynomial-domain proofs. Sturm sign variations count real
/// roots without relying on sampling, root rounding or rational-root guesses.
class PolynomialDomainProofs {
  static const maxDegree = 16;
  static const maxBits = 4096;

  static Rational _checked(Rational value) {
    if (value.numerator.abs().bitLength + value.denominator.bitLength > maxBits) {
      throw const FormatException('Polynomial coefficient budget');
    }
    return value;
  }

  static void _bounded(Polynomial p) {
    if (p.degree > maxDegree) {
      throw const FormatException('Polynomial degree budget');
    }
    for (final coefficient in p.coeffs) {
      _checked(coefficient);
    }
  }

  static Polynomial _remainder(Polynomial a, Polynomial b) {
    _bounded(a);
    _bounded(b);
    if (b.isZero) {
      throw const FormatException('Zero polynomial divisor');
    }
    var remainder = a;
    while (!remainder.isZero && remainder.degree >= b.degree) {
      final shift = remainder.degree - b.degree;
      final factor = _checked(remainder.leading / b.leading);
      final coefficients = remainder.coeffs.toList();
      for (var i = 0; i <= b.degree; i++) {
        final product = _checked(factor * b.coeffs[i]);
        coefficients[i + shift] = _checked(coefficients[i + shift] - product);
      }
      remainder = Polynomial.fromCoeffs(coefficients, a.variable);
    }
    return remainder;
  }

  static Polynomial? gcd(Polynomial a, Polynomial b) {
    try {
      _bounded(a);
      _bounded(b);
      var first = a, second = b;
      while (!second.isZero) {
        final remainder = _remainder(first, second);
        first = second;
        second = remainder;
      }
      if (first.isZero) {
        return first;
      }
      final coefficients = first.coeffs
          .map((coefficient) => _checked(coefficient / first.leading)).toList();
      return Polynomial.fromCoeffs(coefficients, a.variable);
    } on FormatException {
      return null;
    }
  }

  static Rational _value(Polynomial p, Rational point) {
    var result = Rational.zero;
    for (final coefficient in p.coeffs.reversed) {
      result = _checked(_checked(result * point) + coefficient);
    }
    return result;
  }

  static Rational? bound(String source) {
    final exact = ExactConstantEvaluator.evaluate(source);
    if (exact == null) {
      return null;
    }
    final parts = exact.split('/');
    final value = Rational(BigInt.parse(parts[0]),
        parts.length == 1 ? BigInt.one : BigInt.parse(parts[1]));
    return value.numerator.abs().bitLength + value.denominator.bitLength <= maxBits
        ? value : null;
  }

  /// Includes roots at either endpoint, repeated even roots, and irrational
  /// roots inside the interval. Null certifies nothing outside the cost bounds.
  static bool? rootInInterval(Polynomial polynomial, Rational a, Rational b) {
    try {
      _bounded(polynomial);
      _checked(a);
      _checked(b);
      final reverse = (a - b).sign > 0;
      final lower = reverse ? b : a, upper = reverse ? a : b;
      if (polynomial.isZero) {
        return true;
      }
      if (polynomial.degree == 0) {
        return false;
      }
      if (_value(polynomial, lower).isZero || _value(polynomial, upper).isZero) {
        return true;
      }
      final sequence = <Polynomial>[polynomial, polynomial.derivative()];
      while (!sequence.last.isZero) {
        final next = _remainder(sequence[sequence.length - 2], sequence.last)
            .scale(Rational.fromInt(-1));
        if (next.isZero) {
          break;
        }
        sequence.add(next);
      }
      int variations(Rational point) {
        var previous = 0, count = 0;
        for (final p in sequence) {
          final sign = _value(p, point).sign;
          if (sign == 0) {
            continue;
          }
          if (previous != 0 && sign != previous) count++;
          previous = sign;
        }
        return count;
      }
      return variations(lower) > variations(upper);
    } on FormatException {
      return null;
    }
  }
}
