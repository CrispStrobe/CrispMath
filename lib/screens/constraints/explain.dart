// lib/screens/constraints/explain.dart
//
// Unsatisfiable-model explanation (minimal unsatisfiable subset).

part of '../constraints_screen.dart';

/// Stateless renderer for the QuickXplain MUS panel. Shown by every
/// tab when its solve concluded with no solutions / unsatisfiable.
/// State (the result + busy flag) lives in the parent tab; the
/// onExplain callback runs the actual `CspSolver.explain*` call.
class _ExplainSection extends StatelessWidget {
  final bool isLoading;
  final CspMusResult? result;
  final VoidCallback onExplain;

  const _ExplainSection({
    required this.isLoading,
    required this.result,
    required this.onExplain,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (result == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: isLoading ? null : onExplain,
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.search, size: 18),
          label: Text(t.constraintsExplainFailure),
        ),
      );
    }
    return _MusBlock(result: result!);
  }
}

class _MusBlock extends StatelessWidget {
  final CspMusResult result;
  const _MusBlock({required this.result});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (result.error != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: scheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(result.error!,
                  style: TextStyle(color: scheme.onErrorContainer)),
            ),
          ],
        ),
      );
    }
    if (result.wasSatisfiable) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline,
                color: scheme.onSecondaryContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(t.constraintsExplainSatisfiable,
                  style: TextStyle(color: scheme.onSecondaryContainer)),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.constraintsExplainHeader,
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          t.constraintsExplainEntryCount(result.entries.length),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        _musListBox(context, scheme, result.entries),
        // Round 116 (C9): a distinct second minimal conflict, when the
        // deletion-based algorithm pinned the unsatisfiability on a
        // different constraint set than QuickXplain.
        if (result.altEntries.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            t.constraintsExplainAltHeader(result.altEntries.length),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 6),
          _musListBox(context, scheme, result.altEntries),
        ],
      ],
    );
  }

  Widget _musListBox(
          BuildContext context, ColorScheme scheme, List<MusEntry> entries) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3, right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.kind,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: scheme.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SelectableText(
                        entry.label,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}
