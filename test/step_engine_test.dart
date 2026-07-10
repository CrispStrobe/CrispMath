// test/step_engine_test.dart
//
// The step engine identifies the top-level rule and recurses. The
// native bridge isn't available under `flutter test`, so the final
// "Result" step's `after` field will be an error string — that's
// fine, the rule-detection logic doesn't depend on the bridge.
// These tests assert which rule gets emitted for each input shape.

import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/step_engine.dart';
import 'package:crisp_math/engine/symbolic_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final engine = CalculatorEngine();

  List<String> rulesFor(String expr, String variable) =>
      StepEngine.differentiate(expr, variable, engine)
          .map((s) => s.rule)
          .toList();

  group('StepEngine.differentiate — rule selection', () {
    test('constant rule fires when expression has no variable', () {
      final rules = rulesFor('7', 'x');
      expect(rules.first, equals('Constant rule'));
    });

    test('identity rule for d/dx[x]', () {
      final rules = rulesFor('x', 'x');
      expect(rules.first, equals('Identity'));
    });

    test('sum rule splits x + 1 into a sum step plus its subderivatives', () {
      final rules = rulesFor('x + 1', 'x');
      expect(rules.first, equals('Sum/difference rule'));
      expect(rules, contains('Identity'));
      expect(rules, contains('Constant rule'));
    });

    test('product rule fires for x*sin(x)', () {
      final rules = rulesFor('x*sin(x)', 'x');
      expect(rules.first, equals('Product rule'));
      expect(rules, contains('Derivative of sin'));
    });

    test('quotient rule fires for sin(x)/x', () {
      final rules = rulesFor('sin(x)/x', 'x');
      expect(rules.first, equals('Quotient rule'));
    });

    test('power rule fires for x^3', () {
      final rules = rulesFor('x^3', 'x');
      expect(rules.first, equals('Power rule'));
    });

    test('exponential rule fires for 2^x', () {
      final rules = rulesFor('2^x', 'x');
      expect(rules.first, equals('Exponential rule'));
    });

    test('standard function: sin(x) emits the direct-derivative step', () {
      final rules = rulesFor('sin(x)', 'x');
      expect(rules.first, equals('Derivative of sin'));
    });

    test('chain rule label appears when the argument is not just x', () {
      final rules = rulesFor('sin(x^2)', 'x');
      expect(rules.first, contains('Chain rule'));
      expect(rules.first, contains('sin'));
    });

    test('every trace ends with a Result step', () {
      for (final expr in const ['7', 'x', 'x + 1', 'sin(x)', 'x^2']) {
        expect(rulesFor(expr, 'x').last, equals('Result'),
            reason: 'expr=$expr');
      }
    });
  });

  group('StepEngine.solve — equation handling without native bridge', () {
    // The native bridge isn't loaded under flutter test, so every call
    // to engine.simplify/solve/differentiate inside StepEngine returns
    // an "Error: …" string. The step engine still produces structurally
    // valid traces — we only check the shape, not the values.

    test('emits an "Original equation" step when input has =', () {
      final steps = StepEngine.solve('2*x + 3 = 7', 'x', engine);
      expect(steps.first.rule, equals('Original equation'));
    });

    test('emits a "Move all terms to one side" step', () {
      final steps = StepEngine.solve('2*x + 3 = 7', 'x', engine);
      expect(steps.map((s) => s.rule), contains('Move all terms to one side'));
    });

    test('input without "=" is treated as expression = 0', () {
      final steps = StepEngine.solve('x^2 - 4', 'x', engine);
      expect(steps.first.rule, equals('Treat as equation = 0'));
    });

    test('"no variable present" branch fires when expression is constant', () {
      final steps = StepEngine.solve('5 = 5', 'x', engine);
      expect(steps.map((s) => s.rule), contains('No variable present'));
    });

    test('every solve trace has at least one step', () {
      for (final input in const [
        '2*x + 3 = 7',
        'x^2 - 4 = 0',
        'sin(x) = 1/2',
      ]) {
        expect(StepEngine.solve(input, 'x', engine), isNotEmpty,
            reason: 'input=$input');
      }
    });
  });

  group('StepEngine.integrate — rule selection', () {
    List<String> rulesFor(String expr, String variable) =>
        StepEngine.integrate(expr, variable, engine)
            .map((s) => s.rule)
            .toList();

    test('constant rule fires for an integrand without the variable', () {
      final rules = rulesFor('7', 'x');
      expect(rules.first, equals('Constant rule'));
    });

    test('identity / power-rule-1 fires for ∫x dx', () {
      final rules = rulesFor('x', 'x');
      expect(rules.first, equals('Power rule (n=1)'));
    });

    test('power rule fires for ∫x^3 dx with a regular exponent', () {
      final rules = rulesFor('x^3', 'x');
      expect(rules.first, equals('Power rule'));
    });

    test('logarithm rule fires for ∫x^(-1) dx', () {
      final rules = rulesFor('x^-1', 'x');
      expect(rules.first, equals('Logarithm rule'));
    });

    test('logarithm rule also fires for the literal 1/x', () {
      final rules = rulesFor('1/x', 'x');
      expect(rules.first, equals('Logarithm rule'));
    });

    test('sum rule splits ∫(x + 1) dx into a sum step', () {
      final rules = rulesFor('x + 1', 'x');
      expect(rules.first, equals('Sum/difference rule (linearity)'));
      // Should contain at least one sub-rule step from recursing on x and 1.
      expect(rules, contains('Constant rule'));
    });

    test('constant multiple pulls out a constant factor', () {
      final rules = rulesFor('3*x^2', 'x');
      expect(rules.first, equals('Constant multiple'));
      expect(rules, contains('Power rule'));
    });

    test('standard antiderivative fires for ∫sin(x) dx', () {
      final rules = rulesFor('sin(x)', 'x');
      expect(rules.first, equals('Antiderivative of sin'));
    });

    test('falls through to "Unevaluated" for unrecognized shapes', () {
      // sin(x^2) needs substitution but has no factor of 2x to detect
      // it, so even V3's non-linear u-sub doesn't fire — falls through.
      // (Renamed from "Symbolic integration": the fall-through no longer
      // hands off to engine.integrate, which would now recurse.)
      final rules = rulesFor('sin(x^2)', 'x');
      expect(rules.first, equals('Unevaluated'));
    });

    test('repeated IBP rule label fires for ∫x^2*sin(x) dx', () {
      // x^2 · sin(x) is the canonical repeated-IBP example. The
      // detection logic doesn't require the bridge (pattern-only),
      // even though the recursion does — so the *first* step is
      // always the IBP step regardless of native availability.
      final rules = rulesFor('x^2*sin(x)', 'x');
      expect(rules.first, equals('Integration by parts'));
    });

    test('first-degree IBP still fires for ∫x*sin(x) dx (V2 path)', () {
      // The new n=1 branch must behave exactly like the V2 path.
      final rules = rulesFor('x*sin(x)', 'x');
      expect(rules.first, equals('Integration by parts'));
    });

    test('every trace ends with a Result step', () {
      for (final expr in const ['7', 'x', 'x^2', 'sin(x)', '3*x^2']) {
        expect(rulesFor(expr, 'x').last, equals('Result'),
            reason: 'expr=$expr');
      }
    });
  });

  group('StepEngine.differentiate — step content', () {
    test('product rule step references both factors in the after string', () {
      final steps = StepEngine.differentiate('x*sin(x)', 'x', engine);
      final productStep = steps.first;
      expect(productStep.after, contains('x'));
      expect(productStep.after, contains('sin'));
    });

    test('chain rule note mentions the inner derivative', () {
      final steps = StepEngine.differentiate('sin(x^2)', 'x', engine);
      expect(steps.first.note, isNotNull);
      expect(steps.first.note, contains('x'));
    });

    test('constant rule note explains the independence', () {
      final steps = StepEngine.differentiate('42', 'x', engine);
      expect(steps.first.note, isNotNull);
      expect(steps.first.note, contains('does not depend'));
    });
  });

  // =========================================================================
  // Partial fractions — structural tests (bridge-free)
  // =========================================================================
  group('StepEngine.partialFractions — structural (no bridge)', () {
    // Without the native bridge, _partialFractionsStep bails early
    // (engine.differentiate returns "Error: …"), so only the outer
    // frame steps are emitted. We test the public API shape here; the
    // actual decomposition algebra is exercised via the native-host
    // suite (Track D).

    test('always opens with a "Partial fraction decomposition" step', () {
      final steps = StepEngine.partialFractions('1', 'x*(x+1)', 'x', engine);
      expect(steps.first.rule, equals('Partial fraction decomposition'));
    });

    test('simple-poles decomposition produces a Partial-fraction step', () {
      // SymbolicWeb can differentiate/evaluate polynomials in pure Dart,
      // so partial fractions actually works bridge-free for polynomial
      // denominators with integer roots.
      final steps = StepEngine.partialFractions('1', 'x*(x+1)', 'x', engine);
      final rules = steps.map((s) => s.rule).toList();
      expect(rules, contains('Partial-fraction decomposition'));
    });

    test('already-simple denominator (1/x) also hits "Cannot decompose"', () {
      final steps = StepEngine.partialFractions('1', 'x', 'x', engine);
      expect(steps.map((s) => s.rule), contains('Cannot decompose'));
    });

    test('before field references numerator and denominator', () {
      final steps = StepEngine.partialFractions('2', 'x^2 - 1', 'x', engine);
      final first = steps.first;
      expect(first.before, contains('2'));
      expect(first.before, contains('x^2 - 1'));
    });

    test('constant denominator is rejected (no variable in den)', () {
      // Denominator "5" has no x, so _partialFractionsStep returns null
      // immediately.
      final steps = StepEngine.partialFractions('x', '5', 'x', engine);
      expect(steps.map((s) => s.rule), contains('Cannot decompose'));
    });

    test('returns a non-empty list for every input shape', () {
      for (final pair in const [
        ['1', 'x*(x+1)'],
        ['1', 'x'],
        ['x^2', 'x+1'],
      ]) {
        final steps =
            StepEngine.partialFractions(pair[0], pair[1], 'x', engine);
        expect(steps, isNotEmpty, reason: 'num=${pair[0]}, den=${pair[1]}');
      }
    });
  });

  // =========================================================================
  // Quadratic solve — structural tests (bridge-free)
  // =========================================================================
  group('StepEngine.solve — quadratic structural (no bridge)', () {
    // Without the native bridge the degree-detection derivatives
    // return error strings. Since the error string doesn't contain the
    // variable as a standalone word and isn't '0', the engine falls
    // into the linear branch (firstHasVar=false, firstDeriv!='0').
    // We test the outer structural properties — the actual quadratic
    // path is exercised in the native-host (Track D) suite.

    test('x^2 - 5*x + 6 = 0 still produces a non-empty trace', () {
      final steps = StepEngine.solve('x^2 - 5*x + 6 = 0', 'x', engine);
      expect(steps, isNotEmpty);
      expect(steps.first.rule, equals('Original equation'));
    });

    test('x^2 - 5*x + 6 = 0 emits "Move all terms to one side"', () {
      final steps = StepEngine.solve('x^2 - 5*x + 6 = 0', 'x', engine);
      expect(steps.map((s) => s.rule), contains('Move all terms to one side'));
    });

    test('repeated root x^2 - 4*x + 4 = 0 emits original equation', () {
      final steps = StepEngine.solve('x^2 - 4*x + 4 = 0', 'x', engine);
      expect(steps.first.rule, equals('Original equation'));
      expect(steps.length, greaterThanOrEqualTo(2));
    });

    test('no real roots x^2 + 1 = 0 still produces a trace', () {
      final steps = StepEngine.solve('x^2 + 1 = 0', 'x', engine);
      expect(steps, isNotEmpty);
      expect(steps.first.rule, equals('Original equation'));
    });

    test('all quadratic inputs end with a Result or named step', () {
      for (final eq in const [
        'x^2 - 5*x + 6 = 0',
        'x^2 - 4*x + 4 = 0',
        'x^2 + 1 = 0',
      ]) {
        final steps = StepEngine.solve(eq, 'x', engine);
        expect(steps.last.rule, isNotEmpty, reason: 'eq=$eq');
      }
    });
  });

  // =========================================================================
  // Linear solve edge cases
  // =========================================================================
  group('StepEngine.solve — linear edge cases (no bridge)', () {
    test('0*x + 5 = 0 simplifies away x and hits "No variable present"', () {
      // SymbolicWeb.expand simplifies (0*x + 5) - (0) to "5", which
      // has no x, so the engine correctly detects a degenerate case.
      final steps = StepEngine.solve('0*x + 5 = 0', 'x', engine);
      final rules = steps.map((s) => s.rule).toList();
      expect(rules, contains('No variable present'));
      expect(rules.first, equals('Original equation'));
    });

    test('0*x = 0 simplifies to 0 = 0 and hits "No variable present"', () {
      // SymbolicWeb.expand simplifies (0*x) - (0) to "0", so the
      // engine sees a constant equation.
      final steps = StepEngine.solve('0*x = 0', 'x', engine);
      final rules = steps.map((s) => s.rule).toList();
      expect(rules, contains('No variable present'));
      expect(rules.first, equals('Original equation'));
    });

    test('equation without = treated as expression = 0', () {
      final steps = StepEngine.solve('3*x + 9', 'x', engine);
      expect(steps.first.rule, equals('Treat as equation = 0'));
    });

    test('pure constant equation 7 = 3 fires "No variable present"', () {
      final steps = StepEngine.solve('7 = 3', 'x', engine);
      final rules = steps.map((s) => s.rule).toList();
      expect(rules, contains('No variable present'));
    });

    test('identity 0 = 0 fires "No variable present" with always-true', () {
      // body = engine.simplify("(0) - (0)") → error string, but the
      // raw fallback "(0) - (0)" has no x so "No variable present"
      // fires. Whether it says "always true" depends on the body text.
      final steps = StepEngine.solve('0 = 0', 'x', engine);
      final rules = steps.map((s) => s.rule).toList();
      expect(rules, contains('No variable present'));
    });

    test('every solve trace has at least two steps for equations with =', () {
      for (final eq in const [
        '0*x + 5 = 0',
        '0*x = 0',
        '7 = 3',
        'x + 1 = 2',
      ]) {
        final steps = StepEngine.solve(eq, 'x', engine);
        expect(steps.length, greaterThanOrEqualTo(2),
            reason:
                'eq=$eq should have original equation + at least one more step');
      }
    });
  });

  group('StepEngine.antiderivative — authoritative integrator', () {
    // Many rules are pure Dart pattern matches (no engine round-trip), so
    // they resolve even without the native bridge — power rule and the
    // standard trig/exp antiderivatives among them. (Cases that need the
    // bridge to verify a u-substitution etc. are exercised by the native-
    // host suite, Track D.)
    test('power rule produces a verifiable antiderivative for x^2', () {
      final anti = StepEngine.antiderivative('x^2', 'x', engine);
      expect(anti, isNotNull);
      // Differentiating it back returns the integrand (via the web fallback).
      expect(SymbolicWeb.differentiate(anti!.replaceAll('·', '*'), 'x'),
          SymbolicWeb.expand('x^2'));
    });

    test('standard trig antiderivative resolves bridge-free', () {
      // ∫ sin(x) dx = -cos(x) is a pattern rule, not an engine call.
      expect(StepEngine.antiderivative('sin(x)', 'x', engine), '-cos(x)');
    });

    test('returns null (no crash / no recursion) for an unmatched shape', () {
      // The key regression guard: the fall-through must NOT call
      // engine.integrate (which now routes back here) — i.e. no stack
      // overflow, just a clean null. exp(x^2) has no elementary
      // antiderivative, so no rule matches.
      expect(StepEngine.antiderivative('exp(x^2)', 'x', engine), isNull);
    });
  });
}
