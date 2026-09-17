import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_math/services/ocr_service.dart';

void main() {
  test('OcrService persistent worker boot and error handling', () async {
    // Note: In a test environment, native libraries aren't typically loaded,
    // so we expect it to fail gracefully without crashing the isolate.
    final dummyPixels = Uint8List(4); // tiny 1x1 image, 4 channels
    final op = OcrOp('math_gray', 'dummy/path.gguf', dummyPixels, 1, 1);
    
    final result = await OcrService.recognizeAsync(op);
    
    // We expect null because 'dummy/path.gguf' doesn't exist and native lib isn't loaded.
    // The key is that the isolate didn't crash and returned the handled error.
    expect(result, isNull);
    
    await OcrService.kill();
  });
}
