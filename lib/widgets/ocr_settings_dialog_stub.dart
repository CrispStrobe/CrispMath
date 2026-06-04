// lib/widgets/ocr_settings_dialog_stub.dart
//
// Web stub — OCR settings require dart:io for model downloads.
// On web, shows a simple "not available" message.

import 'package:flutter/material.dart';

class OcrSettingsDialog extends StatelessWidget {
  const OcrSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('OCR Settings'),
      content: const Text('On-device OCR is not available in the web version.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
