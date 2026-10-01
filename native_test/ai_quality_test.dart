// Explicit real-provider evaluation. Missing configuration fails, never skips.
import 'dart:convert';
import 'dart:io';

import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/services/ai_provider_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/inference_quality.dart';

void main() {
  test('score configured real model against the committed translation corpus',
      () async {
    final endpoint = Platform.environment['CRISPMATH_AI_ENDPOINT'];
    final model = Platform.environment['CRISPMATH_AI_MODEL'];
    expect(endpoint, isNotNull, reason: 'Set CRISPMATH_AI_ENDPOINT.');
    expect(model, isNotNull, reason: 'Set CRISPMATH_AI_MODEL.');
    final settings = AiProviderConfig(
        endpoint: endpoint!,
        model: model!,
        apiKey: Platform.environment['CRISPMATH_AI_KEY'] ?? '');
    expect(settings.configured, isTrue);
    final service = ProviderAiService(config: () => settings);
    final engine = CalculatorEngine();
    final corpus = jsonDecode(File('test/fixtures/ai/translation_quality.json')
        .readAsStringSync()) as List;
    final records = <Map<String, Object?>>[];
    final report = File(Platform.environment['CRISPMATH_AI_REPORT'] ??
        '.dart_tool/inference/ai-quality.json');
    report.parent.createSync(recursive: true);
    void save() {
      report.writeAsStringSync(const JsonEncoder.withIndent('  ').convert({
        'measured_at': DateTime.now().toUtc().toIso8601String(),
        'model': model,
        'provider_host': Uri.parse(endpoint).host,
        'provider_path': Uri.parse(endpoint).path,
        'max_tokens': 512,
        'temperature': 'provider default',
        'fixture_provider': false,
        'outcomes': countOutcomes(records),
        'cases': records,
      }));
    }

    for (final item in corpus) {
      final example = Map<String, dynamic>.from(item as Map);
      final watch = Stopwatch()..start();
      Map<String, Object?> record;
      String? expression;
      try {
        expression = await service.processMathNLP(example['input'] as String);
        record = {};
      } on AiClarificationRequired catch (error) {
        expression = error.question;
        record = {};
      } catch (error) {
        record = {
          'id': example['id'],
          'input': example['input'],
          'status': 'provider_failure',
          'error': '$error',
        };
      }
      if (expression != null) {
        try {
          final result = example['clarification'] == true
              ? ''
              : engine.evaluate(expression);
          record = scoreTranslation(example, expression, result);
        } catch (error) {
          record = {
            'id': example['id'],
            'input': example['input'],
            'expression': expression,
            'status': 'engine_failure',
            'error': '$error'
          };
        }
      }
      record['elapsed_ms'] = watch.elapsedMilliseconds;
      records.add(record);
      save();
      stdout.writeln('${example['id']}: ${record['status']}');
    }
    final counts = countOutcomes(records);
    expect(records, hasLength(corpus.length));
    expect(counts['correct'] ?? 0, greaterThan(0),
        reason: 'A real model must produce at least one usable translation.');
    stdout.writeln('Real model quality: ${jsonEncode(counts)}');
    // Semantic accuracy is reported, not disguised as a transport success gate.
  }, timeout: const Timeout(Duration(minutes: 15)));
}
