// test/notepad_undo_test.dart
//
// Additional unit tests for notepad_undo.dart covering:
//   - Ring buffer eviction at maxEntries (oldest dropped, not newest)
//   - Reorder undo/redo correctness (index swapping)
//   - clear() method

import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_calc/engine/notepad.dart';
import 'package:crisp_calc/engine/notepad_undo.dart';

void main() {
  // =========================================================================
  // Ring buffer eviction
  // =========================================================================

  group('UndoHistory — ring buffer eviction at maxEntries', () {
    test('oldest entry is evicted, not newest', () {
      final h = UndoHistory();
      // Record maxEntries + 10 operations, each with a distinct index
      // so we can identify them.
      for (var i = 0; i < UndoHistory.maxEntries + 10; i++) {
        h.record(UndoOp(
          kind: UndoOpKind.edit,
          index: i,
          lineId: 'line_$i',
          previousValue: 'val_$i',
        ));
      }

      expect(h.undoCount, UndoHistory.maxEntries);

      // The most recent op (index 59) should be on top of the stack.
      final newest = h.undo();
      expect(newest, isNotNull);
      expect(newest!.index, UndoHistory.maxEntries + 10 - 1); // 59
      expect(newest.lineId, 'line_59');

      // The oldest surviving op should be index 10 (entries 0..9 evicted).
      // Undo remaining 49 entries to reach the bottom.
      UndoOp? bottom;
      for (var i = 0; i < UndoHistory.maxEntries - 1; i++) {
        bottom = h.undo();
        expect(bottom, isNotNull);
      }
      // bottom is now the oldest surviving entry.
      expect(bottom!.index, 10);
      expect(bottom.lineId, 'line_10');

      // Stack should now be empty.
      expect(h.canUndo, false);
      expect(h.undo(), isNull);
    });

    test('eviction does not corrupt redo stack', () {
      final h = UndoHistory();
      // Fill to capacity.
      for (var i = 0; i < UndoHistory.maxEntries; i++) {
        h.record(UndoOp(kind: UndoOpKind.edit, index: i));
      }
      // Undo one so there's a redo entry.
      h.undo();
      expect(h.canRedo, true);
      expect(h.redoCount, 1);

      // Recording a new op clears redo AND evicts oldest.
      h.record(
          const UndoOp(kind: UndoOpKind.insert, index: 999, lineId: 'new'));
      expect(h.canRedo, false);
      expect(h.undoCount, UndoHistory.maxEntries);
    });

    test('exactly maxEntries records keeps all', () {
      final h = UndoHistory();
      for (var i = 0; i < UndoHistory.maxEntries; i++) {
        h.record(UndoOp(kind: UndoOpKind.edit, index: i));
      }
      expect(h.undoCount, UndoHistory.maxEntries);

      // Undo all — first one out should be the last recorded.
      final first = h.undo();
      expect(first!.index, UndoHistory.maxEntries - 1);
    });
  });

  // =========================================================================
  // Reorder undo/redo correctness
  // =========================================================================

  group('applyUndo — reorder', () {
    NotepadDocument makeDoc(List<String> ids) {
      final doc = NotepadDocument.fresh(name: 'T');
      doc.lines.clear();
      for (final id in ids) {
        doc.lines.add(NotepadLine(id: id, source: id));
      }
      return doc;
    }

    test('undo reorder moves line back from newIndex to index', () {
      // Original order: [a, b, c]. User moved line from index 0 to index 2.
      // After the move the doc is [b, c, a].
      final doc = makeDoc(['b', 'c', 'a']);

      const op = UndoOp(
        kind: UndoOpKind.reorder,
        index: 0,
        newIndex: 2,
      );

      final ok = applyUndo(doc, op);
      expect(ok, true);
      // After undo the line at newIndex (2) should move back to index (0).
      expect(doc.lines.map((l) => l.id).toList(), ['a', 'b', 'c']);
    });

    test('undo reorder with adjacent swap', () {
      // Original: [a, b, c]. Moved index 1 -> index 2. Now [a, c, b].
      final doc = makeDoc(['a', 'c', 'b']);

      const op = UndoOp(
        kind: UndoOpKind.reorder,
        index: 1,
        newIndex: 2,
      );

      final ok = applyUndo(doc, op);
      expect(ok, true);
      expect(doc.lines.map((l) => l.id).toList(), ['a', 'b', 'c']);
    });

    test('undo reorder returns false when newIndex is null', () {
      final doc = makeDoc(['a', 'b']);
      const op = UndoOp(kind: UndoOpKind.reorder, index: 0);
      expect(applyUndo(doc, op), false);
    });

    test('undo reorder returns false when indices match after clamping', () {
      final doc = makeDoc(['a']);
      // Both indices clamp to 0 in a single-element list.
      const op = UndoOp(
        kind: UndoOpKind.reorder,
        index: 0,
        newIndex: 0,
      );
      expect(applyUndo(doc, op), false);
    });
  });

  group('applyRedo — reorder', () {
    NotepadDocument makeDoc(List<String> ids) {
      final doc = NotepadDocument.fresh(name: 'T');
      doc.lines.clear();
      for (final id in ids) {
        doc.lines.add(NotepadLine(id: id, source: id));
      }
      return doc;
    }

    test('redo reorder moves line from index to newIndex', () {
      // We start with the original order [a, b, c].
      // Redo should re-apply the reorder: move index 0 -> newIndex 2.
      final doc = makeDoc(['a', 'b', 'c']);

      const op = UndoOp(
        kind: UndoOpKind.reorder,
        index: 0,
        newIndex: 2,
      );

      final ok = applyRedo(doc, op);
      expect(ok, true);
      expect(doc.lines.map((l) => l.id).toList(), ['b', 'c', 'a']);
    });

    test('redo reorder returns false when newIndex is null', () {
      final doc = makeDoc(['a', 'b']);
      const op = UndoOp(kind: UndoOpKind.reorder, index: 0);
      expect(applyRedo(doc, op), false);
    });
  });

  // =========================================================================
  // Undo/redo round-trip for reorder
  // =========================================================================

  group('reorder undo/redo round-trip', () {
    test('undo then redo restores original reorder', () {
      final doc = NotepadDocument.fresh(name: 'T');
      doc.lines.clear();
      doc.lines.add(NotepadLine(id: 'a', source: 'a'));
      doc.lines.add(NotepadLine(id: 'b', source: 'b'));
      doc.lines.add(NotepadLine(id: 'c', source: 'c'));

      // Simulate: user moved line 0 -> 2, so doc is now [b, c, a].
      final line = doc.lines.removeAt(0);
      doc.lines.insert(2, line);
      expect(doc.lines.map((l) => l.id).toList(), ['b', 'c', 'a']);

      final history = UndoHistory();
      const op = UndoOp(
        kind: UndoOpKind.reorder,
        index: 0,
        newIndex: 2,
      );
      history.record(op);

      // Undo.
      final undoOp = history.undo();
      expect(undoOp, isNotNull);
      applyUndo(doc, undoOp!);
      expect(doc.lines.map((l) => l.id).toList(), ['a', 'b', 'c']);

      // Redo.
      final redoOp = history.redo();
      expect(redoOp, isNotNull);
      applyRedo(doc, redoOp!);
      expect(doc.lines.map((l) => l.id).toList(), ['b', 'c', 'a']);
    });
  });

  // =========================================================================
  // clear() method
  // =========================================================================

  group('UndoHistory.clear()', () {
    test('clear empties both undo and redo stacks', () {
      final h = UndoHistory();
      // Build some undo state.
      h.record(const UndoOp(kind: UndoOpKind.edit, index: 0));
      h.record(const UndoOp(kind: UndoOpKind.insert, index: 1, lineId: 'a'));
      h.undo(); // moves the insert op to redo stack.

      expect(h.canUndo, true);
      expect(h.canRedo, true);

      h.clear();

      expect(h.canUndo, false);
      expect(h.canRedo, false);
      expect(h.undoCount, 0);
      expect(h.redoCount, 0);
    });

    test('clear on empty history is a no-op', () {
      final h = UndoHistory();
      h.clear();
      expect(h.undoCount, 0);
      expect(h.redoCount, 0);
    });

    test('recording after clear works normally', () {
      final h = UndoHistory();
      h.record(const UndoOp(kind: UndoOpKind.edit, index: 0));
      h.clear();

      h.record(const UndoOp(
        kind: UndoOpKind.delete,
        index: 3,
        lineId: 'x',
        previousValue: 'hello',
      ));
      expect(h.undoCount, 1);
      final op = h.undo();
      expect(op!.kind, UndoOpKind.delete);
      expect(op.index, 3);
    });
  });

  // =========================================================================
  // applyUndo / applyRedo edge cases
  // =========================================================================

  group('applyUndo — edge cases', () {
    test('undo insert with missing lineId returns false', () {
      final doc = NotepadDocument.fresh(name: 'T');
      doc.lines.clear();
      doc.lines.add(NotepadLine(id: 'a', source: 'x'));

      // lineId 'z' does not exist in doc.
      const op = UndoOp(
        kind: UndoOpKind.insert,
        index: 0,
        lineId: 'z',
      );
      expect(applyUndo(doc, op), false);
      expect(doc.lines.length, 1); // unchanged
    });

    test('undo delete without previousValue returns false', () {
      final doc = NotepadDocument.fresh(name: 'T');
      doc.lines.clear();

      const op = UndoOp(
        kind: UndoOpKind.delete,
        index: 0,
        lineId: 'b',
        // previousValue intentionally omitted
      );
      expect(applyUndo(doc, op), false);
    });

    test('undo edit with missing lineId returns false', () {
      final doc = NotepadDocument.fresh(name: 'T');
      doc.lines.clear();
      doc.lines.add(NotepadLine(id: 'a', source: 'x'));

      const op = UndoOp(
        kind: UndoOpKind.edit,
        index: 0,
        lineId: 'missing',
        previousValue: 'old',
      );
      expect(applyUndo(doc, op), false);
    });

    test('undo delete clamps index to valid range', () {
      final doc = NotepadDocument.fresh(name: 'T');
      doc.lines.clear();
      // Empty doc — index 5 should clamp to 0.
      const op = UndoOp(
        kind: UndoOpKind.delete,
        index: 5,
        lineId: 'restored',
        previousValue: 'hello',
      );
      final ok = applyUndo(doc, op);
      expect(ok, true);
      expect(doc.lines.length, 1);
      expect(doc.lines[0].id, 'restored');
      expect(doc.lines[0].source, 'hello');
    });
  });

  group('applyRedo — edge cases', () {
    test('redo insert without lineId returns false', () {
      final doc = NotepadDocument.fresh(name: 'T');
      doc.lines.clear();

      const op = UndoOp(
        kind: UndoOpKind.insert,
        index: 0,
        // lineId intentionally omitted
      );
      expect(applyRedo(doc, op), false);
    });

    test('redo delete with missing lineId returns false', () {
      final doc = NotepadDocument.fresh(name: 'T');
      doc.lines.clear();
      doc.lines.add(NotepadLine(id: 'a', source: 'x'));

      const op = UndoOp(
        kind: UndoOpKind.delete,
        index: 0,
        lineId: 'nonexistent',
      );
      expect(applyRedo(doc, op), false);
    });

    test('redo edit always returns false (no-op by design)', () {
      final doc = NotepadDocument.fresh(name: 'T');
      doc.lines.clear();
      doc.lines.add(NotepadLine(id: 'a', source: 'x'));

      const op = UndoOp(
        kind: UndoOpKind.edit,
        index: 0,
        lineId: 'a',
        previousValue: 'old',
      );
      expect(applyRedo(doc, op), false);
    });
  });
}
