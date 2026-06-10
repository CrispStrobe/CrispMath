// lib/engine/ocr_providers_init_web.dart
//
// Web implementation of OCR provider registration.
// Uses CrispEmbed compiled to WASM for on-device math OCR in the browser.
// Selected via conditional import when dart.library.js_interop is available.

import 'dart:typed_data';

import 'ocr_cloud_llm_web.dart';
import 'ocr_model_catalog.dart';
import 'ocr_model_manager_web.dart';
import 'ocr_provider.dart';
import 'ocr_wasm_bridge.dart';

/// Grayscale conversion (same logic as ocr_providers_init.dart).
Float32List _toGrayscale(Uint8List imageBytes, int width, int height) {
  final channels = imageBytes.length ~/ (width * height);
  final gray = Float32List(width * height);
  for (var i = 0; i < width * height; i++) {
    if (channels == 1) {
      gray[i] = imageBytes[i] / 255.0;
    } else if (channels >= 3) {
      final base = i * channels;
      gray[i] =
          (0.299 * imageBytes[base] +
              0.587 * imageBytes[base + 1] +
              0.114 * imageBytes[base + 2]) /
          255.0;
    }
  }
  return gray;
}

/// WASM-backed OCR provider for web.
class _WasmOcrProvider implements OcrProvider {
  final OcrModelVariant _model;
  CrispEmbedOcrWasm? _ocr;
  bool _modelLoading = false;

  _WasmOcrProvider(this._model);

  @override
  String get name => '${_model.name} (WASM)';

  @override
  bool get isAvailable => CrispEmbedOcrWasm.isAvailable;

  @override
  bool get requiresNetwork => false;

  @override
  bool get requiresApiKey => false;

  @override
  Future<OcrResult?> recognize(
    Uint8List imageBytes,
    int width,
    int height,
  ) async {
    try {
      if (_ocr == null && !_modelLoading) {
        _modelLoading = true;
        _ocr = await _loadModel();
        _modelLoading = false;
      }
      if (_ocr == null) return null;

      final gray = _toGrayscale(imageBytes, width, height);
      final latex = _ocr!.recognizeGray(gray, width, height);
      if (latex == null || latex.isEmpty) return null;

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

  Future<CrispEmbedOcrWasm?> _loadModel() async {
    // Check IndexedDB cache first.
    var bytes = await OcrModelManagerWeb.getModelBytes(_model);

    if (bytes == null) {
      // Download the model.
      bytes = await OcrModelManagerWeb.download(_model);
      if (bytes == null) return null;
    }

    return CrispEmbedOcrWasm.loadModel(
      bytes,
      modelName: _model.filename,
      nThreads: 1,
    );
  }
}

/// Initialize OCR providers for web.
Future<void> initOcrProviders() async {
  // Initialize the WASM module first.
  final wasmReady = await CrispEmbedOcrWasm.initModule();

  if (wasmReady) {
    // Register the smallest printed math model for web.
    // Users can download larger models from settings.
    final webModels = OcrModelCatalog.printedMath
        .where((m) => m.sizeBytes <= 30 * 1024 * 1024)
        .toList();

    if (webModels.isNotEmpty) {
      final provider = _WasmOcrProvider(webModels.first);
      OcrProviders.register(provider);
      OcrProviders.active = provider;
    }

    // Also register Texo if available.
    final texoModels = OcrModelCatalog.printedMathTexo
        .where((m) => m.sizeBytes <= 30 * 1024 * 1024)
        .toList();
    for (final model in texoModels) {
      OcrProviders.register(_WasmOcrProvider(model));
    }

    // Register handwritten models too.
    final hwModels = OcrModelCatalog.handwrittenMath
        .where((m) => m.sizeBytes <= 15 * 1024 * 1024)
        .toList();
    for (final model in hwModels) {
      OcrProviders.register(_WasmOcrProvider(model));
    }
  }

  // Cloud LLM fallback (web-compatible, uses browser fetch API).
  final cloudProvider = CloudLlmOcrProviderWeb();
  OcrProviders.register(cloudProvider);
  if (OcrProviders.active == null && cloudProvider.isAvailable) {
    OcrProviders.active = cloudProvider;
  }
}

/// Check if OCR is ready to use on web.
bool get isOcrAvailable => OcrProviders.active != null;
