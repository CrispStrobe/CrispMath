/// Evidence recorded by the computation, before display rounding.
/// Unknown precision stays unknown; an integer-looking approximation is never
/// promoted to an exact answer.
enum ResultAccuracy { exact, approximate, symbolic, unknown, unsupported }

enum ComputationMethod {
  integerArithmetic,
  polynomialIntegration,
  polynomialExpansion,
  rationalIntegration,
  integrationRules,
  fundamentalTheorem,
  simpsonIntegration,
  numericFallback,
  symbolicEvaluation,
  simplification,
  calendar,
  unitConversion,
}

class ResultEvidence {
  const ResultEvidence(this.accuracy, this.method, {this.unchanged = false});
  final ResultAccuracy accuracy;
  final ComputationMethod method;
  final bool unchanged;

  Map<String, dynamic> toJson() => {
        'accuracy': accuracy.name,
        'method': method.name,
        if (unchanged) 'unchanged': true,
      };

  static ResultEvidence? fromJson(dynamic value) {
    if (value is! Map) return null;
    final accuracy = ResultAccuracy.values
        .where((item) => item.name == value['accuracy'])
        .firstOrNull;
    final method = ComputationMethod.values
        .where((item) => item.name == value['method'])
        .firstOrNull;
    if (accuracy == null || method == null) return null;
    return ResultEvidence(accuracy, method,
        unchanged: value['unchanged'] == true);
  }
}

class ComputedResult {
  const ComputedResult(this.value, this.evidence);
  final String value;
  final ResultEvidence? evidence;
  Map<String, dynamic> toJson() => {
        'value': value,
        if (evidence != null) 'evidence': evidence!.toJson(),
      };
  factory ComputedResult.fromJson(Map<String, dynamic> json) => ComputedResult(
      json['value'] as String, ResultEvidence.fromJson(json['evidence']));
}
