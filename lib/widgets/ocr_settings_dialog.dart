// lib/widgets/ocr_settings_dialog.dart
//
// Settings dialog for OCR model management: browse available models,
// download/delete, see disk usage, select active model.

import 'package:flutter/material.dart';

import '../engine/ocr_model_manager.dart';
import '../engine/ocr_provider.dart';

class OcrSettingsDialog extends StatefulWidget {
  const OcrSettingsDialog({super.key});

  @override
  State<OcrSettingsDialog> createState() => _OcrSettingsDialogState();
}

class _OcrSettingsDialogState extends State<OcrSettingsDialog> {
  final Map<String, bool> _downloaded = {};
  final Map<String, double> _downloadProgress = {};
  final Set<String> _downloading = {};
  int _totalDiskUsage = 0;

  @override
  void initState() {
    super.initState();
    _checkDownloaded();
  }

  Future<void> _checkDownloaded() async {
    for (final model in OcrModelCatalog.all) {
      final exists = await OcrModelManager.isDownloaded(model);
      if (mounted) setState(() => _downloaded[model.id] = exists);
    }
    final usage = await OcrModelManager.totalDiskUsage();
    if (mounted) setState(() => _totalDiskUsage = usage);
  }

  Future<void> _download(OcrModelVariant model) async {
    // NC license gate: require explicit user confirmation
    if (model.requiresLicenseAcceptance) {
      final accepted = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('License Terms'),
          content: Text(
            'This model is licensed under ${model.license}.\n\n'
            'By downloading, you confirm that you will use these '
            'model weights for non-commercial purposes only.\n\n'
            'The app itself is not restricted — this applies only '
            'to the model weights.',
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

    setState(() {
      _downloading.add(model.id);
      _downloadProgress[model.id] = 0;
    });

    final path = await OcrModelManager.download(
      model,
      onProgress: (received, total) {
        if (mounted && total > 0) {
          setState(() => _downloadProgress[model.id] = received / total);
        }
      },
    );

    if (mounted) {
      setState(() {
        _downloading.remove(model.id);
        _downloadProgress.remove(model.id);
        _downloaded[model.id] = path != null;
      });
      _checkDownloaded(); // refresh disk usage
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${model.name} downloaded')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: ${model.name}')),
        );
      }
    }
  }

  Future<void> _delete(OcrModelVariant model) async {
    await OcrModelManager.delete(model);
    if (mounted) {
      setState(() => _downloaded[model.id] = false);
      _checkDownloaded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final diskMB = (_totalDiskUsage / (1024 * 1024)).toStringAsFixed(1);

    return AlertDialog(
      title: const Text('Math OCR Models'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Disk usage
              Row(
                children: [
                  Icon(Icons.storage,
                      size: 16,
                      semanticLabel: 'Disk usage',
                      color: scheme.primary),
                  const SizedBox(width: 8),
                  Text('Disk usage: $diskMB MB',
                      style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurface.withValues(alpha: 0.7))),
                ],
              ),
              const SizedBox(height: 12),

              // Active provider
              if (OcrProviders.active != null)
                Chip(
                  avatar: const Icon(Icons.check_circle,
                      size: 16, semanticLabel: 'Active'),
                  label: Text('Active: ${OcrProviders.active!.name}'),
                  backgroundColor: scheme.primaryContainer,
                )
              else
                Chip(
                  avatar: Icon(Icons.info_outline,
                      size: 16,
                      semanticLabel: 'No model active',
                      color: scheme.error),
                  label: const Text('No model active — download one below'),
                ),
              const SizedBox(height: 16),

              // Printed math models
              Text('Printed Math',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: scheme.primary)),
              const SizedBox(height: 8),
              for (final model in OcrModelCatalog.printedMath)
                _buildModelTile(model),

              const SizedBox(height: 16),
              Text('Handwritten Math',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: scheme.primary)),
              const SizedBox(height: 8),
              for (final model in OcrModelCatalog.handwrittenMath)
                _buildModelTile(model),
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
    final progress = _downloadProgress[model.id] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: isDownloaded
            ? const Icon(Icons.check_circle,
                color: Colors.green, semanticLabel: 'Downloaded')
            : const Icon(Icons.cloud_download_outlined,
                semanticLabel: 'Not downloaded'),
        title: Text(model.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(model.description, style: const TextStyle(fontSize: 11)),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(model.sizeLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary)),
                if (model.license != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: model.requiresLicenseAcceptance
                          ? Colors.orange.withValues(alpha: 0.15)
                          : Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(model.license!,
                        style: TextStyle(
                            fontSize: 9,
                            color: model.requiresLicenseAcceptance
                                ? Colors.orange.shade700
                                : Colors.green.shade700)),
                  ),
                ],
              ],
            ),
            if (isDownloading)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: LinearProgressIndicator(value: progress),
              ),
          ],
        ),
        trailing: isDownloading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2))
            : isDownloaded
                ? IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, semanticLabel: 'Delete model'),
                    onPressed: () => _delete(model),
                  )
                : IconButton(
                    icon: const Icon(Icons.download,
                        size: 20, semanticLabel: 'Download model'),
                    onPressed: () => _download(model),
                  ),
      ),
    );
  }
}
