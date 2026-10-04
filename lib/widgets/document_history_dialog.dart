import 'package:flutter/material.dart';

import '../engine/notepad.dart';
import '../localization/workflow_localizations.dart';
import '../services/document_history.dart';

class DocumentHistoryDialog extends StatefulWidget {
  final NotepadDocument Function() currentDocument;
  final void Function(NotepadDocument) onRestore;
  const DocumentHistoryDialog(
      {super.key, required this.currentDocument, required this.onRestore});
  @override
  State<DocumentHistoryDialog> createState() => _DocumentHistoryDialogState();
}

class _DocumentHistoryDialogState extends State<DocumentHistoryDialog> {
  final _history = DocumentHistory();
  List<DocumentCheckpoint>? _entries;
  String? _error;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final entries = await _history.forDocument(widget.currentDocument().id);
      if (mounted) setState(() => _entries = entries);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _history.save(widget.currentDocument());
      await _load();
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _compare(DocumentCheckpoint checkpoint) async {
    final changes = checkpoint.compare(widget.currentDocument());
    final restore = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(WorkflowLocalizations.of(context).text(WorkflowLabel.historyCompare)),
              content: SizedBox(
                  width: 520,
                  height:
                      (128 + changes.length * 30).clamp(160, 320).toDouble(),
                  child: ListView(children: [
                    Text(WorkflowLocalizations.of(context).text(WorkflowLabel.historyChanges)),
                    if (changes.isEmpty) Text(WorkflowLocalizations.of(context).text(WorkflowLabel.historyNoChanges)),
                    for (final change in changes) Text(change),
                    Text(WorkflowLocalizations.of(context).text(WorkflowLabel.historyRestoreNotice)),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(WorkflowLocalizations.of(context).text(WorkflowLabel.cancel))),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(WorkflowLocalizations.of(context).text(WorkflowLabel.historyRestore)))
              ],
            ));
    if (restore != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _history.save(widget.currentDocument(), label: WorkflowLocalizations.of(context).text(WorkflowLabel.historyBeforeRestore));
      final doc = checkpoint.document..updatedAt = DateTime.now().toUtc();
      widget.onRestore(doc);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(WorkflowLocalizations.of(context).text(WorkflowLabel.worksheetHistory)),
        content: SizedBox(
            width: 600,
            height:
                (140 + (_entries?.length ?? 1) * 76).clamp(180, 400).toDouble(),
            child: ListView(children: [
              Text(WorkflowLocalizations.of(context).text(WorkflowLabel.historyLimits)),
              if (_error != null) Text(_error!),
              if (_entries == null && _error == null)
                const Center(child: CircularProgressIndicator()),
              if (_entries?.isEmpty == true)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(WorkflowLocalizations.of(context).text(WorkflowLabel.historyEmpty)),
                ),
              for (final entry in _entries ?? <DocumentCheckpoint>[])
                ListTile(
                  title: Text(entry.label),
                  subtitle: Text(entry.createdAt.toLocal().toString().split('.').first),
                  trailing: TextButton(
                    onPressed: _busy ? null : () => _compare(entry),
                    child: Text(WorkflowLocalizations.of(context).text(WorkflowLabel.historyCompareButton)),
                  ),
                ),
            ])),
        actions: [
          TextButton(
              onPressed: _busy ? null : () => Navigator.pop(context),
              child: Text(WorkflowLocalizations.of(context).text(WorkflowLabel.close))),
          FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(WorkflowLocalizations.of(context).text(WorkflowLabel.historySave)))
        ],
      );
}
