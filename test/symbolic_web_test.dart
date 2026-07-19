// test/symbolic_web_test.dart
//
// The pure-Dart web CAS fallback: expand / differentiate / solve for
// single-variable polynomials, with everything outside that grammar
// returning null so the caller falls through to the native-only path.

import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/symbolic_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SymbolicWeb.expand', () {
    test('square of a binomial', () {
      expect(SymbolicWeb.expand('(x+1)^2'), 'x^2 + 2x + 1');
    });

    test('difference of squares', () {
      expect(SymbolicWeb.expand('(x+1)(x-1)'), 'x^2 - 1');
    });

    test('cube', () {
      expect(SymbolicWeb.expand('(x+1)^3'), 'x^3 + 3x^2 + 3x + 1');
    });

    test('scalar distribution', () {
      expect(SymbolicWeb.expand('2*(x+3)'), '2x + 6');
      expect(SymbolicWeb.expand('2(x+3)'), '2x + 6'); // implicit mult
    });

    test('product with monomial', () {
      expect(SymbolicWeb.expand('x*(x+1)'), 'x^2 + x');
    });

    test('division by a constant', () {
      expect(SymbolicWeb.expand('(2x+4)/2'), 'x + 2');
    });

    test('collects like terms', () {
      expect(SymbolicWeb.expand('x + x + x'), '3x');
      expect(SymbolicWeb.expand('(x+1)^2 - x^2'), '2x + 1');
    });

    test('non-x variable preserved', () {
      expect(SymbolicWeb.expand('(t+1)^2'), 't^2 + 2t + 1');
    });

    test('accepts ** as power', () {
      expect(SymbolicWeb.expand('(x+1)**2'), 'x^2 + 2x + 1');
    });

    test('rational coefficients stay exact', () {
      expect(SymbolicWeb.expand('(x+1)/2'), '1/2x + 1/2');
    });

    test('unsupported input returns null', () {
      expect(SymbolicWeb.expand('sin(x)'), isNull); // transcendental
      expect(SymbolicWeb.expand('x*y'), isNull); // multivariate
      expect(SymbolicWeb.expand('1/x'), isNull); // rational function
      expect(SymbolicWeb.expand('x^-2'), isNull); // negative power
      expect(SymbolicWeb.expand('x^x'), isNull); // symbolic power
      expect(SymbolicWeb.expand('(x+1'), isNull); // unbalanced
      expect(SymbolicWeb.expand('x = 1'), isNull); // equation
    });
  });

  group('SymbolicWeb.differentiate', () {
    test('power rule', () {
      expect(SymbolicWeb.differentiate('x^3', 'x'), '3x^2');
    });

    test('polynomial', () {
      expect(SymbolicWeb.differentiate('x^2 + 2x + 1', 'x'), '2x + 2');
    });

    test('expands before differentiating', () {
      expect(SymbolicWeb.differentiate('(x+1)^2', 'x'), '2x + 2');
    });

    test('constant', () {
      expect(SymbolicWeb.differentiate('5', 'x'), '0');
    });

    test('with respect to an absent variable is zero', () {
      expect(SymbolicWeb.differentiate('x^2', 'y'), '0');
    });

    test('non-polynomial returns null', () {
      expect(SymbolicWeb.differentiate('sin(x)', 'x'), isNull);
      expect(SymbolicWeb.differentiate('1/x', 'x'), isNull);
    });
  });

  group('SymbolicWeb.solveList', () {
    test('linear', () {
      expect(SymbolicWeb.solveList('2x + 3 = 7', 'x'), ['2']);
      expect(SymbolicWeb.solveList('2x - 4', 'x'), ['2']);
    });

    test('linear with rational root', () {
      expect(SymbolicWeb.solveList('2x - 1', 'x'), ['1/2']);
    });

    test('quadratic, rational roots', () {
      expect(SymbolicWeb.solveList('x^2 - 4', 'x'), ['2', '-2']);
      expect(SymbolicWeb.solveList('x^2 - 5x + 6', 'x'), ['3', '2']);
    });

    test('quadratic, double root', () {
      expect(SymbolicWeb.solveList('x^2 - 2x + 1', 'x'), ['1']);
    });

    test('quadratic, surd roots', () {
      expect(SymbolicWeb.solveList('x^2 - 2', 'x'), ['sqrt(2)', '-sqrt(2)']);
    });

    test('quadratic, surd roots with rational part', () {
      expect(
        SymbolicWeb.solveList('x^2 - x - 1', 'x'),
        ['1/2 + 1/2*sqrt(5)', '1/2 - 1/2*sqrt(5)'],
      );
    });

    test('quadratic, pure imaginary roots', () {
      expect(SymbolicWeb.solveList('x^2 + 1', 'x'), ['I', '-I']);
    });

    test('quadratic, complex roots', () {
      expect(
        SymbolicWeb.solveList('x^2 + 2x + 5', 'x'),
        ['-1 + 2*I', '-1 - 2*I'],
      );
    });

    test('equation form, both sides', () {
      expect(SymbolicWeb.solveList('x^2 = 2x + 1', 'x'),
          ['1 + sqrt(2)', '1 - sqrt(2)']);
    });

    test('no solution for a non-zero constant', () {
      expect(SymbolicWeb.solveList('5', 'x'), equals(<String>[]));
    });

    test('unsupported returns null', () {
      expect(SymbolicWeb.solveList('x^3 - 1', 'x'), isNull); // cubic
      expect(SymbolicWeb.solveList('sin(x)', 'x'), isNull);
      expect(SymbolicWeb.solveList('x^2 - 4', 'y'), isNull); // wrong var
    });
  });

  group('SymbolicWeb.factor', () {
    // Factors are emitted in ascending-root order (deterministic). The
    // round-trip test below is the real correctness guard.
    test('difference of squares', () {
      expect(SymbolicWeb.factor('x^2 - 1'), '(x + 1)*(x - 1)');
    });

    test('monic quadratic with two integer roots', () {
      expect(SymbolicWeb.factor('x^2 - 5x + 6'), '(x - 2)*(x - 3)');
    });

    test('cubic with three integer roots', () {
      expect(SymbolicWeb.factor('x^3 - 6x^2 + 11x - 6'),
          '(x - 1)*(x - 2)*(x - 3)');
    });

    test('repeated root carries multiplicity', () {
      expect(SymbolicWeb.factor('x^2 - 2x + 1'), '(x - 1)^2');
    });

    test('common integer content is pulled out', () {
      expect(SymbolicWeb.factor('2x^2 - 2'), '2*(x + 1)*(x - 1)');
    });

    test('factors out a zero root', () {
      expect(SymbolicWeb.factor('x^2 - x'), 'x*(x - 1)');
    });

    test('irreducible-over-Q quadratic is returned intact', () {
      // No rational roots → reported correctly, just not split.
      expect(SymbolicWeb.factor('x^2 + 1'), 'x^2 + 1');
      expect(SymbolicWeb.factor('x^2 - 2'), 'x^2 - 2');
    });

    test('rational root yields a fractional linear factor', () {
      // 2x^2 - 3x + 1 = 2(x - 1/2)(x - 1)
      expect(SymbolicWeb.factor('2x^2 - 3x + 1'), '2*(x - 1/2)*(x - 1)');
    });

    test('non-x variable preserved', () {
      expect(SymbolicWeb.factor('y^2 - 9'), '(y + 3)*(y - 3)');
    });

    test('out-of-grammar input returns null', () {
      expect(SymbolicWeb.factor('sin(x)'), isNull);
      expect(SymbolicWeb.factor('x*y - 1'), isNull); // multivariate
    });

    test('the product of the reported factors re-expands to the input', () {
      // Round-trip guard: factor then expand each case back.
      for (final input in ['x^2 - 1', 'x^3 - 6x^2 + 11x - 6', '2x^2 - 2']) {
        final f = SymbolicWeb.factor(input)!;
        expect(SymbolicWeb.expand(f), SymbolicWeb.expand(input),
            reason: 'factor($input) = $f did not re-expand to $input');
      }
    });
  });

  group('SymbolicWeb.integrate', () {
    test('power rule', () {
      expect(SymbolicWeb.integrate('x^2', 'x'), '1/3x^3');
    });

    test('linearity', () {
      expect(SymbolicWeb.integrate('3x^2 + 2x', 'x'), 'x^3 + x^2');
    });

    test('constant', () {
      expect(SymbolicWeb.integrate('5', 'x'), '5x');
    });

    test('identity', () {
      expect(SymbolicWeb.integrate('x', 'x'), '1/2x^2');
    });

    test('non-polynomial returns null', () {
      expect(SymbolicWeb.integrate('sin(x)', 'x'), isNull);
    });

    test('definite integral with rational bounds is exact', () {
      expect(SymbolicWeb.definiteIntegral('x^2', 'x', '0', '1'), '1/3');
      expect(SymbolicWeb.definiteIntegral('x', 'x', '0', '2'), '2');
      expect(SymbolicWeb.definiteIntegral('2x + 1', 'x', '1', '3'), '10');
    });

    test('definite integral with a non-rational bound returns null', () {
      expect(SymbolicWeb.definiteIntegral('x^2', 'x', '0', 'pi'), isNull);
    });
  });

  group('CalculatorEngine routes CAS through the web fallback native-less', () {
    late CalculatorEngine engine;
    setUpAll(() => engine = CalculatorEngine());

    test('expand / differentiate / solve resolve instead of erroring', () {
      // The test host has no native bridge, mirroring the web build.
      if (engine.isNativeAvailable) return; // native → SymEngine owns it
      expect(engine.expand('(x+1)^2'), 'x^2 + 2x + 1');
      expect(engine.differentiate('x^3', 'x'), '3x^2');
      expect(engine.solve('x^2 - 4', 'x'), 'x = {2, -2}');
      expect(engine.solve('2x + 3 = 7', 'x'), 'x = 2');
    });

    test('unsupported CAS input still reports the native requirement', () {
      if (engine.isNativeAvailable) return;
      expect(engine.differentiate('sin(x)', 'x'),
          contains('requires native library'));
      expect(engine.solve('x^3 - 1', 'x'), contains('requires native library'));
    });
  });

  group('SymbolicWeb rejects pathological input cheaply (robustness)', () {
    // A hostile exponent must not drive pow() into a multi-second O(deg^2)
    // expansion. The polynomial parser strips spaces, so `x^200 12` fuses into
    // the exponent `x^20012`; both this and a bare `x^999999` used to hang for
    // 10-20s. They must now bail (null) fast. Guard is a wall-clock budget so a
    // regression re-introduces a visible failure, not just a slow test.
    test('huge exponents bail quickly instead of hanging', () {
      final sw = Stopwatch()..start();
      expect(SymbolicWeb.expand('x^999999'), isNull);
      expect(SymbolicWeb.expand('x^200 12'), isNull); // space-strip -> x^20012
      expect(SymbolicWeb.expand('3x^248 12'), isNull);
      expect(SymbolicWeb.expand('(x^10)^5000'), isNull);
      expect(SymbolicWeb.factor('x^999999 - 1'), isNull);
      expect(SymbolicWeb.differentiate('x^999999', 'x'), isNull);
      expect(sw.elapsedMilliseconds, lessThan(3000),
          reason: 'degree cap must keep pathological input cheap');
    });

    test('long factor chains are degree-bounded', () {
      final sw = Stopwatch()..start();
      expect(SymbolicWeb.expand('x^2000 x^2000 x^2000 x^2000 x^2000'), isNull);
      expect(sw.elapsedMilliseconds, lessThan(3000));
    });

    test('dense high-degree expansions bail fast (decode-bomb guard)', () {
      // A dense expansion's coefficients are BigInts that grow with the degree,
      // so it is super-quadratic in wall time even though the degree is capped.
      // Two paths reach it and both must bail (null) fast, not spend 5-8s:
      //   - a single dense power:      (x+1)^4096
      //   - a long implicit-mult chain: (x+1)(x+1)…(x+1)  (5000 factors)
      // Exercise all four public String-entry ops on each, under one budget.
      final sw = Stopwatch()..start();
      const densePow = '(x+1)^4096';
      final longChain = '(x+1)' * 5000;
      for (final s in [densePow, longChain]) {
        expect(SymbolicWeb.expand(s), isNull, reason: s);
        expect(SymbolicWeb.factor(s), isNull, reason: s);
        expect(SymbolicWeb.differentiate(s, 'x'), isNull, reason: s);
        expect(SymbolicWeb.solveList(s, 'x'), isNull, reason: s);
      }
      expect(sw.elapsedMilliseconds, lessThan(3000),
          reason: 'the degree cap must keep dense expansions cheap');
    });

    test('multivariate factoring bails fast on dense expansions', () {
      // `factor(...)` falls through to the multivariate parser for inputs the
      // univariate parser rejects. That parser expands products/powers into a
      // flat term map with a linear per-term lookup (~O(terms^2) per multiply),
      // so a huge power, a long chain, or a many-variable dense power must bail
      // (null) fast, not hang. Both the public `factor` and `factorMultivariate`
      // entries reach it.
      final sw = Stopwatch()..start();
      final cases = <String>[
        '(x+y)^100000', // huge exponent
        '(x+y)' * 2000, // long implicit-multiply chain
        '(w+x+y+z)^32', // only degree 32 but ~6500 terms
        'x^99999*y', // huge sparse exponent
      ];
      for (final s in cases) {
        expect(SymbolicWeb.factorMultivariate(s), isNull, reason: s);
        expect(SymbolicWeb.factor(s), isNull, reason: s);
      }
      expect(sw.elapsedMilliseconds, lessThan(3000),
          reason: 'multivariate degree/term caps must keep expansion cheap');
    });

    test('deeply nested parens bail cleanly, not StackOverflowError', () {
      final open = '(' * 20000;
      // Must return null (unsupported), never throw a StackOverflowError that
      // escapes the String?-returning API.
      expect(
          () => SymbolicWeb.expand('$open 1 ${')' * 20000}'), returnsNormally);
      expect(SymbolicWeb.expand('$open 1 ${')' * 20000}'), isNull);
      expect(() => SymbolicWeb.expand('x^$open'), returnsNormally);
    });

    test('legitimate expansions are unaffected by the caps', () {
      expect(SymbolicWeb.expand('(x+1)^2'), 'x^2 + 2x + 1');
      expect(SymbolicWeb.expand('(x+1)(x-1)'), 'x^2 - 1');
      // (x+1)^100 is degree 100 — well under the cap — and still expands.
      final big = SymbolicWeb.expand('(x+1)^100');
      expect(big, isNotNull);
      expect(big, startsWith('x^100 + 100x^99'));
    });
  });
}
