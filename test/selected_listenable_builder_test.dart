import 'package:crisp_math/widgets/selected_listenable_builder.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ignores unrelated progress and follows replaced notifier',
      (tester) async {
    final first = ValueNotifier(0), second = ValueNotifier(0);
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    var result = '1', builds = 0;
    Widget view(ValueNotifier<int> notifier) => Directionality(
          textDirection: TextDirection.ltr,
          child: SelectedListenableBuilder(
            listenable: notifier,
            select: () => result,
            builder: (_) {
              builds++;
              return Text(result);
            },
          ),
        );
    await tester.pumpWidget(view(first));
    first.value++;
    await tester.pump();
    expect(builds, 1);
    result = '2';
    first.value++;
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    expect(builds, 2);
    await tester.pumpWidget(view(second));
    final afterReplacement = builds;
    result = '3';
    first.value++;
    await tester.pump();
    expect(builds, afterReplacement);
    second.value++;
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    second.value++;
    expect(tester.takeException(), isNull);
  });
}
