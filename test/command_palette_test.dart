import 'package:crisp_math/engine/command_catalog.dart';
import 'package:crisp_math/widgets/command_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
