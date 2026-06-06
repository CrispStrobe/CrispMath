// lib/engine/ocr_providers_init.dart
//
// Registers available OCR providers at app startup.
// Called from main.dart after platform init.

import 'dart:typed_data';

import 'package:crispembed/crispembed.dart'
    show CrispEmbedOcr, CrispEmbedHmerOcr, CrispEmbedBttrOcr;

import 'ocr_cloud_llm.dart';
import 'ocr_provider.dart';
import 'ocr_model_manager.dart';

/// CrispEmbed-backed OCR provider. Wraps the native library.
class _CrispEmbedProvider implements OcrProvider {
  final String _modelPath;
  CrispEmbedOcr? _ocr;

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

      // Call the native OCR
      final latex = _ocr!.recognizeGray(gray, width, height);
      if (latex == null || latex.isEmpty) return null;

      // Convert to engine syntax (handles BPE markers, spaced braces, etc.)
      final engineSyntax = latexToEngineSyntax(latex);

      return OcrResult(
        text: engineSyntax,
        rawOutput: latex.replaceAll('\u0120', ' ').trim(),
        providerName: name,
      );
    } catch (e) {
      return null;
    }
  }

  CrispEmbedOcr? _initOcr() {
    try {
      return CrispEmbedOcr(_modelPath, nThreads: 4);
    } catch (e) {
      // Native lib not available on this platform — graceful fallback
      return null;
    }
  }
}

/// CrispEmbed HMER provider for handwritten math.
class _CrispEmbedHmerProvider implements OcrProvider {
  final String _modelPath;
  CrispEmbedHmerOcr? _ocr;

  _CrispEmbedHmerProvider(this._modelPath);

  @override
  String get name => 'CrispEmbed HMER (handwritten)';

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
      _ocr ??= _initOcr();
      if (_ocr == null) return null;

      // Convert to grayscale. The C++ layer auto-detects image polarity
      // and inverts if needed (black-on-white → white-on-black).
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

      final latex = _ocr!.recognizeGray(gray, width, height);
      if (latex == null || latex.isEmpty) return null;

      final engineSyntax = latexToEngineSyntax(latex.trim());
      return OcrResult(
        text: engineSyntax,
        rawOutput: latex.trim(),
        providerName: name,
      );
    } catch (e) {
      return null;
    }
  }

  CrispEmbedHmerOcr? _initOcr() {
    try {
      return CrispEmbedHmerOcr(_modelPath, nThreads: 4);
    } catch (e) {
      return null;
    }
  }
}

/// CrispEmbed BTTR provider for handwritten math (better accuracy).
class _CrispEmbedBttrProvider implements OcrProvider {
  final String _modelPath;
  CrispEmbedBttrOcr? _ocr;

  _CrispEmbedBttrProvider(this._modelPath);

  @override
  String get name => 'CrispEmbed BTTR (handwritten)';

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
      _ocr ??= _initOcr();
      if (_ocr == null) return null;

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

      final latex = _ocr!.recognizeGray(gray, width, height);
      if (latex == null || latex.isEmpty) return null;

      final engineSyntax = latexToEngineSyntax(latex.trim());
      return OcrResult(
        text: engineSyntax,
        rawOutput: latex.trim(),
        providerName: name,
      );
    } catch (e) {
      return null;
    }
  }

  CrispEmbedBttrOcr? _initOcr() {
    try {
      return CrispEmbedBttrOcr(_modelPath, nThreads: 4);
    } catch (e) {
      return null;
    }
  }
}

/// Try to register available OCR providers in priority order.
/// Called once at app startup.
Future<void> initOcrProviders() async {
  // Tier 5: On-device handwritten math (BTTR preferred, HMER fallback)
  for (final model in OcrModelCatalog.handwrittenMath) {
    final path = await OcrModelManager.localPath(model);
    if (path != null) {
      OcrProvider provider;
      if (model.id.startsWith('bttr-')) {
        provider = _CrispEmbedBttrProvider(path);
      } else if (model.id.startsWith('hmer-')) {
        provider = _CrispEmbedHmerProvider(path);
      } else {
        continue;
      }
      OcrProviders.register(provider);
      break; // use first available handwritten model
    }
  }

  // Tier 4: On-device CrispEmbed (printed math)
  for (final model in OcrModelCatalog.printedMath) {
    final path = await OcrModelManager.localPath(model);
    if (path != null) {
      final provider = _CrispEmbedProvider(path);
      OcrProviders.register(provider);
      OcrProviders.active = provider;
      break;
    }
  }

  // Tier 3: Cloud LLM (handwritten + printed, requires API key)
  final cloudProvider = CloudLlmOcrProvider();
  OcrProviders.register(cloudProvider);
  // If no on-device model available but cloud is configured, use cloud.
  if (OcrProviders.active == null && cloudProvider.isAvailable) {
    OcrProviders.active = cloudProvider;
  }
}

/// Check if OCR is ready to use.
bool get isOcrAvailable => OcrProviders.active != null;
