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
//   4. Killer cage: only digit combinations that reach the cage sum
//      (distinct digits, matching the cell candidates) stay possible.
//   5. Locked candidates: when a digit's places in one unit all lie in
//      a second unit (pointing, box-line reduction), the digit leaves
//      the rest of the second unit.
//   6. Naked pair/triple: k cells of a unit holding only k digits
//      between them; those digits leave the unit's other cells.
//   7. Hidden pair/triple: k digits that fit only in the same k cells
//      of a unit; those cells drop their other candidates.
//   8. When nothing applies, guess in the cell with the fewest candidates
//      (minimum remaining values; ties go to the cell with the most empty
//      peers) and remember the other options.
//   9. A contradiction (a cell with no candidates, a digit with no place
//      in a unit, or a cage that can no longer reach its sum) undoes
//      everything back to the latest guess, which then tries its next
//      option (backtracking).
//
// Every step keeps the grid and the candidate sets after it, so the
// replay can show pencil marks shrinking, and every guess is a node of
// a search tree the screen can draw.

import 'sudoku.dart';

enum SudokuUnitKind {
  row,
  column,
  box,
  mainDiagonal,
  antiDiagonal,
  disjointGroup,
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
  cageCombination,
  lockedCandidates,
  nakedSubset,
  hiddenSubset,
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
  /// Locked candidates: the unit where the digit is confined.
  /// Subsets: the unit they were found in.
  final SudokuUnit? unit;

  /// Locked candidates: the unit the digit is removed from.
  final SudokuUnit? secondUnit;

  /// The cells the reasoning starts from: the subset cells, the places
  /// of a locked digit, or the cage cells.
  final List<int> focusCells;

  /// Subset digits, or the locked digit.
  final List<int> digits;

  /// Cage steps and cage contradictions: the cage sum and the digit
  /// combinations that still reach it.
  final int? cageSum;
  final List<List<int>> combinations;

  /// Elimination steps: removed candidate bitmask per cell.
  final Map<int, int> removed;

  /// Number of guesses in effect after the step.
  final int depth;

  /// The deepest guess in effect after the step, as a
  /// [SudokuExplanation.tree] node id.
  final int? node;

  /// Guess: the other options kept for backtracking.
  final List<int> alternatives;

  /// Candidates removed by this step: from peers after a placement, or
  /// by an elimination technique.
  final int eliminations;

  const SudokuExplainedStep({
    required this.kind,
    required this.cells,
    required this.candidateMasks,
    this.cell,
    this.value,
    this.unit,
    this.secondUnit,
    this.focusCells = const [],
    this.digits = const [],
    this.cageSum,
    this.combinations = const [],
    this.removed = const {},
    required this.depth,
    this.node,
    this.alternatives = const [],
    this.eliminations = 0,
  });

  /// Removed candidates per cell, for crossed-out pencil marks.
  List<Set<int>> get removedCandidates => [
        for (var i = 0; i < cells.length; i++)
          {
            for (var d = 1; d < 32; d++)
              if ((removed[i] ?? 0) & (1 << d) != 0) d,
          },
      ];

  /// Candidate sets for [SudokuGrid] pencil marks.
  List<Set<int>> get candidates => [
        for (final mask in candidateMasks)
          {
            for (var d = 1; d < 32; d++)
              if (mask & (1 << d) != 0) d,
          },
      ];
}

enum SudokuNodeStatus { open, deadEnd, solution }

/// One guess in the search tree. [parent] is null for a guess made
/// with no other guess in effect.
class SudokuSearchNode {
  final int id;
  final int? parent;
  final int cell;
  final int value;

  /// Index into [SudokuExplanation.steps], or null when not recorded.
  final int? step;
  SudokuNodeStatus status;

  SudokuSearchNode({
    required this.id,
    required this.parent,
    required this.cell,
    required this.value,
    required this.step,
    this.status = SudokuNodeStatus.open,
  });
}

class SudokuExplanation {
  final List<SudokuExplainedStep> steps;
  final List<int>? solution;
  final String? _legacyError;
  final SudokuError? errorMessage;

  String? get error => _legacyError ?? errorMessage?.english;

  /// True when more steps happened than were recorded.
  final bool truncated;
  final int nakedSingles;
  final int hiddenSingles;
  final int guesses;
  final int backtracks;
  final int maxDepth;
  final int cageSteps;
  final int lockedCandidates;
  final int nakedSubsets;
  final int hiddenSubsets;

  /// Every guess, in the order made. Capped at [maxTreeNodes].
  final List<SudokuSearchNode> tree;
  final bool treeTruncated;

  static const maxTreeNodes = 2000;

  const SudokuExplanation({
    required this.steps,
    required this.solution,
    required String? error,
    this.errorMessage,
    required this.truncated,
    required this.nakedSingles,
    required this.hiddenSingles,
    required this.guesses,
    required this.backtracks,
    required this.maxDepth,
    this.cageSteps = 0,
    this.lockedCandidates = 0,
    this.nakedSubsets = 0,
    this.hiddenSubsets = 0,
    this.tree = const [],
    this.treeTruncated = false,
  }) : _legacyError = error;

  bool get solved => error == null && solution != null;

  /// Steps that only removed candidates.
  int get eliminationSteps =>
      cageSteps + lockedCandidates + nakedSubsets + hiddenSubsets;

  /// Solved without any guess: logic alone was enough.
  bool get logicOnly => solved && guesses == 0;
}

class _Branch {
  final List<int> cells;
  final List<int> masks;
  final int cell;
  final List<int> remaining;

  /// Guesses in effect before this branch's guess.
  final int pathDepth;

  _Branch(this.cells, this.masks, this.cell, this.remaining, this.pathDepth);
}

/// What a cage still allows: per-cell digit masks and the digit sets
/// (as masks) of every assignment that reaches the sum.
class _CageOptions {
  final List<int> allowed;
  final Set<int> combinations;

  _CageOptions(this.allowed, this.combinations);
}

int _bitCount(int m) {
  var c = 0;
  while (m != 0) {
    m &= m - 1;
    c++;
  }
  return c;
}

/// Every k-element combination of [items], in order.
Iterable<List<T>> _combinations<T>(List<T> items, int k) sync* {
  if (k == 0) {
    yield [];
    return;
  }
  for (var i = 0; i <= items.length - k; i++) {
    for (final rest in _combinations(items.sublist(i + 1), k - 1)) {
      yield [items[i], ...rest];
    }
  }
}

class _CageWorkLimit implements Exception {}

class SudokuExplainer {
  /// Whether the explainer can faithfully represent the puzzle's rules.
  static bool supports(SudokuPuzzle puzzle) {
    final n = puzzle.layout.side;
    if (n < 1 ||
        n > 30 ||
        puzzle.cells.length != n * n ||
        puzzle.cells.any((v) => v < 0 || v > n)) {
      return false;
    }
    if (puzzle.variant != SudokuVariant.killer) return puzzle.cages == null;
    final cages = puzzle.cages;
    if (cages == null) return false;
    final seen = <int>{};
    for (final cage in cages) {
      for (final i in cage.cellIndexes) {
        if (i < 0 || i >= n * n || !seen.add(i)) return false;
      }
    }
    return seen.length == n * n;
  }

  /// Every all-different unit of [puzzle], in display order.
  static List<SudokuUnit> unitsOf(SudokuPuzzle puzzle) {
    final layout = puzzle.layout;
    final n = layout.side;
    final units = <SudokuUnit>[
      for (var r = 0; r < n; r++)
        SudokuUnit(SudokuUnitKind.row, r + 1, [
          for (var c = 0; c < n; c++) r * n + c,
        ]),
      for (var c = 0; c < n; c++)
        SudokuUnit(SudokuUnitKind.column, c + 1, [
          for (var r = 0; r < n; r++) r * n + c,
        ]),
    ];
    final boxesPerRow = n ~/ layout.boxCols;
    for (var b = 0; b < n; b++) {
      final r0 = (b ~/ boxesPerRow) * layout.boxRows;
      final c0 = (b % boxesPerRow) * layout.boxCols;
      units.add(
        SudokuUnit(SudokuUnitKind.box, b + 1, [
          for (var r = r0; r < r0 + layout.boxRows; r++)
            for (var c = c0; c < c0 + layout.boxCols; c++) r * n + c,
        ]),
      );
    }
    if (puzzle.variant == SudokuVariant.x) {
      units.add(
        SudokuUnit(SudokuUnitKind.mainDiagonal, 1, [
          for (var i = 0; i < n; i++) i * n + i,
        ]),
      );
      units.add(
        SudokuUnit(SudokuUnitKind.antiDiagonal, 1, [
          for (var i = 0; i < n; i++) i * n + (n - 1 - i),
        ]),
      );
    }
    if (puzzle.variant == SudokuVariant.disjoint) {
      for (var g = 0; g < n; g++) {
        final gr = g ~/ layout.boxCols, gc = g % layout.boxCols;
        units.add(
          SudokuUnit(SudokuUnitKind.disjointGroup, g + 1, [
            for (var r = gr; r < n; r += layout.boxRows)
              for (var c = gc; c < n; c += layout.boxCols) r * n + c,
          ]),
        );
      }
    }
    return units;
  }

  /// Solve [puzzle] and record an explained step list. At most [maxSteps]
  /// steps are kept (the solve itself continues to the end); the search
  /// gives up after [maxPlacements] placements. Cage analysis is bounded
  /// across the whole solve by [maxCageWork] state/transition visits; hitting
  /// that limit stops the search without claiming the puzzle is impossible.
  /// Repeated cage evaluations with unchanged candidates are cached, so the
  /// budget is spent on genuinely new work.
  static SudokuExplanation explain(
    SudokuPuzzle puzzle, {
    int maxSteps = 3000,
    int maxPlacements = 200000,
    int maxCageWork = 20000000,
  }) {
    if (!supports(puzzle)) {
      return const SudokuExplanation(
        steps: [],
        solution: null,
        error: null,
        errorMessage: SudokuError.unsupported(),
        truncated: false,
        nakedSingles: 0,
        hiddenSingles: 0,
        guesses: 0,
        backtracks: 0,
        maxDepth: 0,
      );
    }
    if (maxCageWork < 0) throw ArgumentError.value(maxCageWork, 'maxCageWork');
    final n = puzzle.layout.side;
    final size = n * n;
    final units = unitsOf(puzzle);
    final cages = puzzle.variant == SudokuVariant.killer
        ? (puzzle.cages ?? const <KillerCage>[])
        : const <KillerCage>[];
    final peerSets = List.generate(size, (_) => <int>{});
    for (final group in [
      for (final u in units) u.cells,
      for (final c in cages) c.cellIndexes,
    ]) {
      for (final a in group) {
        for (final b in group) {
          if (a != b) peerSets[a].add(b);
        }
      }
    }
    final peers = [for (final s in peerSets) s.toList()..sort()];
    final full = ((1 << (n + 1)) - 1) & ~1;

    // Unit pairs that share at least two cells, for locked candidates.
    final unitPairs = <(SudokuUnit, SudokuUnit, Set<int>)>[];
    for (final a in units) {
      final aCells = a.cells.toSet();
      for (final b in units) {
        if (identical(a, b)) continue;
        final shared = b.cells.where(aCells.contains).toSet();
        if (shared.length >= 2 && shared.length < b.cells.length) {
          unitPairs.add((a, b, shared));
        }
      }
    }

    var cells = List<int>.from(puzzle.cells);
    var masks = List<int>.filled(size, 0);
    final steps = <SudokuExplainedStep>[];
    var truncated = false;
    var naked = 0, hidden = 0, guesses = 0, backtracks = 0, maxDepth = 0;
    var cageSteps = 0, locked = 0, nakedSubsets = 0, hiddenSubsets = 0;
    final stack = <_Branch>[];
    final tree = <SudokuSearchNode>[];
    var treeTruncated = false;
    // Tree node ids of the guesses in effect (-1 = guess not in tree).
    final path = <int>[];

    void record(
      SudokuStepKind kind, {
      int? cell,
      int? value,
      SudokuUnit? unit,
      SudokuUnit? secondUnit,
      List<int> focusCells = const [],
      List<int> digits = const [],
      int? cageSum,
      List<List<int>> combinations = const [],
      Map<int, int> removed = const {},
      List<int> alternatives = const [],
      int eliminations = 0,
    }) {
      if (steps.length >= maxSteps) {
        truncated = true;
        return;
      }
      steps.add(
        SudokuExplainedStep(
          kind: kind,
          cells: List<int>.unmodifiable(cells),
          candidateMasks: List<int>.unmodifiable(masks),
          cell: cell,
          value: value,
          unit: unit,
          secondUnit: secondUnit,
          focusCells: List<int>.unmodifiable(focusCells),
          digits: List<int>.unmodifiable(digits),
          cageSum: cageSum,
          combinations: List<List<int>>.unmodifiable(combinations),
          removed: Map<int, int>.unmodifiable(removed),
          depth: path.length,
          node: path.isEmpty || path.last < 0 ? null : path.last,
          alternatives: List<int>.unmodifiable(alternatives),
          eliminations: eliminations,
        ),
      );
    }

    SudokuExplanation finish(SudokuError? error) => SudokuExplanation(
          steps: steps,
          solution: error == null ? List<int>.unmodifiable(cells) : null,
          error: null,
          errorMessage: error,
          truncated: truncated,
          nakedSingles: naked,
          hiddenSingles: hidden,
          guesses: guesses,
          backtracks: backtracks,
          maxDepth: maxDepth,
          cageSteps: cageSteps,
          lockedCandidates: locked,
          nakedSubsets: nakedSubsets,
          hiddenSubsets: hiddenSubsets,
          tree: tree,
          treeTruncated: treeTruncated,
        );

    List<int> digitsOf(int mask) => [
          for (var d = 1; d <= n; d++)
            if (mask & (1 << d) != 0) d,
        ];

    // Memoize feasibility by the set of digits used: for a fixed cage
    // ordering it determines both the depth and sum. A second traversal of
    // viable states collects exact per-cell supports and complete digit sets.
    // Nothing is returned if the shared work budget is exhausted.
    var cageWork = 0;
    void spendCageWork() {
      if (cageWork >= maxCageWork) throw _CageWorkLimit();
      cageWork++;
    }

    // Cage options depend only on the candidate mask each cage cell
    // currently offers. Reuse recent results but bound retained memory.
    final cageCache = <String, _CageOptions>{};
    const maxCachedCages = 256;

    _CageOptions cageOptions(KillerCage cage) {
      final cageCells = cage.cellIndexes;
      final key = '$cageCells|${cage.targetSum}|'
          '${[
        for (final i in cageCells) cells[i] != 0 ? 1 << cells[i] : masks[i]
      ].join(',')}';
      final cached = cageCache[key];
      if (cached != null) return cached;
      final allowed = List<int>.filled(cageCells.length, 0);
      final combos = <int>{};
      final memo = <int, bool>{};
      final visited = <int>{};
      int optionsAt(int k) {
        final i = cageCells[k];
        return cells[i] != 0 ? 1 << cells[i] : masks[i];
      }

      bool feasible(int k, int used, int sum) {
        spendCageWork();
        final cached = memo[used];
        if (cached != null) return cached;
        if (sum > cage.targetSum) return memo[used] = false;
        if (k == cageCells.length) {
          return memo[used] = sum == cage.targetSum;
        }
        final options = optionsAt(k) & ~used;
        for (var d = 1; d <= n; d++) {
          spendCageWork();
          final bit = 1 << d;
          if (options & bit != 0 && feasible(k + 1, used | bit, sum + d)) {
            return memo[used] = true;
          }
        }
        return memo[used] = false;
      }

      void collect(int k, int used, int sum) {
        spendCageWork();
        if (!visited.add(used)) return;
        if (k == cageCells.length) {
          combos.add(used);
          return;
        }
        final options = optionsAt(k) & ~used;
        for (var d = 1; d <= n; d++) {
          spendCageWork();
          final bit = 1 << d;
          if (options & bit != 0 && feasible(k + 1, used | bit, sum + d)) {
            allowed[k] |= bit;
            collect(k + 1, used | bit, sum + d);
          }
        }
      }

      if (feasible(0, 0, 0)) collect(0, 0, 0);
      final result = _CageOptions(allowed, combos);
      if (cageCache.length >= maxCachedCages) {
        cageCache.remove(cageCache.keys.first);
      }
      cageCache[key] = result;
      return result;
    }

    List<List<int>> comboLists(Set<int> combos) => [
          for (final m in combos) digitsOf(m)
        ]..sort((a, b) => a.join().compareTo(b.join()));

    // Clues must not already clash.
    for (final group in [
      for (final u in units) u.cells,
      for (final c in cages) c.cellIndexes,
    ]) {
      final seen = <int>{};
      for (final i in group) {
        final v = cells[i];
        if (v != 0 && !seen.add(v)) {
          record(SudokuStepKind.start);
          return finish(const SudokuError.clashingClues());
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

    // Applies [removed] to the candidates; returns the number of digits.
    int eliminate(Map<int, int> removed) {
      var count = 0;
      removed.forEach((i, m) {
        masks[i] &= ~m;
        count += _bitCount(m);
      });
      return count;
    }

    // A contradiction: an empty cell without candidates, a digit with no
    // place in a unit, or a cage that cannot reach its sum.
    bool recordContradiction() {
      for (var i = 0; i < size; i++) {
        if (cells[i] == 0 && masks[i] == 0) {
          record(SudokuStepKind.contradiction, cell: i);
          return true;
        }
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
          record(
            SudokuStepKind.contradiction,
            unit: unit,
            value: digitsOf(missing).first,
          );
          return true;
        }
      }
      for (final cage in cages) {
        if (cageOptions(cage).combinations.isEmpty) {
          record(
            SudokuStepKind.contradiction,
            cageSum: cage.targetSum,
            focusCells: cage.cellIndexes,
          );
          return true;
        }
      }
      return false;
    }

    bool cageStep() {
      for (final cage in cages) {
        final options = cageOptions(cage);
        final removed = <int, int>{};
        for (var k = 0; k < cage.cellIndexes.length; k++) {
          final i = cage.cellIndexes[k];
          if (cells[i] != 0) continue;
          final drop = masks[i] & ~options.allowed[k];
          if (drop != 0) removed[i] = drop;
        }
        if (removed.isEmpty) continue;
        final count = eliminate(removed);
        cageSteps++;
        record(
          SudokuStepKind.cageCombination,
          cageSum: cage.targetSum,
          focusCells: cage.cellIndexes,
          combinations: comboLists(options.combinations),
          removed: removed,
          eliminations: count,
        );
        return true;
      }
      return false;
    }

    bool lockedStep() {
      for (final (a, b, shared) in unitPairs) {
        for (var d = 1; d <= n; d++) {
          final bit = 1 << d;
          final places = <int>[];
          var placedInA = false;
          for (final i in a.cells) {
            if (cells[i] == d) placedInA = true;
            if (cells[i] == 0 && masks[i] & bit != 0) places.add(i);
          }
          if (placedInA || places.length < 2) continue;
          if (!places.every(shared.contains)) continue;
          final removed = <int, int>{
            for (final i in b.cells)
              if (!shared.contains(i) && cells[i] == 0 && masks[i] & bit != 0)
                i: bit,
          };
          if (removed.isEmpty) continue;
          final count = eliminate(removed);
          locked++;
          record(
            SudokuStepKind.lockedCandidates,
            unit: a,
            secondUnit: b,
            focusCells: places,
            digits: [d],
            removed: removed,
            eliminations: count,
          );
          return true;
        }
      }
      return false;
    }

    bool nakedSubsetStep(int k) {
      for (final unit in units) {
        final open = [
          for (final i in unit.cells)
            if (cells[i] == 0 && _bitCount(masks[i]) <= k) i,
        ];
        if (open.length < k) continue;
        for (final group in _combinations(open, k)) {
          var union = 0;
          for (final i in group) {
            union |= masks[i];
          }
          if (_bitCount(union) != k) continue;
          final removed = <int, int>{
            for (final i in unit.cells)
              if (cells[i] == 0 && !group.contains(i) && masks[i] & union != 0)
                i: masks[i] & union,
          };
          if (removed.isEmpty) continue;
          final count = eliminate(removed);
          nakedSubsets++;
          record(
            SudokuStepKind.nakedSubset,
            unit: unit,
            focusCells: group,
            digits: digitsOf(union),
            removed: removed,
            eliminations: count,
          );
          return true;
        }
      }
      return false;
    }

    bool hiddenSubsetStep(int k) {
      for (final unit in units) {
        // Open digits with two to k places in the unit.
        final placesOf = <int, List<int>>{};
        var placed = 0;
        for (final i in unit.cells) {
          if (cells[i] != 0) placed |= 1 << cells[i];
        }
        for (var d = 1; d <= n; d++) {
          if (placed & (1 << d) != 0) continue;
          final places = [
            for (final i in unit.cells)
              if (cells[i] == 0 && masks[i] & (1 << d) != 0) i,
          ];
          if (places.length >= 2 && places.length <= k) placesOf[d] = places;
        }
        if (placesOf.length < k) continue;
        for (final group in _combinations(placesOf.keys.toList(), k)) {
          final where = <int>{for (final d in group) ...placesOf[d]!};
          if (where.length != k) continue;
          var keep = 0;
          for (final d in group) {
            keep |= 1 << d;
          }
          final removed = <int, int>{
            for (final i in where)
              if (masks[i] & ~keep != 0) i: masks[i] & ~keep,
          };
          if (removed.isEmpty) continue;
          final count = eliminate(removed);
          hiddenSubsets++;
          record(
            SudokuStepKind.hiddenSubset,
            unit: unit,
            focusCells: where.toList()..sort(),
            digits: group,
            removed: removed,
            eliminations: count,
          );
          return true;
        }
      }
      return false;
    }

    int addNode(int cell, int value) {
      if (tree.length >= SudokuExplanation.maxTreeNodes) {
        treeTruncated = true;
        return -1;
      }
      int? parent;
      for (var j = path.length - 1; j >= 0; j--) {
        if (path[j] >= 0) {
          parent = path[j];
          break;
        }
      }
      tree.add(
        SudokuSearchNode(
          id: tree.length,
          parent: parent,
          cell: cell,
          value: value,
          step: steps.length < maxSteps ? steps.length : null,
        ),
      );
      return tree.length - 1;
    }

    void guess(int cell, int value, List<int> rest) {
      path.add(addNode(cell, value));
      if (path.length > maxDepth) maxDepth = path.length;
      guesses++;
      final removed = place(cell, value);
      record(
        SudokuStepKind.guess,
        cell: cell,
        value: value,
        alternatives: rest,
        eliminations: removed,
      );
    }

    while (true) {
      if (placements > maxPlacements) {
        return finish(SudokuError.placementLimit(maxPlacements));
      }
      bool contradiction;
      try {
        contradiction = recordContradiction();
      } on _CageWorkLimit {
        return finish(SudokuError.cageWorkLimit(maxCageWork));
      }
      if (contradiction) {
        if (path.isNotEmpty && path.last >= 0) {
          tree[path.last].status = SudokuNodeStatus.deadEnd;
        }
        // Undo to the latest guess that still has options.
        while (stack.isNotEmpty && stack.last.remaining.isEmpty) {
          stack.removeLast();
        }
        if (stack.isEmpty) {
          // All guesses on the path have been exhaustively disproved.
          for (final id in path) {
            if (id >= 0) tree[id].status = SudokuNodeStatus.deadEnd;
          }
          return finish(const SudokuError.noSolution());
        }
        final branch = stack.last;
        cells = List<int>.from(branch.cells);
        masks = List<int>.from(branch.masks);
        // Every guess below the branch is exhausted.
        for (final id in path.sublist(branch.pathDepth)) {
          if (id >= 0) tree[id].status = SudokuNodeStatus.deadEnd;
        }
        path.length = branch.pathDepth;
        backtracks++;
        record(SudokuStepKind.backtrack, cell: branch.cell);
        final value = branch.remaining.removeAt(0);
        final rest = List<int>.from(branch.remaining);
        if (branch.remaining.isEmpty) stack.removeLast();
        guess(branch.cell, value, rest);
        continue;
      }
      if (!cells.contains(0)) {
        for (final id in path) {
          if (id >= 0) tree[id].status = SudokuNodeStatus.solution;
        }
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
          record(
            SudokuStepKind.nakedSingle,
            cell: i,
            value: value,
            eliminations: removed,
          );
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
            record(
              SudokuStepKind.hiddenSingle,
              cell: only,
              value: d,
              unit: unit,
              eliminations: removed,
            );
            progressed = true;
            break search;
          }
        }
      }
      if (progressed) continue;

      // Candidate eliminations, simplest first.
      bool cageProgress;
      try {
        cageProgress = cageStep();
      } on _CageWorkLimit {
        return finish(SudokuError.cageWorkLimit(maxCageWork));
      }
      if (cageProgress ||
          lockedStep() ||
          nakedSubsetStep(2) ||
          hiddenSubsetStep(2) ||
          nakedSubsetStep(3) ||
          hiddenSubsetStep(3)) {
        continue;
      }

      // Guess in the cell with the fewest candidates; on a tie, the one
      // with the most empty peers, whose guess constrains the most.
      var best = -1, bestCount = n + 1, bestDegree = -1;
      for (var i = 0; i < size; i++) {
        if (cells[i] != 0) continue;
        final count = _bitCount(masks[i]);
        if (count > bestCount) continue;
        final degree = peers[i].where((p) => cells[p] == 0).length;
        if (count < bestCount || degree > bestDegree) {
          best = i;
          bestCount = count;
          bestDegree = degree;
        }
      }
      final options = digitsOf(masks[best]);
      final rest = options.sublist(1);
      stack.add(
        _Branch(
          List<int>.from(cells),
          List<int>.from(masks),
          best,
          List<int>.from(rest),
          path.length,
        ),
      );
      guess(best, options.first, rest);
    }
  }
}
