// lib/widgets/sudoku_search_tree.dart
//
// Draws the guesses of a [SudokuExplanation] as a tree: each node is a
// guess, its children are the guesses made while it was in effect. Dead
// ends are red, the path to the solution green, and the guess in effect
// at the current visualizer step is ringed; guesses the replay has not
// reached yet are faded. Tapping a node jumps the
// visualizer to the step where that guess was made.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../engine/sudoku_explainer.dart';
import '../localization/app_localizations.dart';

class SudokuSearchTreeView extends StatelessWidget {
  final SudokuExplanation explanation;
  final int? currentNode;
  final int currentStep;
  final int side;
  final ValueChanged<int> onSelectStep;
  final AppLocalizations labels;

  const SudokuSearchTreeView({
    super.key,
    required this.explanation,
    required this.currentNode,
    required this.currentStep,
    required this.side,
    required this.onSelectStep,
    required this.labels,
  });

  static const double _dx = 22;
  static const double _dy = 30;
  static const double _pad = 12;
  static const double _hitRadius = 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final layout = _TreeLayout.of(explanation.tree);
    final width = layout.columns * _dx + 2 * _pad;
    final height = (layout.depth + 1) * _dy + 2 * _pad;
    Offset at(int id) =>
        Offset(_pad + _dx / 2 + layout.x[id] * _dx, _pad + layout.y[id] * _dy);

    final current = currentNode == null ? null : explanation.tree[currentNode!];
    String cell(int i) => 'r${i ~/ side + 1}c${i % side + 1}';

    void onTapUp(TapUpDetails details) {
      int? best;
      var bestDistance = _hitRadius;
      for (final node in explanation.tree) {
        final d = (at(node.id) - details.localPosition).distance;
        if (d <= bestDistance) {
          best = node.id;
          bestDistance = d;
        }
      }
      final step = best == null ? null : explanation.tree[best].step;
      if (step != null) onSelectStep(step);
    }

    return Column(
      key: const ValueKey('sudoku-search-tree'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labels.sudokuSearchTreeTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(labels.sudokuSearchTreeHint,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Semantics(
            label: labels.sudokuSearchTreeTitle,
            child: GestureDetector(
              onTapUp: onTapUp,
              child: CustomPaint(
                size: Size(width, height),
                painter: _TreePainter(
                  nodes: explanation.tree,
                  at: at,
                  current: currentNode,
                  currentStep: currentStep,
                  edge: scheme.outline,
                  open: scheme.onSurfaceVariant,
                  deadEnd: scheme.error,
                  solution: Colors.green.shade600,
                  ring: scheme.primary,
                ),
              ),
            ),
          ),
        ),
        if (current != null)
          Text('${cell(current.cell)} = ${current.value}',
              key: const ValueKey('sudoku-search-tree-current'),
              style:
                  theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
        if (explanation.treeTruncated)
          Text(labels.sudokuSearchTreeTruncated(explanation.tree.length),
              style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// Tidy-ish layout: leaves take consecutive columns in depth-first
/// order and a parent sits over the middle of its children.
class _TreeLayout {
  final List<double> x;
  final List<int> y;
  final int columns;
  final int depth;

  _TreeLayout(this.x, this.y, this.columns, this.depth);

  factory _TreeLayout.of(List<SudokuSearchNode> nodes) {
    final children = List.generate(nodes.length, (_) => <int>[]);
    final roots = <int>[];
    for (final node in nodes) {
      if (node.parent == null) {
        roots.add(node.id);
      } else {
        children[node.parent!].add(node.id);
      }
    }
    final x = List<double>.filled(nodes.length, 0);
    final y = List<int>.filled(nodes.length, 0);
    var next = 0, depth = 0;
    // Iterative post-order so deep searches cannot overflow the stack.
    for (final root in roots) {
      final stack = <(int, int, bool)>[(root, 0, false)];
      while (stack.isNotEmpty) {
        final (id, level, visited) = stack.removeLast();
        y[id] = level;
        depth = math.max(depth, level);
        if (children[id].isEmpty) {
          x[id] = (next++).toDouble();
        } else if (visited) {
          x[id] = (x[children[id].first] + x[children[id].last]) / 2;
        } else {
          stack.add((id, level, true));
          for (final c in children[id].reversed) {
            stack.add((c, level + 1, false));
          }
        }
      }
    }
    return _TreeLayout(x, y, math.max(next, 1), depth);
  }
}

class _TreePainter extends CustomPainter {
  final List<SudokuSearchNode> nodes;
  final Offset Function(int) at;
  final int? current;
  final int currentStep;
  final Color edge, open, deadEnd, solution, ring;

  _TreePainter({
    required this.nodes,
    required this.at,
    required this.current,
    required this.currentStep,
    required this.edge,
    required this.open,
    required this.deadEnd,
    required this.solution,
    required this.ring,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = edge
      ..strokeWidth = 1;
    for (final node in nodes) {
      if (node.parent != null) {
        canvas.drawLine(at(node.parent!), at(node.id), line);
      }
    }
    for (final node in nodes) {
      final reached = node.step != null && node.step! <= currentStep;
      final color = !reached
          ? open.withValues(alpha: 0.25)
          : switch (node.status) {
              SudokuNodeStatus.solution => solution,
              SudokuNodeStatus.deadEnd => deadEnd,
              SudokuNodeStatus.open => open,
            };
      canvas.drawCircle(at(node.id), 5, Paint()..color = color);
    }
    if (current != null) {
      canvas.drawCircle(
          at(current!),
          9,
          Paint()
            ..color = ring
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(_TreePainter old) =>
      old.current != current ||
      old.currentStep != currentStep ||
      !identical(old.nodes, nodes);
}
