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

/// Shared grayscale conversion for all on-device OCR providers.
Float32List _toGrayscale(Uint8List imageBytes, int width, int height) {
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
  return gray;
}

/// Generic interface for any CrispEmbed OCR model that has
/// recognizeGray(Float32List, int, int) → String? and dispose().
abstract class _OcrBackend {
  String? recognizeGray(Float32List pixels, int width, int height);
  void dispose();
}

/// Wraps CrispEmbedOcr (printed math — pix2tex / TrOCR).
class _Pix2TexBackend implements _OcrBackend {
  late final CrispEmbedOcr _ocr;
  _Pix2TexBackend(String path) { _ocr = CrispEmbedOcr(path, nThreads: 4); }
  @override
  String? recognizeGray(Float32List p, int w, int h) => _ocr.recognizeGray(p, w, h);
  @override
  void dispose() => _ocr.dispose();
}

/// Wraps CrispEmbedHmerOcr (handwritten math — DenseNet+GRU).
class _HmerBackend implements _OcrBackend {
  late final CrispEmbedHmerOcr _ocr;
  _HmerBackend(String path) { _ocr = CrispEmbedHmerOcr(path, nThreads: 4); }
  @override
  String? recognizeGray(Float32List p, int w, int h) => _ocr.recognizeGray(p, w, h);
  @override
  void dispose() => _ocr.dispose();
}

/// Wraps CrispEmbedBttrOcr (handwritten math — DenseNet+Transformer).
class _BttrBackend implements _OcrBackend {
  late final CrispEmbedBttrOcr _ocr;
  _BttrBackend(String path) { _ocr = CrispEmbedBttrOcr(path, nThreads: 4); }
  @override
  String? recognizeGray(Float32List p, int w, int h) => _ocr.recognizeGray(p, w, h);
  @override
  void dispose() => _ocr.dispose();
}

/// On-device OCR provider backed by CrispEmbed. Works for all model types
/// (pix2tex, HMER, BTTR) — the correct FFI backend is selected by [_factory].
class _CrispEmbedProvider implements OcrProvider {
  final String _modelPath;
  final String _name;
  final _OcrBackend Function(String path) _factory;
  _OcrBackend? _backend;

  _CrispEmbedProvider(this._modelPath, this._name, this._factory);

  @override
  String get name => _name;

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
      _backend ??= _tryInit();
      if (_backend == null) return null;

      final gray = _toGrayscale(imageBytes, width, height);
      final latex = _backend!.recognizeGray(gray, width, height);
      if (latex == null || latex.isEmpty) return null;

      // All models output LaTeX — convert to engine syntax.
      // latexToEngineSyntax handles BPE markers, spaced braces, nested fracs.
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

  _OcrBackend? _tryInit() {
    try {
      return _factory(_modelPath);
    } catch (e) {
      return null;
    }
  }
}

/// Try to register available OCR providers in priority order.
/// Called once at app startup.
Future<void> initOcrProviders() async {
  // Tier 5: On-device handwritten math (BTTR preferred, then HMER)
  for (final model in OcrModelCatalog.handwrittenMath) {
    final path = await OcrModelManager.localPath(model);
    if (path != null) {
      final String label;
      final _OcrBackend Function(String) factory;
      if (model.id.startsWith('bttr-')) {
        label = 'BTTR (handwritten, 53%)';
        factory = (p) => _BttrBackend(p);
      } else if (model.id.startsWith('hmer-')) {
        label = 'HMER (handwritten, 39%)';
        factory = (p) => _HmerBackend(p);
      } else {
        continue;
      }
      OcrProviders.register(_CrispEmbedProvider(path, label, factory));
      break; // use first available handwritten model
    }
  }

  // Tier 4: On-device printed math (pix2tex / TrOCR)
  for (final model in OcrModelCatalog.printedMath) {
    final path = await OcrModelManager.localPath(model);
    if (path != null) {
      final provider = _CrispEmbedProvider(
          path, 'pix2tex (printed)', (p) => _Pix2TexBackend(p));
      OcrProviders.register(provider);
      OcrProviders.active = provider;
      break;
    }
  }

  // Tier 3: Cloud LLM (handwritten + printed, requires API key)
  final cloudProvider = CloudLlmOcrProvider();
  OcrProviders.register(cloudProvider);
  if (OcrProviders.active == null && cloudProvider.isAvailable) {
    OcrProviders.active = cloudProvider;
  }
}

/// Check if OCR is ready to use.
bool get isOcrAvailable => OcrProviders.active != null;
