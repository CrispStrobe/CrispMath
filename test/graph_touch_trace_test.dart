import 'dart:ui' show PointerDeviceKind;
import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/main.dart';
import 'package:crisp_math/screens/graphing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('touch tap and drag trace the sampled curve', (tester) async {
    SharedPreferences.setMockInitialValues({'crisp.onboardingDismissed': true});
    final state = AppState();
    await state.load(force: true);
    state.clearAllFunctions();
    state.updateFunction(0, 'sin(x)');
    await tester.pumpWidget(const CrispMathApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Graphing').last);
    await tester.pumpAndSettle();
    final paint = find.byWidgetPredicate(
        (widget) => widget is CustomPaint && widget.painter is GraphPainter);
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
      if ((tester.widget<CustomPaint>(paint).painter! as GraphPainter)
          .samples
          .curves
          .isNotEmpty) break;
    }
    expect(
        (tester.widget<CustomPaint>(paint).painter! as GraphPainter)
            .samples
            .curves,
        isNotEmpty);
    await tester.tap(find.byTooltip('Trace curve'));
    await tester.pump();
    double traceX() => double.parse(RegExp(r'x = ([^,]+)')
        .firstMatch((tester.widget<Text>(find.textContaining('x = '))).data!)!
        .group(1)!);
    final before = traceX(), rect = tester.getRect(paint);
    final gesture = await tester.startGesture(
        Offset(rect.left + rect.width * .75, rect.center.dy),
        kind: PointerDeviceKind.touch);
    await tester.pump();
    final tapped = traceX();
    expect(tapped, greaterThan(before));
    await gesture.moveBy(const Offset(-60, 0));
    await tester.pump();
    expect(traceX(), lessThan(tapped));
    await gesture.up();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
  testWidgets(
      'a hidden graph cannot steal focus when its traced source disappears',
      (tester) async {
    SharedPreferences.setMockInitialValues({'crisp.onboardingDismissed': true});
    final state = AppState();
    await state.load(force: true);
    state.clearAllFunctions();
    state.updateFunction(0, 'sin(x)');
    state.updateFunction(1, 'x^2');
    await tester.pumpWidget(const CrispMathApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Graphing').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Trace curve'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trace Y1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trace Y2').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notepad').last);
    await tester.pumpAndSettle();
    final editingFocus = FocusManager.instance.primaryFocus;
    state.clearFunction(1);
    await tester.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus, same(editingFocus));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
