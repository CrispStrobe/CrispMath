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
  /// if the user cancelled. Existing variables are overwritten without
  /// confirmation (matches the calculator's existing M+/store
  /// semantics).
  static Future<String?> promptStoreAsVariable({
    required BuildContext context,
    required String value,
  }) async {
    final t = AppLocalizations.of(context);
    final controller = TextEditingController();
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
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                Navigator.of(ctx).pop(controller.text.trim());
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
    final nameCtrl = TextEditingController();
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
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                Navigator.of(ctx).pop(nameCtrl.text.trim().toLowerCase());
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
}
