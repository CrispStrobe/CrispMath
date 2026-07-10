// Tests for the KeypadGrid compact-mode spacing adaptation.

import 'package:crisp_math/widgets/keypad_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KeypadGrid compact mode', () {
    testWidgets('renders buttons in normal mode', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: KeypadGrid(
              buttons: const ['1', '2', '3', '+'],
              onButtonPressed: (_) {},
            ),
          ),
        ),
      ));
      // All 4 buttons should render.
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('+'), findsOneWidget);
    });

    testWidgets('renders buttons in compact mode (height < 280)',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 200, // compact — triggers reduced spacing
            child: KeypadGrid(
              buttons: const ['1', '2', '3', '+'],
              onButtonPressed: (_) {},
            ),
          ),
        ),
      ));
      // Buttons still render — compact mode only changes spacing.
      expect(find.text('1'), findsOneWidget);
      expect(find.text('+'), findsOneWidget);
    });

    testWidgets('fires onButtonPressed callback', (tester) async {
      String? pressed;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: KeypadGrid(
              buttons: const ['7', '8', '9', '*'],
              onButtonPressed: (b) => pressed = b,
            ),
          ),
        ),
      ));
      await tester.tap(find.text('7'));
      expect(pressed, '7');
    });

    testWidgets('renders full 20-button grid', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: KeypadGrid(
              buttons: List.generate(20, (i) => '$i'),
              onButtonPressed: (_) {},
            ),
          ),
        ),
      ));
      expect(find.text('0'), findsOneWidget);
      expect(find.text('19'), findsOneWidget);
    });
  });
}
