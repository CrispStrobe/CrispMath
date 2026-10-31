// lib/widgets/ocr_settings_dialog.dart
//
// Settings dialog for OCR model management: browse available models,
// download/delete, see disk usage, select active provider.

import 'package:flutter/material.dart';

import '../engine/model_license_consent.dart';
import '../engine/ocr_model_manager.dart';
import '../engine/ocr_provider.dart';
import '../services/ocr_initialization.dart';
import '../engine/ocr_providers_init.dart';
import 'model_license_consent_dialog.dart';

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
    ensureOcrProviders().then((_) {
      if (mounted) setState(() {});
    });
    ModelLicenseConsent.load().then((_) {
      if (mounted) setState(() {});
    });
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
    final terms = model.restrictedTerms;
    if (terms != null) {
      // Restrictive license: explicit, persisted consent naming the license.
      if (!await ensureModelLicenseConsent(context, terms, model.name)) return;
      if (!mounted) return;
    } else if (model.requiresLicenseAcceptance) {
      // NC license gate: require explicit user confirmation
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
        // Reload providers to register the newly downloaded model natively
        await initOcrProviders();
        if (!mounted) return;
        setState(() {});

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

  /// Accept the license of an already-downloaded restricted model (e.g. one
  /// downloaded before its license was corrected) so it can be registered.
  Future<void> _acceptLicense(OcrModelVariant model) async {
    final terms = model.restrictedTerms;
    if (terms == null) return;
    if (!await ensureModelLicenseConsent(context, terms, model.name)) return;
    await initOcrProviders();
    if (mounted) setState(() {});
  }

  Future<void> _withdrawLicense(OcrModelVariant model) async {
    final terms = model.restrictedTerms;
    if (terms == null) return;
    await ModelLicenseConsent.revoke(terms);
    if (!OcrProviders.available.contains(OcrProviders.active)) {
      OcrProviders.active = null;
    }
    if (mounted) setState(() {});
  }

  void _setActiveProvider(OcrProvider provider) {
    setState(() => OcrProviders.active = provider);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final diskMB = (_totalDiskUsage / (1024 * 1024)).toStringAsFixed(1);

    return AlertDialog(
      title: const Text('OCR Models'),
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
                      semanticLabel: isActive ? 'Active' : 'Inactive',
                    ),
                    title: Text(p.name, style: const TextStyle(fontSize: 13)),
                    subtitle: Text(
                      [
                        if (p.requiresNetwork) 'cloud',
                        if (p.requiresApiKey) 'API key',
                        if (!p.requiresNetwork) 'on-device',
                      ].join(' · '),
                      style: const TextStyle(fontSize: 11),
                    ),
                    onTap: () => _setActiveProvider(p),
                  );
                }),
                const Divider(height: 24),
              ] else ...[
                Chip(
                  avatar: Icon(Icons.info_outline,
                      size: 16,
                      semanticLabel: 'No model active',
                      color: scheme.error),
                  label: const Text('No model active — download one below'),
                ),
                const SizedBox(height: 16),
              ],

              // Model catalog sections
              _buildSection('Printed Math — Best Quality',
                  OcrModelCatalog.printedMathPpfnl),
              _buildSection(
                  'Printed Math — Texo', OcrModelCatalog.printedMathTexo),
              _buildSection('Printed Math — MixTex (Chinese+English)',
                  OcrModelCatalog.printedMathMixtex),
              _buildSection(
                  'Printed Math — pix2tex', OcrModelCatalog.printedMath),
              _buildSection(
                  'Handwritten Math', OcrModelCatalog.handwrittenMath),
              _buildSection('Text Detection — Surya (91 langs)',
                  OcrModelCatalog.textDetectionSurya),
              _buildSection(
                  'Text Detection — DBNet', OcrModelCatalog.textDetection),
              _buildSection(
                  'Text Recognition — TrOCR', OcrModelCatalog.textRecognition),
              _buildSection(
                  'Layout Detection', OcrModelCatalog.layoutDetection),
              _buildSection('Vision-Language — Qwen3-VL (recommended)',
                  OcrModelCatalog.visionLanguageQwen3),
              _buildSection(
                  'Vision-Language — Qwen2.5-VL (non-commercial, optional)',
                  OcrModelCatalog.visionLanguage),
              _buildSection('Vision-Language — DeepSeek-OCR2',
                  OcrModelCatalog.deepseekOcr2),
              _buildSection('Vision-Language — Granite Vision (OCRBench 852)',
                  OcrModelCatalog.graniteVision),
              _buildSection('Vision-Language — LightOnOCR (fast, 1B)',
                  OcrModelCatalog.lightOnOcr),
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

  Widget _buildSection(String title, List<OcrModelVariant> models) {
    if (models.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 4),
        for (final model in models) _buildModelTile(model),
      ],
    );
  }

  Widget _buildModelTile(OcrModelVariant model) {
    final isDownloaded = _downloaded[model.id] == true;
    final isDownloading = _downloading.contains(model.id);
    final progress = _downloadProgress[model.id] ?? 0;
    final isPaused = !isDownloading && !isDownloaded && progress > 0;

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
            if (model.restrictedTerms != null)
              Align(
                alignment: Alignment.centerLeft,
                child: ModelLicenseConsent.allows(model.restrictedTerms)
                    ? TextButton(
                        onPressed: () => _withdrawLicense(model),
                        child: const Text('Withdraw license consent',
                            style: TextStyle(fontSize: 11)),
                      )
                    : TextButton(
                        onPressed: () => _acceptLicense(model),
                        child: Text(
                            isDownloaded
                                ? 'Review license to enable'
                                : 'Review license',
                            style: const TextStyle(fontSize: 11)),
                      ),
              ),
            if (isDownloading || isPaused)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: LinearProgressIndicator(
                  value: progress,
                  color: isPaused ? Colors.grey : null,
                ),
              ),
          ],
        ),
        trailing: isDownloading
            ? IconButton(
                icon: const Icon(Icons.pause,
                    size: 20, semanticLabel: 'Pause download'),
                onPressed: () {
                  OcrModelManager.cancelDownload(model);
                  setState(() {
                    _downloading.remove(model.id);
                  });
                },
              )
            : isDownloaded
                ? IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, semanticLabel: 'Delete model'),
                    onPressed: () => _delete(model),
                  )
                : IconButton(
                    icon: Icon(isPaused ? Icons.play_arrow : Icons.download,
                        size: 20,
                        semanticLabel:
                            isPaused ? 'Resume download' : 'Download model'),
                    onPressed: () => _download(model),
                  ),
      ),
    );
  }
}
