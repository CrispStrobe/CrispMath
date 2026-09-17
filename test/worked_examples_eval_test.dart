import 'package:crisp_math/engine/worked_examples.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('evaluate all worked examples through the engine', () {
    final engine = CalculatorEngine();
    
    // Check if bridge is available. If not, we can't test native evaluation.
    if (!engine.isNativeAvailable) {
      print('Skipping evaluation: Native bridge not available in this test environment.');
      return;
    }

    int evaluated = 0;
    for (final e in WorkedExamples.all) {
      final expr = e.expression;
      
      // Skip UI commands
      if (expr.startsWith('open:') || expr.startsWith('dsl:')) {
        continue;
      }
      
      try {
        final result = engine.evaluate(expr);
        // Expecting valid non-error result
        expect(result, isNot(contains('Error:')), reason: '${e.title} failed: $result');
        print('SUCCESS: ${e.title} -> $result');
        evaluated++;
      } catch (err) {
        fail('Exception on ${e.title}: $err');
      }
    }
    print('Evaluated $evaluated examples successfully.');
  });
}
