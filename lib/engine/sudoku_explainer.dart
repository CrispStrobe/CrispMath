// lib/engine/sudoku_explainer.dart
//
// Explainable Sudoku solver. Where [SudokuSolver.solveWithTrace] records
// only grid snapshots from the generic CSP search, this solver records
// *why* each digit is placed, so the module can teach the algorithm:
//
//   1. Candidate elimination: each empty cell keeps the digits that no
//      peer (same row, column, box, diagonal or disjoint group) holds.
//   2. Naked single: a cell with one candidate left must take it.
//   3. Hidden single: a digit with one possible cell in a unit goes there.
//   4. When neither applies, guess in the cell with the fewest candidates
//      (minimum remaining values) and remember the other options.
//   5. A contradiction (a cell with no candidates, or a digit with no
//      place in a unit) undoes everything back to the latest guess, which
//      then tries its next option (backtracking).
//
// Every step keeps the grid and the candidate sets after it, so the
// replay can show pencil marks shrinking. Killer cages need sum
// reasoning this solver does not model; [SudokuExplainer.supports] is
// false for them and the screen keeps the CSP trace.

import 'sudoku.dart';

enum SudokuUnitKind {
  row,
  column,
  box,
  mainDiagonal,
  antiDiagonal,
  disjointGroup
}

/// One all-different group of cells. [number] is 1-based for display.
class SudokuUnit {
  final SudokuUnitKind kind;
  final int number;
  final List<int> cells;

  const SudokuUnit(this.kind, this.number, this.cells);
}

enum SudokuStepKind {
  start,
  nakedSingle,
  hiddenSingle,
  guess,
  contradiction,
  backtrack,
  solved,
}

class SudokuExplainedStep {
  final SudokuStepKind kind;

  /// Grid after the step (0 = empty).
  final List<int> cells;

  /// Candidate bitmask per cell after the step: bit d set means digit d
  /// is still possible. Zero for filled cells.
  final List<int> candidateMasks;

  /// The cell placed (singles, guess), the guess being undone
  /// (backtrack) or the cell left without candidates (contradiction).
  final int? cell;

  /// The digit placed, or the digit with no place left in [unit].
  final int? value;

  /// Hidden single: the unit where [value] fits only in [cell].
  /// Contradiction: the unit with no place left for [value].
  final SudokuUnit? unit;

  /// Number of open guesses after the step.
  final int depth;

  /// Guess: the other options kept for backtracking.
  final List<int> alternatives;

  /// Candidates removed from peers by this placement.
  final int eliminations;

  const SudokuExplainedStep({
    required this.kind,
    required this.cells,
    required this.candidateMasks,
    this.cell,
    this.value,
    this.unit,
    required this.depth,
    this.alternatives = const [],
    this.eliminations = 0,
  });

  /// Candidate sets for [SudokuGrid] pencil marks.
  List<Set<int>> get candidates => [
        for (final mask in candidateMasks)
          {
            for (var d = 1; d < 32; d++)
              if (mask & (1 << d) != 0) d
          }
      ];
}

class SudokuExplanation {
  final List<SudokuExplainedStep> steps;
  final List<int>? solution;
  final String? error;

  /// True when more steps happened than were recorded.
  final bool truncated;
  final int nakedSingles;
  final int hiddenSingles;
  final int guesses;
  final int backtracks;
  final int maxDepth;

  const SudokuExplanation({
    required this.steps,
    required this.solution,
    required this.error,
    required this.truncated,
    required this.nakedSingles,
    required this.hiddenSingles,
    required this.guesses,
    required this.backtracks,
    required this.maxDepth,
  });

  bool get solved => error == null && solution != null;

  /// Solved without any guess: singles alone were enough.
  bool get logicOnly => solved && guesses == 0;
}

class _Branch {
  final List<int> cells;
  final List<int> masks;
  final int cell;
  final List<int> remaining;

  _Branch(this.cells, this.masks, this.cell, this.remaining);
}

class SudokuExplainer {
  static bool supports(SudokuPuzzle puzzle) =>
      puzzle.variant != SudokuVariant.killer;

  /// Every all-different unit of [puzzle], in display order.
  static List<SudokuUnit> unitsOf(SudokuPuzzle puzzle) {
    final layout = puzzle.layout;
    final n = layout.side;
    final units = <SudokuUnit>[
      for (var r = 0; r < n; r++)
        SudokuUnit(
            SudokuUnitKind.row, r + 1, [for (var c = 0; c < n; c++) r * n + c]),
      for (var c = 0; c < n; c++)
        SudokuUnit(SudokuUnitKind.column, c + 1,
            [for (var r = 0; r < n; r++) r * n + c]),
    ];
    final boxesPerRow = n ~/ layout.boxCols;
    for (var b = 0; b < n; b++) {
      final r0 = (b ~/ boxesPerRow) * layout.boxRows;
      final c0 = (b % boxesPerRow) * layout.boxCols;
      units.add(SudokuUnit(SudokuUnitKind.box, b + 1, [
        for (var r = r0; r < r0 + layout.boxRows; r++)
          for (var c = c0; c < c0 + layout.boxCols; c++) r * n + c
      ]));
    }
    if (puzzle.variant == SudokuVariant.x) {
      units.add(SudokuUnit(SudokuUnitKind.mainDiagonal, 1,
          [for (var i = 0; i < n; i++) i * n + i]));
      units.add(SudokuUnit(SudokuUnitKind.antiDiagonal, 1,
          [for (var i = 0; i < n; i++) i * n + (n - 1 - i)]));
    }
    if (puzzle.variant == SudokuVariant.disjoint) {
      for (var g = 0; g < n; g++) {
        final gr = g ~/ layout.boxCols, gc = g % layout.boxCols;
        units.add(SudokuUnit(SudokuUnitKind.disjointGroup, g + 1, [
          for (var r = gr; r < n; r += layout.boxRows)
            for (var c = gc; c < n; c += layout.boxCols) r * n + c
        ]));
      }
    }
    return units;
  }

  /// Solve [puzzle] and record an explained step list. At most [maxSteps]
  /// steps are kept (the solve itself continues to the end); the search
  /// gives up after [maxPlacements] placements.
  static SudokuExplanation explain(
    SudokuPuzzle puzzle, {
    int maxSteps = 3000,
    int maxPlacements = 200000,
  }) {
    final n = puzzle.layout.side;
    final size = n * n;
    final units = unitsOf(puzzle);
    final peerSets = List.generate(size, (_) => <int>{});
    for (final unit in units) {
      for (final a in unit.cells) {
        for (final b in unit.cells) {
          if (a != b) peerSets[a].add(b);
        }
      }
    }
    final peers = [for (final s in peerSets) s.toList()..sort()];
    final full = ((1 << (n + 1)) - 1) & ~1;

    var cells = List<int>.from(puzzle.cells);
    var masks = List<int>.filled(size, 0);
    final steps = <SudokuExplainedStep>[];
    var truncated = false;
    var naked = 0, hidden = 0, guesses = 0, backtracks = 0, maxDepth = 0;
    final stack = <_Branch>[];

    void record(SudokuStepKind kind,
        {int? cell,
        int? value,
        SudokuUnit? unit,
        List<int> alternatives = const [],
        int eliminations = 0}) {
      if (steps.length >= maxSteps) {
        truncated = true;
        return;
      }
      steps.add(SudokuExplainedStep(
        kind: kind,
        cells: List<int>.unmodifiable(cells),
        candidateMasks: List<int>.unmodifiable(masks),
        cell: cell,
        value: value,
        unit: unit,
        depth: stack.length,
        alternatives: List<int>.unmodifiable(alternatives),
        eliminations: eliminations,
      ));
    }

    SudokuExplanation finish(String? error) => SudokuExplanation(
          steps: steps,
          solution: error == null ? List<int>.unmodifiable(cells) : null,
          error: error,
          truncated: truncated,
          nakedSingles: naked,
          hiddenSingles: hidden,
          guesses: guesses,
          backtracks: backtracks,
          maxDepth: maxDepth,
        );

    // Clues must not already clash.
    for (final unit in units) {
      final seen = <int>{};
      for (final i in unit.cells) {
        final v = cells[i];
        if (v != 0 && !seen.add(v)) {
          record(SudokuStepKind.start);
          return finish('The clues already break a rule.');
        }
      }
    }
    for (var i = 0; i < size; i++) {
      if (cells[i] != 0) continue;
      var m = full;
      for (final p in peers[i]) {
        if (cells[p] != 0) m &= ~(1 << cells[p]);
      }
      masks[i] = m;
    }
    record(SudokuStepKind.start);

    var placements = 0;
    int place(int cell, int value) {
      placements++;
      cells[cell] = value;
      masks[cell] = 0;
      final bit = 1 << value;
      var removed = 0;
      for (final p in peers[cell]) {
        if (cells[p] == 0 && masks[p] & bit != 0) {
          masks[p] &= ~bit;
          removed++;
        }
      }
      return removed;
    }

    List<int> digitsOf(int mask) => [
          for (var d = 1; d <= n; d++)
            if (mask & (1 << d) != 0) d
        ];

    // Returns (cell, unit, digit) describing a contradiction, or null.
    (int?, SudokuUnit?, int?)? findContradiction() {
      for (var i = 0; i < size; i++) {
        if (cells[i] == 0 && masks[i] == 0) return (i, null, null);
      }
      for (final unit in units) {
        var placed = 0, possible = 0;
        for (final i in unit.cells) {
          if (cells[i] != 0) {
            placed |= 1 << cells[i];
          } else {
            possible |= masks[i];
          }
        }
        final missing = full & ~placed & ~possible;
        if (missing != 0) {
          return (null, unit, digitsOf(missing).first);
        }
      }
      return null;
    }

    while (true) {
      if (placements > maxPlacements) {
        return finish('Search stopped after $maxPlacements placements.');
      }
      final clash = findContradiction();
      if (clash != null) {
        record(SudokuStepKind.contradiction,
            cell: clash.$1, unit: clash.$2, value: clash.$3);
        // Undo to the latest guess that still has options.
        while (stack.isNotEmpty && stack.last.remaining.isEmpty) {
          stack.removeLast();
        }
        if (stack.isEmpty) {
          return finish('No solution exists for this puzzle.');
        }
        final branch = stack.last;
        cells = List<int>.from(branch.cells);
        masks = List<int>.from(branch.masks);
        backtracks++;
        record(SudokuStepKind.backtrack, cell: branch.cell);
        final value = branch.remaining.removeAt(0);
        final rest = List<int>.from(branch.remaining);
        if (branch.remaining.isEmpty) stack.removeLast();
        guesses++;
        final removed = place(branch.cell, value);
        record(SudokuStepKind.guess,
            cell: branch.cell,
            value: value,
            alternatives: rest,
            eliminations: removed);
        continue;
      }
      if (!cells.contains(0)) {
        record(SudokuStepKind.solved);
        return finish(null);
      }

      // Naked single.
      var progressed = false;
      for (var i = 0; i < size; i++) {
        final m = masks[i];
        if (cells[i] == 0 && m != 0 && m & (m - 1) == 0) {
          final value = digitsOf(m).single;
          final removed = place(i, value);
          naked++;
          record(SudokuStepKind.nakedSingle,
              cell: i, value: value, eliminations: removed);
          progressed = true;
          break;
        }
      }
      if (progressed) continue;

      // Hidden single.
      search:
      for (final unit in units) {
        for (var d = 1; d <= n; d++) {
          final bit = 1 << d;
          int? only;
          var count = 0;
          for (final i in unit.cells) {
            if (cells[i] == d) {
              count = -1;
              break;
            }
            if (cells[i] == 0 && masks[i] & bit != 0) {
              count++;
              only = i;
            }
          }
          if (count == 1) {
            final removed = place(only!, d);
            hidden++;
            record(SudokuStepKind.hiddenSingle,
                cell: only, value: d, unit: unit, eliminations: removed);
            progressed = true;
            break search;
          }
        }
      }
      if (progressed) continue;

      // Guess in the cell with the fewest candidates.
      var best = -1, bestCount = n + 1;
      for (var i = 0; i < size; i++) {
        if (cells[i] != 0) continue;
        final count = digitsOf(masks[i]).length;
        if (count < bestCount) {
          best = i;
          bestCount = count;
        }
      }
      final options = digitsOf(masks[best]);
      final value = options.first;
      final rest = options.sublist(1);
      stack.add(_Branch(List<int>.from(cells), List<int>.from(masks), best,
          List<int>.from(rest)));
      if (stack.length > maxDepth) maxDepth = stack.length;
      guesses++;
      final removed = place(best, value);
      record(SudokuStepKind.guess,
          cell: best, value: value, alternatives: rest, eliminations: removed);
    }
  }
}
