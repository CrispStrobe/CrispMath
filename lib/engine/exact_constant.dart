import 'polynomial.dart';

/// Exact arithmetic for bounded rational constants, roots and integer rounding.
/// Returns null outside this grammar so callers can use their normal CAS path.
class ExactConstantEvaluator {
  static String? evaluate(String input) {
    if (input.length > 512 ||
        !RegExp(r'^[\d.\s+*/%^()\-absqrtfloorceilingE]+$').hasMatch(input)) {
      return null;
    }
    try {
      final parser = _ConstantParser(input);
      final result = parser.expression();
      parser.whitespace();
      return parser.position == input.length ? result.toString() : null;
    } on _Decline {
      return null;
    } on ArgumentError {
      return null;
    }
  }
}

class _Decline implements Exception {}

class _ConstantParser {
  _ConstantParser(this.input);
  final String input;
  int position = 0;
  int nodes = 0;
  int depth = 0;
  static const maxBits = 16384;

  void whitespace() {
    while (position < input.length && input[position].trim().isEmpty) {
      position++;
    }
  }

  bool take(String token) {
    whitespace();
    if (!input.startsWith(token, position)) return false;
    position += token.length;
    return true;
  }

  Rational checked(Rational value) {
    if (++nodes > 256 ||
        value.numerator.bitLength > maxBits ||
        value.denominator.bitLength > maxBits) {
      throw _Decline();
    }
    return value;
  }

  void productBudget(BigInt a, BigInt b) {
    if (a.bitLength + b.bitLength > maxBits) throw _Decline();
  }

  Rational expression() {
    if (++depth > 32) throw _Decline();
    try {
      var value = product();
      while (true) {
        final plus = take('+');
        if (!plus && !take('-')) break;
        final rhs = product();
        productBudget(value.numerator, rhs.denominator);
        productBudget(rhs.numerator, value.denominator);
        productBudget(value.denominator, rhs.denominator);
        value = checked(plus ? value + rhs : value - rhs);
      }
      return value;
    } finally {
      depth--;
    }
  }

  Rational product() {
    var value = unary();
    while (true) {
      String? op;
      for (final candidate in ['*', '/', '%']) {
        if (take(candidate)) {
          op = candidate;
          break;
        }
      }
      if (op == null) return value;
      final rhs = unary();
      if (op == '%') {
        if (value.denominator != BigInt.one ||
            rhs.denominator != BigInt.one ||
            rhs.numerator == BigInt.zero) {
          throw _Decline();
        }
        value = checked(Rational(value.numerator % rhs.numerator, BigInt.one));
      } else if (op == '*') {
        productBudget(value.numerator, rhs.numerator);
        productBudget(value.denominator, rhs.denominator);
        value = checked(value * rhs);
      } else {
        if (rhs.numerator == BigInt.zero) throw _Decline();
        productBudget(value.numerator, rhs.denominator);
        productBudget(value.denominator, rhs.numerator);
        value = checked(value / rhs);
      }
    }
  }

  Rational unary() {
    if (++depth > 32) throw _Decline();
    try {
      if (take('+')) return unary();
      if (take('-')) return checked(-unary());
      return power();
    } finally {
      depth--;
    }
  }

  Rational power() {
    final base = primary();
    if (!take('^')) return base;
    // Unary recurses into power: a^b^c means a^(b^c), while -a^b
    // means -(a^b). A parenthesized negative base stays negative.
    final exponent = unary();
    if (exponent.denominator != BigInt.one ||
        exponent.numerator.abs() > BigInt.from(1024)) {
      throw _Decline();
    }
    final n = exponent.numerator.toInt();
    if (n < 0 && base.numerator == BigInt.zero) throw _Decline();
    if (base.numerator.bitLength * n.abs() > maxBits ||
        base.denominator.bitLength * n.abs() > maxBits) {
      throw _Decline();
    }
    final num = base.numerator.pow(n.abs());
    final den = base.denominator.pow(n.abs());
    return checked(n < 0 ? Rational(den, num) : Rational(num, den));
  }

  Rational primary() {
    for (final name in ['floor', 'ceiling', 'ceil']) {
      if (!take(name)) continue;
      if (!take('(')) throw _Decline();
      final value = expression();
      if (!take(')')) throw _Decline();
      var integer = value.numerator ~/ value.denominator;
      final fractional = value.numerator % value.denominator != BigInt.zero;
      if (fractional) {
        if (name == 'floor' && value.numerator.isNegative) {
          integer -= BigInt.one;
        } else if (name != 'floor' && !value.numerator.isNegative) {
          integer += BigInt.one;
        }
      }
      return checked(Rational(integer, BigInt.one));
    }
    if (take('sqrt')) {
      if (!take('(')) throw _Decline();
      final value = expression();
      if (!take(')') || value.numerator.isNegative) throw _Decline();
      return checked(Rational(
          perfectSquareRoot(value.numerator),
          perfectSquareRoot(value.denominator)));
    }
    if (take('abs')) {
      if (!take('(')) throw _Decline();
      final value = expression();
      if (!take(')')) throw _Decline();
      return checked(value.numerator.isNegative ? -value : value);
    }
    if (take('(')) {
      final value = expression();
      if (!take(')')) throw _Decline();
      return value;
    }
    whitespace();
    final literal = RegExp(r'^(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?')
        .firstMatch(input.substring(position));
    if (literal == null) throw _Decline();
    final text = literal[0]!;
    position += text.length;
    final parts = text.split(RegExp(r'[eE]'));
    final mantissa = parts.first;
    final exponent = parts.length == 1 ? BigInt.zero : BigInt.parse(parts[1]);
    final dot = mantissa.indexOf('.');
    final places = dot < 0 ? 0 : mantissa.length - dot - 1;
    // Bound the decimal scale before allocating a power of ten. Scientific
    // literals stay rational; converting them to doubles first would erase
    // subnormal roots and exact cancellation across large decimal scales.
    final scale = BigInt.from(places) - exponent;
    if (scale.abs() > BigInt.from(maxBits ~/ 4)) throw _Decline();
    final digits = BigInt.parse(mantissa.replaceAll('.', ''));
    final powerOfTen = BigInt.from(10).pow(scale.abs().toInt());
    return checked(scale.isNegative
        ? Rational(digits * powerOfTen, BigInt.one)
        : Rational(digits, powerOfTen));
  }

  /// Integer Newton iteration never converts to double or guesses exactness.
  /// Parsed operands have already passed maxBits; iteration starts above the
  /// root and decreases, using only integers bounded by that same input size.
  BigInt perfectSquareRoot(BigInt value) {
    if (value == BigInt.zero) return BigInt.zero;
    var root = BigInt.one << ((value.bitLength + 1) ~/ 2);
    while (true) {
      final next = (root + value ~/ root) >> 1;
      if (next >= root) break;
      root = next;
    }
    if (root * root != value) throw _Decline();
    return root;
  }
}
