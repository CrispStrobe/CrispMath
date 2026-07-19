// Round 105 (P6): per-module help dialog for the Analyze hub.
// Tests cover the dialog render (title + description from the
// per-locale lookup), the FunctionRef deep-link via "Learn more"
// (only present when a refId is mapped), and the omission of
// Learn-more for modules without a FunctionRef summary.

import 'package:crisp_math/localization/app_localizations.dart';
import 'package:crisp_math/widgets/function_reference_dialog.dart';
import 'package:crisp_math/widgets/module_help_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
        localizationsDelegates: const [AppLocalizationsDelegate()],
        supportedLocales: const [Locale('en')],
        home: Scaffold(body: child),
      );

  testWidgets(
      'ModuleHelpDialog for statistics shows title + description + Learn-more',
      (tester) async {
    await tester.pumpWidget(
        host(const ModuleHelpDialog(kind: ModuleHelpKind.statistics)));

    expect(find.text('Statistics'), findsOneWidget);
    // Description starts with "Descriptive statistics" in EN.
    expect(find.textContaining('Descriptive statistics'), findsOneWidget);
    // Statistics maps to welch_t, so Learn-more is rendered.
    expect(find.text('Learn more'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });

  testWidgets('ModuleHelpDialog for curveSketching has no Learn-more button',
      (tester) async {
    await tester.pumpWidget(
        host(const ModuleHelpDialog(kind: ModuleHelpKind.curveSketching)));

    expect(find.text('Curve sketching'), findsOneWidget);
    expect(find.textContaining('Full analysis'), findsOneWidget);
    // Curve sketching has no FunctionRef summary — Learn-more absent.
    expect(find.text('Learn more'), findsNothing);
    expect(find.text('Close'), findsOneWidget);
  });

  testWidgets('ModuleHelpDialog for notepad renders (no Learn-more button)',
      (tester) async {
    await tester
        .pumpWidget(host(const ModuleHelpDialog(kind: ModuleHelpKind.notepad)));

    expect(find.text('Notepad'), findsOneWidget);
    expect(find.textContaining('live formula'), findsOneWidget);
    // No single FunctionRef summarizes the notepad — Learn-more absent.
    expect(find.text('Learn more'), findsNothing);
    expect(find.text('Close'), findsOneWidget);
  });

  testWidgets('Learn more deep-links to FunctionReferenceDialog seeded with id',
      (tester) async {
    await tester.pumpWidget(
        host(const ModuleHelpDialog(kind: ModuleHelpKind.constraints)));

    expect(find.text('Constraints'), findsOneWidget);
    expect(find.text('Learn more'), findsOneWidget);

    await tester.tap(find.text('Learn more'));
    await tester.pumpAndSettle();

    // Constraints → all_different FunctionRef row.
    expect(find.byType(FunctionReferenceDialog), findsOneWidget);
    expect(find.widgetWithText(TextField, 'all_different'), findsOneWidget);
  });

  testWidgets(
      'ModuleHelpButton in an AppBar opens the dialog for the wrapped kind',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [AppLocalizationsDelegate()],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Test screen'),
          actions: const [ModuleHelpButton(kind: ModuleHelpKind.sudoku)],
        ),
        body: const SizedBox(),
      ),
    ));

    expect(find.byTooltip('What does this module do?'), findsOneWidget);
    await tester.tap(find.byTooltip('What does this module do?'));
    await tester.pumpAndSettle();

    expect(find.byType(ModuleHelpDialog), findsOneWidget);
    expect(find.text('Sudoku'), findsOneWidget);
    expect(find.textContaining('4×4 and 9×9'), findsOneWidget);
  });

  // German locale spot-check: only one switch per locale, so verifying
  // a single kind in DE proves the dispatch table reached the
  // DeLocalizations override correctly.
  testWidgets('DE locale dispatches translated title + description',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('de')],
      locale: Locale('de'),
      home: Scaffold(
        body: ModuleHelpDialog(kind: ModuleHelpKind.sudoku),
      ),
    ));

    expect(find.text('Sudoku'), findsOneWidget);
    // DE description starts with "Löst 4×4-".
    expect(find.textContaining('Löst 4×4'), findsOneWidget);
  });
}
