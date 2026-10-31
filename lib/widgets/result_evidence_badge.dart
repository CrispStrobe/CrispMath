import 'package:flutter/material.dart';
import '../engine/result_evidence.dart';
import '../localization/workflow_localizations.dart';

/// How a result was produced: accuracy, method, and any domain caveat.
///
/// This is reference detail, not chrome. It is shown on demand — from a
/// result's context menu or in the optional history help view — never as
/// a widget attached to every computed line.
class ResultEvidenceBadge extends StatelessWidget {
  const ResultEvidenceBadge({super.key, required this.evidence});
  final ResultEvidence evidence;

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
    return Column(
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
  }
}

/// Opens the on-demand details dialog for [evidence].
Future<void> showResultEvidenceDialog(
    BuildContext context, ResultEvidence evidence) {
  final t = WorkflowLocalizations.of(context);
  return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
              title: Text(t.text(WorkflowLabel.resultDetails)),
              content: ResultEvidenceBadge(evidence: evidence),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(t.text(WorkflowLabel.close)))
              ]));
}
