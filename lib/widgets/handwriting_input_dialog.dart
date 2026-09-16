// lib/widgets/handwriting_input_dialog.dart
//
// Handwritten math input dialog. Shows a drawing canvas where
// the user writes a math expression, then sends it to OCR.

import 'package:flutter/material.dart';

import '../engine/ocr_provider.dart';
import 'drawing_canvas.dart';
import 'ocr_capture_dialog.dart';
import 'ocr_settings_dialog.dart';

/// Shows a dialog with a drawing canvas for handwritten math input.
/// Returns the recognized expression (possibly edited by user), or
/// null if cancelled.
Future<String?> showHandwritingInputDialog(BuildContext context) async {
  return showDialog<String>(
    context: context,
    builder: (_) => const _HandwritingDialog(),
  );
}

class _HandwritingDialog extends StatefulWidget {
  const _HandwritingDialog();

  @override
  State<_HandwritingDialog> createState() => _HandwritingDialogState();
}

class _HandwritingDialogState extends State<_HandwritingDialog> {
  final GlobalKey<DrawingCanvasState> _canvasKey = GlobalKey();
  bool _recognizing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (OcrProviders.active == null) {
        if (OcrProviders.available.isNotEmpty) {
          setState(() {
            OcrProviders.active = OcrProviders.available.first;
          });
        } else {
          _promptDownload();
        }
      }
    });
  }

  Future<void> _promptDownload() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const OcrSettingsDialog(),
    );
    if (mounted) setState(() {});
  }

  Future<void> _recognize() async {
    final canvas = _canvasKey.currentState;
    if (canvas == null || canvas.isEmpty) return;

    final provider = OcrProviders.active;
    if (provider == null) {
      setState(() => _error = 'No OCR provider configured. Please download one.');
      _promptDownload();
      return;
    }

    setState(() {
      _recognizing = true;
      _error = null;
    });

    try {
      // Export canvas to grayscale bitmap
      final bytes = await canvas.toGrayscaleBytes(384, 384);
      if (bytes == null) {
        setState(() {
          _recognizing = false;
          _error = 'Failed to export drawing';
        });
        return;
      }

      // Run OCR
      final result = await provider.recognize(bytes, 384, 384);
      if (!mounted) return;

      setState(() => _recognizing = false);

      if (result == null) {
        setState(() => _error = 'Could not recognize expression');
        return;
      }

      // Show the capture dialog for review/edit
      final expression = await showOcrCaptureDialog(context, result);
      if (expression != null && expression.isNotEmpty && mounted) {
        Navigator.of(context).pop(expression);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _recognizing = false;
          _error = 'OCR failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    
    // Scale up to 80% of screen size as requested
    final maxWidth = screenSize.width * 0.8;
    // Leave some room for title, buttons, and model selector
    final canvasHeight = (screenSize.height * 0.8) - 150.0;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Write Math'),
          if (OcrProviders.available.isNotEmpty)
            DropdownButton<OcrProvider>(
              value: OcrProviders.available.contains(OcrProviders.active) 
                  ? OcrProviders.active 
                  : (OcrProviders.available.isNotEmpty ? OcrProviders.available.first : null),
              icon: const Icon(Icons.arrow_drop_down),
              elevation: 16,
              style: TextStyle(color: cs.primary, fontSize: 13),
              underline: Container(height: 1, color: cs.primary),
              onChanged: (OcrProvider? newValue) {
                if (newValue != null) {
                  setState(() {
                    OcrProviders.active = newValue;
                  });
                }
              },
              items: OcrProviders.available
                  .map<DropdownMenuItem<OcrProvider>>((OcrProvider value) {
                return DropdownMenuItem<OcrProvider>(
                  value: value,
                  child: Text(value.name),
                );
              }).toList(),
            )
          else
            TextButton.icon(
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Download Model'),
              onPressed: _promptDownload,
            ),
        ],
      ),
      content: SizedBox(
        width: maxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: cs.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DrawingCanvas(
                key: _canvasKey,
                width: maxWidth,
                height: canvasHeight > 100 ? canvasHeight : 100,
                strokeWidth: 5.0, // Thicker stroke for much larger canvas
                strokeColor: cs.onSurface,
                backgroundColor: cs.surface,
              ),
            ),
            const SizedBox(height: 8),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: cs.error, fontSize: 12),
                ),
              ),
            if (_recognizing)
              const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _canvasKey.currentState?.clear(),
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => _canvasKey.currentState?.undo(),
          child: const Text('Undo'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _recognizing ? null : _recognize,
          child: const Text('Recognize'),
        ),
      ],
    );
  }
}
