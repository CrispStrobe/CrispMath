import 'package:flutter/material.dart';
import '../engine/linked_graph.dart';
import '../localization/workflow_localizations.dart';

class LinkedSourceDialog extends StatelessWidget {
  const LinkedSourceDialog(
      {super.key,
      required this.slot,
      required this.source,
      required this.editableVariables,
      required this.onEditVariable,
      required this.onOpenSource,
      required this.onDetach});
  final int slot;
  final LinkedGraphResolution source;
  final Set<String> editableVariables;
  final ValueChanged<String> onEditVariable;
  final VoidCallback onOpenSource, onDetach;
  @override
  Widget build(BuildContext context) {
    final t = WorkflowLocalizations.of(context);
    void act(VoidCallback action) {
      Navigator.pop(context);
      action();
    }

    return AlertDialog(
      title: Text(t.text(WorkflowLabel.linkedSource, '${slot + 1}')),
      content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(source.source),
              Text(t.text(WorkflowLabel.sourceExplanation)),
              for (final entry in source.scope.entries)
                Row(children: [
                  Expanded(child: Text('${entry.key} = ${entry.value}')),
                  if (editableVariables.contains(entry.key))
                    TextButton(
                        onPressed: () => act(() => onEditVariable(entry.key)),
                        child: Text(
                            t.text(WorkflowLabel.editVariable, entry.key))),
                ]),
              if (source.error != null)
                Semantics(
                    liveRegion: true,
                    child: Text(source.error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error))),
            ],
          ))),
      actions: [
        TextButton(
            onPressed: () => act(onDetach),
            child: Text(t.text(WorkflowLabel.detachSource))),
        TextButton(
            onPressed: () => act(onOpenSource),
            child: Text(t.text(WorkflowLabel.openSource))),
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.text(WorkflowLabel.close))),
      ],
    );
  }
}
