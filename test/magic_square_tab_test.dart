// Widget coverage for the Constraints → Magic square generator tab.

import 'package:crisp_math/engine/csp_solver.dart';
import 'package:crisp_math/engine/magic_square.dart';
import 'package:crisp_math/screens/constraints_screen.dart';
import 'package:crisp_math/widgets/propagation_visualizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lo Shu square, used as a canned solver answer in the seam tests.
const _loShu = [2, 7, 6, 9, 5, 1, 4, 3, 8];

DiophantineResult _loShuResult() => DiophantineResult.ok([
      {for (var i = 0; i < 9; i++) 'c$i': _loShu[i]}
    ]);

Future<void> _openMagicTab(WidgetTester tester,
    {MagicSquareSolve? solve}) async {
  await tester.binding.setSurfaceSize(const Size(1280, 900));
  await tester.pumpWidget(MaterialApp(
    home: ConstraintsScreen(magicSquareSolveForTesting: solve),
  ));
  await tester.pumpAndSettle();
  // Magic square is the 5th tab (index 4).
  await tester.tap(find.byType(Tab).at(4));
  await tester.pumpAndSettle();
}

/// Numbers rendered inside the magic-square grid, in row-major order.
List<int> _displayedGrid(WidgetTester tester) {
  final grid = find.byKey(const ValueKey('magic-square-grid'));
  return tester
      .widgetList<Text>(find.descendant(of: grid, matching: find.byType(Text)))
      .map((text) => int.tryParse(text.data ?? ''))
      .whereType<int>()
      .toList();
}

FilledButton _generateButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Generate'));

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
    expect(
      find.text('Magic constant: ${MagicSquare.constantFor(4)}'),
      findsOneWidget,
    );
  });

  testWidgets('replay and displayed square describe the same solution', (
    tester,
  ) async {
    await _openMagicTab(tester);
    await tester.tap(find.text('Generate'));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await tester.ensureVisible(find.byKey(const ValueKey('magic-visualize')));
    await tester.tap(find.byKey(const ValueKey('magic-visualize')));
    await tester.pumpAndSettle();

    final replay = tester.widget<PropagationVisualizer>(
      find.byType(PropagationVisualizer),
    );
    expect(replay.trace.solved, isTrue);
    expect(
      _displayedGrid(tester),
      MagicSquare.gridFromSolution(replay.trace.solution!, 3),
    );

    await tester.ensureVisible(find.text('Generate'));
    await tester.tap(find.text('Generate'));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(
      find.byType(PropagationVisualizer),
      findsNothing,
      reason: 'a new square must not retain a stale replay',
    );
  });

  testWidgets('a failed solve reports the error instead of doing nothing', (
    tester,
  ) async {
    await _openMagicTab(
      tester,
      solve: (program, {maxSolutions = 100}) async =>
          DiophantineResult.failure('Solver failed: forced rejection'),
    );

    await tester.tap(find.text('Generate'));
    await tester.pumpAndSettle();

    expect(find.text('Solver failed: forced rejection'), findsOneWidget);
    expect(find.byKey(const ValueKey('magic-square-grid')), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing,
        reason: 'the spinner must stop when the solve fails');
    expect(_generateButton(tester).onPressed, isNotNull,
        reason: 'Generate must stay usable after a failed solve');
  });

  testWidgets('an empty solution list says so instead of staying blank', (
    tester,
  ) async {
    await _openMagicTab(
      tester,
      solve: (program, {maxSolutions = 100}) async => DiophantineResult.ok(const []),
    );

    await tester.tap(find.text('Generate'));
    await tester.pumpAndSettle();

    expect(find.text('No solutions.'), findsOneWidget);
    expect(find.byKey(const ValueKey('magic-square-grid')), findsNothing);
    expect(_generateButton(tester).onPressed, isNotNull);
  });

  testWidgets('a solve that throws leaves no stuck spinner and shows why', (
    tester,
  ) async {
    await _openMagicTab(
      tester,
      solve: (program, {maxSolutions = 100}) async =>
          throw StateError('boom'),
    );

    await tester.tap(find.text('Generate'));
    await tester.pumpAndSettle();

    expect(find.textContaining('boom'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(_generateButton(tester).onPressed, isNotNull);
  });

  testWidgets('retrying after a failure clears the stale error', (
    tester,
  ) async {
    var calls = 0;
    await _openMagicTab(tester,
        solve: (program, {maxSolutions = 100}) async {
      calls++;
      if (calls == 1) return DiophantineResult.failure('Solver failed: first');
      return _loShuResult();
    });

    await tester.tap(find.text('Generate'));
    await tester.pumpAndSettle();
    expect(find.text('Solver failed: first'), findsOneWidget);

    await tester.tap(find.text('Generate'));
    await tester.pumpAndSettle();

    expect(find.text('Solver failed: first'), findsNothing,
        reason: 'a successful retry must clear the previous error');
    final displayed = _displayedGrid(tester);
    expect(displayed, hasLength(9));
    expect(MagicSquare.isMagic(displayed, 3), isTrue,
        reason: 'the generator must show a magic variant of the solution');
    expect(displayed.toSet(), {1, 2, 3, 4, 5, 6, 7, 8, 9});
  });
}
