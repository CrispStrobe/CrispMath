// lib/widgets/ocr_capture_dialog.dart
//
// OCR capture flow: shows the recognized expression for the user
// to review and edit before inserting into the calculator/notepad.
//
// Usage:
//   final result = await showOcrCaptureDialog(context, ocrResult);
//   if (result != null) insertExpression(result);

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/ocr_provider.dart';

/// Shows the OCR result for review. Returns the (possibly edited)
/// expression string, or null if cancelled.
Future<String?> showOcrCaptureDialog(
  BuildContext context,
  OcrResult result,
) async {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _OcrCaptureDialog(result: result),
  );
}

class _OcrCaptureDialog extends StatefulWidget {
  final OcrResult result;
  const _OcrCaptureDialog({required this.result});

  @override
  State<_OcrCaptureDialog> createState() => _OcrCaptureDialogState();
}

class _OcrCaptureDialogState extends State<_OcrCaptureDialog> {
  late TextEditingController _controller;
  bool _showRaw = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.result.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Recognized Expression'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Provider info
            Row(
              children: [
                Icon(Icons.camera_alt, size: 16, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  widget.result.providerName,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (widget.result.confidence != null) ...[
                  const Spacer(),
                  Text(
                    '${(widget.result.confidence! * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Editable expression
            TextField(
              controller: _controller,
              maxLines: 3,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Expression',
                helperText: 'Edit if needed before inserting',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_copy, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _controller.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Copied'),
                          duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ),
            ),

            // Raw output toggle
            if (widget.result.rawOutput != widget.result.text) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => _showRaw = !_showRaw),
                child: Row(
                  children: [
                    Icon(
                      _showRaw ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Raw output',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (_showRaw)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SelectableText(
                    widget.result.rawOutput,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Insert'),
        ),
      ],
    );
  }
}
