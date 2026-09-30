import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/main.dart';
import 'package:crisp_math/screens/graphing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'modules mount on first visit and graph state survives navigation',
      (tester) async {
    SharedPreferences.setMockInitialValues({'crisp.onboardingDismissed': true});
    await AppState().load(force: true);
    AppState().setOnboardingDismissed(true);
    await tester.pumpWidget(const CrispMathApp());
    await tester.pumpAndSettle();
    expect(find.byType(GraphingScreen, skipOffstage: false), findsNothing);
    final rail = find.byType(NavigationRail);
    await tester
        .tap(find.descendant(of: rail, matching: find.text('Graphing')));
    await tester.pumpAndSettle();
    final graphState =
        tester.state<GraphingScreenState>(find.byType(GraphingScreen));
    await tester
        .tap(find.descendant(of: rail, matching: find.text('Calculator')));
    await tester.pumpAndSettle();
    await tester
        .tap(find.descendant(of: rail, matching: find.text('Graphing')));
    await tester.pumpAndSettle();
    expect(tester.state<GraphingScreenState>(find.byType(GraphingScreen)),
        same(graphState));
    expect(tester.takeException(), isNull);
  });
}
