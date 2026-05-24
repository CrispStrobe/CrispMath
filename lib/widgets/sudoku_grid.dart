// lib/widgets/sudoku_grid.dart
//
// Tappable Sudoku grid widget. Renders an N×N grid with bold
// borders around the layout's boxes (e.g. 3×3 sub-grids for 9×9,
// 2×2 for 4×4). Each cell shows its digit value (or empty) and
// can be tapped to fire a callback so the parent can drive
// digit entry.
//
// Three visual states per cell:
//   * **clue**: original puzzle value, slightly emphasized.
//   * **filled**: value placed by the user or the solver, normal weight.
//   * **highlight**: just-changed by the solver (visualizer mode),
//     briefly tinted via the [highlightIndex] prop.
//
// Pure layout — no solver or AppState coupling. Parent passes
// down the cells list and gets back tap events.

import 'package:flutter/material.dart';

import '../engine/sudoku.dart';

class SudokuGrid extends StatelessWidget {
  final SudokuLayout layout;
  final List<int> cells;
  final Set<int> clueIndexes;
  final int? selectedIndex;
  final int? highlightIndex;
  final ValueChanged<int>? onTapCell;

  /// V3: optional per-cell candidate sets. When non-null, each
  /// empty cell renders a sub-grid of candidate digits (pencil
  /// marks) in light/dim color. List length must equal `side²`;
  /// clue cells' entries are ignored.
  final List<Set<int>>? candidates;

  const SudokuGrid({
    super.key,
    required this.layout,
    required this.cells,
    required this.clueIndexes,
    this.selectedIndex,
    this.highlightIndex,
    this.onTapCell,
    this.candidates,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest.shortestSide;
          final cellSize = size / layout.side;
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: scheme.onSurface, width: 2),
            ),
            child: Column(
              children: [
                for (var r = 0; r < layout.side; r++)
                  Expanded(
                    child: Row(
                      children: [
                        for (var c = 0; c < layout.side; c++)
                          Expanded(
                            child: _Cell(
                              row: r,
                              col: c,
                              layout: layout,
                              value: cells[r * layout.side + c],
                              isClue: clueIndexes.contains(r * layout.side + c),
                              isSelected: selectedIndex == r * layout.side + c,
                              isHighlighted:
                                  highlightIndex == r * layout.side + c,
                              cellSize: cellSize,
                              candidates: candidates?[r * layout.side + c],
                              onTap: onTapCell == null
                                  ? null
                                  : () => onTapCell!(r * layout.side + c),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final int row;
  final int col;
  final SudokuLayout layout;
  final int value;
  final bool isClue;
  final bool isSelected;
  final bool isHighlighted;
  final double cellSize;
  final Set<int>? candidates;
  final VoidCallback? onTap;

  const _Cell({
    required this.row,
    required this.col,
    required this.layout,
    required this.value,
    required this.isClue,
    required this.isSelected,
    required this.isHighlighted,
    required this.cellSize,
    required this.candidates,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Heavier border on the bottom + right edge of each box (NOT
    // the last column / row — that's the outer border).
    final isBoxBoundaryRight =
        (col + 1) % layout.boxCols == 0 && col + 1 != layout.side;
    final isBoxBoundaryBottom =
        (row + 1) % layout.boxRows == 0 && row + 1 != layout.side;

    Color? bg;
    if (isHighlighted) {
      bg = scheme.primary.withValues(alpha: 0.30);
    } else if (isSelected) {
      bg = scheme.primary.withValues(alpha: 0.15);
    }

    return Material(
      color: bg ?? scheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: scheme.onSurface.withValues(alpha: 0.6),
                width: isBoxBoundaryRight ? 2 : 0.5,
              ),
              bottom: BorderSide(
                color: scheme.onSurface.withValues(alpha: 0.6),
                width: isBoxBoundaryBottom ? 2 : 0.5,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: value != 0
              ? Text(
                  '$value',
                  style: TextStyle(
                    fontSize: cellSize * 0.55,
                    fontWeight: isClue ? FontWeight.w700 : FontWeight.w400,
                    color: isClue ? scheme.onSurface : scheme.primary,
                  ),
                )
              : (candidates != null && candidates!.isNotEmpty
                  ? _PencilMarks(
                      layout: layout,
                      candidates: candidates!,
                      cellSize: cellSize,
                    )
                  : const SizedBox.shrink()),
        ),
      ),
    );
  }
}

class _PencilMarks extends StatelessWidget {
  final SudokuLayout layout;
  final Set<int> candidates;
  final double cellSize;

  const _PencilMarks({
    required this.layout,
    required this.candidates,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    // Sub-grid mirrors the box layout: a 9-cell uses 3×3 sub-grid,
    // a 6-cell uses 2×3, a 4-cell uses 2×2, a 16-cell uses 4×4.
    // Each candidate digit sits in its conventional position
    // (digit d at row (d-1) ~/ subCols, col (d-1) % subCols) so
    // the user's eye learns where each digit belongs.
    final n = layout.side;
    final subRows = layout.boxRows;
    final subCols = layout.boxCols;
    final scheme = Theme.of(context).colorScheme;
    final dim = scheme.onSurface.withValues(alpha: 0.45);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var sr = 0; sr < subRows; sr++)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var sc = 0; sc < subCols; sc++) ...[
                    () {
                      final digit = sr * subCols + sc + 1;
                      if (digit > n) return const SizedBox();
                      final present = candidates.contains(digit);
                      return Expanded(
                        child: Center(
                          child: Text(
                            present ? '$digit' : '',
                            style: TextStyle(
                              fontSize: cellSize * 0.18,
                              color: dim,
                            ),
                          ),
                        ),
                      );
                    }(),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
