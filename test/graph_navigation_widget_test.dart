import 'package:crisp_math/main.dart';
import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/screens/graphing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('accepted bounds update the viewport before dialog disposal',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({'crisp.onboardingDismissed': true});
    await AppState().load(force: true);
    await tester.pumpWidget(const CrispMathApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Graphing').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Graph bounds'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    for (final (index, value) in ['-5', '5', '-100', '100'].indexed) {
      await tester.enterText(fields.at(index), value);
    }
    await tester.tap(find.text('Apply bounds'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    // Sampling and a following Fit command must already see these bounds,
    // rather than waiting for the 300ms controller-disposal timer.
    final graph = find.byWidgetPredicate(
        (widget) => widget is CustomPaint && widget.painter is GraphPainter);
    expect(graph, findsOneWidget);
    final painter = tester.widget<CustomPaint>(graph).painter! as GraphPainter;
    final size = tester.getSize(graph);
    final ux = 25 * painter.scale;
    final uy = ux * painter.yRatio;
    expect(-(size.width / 2 + painter.offset.dx) / ux, closeTo(-5, 1e-9));
    expect((size.height / 2 + painter.offset.dy) / uy, closeTo(100, 1e-9));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
  testWidgets('mobile bounds report invalid input and view changes undo',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({'crisp.onboardingDismissed': true});
    await AppState().load(force: true);
    await tester.pumpWidget(const CrispMathApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Graphing').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Graph bounds'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '10');
    await tester.enterText(fields.at(1), '-10');
    await tester.tap(find.text('Apply bounds'));
    await tester.pump();
    expect(
        find.text('Enter finite, increasing x and y bounds.'), findsOneWidget);
    await tester.enterText(fields.at(0), '-2');
    await tester.enterText(fields.at(1), '8');
    await tester.enterText(fields.at(2), '-100');
    await tester.enterText(fields.at(3), '100');
    await tester.tap(find.text('Apply bounds'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Undo graph change'));
    await tester.tap(find.byTooltip('Undo graph change'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Graph bounds'));
    await tester.tap(find.byTooltip('Graph bounds'));
    await tester.pumpAndSettle();
    expect(
        (tester.widget<TextField>(find.byType(TextField).at(0)))
            .controller!
            .text,
        isNot('-2.0000000'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
