// test/step_engine_v5_test.dart
//
// Tests for Step Engine V5 + basic step engine verification.

import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/step_engine.dart';

void main() {
  final engine = CalculatorEngine();

  group('StepEngine.integrate — without bridge', () {
    test('power rule works', () {
      final steps = StepEngine.integrate('x^3', 'x', engine);
      expect(steps, isNotEmpty);
      // Last step's `after` should contain the antiderivative.
      expect(steps.last.after, isNotEmpty);
    });

    test('constant rule', () {
      final steps = StepEngine.integrate('5', 'x', engine);
      expect(steps, isNotEmpty);
    });

    test('sum rule', () {
      final steps = StepEngine.integrate('x + 1', 'x', engine);
      expect(steps, isNotEmpty);
    });

    test('identity rule: integrate x', () {
      final steps = StepEngine.integrate('x', 'x', engine);
      expect(steps, isNotEmpty);
    });

    test('partial fraction path does not crash', () {
      final steps = StepEngine.integrate('1/(x^2 - 1)', 'x', engine);
      expect(steps, isNotNull);
    });

    test('trig sub path does not crash', () {
      final steps = StepEngine.integrate('sqrt(4 - x^2)', 'x', engine);
      expect(steps, isNotNull);
    });

    test('sin rule', () {
      final steps = StepEngine.integrate('sin(x)', 'x', engine);
      expect(steps, isNotEmpty);
      expect(steps.last.after, contains('cos'));
    });

    test('cos rule', () {
      final steps = StepEngine.integrate('cos(x)', 'x', engine);
      expect(steps, isNotEmpty);
      expect(steps.last.after, contains('sin'));
    });

    test('exp rule', () {
      final steps = StepEngine.integrate('exp(x)', 'x', engine);
      expect(steps, isNotEmpty);
      expect(steps.last.after, contains('exp'));
    });

    test('constant multiple rule: 3*x^2', () {
      final steps = StepEngine.integrate('3*x^2', 'x', engine);
      expect(steps, isNotEmpty);
    });
  });

  group('StepEngine.differentiate — basic', () {
    test('power rule', () {
      final steps = StepEngine.differentiate('x^3', 'x', engine);
      expect(steps, isNotEmpty);
    });

    test('constant', () {
      final steps = StepEngine.differentiate('7', 'x', engine);
      expect(steps, isNotEmpty);
      expect(steps.last.after, '0');
    });

    test('identity', () {
      final steps = StepEngine.differentiate('x', 'x', engine);
      expect(steps, isNotEmpty);
      expect(steps.last.after, '1');
    });

    test('sum rule', () {
      final steps = StepEngine.differentiate('x^2 + 3*x', 'x', engine);
      expect(steps, isNotEmpty);
    });

    test('sin', () {
      final steps = StepEngine.differentiate('sin(x)', 'x', engine);
      expect(steps, isNotEmpty);
    });

    test('product rule: x*sin(x)', () {
      final steps = StepEngine.differentiate('x*sin(x)', 'x', engine);
      expect(steps, isNotEmpty);
    });
  });

  group('StepEngine.solve — basic', () {
    test('linear equation', () {
      final steps = StepEngine.solve('2*x + 6', 'x', engine);
      expect(steps, isNotEmpty);
    });

    test('quadratic equation', () {
      final steps = StepEngine.solve('x^2 - 4', 'x', engine);
      expect(steps, isNotEmpty);
    });
  });

  group('MathStep', () {
    test('fields', () {
      const step = MathStep(
        rule: 'Test',
        formula: 'f',
        before: 'b',
        after: 'a',
        note: 'n',
      );
      expect(step.rule, 'Test');
      expect(step.formula, 'f');
      expect(step.before, 'b');
      expect(step.after, 'a');
      expect(step.note, 'n');
    });

    test('noteI18n is optional', () {
      const step = MathStep(rule: 'R', formula: 'F', before: 'B', after: 'A');
      expect(step.noteI18n, isNull);
    });
  });

  group('StepNote', () {
    test('key + params', () {
      const note = StepNote('k', {'a': '1'});
      expect(note.key, 'k');
      expect(note.params['a'], '1');
    });

    test('empty params by default', () {
      const note = StepNote('k');
      expect(note.params, isEmpty);
    });
  });
}
