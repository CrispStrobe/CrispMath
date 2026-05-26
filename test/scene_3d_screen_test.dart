// P9-A2: smoke tests for the Scene3DScreen. Verifies the empty
// state, that adding a plane shows up in the object panel, and
// that delete removes it. Doesn't exercise the painter — that's
// covered by the engine tests + the in-app render check.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crisp_calc/engine/app_state.dart';
import 'package:crisp_calc/engine/scene_3d/scene_object.dart';
import 'package:crisp_calc/localization/app_localizations.dart';
import 'package:crisp_calc/screens/scene_3d_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // Reset the singleton AppState so each test starts with a clean
    // (empty) scene.
    final s = AppState();
    s.history.clear();
    s.userVariables.clear();
    s.userFunctions.clear();
    s.notepadDocuments.clear();
    // Drain the scene to defaults.
    for (final obj in List.of(s.scene3D.objects)) {
      s.removeSceneObject(obj.id);
    }
  });

  Future<void> pumpScene(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: [AppLocalizationsDelegate()],
      supportedLocales: [Locale('en')],
      home: Scene3DScreen(),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the empty hint when no objects are in the scene',
      (tester) async {
    await pumpScene(tester);
    expect(find.text('3D Scene'), findsOneWidget);
    expect(find.textContaining('+ button'), findsOneWidget);
    expect(find.text('No objects yet'), findsOneWidget);
  });

  testWidgets('plane added via AppState appears in the panel', (tester) async {
    AppState().addOrUpdateSceneObject(const PlaneObject(
      id: 'p1',
      label: 'X = 0',
      color: 0xFFE53935,
      a: 1,
      b: 0,
      c: 0,
      d: 0,
    ));
    await pumpScene(tester);
    expect(find.text('X = 0'), findsOneWidget);
    expect(find.text('No objects yet'), findsNothing);
  });

  testWidgets('removeSceneObject empties the panel', (tester) async {
    AppState().addOrUpdateSceneObject(const PlaneObject(
      id: 'p1',
      label: 'X = 0',
      color: 0xFFE53935,
      a: 1,
      b: 0,
      c: 0,
      d: 0,
    ));
    await pumpScene(tester);
    expect(find.text('X = 0'), findsOneWidget);

    AppState().removeSceneObject('p1');
    await tester.pumpAndSettle();
    expect(find.text('X = 0'), findsNothing);
    expect(find.text('No objects yet'), findsOneWidget);
  });
}
