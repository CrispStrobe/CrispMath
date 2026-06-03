// test/ocr_model_manager_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_calc/engine/ocr_model_manager.dart';

void main() {
  group('OcrModelCatalog', () {
    test('has printed math models', () {
      expect(OcrModelCatalog.printedMath.length, greaterThanOrEqualTo(3));
    });

    test('has handwritten math models', () {
      expect(OcrModelCatalog.handwrittenMath.length, greaterThanOrEqualTo(1));
    });

    test('all models have unique ids', () {
      final ids = OcrModelCatalog.all.map((m) => m.id).toSet();
      expect(ids.length, OcrModelCatalog.all.length);
    });

    test('all models have valid URLs', () {
      for (final m in OcrModelCatalog.all) {
        expect(m.url, startsWith('https://'));
        expect(m.url, contains('huggingface.co'));
        expect(m.url, endsWith('.gguf'));
      }
    });

    test('all models have non-empty filenames', () {
      for (final m in OcrModelCatalog.all) {
        expect(m.filename.isNotEmpty, true);
        expect(m.filename, endsWith('.gguf'));
      }
    });

    test('size labels format correctly', () {
      expect(OcrModelCatalog.printedMath[0].sizeLabel, '17 MB');
      expect(OcrModelCatalog.printedMath[1].sizeLabel, '31 MB');
      expect(OcrModelCatalog.handwrittenMath[0].sizeLabel, '1.2 GB');
    });

    test('Q4_K is the smallest', () {
      final sorted = List.of(OcrModelCatalog.printedMath)
        ..sort((a, b) => a.sizeBytes.compareTo(b.sizeBytes));
      expect(sorted.first.id, contains('q4k'));
    });
  });

  group('OcrModelVariant', () {
    test('properties', () {
      const m = OcrModelVariant(
        id: 'test',
        name: 'Test',
        filename: 'test.gguf',
        url: 'https://example.com/test.gguf',
        sizeBytes: 1024 * 1024,
        description: 'Test model',
      );
      expect(m.sizeLabel, '1 MB');
    });
  });
}
