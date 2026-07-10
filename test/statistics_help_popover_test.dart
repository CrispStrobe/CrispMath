// Round 105b (P6): per-element help popovers on the Statistics Tests
// tab. Each test-picker chip whose test has a Function Reference entry
// is wrapped in a HelpTarget; in help mode a tap opens the shared
// FunctionRef popover (signature + localized description + "Learn
// more") instead of selecting the test. The one-sample-t chip has no
// catalog entry, so it stays a plain selector even in help mode.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/function_reference.dart';
import 'package:crisp_math/localization/app_localizations.dart';
import 'package:crisp_math/screens/statistics_screen.dart';

void main() {
  setUp(() => AppState().setHelpMode(false));
  tearDown(() => AppState().setHelpMode(false));

  Widget host({Locale locale = const Locale('en')}) => MaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('de')],
        locale: locale,
        home: const StatisticsScreen(),
      );

  // Tests tab is the 4th tab.
  Future<void> openTestsTab(WidgetTester tester) async {
    await tester.tap(find.byType(Tab).at(3));
    await tester.pumpAndSettle();
  }

  testWidgets('help off: tapping a test chip selects it, no popover',
      (tester) async {
    await tester.pumpWidget(host());
    await openTestsTab(tester);

    await tester.tap(find.text('Two-sample t (Welch)'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('help on: tapping a mapped chip opens its FunctionRef popover',
      (tester) async {
    await tester.pumpWidget(host());
    await openTestsTab(tester);

    AppState().setHelpMode(true);
    await tester.pump();

    // Absorbing-overlay false-alarm suppressed, same as the keypad
    // popover tests.
    await tester.tap(find.text('Two-sample t (Welch)'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    final welch = FunctionReferences.all.firstWhere((e) => e.id == 'welch_t');
    expect(find.text(welch.signature), findsOneWidget);
    expect(find.text('Learn more'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });

  testWidgets('DE locale: the popover shows the German description (R100)',
      (tester) async {
    await tester.pumpWidget(host(locale: const Locale('de')));
    await openTestsTab(tester);

    AppState().setHelpMode(true);
    await tester.pump();

    await tester.tap(find.text('Two-sample t (Welch)'), warnIfMissed: false);
    await tester.pumpAndSettle();

    final deDesc = const DeLocalizations().functionRefDescription('welch_t');
    expect(deDesc, isNotNull);
    // First clause is enough to confirm the localized string rendered.
    expect(
        find.textContaining(deDesc!.split('(').first.trim()), findsOneWidget);
  });

  testWidgets('help on: the one-sample-t chip (no catalog entry) skips popover',
      (tester) async {
    await tester.pumpWidget(host());
    await openTestsTab(tester);

    AppState().setHelpMode(true);
    await tester.pump();

    await tester.tap(find.text('One-sample t'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
