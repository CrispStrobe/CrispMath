import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_calc/engine/multivariate_poly.dart';
import 'package:crisp_calc/engine/symbolic_web.dart';

void main() {
  group('MultivariateFactoring', () {
    test('difference of squares x^2 - y^2', () {
      final r = MultivariateFactoring.factor('x^2 - y^2');
      expect(r, isNotNull);
      // Should be (x+y)*(x-y) or similar
      expect(r!.contains('x'), isTrue);
      expect(r.contains('y'), isTrue);
    });

    test('sum of cubes x^3 + y^3', () {
      final r = MultivariateFactoring.factor('x^3 + y^3');
      expect(r, isNotNull);
    });

    test('perfect square x^2 + 2*x*y + y^2', () {
      final r = MultivariateFactoring.factor('x^2 + 2*x*y + y^2');
      expect(r, isNotNull);
    });

    test('common factor x^2*y - x*y^2', () {
      final r = MultivariateFactoring.factor('x^2*y - x*y^2');
      expect(r, isNotNull);
    });

    test('SymbolicWeb.factor falls through to multivariate', () {
      final r = SymbolicWeb.factor('x^2 - y^2');
      expect(r, isNotNull);
    });

    test('univariate still works', () {
      final r = SymbolicWeb.factor('x^2 - 4');
      expect(r, isNotNull);
      expect(r, contains('x'));
    });
  });
}
