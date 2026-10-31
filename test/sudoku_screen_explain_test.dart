// The Sudoku solver module explains how a puzzle is solved: Solve opens
// the step visualizer on the first step, each step names its reason, and
// a summary counts the techniques that actually occurred. The former game
// parts (win check, celebration overlay, clear-to-start) are gone.
//
// Phone layout: the replay controls and the step explanation sit directly
// under the grid, above the puzzle setup controls, so a 390×844 screen
// shows the board and the current reason together. The generator's
// difficulty is a separate setting and never disguises the loaded preset.

import 'package:crisp_math/engine/sudoku.dart';
import 'package:crisp_math/screens/sudoku_screen.dart';
import 'package:crisp_math/widgets/sudoku_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpScreenAt(
    WidgetTester tester,
    Size size, {
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const SudokuScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpScreen(WidgetTester tester) =>
      pumpScreenAt(tester, const Size(1280, 1000));

  /// Scrolls a lazily built list until [finder] exists, then makes it
  /// visible and lets the jump settle before a tap reads its offset.
  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  Future<void> pickPreset(WidgetTester tester, String label) async {
    final picker = find.byType(DropdownButtonFormField<SudokuPuzzle>);
    await reveal(tester, picker);
    await tester.tap(picker);
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> solve(WidgetTester tester) async {
    await reveal(tester, find.text('Solve'));
    await tester.tap(find.text('Solve'));
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester, int times) async {
    await reveal(tester, find.byTooltip('Next step'));
    for (var i = 0; i < times; i++) {
      await tester.tap(find.byTooltip('Next step'));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  bool chipSelected(WidgetTester tester, String label) => tester
      .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, label).first)
      .selected;

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
    await reveal(tester, find.text('Solve'));
    await tester.tap(find.text('Solve'));
    await tester.pumpAndSettle();

    // Default preset is the easy 9×9: singles alone solve it.
    expect(find.byKey(const ValueKey('sudoku-explanation-summary')),
        findsOneWidget);
    expect(find.textContaining('Naked singles 51'), findsOneWidget);
    // Zero counts are omitted, not printed as "Guesses 0".
    expect(find.textContaining('Guesses 0'), findsNothing);
    expect(find.text('Solved by logic alone: no guessing needed.'),
        findsOneWidget);

    // Not auto-playing: the first frame is the explained start.
    expect(find.textContaining('Start: '), findsOneWidget);
    await reveal(tester, find.byTooltip('Next step'));
    await tester.tap(find.byTooltip('Next step'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Naked single: r'), findsOneWidget);
    expect(find.textContaining('has only one candidate left'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous step'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Start: '), findsOneWidget);
  });

  testWidgets('summary omits every zero technique count', (tester) async {
    await pumpScreen(tester);
    await solve(tester);

    final summary = find.byKey(const ValueKey('sudoku-explanation-summary'));
    expect(summary, findsOneWidget);
    expect(find.textContaining('Naked singles 51'), findsOneWidget);
    for (final zero in [
      'Hidden singles 0',
      'Guesses 0',
      'Backtracks 0',
      'Max depth 0',
      'Cage sums 0',
      'Locked candidates 0',
    ]) {
      expect(find.textContaining(zero), findsNothing, reason: zero);
    }
  });

  testWidgets('AI Escargot shows eliminations and a search tree',
      (tester) async {
    await pumpScreen(tester);
    await pickPreset(tester, '9×9 hard (AI Escargot)');
    await solve(tester);
    expect(find.textContaining('Locked candidates '), findsOneWidget);
    expect(find.textContaining('Guesses 0'), findsNothing);
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

  testWidgets('phone: replay and explanation sit directly under the grid',
      (tester) async {
    await pumpScreenAt(tester, const Size(390, 844));
    await solve(tester);
    await tester.pumpAndSettle();

    final grid = tester.getRect(find.byType(SudokuGrid));
    final replay = tester
        .getRect(find.byKey(const ValueKey('sudoku-replay-section')));
    final summary =
        tester.getRect(find.byKey(const ValueKey('sudoku-explanation-summary')));

    // No huge scroll: board, replay controls and the reason all fit the
    // first 844 px, with the replay immediately below the grid.
    expect(replay.top, greaterThanOrEqualTo(grid.bottom - 1));
    expect(replay.top, lessThan(844));
    expect(summary.top, lessThan(844));
    expect(tester.takeException(), isNull);

    // One replay control set only, placed between the board and the
    // setup controls in the narrow list.
    expect(find.byTooltip('Play'), findsOneWidget);
    expect(find.byTooltip('Next step'), findsOneWidget);
    expect(find.byTooltip('Previous step'), findsOneWidget);
    final list = tester.widget<ListView>(find.byType(ListView));
    final children =
        (list.childrenDelegate as SliverChildListDelegate).children;
    expect(children.length, 3);
    expect(children[1].key, const ValueKey('sudoku-replay-section'));

    await tester.tap(find.byTooltip('Next step'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Naked single: r'), findsOneWidget);
  });

  testWidgets('phone: replay survives enlarged text without overflow',
      (tester) async {
    await pumpScreenAt(tester, const Size(390, 844), textScale: 1.8);
    await solve(tester);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final replay = tester
        .getRect(find.byKey(const ValueKey('sudoku-replay-section')));
    expect(replay.top, lessThan(844));
    await reveal(tester, find.byTooltip('Next step'));
    await tester.tap(find.byTooltip('Next step'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Naked single: r'), findsOneWidget);
  });

  testWidgets('generator difficulty is labelled and follows the preset',
      (tester) async {
    await pumpScreen(tester);
    // A fresh screen starts on the easy 9×9 preset.
    expect(chipSelected(tester, 'Easy'), isTrue);
    expect(find.text('New puzzle difficulty'), findsOneWidget);

    await pickPreset(tester, '9×9 hard (AI Escargot)');
    // The hard preset must not leave "Medium" highlighted as if it
    // described the loaded puzzle.
    expect(chipSelected(tester, 'Hard'), isTrue);
    expect(chipSelected(tester, 'Medium'), isFalse);
    expect(chipSelected(tester, 'Easy'), isFalse);
    expect(find.text('9×9 hard (AI Escargot)'), findsOneWidget);

    // The chips remain the generator's own setting: changing one does
    // not alter the loaded preset.
    await reveal(tester, find.widgetWithText(ChoiceChip, 'Medium'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Medium'));
    await tester.pumpAndSettle();
    expect(chipSelected(tester, 'Medium'), isTrue);
    expect(chipSelected(tester, 'Hard'), isFalse);
    expect(find.text('9×9 hard (AI Escargot)'), findsOneWidget);
  });

  testWidgets('preset then generated puzzle keeps one replay control set',
      (tester) async {
    await pumpScreenAt(tester, const Size(390, 844));
    await pickPreset(tester, '4×4 hard');
    await solve(tester);
    expect(find.byKey(const ValueKey('sudoku-replay-section')), findsOneWidget);
    expect(find.byTooltip('Next step'), findsOneWidget);

    // Back out to setup, generate a fresh 4×4 puzzle.
    await reveal(tester, find.text('Generate'));
    await tester.tap(find.text('Generate'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // A generated puzzle has no preset label; the trace is cleared and
    // solving it re-opens exactly one replay section.
    expect(find.byKey(const ValueKey('sudoku-replay-section')), findsNothing);
    await solve(tester);
    expect(find.byKey(const ValueKey('sudoku-replay-section')), findsOneWidget);
    expect(find.byTooltip('Next step'), findsOneWidget);
  });
}
