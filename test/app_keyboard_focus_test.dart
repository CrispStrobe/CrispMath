// Hardware keys only reach a pane while its key listener holds focus.
// When focus falls back to a scope, the shell must hand it back to the
// active pane, or typed keys are silently dropped.

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/main.dart';
import 'package:crisp_math/widgets/latex_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'crisp.onboardingDismissed': true});
    await AppState().load(force: true);
    AppState().setOnboardingDismissed(true);
  });

  Future<void> openTab(WidgetTester tester, String label) async {
    final rail = find.byType(NavigationRail);
    await tester.tap(find.descendant(of: rail, matching: find.text(label)));
    await tester.pumpAndSettle();
  }

  String activeInput(WidgetTester tester) => tester
      .widgetList<LatexInputField>(find.byType(LatexInputField))
      .map((w) => w.controller.text)
      .firstWhere((text) => text.isNotEmpty, orElse: () => '');

  testWidgets('lost focus returns to the active pane', (tester) async {
    await tester.pumpWidget(const CrispMathApp());
    await tester.pumpAndSettle();
    await openTab(tester, 'Graphing');

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus, isNot(isA<FocusScopeNode>()));

    await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
    await tester.pumpAndSettle();
    expect(activeInput(tester), '5');
  });

  testWidgets('the function editor tab receives keys when opened',
      (tester) async {
    await tester.pumpWidget(const CrispMathApp());
    await tester.pumpAndSettle();
    await openTab(tester, 'Functions');
    expect(FocusManager.instance.primaryFocus, isNot(isA<FocusScopeNode>()));
  });
}
