// lib/engine/ocr_providers_init.dart
//
// Registers available OCR providers at app startup.
// Called from main.dart after platform init.

import 'dart:io';
import 'dart:typed_data';

import 'ocr_provider.dart';
import 'ocr_model_manager.dart';

/// CrispEmbed-backed OCR provider. Wraps the native library.
class _CrispEmbedProvider implements OcrProvider {
  final String _modelPath;
  dynamic _ocr; // CrispEmbedOcr from the plugin (loaded lazily)

  _CrispEmbedProvider(this._modelPath);

  @override
  String get name => 'CrispEmbed (on-device)';

  @override
  bool get isAvailable => true;

  @override
  bool get requiresNetwork => false;

  @override
  bool get requiresApiKey => false;

  @override
  Future<OcrResult?> recognize(
      Uint8List imageBytes, int width, int height) async {
    try {
      // Try to init the native OCR context lazily
      _ocr ??= _initOcr();
      if (_ocr == null) return null;

      // Convert image bytes to grayscale float [0..1]
      final channels = imageBytes.length ~/ (width * height);
      final gray = Float32List(width * height);
      for (var i = 0; i < width * height; i++) {
        if (channels == 1) {
          gray[i] = imageBytes[i] / 255.0;
        } else if (channels >= 3) {
          final base = i * channels;
          gray[i] = (0.299 * imageBytes[base] +
                  0.587 * imageBytes[base + 1] +
                  0.114 * imageBytes[base + 2]) /
              255.0;
        }
      }

      // Call the native OCR (this blocks — should be on an isolate for production)
      final latex = _ocr.recognizeGray(gray, width, height) as String?;
      if (latex == null || latex.isEmpty) return null;

      // Clean BPE space tokens and convert to engine syntax
      final cleaned = latex.replaceAll('\u0120', ' ').trim();
      final engineSyntax = latexToEngineSyntax(cleaned);

      return OcrResult(
        text: engineSyntax,
        rawOutput: cleaned,
        providerName: name,
      );
    } catch (e) {
      return null;
    }
  }

  dynamic _initOcr() {
    try {
      // Import CrispEmbedOcr dynamically — if the native lib isn't
      // present, this throws and we return null.
      // Using the crispembed package's CrispEmbedOcr class.
      // For now, return null until the package is in pubspec.
      return null;
    } catch (_) {
      return null;
    }
  }
}

/// Try to register available OCR providers in priority order.
/// Called once at app startup.
Future<void> initOcrProviders() async {
  // Check if any model is already downloaded
  for (final model in OcrModelCatalog.printedMath) {
    final path = await OcrModelManager.localPath(model);
    if (path != null) {
      // Model available — register the CrispEmbed provider
      final provider = _CrispEmbedProvider(path);
      OcrProviders.register(provider);
      OcrProviders.active = provider;
      break;
    }
  }
}

/// Check if OCR is ready to use.
bool get isOcrAvailable => OcrProviders.active != null;
