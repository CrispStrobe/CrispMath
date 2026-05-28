// Round 105b (P6): per-element help popovers on the Sudoku variant
// selector. In help mode each variant chip (Regular / Sudoku-X /
// Killer / Disjoint) opens the Function Reference popover describing
// that variant's rules instead of switching to it.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crisp_calc/engine/app_state.dart';
import 'package:crisp_calc/engine/function_reference.dart';
import 'package:crisp_calc/screens/sudoku_screen.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1280, 800));
  await tester.pumpWidget(const MaterialApp(home: SudokuScreen()));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => AppState().setHelpMode(false));
  tearDown(() async {
    AppState().setHelpMode(false);
  });

  testWidgets(
      'help off: tapping the Sudoku-X chip switches variant, no popover',
      (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Sudoku-X'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('help on: tapping a variant chip opens its FunctionRef popover',
      (tester) async {
    await _pump(tester);

    AppState().setHelpMode(true);
    await tester.pump();

    await tester.tap(find.text('Sudoku-X'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    final ref = FunctionReferences.all.firstWhere((e) => e.id == 'sudoku_x');
    expect(find.text(ref.signature), findsOneWidget);
    expect(find.text('Learn more'), findsOneWidget);
  });
}
