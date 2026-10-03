import 'package:flutter/material.dart';
import '../localization/workflow_localizations.dart';

class NotepadActivity extends StatelessWidget {
  const NotepadActivity(
      {super.key,
      required this.busy,
      required this.failed,
      required this.onRetry,
      this.onCancel,
      this.cancelled = false,
      this.completed = 0,
      this.total = 0});
  final bool busy, failed;
  final VoidCallback onRetry;
  final VoidCallback? onCancel;
  final bool cancelled;
  final int completed, total;
  @override
  Widget build(BuildContext context) {
    final t = WorkflowLocalizations.of(context);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (busy)
        LinearProgressIndicator(value: total > 0 ? completed / total : null),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(children: [
            Expanded(
                child: Semantics(
                    container: true,
                    liveRegion: true,
                    child: Text(busy
                        ? t.text(WorkflowLabel.calculationProgress,
                            '$completed / $total')
                        : t.text(cancelled
                            ? WorkflowLabel.calculationStopped
                            : WorkflowLabel.resultsFailed)))),
            if (busy && onCancel != null)
              TextButton(
                  onPressed: onCancel,
                  child: Text(t.text(WorkflowLabel.cancelCalculation))),
            if ((failed || cancelled) && !busy)
              TextButton(
                  onPressed: onRetry, child: Text(t.text(WorkflowLabel.retry))),
          ])),
    ]);
  }
}
