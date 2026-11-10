import 'dart:convert';

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/linked_graph.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/engine/notepad_plot.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:crisp_math/engine/symbolic_expr.dart';
import 'package:crisp_math/services/workspace_backup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

NotepadDocument worksheet(List<String> sources, {String name = 'Existing'}) =>
    NotepadDocument.fresh(name: name)
      ..lines.clear()
      ..lines.addAll(sources.map((source) => NotepadLine.fresh(source: source)));

NotepadEvaluator get evaluator => NotepadEvaluator(
    dispatcher: (source) async =>
        NumericFallbackEvaluator.tryEvaluate(source) ??
        SymbolicExpressionEvaluator.tryEvaluate(source) ??
        'Error: cannot evaluate $source');

double? valueAt(AppState state, int slot, double x) =>
    NumericFallbackEvaluator.evalNumeric(state.graphFunctions[slot], {'x': x});

Map<String, dynamic> snapshot(AppState state) {
  final copy = jsonDecode(jsonEncode(state.exportToJson()))
      as Map<String, dynamic>;
  copy.remove('exportedAt');
  return copy;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppState state;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    state = AppState.forTesting();
    await state.load();
    state.clearAllFunctions();
  });

  tearDown(() async {
    await state.flushPersistence();
    state.dispose();
  });

  test('graph becomes an isolated linked worksheet using the current sliders',
      () async {
    final existing = worksheet(['a=99', 'a+1']);
    await evaluator.evaluateAll(existing);
    state.setNotepadDocument(existing);
    state.setCurrentNotepadDoc(existing.id);
    final originalDocument = jsonEncode(existing.toJson());
    final originalCount = state.notepadDocuments.length;
    for (var slot = 0; slot < state.graphFunctions.length; slot++) {
      state.updateFunction(slot, 'x+$slot');
    }
    const slot = 3;
    state.updateFunction(slot, 'a*x+b');
    state.setParameter(slot, 'a', 2.5);
    state.setParameter(slot, 'b', -1);
    state.setParameter(slot, 'obsolete', 123);
    state.setVariable('a', '999');
    final originalFunctions = List<String>.of(state.graphFunctions);

    final created = state.createWorksheetFromGraph(slot,
        name: 'Linear model', xMin: -4, xMax: 7);

    expect(created.id, isNot(existing.id));
    expect(created.name, 'Linear model');
    expect(state.notepadDocuments.length, originalCount + 1);
    expect(jsonEncode(existing.toJson()), originalDocument);
    expect(created.lines.map((line) => line.source).take(2),
        ['a = 2.5', 'b = -1.0']);
    expect(created.lines.length, 3);
    expect(state.graphLinks[slot]!.documentId, created.id);
    expect(state.graphLinks[slot]!.lineId, created.lines.last.id);
    expect(state.graphLinks.length, 1);
    expect(state.functionParameters, isNot(contains(slot)));
    expect(state.graphFunctions.where((source) => source.isNotEmpty).length,
        originalFunctions.length);
    for (var other = 0; other < originalFunctions.length; other++) {
      if (other != slot) {
        expect(state.graphFunctions[other], originalFunctions[other]);
      }
    }
    expect(valueAt(state, slot, 2), 4);
    expect(valueAt(state, slot, -2), -6);
    final plot = PlotSpec.tryParse(created.lines.last.cachedResult)!;
    expect(plot.lo, -4);
    expect(plot.hi, 7);
    expect(state.currentNotepadDocId, created.id);
    expect(state.consumeRequestedTab(), 1);
    expect(state.consumeRequestedNotepadLine(), created.lines.last.id);
    expect(state.consumeRequestedGraph(), isNull);
  });

  test('editing the captured parameter updates the same graph slot', () async {
    const slot = 5;
    state.updateFunction(slot, 'a*x^2');
    state.setParameter(slot, 'a', 2);
    final created = state.createWorksheetFromGraph(slot,
        name: 'Quadratic model', xMin: -2, xMax: 3);
    expect(valueAt(state, slot, 3), 18);
    final originalSource = state.graphLinks[slot]!.lineId;
    created.lines.first.source = 'a=4';
    await evaluator.evaluateFrom(created, 0);
    state.setNotepadDocument(created);
    expect(valueAt(state, slot, 3), 36);
    expect(state.graphLinks[slot]!.lineId, originalSource);
    expect(state.graphLinks.length, 1);
    expect(state.graphFunctions.where((s) => s.isNotEmpty).length, 1);
    expect(PlotSpec.tryParse(created.lines.last.cachedResult)!.hi, 3);
  });

  test('conversion uses the graph slider default when no slider was mounted',
      () {
    state.updateFunction(2, 'a*x+2');
    expect(state.functionParameters, isNot(contains(2)));
    final created = state.createWorksheetFromGraph(2,
        name: 'Default parameter', xMin: -1, xMax: 1);
    expect(buildNotepadScope(created)['a'], '1.0');
    expect(valueAt(state, 2, 3), 5);
    expect(state.functionParameters, isNot(contains(2)));
  });

  test('existing linked graphs return to their source without another copy',
      () async {
    final source = worksheet(['a=2', 'plot(a*t,t,-3,5)']);
    await evaluator.evaluateAll(source);
    state.setNotepadDocument(source);
    final slot = state.linkNotepadLine(source.id, source.lines.last.id,
        openGraph: false);
    final before = snapshot(state);
    final count = state.notepadDocuments.length;
    final result = state.createWorksheetFromGraph(slot,
        name: 'Do not duplicate', xMin: -10, xMax: 10);
    expect(identical(result, source), isTrue);
    expect(state.notepadDocuments.length, count);
    expect(state.graphFunctions, before['functions']);
    expect(source.name, 'Existing');
    expect(state.linkedGraphResolution(slot).plot!.lo, -3);
    expect(state.linkedGraphResolution(slot).plot!.hi, 5);
    expect(state.consumeRequestedTab(), 1);
    expect(state.consumeRequestedNotepadLine(), source.lines.last.id);
    expect(state.consumeRequestedGraph(), isNull);
  });

  test('opening a lexical plot queues its resolved interval exactly once',
      () async {
    final source = worksheet(['radius=4', 'plot(t^2,t,-radius,radius/2)']);
    await evaluator.evaluateAll(source);
    state.setNotepadDocument(source);
    final slot = state.linkNotepadLine(source.id, source.lines.last.id,
        openGraph: false);
    expect(state.consumeRequestedGraph(), isNull);
    expect(state.consumeRequestedTab(), isNull);
    expect(valueAt(state, slot, 3), 9);
    expect(state.linkNotepadLine(source.id, source.lines.last.id), slot);
    final request = state.consumeRequestedGraph()!;
    expect(request.slot, slot);
    expect(request.plot!.variable, 't');
    expect(request.plot!.lo, -4);
    expect(request.plot!.hi, 2);
    expect(request.plot!.graphExpression, state.graphFunctions[slot]);
    expect(state.consumeRequestedGraph(), isNull);
    expect(state.consumeRequestedTab(), 2);
    expect(state.consumeRequestedTab(), isNull);
    expect(state.graphLinks.length, 1);
  });

  test('ordinary expression navigation preserves the graph viewport', () async {
    final source = worksheet(['x^2']);
    await evaluator.evaluateAll(source);
    state.setNotepadDocument(source);
    final slot = state.linkNotepadLine(source.id, source.lines.single.id);
    final request = state.consumeRequestedGraph()!;
    expect(request.slot, slot);
    expect(request.plot, isNull);
    expect(state.consumeRequestedGraph(), isNull);
  });

  test('invalid conversion leaves documents, sliders and graph ownership intact',
      () {
    final invalidCases = <({String expression, double lo, double hi})>[
      (expression: '', lo: -1, hi: 1),
      (expression: 'a*x+', lo: -1, hi: 1),
      (expression: 'sinn(x)', lo: -1, hi: 1),
      (expression: 'x', lo: 2, hi: -2),
      (expression: 'x', lo: double.nan, hi: 2),
      (expression: 'x', lo: -2, hi: double.infinity),
    ];
    for (final invalid in invalidCases) {
      state.updateFunction(4, invalid.expression);
      final before = snapshot(state);
      expect(
          () => state.createWorksheetFromGraph(4,
              name: 'Rejected', xMin: invalid.lo, xMax: invalid.hi),
          throwsA(anyOf(isA<StateError>(), isA<ArgumentError>())),
          reason: invalid.expression);
      expect(snapshot(state), before, reason: invalid.expression);
      expect(state.consumeRequestedGraph(), isNull);
      expect(state.consumeRequestedTab(), isNull);
      expect(state.consumeRequestedNotepadLine(), isNull);
    }
    for (final slot in [-1, state.graphFunctions.length]) {
      final before = snapshot(state);
      expect(
          () => state.createWorksheetFromGraph(slot,
              name: 'Rejected', xMin: -1, xMax: 1),
          throwsStateError);
      expect(snapshot(state), before);
    }
  });

  test('nonfinite captured parameters fail before changing source ownership',
      () {
    state.updateFunction(1, 'a*x');
    // Simulate malformed in-memory slider state without serializing Infinity
    // through SharedPreferences before the conversion's validation runs.
    state.functionParameters[1] = {'a': double.infinity};
    final ids = state.notepadDocuments.keys.toSet();
    final current = state.currentNotepadDocId;
    final functions = List<String>.of(state.graphFunctions);
    expect(
        () => state.createWorksheetFromGraph(1,
            name: 'Rejected', xMin: -1, xMax: 1),
        throwsStateError);
    expect(state.notepadDocuments.keys.toSet(), ids);
    expect(state.currentNotepadDocId, current);
    expect(state.graphLinks, isEmpty);
    expect(state.graphFunctions, functions);
    expect(state.functionParameters[1]!['a'], double.infinity);
    expect(state.consumeRequestedTab(), isNull);
  });

  test('source ownership and interval survive reload and a portable backup',
      () async {
    state.updateFunction(6, 'a*x');
    state.setParameter(6, 'a', 3);
    final original = state.createWorksheetFromGraph(6,
        name: 'Saved graph', xMin: -7, xMax: 2);
    final documentId = original.id;
    final lineId = original.lines.last.id;
    final rawExport = snapshot(state);
    final backup = WorkspaceBackup.decode(WorkspaceBackup.encode(state));
    await state.flushPersistence();
    await state.load(force: true);
    expect(state.graphLinks[6]!.documentId, documentId);
    expect(state.graphLinks[6]!.lineId, lineId);
    expect(state.currentNotepadDocId, documentId);
    expect(state.consumeRequestedGraph(), isNull);
    expect(state.consumeRequestedTab(), isNull);
    var restored = state.notepadDocuments[documentId]!;
    await evaluator.evaluateAll(restored);
    state.setNotepadDocument(restored);
    expect(valueAt(state, 6, 4), 12);
    expect(state.linkedGraphResolution(6).plot!.lo, -7);
    expect(state.linkedGraphResolution(6).plot!.hi, 2);

    state.deleteNotepadDocument(documentId);
    expect(state.graphFunctions[6], isEmpty);
    state.importFromJson(rawExport, merge: false);
    restored = state.notepadDocuments[documentId]!;
    await evaluator.evaluateAll(restored);
    state.setNotepadDocument(restored);
    expect(valueAt(state, 6, 4), 12);

    state.deleteNotepadDocument(documentId);
    state.importFromJson(backup.state, merge: false);
    restored = state.notepadDocuments[documentId]!;
    expect(restored.lines.every((line) => line.cachedResult == null), isTrue);
    await evaluator.evaluateAll(restored);
    state.setNotepadDocument(restored);
    expect(valueAt(state, 6, 4), 12);
    expect(state.graphLinks[6]!.lineId, lineId);
    expect(state.linkedGraphResolution(6).plot!.lo, -7);
    expect(state.linkedGraphResolution(6).plot!.hi, 2);
    expect(state.linkNotepadLine(documentId, lineId, openGraph: false), 6);
    expect(state.consumeRequestedGraph(), isNull);
    expect(state.consumeRequestedTab(), isNull);
  });

  test('a missing linked source is not replaced with a stale graph copy', () {
    state.updateFunction(7, '2*x');
    state.graphLinks[7] = const LinkedGraphSource('missing-document', 'missing-line');
    final before = snapshot(state);
    expect(
        () => state.createWorksheetFromGraph(7,
            name: 'Stale copy', xMin: -1, xMax: 1),
        throwsStateError);
    expect(snapshot(state), before);
    expect(state.consumeRequestedNotepadLine(), isNull);
    expect(state.consumeRequestedTab(), isNull);
  });

  test('an existing errored source opens for repair without copying its cache',
      () async {
    final source = worksheet(['a=2', 'plot(a*x)']);
    await evaluator.evaluateAll(source);
    state.setNotepadDocument(source);
    final slot = state.linkNotepadLine(source.id, source.lines.last.id,
        openGraph: false);
    source.lines.first.source = 'a=1/0';
    await evaluator.evaluateFrom(source, 0);
    state.setNotepadDocument(source);
    expect(state.graphFunctions[slot], isEmpty);
    final count = state.notepadDocuments.length;
    expect(
        state.createWorksheetFromGraph(slot,
            name: 'Repair source', xMin: -1, xMax: 1),
        same(source));
    expect(state.notepadDocuments.length, count);
    expect(source.lines.last.cachedError, isNotNull);
    expect(state.consumeRequestedNotepadLine(), source.lines.last.id);
    expect(state.consumeRequestedTab(), 1);
  });
}
