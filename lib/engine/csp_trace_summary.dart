// lib/engine/csp_trace_summary.dart
//
// Totals for a propagation trace, so the constraint visualizer can say
// what the solve took: how many decisions, prunes, dead ends and
// backtracks, and which constraints removed the most values. A solve
// with no decision was settled by propagation alone.

import 'csp_solver.dart';

/// Values one constraint removed over a whole trace.
class CspConstraintWork {
  final String label;
  final int removed;
  final int prunes;
  final int wipeouts;

  const CspConstraintWork(this.label, this.removed, this.prunes, this.wipeouts);
}

class CspTraceSummary {
  final int decisions;
  final int prunes;
  final int wipeouts;
  final int backtracks;
  final int valuesRemoved;

  /// Constraints by values removed, most first; ties keep trace order.
  final List<CspConstraintWork> byConstraint;

  const CspTraceSummary({
    required this.decisions,
    required this.prunes,
    required this.wipeouts,
    required this.backtracks,
    required this.valuesRemoved,
    required this.byConstraint,
  });

  /// Solved without a single decision: propagation settled every domain.
  bool propagationOnly(CspTraceResult trace) =>
      trace.solved && decisions == 0 && !trace.truncated;

  factory CspTraceSummary.of(CspTraceResult trace) {
    var decisions = 0, prunes = 0, wipeouts = 0, backtracks = 0, removed = 0;
    final work = <String, (int, int, int)>{};
    for (final step in trace.steps) {
      switch (step.kind) {
        case CspTraceStepKind.decision:
          decisions++;
        case CspTraceStepKind.prune:
        case CspTraceStepKind.wipeout:
          if (step.kind == CspTraceStepKind.prune) {
            prunes++;
          } else {
            wipeouts++;
          }
          final n = step.removedValues.length;
          removed += n;
          final label = step.causeLabel ?? step.causeKind ?? '?';
          final (r, p, w) = work[label] ?? (0, 0, 0);
          work[label] = (
            r + n,
            p + (step.kind == CspTraceStepKind.prune ? 1 : 0),
            w + (step.kind == CspTraceStepKind.wipeout ? 1 : 0),
          );
        case CspTraceStepKind.backtrack:
        case CspTraceStepKind.backjump:
          backtracks++;
        case CspTraceStepKind.solution:
          break;
      }
    }
    final order = work.keys.toList();
    final byConstraint = [
      for (final label in order)
        CspConstraintWork(
          label,
          work[label]!.$1,
          work[label]!.$2,
          work[label]!.$3,
        ),
    ];
    // List.sort is not stable; break ties by first appearance.
    byConstraint.sort((a, b) {
      final c = b.removed.compareTo(a.removed);
      return c != 0 ? c : order.indexOf(a.label) - order.indexOf(b.label);
    });
    return CspTraceSummary(
      decisions: decisions,
      prunes: prunes,
      wipeouts: wipeouts,
      backtracks: backtracks,
      valuesRemoved: removed,
      byConstraint: byConstraint,
    );
  }
}
