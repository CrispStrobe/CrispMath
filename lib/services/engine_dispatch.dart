import 'dart:convert';
import '../engine/rational_domain.dart';
import '../engine/result_evidence.dart';
import '../engine/calculator_engine.dart';
import 'engine_op.dart';

ComputedResult runEngineOpDetailed(CalculatorEngine engine, EngineOp op) {
  engine.lastResultEvidence = null;
  final value = runEngineOp(engine, op);
  return describeEngineResult(engine, op, value);
}

ComputedResult describeEngineResult(
    CalculatorEngine engine, EngineOp op, String value) {
  final method = op.kind == 'simplify'
      ? ComputationMethod.simplification
      : ComputationMethod.symbolicEvaluation;
  final unsupported = value.startsWith('Error') &&
      RegExp(r'requires native|not available|not implemented|no matching rule|unknown engine op',
              caseSensitive: false)
          .hasMatch(value);
  final evidence = unsupported
      ? ResultEvidence(ResultAccuracy.unsupported, method)
      : value.startsWith('Error')
          ? null
          : engine.lastResultEvidence ??
              ResultEvidence(
                  op.kind == 'simplify'
                      ? ResultAccuracy.symbolic
                      : ResultAccuracy.unknown,
                  method,
                  unchanged: op.kind == 'simplify' &&
                      value.replaceAll(RegExp(r'\s+'), '') ==
                          op.arg1.replaceAll(RegExp(r'\s+'), ''));
  final domain = op.kind == 'simplify' && !value.startsWith('Error')
      ? RationalDomain.inspect(op.arg1)
      : null;
  return ComputedResult(
      value,
      domain == null || evidence == null
          ? evidence
          : ResultEvidence(evidence.accuracy, evidence.method,
              unchanged: evidence.unchanged, sourceDomain: domain.description));
}

String runEngineOp(CalculatorEngine engine, EngineOp op) {
  if (op.kind.startsWith('details:')) {
    return jsonEncode(runEngineOpDetailed(engine,
            EngineOp(op.kind.substring(8), op.arg1, op.arg2, op.arg3, op.arg4))
        .toJson());
  }
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
