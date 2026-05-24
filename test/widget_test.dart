// Smoke test: the app boots without throwing.

import 'package:crisp_calc/engine/app_state.dart';
import 'package:crisp_calc/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App boots without throwing', (WidgetTester tester) async {
    // Pre-dismiss the onboarding tour so the smoke test isn't pinned
    // to a tour-overlay subtree.
    SharedPreferences.setMockInitialValues({
      'crisp.onboardingDismissed': true,
    });
    await AppState().load(force: true);
    await tester.pumpWidget(const CrispCalcApp());
    await tester.pump();
    expect(find.byType(CrispCalcApp), findsOneWidget);
  });
}
