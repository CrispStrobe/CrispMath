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
      print('x^2 - y^2 => $r');
    });

    test('sum of cubes x^3 + y^3', () {
      final r = MultivariateFactoring.factor('x^3 + y^3');
      expect(r, isNotNull);
      print('x^3 + y^3 => $r');
    });

    test('perfect square x^2 + 2*x*y + y^2', () {
      final r = MultivariateFactoring.factor('x^2 + 2*x*y + y^2');
      expect(r, isNotNull);
      print('x^2 + 2xy + y^2 => $r');
    });

    test('common factor x^2*y - x*y^2', () {
      final r = MultivariateFactoring.factor('x^2*y - x*y^2');
      expect(r, isNotNull);
      print('x^2*y - x*y^2 => $r');
    });

    test('SymbolicWeb.factor falls through to multivariate', () {
      final r = SymbolicWeb.factor('x^2 - y^2');
      expect(r, isNotNull);
      print('SymbolicWeb.factor(x^2 - y^2) => $r');
    });

    test('univariate still works', () {
      final r = SymbolicWeb.factor('x^2 - 4');
      expect(r, isNotNull);
      expect(r, contains('x'));
      print('SymbolicWeb.factor(x^2 - 4) => $r');
    });
  });
}
