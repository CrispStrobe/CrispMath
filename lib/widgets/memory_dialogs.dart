// lib/widgets/memory_dialogs.dart
// Memory management dialogs for storing and retrieving calculator results

import 'package:flutter/material.dart';
import '../engine/app_state.dart';
import '../localization/app_localizations.dart';

class MemoryDialogs {
  static void showStoreDialog(
    BuildContext context,
    AppState appState,
    Map<String, String> memory,
  ) {
    if (appState.history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).memoryNoResultToStore)),
      );
      return;
    }

    // Store the unrounded engine value, not the display string, so a
    // saved variable chains at full precision like `Ans` does.
    final lastResult = appState.history.first.ansValue;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).memoryStoreResultTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context).memoryStorePreview(lastResult)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showSaveAsVariableDialog(context, appState, lastResult);
                    },
                    child: Text(AppLocalizations.of(context).memorySaveAsVariable),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showSaveToMemoryDialog(context, memory, lastResult);
                    },
                    child: Text(AppLocalizations.of(context).memorySaveToMemory),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
        ],
      ),
    );
  }

  static void _showSaveAsVariableDialog(
    BuildContext context,
    AppState appState,
    String value,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).memorySaveAsVariable),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).memoryVariableNameLabel,
                border: const OutlineInputBorder(),
                hintText: AppLocalizations.of(context).memoryVariableNameHint,
              ),
            ),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context).memoryValuePreview(value)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                appState.setVariable(name, value);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(AppLocalizations.of(context).memorySavedVariable(name, value))),
                );
              }
            },
            child: Text(AppLocalizations.of(context).storeButton),
          ),
        ],
      ),
    );
  }

  static void _showSaveToMemoryDialog(
    BuildContext context,
    Map<String, String> memory,
    String value,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).memorySaveToMemory),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context).memorySavePreview(value)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: List.generate(
                      9,
                      (i) => ListTile(
                            title: Text('M${i + 1}'),
                            subtitle: Text(memory['M$i'] ?? AppLocalizations.of(context).memoryEmptySlot,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            onTap: () {
                              memory['M$i'] = value;
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(AppLocalizations.of(context).memorySavedToSlot(i + 1))),
                              );
                            },
                          )),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
        ],
      ),
    );
  }

  static void showDeleteMemoryDialog(
    BuildContext context,
    Map<String, String> memory,
    VoidCallback onUpdate,
  ) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context).memoryDeleteTitle),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView(
              shrinkWrap: true,
              children: List.generate(
                  9,
                  (i) => ListTile(
                        title: Text('M${i + 1}'),
                        subtitle: Text(memory['M$i'] ?? AppLocalizations.of(context).memoryEmptySlot,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: memory['M$i'] != null
                            ? IconButton(
                                icon: Icon(Icons.delete,
                                    semanticLabel: AppLocalizations.of(context).userFunctionsDelete),
                                tooltip: AppLocalizations.of(context)
                                    .deleteMemorySlotTooltip,
                                onPressed: () {
                                  setState(() {
                                    memory.remove('M$i');
                                  });
                                  onUpdate();
                                },
                              )
                            : null,
                      )),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            ElevatedButton(
              onPressed: () {
                memory.clear();
                Navigator.of(context).pop();
                onUpdate();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context).memoryAllCleared)),
                );
              },
              child: Text(AppLocalizations.of(context).clearAll),
            ),
          ],
        ),
      ),
    );
  }
}
