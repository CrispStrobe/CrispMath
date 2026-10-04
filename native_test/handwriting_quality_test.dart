import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:crispembed/crispembed.dart';
import 'package:crisp_math/engine/ocr_provider.dart';
import 'package:crisp_math/engine/ocr_providers_init.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

String exactTokens(String latex) =>
    latex.replaceAll('\u0120', ' ').replaceAll(RegExp(r'\s+'), '');

void main() {
  test('measure 50 real handwriting test drawings without cherry-picking', () {
    final model = Platform.environment['CRISPMATH_OCR_MODEL']!;
    final library = Platform.environment['CRISPMATH_OCR_LIBRARY']!;
    final directory = Platform.environment['CRISPMATH_HANDWRITING_CORPUS'] ??
        '.dart_tool/inference/handwriting-corpus';
    final manifest =
        jsonDecode(File('$directory/manifest.json').readAsStringSync()) as Map;
    final encoderArm =
        Platform.environment['CRISPMATH_HANDWRITING_ENCODER'] ?? 'default';
    expect(encoderArm, anyOf('default', 'scalar'));
    final scalarFlag = Platform.environment['POSFORMER_SCALAR_ENCODER'];
    if (encoderArm == 'scalar') {
      expect(scalarFlag, '1');
      expect(File(model).uri.pathSegments.last, 'posformer-q8.gguf');
    } else {
      // The pinned PosFormer implementation checks presence, including "0".
      expect(scalarFlag, isNull);
    }
    expect(manifest['split'], 'test');
    expect(manifest['cases'], hasLength(50));
    final hash = sha256.convert(File(model).readAsBytesSync()).toString();
    expect(hash, Platform.environment['CRISPMATH_OCR_SHA256']);
    final records = <Map<String, dynamic>>[];
    final libraryHash = sha256.convert(File(library).readAsBytesSync()).toString();
    final ocr = CrispEmbedOcr(model, libPath: library, nThreads: 2);
    final report = File(Platform.environment['CRISPMATH_HANDWRITING_REPORT']!);
    report.parent.createSync(recursive: true);
    void write() =>
        report.writeAsStringSync(const JsonEncoder.withIndent('  ').convert({
          'model_sha256': hash,
          'model': File(model).uri.pathSegments.last,
          'source': Platform.environment['GITHUB_SHA'],
          'bridge_source': Platform.environment['CRISPMATH_OCR_BRIDGE_SOURCE'],
          'bridge_patch_sha256':
              Platform.environment['CRISPMATH_OCR_BRIDGE_PATCH_SHA256'],
          'library_sha256': libraryHash,
          'encoder_arm': encoderArm,
          'encoder_environment': {'POSFORMER_SCALAR_ENCODER': scalarFlag},
          'corpus_manifest_sha256': sha256
              .convert(File('$directory/manifest.json').readAsBytesSync())
              .toString(),
          'corpus': manifest,
          'threads': 2,
          'measured_at': DateTime.now().toUtc().toIso8601String(),
          'scoring':
              'Exact LaTeX tokens after whitespace/BPE separator removal; equivalent alternate transcriptions are not exact matches.',
          'exact_matches':
              records.where((r) => r['status'] == 'exact_match').length,
          'runtime_failures':
              records.where((r) => r['status'] == 'runtime_failure').length,
          'cases': records,
        }));
    try {
      for (final item in manifest['cases']) {
        final record = <String, dynamic>{
          'id': item['id'],
          'reference_latex': item['reference_latex']
        };
        final watch = Stopwatch()..start();
        try {
          final bytes = File('$directory/${item['image']}').readAsBytesSync();
          record['image_sha256'] = sha256.convert(bytes).toString();
          final image = img.decodePng(bytes)!;
          record['image_width'] = image.width;
          record['image_height'] = image.height;
          final latex = ocr.recognizeGray(
                  toGrayscaleForIsolate(
                      image.getBytes(order: img.ChannelOrder.rgba),
                      image.width,
                      image.height),
                  image.width,
                  image.height) ??
              '';
          record['latex'] = latex;
          record['expression'] = latexToEngineSyntax(latex);
          record['status'] =
              exactTokens(latex) == exactTokens(item['reference_latex'])
                  ? 'exact_match'
                  : 'different_transcription';
        } catch (error) {
          record['status'] = 'runtime_failure';
          record['error'] = '$error';
        }
        record['elapsed_ms'] = watch.elapsedMilliseconds;
        records.add(record);
        write();
      }
    } finally {
      ocr.dispose();
    }
    expect(records, hasLength(50));
    expect(records.where((r) => r['status'] == 'runtime_failure'), isEmpty);
    stdout.writeln(
        'Measured exact matches: ${records.where((r) => r['status'] == 'exact_match').length}/50. This exploratory measurement is not a reliability guarantee.');
  }, timeout: const Timeout(Duration(minutes: 20)));
}
