// lib/widgets/ocr_settings_dialog_stub.dart
//
// Web-compatible OCR settings dialog. Uses IndexedDB-based model manager
// instead of dart:io file system. Selected via conditional import when
// dart.library.io is NOT available.

import 'package:flutter/material.dart';

import '../engine/ocr_model_catalog.dart';
import '../engine/ocr_model_manager_web.dart';
import '../engine/ocr_provider.dart';

class OcrSettingsDialog extends StatefulWidget {
  const OcrSettingsDialog({super.key});

  @override
  State<OcrSettingsDialog> createState() => _OcrSettingsDialogState();
}

class _OcrSettingsDialogState extends State<OcrSettingsDialog> {
  final Map<String, bool> _downloaded = {};
  final Set<String> _downloading = {};

  @override
  void initState() {
    super.initState();
    _checkDownloaded();
  }

  Future<void> _checkDownloaded() async {
    for (final model in OcrModelCatalog.all) {
      final exists = await OcrModelManagerWeb.isDownloaded(model);
      if (mounted) setState(() => _downloaded[model.id] = exists);
    }
  }

  Future<void> _download(OcrModelVariant model) async {
    if (model.requiresLicenseAcceptance) {
      final accepted = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('License Terms'),
          content: Text(
            'This model is licensed under ${model.license}.\n\n'
            'By downloading, you confirm that you will use these '
            'model weights for non-commercial purposes only.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('I accept — download'),
            ),
          ],
        ),
      );
      if (accepted != true) return;
    }

    setState(() => _downloading.add(model.id));

    final bytes = await OcrModelManagerWeb.download(model);

    if (mounted) {
      setState(() {
        _downloading.remove(model.id);
        _downloaded[model.id] = bytes != null;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(bytes != null
            ? '${model.name} downloaded'
            : 'Download failed: ${model.name}'),
      ));
    }
  }

  Future<void> _delete(OcrModelVariant model) async {
    await OcrModelManagerWeb.delete(model);
    if (mounted) {
      setState(() => _downloaded[model.id] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Show models suitable for web (≤100 MB).
    final webModels = OcrModelCatalog.all
        .where((m) => m.sizeBytes <= 100 * 1024 * 1024)
        .toList();

    return AlertDialog(
      title: const Text('OCR Models (Web)'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Models are cached in your browser (IndexedDB).',
                  style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: 12),

              // Provider selector
              if (OcrProviders.available.isNotEmpty) ...[
                Text('Active Provider',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: scheme.primary)),
                const SizedBox(height: 4),
                ...OcrProviders.available.map((p) {
                  final isActive = OcrProviders.active == p;
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isActive
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: isActive ? scheme.primary : null,
                    ),
                    title:
                        Text(p.name, style: const TextStyle(fontSize: 13)),
                    subtitle: Text(
                      [
                        if (p.requiresNetwork) 'cloud',
                        if (p.requiresApiKey) 'API key',
                        if (!p.requiresNetwork) 'on-device (WASM)',
                      ].join(' · '),
                      style: const TextStyle(fontSize: 11),
                    ),
                    onTap: () =>
                        setState(() => OcrProviders.active = p),
                  );
                }),
                const Divider(height: 24),
              ],

              // Downloadable models
              Text('Available Models',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: scheme.primary)),
              const SizedBox(height: 8),
              for (final model in webModels) _buildModelTile(model),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildModelTile(OcrModelVariant model) {
    final isDownloaded = _downloaded[model.id] == true;
    final isDownloading = _downloading.contains(model.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: isDownloaded
            ? const Icon(Icons.check_circle,
                color: Colors.green, semanticLabel: 'Cached')
            : const Icon(Icons.cloud_download_outlined,
                semanticLabel: 'Not cached'),
        title: Text(model.name, style: const TextStyle(fontSize: 13)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(model.description, style: const TextStyle(fontSize: 10)),
            const SizedBox(height: 2),
            Row(children: [
              Text(model.sizeLabel,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary)),
              if (model.license != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: model.requiresLicenseAcceptance
                        ? Colors.orange.withValues(alpha: 0.15)
                        : Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(model.license!,
                      style: TextStyle(
                          fontSize: 8,
                          color: model.requiresLicenseAcceptance
                              ? Colors.orange.shade700
                              : Colors.green.shade700)),
                ),
              ],
            ]),
          ],
        ),
        trailing: isDownloading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : isDownloaded
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () => _delete(model),
                  )
                : IconButton(
                    icon: const Icon(Icons.download, size: 18),
                    onPressed: () => _download(model),
                  ),
      ),
    );
  }
}
