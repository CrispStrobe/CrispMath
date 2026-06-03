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

  const OcrModelVariant({
    required this.id,
    required this.name,
    required this.filename,
    required this.url,
    required this.sizeBytes,
    required this.description,
  });

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
    ),
    OcrModelVariant(
      id: 'pix2tex-mfr-q8',
      name: 'Math OCR (balanced)',
      filename: 'pix2tex-mfr-q8_0.gguf',
      url: '$_hfBaseUrl/pix2tex-mfr-q8_0.gguf',
      sizeBytes: 31 * 1024 * 1024,
      description: 'Printed math recognition. Best quality/size '
          'balance for desktop. 31 MB, Q8_0 quantization.',
    ),
    OcrModelVariant(
      id: 'pix2tex-mfr-f16',
      name: 'Math OCR (full)',
      filename: 'pix2tex-mfr-f16.gguf',
      url: '$_hfBaseUrl/pix2tex-mfr-f16.gguf',
      sizeBytes: 56 * 1024 * 1024,
      description: 'Printed math recognition. Full FP16 precision. '
          '56 MB. Use when accuracy matters more than size.',
    ),
  ];

  static const List<OcrModelVariant> handwrittenMath = [
    OcrModelVariant(
      id: 'trocr-hw-math',
      name: 'Handwritten Math OCR',
      filename: 'trocr-math-hw-f16.gguf',
      url: 'https://huggingface.co/cstr/trocr-math-handwritten-gguf/resolve/main/trocr-math-hw-f16.gguf',
      sizeBytes: 1200 * 1024 * 1024,
      description: 'Handwritten math recognition (TrOCR large). '
          '1.2 GB. Desktop only — too large for mobile.',
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
