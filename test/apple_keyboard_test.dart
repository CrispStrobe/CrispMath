import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/main.dart';
import 'package:crisp_math/screens/notepad_screen.dart';
import 'package:crisp_math/services/engine_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<NotepadDocument> boot(WidgetTester tester, Size size) async {
    SharedPreferences.setMockInitialValues({'crisp.onboardingDismissed': true});
    await tester.binding.setSurfaceSize(size);
    await AppState().load(force: true);
    final doc = NotepadDocument.fresh(name: 'Keyboard worksheet');
    doc.lines.clear();
    doc.lines
        .addAll(['a=3', 'a+2', 'a*4'].map((s) => NotepadLine.fresh(source: s)));
    AppState().setNotepadDocument(doc);
    AppState().setCurrentNotepadDoc(doc.id);
    await tester.pumpWidget(const CrispMathApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notepad').first);
    await tester.pumpAndSettle();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await EngineService.shutdownForTest();
      await tester.binding.setSurfaceSize(null);
    });
    return doc;
  }

  Future<void> chord(WidgetTester tester, LogicalKeyboardKey key,
      {bool shift = false}) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(key);
    if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
  }

  testWidgets('line navigation and add-row shortcut preserve existing sources',
      (tester) async {
    final doc = await boot(tester, const Size(1032, 1376));
    final fields = find.byType(TextField);
    await tester.tap(fields.first);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(fields.at(1)).focusNode!.hasFocus, isTrue);
    await chord(tester, LogicalKeyboardKey.enter, shift: true);
    expect(doc.lines.map((l) => l.source), ['a=3', 'a+2', 'a*4', '']);
  });

  testWidgets('new-document shortcut keeps the old worksheet', (tester) async {
    final doc = await boot(tester, const Size(744, 900));
    await tester.tap(find.byType(TextField).first);
    await chord(tester, LogicalKeyboardKey.keyN);
    expect(AppState().currentNotepadDocId, isNot(doc.id));
    expect(AppState().notepadDocuments[doc.id]!.lines.length, 3);
  });

  testWidgets('imported worksheet calculates after switching controllers',
      (tester) async {
    final old = await boot(tester, const Size(1032, 1376));
    final imported = NotepadDocument.fresh(name: 'Imported');
    imported.lines.clear();
    imported.lines.add(NotepadLine.fresh(source: '2+3'));
    tester
        .state<NotepadScreenState>(find.byType(NotepadScreen))
        .openImportedWorksheet(imported);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(AppState().currentNotepadDocId, imported.id);
    expect(imported.lines.single.cachedResult, '5');
    expect(imported.lines.single.cachedError, isNull);
    expect(AppState().notepadDocuments, contains(old.id));
  });

  testWidgets('narrow toolbar offers file and capture actions without overflow',
      (tester) async {
    await boot(tester, const Size(390, 844));
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Document menu'));
    await tester.pumpAndSettle();
    expect(find.text('Open worksheet file'), findsOneWidget);
    expect(find.text('Save worksheet file'), findsOneWidget);
    expect(find.text('Scan math'), findsOneWidget);
    expect(find.text('Write math'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
