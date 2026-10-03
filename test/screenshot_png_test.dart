import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import '../tool/screenshot_png.dart';

void main() {
  test(
      'opaque screenshot encoding removes alpha without changing pixels or dimensions',
      () {
    final source = image.Image(width: 2, height: 1, numChannels: 4);
    source.setPixelRgba(0, 0, 12, 34, 56, 255);
    source.setPixelRgba(1, 0, 78, 90, 123, 255);
    final bytes = encodeOpaqueScreenshot(image.encodePng(source));
    expect(bytes[25], 2);
    final result = image.decodePng(bytes)!;
    expect([result.width, result.height, result.numChannels], [2, 1, 3]);
    expect(result.getPixel(0, 0).toList(), [12, 34, 56]);
    expect(result.getPixel(1, 0).toList(), [78, 90, 123]);
  });
  test('transparency and invalid captures are rejected', () {
    final source = image.Image(width: 1, height: 1, numChannels: 4);
    source.setPixelRgba(0, 0, 12, 34, 56, 0);
    expect(() => encodeOpaqueScreenshot(image.encodePng(source)),
        throwsFormatException);
    expect(() => encodeOpaqueScreenshot([1, 2, 3]), throwsFormatException);
  });
}
