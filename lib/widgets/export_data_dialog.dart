// lib/widgets/export_data_dialog.dart
//
// Settings → Export data. Shows the full AppState as pretty-printed
// JSON or calculation history as CSV, with a Copy button.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/app_state.dart';
import '../localization/app_localizations.dart';

enum _ExportFormat { json, csv }

class ExportDataDialog extends StatefulWidget {
  const ExportDataDialog({super.key});

  @override
  State<ExportDataDialog> createState() => _ExportDataDialogState();
}

class _ExportDataDialogState extends State<ExportDataDialog> {
  _ExportFormat _format = _ExportFormat.json;

  String _buildJson() =>
      const JsonEncoder.withIndent('  ').convert(AppState().exportToJson());

  String _buildCsv() {
    final buf = StringBuffer('Expression,Result,Type\n');
    for (final e in AppState().history) {
      buf.writeln(
          '${_csvEscape(e.expression)},${_csvEscape(e.result)},${e.type.name}');
    }
    return buf.toString();
  }

  static String _csvEscape(String s) => '"${s.replaceAll('"', '""')}"';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final content = _format == _ExportFormat.json ? _buildJson() : _buildCsv();

    return AlertDialog(
      title: Text(t.exportDataTitle),
      content: SizedBox(
        width: 520,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.exportDataSubtitle,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            SegmentedButton<_ExportFormat>(
              segments: const [
                ButtonSegment(value: _ExportFormat.json, label: Text('JSON')),
                ButtonSegment(value: _ExportFormat.csv, label: Text('CSV')),
              ],
              selected: {_format},
              onSelectionChanged: (s) => setState(() => _format = s.first),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    content,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.dialogClose),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.copy, size: 16, semanticLabel: 'Copy'),
          label: Text(t.exportDataCopy),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: content));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(t.exportDataCopied),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }
}
