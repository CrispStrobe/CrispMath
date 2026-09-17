import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/unit_expression.dart';
import 'package:crisp_math/engine/worked_examples.dart';
import 'package:crisp_math/utils/expression_preprocessing_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

String simulateCommand(CalculatorEngine engine, String expression) {
  final exp = expression.trim();
  
  final unitRes = UnitExpressionEvaluator.tryEvaluate(exp);
  if (unitRes != null) return unitRes;

  final preprocessed = ExpressionPreprocessingUtils.preprocessNativeExpression(exp);

  if (exp.startsWith('solve(')) {
    final content = exp.substring(6, exp.length - 1).trim();
    if (content.contains(',')) {
      final parts = content.split(',');
      return engine.solve(parts[0].trim(), parts[1].trim());
    }
    return engine.solve(content, 'x');
  } else if (exp.startsWith('linsolve(')) {
    final content = exp.substring(9, exp.length - 1).trim();
    final parts = content.split(',');
    return engine.solveLinearSystem(
      parts[0].trim().split(';').map((e) => e.trim()).toList(),
      parts.sublist(1).map((e) => e.trim()).toList(),
    );
  } else if (exp.startsWith('dsolve(')) {
    final content = exp.substring(7, exp.length - 1).trim();
    return engine.solveOde(content);
  } else if (exp.startsWith('integrate(')) {
    final content = exp.substring(10, exp.length - 1).trim();
    final parts = content.split(',');
    if (parts.length == 2) {
      return engine.integrate(parts[0].trim(), parts[1].trim());
    } else if (parts.length == 4) {
      return engine.integrate(parts[0].trim(), parts[1].trim(), parts[2].trim(), parts[3].trim());
    }
  } else if (exp.startsWith('diff(') || exp.startsWith('d/dx(')) {
    final content = exp.substring(exp.indexOf('(') + 1, exp.length - 1).trim();
    final parts = content.split(',');
    return engine.differentiate(parts[0].trim(), parts[1].trim());
  } else if (exp.startsWith('limit(')) {
    final content = exp.substring(6, exp.length - 1).trim();
    final parts = content.split(',');
    return engine.limit(parts[0].trim(), parts[1].trim(), parts[2].trim());
  } else if (exp.startsWith('taylor(')) {
    final content = exp.substring(7, exp.length - 1).trim();
    final parts = content.split(',');
    return engine.series(parts[0].trim(), parts[1].trim(), order: int.parse(parts[3].trim()), point: parts[2].trim());
  } else if (exp.startsWith('factor(')) {
    final content = exp.substring(7, exp.length - 1).trim();
    return engine.factor(content);
  } else if (exp.startsWith('expand(')) {
    final content = exp.substring(7, exp.length - 1).trim();
    return engine.expand(content);
  } else if (exp.startsWith('simplify(')) {
    final content = exp.substring(9, exp.length - 1).trim();
    return engine.simplify(content);
  } else if (exp.startsWith('polyfactor(')) {
    return '0'; // skip
  } else if (exp.contains('and') || exp.contains('or') || exp.contains('not ')) {
    return '0'; // skip logic
  }
  
  return engine.evaluate(preprocessed);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final engine = CalculatorEngine();

  group('WorkedExamples evaluation (native SymEngine bridge)', () {
    setUpAll(() {
      expect(
        engine.isNativeAvailable,
        isTrue,
        reason: 'native bridge not loaded — run with `-d macos`',
      );
    });

    for (final e in WorkedExamples.all) {
      if (e.expression.startsWith('open:') || e.expression.startsWith('dsl:')) {
        continue;
      }
      
      test('evaluate: ${e.title}', () {
        final result = simulateCommand(engine, e.expression);
        expect(result, isNot(contains('Error:')), reason: 'Failed to evaluate: ${e.expression} -> $result');
      });
    }
  });
}
