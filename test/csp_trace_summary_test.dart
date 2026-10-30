// CspTraceSummary totals a real propagation trace. The counts are
// checked against the trace steps themselves, and the per-constraint
// work must add up to every removed value.

import 'package:crisp_math/engine/csp_solver.dart';
import 'package:crisp_math/engine/csp_trace_summary.dart';
import 'package:crisp_math/engine/magic_square.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a pinned value settles everything by propagation', () async {
    final trace = await CspSolver.traceDsl(
        'vars: x in 0..5\nvars: y in 0..5\nx == 3\nx + y == 5');
    final s = CspTraceSummary.of(trace);
    expect(trace.solved, isTrue);
    expect(s.decisions, 0);
    expect(s.prunes, 2);
    expect(s.valuesRemoved, 10);
    expect(s.propagationOnly(trace), isTrue);
    expect(s.byConstraint.map((w) => w.label),
        ['line 3: x == 3', 'line 4: x + y == 5']);
  });

  test('3-colouring a triangle needs decisions', () async {
    final trace = await CspSolver.traceDsl(
        'vars: a, b, c in 1..3\na != b\na != c\nb != c');
    final s = CspTraceSummary.of(trace);
    expect(s.decisions, 2);
    expect(s.prunes, 3);
    expect(s.propagationOnly(trace), isFalse);
  });

  test('magic square totals agree with the steps', () async {
    final trace = await CspSolver.traceDsl(MagicSquare.buildProgram(3));
    final s = CspTraceSummary.of(trace);
    int count(CspTraceStepKind k) =>
        trace.steps.where((st) => st.kind == k).length;
    expect(s.decisions, count(CspTraceStepKind.decision));
    expect(s.prunes, count(CspTraceStepKind.prune));
    expect(s.wipeouts, count(CspTraceStepKind.wipeout));
    expect(s.backtracks,
        count(CspTraceStepKind.backtrack) + count(CspTraceStepKind.backjump));
    expect(s.byConstraint.fold(0, (a, w) => a + w.removed), s.valuesRemoved);
    expect(s.byConstraint.fold(0, (a, w) => a + w.prunes), s.prunes);
    for (var i = 1; i < s.byConstraint.length; i++) {
      expect(s.byConstraint[i - 1].removed,
          greaterThanOrEqualTo(s.byConstraint[i].removed));
    }
    expect(s.byConstraint.first.label, startsWith('allDifferent('));
  });

  test('wipeouts remove values but are not counted as prunes', () {
    final trace = CspTraceResult.ok(
      variables: const ['x'],
      initialDomains: const {'x': [1, 2, 3]},
      steps: const [
        CspTraceStep(seq: 0, kind: CspTraceStepKind.prune, domains: {},
            causeLabel: 'A', removedValues: [1]),
        CspTraceStep(seq: 1, kind: CspTraceStepKind.wipeout, domains: {},
            causeLabel: 'A', removedValues: [2, 3]),
        CspTraceStep(seq: 2, kind: CspTraceStepKind.wipeout, domains: {},
            causeLabel: 'B', removedValues: [1]),
      ],
      solved: false, solution: null, truncated: false, objectiveIgnored: false,
    );
    final summary = CspTraceSummary.of(trace);
    expect(summary.prunes, 1);
    expect(summary.wipeouts, 2);
    expect(summary.valuesRemoved, 4);
    final a = summary.byConstraint.firstWhere((w) => w.label == 'A');
    final b = summary.byConstraint.firstWhere((w) => w.label == 'B');
    expect((a.removed, a.prunes), (3, 1));
    expect((b.removed, b.prunes), (1, 0));
  });

  test('an unsatisfiable model is never propagation-only', () async {
    final trace = await CspSolver.traceDsl(
        'vars: x in 0..3\nvars: y in 0..3\nx + y == 9');
    final s = CspTraceSummary.of(trace);
    expect(trace.solved, isFalse);
    expect(s.propagationOnly(trace), isFalse);
  });
}
