// lib/engine/scan_cleanup_native.dart
//
// Native (non-web) scan cleanup: decode JPEG/PNG → raw RGBA via Flutter
// codec, convert to RGB, run CrispScanCleanup (deskew, crop, whiten).

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crispembed/crispembed.dart' show CrispScanCleanup;

/// Thread count for scan cleanup (same heuristic as OCR providers).
final int _cleanupThreads = (Platform.numberOfProcessors ~/ 2).clamp(1, 8);

/// Lazily initialized singleton cleanup instance.
CrispScanCleanup? _scanCleanup;

/// Decode JPEG/PNG [fileBytes] to raw pixels, run scan cleanup
/// (deskew, crop, whiten), return cleaned RGB pixels with dimensions.
/// Returns null if decoding or cleanup fails.
Future<({Uint8List pixels, int width, int height})?> decodeAndCleanup(
    Uint8List fileBytes) async {
  try {
    // Decode to raw RGBA via Flutter image codec.
    final codec = await ui.instantiateImageCodec(fileBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    codec.dispose();
    if (byteData == null) return null;

    final w = image.width;
    final h = image.height;
    image.dispose();
    final rgba = byteData.buffer.asUint8List();

    // Convert RGBA → RGB for scan cleanup (expects 3-channel input).
    final rgb = Uint8List(w * h * 3);
    for (var i = 0; i < w * h; i++) {
      rgb[i * 3] = rgba[i * 4];
      rgb[i * 3 + 1] = rgba[i * 4 + 1];
      rgb[i * 3 + 2] = rgba[i * 4 + 2];
    }

    // Run scan cleanup.
    _scanCleanup ??= CrispScanCleanup(nThreads: _cleanupThreads);
    final cleaned = _scanCleanup!.process(rgb, w, h, channels: 3);
    return (
      pixels: cleaned.pixels,
      width: cleaned.width,
      height: cleaned.height,
    );
  } catch (e) {
    return null; // fall through to OCR on original image
  }
}
