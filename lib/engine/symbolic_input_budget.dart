/// Guard scientific exponents before a symbolic parser allocates powers of ten.
/// Mantissa size is bounded by the caller's source-length budget.
bool boundedSymbolicLiterals(String source, {int maxScale = 1024}) {
  final literals = RegExp(r'(?:\d+(?:\.\d*)?|\.\d+)(?:[eE]([+-]?\d+))?');
  for (final literal in literals.allMatches(source)) {
    final exponent = int.tryParse(literal[1] ?? '0');
    if (exponent == null) {
      return false;
    }
    final mantissa = literal[0]!.split(RegExp('[eE]')).first;
    final dot = mantissa.indexOf('.');
    final fractionDigits = dot < 0 ? 0 : mantissa.length - dot - 1;
    if (exponent > maxScale || exponent < -maxScale ||
        (exponent - fractionDigits).abs() > maxScale) {
      return false;
    }
  }
  return true;
}
