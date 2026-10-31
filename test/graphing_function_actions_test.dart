// The "..." menu on a graphed function chip offers Edit and Remove. Edit
// loads the function into the input and Enter saves it back to the same
// slot; Remove clears the slot.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/localization/app_localizations.dart';
import 'package:crisp_math/screens/graphing_screen.dart';
import 'package:crisp_math/widgets/latex_input_field.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppState().load(force: true);
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: [AppLocalizationsDelegate()],
      supportedLocales: [Locale('en')],
      home: GraphingScreen(),
    ));
    await tester.pumpAndSettle();
  }

  String input(WidgetTester tester) => tester
      .widget<LatexInputField>(find.byType(LatexInputField).first)
      .controller
      .text;

  testWidgets('Edit loads the function and Enter saves it to its slot',
      (tester) async {
    AppState().updateFunction(0, 'x^2');
    AppState().updateFunction(1, 'sin(x)');
    await pump(tester);

    await tester.tap(find.byKey(const ValueKey('graph-function-actions-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(input(tester), 'x^2');

    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(AppState().graphFunctions[0], 'x^3');
    expect(AppState().graphFunctions[1], 'sin(x)');
    expect(AppState().graphFunctions[2], isEmpty,
        reason: 'An edit must not add a new function');
    expect(input(tester), isEmpty);
  });

  testWidgets('Remove clears only that slot', (tester) async {
    AppState().updateFunction(0, 'x^2');
    AppState().updateFunction(1, 'sin(x)');
    await pump(tester);

    await tester.tap(find.byKey(const ValueKey('graph-function-actions-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(AppState().graphFunctions[0], 'x^2');
    expect(AppState().graphFunctions[1], isEmpty);
  });

  testWidgets('typing after a click on the plot still reaches the input',
      (tester) async {
    await pump(tester);
    await tester.tap(find.byType(LatexInputField).first);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(600, 500));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
    await tester.pumpAndSettle();
    expect(input(tester), '7');
  });
}
