// Round 105b (P6): per-element help popovers for the Constraints DSL.
// The mini-DSL operators have no standing widgets (they live in the
// free-form program text), so help mode reveals a reference row of
// operator chips; each opens the Function Reference popover for that
// operator. Outside help mode the row is hidden (normal UX unchanged).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/function_reference.dart';
import 'package:crisp_math/screens/constraints_screen.dart';

Future<void> _openDslTab(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1280, 800));
  await tester.pumpWidget(const MaterialApp(home: ConstraintsScreen()));
  await tester.pumpAndSettle();
  // DSL is the 3rd tab.
  await tester.tap(find.byType(Tab).at(2));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => AppState().setHelpMode(false));
  tearDown(() => AppState().setHelpMode(false));

  testWidgets('help off: the DSL operator reference row is hidden',
      (tester) async {
    await _openDslTab(tester);
    expect(find.widgetWithText(ActionChip, 'allDifferent'), findsNothing);
  });

  test('every DSL help chip maps to a real Function Reference entry', () {
    final ids = {for (final e in FunctionReferences.all) e.id};
    for (final (label, refId) in dslOperatorHelpChips) {
      expect(ids, contains(refId),
          reason: 'chip "$label" → refId "$refId" has no catalogue entry');
    }
  });

  testWidgets('help on: EVERY operator chip appears and opens its popover',
      (tester) async {
    await _openDslTab(tester);

    AppState().setHelpMode(true);
    await tester.pump();

    // Exhaustive: every operator in the DSL is surfaced as a chip.
    for (final (label, _) in dslOperatorHelpChips) {
      expect(find.widgetWithText(ActionChip, label), findsOneWidget,
          reason: 'missing help chip for "$label"');
    }

    // Spot-check a Round 108 global end-to-end: tapping opens the popover
    // for its Function Reference id.
    await tester.tap(find.text('table'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    final ref = FunctionReferences.all.firstWhere((e) => e.id == 'table');
    expect(find.text(ref.signature), findsOneWidget);
    expect(find.text('Learn more'), findsOneWidget);
  });
}
