import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:crisp_math/main.dart';
import 'package:crisp_math/services/engine_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('calculator history row exposes one labelled action', (tester) async {
    SharedPreferences.setMockInitialValues({'crisp.onboardingDismissed': true});
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.binding.setSurfaceSize(null);
      await EngineService.shutdownForTest();
    });
    await AppState().load(force: true);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const CrispMathApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    const expr = 'linsolve([2*x-y+z=7,x+3*y-2*z=-3,3*x+y+z=11],[x,y,z])';
    const result = 'x = 2, y = 1, z = 4';
    AppState().addHistoryEntry(expr, result);
    await tester.pumpAndSettle();

    // One node carries the whole row, so a screen reader (and the web
    // accessibility tree) reports expression and result together.
    final node = find.bySemanticsLabel('$expr\n= $result');
    expect(node, findsOneWidget);
    final data = tester.getSemantics(node);
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue,
        reason: 'the row opens details, so it must be an accessible action');
    expect(find.bySemanticsLabel(expr), findsNothing,
        reason: 'the expression must not also be a separate label');

    // The result detail is not a per-row widget; it lives in the row menu.
    expect(find.byTooltip('Result details'), findsNothing);
    expect(find.text('Result details'), findsNothing);
    semantics.dispose();
  });
}
