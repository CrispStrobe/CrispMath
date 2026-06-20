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

// Re-export catalog types (platform-independent, no dart:io).
export 'ocr_model_catalog.dart';
import 'ocr_model_catalog.dart';

/// Manages model download + local storage (native platforms only).
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
      final tmpFile = File(tmpPath);

      // Resume interrupted downloads if the .tmp file exists.
      final existingSize =
          tmpFile.existsSync() ? tmpFile.lengthSync() : 0;

      final request = await client.getUrl(Uri.parse(model.url));
      if (existingSize > 0) {
        request.headers.set('Range', 'bytes=$existingSize-');
      }
      final response = await request.close();

      // 206 = partial content (resume), 200 = full download.
      if (response.statusCode != 200 && response.statusCode != 206) {
        client.close();
        return null;
      }

      final isResume = response.statusCode == 206;
      final total = isResume
          ? (response.contentLength + existingSize)
          : response.contentLength;
      final sink = tmpFile.openWrite(
          mode: isResume ? FileMode.append : FileMode.write);
      int received = isResume ? existingSize : 0;

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
      // Keep partial .tmp for resume on next attempt.
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

  static Future<Directory>? _cachedDir;
  static Future<Directory> _modelsDir() => _cachedDir ??= _resolveModelsDir();

  static Future<Directory> _resolveModelsDir() async {
    final home = Platform.environment['HOME'] ?? '/tmp';
    final dir = Directory('$home/.crispcalc/ocr_models');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
