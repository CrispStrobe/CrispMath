import 'package:flutter/material.dart';

import '../engine/app_state.dart';
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
      if (mounted) setState(() => _message = 'Backup failed: $error');
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
            ? 'Worksheets imported; conflicting versions kept separately.'
            : 'Workspace restored. Previous work is available under Previous workspace.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Workspace backups'),
        content: SizedBox(
            width: 600,
            height: 360,
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text(
                      'Save a portable backup to Files, iCloud Drive or another provider. Open it on another device to transfer your work. Automatic cloud sync requires a configured backend.'),
                  if (_message != null) Text(_message!),
                  if (_incoming != null) ...[
                    Text(
                        '${_incoming!.documents.length} worksheets and ${_incoming!.checkpoints.length} checkpoints in this backup.'),
                    const Text(
                        'Import worksheets keeps current settings and graphs and preserves both versions of changed documents. Replace workspace restores all saved settings, history, functions, graphs and worksheets. A recovery backup is saved first.'),
                    for (final doc in _incoming!.documents.take(20))
                      Text('${doc.name}: ${doc.lines.length} rows'),
                  ],
                ]))),
        actions: [
          TextButton(
              onPressed: _busy ? null : () => Navigator.pop(context),
              child: const Text('Close')),
          TextButton(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                        await WorkspaceBackup.save(AppState());
                      }),
              child: const Text('Save backup')),
          TextButton(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                        final backup = await WorkspaceBackup.open();
                        if (mounted && backup != null) {
                          setState(() => _incoming = backup);
                        }
                      }),
              child: const Text('Open backup')),
          TextButton(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                        final backup = await WorkspaceBackup.recovery();
                        if (mounted) {
                          setState(() {
                            _incoming = backup;
                            if (backup == null) {
                              _message = 'No recovery backup is available.';
                            }
                          });
                        }
                      }),
              child: const Text('Previous workspace')),
          if (_incoming != null) ...[
            FilledButton(
                onPressed: _busy ? null : () => _run(() => _restore(true)),
                child: const Text('Import worksheets')),
            TextButton(
                onPressed: _busy ? null : () => _run(() => _restore(false)),
                child: const Text('Replace workspace')),
          ],
        ],
      );
}
