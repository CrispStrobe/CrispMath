import 'dart:convert';

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
      'legacy blob migrates without losing document IDs or the active document',
      () async {
    final doc = NotepadDocument.fresh(name: 'Legacy');
    doc.lines.first.source = 'a = 42';
    SharedPreferences.setMockInitialValues({
      'crisp.notepadDocs': jsonEncode([doc.toJson()]),
      'crisp.currentNotepadDoc': doc.id,
    });
    final state = AppState();
    await state.load(force: true);
    final prefs = await SharedPreferences.getInstance();
    expect(state.currentNotepadDocId, doc.id);
    expect(state.notepadDocuments[doc.id]!.lines.first.source, 'a = 42');
    expect(prefs.getString('crisp.notepadDocs'), isNull);
    expect(jsonDecode(prefs.getString('crisp.notepadIndex')!), [doc.id]);
    await state.load(force: true);
    expect(state.notepadDocuments[doc.id]!.name, 'Legacy');
  });

  test('saving one document leaves other records untouched; lazy edits flush',
      () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.load(force: true);
    final a = NotepadDocument.fresh(name: 'A'),
        b = NotepadDocument.fresh(name: 'B');
    state.setNotepadDocument(a);
    state.setNotepadDocument(b);
    await state.flushPersistence();
    final prefs = await SharedPreferences.getInstance();
    final bKey = 'crisp.notepadDoc.${Uri.encodeComponent(b.id)}';
    final bBefore = prefs.getString(bKey);
    b.lines.first.source = 'unsaved';
    a.lines.first.source = 'saved';
    state.setNotepadDocument(a, notify: false);
    await state.flushPersistence();
    expect(prefs.getString(bKey), bBefore);
    await state.load(force: true);
    expect(state.notepadDocuments[a.id]!.lines.first.source, 'saved');
    expect(state.notepadDocuments[b.id]!.lines.first.source, '');
    state.deleteNotepadDocument(a.id);
    await state.flushPersistence();
    expect(prefs.getString('crisp.notepadDoc.${Uri.encodeComponent(a.id)}'),
        isNull);
    await state.load(force: true);
    expect(state.notepadDocuments.containsKey(a.id), isFalse);
  });

  test('one corrupt record does not prevent recovery of other documents',
      () async {
    final good = NotepadDocument.fresh(name: 'Good');
    SharedPreferences.setMockInitialValues({
      'crisp.notepadIndex': jsonEncode(['broken', good.id]),
      'crisp.notepadDoc.broken': 'invalid json',
      'crisp.notepadDoc.${Uri.encodeComponent(good.id)}':
          jsonEncode(good.toJson()),
    });
    final state = AppState();
    await state.load(force: true);
    expect(state.notepadDocuments[good.id]!.name, 'Good');
  });
}
