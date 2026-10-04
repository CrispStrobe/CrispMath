import 'symbolic_web.dart';

/// Preserves the original nonzero denominator condition for a single quotient.
/// This is deliberately bounded to univariate polynomial denominators through
/// degree two; null never claims that an arbitrary expression has no restrictions.
class RationalDomain {
  const RationalDomain(this.variable, this.denominator, this.excluded);
  final String variable;
  final String denominator;
  final List<String> excluded;
  String get description =>
      '$denominator ≠ 0 ($variable ≠ ${excluded.join(', ')})';

  static RationalDomain? inspect(String source, {String? variable}) {
    if (source.length > 2000) return null;
    var depth = 0;
    var division = -1;
    for (var i = 0; i < source.length; i++) {
      final c = source[i];
      if (c == '(') depth++;
      if (c == ')') depth--;
      if (depth < 0) return null;
      // This inspector describes a whole quotient. A top-level sum such as
      // x^3/3+C must not turn its additive tail into the denominator 3+C.
      if ((c == '+' || c == '-') && depth == 0 && i > 0) {
        final prefix = source.substring(0, i).trimRight();
        if (prefix.isNotEmpty &&
            !'+-*/^('.contains(prefix[prefix.length - 1])) {
          return null;
        }
      }
      if (c == '/' && depth == 0) {
        if (division >= 0) return null;
        division = i;
      }
    }
    if (division < 0 || depth != 0) return null;
    final denominator = source.substring(division + 1).trim();
    final expanded = SymbolicWeb.expand(denominator);
    if (expanded == null) return null;
    final names =
        RegExp(r'[a-zA-Z]+').allMatches(expanded).map((m) => m[0]!).toSet();
    if (names.length != 1 || (variable != null && !names.contains(variable))) {
      return null;
    }
    final name = variable ?? names.single;
    final roots = SymbolicWeb.solveList(expanded, name);
    if (roots == null || roots.isEmpty) return null;
    return RationalDomain(name, denominator, List.unmodifiable(roots));
  }
}
