import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('removing a parameter updates mounted sibling panes after build',
      (tester) async {
    SharedPreferences.setMockInitialValues({'crisp.onboardingDismissed': true});
    final state = AppState();
    await state.load(force: true);
    state.clearAllFunctions();
    state.updateFunction(0, 'a*x');
    await tester.pumpWidget(const CrispMathApp());
    await tester.pumpAndSettle();
    final rail = find.byType(NavigationRail);
    await tester.tap(find.descendant(of: rail, matching: find.text('Notepad')));
    await tester.pumpAndSettle();
    await tester
        .tap(find.descendant(of: rail, matching: find.text('Graphing')));
    await tester.pumpAndSettle();
    expect(state.functionParameters[0], contains('a'));
    state.updateFunction(0, 'x');
    await tester.pumpAndSettle();
    expect(state.functionParameters[0]?.containsKey('a') ?? false, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
