import 'package:flutter/material.dart';

import '../engine/notepad.dart';
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
              title: const Text('Compare checkpoint'),
              content: SizedBox(
                  width: 520,
                  height:
                      (128 + changes.length * 30).clamp(160, 320).toDouble(),
                  child: ListView(children: [
                    const Text('Changes since this checkpoint:'),
                    if (changes.isEmpty) const Text('No source changes'),
                    for (final change in changes) Text(change),
                    const Text(
                        'Restore saves a checkpoint of your current work first and recalculates results.'),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Restore checkpoint'))
              ],
            ));
    if (restore != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _history.save(widget.currentDocument(), label: 'Before restore');
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
        title: const Text('Document history'),
        content: SizedBox(
            width: 600,
            height:
                (140 + (_entries?.length ?? 1) * 76).clamp(180, 400).toDouble(),
            child: Column(children: [
              const Text(
                  'Up to 20 checkpoints per document, 100 in total, within 1 MB. Older checkpoints expire as the limit is reached.'),
              if (_error != null) Text(_error!),
              Expanded(
                  child: _entries == null
                      ? (_error == null
                          ? const Center(child: CircularProgressIndicator())
                          : const SizedBox.shrink())
                      : _entries!.isEmpty
                          ? const Center(
                              child: Text(
                                  'No checkpoints yet. Save one to keep a version of this worksheet.'))
                          : ListView.builder(
                              itemCount: _entries!.length,
                              itemBuilder: (context, index) {
                                final entry = _entries![index];
                                return ListTile(
                                    title: Text(entry.label),
                                    subtitle: Text(entry.createdAt
                                        .toLocal()
                                        .toString()
                                        .split('.')
                                        .first),
                                    trailing: TextButton(
                                        onPressed: _busy
                                            ? null
                                            : () => _compare(entry),
                                        child: const Text('Compare')));
                              })),
            ])),
        actions: [
          TextButton(
              onPressed: _busy ? null : () => Navigator.pop(context),
              child: const Text('Close')),
          FilledButton(
              onPressed: _busy ? null : _save,
              child: const Text('Save checkpoint'))
        ],
      );
}
