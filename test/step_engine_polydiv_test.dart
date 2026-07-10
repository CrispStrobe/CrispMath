import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_math/engine/step_engine.dart';
import 'package:crisp_math/engine/calculator_engine.dart';

void main() {
  final engine = CalculatorEngine();

  group('StepEngine.polyDivide', () {
    test('x^2 - 1 divided by x - 1 gives x + 1', () {
      final steps = StepEngine.polyDivide('x^2 - 1', 'x - 1', 'x', engine);
      expect(steps, isNotEmpty);
      final result = steps.last;
      expect(result.rule, 'Result');
      expect(result.after, contains('x + 1'));
      // Exact division — no remainder
      expect(result.after.contains('remainder'), isFalse);
    });

    test('x^3 + 1 divided by x + 1 gives x^2 - x + 1', () {
      final steps = StepEngine.polyDivide('x^3 + 1', 'x + 1', 'x', engine);
      expect(steps, isNotEmpty);
      final result = steps.last;
      expect(result.rule, 'Result');
      expect(result.after, contains('x^2'));
    });

    test('x^2 + 3x + 5 divided by x + 1 has remainder 3', () {
      final steps = StepEngine.polyDivide('x^2 + 3x + 5', 'x + 1', 'x', engine);
      expect(steps, isNotEmpty);
      final result = steps.last;
      expect(result.rule, 'Result');
      expect(result.after, contains('remainder'));
      expect(result.after, contains('3'));
    });

    test('degree too low returns quotient 0', () {
      final steps = StepEngine.polyDivide('x + 1', 'x^2 + 1', 'x', engine);
      expect(steps, isNotEmpty);
      final result = steps.last;
      expect(result.after, contains('0'));
    });

    test('constant divided by constant', () {
      final steps = StepEngine.polyDivide('6', '3', 'x', engine);
      expect(steps, isNotEmpty);
      final result = steps.last;
      expect(result.rule, 'Result');
      expect(result.after, contains('2'));
    });

    test('generates intermediate steps', () {
      final steps = StepEngine.polyDivide('x^2 - 1', 'x - 1', 'x', engine);
      // Should have: setup + at least one divide+subtract pair + result
      expect(steps.length, greaterThanOrEqualTo(3));
      expect(steps.first.rule, contains('Set up'));
      expect(steps.last.rule, 'Result');
    });

    test('division by zero polynomial returns error', () {
      final steps = StepEngine.polyDivide('x^2 + 1', '0', 'x', engine);
      expect(steps, isNotEmpty);
      expect(steps.last.after, contains('Error'));
    });

    test('unparseable input returns error', () {
      final steps = StepEngine.polyDivide('sin(x)', 'x + 1', 'x', engine);
      expect(steps, isNotEmpty);
      expect(steps.last.after, contains('Error'));
    });
  });
}
