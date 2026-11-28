import 'polynomial.dart';

/// Exact arithmetic for bounded rational constants, roots and integer rounding.
/// Returns null outside this grammar so callers can use their normal CAS path.
class ExactConstantEvaluator {
  /// With [decimalInput] set (the calculator path), a result that is not a
  /// whole number is answered in decimal, like a pocket calculator:
  /// `9.5-2` → `7.5`, `19/2` → `9.5`, `1/3` → `0.33333333333333333`.
  /// Terminating results print exactly; others are correctly rounded to
  /// [approximateDigits] significant digits (display rounds further). Use
  /// [evaluateDetailed] to also get the exact fraction. Internal callers
  /// that parse the `p/q` text keep the default.
  static String? evaluate(String input, {bool decimalInput = false}) =>
      evaluateDetailed(input, decimalInput: decimalInput)?.text;

  static const approximateDigits = 17;

  static ExactConstantResult? evaluateDetailed(String input,
      {bool decimalInput = false}) {
    if (input.length > 512 ||
        !RegExp(r'^[\d.\s+*/%^!()\-absqrtfloorceilingE]+$').hasMatch(input)) {
      return null;
    }
    try {
      final parser = _ConstantParser(input);
      final result = parser.expression();
      parser.whitespace();
      if (parser.position != input.length) return null;
      if (!decimalInput || result.isInteger) {
        return ExactConstantResult(result.toString());
      }
      final exactText = result.toString();
      if (terminates(result)) {
        final decimal = terminatingDecimal(result);
        if (decimal != null) {
          return ExactConstantResult(decimal, exactFraction: exactText);
        }
      }
      return ExactConstantResult(
          approximateDecimal(result, digits: approximateDigits),
          exactFraction: exactText,
          // `1e-160` is too long to print in plain notation but has one
          // significant digit, so its scientific form is still exact.
          approximate: !_fitsDigits(result, approximateDigits));
    } on _Decline {
      return null;
    } on ArgumentError {
      return null;
    }
  }
}

/// Whether [value] terminates within [digits] significant digits, i.e.
/// [approximateDecimal] prints it without rounding.
bool _fitsDigits(Rational value, int digits) {
  if (!terminates(value)) return false;
  var den = value.denominator;
  var places = 0;
  final ten = BigInt.from(10);
  while (den != BigInt.one) {
    // Multiply up to a power of ten: each factor 2 or 5 costs one place.
    if (den % BigInt.two == BigInt.zero) {
      den ~/= BigInt.two;
    } else {
      den ~/= BigInt.from(5);
    }
    places++;
  }
  final scaled = (value.numerator.abs() * ten.pow(places)) ~/ value.denominator;
  final significant = scaled.toString().replaceFirst(RegExp(r'0+$'), '');
  return significant.length <= digits;
}

/// A result of [ExactConstantEvaluator.evaluateDetailed]. [exactFraction] is
/// the exact `p/q` when [text] is its decimal form; [approximate] is true
/// when that decimal was rounded.
class ExactConstantResult {
  const ExactConstantResult(this.text,
      {this.exactFraction, this.approximate = false});
  final String text;
  final String? exactFraction;
  final bool approximate;
}

/// [value] correctly rounded (half up) to [digits] significant digits, in
/// plain notation for magnitudes 1e-7 ≤ |x| < 1e21 and scientific notation
/// (`1.5e-48`, `2.5e+21`) outside, with trailing zeros removed.
String approximateDecimal(Rational value, {int digits = 17}) {
  if (value.numerator == BigInt.zero) return '0';
  final negative = value.numerator.isNegative;
  final n = value.numerator.abs();
  final d = value.denominator;
  final ten = BigInt.from(10);
  // e = floor(log10(n / d)).
  var e = n.toString().length - d.toString().length;
  bool below(int exp) =>
      exp >= 0 ? n < d * ten.pow(exp) : n * ten.pow(-exp) < d;
  if (below(e)) e--;
  BigInt scaledAt(int exp) {
    final shift = digits - 1 - exp;
    final num = shift >= 0 ? n * ten.pow(shift) : n;
    final den = shift >= 0 ? d : d * ten.pow(-shift);
    return (num * BigInt.two + den) ~/ (den * BigInt.two);
  }

  var scaled = scaledAt(e);
  if (scaled.toString().length > digits) {
    e++;
    scaled = scaledAt(e);
  }
  final mantissa = scaled.toString();
  String trim(String s) =>
      s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  String text;
  if (e >= 21 || e < -7) {
    final frac = trim('0.${mantissa.substring(1)}').substring(1);
    text = '${mantissa[0]}$frac'
        'e${e >= 0 ? '+' : '-'}${e.abs()}';
  } else if (e >= 0) {
    final whole = e + 1 >= mantissa.length
        ? mantissa.padRight(e + 1, '0')
        : mantissa.substring(0, e + 1);
    final frac = e + 1 >= mantissa.length ? '' : mantissa.substring(e + 1);
    text = frac.isEmpty ? whole : trim('$whole.$frac');
  } else {
    text = trim('0.${'0' * (-e - 1)}$mantissa');
  }
  return negative ? '-$text' : text;
}

/// True when [value] has a finite decimal expansion (denominator 2^a·5^b).
bool terminates(Rational value) {
  var den = value.denominator;
  for (final p in [BigInt.two, BigInt.from(5)]) {
    while (den % p == BigInt.zero) {
      den ~/= p;
    }
  }
  return den == BigInt.one;
}

/// Exact decimal text for [value] when its expansion terminates within
/// [maxPlaces] digits (denominator of the form 2^a·5^b), else null.
String? terminatingDecimal(Rational value, {int maxPlaces = 30}) {
  var den = value.denominator;
  var twos = 0, fives = 0;
  final two = BigInt.two, five = BigInt.from(5);
  while (den % two == BigInt.zero) {
    den ~/= two;
    twos++;
  }
  while (den % five == BigInt.zero) {
    den ~/= five;
    fives++;
  }
  if (den != BigInt.one) return null;
  final places = twos > fives ? twos : fives;
  if (places > maxPlaces) return null;
  final scaled =
      value.numerator * BigInt.from(10).pow(places) ~/ value.denominator;
  final negative = scaled.isNegative;
  final digits = scaled.abs().toString().padLeft(places + 1, '0');
  final whole = digits.substring(0, digits.length - places);
  final fraction = digits.substring(digits.length - places);
  final text = places == 0 ? whole : '$whole.$fraction';
  return negative ? '-$text' : text;
}

class _Decline implements Exception {}

class _ConstantParser {
  _ConstantParser(this.input);
  final String input;
  int position = 0;
  int nodes = 0;
  int depth = 0;
  bool sawDecimal = false;
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
    var base = primary();
    // Match the symbolic parser: factorial binds more tightly than power;
    // repeated postfix ! means repeated factorial, not double factorial.
    while (take('!')) {
      base = factorial(base);
    }
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
    if (take('factorial')) {
      if (!take('(')) throw _Decline();
      final value = expression();
      if (!take(')')) throw _Decline();
      return factorial(value);
    }
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
      return checked(Rational(perfectSquareRoot(value.numerator),
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
    if (text.contains(RegExp('[.eE]'))) sawDecimal = true;
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

  Rational factorial(Rational value) {
    // The argument bound applies before converting to int or starting a loop.
    // Each multiplication checks its allocation budget before constructing it.
    if (!value.isInteger ||
        value.numerator.isNegative ||
        value.numerator > BigInt.from(2048)) {
      throw _Decline();
    }
    var product = BigInt.one;
    final n = value.numerator.toInt();
    for (var i = 2; i <= n; i++) {
      final factor = BigInt.from(i);
      productBudget(product, factor);
      product *= factor;
    }
    return checked(Rational(product, BigInt.one));
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
