// test/boolean_chip_test.dart
//
// Widget coverage for the shared `BooleanChip` lifted in Round 113
// from `calculator_screen._buildBooleanChip`. The chip renders
// boolean predicate results in both the calculator history column
// and the notepad result column.

import 'package:crisp_math/widgets/boolean_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}

void main() {
  group('BooleanChip', () {
    testWidgets('true renders "true" label with secondaryContainer palette',
        (tester) async {
      await tester.pumpWidget(_wrap(const BooleanChip(value: true)));
      expect(find.text('true'), findsOneWidget);

      final scheme =
          Theme.of(tester.element(find.byType(BooleanChip))).colorScheme;
      final chip = tester.widget<Chip>(find.byType(Chip));
      expect(chip.backgroundColor, scheme.secondaryContainer);
    });

    testWidgets('false renders "false" label with errorContainer palette',
        (tester) async {
      await tester.pumpWidget(_wrap(const BooleanChip(value: false)));
      expect(find.text('false'), findsOneWidget);

      final scheme =
          Theme.of(tester.element(find.byType(BooleanChip))).colorScheme;
      final chip = tester.widget<Chip>(find.byType(Chip));
      expect(chip.backgroundColor, scheme.errorContainer);
    });

    testWidgets('font size override applies to the label', (tester) async {
      await tester
          .pumpWidget(_wrap(const BooleanChip(value: true, fontSize: 16)));
      final label = tester.widget<Text>(find.text('true'));
      expect(label.style?.fontSize, 16);
    });

    testWidgets('default font size is 18 (calculator surface)', (tester) async {
      await tester.pumpWidget(_wrap(const BooleanChip(value: false)));
      final label = tester.widget<Text>(find.text('false'));
      expect(label.style?.fontSize, 18);
    });
  });
}
