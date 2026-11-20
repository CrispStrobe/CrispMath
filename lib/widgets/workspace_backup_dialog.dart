import 'package:flutter/material.dart';

import '../engine/app_state.dart';
import '../localization/app_localizations.dart';
import '../services/document_history.dart';
import '../services/workspace_backup.dart';

class WorkspaceBackupDialog extends StatefulWidget {
  final VoidCallback? onRestored;
  final WorkspaceBackup? initialBackup;
  const WorkspaceBackupDialog({super.key, this.onRestored, this.initialBackup});
  @override
  State<WorkspaceBackupDialog> createState() => _WorkspaceBackupDialogState();
}

class _WorkspaceBackupDialogState extends State<WorkspaceBackupDialog> {
  WorkspaceBackup? _incoming;
  bool _busy = false;
  String? _message;
  AppLocalizations get _t => AppLocalizations.of(context);
  @override
  void initState() {
    super.initState();
    _incoming = widget.initialBackup;
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) setState(() => _message = _t.backupFailed('$error'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore(bool merge) async {
    final incoming = _incoming!;
    final state = AppState();
    final payload = merge ? incoming.mergeDocuments(state) : incoming.state;
    // Protect current work before any state mutation. Failure aborts restore.
    await WorkspaceBackup.saveRecovery(state);
    final current = await DocumentHistory().all();
    final entries = merge
        ? {
            for (final c in [...current, ...incoming.checkpoints]) c.id: c
          }.values.toList()
        : incoming.checkpoints;
    await DocumentHistory().replaceAll(entries);
    state.importFromJson(payload);
    if (payload.containsKey('currentNotepadDocId')) {
      state.setCurrentNotepadDoc(payload['currentNotepadDocId'] as String?);
    }
    await state.flushPersistence();
    widget.onRestored?.call();
    if (mounted) {
      setState(() {
        _incoming = null;
        _message = merge
            ? _t.backupWorksheetsImported
            : _t.backupWorkspaceRestored;
      });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(_t.backupDialogTitle),
        content: SizedBox(
            width: 600,
            height: 360,
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(_t.backupIntro),
                  if (_message != null) Text(_message!),
                  if (_incoming != null) ...[
                    Text(_t.backupContents(
                        _incoming!.documents.length, _incoming!.checkpoints.length)),
                    Text(_t.backupRestoreExplanation),
                    for (final doc in _incoming!.documents.take(20))
                      Text(_t.backupDocRows(doc.name, doc.lines.length)),
                  ],
                ]))),
        actions: [
          TextButton(
              onPressed: _busy ? null : () => Navigator.pop(context),
              child: Text(_t.dialogClose)),
          TextButton(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                        await WorkspaceBackup.save(AppState());
                      }),
              child: Text(_t.backupSave)),
          TextButton(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                        final backup = await WorkspaceBackup.open();
                        if (mounted && backup != null) {
                          setState(() => _incoming = backup);
                        }
                      }),
              child: Text(_t.backupOpen)),
          TextButton(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                        final backup = await WorkspaceBackup.recovery();
                        if (mounted) {
                          setState(() {
                            _incoming = backup;
                            if (backup == null) {
                              _message = _t.backupNoRecovery;
                            }
                          });
                        }
                      }),
              child: Text(_t.backupPreviousWorkspace)),
          if (_incoming != null) ...[
            FilledButton(
                onPressed: _busy ? null : () => _run(() => _restore(true)),
                child: Text(_t.backupImportWorksheets)),
            TextButton(
                onPressed: _busy ? null : () => _run(() => _restore(false)),
                child: Text(_t.backupReplaceWorkspace)),
          ],
        ],
      );
}
