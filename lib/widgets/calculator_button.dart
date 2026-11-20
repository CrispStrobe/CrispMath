// lib/widgets/calculator_button.dart:

import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

/// A styled button for the calculator keypad.
class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  // Glyph-only buttons get a spoken description for screen readers
  // (VoiceOver / TalkBack would otherwise announce "√" as nothing or
  // "u+221A"); see AppLocalizations.keypadSpokenLabel. Plain digits and
  // recognizable function names (`sin`, `solve`) pass through their own text.

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Semantics(
        // Override the auto-derived label with a screen-reader-friendly
        // form for glyph-only buttons; fall back to the visible text
        // for digits and named functions where the literal is fine.
        label: AppLocalizations.of(context).keypadSpokenLabel(text) ?? text,
        button: true,
        excludeSemantics: true,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: _getButtonColor(text),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  /// Determines the button color based on its function.
  Color _getButtonColor(String text) {
    const operators = ['/', '*', '-', '+', '=', '^'];
    const casFunctions = [
      '∫ dx',
      'd/dx',
      'lim',
      'solve',
      'simplify',
      'factor',
      'expand'
    ];

    if (operators.contains(text) || text == '⌫') {
      return Colors.orange[800]!;
    }
    if (casFunctions.contains(text)) {
      return Colors.blueGrey[700]!;
    }
    if (text == 'C') {
      return Colors.red[700]!;
    }
    // Default color for numbers and general functions.
    return Colors.grey[850]!;
  }
}
