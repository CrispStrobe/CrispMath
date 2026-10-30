import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/command_catalog.dart';
import 'package:crisp_math/localization/app_localizations.dart';
import 'package:crisp_math/main.dart';
import 'package:crisp_math/services/engine_service.dart';
import 'package:crisp_math/widgets/command_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('commands rank titles first and require every search term', () {
    expect(searchCommands('notepad').first.target, 'tab:1');
    expect(searchCommands('unit converter').first.target, 'units');
    expect(searchCommands('no-such-command'), isEmpty);
    expect(searchCommands('  TEMPERATURE '), isNotEmpty);
    expect(appCommands.map((c) => c.id).toSet().length, appCommands.length);
  });
  testWidgets('arrow keys select a command while the search field has focus',
      (tester) async {
    AppCommand? choice;
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => TextButton(
                onPressed: () async {
                  choice = await showDialog<AppCommand>(
                      context: context, builder: (_) => const CommandPalette());
                },
                child: const Text('Open')))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(choice?.target, 'tab:1');
  });
  testWidgets('search and Enter return an explicit command', (tester) async {
    AppCommand? choice;
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => TextButton(
                onPressed: () async {
                  choice = await showDialog<AppCommand>(
                      context: context, builder: (_) => const CommandPalette());
                },
                child: const Text('Open')))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'unit converter');
    // Submit before another frame: the filtered command must be current.
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(choice?.target, 'units');
  });
  testWidgets('shell command search costs no header row and needs no history',
      (tester) async {
    // Regression: the palette trigger used to be a full-width text button
    // above every tab, and the first attempt to move it into the history
    // header made it disappear whenever the history was empty — which is
    // exactly the cold-start state the browser check hits.
    SharedPreferences.setMockInitialValues({'crisp.onboardingDismissed': true});
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.binding.setSurfaceSize(null);
      await EngineService.shutdownForTest();
    });
    await AppState().load(force: true);
    await tester.pumpWidget(const CrispMathApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(AppState().history, isEmpty);
    expect(find.widgetWithText(TextButton, 'Search commands'), findsNothing,
        reason: 'the palette trigger must not spend a line above the body');
    final trigger = find.byTooltip('Calculator menu');
    expect(trigger, findsOneWidget,
        reason: 'the overflow menu must also work with empty history');
    expect(find.descendant(of: trigger, matching: find.byIcon(Icons.more_vert)),
        findsOneWidget);
    expect(find.byTooltip('Search commands'), findsNothing);
    await tester.tap(trigger);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Search commands'));
    await tester.pumpAndSettle();
    expect(find.text('Find a command'), findsWidgets);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    AppState().addHistoryEntry('1+1', '2');
    await tester.pumpAndSettle();
    expect(find.byTooltip('Clear History'), findsNothing,
        reason: 'clear belongs in the calculator menu, not a permanent row');
    await tester.tap(trigger);
    await tester.pumpAndSettle();
    expect(find.text('Clear History'), findsOneWidget);
    await tester.tap(find.text('Search history'));
    await tester.pumpAndSettle();
    final field = find.byWidgetPredicate((widget) => widget is TextField &&
        widget.decoration?.hintText == 'Filter history…');
    expect(field, findsOneWidget);
    await tester.enterText(field, 'missing');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    expect(find.text(AppLocalizations.of(tester.element(field)).historyNoMatches),
        findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(field, findsNothing);
  });

  testWidgets('calculator menu saves and loads history without a glyph row',
      (tester) async {
    SharedPreferences.setMockInitialValues({'crisp.onboardingDismissed': true});
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.binding.setSurfaceSize(null);
      await EngineService.shutdownForTest();
    });
    await AppState().load(force: true);
    await tester.pumpWidget(const CrispMathApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final trigger = find.byTooltip('Calculator menu');
    await tester.tap(trigger);
    await tester.pumpAndSettle();
    expect(find.text('Load history'), findsOneWidget,
        reason: 'loading stays reachable on a fresh install');
    expect(find.text('Save history'), findsNothing,
        reason: 'there is nothing to save yet');
    expect(find.text('Clear History'), findsNothing);
    await tester.tapAt(const Offset(10, 700));
    await tester.pumpAndSettle();
    AppState().addHistoryEntry('1+1', '2');
    await tester.pumpAndSettle();
    await tester.tap(trigger);
    await tester.pumpAndSettle();
    expect(find.text('Save history'), findsOneWidget);
    expect(find.text('Load history'), findsOneWidget);
    expect(find.text('Clear History'), findsOneWidget);
    expect(find.text('Search history'), findsOneWidget);
    await tester.tapAt(const Offset(10, 700));
    await tester.pumpAndSettle();
  });
}
