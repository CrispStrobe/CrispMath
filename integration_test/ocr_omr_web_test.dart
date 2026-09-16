import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:crisp_math/engine/ocr_model_catalog.dart';
import 'package:crisp_math/engine/ocr_wasm_bridge.dart';
import 'package:crisp_math/widgets/drawing_canvas.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('WASM OCR (OMR) E2E: fetch model, draw minus sign, recognize', (tester) async {
    // 1. Init WASM Module
    final ok = await CrispEmbedOcrWasm.initModule();
    expect(ok, isTrue, reason: 'WASM module should initialize');

    // 2. Download tiny model (pix2tex-mfr-q4_k is ~17MB)
    final variant = OcrModelCatalog.printedMath.first; // pix2tex-mfr-q4k
    final uri = Uri.parse(variant.url);
    final response = await http.get(uri);
    expect(response.statusCode, 200, reason: 'Should download model successfully');
    
    // 3. Load model
    final ocr = CrispEmbedOcrWasm.loadModel(
      response.bodyBytes,
      modelName: variant.filename,
      nThreads: 1,
    );
    expect(ocr, isNotNull, reason: 'Model should load successfully in WASM');

    // 4. Create drawing canvas, draw a minus sign
    final key = GlobalKey<DrawingCanvasState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: DrawingCanvas(key: key, width: 384, height: 384),
          ),
        ),
      ),
    );

    final center = tester.getCenter(find.byType(DrawingCanvas));
    // Draw a horizontal line representing a minus sign
    await tester.timedDragFrom(
      center - const Offset(50, 0),
      const Offset(100, 0),
      const Duration(milliseconds: 200),
    );
    await tester.pumpAndSettle();

    // 5. Get grayscale bytes
    final bytes = await key.currentState!.toGrayscaleBytes(384, 384);
    expect(bytes, isNotNull, reason: 'toGrayscaleBytes should not fail on web');
    expect(bytes!.length, 384 * 384);

    // 6. Convert Uint8List to Float32List [0..1] as WASM API requires
    final pixels = Float32List(bytes.length);
    for (int i = 0; i < bytes.length; i++) {
      pixels[i] = bytes[i] / 255.0;
    }

    // 7. Recognize
    final result = ocr!.recognizeGray(pixels, 384, 384);
    expect(result, isNotNull, reason: 'Recognition should return a string (even if empty)');
    // Just verifying it doesn't crash and returns some LaTeX (e.g., '-')
    print('OCR Result: $result');

    ocr.dispose();
  });
}
