import 'dart:typed_data';
import 'package:image/image.dart' as image;

/// Lossless RGB encoding for an already opaque native capture. No resizing,
/// compositing, or pixel changes: reject actual transparency instead of hiding it.
Uint8List encodeOpaqueScreenshot(List<int> bytes) {
  final decoded = image.decodePng(Uint8List.fromList(bytes));
  if (decoded == null) throw const FormatException('Invalid native PNG');
  if (decoded.any((pixel) => pixel.aNormalized != 1)) {
    throw const FormatException(
        'Native screenshot contains transparent pixels');
  }
  return image.encodePng(decoded.convert(numChannels: 3));
}
