import '../engine/calculator_engine.dart';
import 'engine_op.dart';

String runEngineOp(CalculatorEngine engine, EngineOp op) {
  try {
    switch (op.kind) {
      case 'evaluate':
        return engine.evaluate(op.arg1);
      case 'expand':
        return engine.expand(op.arg1);
      case 'simplify':
        return engine.simplify(op.arg1);
      case 'factor':
        return engine.factor(op.arg1);
      case 'solve':
        return engine.solve(op.arg1, op.arg2!);
      case 'differentiate':
        return engine.differentiate(op.arg1, op.arg2!);
      case 'integrate':
        return engine.integrate(op.arg1, op.arg2!, op.arg3, op.arg4);
      case 'limit':
        return engine.limit(op.arg1, op.arg2!, op.arg3!);
      case 'series':
        return engine.series(op.arg1, op.arg2!,
            point: op.arg3 ?? '0', order: int.tryParse(op.arg4 ?? '6') ?? 6);
      case 'linsolve':
        // arg1: ';'-joined equations, arg2: ','-joined symbols.
        return engine.solveLinearSystem(
            op.arg1.split(';').map((e) => e.trim()).toList(),
            op.arg2!.split(',').map((e) => e.trim()).toList());
      case 'gcd':
        return engine.gcd(op.arg1, op.arg2!);
      case 'lcm':
        return engine.lcm(op.arg1, op.arg2!);
      case 'factorial':
        return engine.factorial(int.parse(op.arg1));
      case 'fibonacci':
        return engine.fibonacci(int.parse(op.arg1));
      default:
        return 'Error: unknown engine op ${op.kind}';
    }
  } catch (e) {
    return 'Error: $e';
  }
}
