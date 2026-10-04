import 'exact_constant.dart';
import 'polynomial.dart';
import 'symbolic_expr.dart';
import 'symbolic_input_budget.dart';

/// Exact linear and quadratic equations over Gaussian rational coefficients.
/// Nonconstant denominators decline: their source holes belong to the existing
/// rational-domain solver, and must never be cancelled implicitly here.
class ComplexQuadraticSolver {
  static List<String>? solve(String source, String variable) {
    if (source.length > 512 || !boundedSymbolicLiterals(source) ||
        !RegExp(r'\bI\b').hasMatch(source) || variable == 'I' ||
        !RegExp(r'^[A-Za-z_][A-Za-z_0-9]*$').hasMatch(variable)) {
      return null;
    }
    try {
      final sides = source.split('=');
      if (sides.length > 2) {
        return null;
      }
      final expression = sides.length == 2
          ? '(${sides[0]})-(${sides[1]})' : source;
      var nodes = 0;
      List<_Gaussian> trim(List<_Gaussian> coefficients) {
        while (coefficients.length > 1 && coefficients.last.isZero) {
          coefficients.removeLast();
        }
        return coefficients;
      }
      List<_Gaussian> multiply(List<_Gaussian> a, List<_Gaussian> b) {
        if (a.length + b.length - 2 > 2) {
          throw const FormatException('Complex polynomial degree budget');
        }
        final result = List.filled(a.length + b.length - 1, _Gaussian.zero,
            growable: true);
        for (var i = 0; i < a.length; i++) {
          for (var j = 0; j < b.length; j++) {
            result[i + j] = result[i + j] + a[i] * b[j];
          }
        }
        return trim(result);
      }
      List<_Gaussian> walk(SymExpr node, int depth) {
        if (++nodes > 256 || depth > 32) {
          throw const FormatException('Complex polynomial expression budget');
        }
        if (node is SymNum) {
          return [_Gaussian(node.value, Rational.zero)];
        }
        if (node is SymSym && node.name == 'I') {
          return [_Gaussian.i];
        }
        if (node is SymSym && node.name == variable) {
          return [_Gaussian.zero, _Gaussian.one];
        }
        if (node is SymAdd) {
          var result = [_Gaussian.zero];
          for (final term in node.terms) {
            final next = walk(term, depth + 1);
            final combined = List.filled(
                result.length > next.length ? result.length : next.length,
                _Gaussian.zero, growable: true);
            for (var j = 0; j < combined.length; j++) {
              combined[j] = (j < result.length ? result[j] : _Gaussian.zero) +
                  (j < next.length ? next[j] : _Gaussian.zero);
            }
            result = trim(combined);
          }
          return result;
        }
        if (node is SymMul) {
          var result = [_Gaussian.one];
          for (final factor in node.factors) {
            result = multiply(result, walk(factor, depth + 1));
          }
          return result;
        }
        if (node is SymPow) {
          final exact = ExactConstantEvaluator.evaluate(renderSymExpr(node.exponent));
          final exponent = exact == null ? null : BigInt.tryParse(exact);
          if (exponent == null || exponent.abs() > BigInt.from(128)) {
            throw const FormatException('Complex polynomial power budget');
          }
          var base = walk(node.base, depth + 1);
          final power = exponent.toInt();
          if (power < 0) {
            if (base.length != 1) {
              throw const FormatException('Nonconstant source denominator');
            }
            base = [base.single.inverse()];
          }
          if ((base.length - 1) * power.abs() > 2) {
            throw const FormatException('Complex polynomial degree budget');
          }
          var result = [_Gaussian.one];
          for (var i = 0; i < power.abs(); i++) {
            result = multiply(result, base);
          }
          return result;
        }
        throw const FormatException('Unsupported complex coefficient');
      }
      final coefficients = walk(SymParser(expression).parse(), 0);
      if (coefficients.length == 1) {
        return coefficients.single.isZero ? null : <String>[];
      }
      final b = coefficients[1], c = coefficients[0];
      if (coefficients.length == 2) {
        return [(-c * b.inverse()).toString()];
      }
      final a = coefficients[2];
      final discriminant = b * b - _Gaussian.integer(4) * a * c;
      final denominator = _Gaussian.integer(2) * a;
      final root = discriminant.squareRoot();
      if (root != null) {
        final first = ((-b - root) * denominator.inverse()).toString();
        final second = ((-b + root) * denominator.inverse()).toString();
        return first == second ? [first] : [first, second];
      }
      // These are exact symbolic roots, with the principal square root. Both
      // signs cover the complete quadratic solution set without a real-axis
      // assumption or a floating-point projection of complex coefficients.
      return ['((${-b})-sqrt(($discriminant)))/($denominator)',
              '((${-b})+sqrt(($discriminant)))/($denominator)'];
    } catch (_) {
      return null;
    }
  }
}

class _Gaussian {
  _Gaussian(Rational real, Rational imaginary)
      : real = _checked(real), imaginary = _checked(imaginary);
  factory _Gaussian.integer(int value) => _Gaussian(Rational.fromInt(value), Rational.zero);
  static final zero = _Gaussian.integer(0);
  static final one = _Gaussian.integer(1);
  static final i = _Gaussian(Rational.zero, Rational.one);
  static const maxBits = 4096;
  final Rational real, imaginary;
  bool get isZero => real.isZero && imaginary.isZero;

  static Rational _checked(Rational value) {
    if (value.numerator.abs().bitLength + value.denominator.bitLength > maxBits) {
      throw const FormatException('Complex coefficient budget');
    }
    return value;
  }
  static Rational _multiply(Rational a, Rational b) {
    if (a.numerator.abs().bitLength + b.numerator.abs().bitLength > maxBits ||
        a.denominator.bitLength + b.denominator.bitLength > maxBits) {
      throw const FormatException('Complex product allocation budget');
    }
    return _checked(a * b);
  }
  static Rational _add(Rational a, Rational b) {
    _multiply(a, Rational(b.denominator, BigInt.one));
    _multiply(b, Rational(a.denominator, BigInt.one));
    if (a.denominator.bitLength + b.denominator.bitLength > maxBits) {
      throw const FormatException('Complex sum allocation budget');
    }
    return _checked(a + b);
  }
  _Gaussian operator -() => _Gaussian(-real, -imaginary);
  _Gaussian operator +(_Gaussian other) =>
      _Gaussian(_add(real, other.real), _add(imaginary, other.imaginary));
  _Gaussian operator -(_Gaussian other) => this + -other;
  _Gaussian operator *(_Gaussian other) => _Gaussian(
      _add(_multiply(real, other.real), -_multiply(imaginary, other.imaginary)),
      _add(_multiply(real, other.imaginary), _multiply(imaginary, other.real)));
  _Gaussian inverse() {
    final norm = _add(_multiply(real, real), _multiply(imaginary, imaginary));
    if (norm.isZero) {
      throw const FormatException('Zero complex denominator');
    }
    final reciprocal = Rational(norm.denominator, norm.numerator);
    return _Gaussian(_multiply(real, reciprocal), -_multiply(imaginary, reciprocal));
  }
  static Rational? _sqrt(Rational value) {
    final exact = ExactConstantEvaluator.evaluate('sqrt($value)');
    if (exact == null) {
      return null;
    }
    final parts = exact.split('/');
    return Rational(BigInt.parse(parts[0]),
        parts.length == 1 ? BigInt.one : BigInt.parse(parts[1]));
  }
  _Gaussian? squareRoot() {
    final modulus = _sqrt(_add(_multiply(real, real), _multiply(imaginary, imaginary)));
    if (modulus == null) {
      return null;
    }
    final u = _sqrt(_multiply(_add(modulus, real), Rational(BigInt.one, BigInt.two)));
    final v = _sqrt(_multiply(_add(modulus, -real), Rational(BigInt.one, BigInt.two)));
    return u == null || v == null ? null : _Gaussian(u, imaginary.sign < 0 ? -v : v);
  }
  @override
  String toString() {
    if (imaginary.isZero) {
      return real.toString();
    }
    final term = imaginary.abs == Rational.one ? 'I' : '${imaginary.abs}*I';
    if (real.isZero) {
      return '${imaginary.sign < 0 ? '-' : ''}$term';
    }
    return '$real${imaginary.sign < 0 ? '-' : '+'}$term';
  }
}
