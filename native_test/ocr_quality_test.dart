// Explicit scored native corpus; missing dependencies fail, never skip.
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:crispembed/crispembed.dart';
import 'package:image/image.dart' as img;
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/ocr_providers_init.dart';
import 'package:crisp_math/engine/ocr_provider.dart';
import '../tool/inference_quality.dart';

void main() {
  test('score real OCR across fonts, variations and human handwriting', () {
    final model = Platform.environment['CRISPMATH_OCR_MODEL'];
    final library = Platform.environment['CRISPMATH_OCR_LIBRARY'];
    expect(model, isNotNull);
    expect(library, isNotNull);
    expect(File(model!).existsSync(), isTrue);
    expect(File(library!).existsSync(), isTrue);
    final directory = Directory(Platform.environment['CRISPMATH_OCR_CORPUS'] ??
        '.dart_tool/inference/ocr-corpus');
    final manifest =
        jsonDecode(File('${directory.path}/manifest.json').readAsStringSync())
            as Map;
    final expected = jsonDecode(
        File('test/fixtures/ocr/quality_cases.json').readAsStringSync());
    expect(manifest['cases'], expected,
        reason: 'Generated corpus must match committed ground truth.');
    final records = <Map<String, Object?>>[];
    final report = File(Platform.environment['CRISPMATH_OCR_REPORT'] ??
        '.dart_tool/inference/ocr-quality.json');
    report.parent.createSync(recursive: true);
    final ocr = CrispEmbedOcr(model, libPath: library, nThreads: 2);
    try {
      for (final item in manifest['cases'] as List) {
        final example = Map<String, dynamic>.from(item as Map);
        final watch = Stopwatch()..start();
        Map<String, Object?> record;
        try {
          final image = img.decodePng(
              File('${directory.path}/${example['image']}').readAsBytesSync())!;
          final pixels = image.getBytes(order: img.ChannelOrder.rgba);
          final latex = ocr.recognizeGray(
                  toGrayscaleForIsolate(pixels, image.width, image.height),
                  image.width,
                  image.height) ??
              '';
          final expression = latexToEngineSyntax(latex);
          record = scoreOcr(example, latex, expression,
              calculatorResult: example['probes'] == null
                  ? CalculatorEngine().evaluate(expression)
                  : null);
        } catch (error) {
          record = {
            'id': example['id'],
            'kind': example['kind'],
            'status': 'runtime_failure',
            'error': '$error'
          };
        }
        record['elapsed_ms'] = watch.elapsedMilliseconds;
        records.add(record);
        report.writeAsStringSync(const JsonEncoder.withIndent('  ').convert({
          'measured_at': DateTime.now().toUtc().toIso8601String(),
          'model_sha256':
              '8957d1ec5d1f5983fbdd5f6e819203d7c32079f379563eb61f518221c8c5bdd6',
          'threads': 2,
          'corpus': manifest,
          'outcomes': countOutcomes(records),
          'cases': records,
        }));
        stdout.writeln('${example['id']}: ${record['status']}');
      }
    } finally {
      ocr.dispose();
    }
    expect(records, hasLength((expected as List).length));
    expect(countOutcomes(records)['correct'] ?? 0, greaterThan(0));
    expect(countOutcomes(records)['runtime_failure'] ?? 0, 0);
    stdout.writeln('Real OCR quality: ${jsonEncode(countOutcomes(records))}');
  }, timeout: const Timeout(Duration(minutes: 15)));
}
