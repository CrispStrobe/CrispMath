import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/engine/real_calculus_proofs.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:crisp_math/engine/symbolic_expr.dart';
import 'package:crisp_math/engine/symbolic_taylor.dart';
import 'package:crisp_math/engine/symbolic_web.dart';
import 'package:crisp_math/services/engine_dispatch.dart';
import 'package:crisp_math/services/engine_op.dart';
import 'package:crisp_math/services/notepad_dispatcher.dart';
import 'package:flutter_test/flutter_test.dart';

NotepadDocument _document(List<String> sources) =>
    NotepadDocument.fresh(name: 'Computed formal variable controls')
      ..lines.clear()
      ..lines.addAll(sources.map((source) => NotepadLine.fresh(source: source)));

NotepadEvaluator _evaluator(List<EngineOp> calls) {
  final engine = CalculatorEngine();
  final dispatcher = NotepadDispatcher(
      engine: engine,
      yieldLocalWork: false,
      formatNumber: (value) => value,
      evaluateExpression: (source) async => engine.evaluate(source),
      evaluateDetailedExpression: (source) async =>
          runEngineOpDetailed(engine, EngineOp('evaluate', source)),
      runDetailedOperation: (op) async {
        calls.add(op);
        final computed = runEngineOpDetailed(engine, op);
        // Unit runners have no native bridge. For polynomial Taylor controls
        // use the production coefficient algorithm with its pure Dart
        // callbacks; the actual cusp-zero/error paths above remain engine
        // results. Hosted native/WASM fixtures cover the full engine route.
        if (op.kind == 'series' &&
            computed.value == 'Error: series requires native library') {
          final expression = RealCalculusProofs.absoluteLocalPolynomial(
                  op.arg1, op.arg2!, op.arg3!) ??
              op.arg1;
          final value = normalizePolynomialTaylorValue(
              symbolicTaylorSeries(expression, op.arg2!,
                  point: op.arg3!,
                  order: int.parse(op.arg4!),
                  simplify: (source) =>
                      SymbolicExpressionEvaluator.tryEvaluate(source) ?? 'Error',
                  differentiate: (source, variable) =>
                      SymbolicWeb.differentiate(source, variable) ?? 'Error',
                  substitute: engine.substitute),
              op.arg2!);
          return ComputedResult(value, const ResultEvidence(
              ResultAccuracy.symbolic, ComputationMethod.symbolicEvaluation));
        }
        return computed;
      });
  return NotepadEvaluator(
      dispatcher: dispatcher.evaluate,
      detailedDispatcher: dispatcher.evaluateDetailed);
}

void main() {
  test('actual constant cubic absolute Taylor output has no formal badge',
      () async {
    final doc = _document([
      'series(abs((x+1)^3),x,-1,3)',
      'taylor(abs((x+1)^3),x,-1,3)',
      'series(abs((x+1)^3),x,-1,4)',
      'series(abs(x),x,2,3)',
    ]);
    await _evaluator([]).evaluateAll(doc);
    for (final line in doc.lines.take(2)) {
      expect(line.cachedError, isNull);
      expect(line.cachedResult, '0');
      expect(line.cachedFreeVars, isEmpty);
      expect(line.resultEvidence, isNotNull);
    }
    // The next derivative fails at the cusp; constant metadata must not
    // conceal that domain error or affect a neighboring symbolic result.
    expect(doc.lines[2].cachedError, isNotNull);
    expect(doc.lines[2].cachedResult, isNull);
    expect(doc.lines[3].cachedError, isNull);
    expect(doc.lines[3].cachedResult, 'x');
    expect(doc.lines[3].cachedFreeVars, ['x']);
  });

  test('constant calculus outputs and remaining formal symbols differ',
      () async {
    final doc = _document([
      'diff(x,x)', 'diff(x^2,x)', 'integrate(x,x,0,1)',
      'series(2-(2+y),x,0,3)',
    ]);
    await _evaluator([]).evaluateAll(doc);
    expect(doc.lines[0].cachedError, isNull);
    expect(doc.lines[0].cachedResult, '1');
    expect(doc.lines[0].cachedFreeVars, isEmpty);
    expect(doc.lines[1].cachedError, isNull);
    expect(doc.lines[1].cachedFreeVars, ['x']);
    expect(doc.lines[2].cachedError, isNull);
    expect(doc.lines[2].cachedFreeVars, isEmpty);
    expect(doc.lines[3].cachedError, isNull);
    expect(doc.lines[3].cachedFreeVars, ['y']);
  });

  test('incremental formal availability refresh covers both Taylor aliases',
      () async {
    final calls = <EngineOp>[];
    final doc = _document([
      'x=9', 'series(abs((x+1)^3),x,-1,3)',
      'series(abs(x),x,2,3)', 'taylor(abs(x),x,2,3)',
    ]);
    final evaluator = _evaluator(calls);
    await evaluator.evaluateAll(doc);
    final results = doc.lines.skip(1).map((line) => line.cachedResult).toList();
    final evidence = doc.lines.skip(1).map((line) => line.resultEvidence).toList();
    final count = calls.length;
    for (final source in ['y=9', 'x=2', '# removed x', 'x=3']) {
      doc.lines[0].source = source;
      await evaluator.evaluateChanged(doc, {0});
      final available = source.startsWith('x=');
      expect(doc.lines[1].cachedFreeVars, isEmpty, reason: source);
      for (final line in doc.lines.skip(2)) {
        expect(line.cachedFreeVars, available ? isEmpty : ['x'], reason: source);
      }
      expect(doc.lines.skip(1).map((line) => line.cachedResult).toList(), results);
      expect(doc.lines.skip(1).map((line) => line.resultEvidence).toList(), evidence);
      expect(calls.length, count, reason: 'Formal availability is not a value dependency');
    }
  });

  test('reactive order edits change constant and symbolic output badges',
      () async {
    final calls = <EngineOp>[];
    final doc = _document(['n=1', 'a=2', 'series(a*x^2,x,0,n)']);
    final evaluator = _evaluator(calls);
    expect(buildDependencyGraph(doc).dependsOn[2], {0, 1});
    await evaluator.evaluateAll(doc);
    expect(doc.lines[2].cachedError, isNull);
    expect(doc.lines[2].cachedResult, '0');
    expect(doc.lines[2].cachedFreeVars, isEmpty);
    doc.lines[0].source = 'n=3';
    await evaluator.evaluateChanged(doc, {0});
    expect(doc.lines[2].cachedError, isNull);
    expect(doc.lines[2].cachedFreeVars, ['x']);
    final before = doc.lines[2].cachedResult;
    doc.lines[1].source = 'a=0';
    await evaluator.evaluateChanged(doc, {1});
    expect(doc.lines[2].cachedError, isNull);
    expect(doc.lines[2].cachedResult, '0');
    expect(doc.lines[2].cachedResult, isNot(before));
    expect(doc.lines[2].cachedFreeVars, isEmpty);
    expect(calls.where((op) => op.kind == 'series').length, 3);
  });

  test('result metadata does not discard ordinary input dependencies',
      () async {
    // Isolate metadata from CAS simplification: ordinary a and the outside x
    // remain source inputs even if a dispatcher computes a constant value.
    final doc = _document(['series(a*x,x,0,1)', 'series(x,x,0,1)+x']);
    final evaluator = NotepadEvaluator(dispatcher: (_) async => '0');
    await evaluator.evaluateAll(doc);
    expect(doc.lines[0].cachedFreeVars, ['a']);
    expect(doc.lines[1].cachedFreeVars, ['x']);
  });
}
