// lib/widgets/module_help_dialog.dart
//
// Round 105 (P6): per-module help dialog reachable from each
// Analyze-hub module screen's AppBar via [ModuleHelpButton].
//
// Each module declares its content as a [ModuleHelpKind] enum
// value; the dialog renders the per-locale title + description
// pulled from [AppLocalizations] (so the i18n pass in Round 100
// handles translations without touching this file). Optional
// [FunctionRef] cross-link surfaces "Learn more" deep-linking
// the full Function Reference dialog filtered by the seeded id.
//
// Unlike Calculator + Notepad's global help-mode toggle pattern,
// the module screens use a direct help button — one-shot module
// explanation, no global state. The mental model is "what does
// this thing do?" → tap (?), read, dismiss.

import 'package:flutter/material.dart';

import '../engine/function_reference.dart';
import '../localization/app_localizations.dart';
import 'function_reference_dialog.dart';

export '../engine/module_help_kind.dart' show ModuleHelpKind;

/// Optional FunctionRef.id that the module's "Learn more" button
/// should seed [FunctionReferenceDialog.initialSearch] with.
/// Modules whose surface area isn't fully covered by FR rows leave
/// their entry unset — the dialog hides the Learn-more button.
const Map<ModuleHelpKind, String> _kModuleRefId = {
  ModuleHelpKind.statistics: 'welch_t',
  ModuleHelpKind.constraints: 'all_different',
  ModuleHelpKind.sudoku: 'sudoku_regular',
  // curveSketching / planes / conicSections / graphing3D / scene3D
  // have no single FR row that summarizes the module; intentionally
  // omitted so the dialog renders without a Learn-more button.
};

/// AppBar action button that opens [ModuleHelpDialog] for the given
/// module. Drop-in for any module screen — wrap in `actions: [...]`
/// on the screen's `Scaffold.appBar`.
class ModuleHelpButton extends StatelessWidget {
  const ModuleHelpButton({super.key, required this.kind});

  final ModuleHelpKind kind;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return IconButton(
      icon: const Icon(Icons.help_outline),
      tooltip: t.moduleHelpTooltip,
      onPressed: () => showDialog<void>(
        context: context,
        builder: (_) => ModuleHelpDialog(kind: kind),
      ),
    );
  }
}

/// The dialog itself. Public for widget-test access; production
/// surface is via [ModuleHelpButton].
class ModuleHelpDialog extends StatelessWidget {
  const ModuleHelpDialog({super.key, required this.kind});

  final ModuleHelpKind kind;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final refId = _kModuleRefId[kind];
    final ref = refId == null
        ? null
        : FunctionReferences.all.firstWhere(
            (e) => e.id == refId,
            orElse: () => const FunctionRef(
              id: '',
              category: FunctionRefCategory.cas,
              signature: '',
              shortDescription: '',
            ),
          );

    return AlertDialog(
      title: Text(t.moduleHelpTitle(kind)),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Text(t.moduleHelpDescription(kind)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.dialogClose),
        ),
        if (ref != null && ref.id.isNotEmpty)
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).pop();
              showDialog<void>(
                context: context,
                builder: (_) => FunctionReferenceDialog(initialSearch: ref.id),
              );
            },
            child: Text(t.keypadHelpLearnMore),
          ),
      ],
    );
  }
}
