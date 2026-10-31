// Memory slots are 64x36. A stored value must fit without overflowing,
// however long it is, and the full value stays available on hover.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/localization/app_localizations.dart';
import 'package:crisp_math/widgets/variable_viewer.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppState().load(force: true);
  });

  testWidgets('a long memory value fits its slot', (tester) async {
    const long = '123456789012345678901234567890*sin(x)^2+cos(x)^2';
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [AppLocalizationsDelegate()],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: SizedBox(
          width: 360,
          height: 700,
          child: VariableViewer(
            appState: AppState(),
            onVariableTap: (_) {},
            memory: const {'M0': long, 'M1': '42'},
            onMemoryAction: (_) {},
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byTooltip('M1 = $long'), findsOneWidget);
  });
}
