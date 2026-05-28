// lib/widgets/function_ref_help_popover.dart
//
// Round 105b (P6): a per-element help popover for any FunctionRef
// catalog entry, keyed by id. Looks the entry up in
// FunctionReferences.all and shows its signature plus the LOCALIZED
// short description (R100), with a "Learn more" button that deep-links
// into the full Function Reference dialog filtered to that id.
//
// Shared by the calculator keypad (R102b per-glyph popovers) and the
// module-surface screens — Statistics test chips, Constraints DSL
// operators, Sudoku variant presets (R105b). Centralising it here
// means the localized-description fix and the "Learn more" wiring live
// in exactly one place.

import 'package:flutter/material.dart';

import '../engine/function_reference.dart';
import '../localization/app_localizations.dart';
import 'function_reference_dialog.dart';

/// Show the help popover for the catalog entry with [refId]. No-op if
/// the id isn't in the catalog (so callers can pass an id optimistically).
void showFunctionRefHelpPopover(BuildContext context, String refId) {
  final ref = FunctionReferences.all.firstWhere(
    (e) => e.id == refId,
    orElse: () => const FunctionRef(
      id: '',
      category: FunctionRefCategory.cas,
      signature: '',
      shortDescription: '',
    ),
  );
  if (ref.id.isEmpty) return;
  final t = AppLocalizations.of(context);
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          ref.signature,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
        ),
        // R100: prefer the localized description; fall back to the
        // English catalog string when the locale hasn't translated it.
        content: Text(
          t.functionRefDescription(ref.id) ?? ref.shortDescription,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(t.dialogClose),
          ),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              showDialog<void>(
                context: context,
                builder: (_) => FunctionReferenceDialog(initialSearch: ref.id),
              );
            },
            child: Text(t.keypadHelpLearnMore),
          ),
        ],
      );
    },
  );
}
