import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../engine/worksheet_bundle.dart';
import '../localization/workflow_localizations.dart';

class WorksheetExportDialog extends StatefulWidget {
  final WorksheetBundle bundle;
  const WorksheetExportDialog({super.key, required this.bundle});
  @override
  State<WorksheetExportDialog> createState() => _WorksheetExportDialogState();
}

class _WorksheetExportDialogState extends State<WorksheetExportDialog> {
  bool _busy = false;
  String? _error;
  Future<void> _save(String format) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final bytes = format == 'pdf'
          ? await widget.bundle.pdf()
          : Uint8List.fromList(utf8.encode(format == 'html'
              ? widget.bundle.html()
              : format == 'tex'
                  ? widget.bundle.latex()
                  : widget.bundle.markdown()));
      await FilePicker.saveFile(
          fileName: 'Worksheet.$format',
          type: FileType.custom,
          allowedExtensions: [format],
          bytes: bytes);
    } catch (error) {
      if (mounted) setState(() => _error = WorkflowLocalizations.of(context).text(WorkflowLabel.exportFailed, '$error'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bundle = widget.bundle;
    return AlertDialog(
      scrollable: true,
      title: Text(WorkflowLocalizations.of(context).text(WorkflowLabel.worksheetExport)),
      content: SizedBox(
          width: 720,
          height: 480,
          child: ListView.builder(
            itemCount: 2 +
                bundle.warnings.length +
                bundle.document.lines.length +
                bundle.graphs.length +
                (_error == null ? 0 : 1),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Text(bundle.document.name,
                    style: Theme.of(context).textTheme.titleLarge);
              }
              if (index == 1) {
                return Text(WorkflowLocalizations.of(context).text(WorkflowLabel.exportSnapshot));
              }
              index -= 2;
              if (index < bundle.warnings.length) {
                return Text(bundle.warnings[index]);
              }
              index -= bundle.warnings.length;
              if (index < bundle.document.lines.length) {
                return ListTile(
                    title: Text(bundle.document.lines[index].source),
                    subtitle: Text(bundle.resultAt(index)),
                    dense: true);
              }
              index -= bundle.document.lines.length;
              if (index < bundle.graphs.length) {
                final graph = bundle.graphs[index];
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(graph.expression,
                          style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: CustomPaint(painter: _GraphPainter(graph))),
                      for (final row in graph.values)
                        Text('x = ${row.$1}, y = ${row.$2 ?? WorkflowLocalizations.of(context).text(WorkflowLabel.exportUndefined)}'),
                    ]);
              }
              return Text(_error!);
            },
          )),
      actions: [
        SizedBox(
          width: 720,
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 4,
            children: [
              TextButton(
                  onPressed: _busy ? null : () => Navigator.pop(context),
                  child: Text(WorkflowLocalizations.of(context).text(WorkflowLabel.close))),
              for (final format in ['html', 'md', 'tex', 'pdf'])
                TextButton(
                    onPressed: _busy ? null : () => _save(format),
                    child: Text(WorkflowLocalizations.of(context).text(WorkflowLabel.exportSave, format.toUpperCase()))),
            ],
          ),
        ),
      ],
    );
  }
}

class _GraphPainter extends CustomPainter {
  final WorksheetGraph graph;
  _GraphPainter(this.graph);
  @override
  void paint(Canvas canvas, Size size) {
    final axes = Paint()
      ..color = Colors.grey
      ..strokeWidth = .7;
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), axes);
    canvas.drawLine(
        Offset(size.width / 2, 0), Offset(size.width / 2, size.height), axes);
    // Render the exact path captured for the SVG, avoiding a second evaluation.
    final path = Path();
    for (final match
        in RegExp(r'([ML])([\d.-]+),([\d.-]+)').allMatches(graph.curvePath)) {
      final x = double.parse(match[2]!) / 640 * size.width;
      final y = double.parse(match[3]!) / 320 * size.height;
      if (match[1] == 'M') {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_GraphPainter oldDelegate) => oldDelegate.graph != graph;
}
