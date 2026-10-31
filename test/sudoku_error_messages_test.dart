import 'package:crisp_math/engine/sudoku.dart';
import 'package:crisp_math/engine/sudoku_explainer.dart';
import 'package:crisp_math/localization/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('explainer emits typed errors with unchanged English and limits', () {
    final clash = SudokuPuzzle(layout: SudokuLayout.small,
        cells: [1, 1, ...List<int>.filled(14, 0)]);
    final bad = SudokuExplainer.explain(clash);
    expect(bad.error, 'The clues already break a rule.');
    expect(bad.errorMessage!.kind, SudokuErrorKind.clashingClues);
    expect(bad.solved, isFalse);

    final unsupported = SudokuPuzzle(layout: SudokuLayout.small,
        cells: List<int>.filled(16, 0), cages: SudokuPresets.killer4x4.cages);
    final u = SudokuExplainer.explain(unsupported);
    expect(u.error, 'Unsupported Sudoku puzzle.');
    expect(u.errorMessage!.kind, SudokuErrorKind.unsupported);

    final impossible = SudokuPuzzle(layout: SudokuLayout.small,
        cells: [1, 2, 3, 0, 0, 0, 0, 4, ...List<int>.filled(8, 0)]);
    final n = SudokuExplainer.explain(impossible);
    expect(n.error, 'No solution exists for this puzzle.');
    expect(n.errorMessage!.kind, SudokuErrorKind.noSolution);

    final p = SudokuExplainer.explain(SudokuPresets.small4x4Easy,
        maxPlacements: 1);
    expect(p.error, 'Search stopped after 1 placements.');
    expect(p.errorMessage!.kind, SudokuErrorKind.placementLimit);
    expect(p.errorMessage!.limit, 1);
    final c = SudokuExplainer.explain(SudokuPresets.killer4x4, maxCageWork: 17);
    expect(c.error, 'Search stopped after reaching the cage work limit (17).');
    expect(c.errorMessage!.kind, SudokuErrorKind.cageWorkLimit);
    expect(c.errorMessage!.limit, 17);
    expect(SudokuExplainer.explain(SudokuPresets.small4x4Easy).errorMessage,
        isNull);
  });

  test('CSP fallback emits typed no-solution and legacy constructors work',
      () async {
    final puzzle = SudokuPuzzle(layout: SudokuLayout.small,
        cells: [1, 1, ...List<int>.filled(14, 0)],
        cages: SudokuPresets.killer4x4.cages);
    expect(SudokuExplainer.supports(puzzle), isFalse);
    final trace = await SudokuSolver.solveWithTrace(puzzle);
    expect(trace.solved, isFalse);
    expect(trace.error, 'No solution exists for this puzzle.');
    expect(trace.errorMessage!.kind, SudokuErrorKind.noSolution);
    const legacy = SudokuTrace(frames: [], solution: null, error: 'custom');
    expect(legacy.error, 'custom');
    expect(legacy.errorMessage, isNull);
    const explanation = SudokuExplanation(steps: [], solution: null,
        error: 'custom', truncated: false, nakedSingles: 0, hiddenSingles: 0,
        guesses: 0, backtracks: 0, maxDepth: 0);
    expect(explanation.error, 'custom');
    expect(explanation.errorMessage, isNull);
  });

  test('all message kinds render in every locale with actual limits', () {
    final messages = [
      const SudokuError.unsupported(),
      const SudokuError.clashingClues(),
      const SudokuError.noSolution(),
      const SudokuError.placementLimit(123),
      const SudokuError.cageWorkLimit(456),
    ];
    final translations = <AppLocalizations, List<String>>{
      const EnLocalizations(): [
        'Unsupported Sudoku puzzle.',
        'The clues already break a rule.',
        'No solution exists for this puzzle.',
        'Search stopped after 123 placements.',
        'Search stopped after reaching the cage work limit (456).',
      ],
      const DeLocalizations(): [
        'Nicht unterstütztes Sudoku.',
        'Die Vorgaben verletzen bereits eine Regel.',
        'Für dieses Sudoku gibt es keine Lösung.',
        'Suche nach 123 Platzierungen abgebrochen.',
        'Suche beim Erreichen des Käfig-Arbeitslimits (456) abgebrochen.',
      ],
      const FrLocalizations(): [
        'Sudoku non pris en charge.',
        'Les indices enfreignent déjà une règle.',
        'Ce Sudoku n’a pas de solution.',
        'Recherche arrêtée après 123 placements.',
        'Recherche arrêtée à la limite de travail des cages (456).',
      ],
      const EsLocalizations(): [
        'Sudoku no compatible.',
        'Las pistas ya infringen una regla.',
        'Este Sudoku no tiene solución.',
        'Búsqueda detenida tras 123 colocaciones.',
        'Búsqueda detenida al alcanzar el límite de trabajo de las jaulas (456).',
      ],
    };
    for (final entry in translations.entries) {
      for (var i = 0; i < messages.length; i++) {
        expect(entry.key.sudokuError(messages[i]), entry.value[i]);
      }
    }
  });
}
