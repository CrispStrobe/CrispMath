import 'package:crisp_math/localization/app_localizations.dart';
import 'package:crisp_math/screens/sudoku_screen.dart';
import 'package:crisp_math/widgets/sudoku_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('solver error follows locale changes without re-solving',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Widget app(Locale locale) => MaterialApp(
          locale: locale,
          supportedLocales: const [Locale('en'), Locale('de')],
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SudokuScreen(),
        );
    await tester.pumpWidget(app(const Locale('en')));
    await tester.pumpAndSettle();
    // The default puzzle starts with 5 in row 1, and cell 2 is empty.
    tester.widget<SudokuGrid>(find.byType(SudokuGrid)).onDropDigit!(2, 5);
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Solve'), 250,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Solve'));
    await tester.pumpAndSettle();
    expect(find.text('The clues already break a rule.'), findsOneWidget);
    await tester.pumpWidget(app(const Locale('de')));
    await tester.pumpAndSettle();
    expect(find.text('Die Vorgaben verletzen bereits eine Regel.'),
        findsOneWidget);
    expect(find.text('The clues already break a rule.'), findsNothing);
  });
}
