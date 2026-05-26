// Round 91: right-click / long-press "Store result as variable / function"
// dialogs, shared by the Calculator history-row menu and the Notepad
// line-result menu. Returns the persisted name on success (so the
// caller can surface a toast) or null on cancel / validation reject.

import 'package:flutter/material.dart';

import '../engine/app_state.dart';
import '../localization/app_localizations.dart';
import '../utils/expression_preprocessing_utils.dart';

class StoreResultDialogs {
  /// Prompts for a variable name, then persists [value] via
  /// [AppState.setVariable]. Returns the chosen name on save, or null
  /// if the user cancelled. If the entered name already exists, the
  /// user gets an overwrite-confirmation dialog (round 91b — the
  /// original 91 silently clobbered, matching the M+/store semantics
  /// but surprising users coming from the function-store flow).
  static Future<String?> promptStoreAsVariable({
    required BuildContext context,
    required String value,
  }) async {
    final t = AppLocalizations.of(context);
    // R91b: pre-fill with the next unused single-letter name so the
    // user can hit Enter to accept the suggestion.
    final suggested = _nextUnusedSingleLetterName();
    final controller = TextEditingController(text: suggested);
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(t.storeVariableTitle),
          content: SizedBox(
            width: 320,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '= $value',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(ctx)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: t.storeNameLabel,
                      hintText: 'x',
                    ),
                    validator: (s) => _validateVariableName(s, t),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(t.cancel),
            ),
            FilledButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final name = controller.text.trim();
                if (AppState().userVariables.containsKey(name)) {
                  final ok = await _confirmOverwrite(
                    ctx,
                    name: name,
                    existingValue: AppState().userVariables[name],
                  );
                  if (ok != true) return;
                }
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop(name);
              },
              child: Text(t.storeButton),
            ),
          ],
        );
      },
    );
    if (saved == null || saved.isEmpty) return null;
    AppState().setVariable(saved, value);
    return saved;
  }

  /// Prompts for a function name + parameter name, then persists a
  /// [UserFunction] via [AppState.setUserFunction]. The body is fixed
  /// to [expression]. The parameter defaults to the first single-letter
  /// free variable in [expression] (or the first free variable if none
  /// is single-letter). Returns the chosen function name on save, or
  /// null on cancel.
  static Future<String?> promptStoreAsFunction({
    required BuildContext context,
    required String expression,
  }) async {
    final t = AppLocalizations.of(context);
    final freeVars =
        ExpressionPreprocessingUtils.extractFreeVariables(expression);
    if (freeVars.isEmpty) return null;
    final defaultParam =
        freeVars.firstWhere((v) => v.length == 1, orElse: () => freeVars.first);
    // R91b: suggest the next unused single-letter that doesn't
    // collide with the parameter (so f(x) doesn't get suggested as
    // `x`).
    final suggestedName = _nextUnusedSingleLetterName(exclude: {defaultParam});
    final nameCtrl = TextEditingController(text: suggestedName);
    final paramCtrl = TextEditingController(text: defaultParam);
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(t.storeFunctionTitle),
          content: SizedBox(
            width: 360,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expression,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(ctx)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: t.storeNameLabel,
                      hintText: 'f',
                      helperText: t.userFunctionsNameHelp,
                    ),
                    validator: (s) => _validateFunctionName(s, t),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: paramCtrl,
                    decoration: InputDecoration(
                      labelText: t.storeFunctionParamLabel,
                      hintText: defaultParam,
                    ),
                    validator: (s) {
                      final v = s?.trim() ?? '';
                      if (v.isEmpty) return t.userFunctionsNameRequired;
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(t.cancel),
            ),
            FilledButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final name = nameCtrl.text.trim().toLowerCase();
                if (AppState().userFunctions.containsKey(name)) {
                  final existing = AppState().userFunctions[name]!;
                  final ok = await _confirmOverwrite(
                    ctx,
                    name: name,
                    existingValue:
                        '${existing.name}(${existing.paramVar}) = ${existing.body}',
                  );
                  if (ok != true) return;
                }
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop(name);
              },
              child: Text(t.storeButton),
            ),
          ],
        );
      },
    );
    if (saved == null || saved.isEmpty) return null;
    AppState().setUserFunction(UserFunction(
      name: saved,
      paramVar: paramCtrl.text.trim(),
      body: expression,
    ));
    return saved;
  }

  static String? _validateVariableName(String? input, AppLocalizations t) {
    final v = input?.trim() ?? '';
    if (v.isEmpty) return t.userFunctionsNameRequired;
    if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(v)) {
      return t.userFunctionsNameInvalid;
    }
    if (ExpressionPreprocessingUtils.isReservedName(v)) {
      return t.storeNameReserved;
    }
    return null;
  }

  static String? _validateFunctionName(String? input, AppLocalizations t) {
    final v = input?.trim().toLowerCase() ?? '';
    if (v.isEmpty) return t.userFunctionsNameRequired;
    if (!RegExp(r'^[a-z]$').hasMatch(v)) return t.userFunctionsNameInvalid;
    if (ExpressionPreprocessingUtils.isReservedName(v)) {
      return t.storeNameReserved;
    }
    return null;
  }

  /// R91b: walk the single-letter alphabet for the next name that
  /// isn't already a variable, a user function, a reserved CAS
  /// token, or in the [exclude] set (used to avoid suggesting the
  /// parameter name as the function name). Falls back to 'x' if
  /// the alphabet is exhausted — extremely unlikely in practice.
  static String _nextUnusedSingleLetterName({Set<String> exclude = const {}}) {
    final s = AppState();
    final taken = {
      ...s.userVariables.keys,
      ...s.userFunctions.keys,
      ...exclude,
    };
    for (var c = 'a'.codeUnitAt(0); c <= 'z'.codeUnitAt(0); c++) {
      final candidate = String.fromCharCode(c);
      if (taken.contains(candidate)) continue;
      if (ExpressionPreprocessingUtils.isReservedName(candidate)) continue;
      return candidate;
    }
    return 'x';
  }

  /// R91b: confirm before clobbering an existing variable or
  /// function. Returns `true` when the user confirms, `false` /
  /// `null` to abort the save.
  static Future<bool?> _confirmOverwrite(
    BuildContext context, {
    required String name,
    required String? existingValue,
  }) async {
    final t = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.storeOverwriteTitle(name)),
        content: existingValue == null
            ? null
            : Text(
                t.storeOverwriteCurrent(existingValue),
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Theme.of(ctx)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.storeOverwriteConfirm),
          ),
        ],
      ),
    );
  }
}
