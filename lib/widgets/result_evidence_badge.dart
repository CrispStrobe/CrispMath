import 'package:flutter/material.dart';
import '../engine/result_evidence.dart';
import '../localization/workflow_localizations.dart';

class ResultEvidenceBadge extends StatelessWidget {
  const ResultEvidenceBadge(
      {super.key, required this.evidence, this.compact = true});
  final ResultEvidence evidence;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = WorkflowLocalizations.of(context);
    final accuracy = t.text(switch (evidence.accuracy) {
      ResultAccuracy.exact => WorkflowLabel.resultExact,
      ResultAccuracy.approximate => WorkflowLabel.resultApproximate,
      ResultAccuracy.symbolic => WorkflowLabel.resultSymbolic,
      ResultAccuracy.unknown => WorkflowLabel.resultComputed,
      ResultAccuracy.unsupported => WorkflowLabel.resultUnsupported,
    });
    final method = t.text(switch (evidence.method) {
      ComputationMethod.integerArithmetic => WorkflowLabel.methodInteger,
      ComputationMethod.polynomialIntegration => WorkflowLabel.methodPolynomial,
      ComputationMethod.polynomialExpansion =>
        WorkflowLabel.methodExpansionFallback,
      ComputationMethod.rationalIntegration => WorkflowLabel.methodRational,
      ComputationMethod.integrationRules => WorkflowLabel.methodRules,
      ComputationMethod.fundamentalTheorem => WorkflowLabel.methodFundamental,
      ComputationMethod.simpsonIntegration => WorkflowLabel.methodSimpson,
      ComputationMethod.numericFallback => WorkflowLabel.methodNumeric,
      ComputationMethod.symbolicEvaluation => WorkflowLabel.methodSymbolic,
      ComputationMethod.simplification => WorkflowLabel.methodSimplification,
      ComputationMethod.calendar => WorkflowLabel.methodCalendar,
      ComputationMethod.unitConversion => WorkflowLabel.methodUnits,
    });
    Widget details() => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$accuracy · $method'),
              if (evidence.accuracy == ResultAccuracy.unknown)
                Text(t.text(WorkflowLabel.resultUnknownPrecision)),
              if (evidence.sourceDomain != null)
                Text('Original domain: ${evidence.sourceDomain}'),
              if (evidence.unchanged)
                Text(t.text(WorkflowLabel.resultUnchanged)),
            ]);
    if (!compact) return details();
    return TextButton(
      style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          visualDensity: VisualDensity.compact,
          textStyle: const TextStyle(fontSize: 11)),
      onPressed: () => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text(t.text(WorkflowLabel.resultDetails)),
                  content: details(),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(t.text(WorkflowLabel.close)))
                  ])),
      child: Text(
          '$accuracy · $method${evidence.sourceDomain != null ? ' · domain' : ''}'),
    );
  }
}
