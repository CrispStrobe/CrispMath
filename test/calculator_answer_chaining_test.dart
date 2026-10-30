import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/main.dart';
import 'package:crisp_math/services/engine_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('text editor chains operators without losing Ans', (tester) async {
    SharedPreferences.setMockInitialValues({'crisp.onboardingDismissed': true});
    await tester.binding.setSurfaceSize(const Size(1280, 900));
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
    await tester.tap(find.byTooltip('Edit expression'));
    await tester.pumpAndSettle();
    final field = find.byType(TextField);

    Future<void> submit() async {
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }

    await tester.enterText(field, '24');
    await submit();
    expect(AppState().history.first.result, '24');

    for (final step in [
      ('/', 'Ans/2', '12'),
      ('*', 'Ans*2', '24'),
      ('+', 'Ans+2', '26'),
    ]) {
      await tester.enterText(field, step.$1);
      final editor = tester.widget<TextField>(field).controller!;
      expect(editor.text, 'Ans${step.$1}');
      tester.testTextInput.updateEditingValue(TextEditingValue(
        text: step.$2,
        selection: TextSelection.collapsed(offset: step.$2.length),
      ));
      await tester.pump();
      await submit();
      expect(AppState().history.first.expression, step.$2);
      expect(AppState().history.first.result, step.$3);
    }

    await tester.enterText(field, '7');
    await submit();
    expect(AppState().history.first.expression, '7');
    expect(AppState().history.first.result, '7');

    // Text input may deliver an operator and its operand in one update.
    await tester.enterText(field, '/2');
    expect(tester.widget<TextField>(field).controller!.text, 'Ans/2');
    await submit();
    expect(AppState().history.first.result, '7/2');
  });
}
