// lib/engine/scan_cleanup.dart
//
// Scan cleanup preprocessing for camera photos before OCR.
// Decodes JPEG/PNG to raw pixels, applies deskew/crop/whiten via
// CrispEmbed's CrispScanCleanup, returns cleaned RGB pixels.
//
// On web this is a no-op (returns null) since CrispScanCleanup
// requires dart:ffi.

import 'dart:typed_data';

import 'scan_cleanup_stub.dart' if (dart.library.io) 'scan_cleanup_native.dart'
    as impl;

/// Decode JPEG/PNG [fileBytes] to raw pixels, run scan cleanup
/// (deskew, crop, whiten), return cleaned RGB pixels with dimensions.
/// Returns null if cleanup fails or isn't available (web).
Future<({Uint8List pixels, int width, int height})?> decodeAndCleanup(
        Uint8List fileBytes) =>
    impl.decodeAndCleanup(fileBytes);
