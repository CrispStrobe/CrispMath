// Smoke tests for the plot-mode selector (roadmap C5.2). Confirms the
// GraphingScreen mounts, the mode selector switches through all four
// modes, the right expression inputs appear, and nothing throws while
// the painter samples/renders each mode. The sampling math itself is
// covered by plot_types_test.dart.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crisp_math/localization/app_localizations.dart';
import 'package:crisp_math/screens/graphing_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

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

  testWidgets('mode selector offers all four plot modes', (tester) async {
    await pump(tester);
    expect(find.text('y = f(x)'), findsOneWidget);
    expect(find.text('Parametric'), findsOneWidget);
    expect(find.text('Polar'), findsOneWidget);
    expect(find.text('Implicit'), findsOneWidget);
  });

  testWidgets('parametric mode shows x(t)/y(t) inputs and renders',
      (tester) async {
    await pump(tester);
    await tester.tap(find.text('Parametric'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'cos(t)'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'sin(t)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('polar mode shows r(θ) input and renders', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Polar'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, '1 + cos(theta)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('implicit mode shows F(x,y) input and renders', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Implicit'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'x^2 + y^2 - 4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editing a parametric expression does not throw', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Parametric'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'cos(t)'), '2*cos(t)');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching back to cartesian restores the classic view',
      (tester) async {
    await pump(tester);
    await tester.tap(find.text('Implicit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('y = f(x)'));
    await tester.pumpAndSettle();
    // The implicit input is gone in cartesian mode.
    expect(find.widgetWithText(TextField, 'x^2 + y^2 - 4'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
