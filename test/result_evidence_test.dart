import 'dart:convert';
import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:crisp_math/services/engine_dispatch.dart';
import 'package:crisp_math/services/engine_op.dart';
import 'package:crisp_math/services/notepad_dispatcher.dart';
import 'package:crisp_math/widgets/result_evidence_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class NumericalEngine extends CalculatorEngine {
  @override
  String integrate(String expression, String variable,
      [String? lower, String? upper]) {
    lastResultEvidence = const ResultEvidence(
        ResultAccuracy.approximate, ComputationMethod.simpsonIntegration);
    return '1';
  }
}

void main() {
  test(
      'simplification fallback identifies expansion rather than full simplification',
      () {
    final engine = CalculatorEngine();
    if (engine.isNativeAvailable) return;
    final result =
        runEngineOpDetailed(engine, const EngineOp('simplify', '(x+1)^2'));
    expect(result.evidence!.method, ComputationMethod.polynomialExpansion);
    expect(result.evidence!.accuracy, ResultAccuracy.symbolic);
  });

  test('exact polynomial integration records its actual method', () {
    final result = runEngineOpDetailed(
        CalculatorEngine(), const EngineOp('integrate', 'x^2', 'x', '0', '1'));
    expect(result.value, '1/3');
    expect(result.evidence!.accuracy, ResultAccuracy.exact);
    expect(result.evidence!.method, ComputationMethod.polynomialIntegration);
  });
  test(
      'integer-looking numerical result remains approximate across worker encoding',
      () {
    final encoded = runEngineOp(NumericalEngine(),
        const EngineOp('details:integrate', 'exp(x^2)', 'x', '0', '1'));
    final result = ComputedResult.fromJson(jsonDecode(encoded));
    expect(result.value, '1');
    expect(result.evidence!.accuracy, ResultAccuracy.approximate);
    expect(result.evidence!.method, ComputationMethod.simpsonIntegration);
  });
  test(
      'evidence resets between engine operations and unsupported results identify the gap',
      () {
    final engine = NumericalEngine();
    runEngineOpDetailed(engine, const EngineOp('integrate', 'x', 'x'));
    final result = runEngineOpDetailed(engine, const EngineOp('missing', 'x'));
    expect(result.evidence!.accuracy, ResultAccuracy.unsupported);
    expect(result.evidence!.method, ComputationMethod.symbolicEvaluation);
    expect(engine.lastResultEvidence, isNull);
  });
  test(
      'history and document caches preserve evidence and accept legacy/unknown metadata',
      () {
    const evidence = ResultEvidence(
        ResultAccuracy.approximate, ComputationMethod.simpsonIntegration);
    final entry = CalculationEntry(
        expression: 'integrate(x,x)', result: '1', resultEvidence: evidence);
    expect(CalculationEntry.fromJson(entry.toJson()).resultEvidence!.accuracy,
        ResultAccuracy.approximate);
    final line = NotepadLine.fresh(source: 'x')..resultEvidence = evidence;
    expect(NotepadLine.fromJson(line.toJson()).resultEvidence!.method,
        ComputationMethod.simpsonIntegration);
    expect(CalculationEntry.fromJson({'e': '1+1', 'r': '2'}).resultEvidence,
        isNull);
    expect(ResultEvidence.fromJson({'accuracy': 'future', 'method': 'future'}),
        isNull);
  });
  test(
      'notepad metadata is bound to each result and cleared for an edited non-code row',
      () async {
    final doc = NotepadDocument.fresh(name: 'Evidence');
    doc.lines.clear();
    doc.lines.addAll(
        [NotepadLine.fresh(source: '1+1'), NotepadLine.fresh(source: '2+3')]);
    final dispatcher = NotepadDispatcher(formatNumber: (v) => v);
    final evaluator = NotepadEvaluator(
        dispatcher: dispatcher.evaluate,
        detailedDispatcher: dispatcher.evaluateDetailed);
    await evaluator.evaluateAll(doc);
    expect(doc.lines.map((l) => l.resultEvidence!.accuracy),
        everyElement(ResultAccuracy.exact));
    doc.lines.first.source = '# comment';
    await evaluator.evaluateFrom(doc, 0);
    expect(doc.lines.first.resultEvidence, isNull);
  });
  testWidgets('numerical badge opens method details without claiming exactness',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: ResultEvidenceBadge(
                evidence: ResultEvidence(ResultAccuracy.approximate,
                    ComputationMethod.simpsonIntegration)))));
    expect(find.textContaining('Approximate'), findsOneWidget);
    expect(find.text('Exact'), findsNothing);
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(find.text('Result details'), findsOneWidget);
    expect(find.textContaining('Simpson'), findsNWidgets(2));
  });
}
