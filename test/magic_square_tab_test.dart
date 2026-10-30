// Widget coverage for the Constraints → Magic square generator tab.

import 'package:crisp_math/engine/magic_square.dart';
import 'package:crisp_math/screens/constraints_screen.dart';
import 'package:crisp_math/widgets/propagation_visualizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _openMagicTab(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1280, 900));
  await tester.pumpWidget(const MaterialApp(home: ConstraintsScreen()));
  await tester.pumpAndSettle();
  // Magic square is the 5th tab (index 4).
  await tester.tap(find.byType(Tab).at(4));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('generates a valid 3×3 square on tap', (tester) async {
    await _openMagicTab(tester);

    // Default order 3×3 → magic constant 15.
    expect(find.text('Magic constant: 15'), findsOneWidget);

    await tester.tap(find.text('Generate'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // The rendered grid shows all nine values 1..9.
    for (var v = 1; v <= 9; v++) {
      expect(find.text('$v'), findsWidgets);
    }
  });

  testWidgets('switching size updates the magic constant', (tester) async {
    await _openMagicTab(tester);
    await tester.tap(find.text('4×4'));
    await tester.pumpAndSettle();
    expect(find.text('Magic constant: ${MagicSquare.constantFor(4)}'),
        findsOneWidget);
  });

  testWidgets('replay and displayed square describe the same solution',
      (tester) async {
    await _openMagicTab(tester);
    await tester.tap(find.text('Generate'));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await tester.ensureVisible(find.byKey(const ValueKey('magic-visualize')));
    await tester.tap(find.byKey(const ValueKey('magic-visualize')));
    await tester.pumpAndSettle();

    final replay = tester.widget<PropagationVisualizer>(
        find.byType(PropagationVisualizer));
    expect(replay.trace.solved, isTrue);
    final grid = find.byKey(const ValueKey('magic-square-grid'));
    final displayed = tester
        .widgetList<Text>(find.descendant(of: grid, matching: find.byType(Text)))
        .map((text) => int.tryParse(text.data ?? ''))
        .whereType<int>()
        .toList();
    expect(displayed, MagicSquare.gridFromSolution(replay.trace.solution!, 3));

    await tester.ensureVisible(find.text('Generate'));
    await tester.tap(find.text('Generate'));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byType(PropagationVisualizer), findsNothing,
        reason: 'a new square must not retain a stale replay');
  });
}
