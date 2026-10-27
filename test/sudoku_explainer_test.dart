// SudokuExplainer records why each digit is placed. These tests check
// the solutions against the independent CSP solver and re-derive every
// recorded reason from the candidates of the step before it, so a step
// that claims a single which was not actually forced fails.

import 'package:crisp_math/engine/sudoku.dart';
import 'package:crisp_math/engine/sudoku_explainer.dart';
import 'package:flutter_test/flutter_test.dart';

bool _satisfiesRules(SudokuPuzzle puzzle, List<int> grid) {
  for (final unit in SudokuExplainer.unitsOf(puzzle)) {
    final digits = {for (final i in unit.cells) grid[i]};
    if (digits.length != unit.cells.length || digits.contains(0)) return false;
  }
  for (var i = 0; i < grid.length; i++) {
    if (puzzle.cells[i] != 0 && puzzle.cells[i] != grid[i]) return false;
  }
  return true;
}

/// Re-derives each step's reason from the previous step's state.
void _checkReasons(SudokuExplanation e) {
  for (var k = 1; k < e.steps.length; k++) {
    final before = e.steps[k - 1];
    final step = e.steps[k];
    switch (step.kind) {
      case SudokuStepKind.nakedSingle:
        final mask = before.candidateMasks[step.cell!];
        expect(before.cells[step.cell!], 0, reason: 'step $k cell was empty');
        expect(mask, 1 << step.value!,
            reason: 'step $k: naked single must be the only candidate');
        expect(step.cells[step.cell!], step.value);
      case SudokuStepKind.hiddenSingle:
        final bit = 1 << step.value!;
        final places = [
          for (final i in step.unit!.cells)
            if (before.cells[i] == 0 && before.candidateMasks[i] & bit != 0) i
        ];
        expect(places, [step.cell],
            reason: 'step $k: hidden single must have one place in its unit');
        expect(step.unit!.cells.any((i) => before.cells[i] == step.value),
            isFalse);
      case SudokuStepKind.guess:
        expect(before.candidateMasks[step.cell!] & (1 << step.value!), isNot(0),
            reason: 'step $k: a guess takes one of the cell candidates');
      case SudokuStepKind.contradiction:
        if (step.cell != null) {
          expect(step.cells[step.cell!], 0);
          expect(step.candidateMasks[step.cell!], 0);
        } else {
          final bit = 1 << step.value!;
          expect(
              step.unit!.cells.any((i) =>
                  step.cells[i] == step.value ||
                  step.candidateMasks[i] & bit != 0),
              isFalse,
              reason: 'step $k: digit must have no place left in the unit');
        }
        expect(e.steps[k + 1].kind, SudokuStepKind.backtrack,
            reason: 'a contradiction inside a search is followed by a '
                'backtrack');
      case SudokuStepKind.backtrack:
        expect(e.steps[k + 1].kind, SudokuStepKind.guess);
        expect(e.steps[k + 1].cell, step.cell,
            reason: 'backtracking retries the same guessed cell');
      case SudokuStepKind.start:
        fail('start only appears first');
      case SudokuStepKind.solved:
        expect(k, e.steps.length - 1);
        expect(step.cells, isNot(contains(0)));
    }
  }
}

void main() {
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
      _checkReasons(e);
      final counted = e.steps.where((s) =>
          s.kind == SudokuStepKind.nakedSingle ||
          s.kind == SudokuStepKind.hiddenSingle);
      expect(counted.length, e.nakedSingles + e.hiddenSingles,
          reason: preset.id);
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
          i
    ].first;
    final value = [for (var d = 1; d <= 9; d++) d]
        .firstWhere((d) => before.candidateMasks[wide] & (1 << d) != 0);
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
        ]));
  });

  test('X and disjoint variants include their extra units', () {
    final x = SudokuExplainer.unitsOf(SudokuPresets.eight8x8X);
    expect(x.where((u) => u.kind == SudokuUnitKind.mainDiagonal).single.cells,
        [for (var i = 0; i < 8; i++) i * 8 + i]);
    final disjoint = SudokuExplainer.unitsOf(SudokuPresets.eight8x8Disjoint)
        .where((u) => u.kind == SudokuUnitKind.disjointGroup)
        .toList();
    expect(disjoint, hasLength(8));
    expect(disjoint.every((u) => u.cells.length == 8), isTrue);
  });

  test('clashing clues and unsolvable grids report errors, not solutions',
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
  });

  test('step recording is capped but the solve still completes', () {
    final e =
        SudokuExplainer.explain(SudokuPresets.standard9x9Hard, maxSteps: 10);
    expect(e.steps, hasLength(10));
    expect(e.truncated, isTrue);
    expect(e.solved, isTrue);
    expect(e.solution,
        SudokuExplainer.explain(SudokuPresets.standard9x9Hard).solution);
  });

  test('Killer puzzles are left to the CSP replay', () {
    expect(SudokuExplainer.supports(SudokuPresets.killer9x9), isFalse);
    expect(SudokuExplainer.supports(SudokuPresets.standard9x9Hard), isTrue);
  });
}
