import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:crisp_math/services/engine_dispatch.dart';
import 'package:crisp_math/services/engine_op.dart';
import 'package:flutter_test/flutter_test.dart';

NotepadDocument worksheet(List<String> sources) {
  final doc = NotepadDocument.fresh(name: 'Numeric provenance');
  doc.lines.clear();
  doc.lines.addAll(sources.map((s) => NotepadLine.fresh(source: s)));
  return doc;
}

NotepadEvaluator evaluator(ResultAccuracy upstreamAccuracy,
    {Map<String, String> externalScope = const {}}) {
  final engine = CalculatorEngine();
  Future<ComputedResult> dispatch(String source) async {
    if (source.contains('pi')) {
      // A controlled upstream approximation reproduces the native worksheet
      // report. All downstream arithmetic uses the real exact app engine.
      return ComputedResult('28.274333882308138',
          ResultEvidence(upstreamAccuracy, ComputationMethod.symbolicEvaluation));
    }
    if (source.contains('/0')) {
      return const ComputedResult('Error: division by zero', null);
    }
    return runEngineOpDetailed(engine, EngineOp('evaluate', source));
  }

  return NotepadEvaluator(
      dispatcher: (s) async => (await dispatch(s)).value,
      detailedDispatcher: dispatch,
      externalScope: externalScope);
}

void main() {
  for (final accuracy in [ResultAccuracy.unknown, ResultAccuracy.approximate]) {
    test('${accuracy.name} coefficient survives arithmetic, aliases and functions',
        () async {
      final doc = worksheet([
        'r=3',
        'h=5',
        'area=pi*r^2',
        'volume=area*h',
        'line4*2',
        'f(t)=area*t',
        'f(h)',
        'g(u)=f(u)+1',
        'g(h)',
      ]);
      await evaluator(accuracy).evaluateAll(doc);
      expect(doc.lines.map((l) => l.cachedError), everyElement(isNull));
      for (final index in [3, 4, 5, 6, 7, 8]) {
        expect(doc.lines[index].resultEvidence?.accuracy, accuracy,
            reason: 'line ${index + 1}: ${doc.lines[index].cachedResult}');
      }
      for (final index in [3, 4, 6, 8]) {
        final cached = doc.lines[index].cachedResult!;
        expect(cached, isNot(contains('/')));
        expect(double.tryParse(cached), isNotNull);
      }
      expect(double.parse(doc.lines[3].cachedResult!),
          closeTo(141.3716694115407, 1e-12));
      expect(double.parse(doc.lines[8].cachedResult!),
          closeTo(142.3716694115407, 1e-12));
      final restored = NotepadDocument.fromJson(doc.toJson());
      expect(restored.lines[3].cachedResult, doc.lines[3].cachedResult);
      expect(restored.lines[3].resultEvidence?.accuracy, accuracy);
    });
  }

  test('explicit decimal literals and exact dependencies remain exact rationals',
      () async {
    final doc = worksheet(['a=0.1', 'b=0.2', 'a+b', 'f(t)=t^2', 'f(3)']);
    await evaluator(ResultAccuracy.unknown).evaluateAll(doc);
    expect(doc.lines[2].cachedResult, '3/10');
    expect(doc.lines[2].resultEvidence?.accuracy, ResultAccuracy.exact);
    expect(doc.lines[3].resultEvidence?.accuracy, ResultAccuracy.symbolic);
    expect(doc.lines[4].cachedResult, '9');
    expect(doc.lines[4].resultEvidence?.accuracy, ResultAccuracy.exact);
  });

  test('incremental replacement with an exact coefficient clears uncertainty',
      () async {
    final doc = worksheet(['r=3', 'h=5', 'area=pi*r^2', 'volume=area*h']);
    final runner = evaluator(ResultAccuracy.approximate);
    await runner.evaluateAll(doc);
    expect(doc.lines[3].resultEvidence?.accuracy, ResultAccuracy.approximate);
    doc.lines[2].source = 'area=2';
    await runner.evaluateFrom(doc, 2);
    expect(doc.lines[3].cachedResult, '10');
    expect(doc.lines[3].resultEvidence?.accuracy, ResultAccuracy.exact);
  });

  test('constant formal functions retain exact literal coefficient semantics',
      () async {
    final doc = worksheet(['f(t)=0.1', 'f(8)+0.2']);
    await evaluator(ResultAccuracy.unknown).evaluateAll(doc);
    expect(doc.lines[0].resultEvidence?.accuracy, ResultAccuracy.symbolic);
    expect(doc.lines[1].cachedResult, '3/10');
    expect(doc.lines[1].resultEvidence?.accuracy, ResultAccuracy.exact);
  });

  test('numerical imports without precision metadata cannot become exact',
      () async {
    final doc = worksheet(['a*2']);
    await evaluator(ResultAccuracy.unknown,
            externalScope: {'a': '3.141592653589793'})
        .evaluateAll(doc);
    expect(doc.lines.single.resultEvidence?.accuracy, ResultAccuracy.unknown);
    expect(double.parse(doc.lines.single.cachedResult!),
        closeTo(6.283185307179586, 1e-15));
  });

  test('error rows discard inherited precision and numerical cached value',
      () async {
    final doc = worksheet(['area=pi*9', 'area/0']);
    await evaluator(ResultAccuracy.approximate).evaluateAll(doc);
    expect(doc.lines[1].cachedResult, isNull);
    expect(doc.lines[1].cachedError, contains('division by zero'));
    expect(doc.lines[1].resultEvidence, isNull);
  });
}
