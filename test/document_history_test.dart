import 'dart:convert';
import 'dart:typed_data';

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/services/document_history.dart';
import 'package:crisp_math/services/workspace_backup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppState().load(force: true);
    AppState()
        .notepadDocuments
        .removeWhere((id, _) => id != kWelcomeNotepadDocId);
  });
  NotepadDocument document() {
    final doc = NotepadDocument.fresh(name: 'History');
    doc.lines.clear();
    doc.lines.add(NotepadLine.fresh(source: '2+3')
      ..cachedResult = '5'
      ..pinned = true);
    return doc;
  }

  test('snapshot retains IDs and presentation while discarding caches', () {
    final doc = document();
    final checkpoint = DocumentCheckpoint.capture(doc, label: 'First');
    doc.lines.first.source = '8+1';
    final restored = checkpoint.document;
    expect(restored.id, doc.id);
    expect(restored.lines.first.id, doc.lines.first.id);
    expect(restored.lines.first.source, '2+3');
    expect(restored.lines.first.cachedResult, isNull);
    expect(restored.lines.first.pinned, isTrue);
    expect(checkpoint.compare(doc), contains('2+3 → 8+1'));
    expect(DocumentCheckpoint.fromJson(checkpoint.toJson()).documentId, doc.id);
  });
  test('comparison records added, removed and moved rows', () {
    final doc = document();
    doc.lines.add(NotepadLine.fresh(source: '10'));
    final checkpoint = DocumentCheckpoint.capture(doc, label: 'Before');
    doc.lines.removeAt(0);
    doc.lines.add(NotepadLine.fresh(source: '12'));
    expect(checkpoint.compare(doc),
        containsAll(['Removed: 2+3', 'Moved: 10', 'Added: 12']));
  });
  test('serialized concurrent checkpoints retain latest twenty', () async {
    final doc = document();
    final history = DocumentHistory();
    await Future.wait(
        [for (var i = 0; i < 25; i++) history.save(doc, label: 'Version $i')]);
    final entries = await history.forDocument(doc.id);
    expect(entries.length, 20);
    expect(entries.first.label, 'Version 24');
    expect(entries.last.label, 'Version 5');
    expect(entries.first.document.lines.first.cachedResult, isNull);
  });
  test('malformed source and excessive snapshots fail before writing',
      () async {
    final doc = document();
    final raw = worksheetSource(doc);
    (raw['l'] as List).add((raw['l'] as List).first);
    expect(() => validateWorksheetSource(raw), throwsFormatException);
    final large = document()..name = 'Large';
    large.lines.first.source = 'x' * DocumentHistory.maxBytes;
    await expectLater(DocumentHistory().save(large), throwsFormatException);
    expect(await DocumentHistory().all(), isEmpty);
  });
  test('backup integrity, caches and secret exclusion', () async {
    final doc = document();
    AppState().setNotepadDocument(doc);
    AppState().setCurrentNotepadDoc(doc.id);
    final checkpoint = await DocumentHistory().save(doc);
    final bytes = WorkspaceBackup.encode(AppState(), checkpoints: [checkpoint]);
    final decoded = WorkspaceBackup.decode(bytes);
    expect(decoded.documents.single.lines.first.cachedResult, isNull);
    expect(decoded.checkpoints.single.documentId, doc.id);
    final raw = jsonDecode(utf8.decode(bytes));
    raw['state']['notepadDocuments'][0]['n'] = 'Tampered';
    expect(
        () => WorkspaceBackup.decode(
            Uint8List.fromList(utf8.encode(jsonEncode(raw)))),
        throwsFormatException);
    final normalized = WorkspaceBackup.normalize({
      ...AppState().exportToJson(),
      'apiKey': 'private',
      'session': 'private'
    });
    expect(normalized, isNot(contains('apiKey')));
    expect(normalized, isNot(contains('session')));
    final invalid = {
      ...AppState().exportToJson(),
      'userFunctions': [
        {'n': 12}
      ]
    };
    expect(() => WorkspaceBackup.normalize(invalid), throwsFormatException);
    expect(AppState().notepadDocuments[doc.id]!.name, 'History');
  });
  test('document merge preserves both versions regardless of timestamps', () {
    final doc = document();
    AppState().setNotepadDocument(doc);
    final old = worksheetSource(doc)..['u'] = '2000-01-01T00:00:00Z';
    old['l'][0]['s'] = '99';
    final incoming = WorkspaceBackup.fromState({
      'notepadDocuments': [old]
    });
    final merged = incoming.mergeDocuments(AppState());
    final docs = (merged['notepadDocuments'] as List)
        .map(validateWorksheetSource)
        .toList();
    expect(docs.length, 2);
    expect(docs.first.lines.first.source, '2+3');
    expect(docs.last.lines.first.source, '99');
    expect(docs.last.id, isNot(doc.id));
    expect(docs.last.lines.first.id, isNot(doc.lines.first.id));
    expect(AppState().notepadDocuments.length, 2,
        reason: 'Welcome plus original; merge preview never mutates state');
  });
  test('repeated conflict imports do not duplicate preserved versions', () {
    final doc = document();
    AppState().setNotepadDocument(doc);
    final remote = worksheetSource(doc);
    remote['l'][0]['s'] = '99';
    final incoming = WorkspaceBackup.fromState({
      'notepadDocuments': [remote]
    });
    AppState().importFromJson(incoming.mergeDocuments(AppState()));
    expect(
        (incoming.mergeDocuments(AppState())['notepadDocuments'] as List)
            .length,
        2);
  });
  test('invalid 3D geometry is rejected before changing the workspace', () {
    final raw = AppState().exportToJson();
    raw['scene3D']['zo'] = double.infinity;
    expect(() => WorkspaceBackup.normalize(raw), throwsFormatException);
    expect(AppState().scene3D.zoom.isFinite, isTrue);
  });

  test('recovery persists original workspace before later edits', () async {
    final doc = document();
    AppState().setNotepadDocument(doc);
    await DocumentHistory().save(doc);
    await WorkspaceBackup.saveRecovery(AppState());
    doc.lines.first.source = 'New content';
    final recovery = await WorkspaceBackup.recovery();
    expect(recovery!.documents.single.lines.first.source, '2+3');
    expect(recovery.checkpoints.length, 1);
  });
  test('a workspace without an active document can be backed up', () {
    AppState().setCurrentNotepadDoc(null);
    final backup = WorkspaceBackup.decode(WorkspaceBackup.encode(AppState()));
    expect(backup.state['currentNotepadDocId'], isNull);
  });
}
