// test/calculator_input_bar_test.dart
//
// Round 108: the calculator input bar is responsive — the action
// toolbar (reset focus, backspace, ◀/▶, =/EXE) sits left of the field
// on wide layouts and drops beneath a full-width field on phone widths.
// These tests pin both layouts (no overflow either way) and that the
// action callbacks fire.

import 'package:crisp_math/controllers/latex_controller.dart';
import 'package:crisp_math/widgets/calculator_input_bar.dart';
import 'package:crisp_math/widgets/latex_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Size size,
    {required LatexController controller,
    VoidCallback? onEvaluate,
    VoidCallback? onResetFocus,
    String preview = ''}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Column(
        children: [
          CalculatorInputBar(
            controller: controller,
            onResetFocus: onResetFocus ?? () {},
            onEvaluate: onEvaluate ?? () {},
            resultPreview: preview,
          ),
        ],
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('phone width: field stacks above the toolbar, no overflow',
      (tester) async {
    final controller = LatexController();
    addTearDown(controller.dispose);
    await _pump(tester, const Size(375, 812), controller: controller);

    // All five actions plus the field render.
    expect(find.byType(CalculatorInputBar), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_return), findsOneWidget);
    expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);

    // Stacked: the field's row is ABOVE the toolbar's = button.
    final fieldY = tester.getTopLeft(find.byType(LatexInputField)).dy;
    final evalY = tester.getTopLeft(find.byIcon(Icons.keyboard_return)).dy;
    expect(fieldY, lessThan(evalY),
        reason: 'field should sit above the toolbar on phone widths');
    // No RenderFlex overflow was thrown (pumpAndSettle would have failed).
  });

  testWidgets('wide width: toolbar sits left of the field on one row',
      (tester) async {
    final controller = LatexController();
    addTearDown(controller.dispose);
    await _pump(tester, const Size(1000, 800), controller: controller);

    // Single row: the = button is to the LEFT of the field, same row.
    final evalX = tester.getTopLeft(find.byIcon(Icons.keyboard_return)).dx;
    final fieldX = tester.getTopLeft(find.byType(LatexInputField)).dx;
    expect(evalX, lessThan(fieldX),
        reason: 'toolbar should sit left of the field on wide layouts');
  });

  testWidgets('evaluate + reset callbacks fire', (tester) async {
    var evaluated = 0;
    var reset = 0;
    final controller = LatexController();
    addTearDown(controller.dispose);
    await _pump(tester, const Size(375, 812),
        controller: controller,
        onEvaluate: () => evaluated++,
        onResetFocus: () => reset++);

    await tester.tap(find.byIcon(Icons.keyboard_return));
    await tester.tap(find.byIcon(Icons.refresh));
    expect(evaluated, 1);
    expect(reset, 1);
  });
}
