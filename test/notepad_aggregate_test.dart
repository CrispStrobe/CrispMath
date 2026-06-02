// test/notepad_aggregate_test.dart
//
// Tests for notepad aggregate keywords: total, subtotal, average, count.

import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_calc/engine/notepad.dart';
import 'package:crisp_calc/engine/notepad_evaluator.dart';

void main() {
  group('classifyNotepadLine — aggregate keywords', () {
    ParsedNotepadLine classify(String src) =>
        classifyNotepadLine(src, lineIndex: 5, firstCodeLineIndex: 0);

    test('total is classified as aggregate', () {
      final p = classify('total');
      expect(p.kind, NotepadLineKind.aggregate);
      expect(p.name, 'total');
    });

    test('subtotal is classified as aggregate', () {
      final p = classify('subtotal');
      expect(p.kind, NotepadLineKind.aggregate);
      expect(p.name, 'subtotal');
    });

    test('average is classified as aggregate', () {
      final p = classify('average');
      expect(p.kind, NotepadLineKind.aggregate);
      expect(p.name, 'average');
    });

    test('count is classified as aggregate', () {
      final p = classify('count');
      expect(p.kind, NotepadLineKind.aggregate);
      expect(p.name, 'count');
    });

    test('Total (capitalized) is classified as aggregate', () {
      final p = classify('Total');
      expect(p.kind, NotepadLineKind.aggregate);
      expect(p.name, 'total');
    });

    test('AVERAGE (all caps) is classified as aggregate', () {
      final p = classify('AVERAGE');
      expect(p.kind, NotepadLineKind.aggregate);
      expect(p.name, 'average');
    });

    test('total with comment is classified as aggregate', () {
      final p = classify('total // final sum');
      // After comment stripping, the body is "total" — should match.
      expect(p.kind, NotepadLineKind.aggregate);
    });

    test('total + 5 is NOT an aggregate (expression)', () {
      final p = classify('total + 5');
      expect(p.kind, NotepadLineKind.expression);
    });

    test('my_total is NOT an aggregate (expression/assignment)', () {
      final p = classify('my_total');
      expect(p.kind, NotepadLineKind.expression);
    });
  });

  group('NotepadEvaluator — aggregate evaluation', () {
    // Build a doc and pre-populate cachedResult on expression lines,
    // then run the evaluator on the aggregate line.

    Future<String> fakeDispatcher(String s) async => s;

    test('total sums all preceding numeric results', () async {
      final doc = NotepadDocument(
        id: 'test',
        name: 'Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lines: [
          NotepadLine.fresh(source: '10')..cachedResult = '10',
          NotepadLine.fresh(source: '20')..cachedResult = '20',
          NotepadLine.fresh(source: '30')..cachedResult = '30',
          NotepadLine.fresh(source: 'total'),
        ],
      );

      final eval = NotepadEvaluator(dispatcher: fakeDispatcher);
      await eval.evaluateAll(doc);

      expect(doc.lines[3].cachedResult, '60');
      expect(doc.lines[3].cachedError, isNull);
    });

    test('subtotal sums from previous aggregate', () async {
      final doc = NotepadDocument(
        id: 'test',
        name: 'Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lines: [
          NotepadLine.fresh(source: '10')..cachedResult = '10',
          NotepadLine.fresh(source: '20')..cachedResult = '20',
          NotepadLine.fresh(source: 'subtotal'),
          NotepadLine.fresh(source: '5')..cachedResult = '5',
          NotepadLine.fresh(source: '15')..cachedResult = '15',
          NotepadLine.fresh(source: 'subtotal'),
        ],
      );

      final eval = NotepadEvaluator(dispatcher: fakeDispatcher);
      await eval.evaluateAll(doc);

      // First subtotal: 10 + 20 = 30
      expect(doc.lines[2].cachedResult, '30');
      // Second subtotal: 5 + 15 = 20 (only from line 3 onward)
      expect(doc.lines[5].cachedResult, '20');
    });

    test('total sums from top, ignoring intervening aggregates', () async {
      final doc = NotepadDocument(
        id: 'test',
        name: 'Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lines: [
          NotepadLine.fresh(source: '10')..cachedResult = '10',
          NotepadLine.fresh(source: 'subtotal'),
          NotepadLine.fresh(source: '5')..cachedResult = '5',
          NotepadLine.fresh(source: 'total'),
        ],
      );

      final eval = NotepadEvaluator(dispatcher: fakeDispatcher);
      await eval.evaluateAll(doc);

      // subtotal at line 1: 10
      expect(doc.lines[1].cachedResult, '10');
      // total at line 3: 10 + 5 = 15 (scans from top, includes
      // line 0 and line 2; skips line 1 which is an aggregate)
      expect(doc.lines[3].cachedResult, '15');
    });

    test('average computes mean', () async {
      final doc = NotepadDocument(
        id: 'test',
        name: 'Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lines: [
          NotepadLine.fresh(source: '10')..cachedResult = '10',
          NotepadLine.fresh(source: '20')..cachedResult = '20',
          NotepadLine.fresh(source: '30')..cachedResult = '30',
          NotepadLine.fresh(source: 'average'),
        ],
      );

      final eval = NotepadEvaluator(dispatcher: fakeDispatcher);
      await eval.evaluateAll(doc);

      expect(doc.lines[3].cachedResult, '20');
    });

    test('count counts numeric results', () async {
      final doc = NotepadDocument(
        id: 'test',
        name: 'Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lines: [
          NotepadLine.fresh(source: '10')..cachedResult = '10',
          NotepadLine.fresh(source: '// comment'),
          NotepadLine.fresh(source: '20')..cachedResult = '20',
          NotepadLine.fresh(source: 'hello')..cachedResult = 'hello',
          NotepadLine.fresh(source: 'count'),
        ],
      );

      final eval = NotepadEvaluator(dispatcher: fakeDispatcher);
      await eval.evaluateAll(doc);

      // Only lines with parseable numeric results: 10 and 20
      expect(doc.lines[4].cachedResult, '2');
    });

    test('average with no numeric values gives error', () async {
      final doc = NotepadDocument(
        id: 'test',
        name: 'Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lines: [
          NotepadLine.fresh(source: '// only comments'),
          NotepadLine.fresh(source: 'average'),
        ],
      );

      final eval = NotepadEvaluator(dispatcher: fakeDispatcher);
      await eval.evaluateAll(doc);

      expect(doc.lines[1].cachedError, contains('no numeric values'));
    });
  });
}
