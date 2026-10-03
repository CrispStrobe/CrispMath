import 'dart:convert';

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/linked_graph.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

NotepadDocument sample() {
  final doc = NotepadDocument.fresh(name: 'Model');
  doc.lines.clear();
  doc.lines.addAll([
    NotepadLine.fresh(source: 'a = 2')..cachedResult = '2',
    NotepadLine.fresh(source: 'f = a*sin(x)'),
  ]);
  return doc;
}

void main() {
  test('local function definitions map their lexical parameter to graph x',
      () async {
    final doc = NotepadDocument.fresh(name: 'Function graph')
      ..lines.clear()
      ..lines.addAll(['t=100', 'a=2', 'f(t)=t^2+a', 'f(x)+1']
          .map((s) => NotepadLine.fresh(source: s)));
    final evaluator = NotepadEvaluator(
        dispatcher: (s) async =>
            NumericFallbackEvaluator.evalNumeric(s)?.toString() ?? s);
    await evaluator.evaluateAll(doc);
    final definition = resolveLinkedGraph(doc, doc.lines[2].id);
    expect(definition.error, isNull);
    expect(definition.scope, {'a': '2.0'});
    expect(
        NumericFallbackEvaluator.evalNumeric(definition.expression!, {'x': 3}),
        11);
    final call = resolveLinkedGraph(doc, doc.lines[3].id);
    expect(call.error, isNull);
    expect(
        NumericFallbackEvaluator.evalNumeric(call.expression!, {'x': 3}), 12);
    doc.lines[1].source = 'a=5';
    await evaluator.evaluateChanged(doc, {1});
    expect(
        NumericFallbackEvaluator.evalNumeric(
            resolveLinkedGraph(doc, doc.lines[3].id).expression!, {'x': 3}),
        15);
  });
  test('multiple-parameter function calls allow a fixed argument for graphs',
      () async {
    final doc = NotepadDocument.fresh(name: 'Function graph')
      ..lines.clear()
      ..lines.addAll(
          ['g(t,y)=t*y', 'g(x,2)'].map((s) => NotepadLine.fresh(source: s)));
    await NotepadEvaluator(dispatcher: (s) async => s).evaluateAll(doc);
    expect(resolveLinkedGraph(doc, doc.lines.first.id).error,
        contains('one parameter'));
    final call = resolveLinkedGraph(doc, doc.lines.last.id);
    expect(call.error, isNull);
    expect(NumericFallbackEvaluator.evalNumeric(call.expression!, {'x': 3}), 6);
  });

  test(
      'variable navigation selects the effective assignment and ignores imports',
      () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.load(force: true);
    final doc = sample();
    final later = NotepadLine.fresh(source: 'a = 3')..cachedResult = '3';
    doc.lines.add(later);
    state.setNotepadDocument(doc);
    final slot = state.linkNotepadLine(doc.id, doc.lines[1].id);
    state.consumeRequestedTab();
    state.requestOpenNotepadSource(slot, variable: 'a');
    expect(state.consumeRequestedNotepadLine(), later.id);
    expect(state.consumeRequestedTab(), 1);
    state.requestOpenNotepadSource(slot, variable: 'missing');
    expect(state.consumeRequestedNotepadLine(), isNull);
    expect(state.consumeRequestedTab(), isNull);
    expect(linkedVariableLine(doc, 'line1'), isNull);
    doc.lines.remove(later);
    expect(linkedVariableLine(doc, 'a'), doc.lines.first.id);
  });
  test('scope binding leaves graph variable free and reports missing values',
      () {
    final doc = sample();
    final result = resolveLinkedGraph(doc, doc.lines.last.id);
    expect(result.scope, {'a': '2'});
    expect(NumericFallbackEvaluator.evalNumeric(result.expression!, {'x': 1}),
        closeTo(1.6829419696, 1e-9));
    doc.lines.first.cachedResult = null;
    doc.lines.first.cachedError = 'invalid';
    expect(
        resolveLinkedGraph(doc, doc.lines.last.id).error, contains('Define a'));
    expect(resolveLinkedGraph(doc, 'missing').error, contains('missing'));
  });
  test('only declared global imports enter a document graph scope', () {
    final doc = sample();
    doc.lines.removeAt(0);
    expect(
        resolveLinkedGraph(doc, doc.lines.last.id, globals: {'a': '4'}).error,
        isNotNull);
    doc.lines.insert(0, NotepadLine.fresh(source: 'use a'));
    expect(
        resolveLinkedGraph(doc, doc.lines.last.id, globals: {'a': '4'}).scope,
        {'a': '4'});
  });
  test(
      'links update, survive reload/export, recover deletion and detach on manual edits',
      () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.load(force: true);
    final doc = sample();
    state.setNotepadDocument(doc);
    final slot = state.linkNotepadLine(doc.id, doc.lines.last.id);
    expect(state.consumeRequestedTab(), 2);
    expect(state.graphFunctions[slot], '(2)*sin(x)');
    doc.lines.first.cachedResult = '3';
    state.setNotepadDocument(doc);
    expect(state.graphFunctions[slot], '(3)*sin(x)');
    await state.flushPersistence();
    final backup =
        jsonDecode(jsonEncode(state.exportToJson())) as Map<String, dynamic>;
    await state.load(force: true);
    expect(state.graphLinks[slot]!.lineId, doc.lines.last.id);
    state.deleteNotepadDocument(doc.id);
    expect(state.graphFunctions[slot], isEmpty);
    expect(state.linkedGraphResolution(slot).error, isNotNull);
    state.importFromJson(backup, merge: false);
    expect(state.graphFunctions[slot], '(3)*sin(x)');
    state.requestOpenNotepadSource(slot);
    expect(state.consumeRequestedTab(), 1);
    expect(state.consumeRequestedNotepadLine(), doc.lines.last.id);
    state.updateFunction(slot, 'x^2');
    expect(state.graphLinks.containsKey(slot), isFalse);
    await state.flushPersistence();
  });
}
