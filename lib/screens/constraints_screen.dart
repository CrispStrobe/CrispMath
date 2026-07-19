// lib/screens/constraints_screen.dart
//
// Analysis-hub module for Constraint Satisfaction Problems. Four tabs:
//
//   1. Diophantine — enumerate integer solutions to a system of
//      bounded linear/inequality constraints. The variable list
//      drives a Map<String, (min, max)> and the constraints list is
//      passed through CspSolver.solveDiophantine.
//
//   2. Cryptarithm — solve `WORD1 + WORD2 = WORD3` puzzles via
//      CspSolver.solveCryptarithm.
//
//   3. Free-form DSL — the round-72 mini-DSL with `allDifferent`,
//      arithmetic comparators, `minimize` / `maximize`, `noOverlap`,
//      `cumulative` directives.
//
//   4. FlatZinc — paste a `.fzn` source string (typically produced
//      by `mzn2fzn` from a MiniZinc model) and call dart_csp's
//      FlatZinc frontend directly. Output is the standard FlatZinc
//      output format. Round E.1.
//
// Each tab shows the result in a copyable read-only block. Long-
// running solves are not yet routed through the persistent worker —
// typical CSP problems at this scale finish in milliseconds.

import 'dart:math';

import 'package:dart_csp/dart_csp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/app_state.dart';
import '../engine/csp_solver.dart';
import '../engine/magic_square.dart';
import '../localization/app_localizations.dart';
import '../widgets/australia_map_painter.dart';
import '../widgets/germany_map_painter.dart';
import '../widgets/propagation_visualizer.dart';
import '../widgets/function_ref_help_popover.dart';
import '../widgets/help_target.dart';
import '../widgets/module_help_dialog.dart';

class ConstraintsScreen extends StatefulWidget {
  const ConstraintsScreen({super.key});

  @override
  State<ConstraintsScreen> createState() => _ConstraintsScreenState();
}

class _ConstraintsScreenState extends State<ConstraintsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
    // Round 73: if a DSL worked-example was tapped, the AppState
    // slot will be populated. Jump directly to the Free-form tab
    // so the user lands on the editor (the _DslTab itself drains
    // the slot + sets the program text in its own initState).
    if (AppState().pendingDslProgramId != null) {
      _tabs.index = 2;
    }
    // A pending cryptarithm puzzle lands the user on the Cryptarithm
    // tab (index 1), which drains the slot + fills the field in its
    // own initState. Peeked (not consumed) here so the tab still sees
    // it.
    if (AppState().pendingCryptarithmPuzzle != null) {
      _tabs.index = 1;
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.moduleConstraintsTitle),
        actions: const [ModuleHelpButton(kind: ModuleHelpKind.constraints)],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: [
            Tab(text: t.constraintsTabDiophantine),
            Tab(text: t.constraintsTabCryptarithm),
            Tab(text: t.constraintsTabDsl),
            Tab(text: t.constraintsTabFlatZinc),
            Tab(text: t.constraintsTabMagicSquare),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _DiophantineTab(),
          _CryptarithmTab(),
          _DslTab(),
          _FlatZincTab(),
          _MagicSquareTab(),
        ],
      ),
    );
  }
}

// === Magic-square generator tab ========================================

class _MagicSquareTab extends StatefulWidget {
  const _MagicSquareTab();
  @override
  State<_MagicSquareTab> createState() => _MagicSquareTabState();
}

class _MagicSquareTabState extends State<_MagicSquareTab> {
  int _n = 3;
  List<int>? _square;
  bool _solving = false;
  final _rng = Random();

  Future<void> _generate() async {
    final n = _n;
    setState(() {
      _solving = true;
      _square = null;
    });
    final r =
        await CspSolver.solveDsl(MagicSquare.buildProgram(n), maxSolutions: 1);
    if (!mounted || n != _n) return;
    setState(() {
      _solving = false;
      if (r.ok && r.solutions.isNotEmpty) {
        final grid = MagicSquare.gridFromSolution(r.solutions.first, n);
        _square = MagicSquare.randomVariant(grid, n, _rng);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.constraintsMagicIntro,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('${t.constraintsMagicSize}:  '),
              const SizedBox(width: 4),
              ...MagicSquare.supportedSizes.map(
                (n) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('$n×$n'),
                    selected: _n == n,
                    onSelected: _solving
                        ? null
                        : (sel) {
                            if (sel && n != _n) {
                              setState(() {
                                _n = n;
                                _square = null;
                              });
                            }
                          },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            t.constraintsMagicConstant(MagicSquare.constantFor(_n)),
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _solving ? null : _generate,
              icon: _solving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.casino_outlined),
              label: Text(t.constraintsMagicGenerate),
            ),
          ),
          if (_square != null) ...[
            const SizedBox(height: 20),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: _MagicSquareGrid(values: _square!, n: _n),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t.constraintsMagicHint,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Renders an N×N magic square as a bordered grid of centered numbers.
class _MagicSquareGrid extends StatelessWidget {
  final List<int> values;
  final int n;
  const _MagicSquareGrid({required this.values, required this.n});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outline, width: 1.5),
        ),
        child: Column(
          children: [
            for (var r = 0; r < n; r++)
              Expanded(
                child: Row(
                  children: [
                    for (var c = 0; c < n; c++)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: scheme.outlineVariant),
                            color: scheme.surfaceContainerHighest,
                          ),
                          alignment: Alignment.center,
                          child: FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                '${values[r * n + c]}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// === Diophantine tab ====================================================

class _DiophantineTab extends StatefulWidget {
  const _DiophantineTab();
  @override
  State<_DiophantineTab> createState() => _DiophantineTabState();
}

class _DiophantineTabState extends State<_DiophantineTab> {
  final _varsCtl = TextEditingController(text: 'x in 0..50\ny in 0..50');
  final _constraintsCtl =
      TextEditingController(text: '2*x + 3*y == 30\nx <= y');
  DiophantineResult? _result;
  bool _solving = false;
  // Round E.2: MUS state. Cleared whenever a fresh solve runs so the
  // user doesn't see a stale conflict tied to inputs that have since
  // changed. Populated by `_explain`.
  CspMusResult? _mus;
  bool _explaining = false;

  @override
  void dispose() {
    _varsCtl.dispose();
    _constraintsCtl.dispose();
    super.dispose();
  }

  /// Parses one variable line. Accepts:
  ///   `name in min..max`
  /// Returns null on shape mismatch — caller surfaces an error per line.
  ({String name, int min, int max})? _parseVarLine(String line) {
    final m =
        RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s+in\s+(-?\d+)\s*\.\.\s*(-?\d+)$')
            .firstMatch(line.trim());
    if (m == null) return null;
    return (
      name: m.group(1)!,
      min: int.parse(m.group(2)!),
      max: int.parse(m.group(3)!),
    );
  }

  Future<void> _solve() async {
    final t = AppLocalizations.of(context);
    final varLines = _varsCtl.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final variables = <String, ({int min, int max})>{};
    final parseErrors = <String>[];
    for (final line in varLines) {
      final v = _parseVarLine(line);
      if (v == null) {
        parseErrors.add('${t.constraintsBadVarLine}: $line');
        continue;
      }
      variables[v.name] = (min: v.min, max: v.max);
    }
    if (parseErrors.isNotEmpty) {
      setState(() => _result = DiophantineResult.failure(parseErrors.first));
      return;
    }
    final constraints = _constraintsCtl.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    setState(() {
      _solving = true;
      _mus = null;
    });
    final r = await CspSolver.solveDiophantine(
        variables: variables, constraints: constraints);
    if (!mounted) return;
    setState(() {
      _solving = false;
      _result = r;
    });
  }

  Future<void> _explain() async {
    // Re-parse the live inputs so the MUS reflects whatever's in the
    // textareas right now (which may differ from the last solve if
    // the user edited but hasn't re-solved). Parse errors fall
    // through to a no-op — the user has a stale result and the
    // standard solve-time error path will take over on next Solve.
    final variables = <String, ({int min, int max})>{};
    for (final line in _varsCtl.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)) {
      final v = _parseVarLine(line);
      if (v == null) return;
      variables[v.name] = (min: v.min, max: v.max);
    }
    final constraints = _constraintsCtl.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    setState(() => _explaining = true);
    final r = await CspSolver.explainDiophantine(
      variables: variables,
      constraints: constraints,
    );
    if (!mounted) return;
    setState(() {
      _explaining = false;
      _mus = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.constraintsDiophantineIntro,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          TextField(
            controller: _varsCtl,
            maxLines: 4,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              labelText: t.constraintsVariablesLabel,
              helperText: t.constraintsVariablesHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _constraintsCtl,
            maxLines: 6,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              labelText: t.constraintsConstraintsLabel,
              helperText: t.constraintsConstraintsHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _solving ? null : _solve,
            icon: _solving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(t.constraintsSolveButton),
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            _ResultBlock(result: _result!),
            if (_result!.ok && _result!.solutions.isEmpty) ...[
              const SizedBox(height: 12),
              _ExplainSection(
                isLoading: _explaining,
                result: _mus,
                onExplain: _explain,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ResultBlock extends StatelessWidget {
  final DiophantineResult result;
  const _ResultBlock({required this.result});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (!result.ok) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
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
    final lines = <String>[];
    for (var i = 0; i < result.solutions.length; i++) {
      final parts = result.solutions[i].entries
          .map((e) => '${e.key}=${e.value}')
          .toList();
      // Round 111: append any set-variable members for this assignment,
      // e.g. `Team={1, 3}`.
      if (i < result.setSolutions.length) {
        result.setSolutions[i].forEach((name, members) {
          parts.add('$name={${members.join(', ')}}');
        });
      }
      final entries = parts.join(', ');
      // Optimization mode is always one assignment — drop the
      // numbering so the result reads "x=3, y=4" rather than
      // "1. x=3, y=4".
      lines.add(result.objective != null ? entries : '${i + 1}.  $entries');
    }
    final body = lines.isEmpty ? t.constraintsNoSolutions : lines.join('\n');
    // Round 74: optimization results get a dedicated header showing
    // the optimal objective value; enumeration results keep the
    // "N solutions" header (or "first N" when truncated).
    final headerText = result.objective != null
        ? t.constraintsOptimalHeader(result.objective!)
        : result.truncated
            ? t.constraintsTruncatedHeader(result.solutions.length)
            : t.constraintsSolutionsHeader(result.solutions.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              headerText,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            if (result.solutions.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: t.constraintsCopyResult,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: body));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.constraintsCopiedToast),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: SelectableText(
            body,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        // Set-variable overlay: present when the DSL program declared
        // `set` variables. Renders each solution's chosen subsets as
        // chip clusters — the natural shape for membership results.
        if (result.setVarNames.isNotEmpty &&
            result.setSolutions.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SetSolutionView(
            setVarNames: result.setVarNames,
            setSolutions: result.setSolutions,
          ),
        ],
        // Gantt overlay: present only when the DSL program had
        // `noOverlap` / `cumulative` constraints AND we got at
        // least one solution. Renders the first solution's start
        // times as a horizontal chart over the same time axis.
        if (result.ganttTasks.isNotEmpty && result.solutions.isNotEmpty) ...[
          const SizedBox(height: 12),
          _GanttChart(
            tasks: result.ganttTasks,
            assignment: result.solutions.first,
            capacity: result.ganttCapacity,
          ),
        ],
        // 2D packing overlay: present when the DSL program had a `diffN`
        // constraint AND we got at least one solution. Draws the first
        // solution's rectangle placement to scale inside the inferred
        // container, the planar sibling of the 1-D Gantt chart above.
        if (result.packingRects.isNotEmpty &&
            result.solutions.isNotEmpty &&
            result.packingWidth != null &&
            result.packingHeight != null) ...[
          const SizedBox(height: 12),
          _PackingChart(
            rects: result.packingRects,
            assignment: result.solutions.first,
            containerWidth: result.packingWidth!,
            containerHeight: result.packingHeight!,
          ),
        ],
        // Tour overlay: present when the DSL program had a `circuit` /
        // `subcircuit` constraint AND we got at least one solution. Draws
        // the first solution's Hamiltonian tour as a directed node-graph
        // with the nodes on a circle (successor-model edges i → next[i]).
        if (result.circuitVars.isNotEmpty && result.solutions.isNotEmpty) ...[
          const SizedBox(height: 12),
          _TourChart(
            successors: result.circuitVars,
            labels: result.circuitLabels,
            assignment: result.solutions.first,
            isSub: result.circuitIsSub,
          ),
        ],
        // Soft-constraint (MaxCSP) overlay: present when the DSL program
        // had `soft(…)` lines. Shows the satisfaction score plus each
        // preference — satisfied in green, violated struck through.
        if (result.softResults.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SoftConstraintPanel(
            results: result.softResults,
            satisfiedWeight: result.satisfiedWeight,
            totalWeight: result.totalWeight,
          ),
        ],
        // Search-strategy comparison: present when the program was solved
        // with "Compare strategies". A per-heuristic solver-stats table.
        if (result.strategyStats.isNotEmpty) ...[
          const SizedBox(height: 12),
          _StrategyStatsTable(stats: result.strategyStats),
        ],
        // Map-coloring overlay: the `mapColoringAustralia` gallery
        // program assigns a color to each of the seven Australian
        // regions. When the first solution is exactly that variable
        // set, render it as a schematic colored map so the
        // "no two neighbours share a color" property is visible.
        if (result.solutions.isNotEmpty &&
            AustraliaMapView.matches(result.solutions.first)) ...[
          const SizedBox(height: 12),
          AustraliaMapView(assignment: result.solutions.first),
        ],
        // Germany map-coloring overlay: the `mapColoringGermany` gallery
        // program assigns a color to each of the 16 Bundesländer. Same
        // trigger as Australia, on the German region key-set.
        if (result.solutions.isNotEmpty &&
            GermanyMapView.matches(result.solutions.first)) ...[
          const SizedBox(height: 12),
          GermanyMapView(assignment: result.solutions.first),
        ],
      ],
    );
  }
}

/// Tiny Gantt chart for schedules produced by the DSL tab. One row
/// per task, sorted by group and start time; bar width = duration.
/// For `cumulative` problems the row's right-edge label includes
/// the demand. Capacity (when known) is shown as a header strip.
class _GanttChart extends StatelessWidget {
  final List<GanttTaskSpec> tasks;
  final DiophantineSolution assignment;
  final int? capacity;

  const _GanttChart({
    required this.tasks,
    required this.assignment,
    this.capacity,
  });

  @override
  Widget build(BuildContext context) {
    // Compute the timeline span from the assignment + durations.
    var maxEnd = 0;
    for (final t in tasks) {
      final start = (assignment[t.startVar] as num?)?.toInt();
      if (start == null) continue;
      final end = start + t.duration;
      if (end > maxEnd) maxEnd = end;
    }
    if (maxEnd <= 0) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    const rowHeight = 28.0;
    final headerHeight = capacity != null ? 22.0 : 18.0;
    final totalHeight = headerHeight + tasks.length * rowHeight + 4;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: SizedBox(
        height: totalHeight,
        child: CustomPaint(
          painter: _GanttPainter(
            tasks: tasks,
            assignment: assignment,
            maxEnd: maxEnd,
            capacity: capacity,
            rowHeight: rowHeight,
            headerHeight: headerHeight,
            scheme: scheme,
            textStyle: Theme.of(context).textTheme.bodySmall ??
                const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}

class _GanttPainter extends CustomPainter {
  final List<GanttTaskSpec> tasks;
  final DiophantineSolution assignment;
  final int maxEnd;
  final int? capacity;
  final double rowHeight;
  final double headerHeight;
  final ColorScheme scheme;
  final TextStyle textStyle;

  _GanttPainter({
    required this.tasks,
    required this.assignment,
    required this.maxEnd,
    required this.capacity,
    required this.rowHeight,
    required this.headerHeight,
    required this.scheme,
    required this.textStyle,
  });

  /// Color palette per group — cycles if there are more groups than
  /// entries. Picked from Material Design's tonal palette so the
  /// bars look at home in both light and dark themes.
  static const List<Color> _groupColors = [
    Color(0xFF1976D2), // blue 700
    Color(0xFFE64A19), // deep orange 700
    Color(0xFF388E3C), // green 700
    Color(0xFF7B1FA2), // purple 700
    Color(0xFFFBC02D), // yellow 700
    Color(0xFF00796B), // teal 700
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Reserve a left gutter for task labels.
    const chartLeft = 56.0;
    final chartWidth = size.width - chartLeft - 8;
    if (chartWidth <= 0) return;
    final pxPerUnit = chartWidth / maxEnd;

    // Time-axis grid (light vertical lines + tick numbers along the top).
    final gridPaint = Paint()
      ..color = scheme.outlineVariant
      ..strokeWidth = 1;
    final axisLabelStyle = textStyle.copyWith(
      color: scheme.onSurfaceVariant,
      fontSize: 10,
    );
    final stepCandidates = [1, 2, 5, 10, 20, 50, 100];
    var step = 1;
    for (final s in stepCandidates) {
      if (maxEnd / s <= 10) {
        step = s;
        break;
      }
      step = s;
    }
    for (var t = 0; t <= maxEnd; t += step) {
      final x = chartLeft + t * pxPerUnit;
      canvas.drawLine(
        Offset(x, headerHeight),
        Offset(x, size.height),
        gridPaint,
      );
      final tp = TextPainter(
        text: TextSpan(text: '$t', style: axisLabelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + 2, 2));
    }

    // Capacity header strip (only for cumulative problems).
    if (capacity != null) {
      final capLabel = TextPainter(
        text: TextSpan(
          text: 'capacity = $capacity',
          style: axisLabelStyle.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      capLabel.paint(canvas, Offset(chartLeft, headerHeight - capLabel.height));
    }

    // Sort tasks by group then start time so each lane reads left-to-right.
    final sorted = [...tasks]..sort((a, b) {
        if (a.groupIndex != b.groupIndex) {
          return a.groupIndex.compareTo(b.groupIndex);
        }
        final aStart = (assignment[a.startVar] as num?)?.toInt() ?? 0;
        final bStart = (assignment[b.startVar] as num?)?.toInt() ?? 0;
        return aStart.compareTo(bStart);
      });

    final rowPaint = Paint();
    final labelStyle = textStyle.copyWith(color: scheme.onSurface);
    for (var i = 0; i < sorted.length; i++) {
      final task = sorted[i];
      final start = (assignment[task.startVar] as num?)?.toInt();
      if (start == null) continue;
      final yTop = headerHeight + i * rowHeight + 4;
      final yBot = yTop + rowHeight - 8;

      // Left-gutter task name.
      final nameTp = TextPainter(
        text: TextSpan(text: task.startVar, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: chartLeft - 4);
      nameTp.paint(
        canvas,
        Offset(0, yTop + (rowHeight - 8 - nameTp.height) / 2),
      );

      // Bar.
      final barX = chartLeft + start * pxPerUnit;
      final barW = task.duration * pxPerUnit;
      rowPaint.color = _groupColors[task.groupIndex % _groupColors.length];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(barX, yTop, barX + barW, yBot),
          const Radius.circular(3),
        ),
        rowPaint,
      );

      // Inside-bar caption: duration (and demand if cumulative).
      final cap = task.demand != null
          ? '${task.duration}u · d${task.demand}'
          : '${task.duration}u';
      final capTp = TextPainter(
        text: TextSpan(
          text: cap,
          style: labelStyle.copyWith(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      if (capTp.width + 8 < barW) {
        capTp.paint(
          canvas,
          Offset(barX + 4, yTop + (rowHeight - 8 - capTp.height) / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GanttPainter old) =>
      old.tasks != tasks ||
      old.assignment != assignment ||
      old.maxEnd != maxEnd ||
      old.capacity != capacity;
}

/// 2D rectangle-layout chart for `diffN` packing programs — the planar
/// sibling of [_GanttChart]. Draws each rectangle at its solved lower-
/// left `(x, y)` within the inferred container, to scale, with the
/// origin at the bottom-left so the picture reads like a floor plan.
class _PackingChart extends StatelessWidget {
  final List<PackingRectSpec> rects;
  final DiophantineSolution assignment;
  final int containerWidth;
  final int containerHeight;

  const _PackingChart({
    required this.rects,
    required this.assignment,
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (containerWidth <= 0 || containerHeight <= 0) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    // Fit the container into a bounded box while preserving aspect ratio.
    const maxDim = 240.0;
    final aspect = containerWidth / containerHeight;
    double drawW, drawH;
    if (aspect >= 1) {
      drawW = maxDim;
      drawH = maxDim / aspect;
    } else {
      drawH = maxDim;
      drawW = maxDim * aspect;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Packing · $containerWidth × $containerHeight',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              width: drawW + 2,
              height: drawH + 2,
              child: CustomPaint(
                painter: _PackingPainter(
                  rects: rects,
                  assignment: assignment,
                  containerWidth: containerWidth,
                  containerHeight: containerHeight,
                  scheme: scheme,
                  textStyle: Theme.of(context).textTheme.bodySmall ??
                      const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackingPainter extends CustomPainter {
  final List<PackingRectSpec> rects;
  final DiophantineSolution assignment;
  final int containerWidth;
  final int containerHeight;
  final ColorScheme scheme;
  final TextStyle textStyle;

  _PackingPainter({
    required this.rects,
    required this.assignment,
    required this.containerWidth,
    required this.containerHeight,
    required this.scheme,
    required this.textStyle,
  });

  // Same tonal palette as the Gantt painter, cycled per rectangle.
  static const List<Color> _rectColors = [
    Color(0xFF1976D2), // blue 700
    Color(0xFFE64A19), // deep orange 700
    Color(0xFF388E3C), // green 700
    Color(0xFF7B1FA2), // purple 700
    Color(0xFFFBC02D), // yellow 700
    Color(0xFF00796B), // teal 700
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final pxPerX = size.width / containerWidth;
    final pxPerY = size.height / containerHeight;

    // Container border.
    final borderPaint = Paint()
      ..color = scheme.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(Offset.zero & size, borderPaint);

    final fillPaint = Paint()..style = PaintingStyle.fill;
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.85);

    for (var i = 0; i < rects.length; i++) {
      final r = rects[i];
      final x = (assignment[r.xVar] as num?)?.toInt();
      final y = (assignment[r.yVar] as num?)?.toInt();
      if (x == null || y == null) continue;

      // Flip the y-axis so the origin sits at the bottom-left.
      final left = x * pxPerX;
      final top = (containerHeight - y - r.height) * pxPerY;
      final rect = Rect.fromLTWH(
        left,
        top,
        r.width * pxPerX,
        r.height * pxPerY,
      );
      fillPaint.color =
          _rectColors[i % _rectColors.length].withValues(alpha: 0.85);
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, edgePaint);

      // Inside-rect caption: "w×h" when it fits.
      final label = '${r.width}×${r.height}';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: textStyle.copyWith(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      if (tp.width + 4 < rect.width && tp.height + 2 < rect.height) {
        tp.paint(
          canvas,
          Offset(
            rect.left + (rect.width - tp.width) / 2,
            rect.top + (rect.height - tp.height) / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PackingPainter old) =>
      old.rects != rects ||
      old.assignment != assignment ||
      old.containerWidth != containerWidth ||
      old.containerHeight != containerHeight;
}

/// Directed node-graph for `circuit` / `subcircuit` tours. Nodes are
/// laid out on a circle in index order; a solved successor value
/// `next[i]` draws an arrow from node `i` to node `next[i]`. For
/// `subcircuit`, a self-loop (`next[i] == i`) means the node is not
/// visited — it is drawn dimmed with no outgoing edge. This is the
/// reusable node-graph widget the C9 constraint-network view builds on.
class _TourChart extends StatelessWidget {
  final List<String> successors;
  final List<String>? labels;
  final DiophantineSolution assignment;
  final bool isSub;

  const _TourChart({
    required this.successors,
    required this.labels,
    required this.assignment,
    required this.isSub,
  });

  @override
  Widget build(BuildContext context) {
    if (successors.length < 2) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSub
                ? 'Subcircuit · ${successors.length} nodes'
                : 'Tour · ${successors.length} nodes',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: CustomPaint(
                painter: _TourPainter(
                  successors: successors,
                  labels: labels,
                  assignment: assignment,
                  isSub: isSub,
                  scheme: scheme,
                  textStyle: Theme.of(context).textTheme.bodySmall ??
                      const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TourPainter extends CustomPainter {
  final List<String> successors;
  final List<String>? labels;
  final DiophantineSolution assignment;
  final bool isSub;
  final ColorScheme scheme;
  final TextStyle textStyle;

  _TourPainter({
    required this.successors,
    required this.labels,
    required this.assignment,
    required this.isSub,
    required this.scheme,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = successors.length;
    const nodeR = 16.0;
    final center = Offset(size.width / 2, size.height / 2);
    final layoutR = size.shortestSide / 2 - nodeR - 6;

    // Circular layout: node i at angle -90° + i·(360°/n), so node 0
    // sits at the top and the tour reads clockwise.
    Offset posOf(int i) {
      final a = -pi / 2 + i * 2 * pi / n;
      return center + Offset(cos(a) * layoutR, sin(a) * layoutR);
    }

    final visited = List<bool>.filled(n, !isSub);
    if (isSub) {
      // Mark nodes that participate (successor != self).
      for (var i = 0; i < n; i++) {
        final nxt = (assignment[successors[i]] as num?)?.toInt();
        if (nxt != null && nxt != i) {
          visited[i] = true;
          visited[nxt] = true;
        }
      }
    }

    final edgePaint = Paint()
      ..color = scheme.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Directed edges i → next[i], drawn as arrows stopping at the node rim.
    for (var i = 0; i < n; i++) {
      final nxt = (assignment[successors[i]] as num?)?.toInt();
      if (nxt == null || nxt < 0 || nxt >= n) continue;
      if (nxt == i) continue; // self-loop = not visited (subcircuit)
      final from = posOf(i);
      final to = posOf(nxt);
      final dir = (to - from);
      final len = dir.distance;
      if (len == 0) continue;
      final unit = dir / len;
      final start = from + unit * nodeR;
      final end = to - unit * nodeR;
      canvas.drawLine(start, end, edgePaint);

      // Arrowhead at the destination rim.
      const headLen = 9.0;
      const headHalf = 5.0;
      final back = end - unit * headLen;
      final perp = Offset(-unit.dy, unit.dx) * headHalf;
      final headPaint = Paint()
        ..color = scheme.primary
        ..style = PaintingStyle.fill;
      final path = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(back.dx + perp.dx, back.dy + perp.dy)
        ..lineTo(back.dx - perp.dx, back.dy - perp.dy)
        ..close();
      canvas.drawPath(path, headPaint);
    }

    // Nodes on top of the edges.
    for (var i = 0; i < n; i++) {
      final p = posOf(i);
      final on = visited[i];
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..color = on ? scheme.primaryContainer : scheme.surfaceContainerHighest;
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = on ? scheme.primary : scheme.outlineVariant;
      canvas.drawCircle(p, nodeR, fill);
      canvas.drawCircle(p, nodeR, ring);

      final label = labels != null ? labels![i] : '$i';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: textStyle.copyWith(
            color: on ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: nodeR * 2 - 2);
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_TourPainter old) =>
      old.successors != successors ||
      old.labels != labels ||
      old.assignment != assignment ||
      old.isSub != isSub;
}

/// MaxCSP satisfaction panel for `soft(…)` programs. A score header
/// (satisfied weight / total, with a progress bar) over a list of the
/// preferences — satisfied ones in green with a check, violated ones
/// struck through with the outline colour.
class _SoftConstraintPanel extends StatelessWidget {
  final List<SoftConstraintResult> results;
  final int satisfiedWeight;
  final int totalWeight;

  const _SoftConstraintPanel({
    required this.results,
    required this.satisfiedWeight,
    required this.totalWeight,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final frac = totalWeight == 0 ? 0.0 : satisfiedWeight / totalWeight;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.constraintsSoftScore(satisfiedWeight, totalWeight),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: frac,
              minHeight: 6,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.lerp(scheme.error, const Color(0xFF388E3C), frac) ??
                    scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          for (final s in results)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    s.satisfied ? Icons.check_circle : Icons.cancel_outlined,
                    size: 16,
                    color: s.satisfied
                        ? const Color(0xFF388E3C)
                        : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.description,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: s.satisfied
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                        decoration:
                            s.satisfied ? null : TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                  Text(
                    'w${s.weight}',
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Chip-cluster view for `set` programs. Each solution is one row of
/// labelled clusters — one cluster per set variable, its members shown
/// as chips (or an "∅" chip when the set is empty). Caps the number of
/// rendered solutions so a large enumeration stays readable.
class _SetSolutionView extends StatelessWidget {
  final List<String> setVarNames;
  final List<Map<String, List<int>>> setSolutions;

  const _SetSolutionView({
    required this.setVarNames,
    required this.setSolutions,
  });

  static const _maxRows = 8;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shown = setSolutions.take(_maxRows).toList();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < shown.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (setSolutions.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '#${i + 1}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      for (final name in setVarNames)
                        _SetCluster(
                            name: name, members: shown[i][name] ?? const []),
                    ],
                  ),
                ],
              ),
            ),
          if (setSolutions.length > shown.length)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '… +${setSolutions.length - shown.length} more',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SetCluster extends StatelessWidget {
  final String name;
  final List<int> members;

  const _SetCluster({required this.name, required this.members});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$name  (${members.length})',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            if (members.isEmpty)
              _chip(scheme, '∅', muted: true)
            else
              for (final m in members) _chip(scheme, '$m'),
          ],
        ),
      ],
    );
  }

  Widget _chip(ColorScheme scheme, String text, {bool muted = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color:
              muted ? scheme.surfaceContainerHighest : scheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: muted ? scheme.onSurfaceVariant : scheme.onPrimaryContainer,
          ),
        ),
      );
}

/// Search-strategy comparison table. One row per heuristic showing the
/// search effort (decisions / backtracks / propagations) and wall-clock
/// to find a single solution. The lightest decision count is highlighted
/// — a teaching aid for "which variable/value ordering fits this
/// problem". Wall-clock is shown but noisy (JIT warmup on the first run),
/// so the pedagogical signal is the decision/backtrack counts.
class _StrategyStatsTable extends StatelessWidget {
  final List<SearchStrategyStat> stats;

  const _StrategyStatsTable({required this.stats});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    // The best (fewest decisions) among strategies that found a solution.
    final solved = stats.where((s) => s.found).toList();
    final bestDecisions = solved.isEmpty
        ? null
        : solved.map((s) => s.decisions).reduce((a, b) => a < b ? a : b);

    final headerStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        );
    const numStyle = TextStyle(fontFamily: 'monospace', fontSize: 12);

    TableRow row(List<Widget> cells) => TableRow(children: [
          for (final c in cells)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              child: c,
            ),
        ]);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.constraintsStrategyHeader,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              children: [
                row([
                  Text(t.constraintsStrategyCol, style: headerStyle),
                  Text(t.constraintsStrategyDecisions, style: headerStyle),
                  Text(t.constraintsStrategyBacktracks, style: headerStyle),
                  Text(t.constraintsStrategyPropagations, style: headerStyle),
                  Text(t.constraintsStrategyTime, style: headerStyle),
                ]),
                for (final s in stats)
                  row([
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (s.found &&
                            bestDecisions != null &&
                            s.decisions == bestDecisions)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(Icons.star,
                                size: 13, color: scheme.primary),
                          ),
                        Text(s.name,
                            style: TextStyle(
                                fontSize: 12,
                                color: s.found
                                    ? scheme.onSurface
                                    : scheme.onSurfaceVariant)),
                      ],
                    ),
                    Text(s.found ? '${s.decisions}' : '—', style: numStyle),
                    Text(s.found ? '${s.backtracks}' : '—', style: numStyle),
                    Text(s.found ? '${s.propagations}' : '—', style: numStyle),
                    Text(
                        s.found
                            ? '${(s.elapsedMicros / 1000).toStringAsFixed(1)} ms'
                            : '—',
                        style: numStyle),
                  ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Constraint-network (factor) graph for a DSL program — a structural
/// view drawn before/without solving. Variable nodes sit on a circle
/// (set variables as rounded squares); a binary constraint draws a
/// direct edge, an n-ary constraint a small square factor node wired to
/// each variable, and a unary constraint a dot on the node. Built on the
/// same circular-layout foundation as [_TourChart].
class _ConstraintGraph extends StatelessWidget {
  final DslStructure structure;

  const _ConstraintGraph({required this.structure});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    if (structure.variables.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.constraintsStructureHeader(
                structure.variables.length, structure.constraints.length),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: _ConstraintGraphPainter(
                  structure: structure,
                  scheme: scheme,
                  textStyle: Theme.of(context).textTheme.bodySmall ??
                      const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConstraintGraphPainter extends CustomPainter {
  final DslStructure structure;
  final ColorScheme scheme;
  final TextStyle textStyle;

  _ConstraintGraphPainter({
    required this.structure,
    required this.scheme,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final vars = structure.variables;
    final n = vars.length;
    const nodeR = 17.0;
    final center = Offset(size.width / 2, size.height / 2);
    final layoutR = size.shortestSide / 2 - nodeR - 8;
    final index = {for (var i = 0; i < n; i++) vars[i]: i};

    Offset posOf(int i) {
      // Single node sits at the centre; otherwise spread on a circle.
      if (n == 1) return center;
      final a = -pi / 2 + i * 2 * pi / n;
      return center + Offset(cos(a) * layoutR, sin(a) * layoutR);
    }

    final edgePaint = Paint()
      ..color = scheme.outline
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final factorFill = Paint()
      ..color = scheme.tertiary
      ..style = PaintingStyle.fill;
    final unaryPaint = Paint()
      ..color = scheme.secondary
      ..style = PaintingStyle.fill;

    // Edges + factor nodes first, so variable nodes render on top.
    for (final c in structure.constraints) {
      final ids = [
        for (final v in c.vars)
          if (index.containsKey(v)) index[v]!
      ];
      if (ids.isEmpty) continue;
      if (ids.length == 1) {
        // Unary: a small dot just outside the node.
        final p = posOf(ids.first);
        final dir =
            n == 1 ? const Offset(0, -1) : (p - center) / (p - center).distance;
        canvas.drawCircle(p + dir * (nodeR + 5), 3.5, unaryPaint);
      } else if (ids.length == 2) {
        canvas.drawLine(posOf(ids[0]), posOf(ids[1]), edgePaint);
      } else {
        // N-ary: a factor node at the centroid pulled toward the centre.
        var cx = 0.0, cy = 0.0;
        for (final id in ids) {
          final p = posOf(id);
          cx += p.dx;
          cy += p.dy;
        }
        var fp = Offset(cx / ids.length, cy / ids.length);
        fp = Offset.lerp(fp, center, 0.25)!;
        for (final id in ids) {
          canvas.drawLine(fp, posOf(id), edgePaint);
        }
        canvas.drawRect(
          Rect.fromCenter(center: fp, width: 11, height: 11),
          factorFill,
        );
      }
    }

    // Variable nodes.
    for (var i = 0; i < n; i++) {
      final p = posOf(i);
      final isSet = structure.setVars.contains(vars[i]);
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..color = isSet ? scheme.tertiaryContainer : scheme.primaryContainer;
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = isSet ? scheme.tertiary : scheme.primary;
      if (isSet) {
        final rrect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: p, width: nodeR * 2, height: nodeR * 2),
          const Radius.circular(5),
        );
        canvas.drawRRect(rrect, fill);
        canvas.drawRRect(rrect, ring);
      } else {
        canvas.drawCircle(p, nodeR, fill);
        canvas.drawCircle(p, nodeR, ring);
      }
      final tp = TextPainter(
        text: TextSpan(
          text: vars[i],
          style: textStyle.copyWith(
            color:
                isSet ? scheme.onTertiaryContainer : scheme.onPrimaryContainer,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: nodeR * 2 - 2);
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_ConstraintGraphPainter old) => old.structure != structure;
}

// === Cryptarithm tab ====================================================

class _CryptarithmTab extends StatefulWidget {
  const _CryptarithmTab();
  @override
  State<_CryptarithmTab> createState() => _CryptarithmTabState();
}

class _CryptarithmTabState extends State<_CryptarithmTab> {
  final _ctl = TextEditingController(text: 'SEND + MORE = MONEY');
  CryptarithmResult? _result;
  bool _solving = false;
  CspMusResult? _mus;
  bool _explaining = false;

  @override
  void initState() {
    super.initState();
    // Drain a pending `open:constraints?cryptarithm=<puzzle>` request
    // (set by the worked-examples / Function Reference dispatcher). The
    // sentinel carries the puzzle without spaces; prettify it back to
    // the tab's `WORD op WORD = WORD` display style.
    final puzzle = AppState().consumePendingCryptarithmPuzzle();
    if (puzzle != null && puzzle.trim().isNotEmpty) {
      _ctl.text = _prettifyCryptarithm(puzzle);
    }
  }

  /// Re-inserts spaces around the operators of a compact cryptarithm
  /// string (`SEND+MORE=MONEY` → `SEND + MORE = MONEY`) so a sentinel-
  /// supplied puzzle matches the field's hand-typed style. The solver
  /// strips whitespace anyway, so this is purely cosmetic.
  static String _prettifyCryptarithm(String raw) => raw
      .replaceAll(' ', '')
      .replaceAllMapped(RegExp(r'[+\-=]'), (m) => ' ${m[0]} ')
      .trim();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _solve() async {
    setState(() {
      _solving = true;
      _mus = null;
    });
    final r = await CspSolver.solveCryptarithm(_ctl.text);
    if (!mounted) return;
    setState(() {
      _solving = false;
      _result = r;
    });
  }

  Future<void> _explain() async {
    setState(() => _explaining = true);
    final r = await CspSolver.explainCryptarithm(_ctl.text);
    if (!mounted) return;
    setState(() {
      _explaining = false;
      _mus = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.constraintsCryptarithmIntro,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          TextField(
            controller: _ctl,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            decoration: InputDecoration(
              labelText: t.constraintsCryptarithmInputLabel,
              hintText: 'SEND + MORE = MONEY',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _solving ? null : _solve,
            icon: _solving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(t.constraintsSolveButton),
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            _CryptarithmResultBlock(result: _result!),
            // Surface Explain only on the "no assignment" case, not
            // on shape-parse errors where the model wasn't built.
            if (!_result!.ok && _result!.error!.contains('No assignment')) ...[
              const SizedBox(height: 12),
              _ExplainSection(
                isLoading: _explaining,
                result: _mus,
                onExplain: _explain,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// === DSL tab (CSP Round C) ==============================================

class _DslTab extends StatefulWidget {
  const _DslTab();
  @override
  State<_DslTab> createState() => _DslTabState();
}

class _DslTabState extends State<_DslTab> {
  // Round 72 gallery: each entry's `program` is a complete DSL
  // text that replaces the TextField on pick. The `id` doubles as
  // the i18n key for the localized title.
  static const List<({String id, String program})> _gallery = [
    (
      id: 'magicSum',
      program: '''vars: x, y, z in 1..9
allDifferent(x, y, z)
x + y + z == 15''',
    ),
    (
      // Classic 3×3 magic square: 9 distinct digits 1..9 with
      // every row, column, and main diagonal summing to 15.
      id: 'magicSquare3',
      program: '''vars: a, b, c, d, e, f, g, h, i in 1..9
allDifferent(a, b, c, d, e, f, g, h, i)
a + b + c == 15
d + e + f == 15
g + h + i == 15
a + d + g == 15
b + e + h == 15
c + f + i == 15
a + e + i == 15
c + e + g == 15''',
    ),
    (
      // 4×4 magic square: 16 distinct values 1..16 with every
      // row, column, and main diagonal summing to the magic
      // constant M = N(N²+1)/2 = 4·17/2 = 34. Solving the
      // program is itself a generator — there are 7040 distinct
      // 4×4 magic squares (ignoring symmetry), so the solver
      // returns one of them.
      id: 'magicSquare4',
      program: '''vars: a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p in 1..16
allDifferent(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p)
a + b + c + d == 34
e + f + g + h == 34
i + j + k + l == 34
m + n + o + p == 34
a + e + i + m == 34
b + f + j + n == 34
c + g + k + o == 34
d + h + l + p == 34
a + f + k + p == 34
d + g + j + m == 34''',
    ),
    (
      // Four mutually-adjacent regions colored with 3 colors.
      // Adjacency: 1-2, 1-3, 1-4, 2-3, 2-4, 3-4 — a complete
      // K4 graph, which is NOT 3-colorable, so this enumerates
      // zero solutions. Edit to drop one edge for solutions.
      id: 'mapColoring',
      program: '''vars: r1, r2, r3, r4 in 1..3
r1 != r2
r1 != r3
r2 != r3
r3 != r4
r2 != r4''',
    ),
    (
      // The canonical map-coloring CSP (Russell & Norvig): color
      // the seven Australian states/territories so that no two
      // adjacent regions share a color. Three colors suffice
      // (the map is planar). Variables: wa=Western Australia,
      // nt=Northern Territory, sa=South Australia, q=Queensland,
      // nsw=New South Wales, v=Victoria, t=Tasmania. Tasmania is
      // an island with no land border, so it carries no
      // adjacency constraint and is freely colorable.
      id: 'mapColoringAustralia',
      program: '''vars: wa, nt, sa, q, nsw, v, t in 1..3
wa != nt
wa != sa
nt != sa
nt != q
sa != q
sa != nsw
sa != v
q != nsw
nsw != v''',
    ),
    (
      // Germany's 16 Bundesländer (ISO 3166-2:DE codes as variable
      // names: bw=Baden-Württemberg, by=Bayern, be=Berlin,
      // bb=Brandenburg, hb=Bremen, hh=Hamburg, he=Hessen,
      // mv=Mecklenburg-Vorpommern, ni=Niedersachsen,
      // nw=Nordrhein-Westfalen, rp=Rheinland-Pfalz, sl=Saarland,
      // sn=Sachsen, st=Sachsen-Anhalt, sh=Schleswig-Holstein,
      // th=Thüringen). Unlike Australia (3-colorable), this map needs
      // FOUR colors: Thüringen borders five states (ni, st, sn, by,
      // he) that themselves form a 5-cycle — a 5-wheel, whose
      // chromatic number is 4. So the domain here is 1..4; with only
      // three colors the program is unsatisfiable. Berlin (be) sits
      // entirely inside Brandenburg (bb); Bremen (hb) inside
      // Niedersachsen (ni) — both classic enclaves.
      id: 'mapColoringGermany',
      program:
          '''vars: bw, by, be, bb, hb, hh, he, mv, ni, nw, rp, sl, sn, st, sh, th in 1..4
sh != hh
sh != ni
sh != mv
hh != ni
mv != ni
mv != bb
ni != hb
ni != st
ni != bb
ni != th
ni != he
ni != nw
st != bb
st != sn
st != th
bb != be
bb != sn
nw != he
nw != rp
he != rp
he != by
he != th
th != sn
th != by
sn != by
rp != sl
rp != bw
rp != by
sl != bw
bw != by''',
    ),
    (
      // Triples of strictly-increasing positive integers summing
      // to 20: a < b < c, a+b+c=20, with a,b,c in 1..20.
      id: 'orderedTriples',
      program: '''vars: a, b, c in 1..20
a + b + c == 20
a < b
b < c''',
    ),
    (
      // Set partitioning / equal-sum split. Given the multiset
      // {4, 3, 2, 3, 2, 2} (total 16), split it into two groups
      // of equal sum (8 each). One 0/1 indicator per number
      // selects it into group A; the linear constraint forces
      // group A's weighted sum to half the total. The unselected
      // numbers form group B, whose sum is then also 8. A 1 in
      // the solution means "this number goes in group A".
      id: 'equalSumSplit',
      program: '''vars: b1, b2, b3, b4, b5, b6 in 0..1
4*b1 + 3*b2 + 2*b3 + 3*b4 + 2*b5 + 2*b6 == 8''',
    ),
    (
      // Round 74: textbook coin-change. Pay 17 cents with the
      // fewest coins drawn from {1, 5, 10, 25}. The minimize
      // directive returns the unique optimum (one 10 + one 5 +
      // two 1s = four coins) plus the objective value.
      id: 'coinChangeMin',
      program: '''vars: pennies in 0..17
vars: nickels in 0..3
vars: dimes in 0..1
vars: quarters in 0..0
pennies + 5*nickels + 10*dimes + 25*quarters == 17
minimize pennies + nickels + dimes + quarters''',
    ),
    (
      // 0/1 knapsack: four items with weights {2,3,4,5} and values
      // {3,4,5,6}, knapsack capacity 5. One 0/1 indicator per item;
      // the linear constraint caps total weight, and `maximize`
      // (branch-and-bound) returns the optimal-value subset. Optimum:
      // items 1+2 (weight 5, value 7).
      id: 'knapsack',
      program: '''vars: x1, x2, x3, x4 in 0..1
2*x1 + 3*x2 + 4*x3 + 5*x4 <= 5
maximize 3*x1 + 4*x2 + 5*x3 + 6*x4''',
    ),
    (
      // Linear production planning: make `a` units of product A and
      // `b` of product B to maximize profit (3 per A, 5 per B) subject
      // to two shared resources — machine hours (2·A + B ≤ 10) and
      // labour (A + 3·B ≤ 15). Integer branch-and-bound. Optimum:
      // a=3, b=4 → profit 29 (both resources fully consumed).
      id: 'productionPlanning',
      program: '''vars: a, b in 0..10
2*a + b <= 10
a + 3*b <= 15
maximize 3*a + 5*b''',
    ),
    (
      // Assignment problem: assign 3 workers to 3 tasks at minimum
      // total cost. x_ij = 1 iff worker i does task j. Each worker
      // takes exactly one task (row sums = 1) and each task is taken
      // by exactly one worker (column sums = 1). The objective sums
      // the chosen cells of the cost matrix
      //   [[9,2,7],[6,4,3],[5,8,1]].
      // Optimum cost 9: w1→t2 (2), w2→t1 (6), w3→t3 (1).
      id: 'assignmentMinCost',
      program: '''vars: x11, x12, x13, x21, x22, x23, x31, x32, x33 in 0..1
x11 + x12 + x13 == 1
x21 + x22 + x23 == 1
x31 + x32 + x33 == 1
x11 + x21 + x31 == 1
x12 + x22 + x32 == 1
x13 + x23 + x33 == 1
minimize 9*x11 + 2*x12 + 7*x13 + 6*x21 + 4*x22 + 3*x23 + 5*x31 + 8*x32 + 1*x33''',
    ),
    (
      // Balanced transportation problem (min-cost distribution).
      // Two warehouses with supplies S1=4, S2=6 ship to three
      // customers with demands D1=3, D2=3, D3=4. Supply == demand,
      // so every warehouse row and customer column is an equality.
      // x_ij is the integer number of units shipped from warehouse i
      // to customer j; the unit-cost matrix is
      //   [[4, 6, 8], [9, 5, 3]].
      // Branch-and-bound returns the unique min-cost plan, total 40:
      //   x11=3, x12=1, x22=2, x23=4 (every other route unused).
      id: 'transportation',
      program: '''vars: x11, x12, x13, x21, x22, x23 in 0..6
x11 + x12 + x13 == 4
x21 + x22 + x23 == 6
x11 + x21 == 3
x12 + x22 == 3
x13 + x23 == 4
minimize 4*x11 + 6*x12 + 8*x13 + 9*x21 + 5*x22 + 3*x23''',
    ),
    (
      // Round 77: single-machine scheduling with minimum makespan.
      // Three tasks of durations 4, 3, 2 must run without overlap;
      // the `noOverlap` overlay enforces pairwise disjointness on
      // the half-open intervals [start, start+duration). The
      // makespan variable bounds each task's end and is what we
      // minimize. Optimal makespan = 4+3+2 = 9; in this instance
      // the solver returns one of the equally-good orderings.
      id: 'schedulingMakespan',
      program: '''vars: s1, s2, s3 in 0..9
vars: makespan in 0..9
noOverlap(s1=4, s2=3, s3=2)
s1 + 4 <= makespan
s2 + 3 <= makespan
s3 + 2 <= makespan
minimize makespan''',
    ),
    (
      // Round 80: parallel-resource scheduling. Three tasks share a
      // renewable resource of capacity 2: task s1 alone consumes the
      // whole resource (demand 2, duration 2), while s2 and s3 each
      // demand 1 and so can run in parallel with each other. Total
      // work = 2·2 + 3·1 + 4·1 = 11; with capacity 2 the makespan
      // lower bound is ⌈11/2⌉ = 6. Achieved e.g. by running s2 + s3
      // parallel from t=0..3, s3 alone t=3..4, then s1 from t=4..6.
      id: 'cumulativeScheduling',
      program: '''vars: s1, s2, s3 in 0..6
vars: makespan in 0..6
cumulative(s1=2@2, s2=3@1, s3=4@1; capacity=2)
s1 + 2 <= makespan
s2 + 3 <= makespan
s3 + 4 <= makespan
minimize makespan''',
    ),
    (
      // Round 84: multi-resource project scheduling (RCPSP — the
      // classical resource-constrained project scheduling
      // problem). Four tasks share two renewable resources, each
      // of capacity 3 — interpret as a crew of 3 and an
      // equipment pool of 3.
      //
      //   Task | dur | crew | equip
      //     s1 |  3  |   2  |   1
      //     s2 |  4  |   1  |   2
      //     s3 |  2  |   2  |   2
      //     s4 |  3  |   1  |   1
      //
      // s2 + s3 together demand equip = 4 > 3 capacity, so they
      // cannot overlap on equipment — that constraint is the
      // binding resource. Lower bound on makespan is
      // max(⌈17/3⌉, ⌈18/3⌉, dur(s2)+dur(s3)) = 6. Achieved by
      // s1=0, s2=0, s3=4, s4=3 → makespan 6.
      id: 'rcpsp',
      program: '''vars: s1, s2, s3, s4 in 0..6
vars: makespan in 0..6
cumulative(s1=3@2, s2=4@1, s3=2@2, s4=3@1; capacity=3)
cumulative(s1=3@1, s2=4@2, s3=2@2, s4=3@1; capacity=3)
s1 + 3 <= makespan
s2 + 4 <= makespan
s3 + 2 <= makespan
s4 + 3 <= makespan
minimize makespan''',
    ),
    (
      // Round 108: logic-grid deduction. `implies` and `exactly` over
      // `name=value` conditions are the vocabulary logic-grid riddles
      // ("Einstein"/"zebra" puzzles) are built from. Ann, Bob and Cy
      // each pick a different pet; two clues prune the permutations.
      id: 'logicGrid',
      program: '''# Ann, Bob, Cy each pick a different pet.
# 1 = cat, 2 = dog, 3 = fish.
vars: ann, bob, cy in 1..3
allDifferent(ann, bob, cy)
ann != 3
implies(bob=1, cy=2)
exactly(1, ann=1, bob=1)''',
    ),
    (
      // Round 108: nurse rostering. `atMostInARow` compiles to a small
      // regular-language (DFA) automaton — the natural way to express
      // "no more than k of a shift back-to-back"; `gcc` pins the exact
      // number of days off across the week.
      id: 'nurseRostering',
      program: '''# One nurse's 5-day plan. 0 = off, 1 = day, 2 = night.
vars: d1, d2, d3, d4, d5 in 0..2
atMostInARow(d1, d2, d3, d4, d5; value=1; max=2)
atMostInARow(d1, d2, d3, d4, d5; value=2; max=1)
gcc(d1, d2, d3, d4, d5; 0=2)''',
    ),
    (
      // Round 108: chromatic number. `nvalue` counts the distinct
      // values (colours); minimizing it finds the fewest colours a
      // graph needs. An odd cycle (here a 5-cycle) needs 3.
      id: 'chromaticNumber',
      program: '''# Fewest colours for a 5-cycle (odd cycle => 3).
vars: a, b, c, d, e in 1..5
vars: colors in 1..5
a != b
b != c
c != d
d != e
e != a
nvalue(a, b, c, d, e; count=colors)
minimize colors''',
    ),
    (
      // Round 108: the `table` constraint — restrict a tuple to an
      // explicit set of allowed rows (a compatibility matrix). Here a
      // café only offers certain (main, side) pairings; enumerating the
      // program lists exactly the menu.
      id: 'menuPairing',
      program: '''# Café menu — only these (main, side) pairings are offered.
# main: 1 soup / 2 salad / 3 pasta   side: 1 bread / 2 fries / 3 fruit
vars: main, side in 1..3
table(main, side; (1,1), (1,3), (2,2), (2,3), (3,1), (3,2))''',
    ),
    (
      // Round 108 (C8): 2D packing with `diffN`. Three differently
      // shaped tiles are placed without overlap inside a 4×4 box; the
      // result renders as a scaled floor-plan layout. Each tuple is
      // (xVar, yVar, width, height) with the lower-left at (x, y).
      id: 'packing',
      program: '''# Pack three tiles into a 4×4 box — no overlaps.
# Each tuple is (xVar, yVar, width, height).
vars: ax, ay, bx, by, cx, cy in 0..2
diffN((ax,ay,2,2), (bx,by,2,1), (cx,cy,1,2))''',
    ),
    (
      // Round 109 (C8): a single tour over successor variables with the
      // `circuit` constraint — a TSP / delivery-routing skeleton. Each
      // variable is the index of the stop visited next; enumerating the
      // program lists every Hamiltonian tour, drawn as a directed
      // node-graph in the DSL tab.
      id: 'deliveryRoute',
      program: '''# Delivery route — visit all four stops once, back to depot.
# next[i] = index of the stop visited after stop i (0=depot … 3=park).
vars: depot, shop, bank, park in 0..3
circuit(depot, shop, bank, park; labels=Depot, Shop, Bank, Park)''',
    ),
    (
      // Round 110 (C8): over-constrained scheduling with soft
      // preferences. The hard constraint forces two shifts apart; three
      // weighted preferences pull in conflicting directions, so the
      // MaxCSP solver keeps the heaviest satisfiable set.
      id: 'shiftPrefs',
      program: '''# Two people, three time slots (0,1,2). They must differ.
# Weighted preferences — the solver keeps the best satisfiable set.
vars: alex, bo in 0..2
alex != bo
soft(3): alex = 0     # Alex strongly prefers the early slot
soft(2): bo = 0       # Bo also wants it (they can't both have it)
soft(1): alex = bo    # a nice-to-have that the hard rule forbids''',
    ),
    (
      // Round 111 (C8): set-variable committee selection. Pick a 3-member
      // committee and a disjoint 2-member reserve bench from a pool of 5,
      // with one member pinned. Solutions render as chip clusters.
      id: 'committee',
      program: '''# Pick a committee + a disjoint reserve bench from 5 people.
# Universe 1..5 = the five candidates; member 1 must be on the committee.
set Committee, Bench from 1..5
card(Committee) = 3
card(Bench) = 2
disjoint(Committee, Bench)
Committee contains 1''',
    ),
  ];

  final _ctl = TextEditingController(text: _gallery.first.program);
  DiophantineResult? _result;
  bool _solving = false;
  CspMusResult? _mus;
  bool _explaining = false;
  // Round E.3: FlatZinc export state. Cleared on every fresh
  // solve / example load so a stale translation can't linger
  // after the user has edited the program.
  FlatZincExportResult? _export;
  // Round F: propagation step-trace for the visualizer. Cleared on
  // every fresh solve / example load / export so a stale replay can't
  // linger after the program changed.
  CspTraceResult? _trace;
  bool _tracing = false;
  // Round 113 (C9): constraint-network structure graph. Computed
  // synchronously from the program text; cleared on every fresh
  // solve / example load / export so it can't outlive its program.
  DslStructure? _structure;

  @override
  void initState() {
    super.initState();
    // Round 73: if the user got here via a `dsl:<id>` worked-
    // example sentinel, AppState carries the pending gallery id.
    // Drain it and load the matching program.
    final pendingId = AppState().consumePendingDslProgramId();
    if (pendingId != null) {
      for (final entry in _gallery) {
        if (entry.id == pendingId) {
          _ctl.text = entry.program;
          break;
        }
      }
    }
  }

  void _loadExample(String programText) {
    setState(() {
      _ctl.text = programText;
      _result = null;
      _mus = null;
      _export = null;
      _trace = null;
      _structure = null;
    });
  }

  void _doExport() {
    setState(() {
      _export = DslToFlatZinc.export(_ctl.text);
      _trace = null;
      _structure = null;
    });
  }

  // Round 113 (C9): compute + reveal the constraint-network graph. A
  // synchronous structural parse — no solving — so no spinner needed.
  void _showStructure() {
    setState(() {
      _structure = CspSolver.analyzeDslStructure(_ctl.text);
      _export = null;
      _trace = null;
    });
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _solve({bool compareStrategies = false}) async {
    setState(() {
      _solving = true;
      _mus = null;
      _export = null;
      _trace = null;
      _structure = null;
    });
    final r = await CspSolver.solveDsl(_ctl.text,
        compareStrategies: compareStrategies);
    if (!mounted) return;
    setState(() {
      _solving = false;
      _result = r;
    });
  }

  // Round F: build a propagation step-trace and reveal the AC-3
  // replay visualizer. Independent of the Solve result block — the
  // user can visualize without first solving.
  Future<void> _visualize() async {
    setState(() {
      _tracing = true;
      _export = null;
    });
    final r = await CspSolver.traceDsl(_ctl.text);
    if (!mounted) return;
    setState(() {
      _tracing = false;
      _trace = r;
    });
  }

  Future<void> _explain() async {
    setState(() => _explaining = true);
    final r = await CspSolver.explainDsl(_ctl.text);
    if (!mounted) return;
    setState(() {
      _explaining = false;
      _mus = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.constraintsDslIntro,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          TextField(
            controller: _ctl,
            minLines: 6,
            maxLines: 16,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              labelText: t.constraintsDslInputLabel,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _solving ? null : _solve,
                icon: _solving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(t.constraintsSolveButton),
              ),
              // Round 72: pre-built example programs. Selecting a
              // menu item replaces the TextField with that program.
              PopupMenuButton<String>(
                tooltip: t.constraintsDslExamplesTooltip,
                onSelected: _loadExample,
                itemBuilder: (context) => [
                  for (final entry in _gallery)
                    PopupMenuItem<String>(
                      value: entry.program,
                      child: Text(t.constraintsDslExampleTitle(entry.id)),
                    ),
                ],
                child: OutlinedButton.icon(
                  // The PopupMenuButton's child handles taps; the
                  // button's own onPressed is intentionally null.
                  onPressed: null,
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: Text(t.constraintsDslExamplesButton),
                ),
              ),
              // Round E.3: emit a FlatZinc translation of the
              // currently-typed program. Sits next to Examples so
              // the cluster of "what to do with this DSL"
              // affordances stays in one place.
              OutlinedButton.icon(
                onPressed: _doExport,
                icon: const Icon(Icons.code, size: 18),
                label: Text(t.constraintsExportFlatZinc),
              ),
              // Round F: AC-3 propagation step-trace visualizer.
              OutlinedButton.icon(
                onPressed: _tracing ? null : _visualize,
                icon: _tracing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.slideshow_outlined, size: 18),
                label: Text(t.constraintsVisualizeButton),
              ),
              // Round 112 (C8): run the same program under several
              // search heuristics and show a solver-stats comparison.
              OutlinedButton.icon(
                onPressed:
                    _solving ? null : () => _solve(compareStrategies: true),
                icon: const Icon(Icons.speed_outlined, size: 18),
                label: Text(t.constraintsCompareStrategies),
              ),
              // Round 113 (C9): draw the constraint-network graph.
              OutlinedButton.icon(
                onPressed: _showStructure,
                icon: const Icon(Icons.hub_outlined, size: 18),
                label: Text(t.constraintsStructureButton),
              ),
            ],
          ),
          // Round 105b (P6): in help mode, reveal a reference row of
          // the DSL operators. The DSL operators have no standing UI
          // (they live in the program text), so this row IS their
          // per-element help surface — each chip opens the Function
          // Reference popover for that operator.
          const _DslOperatorHelpRow(),
          if (_result != null) ...[
            const SizedBox(height: 16),
            _ResultBlock(result: _result!),
            if (_result!.ok && _result!.solutions.isEmpty) ...[
              const SizedBox(height: 12),
              _ExplainSection(
                isLoading: _explaining,
                result: _mus,
                onExplain: _explain,
              ),
            ],
          ],
          if (_export != null) ...[
            const SizedBox(height: 16),
            _FlatZincExportBlock(result: _export!),
          ],
          if (_trace != null) ...[
            const SizedBox(height: 16),
            if (_trace!.ok)
              PropagationVisualizer(trace: _trace!)
            else
              _TraceErrorBlock(message: _trace!.error!),
          ],
          if (_structure != null) ...[
            const SizedBox(height: 16),
            if (_structure!.ok)
              _ConstraintGraph(structure: _structure!)
            else
              _TraceErrorBlock(message: _structure!.error!),
          ],
        ],
      ),
    );
  }
}

/// Round F: friendly error surface when a program can't be traced
/// (parse error, no variables, etc.). Mirrors the export error block.
class _TraceErrorBlock extends StatelessWidget {
  final String message;
  const _TraceErrorBlock({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
            child:
                Text(message, style: TextStyle(color: scheme.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}

/// Round 105b (P6): operator reference + help row for the DSL tab.
/// Hidden outside help mode (the tab's normal UX is unchanged); in
/// help mode it shows one chip per mini-DSL operator, each opening
/// that operator's Function Reference popover. This is the DSL's
/// per-element help surface, since the operators otherwise live only
/// inside the free-form program text.
/// (chip label, FunctionRef id) for every mini-DSL operator surfaced as
/// a help-mode chip. Public so a test can assert the row is exhaustive
/// (every operator present) and each refId resolves to a catalogue
/// entry. Keep in sync with the keywords `CspSolver.solveDsl` accepts.
const dslOperatorHelpChips = <(String, String)>[
  ('vars:', 'vars'),
  ('allDifferent', 'all_different'),
  ('noOverlap', 'no_overlap'),
  ('cumulative', 'cumulative'),
  // Round 108 globals.
  ('atLeast', 'at_least'),
  ('atMost', 'at_most'),
  ('exactly', 'exactly'),
  ('implies', 'implies'),
  ('gcc', 'gcc'),
  ('among', 'among'),
  ('nvalue', 'nvalue'),
  ('atMostInARow', 'at_most_in_a_row'),
  ('valuePrecedence', 'value_precedence'),
  ('table', 'table'),
  ('element', 'element'),
  ('diffN', 'diff_n'),
  ('circuit', 'circuit'),
  ('soft', 'soft'),
  ('set', 'set_var'),
  ('card', 'set_var'),
  ('subset', 'set_var'),
  ('disjoint', 'set_var'),
  ('minimize', 'minimize'),
  ('maximize', 'maximize'),
];

class _DslOperatorHelpRow extends StatelessWidget {
  const _DslOperatorHelpRow();

  static const _operators = dslOperatorHelpChips;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        if (!AppState().helpMode) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final (label, refId) in _operators)
                HelpTarget(
                  onHelpTap: () => showFunctionRefHelpPopover(context, refId),
                  child: ActionChip(
                    label: Text(
                      label,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 12),
                    ),
                    onPressed: () => showFunctionRefHelpPopover(context, refId),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Renders a [FlatZincExportResult]: either a copyable monospace
/// block with the translated FlatZinc text, or a friendly error
/// when the DSL didn't translate cleanly. Round E.3.
class _FlatZincExportBlock extends StatelessWidget {
  final FlatZincExportResult result;
  const _FlatZincExportBlock({required this.result});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (!result.ok) {
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
    final src = result.source!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(t.constraintsExportedHeader,
                style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: t.constraintsCopyResult,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: src));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.constraintsCopiedToast),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: SelectableText(
            src,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _CryptarithmResultBlock extends StatelessWidget {
  final CryptarithmResult result;
  const _CryptarithmResultBlock({required this.result});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (!result.ok) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
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
    final sorted = result.assignment.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final body = sorted.map((e) => '${e.key} = ${e.value}').join('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.constraintsCryptarithmFoundHeader,
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: SelectableText(
            body,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// === FlatZinc tab (CSP Round E.1) =======================================

class _FlatZincTab extends StatefulWidget {
  const _FlatZincTab();
  @override
  State<_FlatZincTab> createState() => _FlatZincTabState();
}

class _FlatZincTabState extends State<_FlatZincTab> {
  // Gallery of canonical FlatZinc snippets. Hand-written to be
  // small enough to read in the textarea; the dart_csp HEAD's
  // FlatZinc parser handles the full spec, so users can paste
  // anything mzn2fzn produces.
  static const List<({String id, String source})> _gallery = [
    (
      // 4-queens: row index implicit, queen[i] = column. Pairwise
      // diagonals via int_lin_ne (queen[i] - queen[j] != ±(i-j)).
      id: 'nqueens4',
      source: '''array[1..4] of var 1..4: q :: output_array([1..4]);
constraint all_different_int(q);
constraint int_lin_ne([1, -1], [q[1], q[2]], 1);
constraint int_lin_ne([1, -1], [q[1], q[2]], -1);
constraint int_lin_ne([1, -1], [q[1], q[3]], 2);
constraint int_lin_ne([1, -1], [q[1], q[3]], -2);
constraint int_lin_ne([1, -1], [q[1], q[4]], 3);
constraint int_lin_ne([1, -1], [q[1], q[4]], -3);
constraint int_lin_ne([1, -1], [q[2], q[3]], 1);
constraint int_lin_ne([1, -1], [q[2], q[3]], -1);
constraint int_lin_ne([1, -1], [q[2], q[4]], 2);
constraint int_lin_ne([1, -1], [q[2], q[4]], -2);
constraint int_lin_ne([1, -1], [q[3], q[4]], 1);
constraint int_lin_ne([1, -1], [q[3], q[4]], -1);
solve satisfy;
''',
    ),
    (
      // Bin-packing: 3 items of sizes [2, 3, 5] across 2 bins of
      // capacity 5. bin_packing_load propagates load[b] = sum of
      // sizes of items assigned to bin b.
      id: 'binPacking',
      source: '''array[1..2] of var 0..5: load :: output_array([1..2]);
array[1..3] of var 1..2: bin :: output_array([1..3]);
constraint bin_packing_load(load, bin, [2, 3, 5]);
solve satisfy;
''',
    ),
  ];

  final _ctl = TextEditingController(text: _gallery.first.source);
  bool _allSolutions = false;
  bool _solving = false;
  String? _output;
  String? _error;
  CspMusResult? _mus;
  bool _explaining = false;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _loadExample(String source) {
    setState(() {
      _ctl.text = source;
      _output = null;
      _error = null;
      _mus = null;
    });
  }

  Future<void> _solve() async {
    final source = _ctl.text;
    setState(() {
      _solving = true;
      _output = null;
      _error = null;
      _mus = null;
    });
    String? out;
    String? err;
    try {
      out = await FlatZinc.solve(source, all: _allSolutions);
    } catch (e) {
      err = e.toString();
    }
    if (!mounted) return;
    setState(() {
      _solving = false;
      _output = out;
      _error = err;
    });
  }

  Future<void> _explain() async {
    setState(() => _explaining = true);
    final r = await CspSolver.explainFlatZinc(_ctl.text);
    if (!mounted) return;
    setState(() {
      _explaining = false;
      _mus = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.constraintsFlatZincIntro,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          TextField(
            controller: _ctl,
            minLines: 8,
            maxLines: 20,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              labelText: t.constraintsFlatZincInputLabel,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _solving ? null : _solve,
                icon: _solving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(t.constraintsSolveButton),
              ),
              FilterChip(
                label: Text(t.constraintsFlatZincAllSolutions),
                selected: _allSolutions,
                onSelected: (v) => setState(() => _allSolutions = v),
              ),
              PopupMenuButton<String>(
                tooltip: t.constraintsDslExamplesTooltip,
                onSelected: _loadExample,
                itemBuilder: (context) => [
                  for (final entry in _gallery)
                    PopupMenuItem<String>(
                      value: entry.source,
                      child: Text(t.constraintsFlatZincExampleTitle(entry.id)),
                    ),
                ],
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: Text(t.constraintsDslExamplesButton),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            _FlatZincErrorBlock(message: _error!),
          ],
          if (_output != null) ...[
            const SizedBox(height: 16),
            _FlatZincOutputBlock(text: _output!),
            if (_output!.contains('=====UNSATISFIABLE=====')) ...[
              const SizedBox(height: 12),
              _ExplainSection(
                isLoading: _explaining,
                result: _mus,
                onExplain: _explain,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _FlatZincErrorBlock extends StatelessWidget {
  final String message;
  const _FlatZincErrorBlock({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
            child: SelectableText(
              message,
              style: TextStyle(
                color: scheme.onErrorContainer,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlatZincOutputBlock extends StatelessWidget {
  final String text;
  const _FlatZincOutputBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // Standard FlatZinc output ends with `==========` when search
    // is exhaustive (every solution found, or optimization proven
    // optimal), or `=====UNSATISFIABLE=====` when no solution exists.
    final trimmed = text.trim();
    final isUnsat = trimmed.contains('=====UNSATISFIABLE=====');
    final isExhaustive = trimmed.endsWith('==========');
    final solCount = '\n$trimmed'.split('\n----------').length - 1;
    final header = isUnsat
        ? t.constraintsFlatZincUnsatisfiable
        : isExhaustive
            ? (solCount == 1
                ? t.constraintsFlatZincExhaustiveOne
                : t.constraintsFlatZincExhaustiveN(solCount))
            : t.constraintsFlatZincFirstSolution;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(header, style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: t.constraintsCopyResult,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: text));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.constraintsCopiedToast),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: SelectableText(
            text,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// === Round E.2 — shared "Explain failure" / MUS rendering =================

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
              for (final entry in result.entries)
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
        ),
      ],
    );
  }
}
