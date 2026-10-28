// The first-run tour opens on the live worksheet and reports whether the
// user chose to try it (MainScreen then opens the guided example).

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/localization/app_localizations.dart';
import 'package:crisp_math/widgets/onboarding_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppState().load(force: true);
  });

  Future<bool?> runTour(
      WidgetTester tester, Future<void> Function() act) async {
    bool? result;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [AppLocalizationsDelegate()],
      supportedLocales: const [Locale('en')],
      home: Builder(
          builder: (context) => TextButton(
              onPressed: () async =>
                  result = await OnboardingTour.show(context),
              child: const Text('start'))),
    ));
    await tester.tap(find.text('start'));
    await tester.pumpAndSettle();
    await act();
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('first card is the worksheet; its button returns true',
      (tester) async {
    final result = await runTour(tester, () async {
      expect(find.text('A calculator that remembers'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('onboarding-try-worksheet')));
    });
    expect(result, isTrue);
    expect(AppState().onboardingDismissed, isTrue);
  });

  testWidgets('skipping returns false and still dismisses the tour',
      (tester) async {
    final result = await runTour(tester, () async {
      await tester.tap(find.text('Skip'));
    });
    expect(result, isFalse);
    expect(AppState().onboardingDismissed, isTrue);
  });
}
