import 'package:crisp_math/engine/numeric_fallback.dart';

/// Quality is scored separately from provider/recognition availability.
/// Ground truth is fixed in the corpus, never generated from model output.
Map<String, Object?> scoreTranslation(
    Map<String, dynamic> example, String expression, String result) {
  final record = <String, Object?>{
    'id': example['id'],
    'input': example['input'],
    'expression': expression,
    'result': result,
  };
  if (example['clarification'] == true) {
    final asks = RegExp(r'\?|\b(?:clarify|provide|specify|which|what|need)\b',
            caseSensitive: false)
        .hasMatch(expression);
    return {
      ...record,
      'status': asks ? 'correct_clarification' : 'incorrect_translation',
      'reason': asks
          ? 'Requested missing information.'
          : 'Invented an expression for an underspecified question.',
    };
  }
  final expected = (example['expected'] as num).toDouble();
  if (double.tryParse(expression.trim()) != null) {
    return {
      ...record,
      'status': 'incorrect_translation',
      'expected': expected,
      'reason': 'Returned a calculated answer instead of an expression.',
    };
  }
  if (result.startsWith('Error')) {
    return {...record, 'status': 'invalid_expression', 'expected': expected};
  }
  final actual = NumericFallbackEvaluator.evalNumeric(result, {});
  final correct = actual != null &&
      actual.isFinite &&
      (actual - expected).abs() <= 1e-8 * (1 + expected.abs());
  return {
    ...record,
    'status': correct ? 'correct' : 'incorrect_translation',
    'expected': expected,
    'actual': actual != null && actual.isFinite ? actual : null,
  };
}

Map<String, Object?> scoreOcr(
    Map<String, dynamic> example, String latex, String expression,
    {String? calculatorResult}) {
  final record = <String, Object?>{
    'id': example['id'],
    'kind': example['kind'],
    'recognized_latex': latex,
    'expression': expression,
    if (calculatorResult != null) 'calculator_result': calculatorResult,
  };
  if (latex.trim().isEmpty) {
    return {...record, 'status': 'recognition_failure'};
  }
  final List probes = example['probes'] as List? ??
      [
        {'scope': <String, double>{}, 'expected': example['expected']}
      ];
  final actuals = <double?>[];
  var correct = true;
  var evaluable = true;
  for (final probe in probes) {
    final scope = (probe['scope'] as Map).map(
        (key, value) => MapEntry(key as String, (value as num).toDouble()));
    final actual = NumericFallbackEvaluator.evalNumeric(
        calculatorResult ?? expression, scope);
    final expected = (probe['expected'] as num).toDouble();
    final finite = actual != null && actual.isFinite;
    actuals.add(finite ? actual : null);
    evaluable &= finite;
    correct &=
        finite && (actual - expected).abs() <= 1e-8 * (1 + expected.abs());
  }
  return {
    ...record,
    'actuals': actuals,
    'status': !evaluable
        ? 'invalid_expression'
        : correct
            ? 'correct'
            : 'incorrect_recognition'
  };
}

Map<String, int> countOutcomes(Iterable<Map<String, Object?>> records) {
  final counts = <String, int>{};
  for (final record in records) {
    final status = record['status'] as String;
    counts[status] = (counts[status] ?? 0) + 1;
  }
  return counts;
}
