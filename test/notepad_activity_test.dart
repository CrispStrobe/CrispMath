import 'package:crisp_math/widgets/notepad_activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mobile Cancel is below the app bar and invokes cancellation',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var cancelled = false, help = false;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      appBar: AppBar(actions: [
        IconButton(
            tooltip: 'Help mode',
            onPressed: () => help = true,
            icon: const Icon(Icons.help))
      ]),
      body: NotepadActivity(
          busy: true,
          failed: false,
          completed: 12,
          total: 2000,
          onCancel: () => cancelled = true,
          onRetry: () {}),
    )));
    expect(find.text('Updating results: 12 / 2000'), findsOneWidget);
    final action = find.widgetWithText(TextButton, 'Cancel calculation');
    expect(tester.getRect(action).top,
        greaterThanOrEqualTo(tester.getRect(find.byType(AppBar)).bottom));
    await tester.tap(action);
    expect(cancelled, isTrue);
    expect(help, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('live progress announcements do not contain action buttons',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: NotepadActivity(
                busy: true,
                failed: false,
                completed: 1,
                total: 10,
                onCancel: () {},
                onRetry: () {}))));
    final announcements = find.byWidgetPredicate((widget) =>
        widget is Semantics && widget.properties.liveRegion == true);
    expect(announcements, findsOneWidget);
    expect(
        find.descendant(of: announcements, matching: find.byType(TextButton)),
        findsNothing);
  });

  testWidgets('a stopped batch keeps its message and Retry action',
      (tester) async {
    var retried = false;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: NotepadActivity(
                busy: false,
                failed: false,
                cancelled: true,
                onRetry: () => retried = true))));
    expect(find.text('Calculation stopped. Completed results are kept.'),
        findsOneWidget);
    expect(find.text('Cancel calculation'), findsNothing);
    await tester.tap(find.widgetWithText(TextButton, 'Retry'));
    expect(retried, isTrue);
  });
}
