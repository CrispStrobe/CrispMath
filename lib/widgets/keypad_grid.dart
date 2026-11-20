// lib/widgets/keypad_grid.dart:

import 'package:flutter/material.dart';

import '../engine/function_reference.dart';
import '../localization/app_localizations.dart';
import 'calculator_button.dart';
import 'help_target.dart';

/// Hover / long-press delay for keypad and keypad-tab tooltips.
const Duration kKeypadTooltipWait = Duration(milliseconds: 500);

/// Physical-keyboard equivalents shown in keypad tooltips.
const Map<String, String> _keypadShortcuts = {'C': 'Esc'};

final Map<String, FunctionRef> _functionRefsById = {
  for (final ref in FunctionReferences.all) ref.id: ref,
};

/// Tooltip text for a keypad key: what it does (the localized
/// [FunctionRef] description when [refId] has a catalog entry, otherwise
/// [AppLocalizations.keypadKeyHint]), the signature and first example,
/// and the keyboard shortcut if there is one. Null for keys with nothing
/// useful to say (digits).
String? keypadTooltipMessage(BuildContext context, String key, String? refId) {
  final t = AppLocalizations.of(context);
  final lines = <String>[];
  final ref = refId == null ? null : _functionRefsById[refId];
  if (ref != null) {
    lines.add(_firstSentence(
        t.functionRefDescription(ref.id) ?? ref.shortDescription));
    lines.add(ref.signature);
    if (ref.examples.isNotEmpty) {
      final example = ref.examples.first;
      final shown = example.expected.isEmpty || example.expected.length > 40
          ? example.input
          : '${example.input} = ${example.expected}';
      if (shown != ref.signature) lines.add(t.keypadTooltipExample(shown));
    }
  } else {
    final hint = t.keypadKeyHint(key);
    if (hint != null) lines.add(hint);
  }
  final shortcut = _keypadShortcuts[key];
  if (shortcut != null) lines.add(t.keypadTooltipShortcut(shortcut));
  return lines.isEmpty ? null : lines.join('\n');
}

/// First sentence of a catalog description, without Markdown backticks.
String _firstSentence(String text) {
  final plain = text.replaceAll('`', '').trim();
  final end = plain.indexOf('. ');
  return end < 0 ? plain : plain.substring(0, end + 1);
}

/// A widget that arranges calculator buttons in a responsive grid.
///
/// Round 102 (P6): when [helpRefIdFor] AND [onHelpTap] are both
/// supplied, every button is wrapped in a [HelpTarget]. While help
/// mode is on, tapping a button whose `helpRefIdFor(text)` returns a
/// non-null id calls `onHelpTap(id)` instead of the normal press
/// handler. Buttons without a matching id still render the
/// help-mode outline but stay functional on tap.
class KeypadGrid extends StatelessWidget {
  final List<String> buttons;
  final void Function(String) onButtonPressed;

  /// Round 102: per-button glyph→FunctionRef-id resolver. Returns
  /// `null` for buttons without a catalogued help entry.
  final String? Function(String buttonText)? helpRefIdFor;

  /// Round 102: invoked with the resolved FunctionRef id when a
  /// button is tapped in help mode.
  final void Function(String refId)? onHelpTap;

  const KeypadGrid({
    super.key,
    required this.buttons,
    required this.onButtonPressed,
    this.helpRefIdFor,
    this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    // This LayoutBuilder creates a perfectly responsive grid that fills the available space.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Scale spacing and padding down when the available area is tight
        // (e.g. graphing screen where the keypad shares space with the plot).
        final compact = constraints.maxHeight < 280;
        final double crossAxisSpacing = compact ? 4 : 10;
        final double mainAxisSpacing = compact ? 4 : 10;
        final double pad = compact ? 4 : 12;
        final double horizontalPadding = pad * 2;
        final double verticalPadding = pad * 2;

        final double cellWidth = (constraints.maxWidth -
                horizontalPadding -
                (3 * crossAxisSpacing)) /
            4;
        final double cellHeight =
            (constraints.maxHeight - verticalPadding - (4 * mainAxisSpacing)) /
                5;

        // Prevent division-by-zero or negative aspect ratio if constraints are not ready.
        final double aspectRatio =
            (cellHeight > 0 && cellWidth > 0) ? cellWidth / cellHeight : 1.0;

        return GridView.builder(
          padding: EdgeInsets.all(pad),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: aspectRatio,
          ),
          itemCount: buttons.length,
          itemBuilder: (context, index) {
            final buttonText = buttons[index];
            final refId = helpRefIdFor?.call(buttonText);
            Widget button = CalculatorButton(
              text: buttonText,
              onPressed: () => onButtonPressed(buttonText),
            );
            final tooltip = keypadTooltipMessage(context, buttonText, refId);
            if (tooltip != null) {
              // The button already carries a spoken Semantics label; keep
              // the tooltip visual-only so screen readers and semantics
              // finders see the same node as before.
              button = Tooltip(
                message: tooltip,
                waitDuration: kKeypadTooltipWait,
                excludeFromSemantics: true,
                child: button,
              );
            }
            if (helpRefIdFor == null || onHelpTap == null) return button;
            return HelpTarget(
              padding: EdgeInsets.zero,
              borderRadius: const Radius.circular(16),
              onHelpTap: refId == null ? null : () => onHelpTap!(refId),
              child: button,
            );
          },
        );
      },
    );
  }
}
