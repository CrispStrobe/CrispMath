import 'dart:convert';
import 'dart:io';

import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/inference_quality.dart';

void main() {
  test('every numerical reference agrees with independent corpus ground truth',
      () {
    final corpus = jsonDecode(File('test/fixtures/ai/translation_quality.json')
        .readAsStringSync()) as List;
    expect(corpus.map((item) => item['id']).toSet().length, corpus.length);
    final engine = CalculatorEngine();
    for (final item in corpus) {
      final example = Map<String, dynamic>.from(item as Map);
      if (example['clarification'] == true) continue;
      final reference = example['reference'] as String;
      expect(
          scoreTranslation(
              example, reference, engine.evaluate(reference))['status'],
          'correct',
          reason: example['id'] as String);
    }
  });
  test('wrong answers, invalid expressions and provider failures stay distinct',
      () {
    final example = {'id': 'sum', 'input': 'two plus two', 'expected': 4};
    expect(scoreTranslation(example, '2+3', '5')['status'],
        'incorrect_translation');
    expect(
        scoreTranslation(example, '4', '4')['status'], 'incorrect_translation');
    expect(scoreTranslation(example, '2+', 'Error: incomplete')['status'],
        'invalid_expression');
    expect(
        countOutcomes([
          scoreTranslation(example, '2+3', '5'),
          scoreTranslation(example, '2+', 'Error: incomplete'),
          {'status': 'provider_failure'},
        ]),
        {
          'incorrect_translation': 1,
          'invalid_expression': 1,
          'provider_failure': 1
        });
  });
  test('OCR references preserve independent constants and variable probes', () {
    final corpus = jsonDecode(
            File('test/fixtures/ocr/quality_cases.json').readAsStringSync())
        as List;
    expect(corpus.map((item) => item['id']).toSet().length, corpus.length);
    for (final item in corpus) {
      final example = Map<String, dynamic>.from(item as Map);
      expect(
          scoreOcr(
              example, 'reference', example['reference'] as String)['status'],
          'correct',
          reason: example['id'] as String);
    }
    final example = {'id': 'sum', 'expected': 12};
    expect(scoreOcr(example, '', '')['status'], 'recognition_failure');
    expect(scoreOcr(example, '5-7', '5-7')['status'], 'incorrect_recognition');
    expect(scoreOcr(example, 'bad', 'bad')['status'], 'invalid_expression');
    expect(() => jsonEncode(scoreOcr(example, 'bad', '1/0')), returnsNormally);
  });
  test('ambiguous requests require clarification, not a guessed formula', () {
    final example = {
      'id': 'area',
      'input': 'circle area',
      'clarification': true
    };
    expect(scoreTranslation(example, 'What is the radius?', '')['status'],
        'correct_clarification');
    expect(scoreTranslation(example, 'pi*r^2', '')['status'],
        'incorrect_translation');
  });
}
