import 'dart:async';

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/screens/calculator_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('only one history import may run at a time', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppState().load(force: true);
    final picker = Completer<List<CalculationEntry>?>();
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CalculatorScreen(historyFileOpenForTesting: () {
        calls++;
        return picker.future;
      })),
    ));
    await tester.pump();
    await tester.tap(find.byTooltip('Calculator menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load history'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Load history'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Calculator menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load history'));
    await tester.pump();
    expect(find.text('A history file is already being loaded.'), findsOneWidget);
    expect(calls, 1);
    picker.complete(null);
    await tester.pumpAndSettle();
  });

  testWidgets('loading asks again if history changed after confirmation',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.load(force: true);
    state.addHistoryEntry('1+1', '2');
    final picker = Completer<List<CalculationEntry>?>();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CalculatorScreen(historyFileOpenForTesting: () => picker.future),
      ),
    ));
    await tester.pump();
    await tester.tap(find.byTooltip('Calculator menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load history'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Load history'));
    await tester.pumpAndSettle();
    // A calculation can finish while the platform file chooser is open.
    state.addHistoryEntry('2+2', '4');
    picker.complete([CalculationEntry(expression: '3+3', result: '6')]);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ElevatedButton, 'Load history'), findsOneWidget,
        reason: 'the new result was not part of the confirmed replacement');
    expect(
        find.text('History changed while loading. Loading will also replace the new entries. Continue?'),
        findsOneWidget);
    expect(state.history.map((e) => e.result), ['4', '2']);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(state.history.map((e) => e.result), ['4', '2']);
  });
}
