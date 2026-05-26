import 'package:flutter/material.dart';

/// Boolean result chip used by both the calculator history column and
/// the notepad result column (Round 110 + Round 113, P7). Pulls the
/// secondaryContainer / errorContainer pair the rest of the app uses
/// for "win / fail" surfaces (sudoku, blocked-by chip) so the surface
/// feels consistent.
///
/// `fontSize` defaults to the calculator's 18; notepad's surrounding
/// text is 16, so pass `16` when embedding there.
class BooleanChip extends StatelessWidget {
  final bool value;
  final double fontSize;

  const BooleanChip({super.key, required this.value, this.fontSize = 18});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      visualDensity: VisualDensity.compact,
      backgroundColor:
          value ? scheme.secondaryContainer : scheme.errorContainer,
      label: Text(
        value ? 'true' : 'false',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: value ? scheme.onSecondaryContainer : scheme.onErrorContainer,
        ),
      ),
    );
  }
}
