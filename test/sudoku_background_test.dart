// test/sudoku_background_test.dart
//
// Round 108: the advanced-hint candidate compute now runs on a worker
// isolate so it never blocks the UI isolate and can be cancelled mid-
// flight. These tests confirm the background result is identical to the
// in-process one, and that cancelling resolves cleanly to null.

import 'package:crisp_math/engine/sudoku.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('computeCandidatesPrunedInBackground', () {
    // Solvable 4×4 with a valid first row fixed; the rest is open.
    final puzzle = SudokuPuzzle(
      layout: SudokuLayout.small,
      cells: [
        1, 2, 3, 4, //
        0, 0, 0, 0, //
        0, 0, 0, 0, //
        0, 0, 0, 0, //
      ],
    );

    test('matches the in-process computeCandidatesPruned', () async {
      final inProcess = await SudokuSolver.computeCandidatesPruned(puzzle);
      final handle = SudokuSolver.computeCandidatesPrunedInBackground(puzzle);
      final background = await handle.result;
      expect(background, isNotNull);
      expect(background!.length, inProcess.length);
      for (var i = 0; i < inProcess.length; i++) {
        expect(background[i], equals(inProcess[i]), reason: 'cell $i differs');
      }
    }, timeout: const Timeout(Duration(seconds: 25)));

    test('cancel() resolves to null without hanging', () async {
      final handle = SudokuSolver.computeCandidatesPrunedInBackground(puzzle);
      handle.cancel();
      expect(await handle.result, isNull);
    }, timeout: const Timeout(Duration(seconds: 10)));
  });
}
