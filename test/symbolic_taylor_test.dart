import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:crisp_math/engine/symbolic_expr.dart';
import 'package:crisp_math/engine/symbolic_taylor.dart';
import 'package:crisp_math/engine/symbolic_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String series(String expression, {String point = '0', int order = 6}) =>
      symbolicTaylorSeries(expression, 'x',
          point: point,
          order: order,
          simplify: (s) =>
              SymbolicExpressionEvaluator.tryEvaluate(s) ?? 'Error',
          differentiate: (s, v) => SymbolicWeb.differentiate(s, v) ?? 'Error',
          substitute: (s, v, p) =>
              s.replaceAll(RegExp('(?<![A-Za-z_])$v(?![A-Za-z_])'), p));

  test('shifted polynomial retains its exact coefficients', () {
    final actual = series('x^3+2*x+1', point: '2', order: 4);
    expect(actual, isNot(startsWith('Error')));
    for (final x in [-2.5, 0.0, 0.7, 2.0, 4.0]) {
      expect(NumericFallbackEvaluator.evalNumeric(actual, {'x': x}),
          closeTo(x * x * x + 2 * x + 1, 1e-10));
    }
  });

  test('truncation at a shifted point discards higher degree terms', () {
    final actual = series('x^3', point: '2', order: 2);
    for (final x in [-1.0, 0.0, 2.0, 3.0]) {
      expect(NumericFallbackEvaluator.evalNumeric(actual, {'x': x}),
          closeTo(8 + 12 * (x - 2), 1e-10));
    }
  });

  test('constant terminates before unnecessary derivatives', () {
    expect(series('7', order: 64), '7');
  });

  test('invalid orders fail before calling the CAS', () {
    for (final order in [0, -1, 65]) {
      expect(series('x', order: order), startsWith('Error: order'));
    }
  });

  test('CAS errors and non-finite coefficients are returned as errors', () {
    for (final value in ['Error: invalid expression', 'nan', 'zoo', 'oo']) {
      final actual = symbolicTaylorSeries('1/x', 'x',
          point: '0',
          order: 3,
          simplify: (s) => s,
          differentiate: (s, v) => '0',
          substitute: (s, v, p) => value);
      expect(actual, startsWith('Error: series'));
    }
  });
}
