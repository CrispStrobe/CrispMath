// The Sudoku preset field must always name the puzzle that is actually
// loaded: the selected preset while one is loaded, and the localized
// "Custom" placeholder once the grid is generated, hand-edited or
// switched to a size without a preset. It used to be a FormField that
// owned its own value, so it drifted from the loaded puzzle.
//
// The size/variant chips also fire for the chip that is already active.
// That used to re-resolve the same combination to a preset and silently
// replace the user's edited grid (clues included); it is a no-op now.

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/sudoku.dart';
import 'package:crisp_math/screens/sudoku_screen.dart';
import 'package:crisp_math/widgets/sudoku_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppState().consumePendingSudokuPresetId();
  });

  final presetField = find.byType(DropdownButton<SudokuPuzzle>);

  SudokuPuzzle preset(String id) =>
      SudokuPresets.all.firstWhere((p) => p.id == id).puzzle;

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: SudokuScreen()));
    await tester.pumpAndSettle();
  }

  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  Future<void> pickPreset(WidgetTester tester, String label) async {
    await reveal(tester, presetField);
    await tester.tap(presetField);
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  /// What the field displays: the loaded preset, or null when the grid is
  /// custom (generated, hand-edited or a size without a preset).
  SudokuPuzzle? fieldValue(WidgetTester tester) =>
      tester.widget<DropdownButton<SudokuPuzzle>>(presetField).value;

  List<int> gridCells(WidgetTester tester) =>
      tester.widget<SudokuGrid>(find.byType(SudokuGrid)).cells;

  /// Fills the first empty cell from the digit pad and returns its index.
  Future<int> enterDigit(WidgetTester tester, int digit) async {
    final grid = tester.widget<SudokuGrid>(find.byType(SudokuGrid));
    final index = grid.cells.indexWhere((v) => v == 0);
    expect(index, isNonNegative, reason: 'grid has no empty cell');
    final side = grid.layout.side;
    final rect = tester.getRect(find.byType(SudokuGrid));
    await tester.tapAt(Offset(
      rect.left + (index % side + 0.5) * rect.width / side,
      rect.top + (index ~/ side + 0.5) * rect.height / side,
    ));
    await tester.pumpAndSettle();
    final button = find.widgetWithText(OutlinedButton, '$digit');
    await reveal(tester, button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(gridCells(tester)[index], digit,
        reason: 'entry did not reach the tapped cell');
    return index;
  }

  testWidgets('preset field names the preset, then Custom after Generate',
      (tester) async {
    await pumpScreen(tester);
    // The field-initializer preset is what the field reports on load.
    expect(identical(fieldValue(tester), preset('standard9x9Easy')), isTrue);
    expect(find.text('Custom'), findsNothing);

    await pickPreset(tester, '4×4 hard');
    expect(identical(fieldValue(tester), preset('small4x4Hard')), isTrue);
    expect(find.text('Custom'), findsNothing);

    // Generate replaces the preset with a fresh puzzle. The field must
    // drop the preset it no longer holds and say Custom — before the fix
    // the FormField kept its own state and the field showed no name.
    await reveal(tester, find.text('Generate'));
    await tester.tap(find.text('Generate'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(fieldValue(tester), isNull);
    expect(find.text('Custom'), findsOneWidget);
    expect(gridCells(tester).length, 16);
  });

  testWidgets('editing a clue turns the field Custom; a preset still loads',
      (tester) async {
    await pumpScreen(tester);
    await pickPreset(tester, '4×4 hard');
    expect(identical(fieldValue(tester), preset('small4x4Hard')), isTrue);

    await enterDigit(tester, 3);

    // The grid is no longer the preset, so the field must not keep
    // naming it.
    expect(fieldValue(tester), isNull);
    expect(find.text('Custom'), findsOneWidget);

    // The field still drives preset loading after the swap.
    await pickPreset(tester, '4×4 easy');
    expect(identical(fieldValue(tester), preset('small4x4Easy')), isTrue);
    expect(find.text('Custom'), findsNothing);
  });

  testWidgets('tapping the already-selected size keeps the edited grid',
      (tester) async {
    await pumpScreen(tester);
    await pickPreset(tester, '4×4 hard');
    final index = await enterDigit(tester, 3);
    final edited = List<int>.from(gridCells(tester));
    expect(edited[index], 3);

    // 4×4 is already the active size. Re-tapping it used to reload the
    // first 4×4 preset, wiping the digit the user had just entered.
    await reveal(tester, find.widgetWithText(ChoiceChip, '4×4'));
    await tester.tap(find.widgetWithText(ChoiceChip, '4×4'));
    await tester.pumpAndSettle();

    expect(gridCells(tester), edited);
    expect(gridCells(tester)[index], 3);
    expect(fieldValue(tester), isNull);
    expect(find.text('Custom'), findsOneWidget);
  });

  testWidgets('tapping the already-selected variant keeps the edited grid',
      (tester) async {
    await pumpScreen(tester);
    await pickPreset(tester, '4×4 hard');
    await enterDigit(tester, 2);
    final edited = List<int>.from(gridCells(tester));

    await reveal(tester, find.widgetWithText(ChoiceChip, 'Regular'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Regular'));
    await tester.pumpAndSettle();

    expect(gridCells(tester), edited);
    expect(fieldValue(tester), isNull);
  });

  testWidgets('switching to a size without a preset reports Custom',
      (tester) async {
    await pumpScreen(tester);
    await pickPreset(tester, '9×9 hard (AI Escargot)');
    expect(identical(fieldValue(tester), preset('standard9x9Hard')), isTrue);

    // No 16×16 preset exists, so this is an empty custom grid — and the
    // field must stop naming the 9×9 preset it replaced.
    await reveal(tester, find.widgetWithText(ChoiceChip, '16×16'));
    await tester.tap(find.widgetWithText(ChoiceChip, '16×16'));
    await tester.pumpAndSettle();

    expect(fieldValue(tester), isNull);
    expect(find.text('Custom'), findsOneWidget);
    expect(gridCells(tester), everyElement(0));
    expect(gridCells(tester).length, 256);
    expect(tester.takeException(), isNull);
  });
}
