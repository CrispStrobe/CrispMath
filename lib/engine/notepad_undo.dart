// lib/engine/notepad_undo.dart
//
// Notepad V2: multi-level undo/redo for document edits.
//
// Records line-level operations (insert, delete, edit, reorder) in a
// ring buffer. Cmd+Z undoes, Cmd+Shift+Z redoes. Capped at 50 entries
// per document to bound memory.

import 'notepad.dart';

/// The kind of operation that was performed.
enum UndoOpKind { insert, delete, edit, reorder }

/// A single undoable operation.
class UndoOp {
  final UndoOpKind kind;

  /// For insert: the index where the line was added.
  /// For delete: the index where the line was removed.
  /// For edit: the line index.
  /// For reorder: the old index.
  final int index;

  /// For reorder: the new index.
  final int? newIndex;

  /// For delete: the removed line (for restoring).
  /// For edit: the previous source text.
  final String? previousValue;

  /// For insert: the line id (for removal on undo).
  /// For edit: the line id.
  final String? lineId;

  const UndoOp({
    required this.kind,
    required this.index,
    this.newIndex,
    this.previousValue,
    this.lineId,
  });
}

/// Ring-buffer undo/redo stack. One per document.
class UndoHistory {
  static const int maxEntries = 50;

  final List<UndoOp> _undoStack = [];
  final List<UndoOp> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  /// Record an operation. Clears the redo stack (a new action
  /// forks the history).
  void record(UndoOp op) {
    _undoStack.add(op);
    if (_undoStack.length > maxEntries) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  /// Undo the most recent operation. Returns the op to reverse,
  /// or null if the stack is empty. The caller applies the reverse
  /// to the document.
  UndoOp? undo() {
    if (_undoStack.isEmpty) return null;
    final op = _undoStack.removeLast();
    _redoStack.add(op);
    return op;
  }

  /// Redo the most recently undone operation.
  UndoOp? redo() {
    if (_redoStack.isEmpty) return null;
    final op = _redoStack.removeLast();
    _undoStack.add(op);
    return op;
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }

  int get undoCount => _undoStack.length;
  int get redoCount => _redoStack.length;
}

/// Apply an undo operation to a document. Returns true if the
/// document was modified.
bool applyUndo(NotepadDocument doc, UndoOp op) {
  switch (op.kind) {
    case UndoOpKind.insert:
      // Undo an insert → remove the line.
      final idx = doc.lines.indexWhere((l) => l.id == op.lineId);
      if (idx >= 0) {
        doc.lines.removeAt(idx);
        return true;
      }
      return false;

    case UndoOpKind.delete:
      // Undo a delete → re-insert the line.
      if (op.previousValue != null && op.lineId != null) {
        final restored = NotepadLine(
          id: op.lineId!,
          source: op.previousValue!,
        );
        final idx = op.index.clamp(0, doc.lines.length);
        doc.lines.insert(idx, restored);
        return true;
      }
      return false;

    case UndoOpKind.edit:
      // Undo an edit → restore the previous source.
      final idx = doc.lines.indexWhere((l) => l.id == op.lineId);
      if (idx >= 0 && op.previousValue != null) {
        doc.lines[idx].source = op.previousValue!;
        return true;
      }
      return false;

    case UndoOpKind.reorder:
      // Undo a reorder → move back.
      if (op.newIndex != null) {
        final current = op.newIndex!.clamp(0, doc.lines.length - 1);
        final target = op.index.clamp(0, doc.lines.length - 1);
        if (current != target && current < doc.lines.length) {
          final line = doc.lines.removeAt(current);
          doc.lines.insert(target, line);
          return true;
        }
      }
      return false;
  }
}

/// Apply a redo operation to a document. Returns true if modified.
bool applyRedo(NotepadDocument doc, UndoOp op) {
  switch (op.kind) {
    case UndoOpKind.insert:
      // Redo an insert → re-insert.
      if (op.lineId != null) {
        final line = NotepadLine(id: op.lineId!, source: '');
        final idx = op.index.clamp(0, doc.lines.length);
        doc.lines.insert(idx, line);
        return true;
      }
      return false;

    case UndoOpKind.delete:
      // Redo a delete → remove again.
      final idx = doc.lines.indexWhere((l) => l.id == op.lineId);
      if (idx >= 0) {
        doc.lines.removeAt(idx);
        return true;
      }
      return false;

    case UndoOpKind.edit:
      // Redo an edit → we don't store the "new" value in the op,
      // so redo of edit is a no-op (the user just types again).
      return false;

    case UndoOpKind.reorder:
      // Redo a reorder → move forward.
      if (op.newIndex != null) {
        final current = op.index.clamp(0, doc.lines.length - 1);
        final target = op.newIndex!.clamp(0, doc.lines.length - 1);
        if (current != target && current < doc.lines.length) {
          final line = doc.lines.removeAt(current);
          doc.lines.insert(target, line);
          return true;
        }
      }
      return false;
  }
}
