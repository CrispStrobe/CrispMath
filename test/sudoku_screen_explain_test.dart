// The Sudoku solver module explains how a puzzle is solved: Solve opens
// the step visualizer on the first step, each step names its reason, and
// a summary counts singles, guesses and backtracks. The former game
// parts (win check, celebration overlay, clear-to-start) are gone.

import 'package:crisp_math/engine/sudoku.dart';
import 'package:crisp_math/screens/sudoku_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: SudokuScreen()));
    await tester.pumpAndSettle();
  }

  Future<void> pickPreset(WidgetTester tester, String label) async {
    final picker = find.byType(DropdownButtonFormField<SudokuPuzzle>);
    await tester.ensureVisible(picker);
    await tester.tap(picker);
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> solve(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Solve'));
    await tester.tap(find.text('Solve'));
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester, int times) async {
    await tester.ensureVisible(find.byTooltip('Next step'));
    for (var i = 0; i < times; i++) {
      await tester.tap(find.byTooltip('Next step'));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('no game affordances; titled as a solver', (tester) async {
    await pumpScreen(tester);
    expect(find.text('Sudoku solver'), findsOneWidget);
    expect(find.text('Clear to start'), findsNothing);
    expect(find.text('Solved correctly'), findsNothing);
    expect(find.textContaining('Enter clues'), findsOneWidget);
  });

  testWidgets('Solve opens on the first step and steps carry reasons',
      (tester) async {
    await pumpScreen(tester);
    await tester.ensureVisible(find.text('Solve'));
    await tester.tap(find.text('Solve'));
    await tester.pumpAndSettle();

    // Default preset is the easy 9×9: singles alone solve it.
    expect(find.byKey(const ValueKey('sudoku-explanation-summary')),
        findsOneWidget);
    expect(find.textContaining('Naked singles 51'), findsOneWidget);
    expect(find.textContaining('Guesses 0'), findsOneWidget);
    expect(find.text('Solved by logic alone: no guessing needed.'),
        findsOneWidget);

    // Not auto-playing: the first frame is the explained start.
    expect(find.textContaining('Start: '), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Next step'));
    await tester.tap(find.byTooltip('Next step'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Naked single: r'), findsOneWidget);
    expect(find.textContaining('has only one candidate left'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous step'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Start: '), findsOneWidget);
  });

  testWidgets('AI Escargot shows eliminations and a search tree',
      (tester) async {
    await pumpScreen(tester);
    await pickPreset(tester, '9×9 hard (AI Escargot)');
    await solve(tester);
    expect(find.textContaining('Locked candidates '), findsOneWidget);
    expect(find.byKey(const ValueKey('sudoku-search-tree')), findsOneWidget);
    // Steps 1-3 are guess-free logic; step 4 is a locked-candidates step.
    await next(tester, 4);
    expect(find.textContaining('Locked candidates: in '), findsOneWidget);
  });

  testWidgets('Killer cages are explained by their sums', (tester) async {
    await pumpScreen(tester);
    await pickPreset(tester, '9×9 Killer');
    await solve(tester);
    expect(find.textContaining('Cage sums '), findsOneWidget);
    expect(find.text('Solved by logic alone: no guessing needed.'),
        findsOneWidget);
    expect(find.byKey(const ValueKey('sudoku-search-tree')), findsNothing);
    await next(tester, 1);
    expect(find.textContaining('Cage sum: '), findsOneWidget);
  });
}
