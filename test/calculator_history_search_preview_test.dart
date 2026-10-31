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

  Future<void> openSearchAndEditor(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    AppState().addHistoryEntry('alpha', '11');
    AppState().addHistoryEntry('beta', '22');
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: CalculatorScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Calculator menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Search history'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit expression'));
    await tester.pumpAndSettle();
  }

  Finder searchField() => find.byWidgetPredicate((widget) =>
      widget is TextField && widget.decoration?.hintText == 'Filter history…');

  Finder expressionField() => find.descendant(
      of: find.byType(CalculatorInputBar), matching: find.byType(TextField));

  /// A history row, not the search field's own text: after typing a filter the
  /// same string appears in both, so a bare [find.text] would double-count.
  Finder historyRow(String text) =>
      find.descendant(of: find.byType(ListView), matching: find.text(text));

  String preview(WidgetTester tester) => tester
      .widget<CalculatorInputBar>(find.byType(CalculatorInputBar))
      .resultPreview;

  testWidgets('history search does not cancel a pending live preview',
      (tester) async {
    await openSearchAndEditor(tester);
    expect(searchField(), findsOneWidget);
    expect(expressionField(), findsOneWidget);
    await tester.enterText(expressionField(), '1+2');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(preview(tester), '3');
    expect(historyRow('alpha'), findsOneWidget);
    expect(historyRow('beta'), findsOneWidget);

    await tester.enterText(expressionField(), '2+3');
    await tester.enterText(searchField(), 'alpha');
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump();
    expect(preview(tester), '5');
    expect(historyRow('beta'), findsOneWidget,
        reason: 'history filtering still waits for its own 200ms debounce');
    await tester.pump(const Duration(milliseconds: 50));
    expect(historyRow('alpha'), findsOneWidget);
    expect(historyRow('beta'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('disposing cancels both pending debounces', (tester) async {
    await openSearchAndEditor(tester);
    await tester.enterText(searchField(), 'alpha');
    await tester.enterText(expressionField(), '2+3');
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
