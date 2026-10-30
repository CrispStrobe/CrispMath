import 'dart:async';

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:crisp_math/screens/calculator_screen.dart';
import 'package:crisp_math/services/engine_op.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'crisp.autoBindSolve': true});
    await AppState().load(force: true);
  });

  testWidgets('disposed solve does not auto-bind its late result',
      (tester) async {
    final result = Completer<ComputedResult>();
    final started = Completer<EngineOp>();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CalculatorScreen(engineOpForTesting: (op) {
        started.complete(op);
        return result.future;
      })),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit expression'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'solve(x-2,x)');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(started.isCompleted, isTrue);
    expect((await started.future).kind, 'solve');
    await tester.pumpWidget(const SizedBox.shrink());
    result.complete(const ComputedResult('{2}', null));
    await tester.pump();
    await tester.pump();
    expect(AppState().getVariable('x'), isNull);
    expect(AppState().history, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('mounted solve still auto-binds its late result', (tester) async {
    final result = Completer<ComputedResult>();
    final started = Completer<EngineOp>();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CalculatorScreen(engineOpForTesting: (op) {
        started.complete(op);
        return result.future;
      })),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit expression'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'solve(x-2,x)');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(started.isCompleted, isTrue);
    expect((await started.future).kind, 'solve');
    result.complete(const ComputedResult('{2}', null));
    await tester.pump();
    await tester.pump();
    expect(AppState().getVariable('x'), '2');
    expect(AppState().history.single.result, '{2}');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('disposed inline derivative does not start another operation',
      (tester) async {
    final first = Completer<ComputedResult>();
    final calls = <EngineOp>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CalculatorScreen(engineOpForTesting: (op) {
        calls.add(op);
        return calls.length == 1
            ? first.future
            : Future.value(const ComputedResult('3*x^2', null));
      })),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit expression'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'diff(x^2,x)+diff(x^3,x)');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(calls, hasLength(1));
    expect(calls.single.kind, 'differentiate');
    await tester.pumpWidget(const SizedBox.shrink());
    first.complete(const ComputedResult('2*x', null));
    await tester.pump();
    await tester.pump();
    expect(calls, hasLength(1));
    expect(AppState().history, isEmpty);
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('disposed failed derivative does not start another prefix',
      (tester) async {
    final first = Completer<ComputedResult>();
    final calls = <EngineOp>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CalculatorScreen(engineOpForTesting: (op) {
        calls.add(op);
        return calls.length == 1
            ? first.future
            : Future.value(const ComputedResult('3*x^2', null));
      })),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit expression'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'd/dx(x^2,x)+diff(x^3,x)');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(calls, hasLength(1));
    expect(calls.single.kind, 'differentiate');
    await tester.pumpWidget(const SizedBox.shrink());
    first.completeError(StateError('engine unavailable'));
    await tester.pump();
    await tester.pump();
    expect(calls, hasLength(1));
    expect(AppState().history, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('disposed piecewise fold does not start another condition',
      (tester) async {
    final first = Completer<ComputedResult>();
    final calls = <EngineOp>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CalculatorScreen(engineOpForTesting: (op) {
        calls.add(op);
        return calls.length == 1
            ? first.future
            : Future.value(const ComputedResult('true', null));
      })),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit expression'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'piecewise(x<0,1,x<1,2,3)');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(calls, hasLength(1));
    expect(calls.single.kind, 'evaluate');
    await tester.pumpWidget(const SizedBox.shrink());
    first.complete(const ComputedResult('false', null));
    await tester.pump();
    await tester.pump();
    expect(calls, hasLength(1));
    expect(AppState().history, isEmpty);
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('late EXE result does not steal history search focus',
      (tester) async {
    AppState().addHistoryEntry('earlier', '1');
    final result = Completer<ComputedResult>();
    final started = Completer<EngineOp>();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CalculatorScreen(engineOpForTesting: (op) {
        started.complete(op);
        return result.future;
      })),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit expression'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '1+2');
    await tester.tap(find.byIcon(Icons.keyboard_return));
    await tester.pump();
    expect(started.isCompleted, isTrue);
    expect((await started.future).kind, 'evaluate');
    final keyboard =
        tester.widget<KeyboardListener>(find.byType(KeyboardListener));
    expect(keyboard.focusNode.hasPrimaryFocus, isTrue,
        reason: 'EXE intentionally focuses the calculator at initiation');
    await tester.tap(find.byTooltip('Calculator menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Search history'));
    await tester.pumpAndSettle();
    final search = find.byWidgetPredicate((widget) =>
        widget is TextField &&
        widget.decoration?.hintText == 'Filter history…');
    expect(search, findsOneWidget);
    final searchFocus = tester.widget<TextField>(search).focusNode!;
    expect(searchFocus.hasPrimaryFocus, isTrue);
    result.complete(const ComputedResult('3', null));
    await tester.pump();
    await tester.pump();
    expect(AppState().history.first.result, '3');
    expect(searchFocus.hasPrimaryFocus, isTrue);
    await tester.enterText(search, 'earlier');
    await tester.pump(const Duration(milliseconds: 250));
    expect(searchFocus.hasPrimaryFocus, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
