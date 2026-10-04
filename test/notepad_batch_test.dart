import 'dart:async';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

NotepadDocument document(List<String> sources) {
  final doc = NotepadDocument.fresh(name: 'Batch');
  doc.lines
    ..clear()
    ..addAll(sources.map((source) => NotepadLine.fresh(source: source)));
  return doc;
}

Future<String> numeric(String expression) async =>
    NumericFallbackEvaluator.evalNumeric(expression)!.toInt().toString();

void main() {
  test('scope revisions observe edits, cache changes and structural mutations',
      () {
    final doc = document(['a = 1', 'b = 2']);
    final original = doc.lines.first;
    var revision = doc.scopeRevision;
    original.source = 'a = 3';
    expect(doc.scopeRevision, ++revision);
    original.source = 'a = 3';
    expect(doc.scopeRevision, revision);
    original.cachedResult = '3';
    expect(doc.scopeRevision, ++revision);
    original.cachedError = 'Error';
    expect(doc.scopeRevision, revision);
    doc.lines.insert(1, original);
    expect(doc.scopeRevision, ++revision);
    doc.lines.removeAt(0);
    expect(doc.scopeRevision, ++revision);
    original.source = 'a = 4'; // Remaining duplicate is still observed.
    expect(doc.scopeRevision, ++revision);
    doc.lines.remove(original);
    expect(doc.scopeRevision, ++revision);
    original.source = 'a = 5'; // Removed row cannot invalidate the document.
    expect(doc.scopeRevision, revision);
    final restored = NotepadDocument.fromJson(doc.toJson());
    expect(restored.toJson(), doc.toJson());
    expect(restored.scopeRevision, 0);
  });

  test('rows shared by documents invalidate both independent scopes', () {
    final first = document(['a = 1']);
    final second = document([])..lines.add(first.lines.first);
    final a = first.scopeRevision, b = second.scopeRevision;
    first.lines.first.cachedResult = '1';
    expect(first.scopeRevision, a + 1);
    expect(second.scopeRevision, b + 1);
  });

  test('two rapid edits recalculate both independent dependency branches',
      () async {
    final doc = document(['a = 1', 'b = 2', 'a + 10', 'b + 20', '99']);
    var calls = 0;
    final evaluator = NotepadEvaluator(dispatcher: (expression) {
      calls++;
      return numeric(expression);
    });
    await evaluator.evaluateAll(doc);
    calls = 0;
    doc.lines[0].source = 'a = 4';
    doc.lines[1].source = 'b = 5';
    await evaluator.evaluateChanged(doc, {0, 1});
    expect(calls, 4);
    expect(doc.lines.map((line) => line.cachedResult),
        ['4', '5', '14', '25', '99']);
  });

  test(
      'cancelled dispatch cannot commit its result or evidence or run the tail',
      () async {
    final doc = document(['1', '2']);
    final token = NotepadEvaluationCancellation();
    final reply = Completer<ComputedResult>();
    var calls = 0;
    final run = NotepadEvaluator(
      cancellation: token,
      dispatcher: numeric,
      detailedDispatcher: (_) {
        calls++;
        return reply.future;
      },
    ).evaluateAll(doc);
    final assertion =
        expectLater(run, throwsA(isA<NotepadEvaluationCancelled>()));
    token.cancel();
    reply.complete(const ComputedResult(
        '1',
        ResultEvidence(
            ResultAccuracy.exact, ComputationMethod.integerArithmetic)));
    await assertion;
    expect(calls, 1);
    expect(
        doc.lines.every(
            (line) => line.cachedResult == null && line.resultEvidence == null),
        isTrue);
  });

  test('source changed during a dispatch cannot receive an old answer',
      () async {
    final doc = document(['1']);
    final reply = Completer<String>();
    final run =
        NotepadEvaluator(dispatcher: (_) => reply.future).evaluateAll(doc);
    final assertion =
        expectLater(run, throwsA(isA<NotepadEvaluationCancelled>()));
    doc.lines.first.source = '2';
    reply.complete('1');
    await assertion;
    expect(doc.lines.first.cachedResult, isNull);
  });

  test(
      'progress counts selected rows, preserves completed rows on cancellation',
      () async {
    final doc = document(['a = 1', 'a + 2', '3']);
    final token = NotepadEvaluationCancellation();
    final progress = <(int, int)>[];
    await expectLater(
        NotepadEvaluator(
            dispatcher: numeric,
            cancellation: token,
            onProgress: (completed, total, _) {
              progress.add((completed, total));
              if (completed == 1) token.cancel();
            }).evaluateChanged(doc, {0}),
        throwsA(isA<NotepadEvaluationCancelled>()));
    expect(progress, [(0, 2), (1, 2)]);
    expect(doc.lines.first.cachedResult, '1');
    expect(doc.lines[1].cachedResult, isNull);
    await NotepadEvaluator(dispatcher: numeric).evaluateAll(doc);
    expect(doc.lines[1].cachedResult, '3');
  });

  test('incremental edits update Ans, aggregates and aggregate aliases',
      () async {
    final doc = document(['a = 1', 'Ans + 2', 'total', 'line3 + 5']);
    final evaluator = NotepadEvaluator(dispatcher: numeric);
    await evaluator.evaluateAll(doc);
    expect(doc.lines.map((line) => line.cachedResult), ['1', '3', '4', '9']);
    doc.lines.first.source = 'a = 4';
    await evaluator.evaluateFrom(doc, 0);
    expect(doc.lines.map((line) => line.cachedResult), ['4', '6', '10', '15']);
  });

  test('FlatZinc cancellation does not commit exported bindings', () async {
    final doc = document(['fzn: var 1..2: x :: output_var; solve satisfy;']);
    final token = NotepadEvaluationCancellation();
    final reply = Completer<NotepadFlatZincResult>();
    final run = NotepadEvaluator(
        dispatcher: numeric,
        cancellation: token,
        flatzincDispatcher: (_) => reply.future).evaluateAll(doc);
    final assertion =
        expectLater(run, throwsA(isA<NotepadEvaluationCancelled>()));
    token.cancel();
    reply.complete(const NotepadFlatZincResult(
        formatted: 'x = 1;', scalarBindings: {'x': '1'}));
    await assertion;
    expect(doc.lines.first.cachedResult, isNull);
    expect(doc.lines.first.cachedExports, isEmpty);
  });
}
