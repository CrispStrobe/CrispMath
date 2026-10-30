// SudokuExplainer records why each digit is placed. These tests check
// the solutions against the independent CSP solver and re-derive every
// recorded reason from the candidates of the step before it, so a step
// that claims a single which was not actually forced fails.

import 'package:crisp_math/engine/sudoku.dart';
import 'package:crisp_math/engine/sudoku_explainer.dart';
import 'package:crisp_math/localization/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

bool _satisfiesRules(SudokuPuzzle puzzle, List<int> grid) {
  for (final unit in SudokuExplainer.unitsOf(puzzle)) {
    final digits = {for (final i in unit.cells) grid[i]};
    if (digits.length != unit.cells.length || digits.contains(0)) return false;
  }
  for (var i = 0; i < grid.length; i++) {
    if (puzzle.cells[i] != 0 && puzzle.cells[i] != grid[i]) return false;
  }
  for (final cage in puzzle.cages ?? const <KillerCage>[]) {
    final digits = [for (final i in cage.cellIndexes) grid[i]];
    if (digits.toSet().length != digits.length ||
        digits.fold<int>(0, (sum, d) => sum + d) != cage.targetSum) {
      return false;
    }
  }
  return true;
}

int _bits(int m) => m == 0 ? 0 : 1 + _bits(m & (m - 1));

/// Digit masks per cage cell over every distinct-digit assignment that
/// reaches [sum], by brute force over [state].
List<int> _cageAllowed(SudokuExplainedStep state, List<int> cage, int sum) {
  final allowed = List<int>.filled(cage.length, 0);
  final pick = List<int>.filled(cage.length, 0);
  void go(int k, int used, int total) {
    if (k == cage.length) {
      if (total == sum) {
        for (var j = 0; j < cage.length; j++) {
          allowed[j] |= 1 << pick[j];
        }
      }
      return;
    }
    final i = cage[k];
    for (var d = 1; d < 32; d++) {
      final ok = state.cells[i] == 0
          ? state.candidateMasks[i] & (1 << d) != 0
          : state.cells[i] == d;
      if (!ok || used & (1 << d) != 0) continue;
      pick[k] = d;
      go(k + 1, used | (1 << d), total + d);
    }
  }

  go(0, 0, 0);
  return allowed;
}

/// Independent complete digit sets for a cage, including filled cells.
Set<int> _cageSets(SudokuExplainedStep state, List<int> cage, int sum) {
  final sets = <int>{};
  void go(int k, int used, int total) {
    if (k == cage.length) {
      if (total == sum) sets.add(used);
      return;
    }
    final i = cage[k];
    for (var d = 1; d < 32; d++) {
      final bit = 1 << d;
      if (used & bit != 0) continue;
      final allowed = state.cells[i] == 0
          ? state.candidateMasks[i] & bit != 0
          : state.cells[i] == d;
      if (!allowed) continue;
      go(k + 1, used | bit, total + d);
    }
  }

  go(0, 0, 0);
  return sets;
}

/// Checks an elimination step: the grid is unchanged and the candidates
/// lost exactly [SudokuExplainedStep.removed].
void _checkElimination(
  SudokuExplainedStep before,
  SudokuExplainedStep step,
  int k,
) {
  expect(step.cells, before.cells, reason: 'step $k places nothing');
  expect(step.removed, isNotEmpty, reason: 'step $k removes something');
  for (var i = 0; i < step.cells.length; i++) {
    final r = step.removed[i] ?? 0;
    expect(
      before.candidateMasks[i] & r,
      r,
      reason: 'step $k removes only existing candidates',
    );
    expect(
      step.candidateMasks[i],
      before.candidateMasks[i] & ~r,
      reason: 'step $k candidates at $i',
    );
  }
}

/// Re-derives each step's reason from the previous step's state.
void _checkReasons(SudokuExplanation e, {List<KillerCage>? cages}) {
  for (var k = 1; k < e.steps.length; k++) {
    final before = e.steps[k - 1];
    final step = e.steps[k];
    switch (step.kind) {
      case SudokuStepKind.nakedSingle:
        final mask = before.candidateMasks[step.cell!];
        expect(before.cells[step.cell!], 0, reason: 'step $k cell was empty');
        expect(
          mask,
          1 << step.value!,
          reason: 'step $k: naked single must be the only candidate',
        );
        expect(step.cells[step.cell!], step.value);
      case SudokuStepKind.hiddenSingle:
        final bit = 1 << step.value!;
        final places = [
          for (final i in step.unit!.cells)
            if (before.cells[i] == 0 && before.candidateMasks[i] & bit != 0) i,
        ];
        expect(
            places,
            [
              step.cell,
            ],
            reason: 'step $k: hidden single must have one place in its unit');
        expect(
          step.unit!.cells.any((i) => before.cells[i] == step.value),
          isFalse,
        );
      case SudokuStepKind.cageCombination:
        _checkElimination(before, step, k);
        final allowed = _cageAllowed(before, step.focusCells, step.cageSum!);
        final listed = {
          for (final combo in step.combinations)
            combo.fold<int>(0, (bits, d) => bits | (1 << d)),
        };
        expect(
          listed,
          _cageSets(before, step.focusCells, step.cageSum!),
          reason: 'step $k: cage digit sets must be complete and valid',
        );
        for (var j = 0; j < step.focusCells.length; j++) {
          final r = step.removed[step.focusCells[j]] ?? 0;
          expect(
            r & allowed[j],
            0,
            reason: 'step $k: a removed digit reaches the cage sum',
          );
        }
        expect(step.removed.keys.every(step.focusCells.contains), isTrue);
        expect(cages!.any((c) => c.targetSum == step.cageSum), isTrue);
      case SudokuStepKind.lockedCandidates:
        _checkElimination(before, step, k);
        final bit = 1 << step.digits.single;
        final second = step.secondUnit!.cells.toSet();
        final places = [
          for (final i in step.unit!.cells)
            if (before.cells[i] == 0 && before.candidateMasks[i] & bit != 0) i,
        ];
        expect(
          places.every(second.contains),
          isTrue,
          reason: 'step $k: the digit is confined to the second unit',
        );
        expect(
          step.unit!.cells.any((i) => before.cells[i] == step.digits.single),
          isFalse,
        );
        step.removed.forEach((i, r) {
          expect(r, bit);
          expect(
            second.contains(i) && !step.unit!.cells.contains(i),
            isTrue,
            reason: 'step $k removes only outside the first unit',
          );
        });
      case SudokuStepKind.nakedSubset:
        _checkElimination(before, step, k);
        var union = 0;
        for (final i in step.focusCells) {
          expect(before.cells[i], 0);
          union |= before.candidateMasks[i];
        }
        final digits = step.digits.fold(0, (m, d) => m | (1 << d));
        expect(union, digits, reason: 'step $k: subset cells hold the digits');
        expect(
          _bits(union),
          step.focusCells.length,
          reason: 'step $k: k cells hold exactly k digits',
        );
        step.removed.forEach((i, r) {
          expect(step.unit!.cells.contains(i), isTrue);
          expect(step.focusCells.contains(i), isFalse);
          expect(r & ~union, 0);
        });
      case SudokuStepKind.hiddenSubset:
        _checkElimination(before, step, k);
        expect(step.digits, hasLength(step.focusCells.length));
        var keep = 0;
        for (final d in step.digits) {
          keep |= 1 << d;
          final places = [
            for (final i in step.unit!.cells)
              if (before.cells[i] == 0 &&
                  before.candidateMasks[i] & (1 << d) != 0)
                i,
          ];
          expect(
            places.every(step.focusCells.contains),
            isTrue,
            reason: 'step $k: digit $d fits only in the subset cells',
          );
        }
        step.removed.forEach((i, r) {
          expect(step.focusCells.contains(i), isTrue);
          expect(r & keep, 0);
        });
      case SudokuStepKind.guess:
        expect(
          before.candidateMasks[step.cell!] & (1 << step.value!),
          isNot(0),
          reason: 'step $k: a guess takes one of the cell candidates',
        );
      case SudokuStepKind.contradiction:
        if (step.cageSum != null) {
          expect(
            _cageAllowed(
              step,
              step.focusCells,
              step.cageSum!,
            ).every((m) => m == 0),
            isTrue,
            reason: 'step $k: the cage can no longer reach its sum',
          );
        } else if (step.cell != null) {
          expect(step.cells[step.cell!], 0);
          expect(step.candidateMasks[step.cell!], 0);
        } else {
          final bit = 1 << step.value!;
          expect(
            step.unit!.cells.any(
              (i) =>
                  step.cells[i] == step.value ||
                  step.candidateMasks[i] & bit != 0,
            ),
            isFalse,
            reason: 'step $k: digit must have no place left in the unit',
          );
        }
        expect(
          e.steps[k + 1].kind,
          SudokuStepKind.backtrack,
          reason: 'a contradiction inside a search is followed by a '
              'backtrack',
        );
      case SudokuStepKind.backtrack:
        expect(e.steps[k + 1].kind, SudokuStepKind.guess);
        expect(
          e.steps[k + 1].cell,
          step.cell,
          reason: 'backtracking retries the same guessed cell',
        );
      case SudokuStepKind.start:
        fail('start only appears first');
      case SudokuStepKind.solved:
        expect(k, e.steps.length - 1);
        expect(step.cells, isNot(contains(0)));
    }
  }
}

/// The search tree has one node per guess; the solution path is a chain
/// from a root, and every other node ended in a contradiction.
void _checkTree(SudokuExplanation e, String id) {
  expect(e.tree, hasLength(e.guesses), reason: id);
  final onPath =
      e.tree.where((n) => n.status == SudokuNodeStatus.solution).toList();
  expect(onPath, hasLength(e.steps.last.depth), reason: id);
  for (var j = 0; j < onPath.length; j++) {
    expect(onPath[j].parent, j == 0 ? isNull : onPath[j - 1].id, reason: id);
  }
  expect(
    e.tree.where((n) => n.status == SudokuNodeStatus.open),
    isEmpty,
    reason: id,
  );
  for (final node in e.tree) {
    final step = e.steps[node.step!];
    expect(step.kind, SudokuStepKind.guess, reason: id);
    expect((step.cell, step.value), (node.cell, node.value), reason: id);
  }
}

void main() {
  test('cage budget stops without partial deductions or an unsat claim', () {
    final puzzle = SudokuPresets.killer4x4;
    final limited = SudokuExplainer.explain(puzzle, maxCageWork: 1);
    expect(limited.solution, isNull);
    expect(limited.error, contains('cage work limit'));
    expect(limited.steps.map((s) => s.kind), [SudokuStepKind.start]);
    expect(
      limited.tree.where((n) => n.status == SudokuNodeStatus.deadEnd),
      isEmpty,
    );
    final complete = SudokuExplainer.explain(puzzle);
    expect(complete.solved, isTrue);
    expect(complete.cageSteps, greaterThan(0));
    _checkReasons(complete, cages: puzzle.cages);
  });

  test('cage supports are cell-specific, not just digit-set membership', () {
    const solution = [2, 3, 1, 4, 1, 4, 2, 3, 3, 1, 4, 2, 4, 2, 3, 1];
    final puzzle = SudokuPuzzle(
      layout: SudokuLayout.small,
      variant: SudokuVariant.killer,
      cells: [0, 0, 1, ...List<int>.filled(13, 0)],
      cages: [
        const KillerCage(cellIndexes: [0, 1, 4], targetSum: 6),
        for (var i = 0; i < 16; i++)
          if (![0, 1, 4].contains(i))
            KillerCage(cellIndexes: [i], targetSum: solution[i]),
      ],
    );
    final complete = SudokuExplainer.explain(puzzle);
    expect(complete.solution, solution);
    final step = complete.steps.firstWhere(
      (step) => step.kind == SudokuStepKind.cageCombination,
    );
    expect(step.combinations, [
      [1, 2, 3],
    ]);
    // 2 and 3 occur in the only digit set, but cannot go in cell 4.
    expect(step.removed[4]! & ((1 << 2) | (1 << 3)), (1 << 2) | (1 << 3));
    _checkReasons(complete, cages: puzzle.cages);
    // Negative control: 2 is a valid candidate in cell 0, unlike cell 4.
    final before = complete.steps.first;
    final forged = SudokuExplainedStep(
      kind: SudokuStepKind.cageCombination,
      cells: before.cells,
      candidateMasks: [
        for (var i = 0; i < before.cells.length; i++)
          i == 0
              ? before.candidateMasks[i] & ~(1 << 2)
              : before.candidateMasks[i],
      ],
      focusCells: step.focusCells,
      cageSum: step.cageSum,
      combinations: step.combinations,
      removed: {0: 1 << 2},
      depth: 0,
    );
    final invalid = SudokuExplanation(
      steps: [before, forged],
      solution: complete.solution,
      error: null,
      truncated: false,
      nakedSingles: 0,
      hiddenSingles: 0,
      guesses: 0,
      backtracks: 0,
      maxDepth: 0,
    );
    expect(
      () => _checkReasons(invalid, cages: puzzle.cages),
      throwsA(isA<TestFailure>()),
    );
    final missingCombinations = SudokuExplainedStep(
      kind: SudokuStepKind.cageCombination,
      cells: step.cells,
      candidateMasks: step.candidateMasks,
      focusCells: step.focusCells,
      cageSum: step.cageSum,
      combinations: const [],
      removed: step.removed,
      depth: step.depth,
    );
    final missing = SudokuExplanation(
      steps: [before, missingCombinations],
      solution: complete.solution,
      error: null,
      truncated: false,
      nakedSingles: 0,
      hiddenSingles: 0,
      guesses: 0,
      backtracks: 0,
      maxDepth: 0,
    );
    expect(
      () => _checkReasons(missing, cages: puzzle.cages),
      throwsA(isA<TestFailure>()),
    );
    final limited = SudokuExplainer.explain(puzzle, maxCageWork: 20);
    expect(limited.error, contains('cage work limit'));
    expect(limited.steps.map((s) => s.kind), [SudokuStepKind.start]);
    expect(limited.solution, isNull);
  });

  test('large cages are bounded without claiming infeasibility', () {
    final puzzle = SudokuPuzzle(
      layout: SudokuLayout.large,
      variant: SudokuVariant.killer,
      cells: List<int>.filled(256, 0),
      cages: [
        for (var r = 0; r < 16; r++)
          KillerCage(
            cellIndexes: [for (var c = 0; c < 16; c++) r * 16 + c],
            targetSum: 136,
          ),
      ],
    );
    expect(SudokuExplainer.supports(puzzle), isTrue);
    final limited = SudokuExplainer.explain(puzzle, maxCageWork: 200);
    expect(limited.error, contains('cage work limit'));
    expect(limited.solution, isNull);
    expect(limited.steps.map((s) => s.kind), [SudokuStepKind.start]);
  });

  test('malformed killer partition is unsupported, not silently solved', () {
    final cages = List<KillerCage>.from(SudokuPresets.killer4x4.cages!);
    final puzzle = SudokuPuzzle(
      layout: SudokuLayout.small,
      cells: List<int>.filled(16, 0),
      variant: SudokuVariant.killer,
      cages: cages,
    );
    cages.removeLast(); // Mutable model can become invalid after construction.
    expect(SudokuExplainer.supports(puzzle), isFalse);
    final result = SudokuExplainer.explain(puzzle);
    expect(result.solution, isNull);
    expect(result.error, contains('Unsupported'));
    expect(SudokuExplainer.supports(SudokuPresets.killer4x4), isTrue);
    // The generic solver enforces a non-null cage list even on regular grids.
    final regularWithCages = SudokuPuzzle(
      layout: SudokuLayout.small,
      cells: List<int>.filled(16, 0),
      cages: SudokuPresets.killer4x4.cages,
    );
    expect(SudokuExplainer.supports(regularWithCages), isFalse);
    expect(
      SudokuExplainer.explain(regularWithCages).error,
      contains('Unsupported'),
    );
  });

  test('exhausted unsatisfiable search marks every ancestor dead', () async {
    final puzzle = SudokuPresets.standard9x9Hard.withCell(0, 1, 2);
    expect(await SudokuSolver.solve(puzzle), isNull);
    final result = SudokuExplainer.explain(puzzle);
    expect(result.error, 'No solution exists for this puzzle.');
    expect(result.maxDepth, greaterThan(1));
    expect(result.tree, isNotEmpty);
    expect(
      result.tree.every((n) => n.status == SudokuNodeStatus.deadEnd),
      isTrue,
    );
    final limited = SudokuExplainer.explain(
      SudokuPuzzle(layout: SudokuLayout.small, cells: List<int>.filled(16, 0)),
      maxPlacements: 1,
    );
    expect(limited.error, contains('Search stopped'));
    expect(limited.tree.any((n) => n.status == SudokuNodeStatus.open), isTrue);
  });

  test(
    'all locales describe cell-specific cage assignments and neutral contradictions',
    () {
      final expected = <AppLocalizations, (String, String)>{
        const EnLocalizations(): (
          'assignments to its cells',
          'guess was wrong',
        ),
        const DeLocalizations(): (
          'Zuordnungen zu den Zellen',
          'Annahme war falsch',
        ),
        const EsLocalizations(): (
          'asignaciones a las celdas',
          'suposición era errónea',
        ),
        const FrLocalizations(): (
          'affectations aux cases',
          'hypothèse était fausse',
        ),
      };
      for (final entry in expected.entries) {
        final t = entry.key;
        final cage = t.sudokuStepCage(5, 2, '{1, 4} {2, 3}', 1);
        expect(cage, contains(entry.value.$1));
        expect(cage, contains('{1, 4} {2, 3}'));
        for (final text in [
          t.sudokuStepContradictionCell('r1c1'),
          t.sudokuStepContradictionUnit('row 1', 2),
          t.sudokuStepContradictionCage(5),
        ]) {
          expect(text, isNot(contains(entry.value.$2)));
        }
      }
    },
  );
  test(
      'every supported preset solves, matches the CSP solver, and every '
      'recorded reason holds', () async {
    for (final preset in SudokuPresets.all) {
      final puzzle = preset.puzzle;
      if (!SudokuExplainer.supports(puzzle)) continue;
      final e = SudokuExplainer.explain(puzzle);
      expect(e.solved, isTrue, reason: preset.id);
      expect(e.truncated, isFalse, reason: preset.id);
      expect(_satisfiesRules(puzzle, e.solution!), isTrue, reason: preset.id);
      expect(e.solution, await SudokuSolver.solve(puzzle), reason: preset.id);
      expect(e.steps.first.kind, SudokuStepKind.start);
      expect(e.steps.last.kind, SudokuStepKind.solved);
      _checkReasons(e, cages: puzzle.cages);
      final counted = e.steps.where(
        (s) =>
            s.kind == SudokuStepKind.nakedSingle ||
            s.kind == SudokuStepKind.hiddenSingle,
      );
      expect(
        counted.length,
        e.nakedSingles + e.hiddenSingles,
        reason: preset.id,
      );
      final eliminations = e.steps.where((s) => s.removed.isNotEmpty);
      expect(eliminations.length, e.eliminationSteps, reason: preset.id);
      _checkTree(e, preset.id);
    }
  });

  test('the reason check rejects a step whose single was not forced', () {
    final e = SudokuExplainer.explain(SudokuPresets.standard9x9Hard);
    final k = e.steps.indexWhere((s) => s.kind == SudokuStepKind.nakedSingle);
    final real = e.steps[k];
    // Claim a naked single in an empty cell that still has two or more
    // candidates in the step before.
    final before = e.steps[k - 1];
    final wide = [
      for (var i = 0; i < before.cells.length; i++)
        if (before.cells[i] == 0 &&
            before.candidateMasks[i] & (before.candidateMasks[i] - 1) != 0)
          i,
    ].first;
    final value = [
      for (var d = 1; d <= 9; d++) d,
    ].firstWhere((d) => before.candidateMasks[wide] & (1 << d) != 0);
    final forged = SudokuExplainedStep(
      kind: SudokuStepKind.nakedSingle,
      cells: [...before.cells]..[wide] = value,
      candidateMasks: real.candidateMasks,
      cell: wide,
      value: value,
      depth: real.depth,
    );
    final tampered = SudokuExplanation(
      steps: [...e.steps.take(k), forged],
      solution: e.solution,
      error: null,
      truncated: false,
      nakedSingles: e.nakedSingles,
      hiddenSingles: e.hiddenSingles,
      guesses: e.guesses,
      backtracks: e.backtracks,
      maxDepth: e.maxDepth,
    );
    expect(() => _checkReasons(tampered), throwsA(isA<TestFailure>()));
  });

  test('the reason check rejects an unjustified elimination', () {
    final e = SudokuExplainer.explain(SudokuPresets.standard9x9Hard);
    final k = e.steps.indexWhere(
      (s) => s.kind == SudokuStepKind.lockedCandidates,
    );
    final real = e.steps[k];
    final before = e.steps[k - 1];
    // Remove the digit from a cell inside the first unit as well, which
    // locked candidates never justifies.
    final bit = 1 << real.digits.single;
    final extra = real.focusCells.first;
    final removed = {...real.removed, extra: bit};
    final forged = SudokuExplainedStep(
      kind: SudokuStepKind.lockedCandidates,
      cells: before.cells,
      candidateMasks: [
        for (var i = 0; i < before.cells.length; i++)
          before.candidateMasks[i] & ~(removed[i] ?? 0),
      ],
      unit: real.unit,
      secondUnit: real.secondUnit,
      focusCells: real.focusCells,
      digits: real.digits,
      removed: removed,
      depth: real.depth,
    );
    final tampered = SudokuExplanation(
      steps: [...e.steps.take(k), forged],
      solution: e.solution,
      error: null,
      truncated: false,
      nakedSingles: 0,
      hiddenSingles: 0,
      guesses: 0,
      backtracks: 0,
      maxDepth: 0,
    );
    expect(() => _checkReasons(tampered), throwsA(isA<TestFailure>()));
  });

  test('easy 9×9 needs logic only; hard 9×9 needs search and backtracking', () {
    final easy = SudokuExplainer.explain(SudokuPresets.standard9x9Easy);
    expect(easy.logicOnly, isTrue);
    expect(easy.guesses, 0);

    final hard = SudokuExplainer.explain(SudokuPresets.standard9x9Hard);
    expect(hard.logicOnly, isFalse);
    expect(hard.guesses, greaterThan(0));
    expect(hard.backtracks, greaterThan(0));
    expect(hard.hiddenSingles, greaterThan(0));
    expect(hard.maxDepth, greaterThan(0));
    expect(
      hard.steps.map((s) => s.kind).toSet(),
      containsAll([
        SudokuStepKind.nakedSingle,
        SudokuStepKind.hiddenSingle,
        SudokuStepKind.guess,
        SudokuStepKind.contradiction,
        SudokuStepKind.backtrack,
        SudokuStepKind.lockedCandidates,
        SudokuStepKind.nakedSubset,
        SudokuStepKind.hiddenSubset,
      ]),
    );
    expect(
      hard.tree.where((n) => n.status == SudokuNodeStatus.deadEnd),
      isNotEmpty,
    );
  });

  test('12×12 is solved by eliminations without guessing', () {
    final e = SudokuExplainer.explain(SudokuPresets.twelve12x12);
    expect(e.logicOnly, isTrue);
    expect(e.lockedCandidates, greaterThan(0));
    expect(e.tree, isEmpty);
  });

  test('X and disjoint variants include their extra units', () {
    final x = SudokuExplainer.unitsOf(SudokuPresets.eight8x8X);
    expect(x.where((u) => u.kind == SudokuUnitKind.mainDiagonal).single.cells, [
      for (var i = 0; i < 8; i++) i * 8 + i,
    ]);
    final disjoint = SudokuExplainer.unitsOf(
      SudokuPresets.eight8x8Disjoint,
    ).where((u) => u.kind == SudokuUnitKind.disjointGroup).toList();
    expect(disjoint, hasLength(8));
    expect(disjoint.every((u) => u.cells.length == 8), isTrue);
  });

  test(
    'clashing clues and unsolvable grids report errors, not solutions',
    () async {
      final clash = SudokuPuzzle(
        layout: SudokuLayout.small,
        cells: [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      );
      final c = SudokuExplainer.explain(clash);
      expect(c.solved, isFalse);
      expect(c.solution, isNull);
      expect(c.error, isNotNull);

      final unsolvable = SudokuPuzzle(
        layout: SudokuLayout.small,
        cells: [1, 2, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 3],
      );
      expect(await SudokuSolver.solve(unsolvable), isNull);
      final u = SudokuExplainer.explain(unsolvable);
      expect(u.solved, isFalse);
      expect(u.error, 'No solution exists for this puzzle.');
      expect(u.steps.last.kind, SudokuStepKind.contradiction);
    },
  );

  test('step recording is capped but the solve still completes', () {
    final e = SudokuExplainer.explain(
      SudokuPresets.standard9x9Hard,
      maxSteps: 10,
    );
    expect(e.steps, hasLength(10));
    expect(e.truncated, isTrue);
    expect(e.solved, isTrue);
    expect(
      e.solution,
      SudokuExplainer.explain(SudokuPresets.standard9x9Hard).solution,
    );
  });

  test('Killer cages are reasoned about by their sums', () {
    expect(SudokuExplainer.supports(SudokuPresets.killer9x9), isTrue);
    final e = SudokuExplainer.explain(SudokuPresets.killer9x9);
    expect(e.logicOnly, isTrue);
    expect(e.cageSteps, greaterThan(0));
    final step = e.steps.firstWhere(
      (s) => s.kind == SudokuStepKind.cageCombination,
    );
    // Every listed combination is a set of distinct digits with the sum.
    for (final combo in step.combinations) {
      expect(combo.toSet(), hasLength(step.focusCells.length));
      expect(combo.fold(0, (a, b) => a + b), step.cageSum);
    }
  });

  test('a cage that cannot reach its sum is a contradiction', () {
    // 4×4 killer: a two-cell cage of sum 2 needs two equal digits.
    final cells = List<int>.filled(16, 0);
    final cages = [
      const KillerCage(cellIndexes: [0, 1], targetSum: 2),
      for (var i = 2; i < 16; i++) KillerCage(cellIndexes: [i], targetSum: 1),
    ];
    final e = SudokuExplainer.explain(
      SudokuPuzzle(
        layout: SudokuLayout.small,
        cells: cells,
        variant: SudokuVariant.killer,
        cages: cages,
      ),
    );
    expect(e.solved, isFalse);
    expect(e.error, 'No solution exists for this puzzle.');
    final contradiction = e.steps.firstWhere(
      (s) => s.kind == SudokuStepKind.contradiction,
    );
    expect(contradiction.cageSum ?? contradiction.cell, isNotNull);
  });
}
