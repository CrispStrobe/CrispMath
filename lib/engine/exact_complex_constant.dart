import 'polynomial.dart';
import 'symbolic_expr.dart';
import 'exact_constant.dart';
import 'symbolic_input_budget.dart';

/// Exact Gaussian-rational constants with bounded arithmetic. Unknown symbols
/// and functions decline: conjugation must never assume a free symbol is real.
class ExactComplexConstant {
  static const maxBits = 4096;

  static Rational checked(Rational value) {
    if (value.numerator.abs().bitLength + value.denominator.bitLength > maxBits) {
      throw const FormatException('Complex coefficient budget');
    }
    return value;
  }

  static Rational? _constant(SymExpr expression) {
    final exact = ExactConstantEvaluator.evaluate(renderSymExpr(expression));
    if (exact == null) {
      return null;
    }
    final parts = exact.split('/');
    return checked(Rational(BigInt.parse(parts[0]),
        parts.length == 1 ? BigInt.one : BigInt.parse(parts[1])));
  }

  static String? conjugation(String source) {
    if (source.length > 512 || !RegExp(r'\bconjugate\s*\(').hasMatch(source) ||
        !boundedSymbolicLiterals(source)) {
      return null;
    }
    var nodes = 0;
    (Rational, Rational) add((Rational, Rational) a, (Rational, Rational) b) =>
        (checked(a.$1 + b.$1), checked(a.$2 + b.$2));
    (Rational, Rational) multiply((Rational, Rational) a, (Rational, Rational) b) => (
      checked(checked(a.$1 * b.$1) - checked(a.$2 * b.$2)),
      checked(checked(a.$1 * b.$2) + checked(a.$2 * b.$1)),
    );
    (Rational, Rational) walk(SymExpr node, int depth) {
      if (++nodes > 256 || depth > 32) {
        throw const FormatException('Complex expression budget');
      }
      if (node is SymNum) {
        return (checked(node.value), Rational.zero);
      }
      if (node is SymSym && node.name == 'I') {
        return (Rational.zero, Rational.one);
      }
      if (node is SymAdd || node is SymMul) {
        var result = (node is SymAdd ? Rational.zero : Rational.one, Rational.zero);
        final children = node is SymAdd ? node.terms : (node as SymMul).factors;
        for (final child in children) {
          final value = walk(child, depth + 1);
          result = node is SymAdd ? add(result, value) : multiply(result, value);
        }
        return result;
      }
      if (node is SymCall && node.name == 'conjugate' && node.args.length == 1) {
        final value = walk(node.args.single, depth + 1);
        return (value.$1, -value.$2);
      }
      if (node is SymPow) {
        final exponent = _constant(node.exponent);
        if (exponent == null || !exponent.isInteger ||
            exponent.numerator.abs() > BigInt.from(128)) {
          throw const FormatException('Unsupported complex exponent');
        }
        var base = walk(node.base, depth + 1);
        final power = exponent.numerator.toInt();
        if (power < 0) {
          final norm = checked(checked(base.$1 * base.$1) + checked(base.$2 * base.$2));
          if (norm.isZero) {
            throw const FormatException('Zero complex divisor');
          }
          base = (checked(base.$1 / norm), checked(-base.$2 / norm));
        }
        var result = (Rational.one, Rational.zero);
        for (var i = 0; i < power.abs(); i++) {
          result = multiply(result, base);
        }
        return result;
      }
      throw const FormatException('Not a Gaussian-rational constant');
    }
    try {
      final value = walk(SymParser(source).parse(), 0);
      if (value.$2.isZero) {
        return value.$1.toString();
      }
      final imaginary = '${value.$2.abs}*I';
      if (value.$1.isZero) {
        return '${value.$2.sign < 0 ? '-' : ''}$imaginary';
      }
      return '${value.$1}${value.$2.sign < 0 ? '-' : '+'}$imaginary';
    } catch (_) {
      return null;
    }
  }

  /// Rewrite principal negative-base rational powers to their polar form.
  /// This removes backend-dependent real cube-root conventions while retaining
  /// exp(i*pi*p/q), the principal argument of every strictly negative real.
  /// The caller evaluates this positive-base/trigonometric constant normally.
  static String? principalPower(String source) {
    if (source.length > 512 || (!source.contains('^') && !source.contains('**')) ||
        !boundedSymbolicLiterals(source)) {
      return null;
    }
    try {
      var nodes = 0, changed = false;
      SymExpr walk(SymExpr node, int depth) {
        if (++nodes > 256 || depth > 32) {
          throw const FormatException('Principal power budget');
        }
        if (node is SymAdd) {
          return SymAdd(node.terms.map((n) => walk(n, depth + 1)).toList());
        }
        if (node is SymMul) {
          return SymMul(node.factors.map((n) => walk(n, depth + 1)).toList());
        }
        if (node is SymCall) {
          return SymCall(node.name, node.args.map((n) => walk(n, depth + 1)).toList());
        }
        if (node is! SymPow) {
          return node;
        }
        final base = _constant(node.base), exponent = _constant(node.exponent);
        if (base != null && exponent != null && base.sign < 0 && !exponent.isInteger &&
            exponent.denominator <= BigInt.from(128) &&
            exponent.numerator.abs() <= BigInt.from(128)) {
          changed = true;
          final angle = SymMul([const SymSym('pi'), SymNum(exponent)]);
          return SymMul([
            SymPow(SymNum(base.abs), SymNum(exponent)),
            SymAdd([SymCall('cos', [angle]), SymMul([const SymSym('I'), SymCall('sin', [angle])])]),
          ]);
        }
        return SymPow(walk(node.base, depth + 1), walk(node.exponent, depth + 1));
      }
      String native(SymExpr node) {
        if (node is SymNum) {
          return '(${node.value})';
        }
        if (node is SymSym) {
          return node.name;
        }
        if (node is SymAdd) {
          return '(${node.terms.map(native).join('+')})';
        }
        if (node is SymMul) {
          return '(${node.factors.map(native).join('*')})';
        }
        if (node is SymPow) {
          return '(${native(node.base)})^(${native(node.exponent)})';
        }
        if (node is SymCall) {
          return '${node.name}(${node.args.map(native).join(',')})';
        }
        throw const FormatException('Unknown expression');
      }
      final result = walk(SymParser(source).parse(), 0);
      final rendered = changed ? native(result) : null;
      return rendered != null && rendered.length <= 4096 ? rendered : null;
    } catch (_) {
      return null;
    }
  }
}
