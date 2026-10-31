import 'dart:async';

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/screens/calculator_screen.dart';
import 'package:crisp_math/services/engine_dispatch.dart';
import 'package:crisp_math/widgets/calculator_input_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('pending result refreshes the preserved Ans draft preview',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppState().load(force: true);
    AppState().addHistoryEntry('2', '2');
    final started = Completer<void>();
    final release = Completer<void>();
    final engine = CalculatorEngine();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CalculatorScreen(engineOpForTesting: (op) async {
        started.complete();
        await release.future;
        return runEngineOpDetailed(engine, op);
      })),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit expression'));
    await tester.pumpAndSettle();
    final field = find.byType(TextField);
    await tester.enterText(field, '2+3');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(started.isCompleted, isTrue);
    await tester.enterText(field, 'Ans+1');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(tester.widget<CalculatorInputBar>(find.byType(CalculatorInputBar))
        .resultPreview, '3');
    release.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(tester.widget<TextField>(field).controller!.text, 'Ans+1');
    expect(tester.widget<CalculatorInputBar>(find.byType(CalculatorInputBar))
        .resultPreview, '6');
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
