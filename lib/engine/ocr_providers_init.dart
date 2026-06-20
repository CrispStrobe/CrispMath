// lib/engine/ocr_providers_init.dart
//
// Registers available OCR providers at app startup.
// Called from main.dart after platform init.

import 'dart:io';
import 'dart:typed_data';

import 'package:crispembed/crispembed.dart'
    show CrispEmbedOcr, CrispLayout, CrispOcrPipeline, LayoutRegion;

import 'ocr_cloud_llm.dart';
import 'ocr_provider.dart';
import 'ocr_model_manager.dart';

/// Adaptive thread count based on available cores.
final int _ocrThreads = (Platform.numberOfProcessors ~/ 2).clamp(1, 8);

/// Shared grayscale conversion for all on-device OCR providers.
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

/// Generic interface for any CrispEmbed OCR model that has
/// recognizeGray(Float32List, int, int) → String? and dispose().
abstract class _OcrBackend {
  String? recognizeGray(Float32List pixels, int width, int height);
  void dispose();
}

/// Wraps CrispEmbedOcr (printed math — pix2tex / TrOCR).
class _Pix2TexBackend implements _OcrBackend {
  late final CrispEmbedOcr _ocr;
  _Pix2TexBackend(String path) {
    _ocr = CrispEmbedOcr(path, nThreads: _ocrThreads);
  }
  @override
  String? recognizeGray(Float32List p, int w, int h) =>
      _ocr.recognizeGray(p, w, h);
  @override
  void dispose() => _ocr.dispose();
}

/// Wraps CrispEmbedOcr for handwritten math models (HMER/BTTR).
/// The C++ layer auto-detects model architecture from the GGUF file.
class _HandwrittenBackend implements _OcrBackend {
  late final CrispEmbedOcr _ocr;
  _HandwrittenBackend(String path) {
    _ocr = CrispEmbedOcr(path, nThreads: _ocrThreads);
  }
  @override
  String? recognizeGray(Float32List p, int w, int h) =>
      _ocr.recognizeGray(p, w, h);
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
    Uint8List imageBytes,
    int width,
    int height,
  ) async {
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

/// On-device VLM provider that sends color images directly (no grayscale
/// conversion). VLMs benefit from color cues in diagrams, tables, etc.
class _CrispEmbedVlmProvider implements OcrProvider {
  final String _modelPath;
  final String _name;
  CrispEmbedOcr? _ocr;

  _CrispEmbedVlmProvider(this._modelPath, this._name);

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
    Uint8List imageBytes,
    int width,
    int height,
  ) async {
    try {
      _ocr ??= _tryInit();
      if (_ocr == null) return null;

      final channels = imageBytes.length ~/ (width * height);
      final latex = _ocr!.recognizeRaw(imageBytes, width, height, channels);
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

  CrispEmbedOcr? _tryInit() {
    try {
      return CrispEmbedOcr(_modelPath, nThreads: _ocrThreads);
    } catch (e) {
      return null;
    }
  }
}

/// On-device general OCR provider backed by CrispEmbed (DBNet + TrOCR).
/// Detects text regions in the image, then recognizes each region.
/// Returns all recognized text concatenated with newlines.
class _GeneralOcrProvider implements OcrProvider {
  final String _detPath;
  final String _recPath;
  CrispOcrPipeline? _pipeline;

  _GeneralOcrProvider(this._detPath, this._recPath);

  @override
  String get name => 'General OCR (DBNet+TrOCR)';

  @override
  bool get isAvailable => true;

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
      _pipeline ??= _tryInit();
      if (_pipeline == null) return null;

      // CrispOcrPipeline.run() takes a file path — write to temp file.
      final tmpDir = await Directory.systemTemp.createTemp('ocr_');
      final tmpFile = File('${tmpDir.path}/input.png');
      // Write raw pixels as PPM (simplest uncompressed format).
      final channels = imageBytes.length ~/ (width * height);
      final ppm = _toPpm(imageBytes, width, height, channels);
      await tmpFile.writeAsBytes(ppm);

      final results = _pipeline!.run(tmpFile.path);

      // Cleanup temp file.
      try {
        await tmpDir.delete(recursive: true);
      } catch (_) {}

      if (results.isEmpty) return null;

      final text = results.map((r) => r.text).join(' ');
      return OcrResult(
        text: text,
        rawOutput: text,
        providerName: name,
      );
    } catch (e) {
      return null;
    }
  }

  CrispOcrPipeline? _tryInit() {
    try {
      return CrispOcrPipeline(_detPath, _recPath, nThreads: _ocrThreads);
    } catch (e) {
      return null;
    }
  }
}

/// Layout-aware OCR provider. Runs RT-DETRv2 layout detection on the image,
/// then dispatches math OCR for formula regions and returns region annotations
/// for text/table/figure regions.
class _LayoutOcrProvider implements OcrProvider {
  final String _layoutPath;
  final OcrProvider? _mathProvider;
  CrispLayout? _layout;

  _LayoutOcrProvider(this._layoutPath, this._mathProvider);

  @override
  String get name => 'Layout-aware OCR';

  @override
  bool get isAvailable => true;

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
      _layout ??= _tryInit();
      if (_layout == null) return null;

      // Write image to temp file for CrispLayout (file-based API).
      final channels = imageBytes.length ~/ (width * height);
      final tmpDir = await Directory.systemTemp.createTemp('layout_');
      final tmpFile = File('${tmpDir.path}/input.ppm');
      await tmpFile.writeAsBytes(_toPpm(imageBytes, width, height, channels));

      final regions = _layout!.detect(tmpFile.path, threshold: 0.3);

      // Cleanup temp file.
      try {
        await tmpDir.delete(recursive: true);
      } catch (_) {}

      if (regions.isEmpty) return null;

      final parts = <String>[];

      for (final region in regions) {
        if (_isFormulaRegion(region) && _mathProvider != null) {
          // Crop the formula region and run math OCR on it.
          final cropped = _cropRegion(imageBytes, width, height, channels,
              region.x1.round(), region.y1.round(),
              region.x2.round(), region.y2.round());
          if (cropped != null) {
            final cropW = region.x2.round() - region.x1.round();
            final cropH = region.y2.round() - region.y1.round();
            final mathResult =
                await _mathProvider.recognize(cropped, cropW, cropH);
            if (mathResult != null) {
              parts.add(mathResult.text);
              continue;
            }
          }
        }
        // For non-formula regions, annotate with region type.
        parts.add('[${region.labelName}]');
      }

      if (parts.isEmpty) return null;
      final text = parts.join(' ');
      return OcrResult(
        text: text,
        rawOutput: regions
            .map((r) =>
                '${r.labelName}(${r.x1.toInt()},${r.y1.toInt()}-'
                '${r.x2.toInt()},${r.y2.toInt()} '
                'score=${r.score.toStringAsFixed(2)})')
            .join('; '),
        providerName: name,
      );
    } catch (e) {
      return null;
    }
  }

  CrispLayout? _tryInit() {
    try {
      return CrispLayout(_layoutPath, nThreads: _ocrThreads);
    } catch (e) {
      return null;
    }
  }

  static bool _isFormulaRegion(LayoutRegion r) {
    final name = r.labelName.toLowerCase();
    return name.contains('formula') ||
        name.contains('equation') ||
        name.contains('math');
  }

  /// Crop raw pixel data to a bounding box region.
  static Uint8List? _cropRegion(Uint8List pixels, int srcW, int srcH,
      int channels, int x1, int y1, int x2, int y2) {
    // Clamp to image bounds.
    final cx1 = x1.clamp(0, srcW);
    final cy1 = y1.clamp(0, srcH);
    final cx2 = x2.clamp(0, srcW);
    final cy2 = y2.clamp(0, srcH);
    final cropW = cx2 - cx1;
    final cropH = cy2 - cy1;
    if (cropW <= 0 || cropH <= 0) return null;

    final cropped = Uint8List(cropW * cropH * channels);
    for (var row = 0; row < cropH; row++) {
      final srcOffset = ((cy1 + row) * srcW + cx1) * channels;
      final dstOffset = row * cropW * channels;
      cropped.setRange(
          dstOffset, dstOffset + cropW * channels, pixels, srcOffset);
    }
    return cropped;
  }
}

/// Encode raw RGBA/RGB/Gray pixels as PPM (P6) for CrispEmbed file-based API.
Uint8List _toPpm(Uint8List pixels, int w, int h, int channels) {
  final header = 'P6\n$w $h\n255\n';
  final headerBytes = header.codeUnits;
  final rgb = Uint8List(w * h * 3);
  for (var i = 0; i < w * h; i++) {
    if (channels == 1) {
      rgb[i * 3] = rgb[i * 3 + 1] = rgb[i * 3 + 2] = pixels[i];
    } else if (channels >= 3) {
      final base = i * channels;
      rgb[i * 3] = pixels[base];
      rgb[i * 3 + 1] = pixels[base + 1];
      rgb[i * 3 + 2] = pixels[base + 2];
    }
  }
  final result = Uint8List(headerBytes.length + rgb.length);
  result.setRange(0, headerBytes.length, headerBytes);
  result.setRange(headerBytes.length, result.length, rgb);
  return result;
}

/// Try to register available OCR providers in priority order.
/// Called once at app startup.
Future<void> initOcrProviders() async {
  // Pre-resolve all model paths in parallel (avoids serial File.exists calls).
  final allModels = OcrModelCatalog.all;
  final allPaths = await Future.wait(
      allModels.map((m) => OcrModelManager.localPath(m)));
  final pathMap = <String, String>{};
  for (var i = 0; i < allModels.length; i++) {
    if (allPaths[i] != null) pathMap[allModels[i].id] = allPaths[i]!;
  }

  // Tier 5: On-device handwritten math (BTTR preferred, then HMER)
  for (final model in OcrModelCatalog.handwrittenMath) {
    final path = pathMap[model.id];
    if (path != null) {
      final String label;
      final _OcrBackend Function(String) factory;
      if (model.id.startsWith('posformer-')) {
        label = 'PosFormer (handwritten, 57%)';
        factory = (p) => _HandwrittenBackend(p);
      } else if (model.id.startsWith('bttr-')) {
        label = 'BTTR (handwritten, 49%)';
        factory = (p) => _HandwrittenBackend(p);
      } else if (model.id.startsWith('hmer-')) {
        label = 'HMER (handwritten, 39%)';
        factory = (p) => _HandwrittenBackend(p);
      } else {
        continue;
      }
      OcrProviders.register(_CrispEmbedProvider(path, label, factory));
      break; // use first available handwritten model
    }
  }

  // Tier 4a: On-device printed math — PP-FormulaNet-L (SOTA, Apache-2.0)
  for (final model in OcrModelCatalog.printedMathPpfnl) {
    final path = pathMap[model.id];
    if (path != null) {
      final provider = _CrispEmbedProvider(
        path,
        'PP-FormulaNet-L (printed, 181M)',
        (p) => _Pix2TexBackend(p), // same FFI — auto-detected from GGUF
      );
      OcrProviders.register(provider);
      OcrProviders.active = provider;
      break;
    }
  }

  // Tier 4b: On-device printed math — MixTex (Chinese+English, Apache-2.0)
  for (final model in OcrModelCatalog.printedMathMixtex) {
    final path = pathMap[model.id];
    if (path != null) {
      final provider = _CrispEmbedProvider(
        path,
        'MixTex (Chinese+English)',
        (p) => _Pix2TexBackend(p), // same FFI — auto-detected from GGUF
      );
      OcrProviders.register(provider);
      break;
    }
  }

  // Tier 4d: On-device printed math — Texo-distill (AGPL)
  for (final model in OcrModelCatalog.printedMathTexo) {
    final path = pathMap[model.id];
    if (path != null) {
      final provider = _CrispEmbedProvider(
        path,
        'Texo (printed, BLEU 0.90)',
        (p) => _Pix2TexBackend(p), // same FFI — auto-detected from GGUF
      );
      OcrProviders.register(provider);
      OcrProviders.active = provider;
      break;
    }
  }

  // Tier 4e: On-device printed math — pix2tex / TrOCR (fallback)
  if (OcrProviders.active == null) {
    for (final model in OcrModelCatalog.printedMath) {
      final path = pathMap[model.id];
      if (path != null) {
        final provider = _CrispEmbedProvider(
          path,
          'pix2tex (printed)',
          (p) => _Pix2TexBackend(p),
        );
        OcrProviders.register(provider);
        OcrProviders.active = provider;
        break;
      }
    }
  }

  // Tier 3b: General OCR (text detection + TrOCR recognition)
  // Prefer Surya (91 languages, better accuracy) over DBNet.
  String? detPath;
  String? recPath;
  for (final model in OcrModelCatalog.textDetectionSurya) {
    detPath = pathMap[model.id];
    if (detPath != null) break;
  }
  if (detPath == null) {
    for (final model in OcrModelCatalog.textDetection) {
      detPath = pathMap[model.id];
      if (detPath != null) break;
    }
  }
  for (final model in OcrModelCatalog.textRecognition) {
    recPath = pathMap[model.id];
    if (recPath != null) break;
  }
  if (detPath != null && recPath != null) {
    OcrProviders.register(_GeneralOcrProvider(detPath, recPath));
  }

  // Tier 3a: Layout-aware OCR (RT-DETRv2 + math OCR for formula regions)
  for (final model in OcrModelCatalog.layoutDetection) {
    final layoutPath = pathMap[model.id];
    if (layoutPath != null) {
      // Use the current active math provider for formula region OCR.
      OcrProviders.register(
          _LayoutOcrProvider(layoutPath, OcrProviders.active));
      break;
    }
  }

  // Tier 2a: Qwen3-VL vision-language (desktop only, 1.5–2.2 GB)
  // Preferred over Qwen2.5-VL: smaller (2B vs 3B), faster (fused attn,
  // backend KV cache), and better (DeepStack vision fusion).
  bool hasQwen3vl = false;
  for (final model in OcrModelCatalog.visionLanguageQwen3) {
    final path = pathMap[model.id];
    if (path != null) {
      OcrProviders.register(
          _CrispEmbedVlmProvider(path, 'Qwen3-VL (document OCR, 2B)'));
      hasQwen3vl = true;
      break;
    }
  }

  // Tier 2b: Qwen2.5-VL vision-language (fallback, 2.6–3.9 GB)
  if (!hasQwen3vl) {
    for (final model in OcrModelCatalog.visionLanguage) {
      final path = pathMap[model.id];
      if (path != null) {
        OcrProviders.register(
            _CrispEmbedVlmProvider(path, 'Qwen2.5-VL (document OCR, 3B)'));
        break;
      }
    }
  }

  // Tier 2c: DeepSeek-OCR2 (desktop only, 2.1–6.3 GB)
  for (final model in OcrModelCatalog.deepseekOcr2) {
    final path = pathMap[model.id];
    if (path != null) {
      OcrProviders.register(
          _CrispEmbedVlmProvider(path, 'DeepSeek-OCR2 (MoE, 3B)'));
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
