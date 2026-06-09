// lib/engine/ocr_model_manager.dart
//
// Manages OCR model download + storage for on-device math OCR.
// Models are GGUF files hosted on HuggingFace, downloaded on first
// use into the app's documents directory.
//
// Follows the same pattern as CrisperWeaver's ModelService:
// - HuggingFace resolve URLs
// - Progress callback for UI
// - SHA256 verification (optional)
// - Automatic cleanup of old versions

import 'dart:io';

/// A downloadable OCR model variant.
class OcrModelVariant {
  final String id;
  final String name;
  final String filename;
  final String url;
  final int sizeBytes;
  final String description;

  /// License string (e.g. 'MIT', 'CC BY-NC-SA 3.0'). If non-null and
  /// contains 'NC', the download UI should show an acceptance gate.
  final String? license;

  const OcrModelVariant({
    required this.id,
    required this.name,
    required this.filename,
    required this.url,
    required this.sizeBytes,
    required this.description,
    this.license,
  });

  /// Whether the model requires the user to accept NC license terms.
  bool get requiresLicenseAcceptance =>
      license != null && license!.contains('NC');

  String get sizeLabel {
    if (sizeBytes >= 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(0)} MB';
  }
}

/// Registry of available OCR models.
class OcrModelCatalog {
  static const String _hfBaseUrl =
      'https://huggingface.co/cstr/pix2tex-mfr-gguf/resolve/main';

  static const List<OcrModelVariant> printedMath = [
    OcrModelVariant(
      id: 'pix2tex-mfr-q4k',
      name: 'Math OCR (tiny)',
      filename: 'pix2tex-mfr-q4_k.gguf',
      url: '$_hfBaseUrl/pix2tex-mfr-q4_k.gguf',
      sizeBytes: 17 * 1024 * 1024,
      description: 'Printed math recognition. Smallest model, '
          'good for mobile. 17 MB, Q4_K quantization.',
      license: 'MIT',
    ),
    OcrModelVariant(
      id: 'pix2tex-mfr-q8',
      name: 'Math OCR (balanced)',
      filename: 'pix2tex-mfr-q8_0.gguf',
      url: '$_hfBaseUrl/pix2tex-mfr-q8_0.gguf',
      sizeBytes: 31 * 1024 * 1024,
      description: 'Printed math recognition. Best quality/size '
          'balance for desktop. 31 MB, Q8_0 quantization.',
      license: 'MIT',
    ),
    OcrModelVariant(
      id: 'pix2tex-mfr-f16',
      name: 'Math OCR (full)',
      filename: 'pix2tex-mfr-f16.gguf',
      url: '$_hfBaseUrl/pix2tex-mfr-f16.gguf',
      sizeBytes: 56 * 1024 * 1024,
      description: 'Printed math recognition. Full FP16 precision. '
          '56 MB. Use when accuracy matters more than size.',
      license: 'MIT',
    ),
  ];

  static const String _hfHmerUrl =
      'https://huggingface.co/cstr/hmer-handwritten-math-gguf/resolve/main';

  static const String _hfBttrUrl =
      'https://huggingface.co/cstr/bttr-handwritten-math-gguf/resolve/main';

  static const String _hfPosformerUrl =
      'https://huggingface.co/cstr/posformer-crohme-GGUF/resolve/main';

  static const List<OcrModelVariant> handwrittenMath = [
    // PosFormer (best — ~57% exact match, DenseNet+Transformer+ARM)
    OcrModelVariant(
      id: 'posformer-crohme-q8',
      name: 'PosFormer (best handwritten)',
      filename: 'posformer-crohme-q8_0.gguf',
      url: '$_hfPosformerUrl/posformer-crohme-q8_0.gguf',
      sizeBytes: 12 * 1024 * 1024,
      description: 'Best handwritten math (DenseNet+Transformer+ARM). '
          '12 MB Q8_0. ~57% on CROHME 2014.',
      license: 'CC BY-NC-SA 3.0',
    ),
    OcrModelVariant(
      id: 'posformer-crohme-q4k',
      name: 'PosFormer (mobile)',
      filename: 'posformer-crohme-q4_k.gguf',
      url: '$_hfPosformerUrl/posformer-crohme-q4_k.gguf',
      sizeBytes: 10 * 1024 * 1024,
      description: 'Handwritten math (DenseNet+Transformer+ARM). '
          '10 MB Q4_K. Smallest high-accuracy model.',
      license: 'CC BY-NC-SA 3.0',
    ),
    // BTTR (code: MIT, weights: NC from CROHME training data)
    OcrModelVariant(
      id: 'bttr-hw-q8',
      name: 'Handwritten Math BTTR',
      filename: 'bttr-hw-q8_0.gguf',
      url: '$_hfBttrUrl/bttr-hw-q8_0.gguf',
      sizeBytes: 13 * 1024 * 1024,
      description: 'Handwritten math (DenseNet+Transformer). '
          '13 MB Q8_0. 49% on CROHME.',
      license: 'CC BY-NC-SA 3.0',
    ),
    OcrModelVariant(
      id: 'bttr-hw-q4k',
      name: 'Handwritten Math BTTR (mobile)',
      filename: 'bttr-hw-q4_k.gguf',
      url: '$_hfBttrUrl/bttr-hw-q4_k.gguf',
      sizeBytes: 11 * 1024 * 1024,
      description: 'Handwritten math (DenseNet+Transformer). '
          '11 MB Q4_K. Smaller for mobile.',
      license: 'CC BY-NC-SA 3.0',
    ),
    OcrModelVariant(
      id: 'bttr-hw-f32',
      name: 'Handwritten Math BTTR (full)',
      filename: 'bttr-hw-f32.gguf',
      url: '$_hfBttrUrl/bttr-hw-f32.gguf',
      sizeBytes: 25 * 1024 * 1024,
      description: 'Handwritten math (DenseNet+Transformer). '
          '25 MB F32. Full precision.',
      license: 'CC BY-NC-SA 3.0',
    ),
    // HMER (code: MIT, weights: NC from CROHME training data)
    OcrModelVariant(
      id: 'hmer-hw-q4k',
      name: 'Handwritten Math HMER (tiny)',
      filename: 'hmer-hw-q4_k.gguf',
      url: '$_hfHmerUrl/hmer-hw-q4_k.gguf',
      sizeBytes: 4 * 1024 * 1024,
      description: 'Handwritten math (DenseNet+GRU). '
          '4 MB Q4_K. Smallest model.',
      license: 'CC BY-NC-SA 3.0',
    ),
    OcrModelVariant(
      id: 'hmer-hw-q8',
      name: 'Handwritten Math HMER (balanced)',
      filename: 'hmer-hw-q8_0.gguf',
      url: '$_hfHmerUrl/hmer-hw-q8_0.gguf',
      sizeBytes: 7 * 1024 * 1024,
      description: 'Handwritten math (DenseNet+GRU). '
          '7 MB Q8_0.',
      license: 'CC BY-NC-SA 3.0',
    ),
  ];

  static List<OcrModelVariant> get all => [...printedMath, ...handwrittenMath];
}

/// Manages model download + local storage.
class OcrModelManager {
  /// Returns the local path for a model variant, or null if not downloaded.
  static Future<String?> localPath(OcrModelVariant model) async {
    final dir = await _modelsDir();
    final file = File('${dir.path}/${model.filename}');
    if (await file.exists()) return file.path;
    return null;
  }

  /// Check if a model is downloaded.
  static Future<bool> isDownloaded(OcrModelVariant model) async {
    return await localPath(model) != null;
  }

  /// Download a model. Calls [onProgress] with (received, total) bytes.
  /// Returns the local file path on success, null on failure.
  static Future<String?> download(
    OcrModelVariant model, {
    void Function(int received, int total)? onProgress,
  }) async {
    final dir = await _modelsDir();
    final targetPath = '${dir.path}/${model.filename}';
    final tmpPath = '$targetPath.tmp';

    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(model.url));
      final response = await request.close();

      if (response.statusCode != 200) {
        return null;
      }

      final total = response.contentLength;
      final file = File(tmpPath);
      final sink = file.openWrite();
      int received = 0;

      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(received, total);
      }

      await sink.close();
      await File(tmpPath).rename(targetPath);
      client.close();
      return targetPath;
    } catch (e) {
      // Clean up partial download
      try {
        await File(tmpPath).delete();
      } catch (_) {}
      return null;
    }
  }

  /// Delete a downloaded model.
  static Future<void> delete(OcrModelVariant model) async {
    final path = await localPath(model);
    if (path != null) {
      await File(path).delete();
    }
  }

  /// Total disk space used by downloaded models.
  static Future<int> totalDiskUsage() async {
    final dir = await _modelsDir();
    if (!await dir.exists()) return 0;
    int total = 0;
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.gguf')) {
        total += await entity.length();
      }
    }
    return total;
  }

  static Future<Directory> _modelsDir() async {
    // Use app documents directory + 'ocr_models' subdirectory
    final home = Platform.environment['HOME'] ?? '/tmp';
    final dir = Directory('$home/.crispcalc/ocr_models');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
