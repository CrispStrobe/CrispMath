import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/localization/app_localizations.dart';
import 'package:crisp_math/screens/graphing_screen.dart';
import 'package:crisp_math/widgets/graph_value_table_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('trace controls are discoverable and table errors stay visible',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppState().load(force: true);
    await tester.pumpWidget(const MaterialApp(
        localizationsDelegates: [AppLocalizationsDelegate()],
        home: GraphingScreen()));
    await tester.tap(find.byTooltip('Trace curve'));
    await tester.pumpAndSettle();
    expect(find.text('Trace Y1'), findsOneWidget);
    expect(find.byKey(const ValueKey('graph-trace-readout')), findsOneWidget);
    await tester.tap(find.byTooltip('Value table'));
    await tester.pumpAndSettle();
    expect(find.byType(GraphValueTableDialog), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Step'), '0');
    await tester.tap(find.text('Generate table'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Step > 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
