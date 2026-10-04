import 'package:crisp_math/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: StatisticsScreen()));
    await tester.tap(find.text('Distributions'));
    await tester.pumpAndSettle();
  }
  Finder field(String label) => find.byWidgetPredicate((widget) =>
      widget is TextField && widget.decoration?.labelText == label);
  Future<void> fill(WidgetTester tester, String label, String value) async {
    await tester.ensureVisible(field(label));
    await tester.enterText(field(label), value);
    await tester.pumpAndSettle();
  }
  testWidgets('Student interval inputs render shared Cauchy probability', (tester) async {
    await open(tester);
    await fill(tester, 'Degrees of freedom ν', '1');
    await fill(tester, 'Interval lower bound', '0');
    await fill(tester, 'Interval upper bound', '1.7320508075688772');
    expect(find.text('P(lower ≤ T ≤ upper)'), findsOneWidget);
    expect(find.text('0.333333'), findsOneWidget);
    await fill(tester, 'Interval lower bound', '1.7320508075688772');
    expect(find.text('0'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Student interval rejects invalid df and reversed/nonfinite bounds', (tester) async {
    await open(tester);
    for (final value in ['0', '-1', '1.5']) {
      await fill(tester, 'Degrees of freedom ν', value);
      expect(find.text('P(lower ≤ T ≤ upper)'), findsNothing);
      expect(tester.takeException(), isNull);
    }
    await fill(tester, 'Degrees of freedom ν', '1');
    await fill(tester, 'Interval lower bound', '2');
    await fill(tester, 'Interval upper bound', '1');
    expect(find.text('P(lower ≤ T ≤ upper)'), findsNothing);
    await fill(tester, 'Interval lower bound', 'NaN');
    expect(find.text('P(lower ≤ T ≤ upper)'), findsNothing);
    await fill(tester, 'Interval lower bound', '0');
    await fill(tester, 'Interval upper bound', 'Infinity');
    expect(find.text('P(lower ≤ T ≤ upper)'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('full precision preserves trillion-centered mean and median', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: StatisticsScreen()));
    final input = find.byWidgetPredicate((widget) => widget is TextField &&
        widget.decoration?.labelText == 'Data (comma, space, or newline-separated)');
    await tester.enterText(input, '1000000000000, 1000000000001, 1000000000002');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Full precision'));
    await tester.tap(find.text('Full precision'));
    await tester.pumpAndSettle();
    expect(find.text('Summary at full precision'), findsOneWidget);
    expect(find.text('Mean: 1000000000001.0\nMedian: 1000000000001.0\nSample standard deviation: 1.0'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Summary at full precision'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
