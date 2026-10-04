import 'numeric_fallback.dart';

/// Finite real endpoint evaluation of an established antiderivative.
/// Domain/pole validation belongs to the caller before applying the FTC.
class DefiniteAntiderivative {
  static double? evaluate(String antiderivative, String variable,
      String lower, String upper) {
    final a = NumericFallbackEvaluator.evalNumeric(lower);
    final b = NumericFallbackEvaluator.evalNumeric(upper);
    if (a == null || b == null || !a.isFinite || !b.isFinite) return null;
    final expression =
        NumericFallbackEvaluator.compile(antiderivative.replaceAll('·', '*'));
    if (expression == null) return null;
    final atUpper = expression.evaluate({variable: b});
    final atLower = expression.evaluate({variable: a});
    if (atUpper == null ||
        atLower == null ||
        !atUpper.isFinite ||
        !atLower.isFinite) {
      return null;
    }
    final difference = atUpper - atLower;
    return difference.isFinite ? difference : null;
  }
}
