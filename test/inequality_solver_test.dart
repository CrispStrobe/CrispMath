// Unit tests for the polynomial inequality solver (roadmap C3).
// Headless: roots come from the pure-Dart SymbolicWeb path, which is
// exactly what the pre-WASM web fallback uses. The SymPy-certified
// corpus (cas_corpus) covers the same cases plus the native root path.

import 'package:crisp_calc/engine/calculator_engine.dart';
import 'package:crisp_calc/engine/inequality_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final engine = CalculatorEngine();

  String solve(String ineq, [String v = 'x']) =>
      InequalitySolver.solve(engine, ineq, v);

  group('InequalitySolver', () {
    test('strict quadratic, two roots', () {
      expect(solve('x^2 - 4 > 0'), 'x < -2 ∨ x > 2');
      expect(solve('x^2 - 4 < 0'), '-2 < x < 2');
    });

    test('non-strict quadratic includes endpoints', () {
      expect(solve('x^2 - 4 >= 0'), 'x ≤ -2 ∨ x ≥ 2');
      expect(solve('x^2 - 4 <= 0'), '-2 ≤ x ≤ 2');
    });

    test('linear', () {
      expect(solve('2*x + 3 < 0'), 'x < -3/2');
      expect(solve('-x + 1 > 0'), 'x < 1'); // negative leading coefficient
    });

    test('rhs not zero is moved over', () {
      expect(solve('x^2 < 4'), '-2 < x < 2');
      expect(solve('2*x + 3 < x'), 'x < -3');
    });

    test('double root', () {
      expect(solve('x^2 - 2*x + 1 > 0'), 'x ≠ 1');
      expect(solve('x^2 - 2*x + 1 >= 0'), 'x ∈ ℝ');
      expect(solve('x^2 - 2*x + 1 <= 0'), 'x = 1');
      expect(solve('x^2 - 2*x + 1 < 0'), 'x ∈ ∅');
    });

    test('no real roots', () {
      expect(solve('x^2 + 1 > 0'), 'x ∈ ℝ');
      expect(solve('x^2 + 1 < 0'), 'x ∈ ∅');
    });

    test('unicode operators accepted', () {
      expect(solve('x^2 - 4 ≤ 0'), '-2 ≤ x ≤ 2');
      expect(solve('x^2 - 4 ≥ 0'), 'x ≤ -2 ∨ x ≥ 2');
    });

    test('surd endpoints stay exact', () {
      final r = solve('x^2 - 2 >= 0');
      expect(r, contains('sqrt(2)'));
      expect(r, isNot(contains('1.41')));
    });

    test('looksLikeInequality', () {
      expect(InequalitySolver.looksLikeInequality('x^2 - 4 > 0'), isTrue);
      expect(InequalitySolver.looksLikeInequality('x >= 2'), isTrue);
      expect(InequalitySolver.looksLikeInequality('x + 2'), isFalse);
      expect(InequalitySolver.looksLikeInequality('x = 2'), isFalse);
    });

    test('non-polynomial input errors cleanly', () {
      expect(solve('sin(x) > 0'), startsWith('Error'));
    });
  });
}
