import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/screens/calculator_screen.dart';
import 'package:crisp_math/widgets/calculator_input_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppState().load(force: true);
  });

  Future<void> submit(WidgetTester tester, String expression) async {
    final bar =
        tester.widget<CalculatorInputBar>(find.byType(CalculatorInputBar));
    bar.controller.setEditingValue(TextEditingValue(
      text: expression,
      selection: TextSelection.collapsed(offset: expression.length),
    ));
    bar.onEvaluate();
    await tester.pumpAndSettle();
  }

  testWidgets('missing Ans reaches history for arithmetic and assignment',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CalculatorScreen()));
    await tester.pumpAndSettle();
    for (final expression in [
      'Ans/2',
      'Ans*2',
      'a=Ans/2',
      'sqrt(Ans)',
      'gcd(Ans,6)',
      'solve(Ans+x)'
    ]) {
      await submit(tester, expression);
      expect(AppState().history.first.result, 'Error: No Ans in memory',
          reason: expression);
      expect(find.text('No Ans in memory.'), findsWidgets);
    }
  });

  testWidgets('Ans inside a user function reports missing memory',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CalculatorScreen()));
    await tester.pumpAndSettle();
    AppState()
        .setUserFunction(UserFunction(name: 'f', params: ['x'], body: 'Ans+x'));
    await submit(tester, 'f(1)');
    expect(AppState().history.first.result, 'Error: No Ans in memory');
  });

  testWidgets('arithmetic uses the last successful Ans after an error',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CalculatorScreen()));
    await tester.pumpAndSettle();
    AppState().addHistoryEntry('4', '4');
    AppState().addHistoryEntry('1/0', 'Error: division by zero');
    await submit(tester, 'Ans/2');
    expect(AppState().history.first.result, '2');
    AppState().addHistoryEntry('1/0', 'Error: division by zero');
    await submit(tester, 'Ans*2');
    expect(AppState().history.first.result, '4');
  });
}
