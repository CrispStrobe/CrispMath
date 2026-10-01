import 'package:flutter/material.dart';
import '../localization/workflow_localizations.dart';

class NotepadActivity extends StatelessWidget {
  const NotepadActivity(
      {super.key,
      required this.busy,
      required this.failed,
      required this.onRetry});
  final bool busy, failed;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final t = WorkflowLocalizations.of(context);
    return Semantics(
        liveRegion: true,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (busy) const LinearProgressIndicator(),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(children: [
                Expanded(
                    child: Text(t.text(busy
                        ? WorkflowLabel.updatingResults
                        : WorkflowLabel.resultsFailed))),
                if (failed && !busy)
                  TextButton(
                      onPressed: onRetry,
                      child: Text(t.text(WorkflowLabel.retry))),
              ])),
        ]));
  }
}
