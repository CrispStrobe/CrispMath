import 'dart:async';

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/screens/calculator_screen.dart';
import 'package:crisp_math/services/engine_dispatch.dart';
import 'package:crisp_math/services/engine_op.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppState().load(force: true);
  });

  testWidgets('pending engine completion preserves later editor input',
      (tester) async {
    final release = Completer<void>();
    final started = Completer<void>();
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
    await tester.enterText(field, '1+2');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(started.isCompleted, isTrue);
    await tester.enterText(field, '9');
    release.complete();
    await tester.pump();
    await tester.pump();
    expect(AppState().history.single.expression, '1+2');
    expect(AppState().history.single.result, '3');
    expect(tester.widget<TextField>(field).controller!.text, '9');
    expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);
    await tester.enterText(field, '+7');
    expect(tester.widget<TextField>(field).controller!.text, '+7',
        reason: 'the completion must not treat the new draft as a fresh answer');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('overlapping assignment runs after the first calculation',
      (tester) async {
    final release = Completer<void>();
    final started = Completer<void>();
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
    await tester.enterText(field, '1+2');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(started.isCompleted, isTrue);
    await tester.enterText(field, 'a=8');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(AppState().history, isEmpty,
        reason: 'a second dispatch must not run during the first');
    release.complete();
    await tester.pump();
    await tester.pump();
    final first = AppState().history.last;
    expect(first.expression, '1+2');
    expect(first.result, '3');
    expect(first.resultEvidence?.method,
        runEngineOpDetailed(engine, const EngineOp('evaluate', '1+2'))
            .evidence?.method);
    await tester.pump();
    expect(AppState().history, hasLength(2));
    expect(AppState().history.first.expression, 'a=8');
    expect(AppState().history.first.result, 'Stored a = 8');
    expect(AppState().history.last.result, '3');
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('queued submissions retain order and preserve a newer draft',
      (tester) async {
    final release = Completer<void>();
    final started = Completer<void>();
    final engine = CalculatorEngine();
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CalculatorScreen(engineOpForTesting: (op) async {
        if (calls++ == 0) {
          started.complete();
          await release.future;
        }
        return runEngineOpDetailed(engine, op);
      })),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit expression'));
    await tester.pumpAndSettle();
    final field = find.byType(TextField);
    await tester.enterText(field, '1+2');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(started.isCompleted, isTrue);
    for (final expression in ['4+5', '7+8']) {
      await tester.enterText(field, expression);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
    }
    await tester.enterText(field, '99');
    release.complete();
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(AppState().history.map((entry) => entry.expression).toList(),
        ['7+8', '4+5', '1+2']);
    expect(AppState().history.map((entry) => entry.result).toList(),
        ['15', '9', '3']);
    expect(tester.widget<TextField>(field).controller!.text, '99');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('late engine error preserves an edited draft', (tester) async {
    final release = Completer<void>();
    final started = Completer<void>();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CalculatorScreen(engineOpForTesting: (op) async {
        started.complete();
        await release.future;
        throw StateError('engine unavailable');
      })),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit expression'));
    await tester.pumpAndSettle();
    final field = find.byType(TextField);
    await tester.enterText(field, '1+2');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(started.isCompleted, isTrue);
    await tester.enterText(field, '7');
    release.complete();
    await tester.pump();
    await tester.pump();
    expect(AppState().history.single.result, 'Error: Bad state: engine unavailable');
    expect(tester.widget<TextField>(field).controller!.text, '7');
    await tester.enterText(field, '+2');
    expect(tester.widget<TextField>(field).controller!.text, '+2');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
