// lib/screens/constraints/result_views.dart
//
// Solution views shared by the constraint tabs: result block, schedule,
// packing and tour charts, soft constraints, set solutions, strategy
// statistics and constraint/colouring graphs.

part of '../constraints_screen.dart';

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
        // General graph-colouring overlay: any program with binary `!=`
        // edges (map colouring, chromatic number, scheduling conflicts)
        // draws the network with each node filled by its solved value.
        // Suppressed when a bespoke schematic map already handles it.
        if (result.colorEdges.isNotEmpty &&
            result.solutions.isNotEmpty &&
            !AustraliaMapView.matches(result.solutions.first) &&
            !GermanyMapView.matches(result.solutions.first)) ...[
          const SizedBox(height: 12),
          _ColorGraph(
            edges: result.colorEdges,
            assignment: result.solutions.first,
          ),
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
/// problem". The final row is min-conflicts *local search* — a different
/// solver family measured in iterations (the backtracking counters read
/// `·`), so the table contrasts systematic search against guess-and-
/// repair. Wall-clock is shown but noisy (JIT warmup on the first run),
/// so the pedagogical signal is the decision / iteration counts.
class _StrategyStatsTable extends StatelessWidget {
  final List<SearchStrategyStat> stats;

  const _StrategyStatsTable({required this.stats});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    // The best (fewest decisions) among *backtracking* strategies that
    // found a solution — min-conflicts is a different family (measured in
    // iterations) and never competes for the fewest-decisions star.
    final solved = stats.where((s) => s.found && !s.isLocalSearch).toList();
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
                  Text(t.constraintsStrategyIterations, style: headerStyle),
                  Text(t.constraintsStrategyTime, style: headerStyle),
                ]),
                for (final s in stats)
                  row([
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (s.found &&
                            !s.isLocalSearch &&
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
                    // Backtracking counters — n/a ('·') for local search.
                    Text(
                        s.isLocalSearch
                            ? '·'
                            : (s.found ? '${s.decisions}' : '—'),
                        style: numStyle),
                    Text(
                        s.isLocalSearch
                            ? '·'
                            : (s.found ? '${s.backtracks}' : '—'),
                        style: numStyle),
                    Text(
                        s.isLocalSearch
                            ? '·'
                            : (s.found ? '${s.propagations}' : '—'),
                        style: numStyle),
                    // Iterations — n/a ('·') for backtracking search.
                    Text(
                        !s.isLocalSearch
                            ? '·'
                            : (s.found ? '${s.iterations}' : '—'),
                        style: numStyle),
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

/// Graph-colouring render: the `!=` network drawn with each node filled
/// by its solved value's colour. Makes "no two adjacent nodes share a
/// colour" visible for map-colouring / chromatic-number programs. Built
/// on the same circular layout as [_TourChart] / [_ConstraintGraph].
class _ColorGraph extends StatelessWidget {
  final List<List<String>> edges;
  final DiophantineSolution assignment;

  const _ColorGraph({required this.edges, required this.assignment});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    // Nodes = variables that appear in an edge, in first-seen order.
    final nodes = <String>[];
    for (final e in edges) {
      for (final v in e) {
        if (!nodes.contains(v)) nodes.add(v);
      }
    }
    if (nodes.isEmpty) return const SizedBox.shrink();
    // Distinct solved values → colour count (the chromatic number used).
    final colours = {for (final n in nodes) assignment[n]}.length;
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
            t.constraintsColorGraphHeader(nodes.length, colours),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: CustomPaint(
                painter: _ColorGraphPainter(
                  nodes: nodes,
                  edges: edges,
                  assignment: assignment,
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

class _ColorGraphPainter extends CustomPainter {
  final List<String> nodes;
  final List<List<String>> edges;
  final DiophantineSolution assignment;
  final ColorScheme scheme;
  final TextStyle textStyle;

  _ColorGraphPainter({
    required this.nodes,
    required this.edges,
    required this.assignment,
    required this.scheme,
    required this.textStyle,
  });

  // A qualitative palette indexed by the solved value. Distinct hues so
  // adjacent-node difference reads at a glance; cycles beyond its length.
  static const List<Color> _palette = [
    Color(0xFF1976D2), // blue
    Color(0xFFE64A19), // deep orange
    Color(0xFF388E3C), // green
    Color(0xFFFBC02D), // yellow
    Color(0xFF7B1FA2), // purple
    Color(0xFF00796B), // teal
    Color(0xFFC2185B), // pink
    Color(0xFF5D4037), // brown
  ];

  Color _colourFor(int? value) => value == null
      ? scheme.surfaceContainerHighest
      : _palette[value % _palette.length];

  @override
  void paint(Canvas canvas, Size size) {
    final n = nodes.length;
    const nodeR = 16.0;
    final center = Offset(size.width / 2, size.height / 2);
    final layoutR = size.shortestSide / 2 - nodeR - 8;
    final index = {for (var i = 0; i < n; i++) nodes[i]: i};

    Offset posOf(int i) {
      if (n == 1) return center;
      final a = -pi / 2 + i * 2 * pi / n;
      return center + Offset(cos(a) * layoutR, sin(a) * layoutR);
    }

    final edgePaint = Paint()
      ..color = scheme.outline
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (final e in edges) {
      final a = index[e[0]], b = index[e[1]];
      if (a == null || b == null) continue;
      canvas.drawLine(posOf(a), posOf(b), edgePaint);
    }

    for (var i = 0; i < n; i++) {
      final p = posOf(i);
      final value = assignment[nodes[i]];
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..color = _colourFor(value);
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.85);
      canvas.drawCircle(p, nodeR, fill);
      canvas.drawCircle(p, nodeR, ring);

      final tp = TextPainter(
        text: TextSpan(
          text: nodes[i],
          style: textStyle.copyWith(
            color: Colors.white,
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
  bool shouldRepaint(_ColorGraphPainter old) =>
      old.nodes != nodes || old.edges != edges || old.assignment != assignment;
}

// === Cryptarithm tab ====================================================
