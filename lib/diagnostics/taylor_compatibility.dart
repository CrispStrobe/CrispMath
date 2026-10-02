import '../engine/calculator_engine.dart';
import '../engine/numeric_fallback.dart';
import '../engine/symbolic_taylor.dart';

/// Exercises the compatibility path even on libraries with native series().
Map<String, Object> checkTaylorCompatibility(CalculatorEngine engine) {
  final results = <Map<String, Object>>[];
  const cases = [
    ('1/(1-x)', '0', 4, '1+x+x^2+x^3'),
    ('exp(x)', '0', 5, '1+x+x^2/2+x^3/6+x^4/24'),
    ('sin(x)', '0', 6, 'x-x^3/6+x^5/120'),
    ('x^2', '2', 4, 'x^2'),
    ('1/x', '1', 3, '1-(x-1)+(x-1)^2'),
    ('7', '0', 64, '7'),
    ('exp(x)', '0', 1, '1'),
    ('1/x', '0', 4, 'Error'),
    ('exp(x)', '0', 0, 'Error'),
    ('exp(x)', '0', 65, 'Error'),
  ];
  for (final (expression, point, order, expected) in cases) {
    final actual = symbolicTaylorSeries(expression, 'x',
        point: point,
        order: order,
        simplify: engine.simplify,
        differentiate: engine.differentiate,
        substitute: engine.substitute);
    var passed = actual.startsWith('Error') == expected.startsWith('Error');
    if (passed && expected != 'Error') {
      // Independent numeric parser samples the returned polynomial, not the
      // original function (a truncated series deliberately differs from it).
      for (final x in [-1.7, -0.4, 0.0, 0.8, 2.3]) {
        final value = NumericFallbackEvaluator.evalNumeric(actual, {'x': x});
        final target = NumericFallbackEvaluator.evalNumeric(expected, {'x': x});
        passed = passed &&
            value != null &&
            target != null &&
            (value - target).abs() <= 1e-10 * (1 + target.abs());
      }
    }
    results.add({
      'expression': expression,
      'point': point,
      'order': order,
      'actual': actual,
      'expected': expected,
      'passed': passed,
    });
  }
  return {
    'nativeBridge': engine.isNativeAvailable,
    'passed':
        engine.isNativeAvailable && results.every((r) => r['passed'] == true),
    'results': results,
  };
}
