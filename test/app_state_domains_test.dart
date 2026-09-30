import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('history and viewport updates do not notify appearance or documents',
      () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.load(force: true);
    var appearances = 0, documents = 0, graphs = 0, calculator = 0;
    void appearance() => appearances++;
    void document() => documents++;
    void graph() => graphs++;
    void calculation() => calculator++;
    state.appearanceChanges.addListener(appearance);
    state.documentChanges.addListener(document);
    state.graphChanges.addListener(graph);
    state.calculatorChanges.addListener(calculation);
    addTearDown(() {
      state.appearanceChanges.removeListener(appearance);
      state.documentChanges.removeListener(document);
      state.graphChanges.removeListener(graph);
      state.calculatorChanges.removeListener(calculation);
    });
    state.addHistoryEntry('2+3', '5');
    expect([appearances, documents, graphs, calculator], [0, 0, 0, 1]);
    state.setParameter(0, 'a', 2);
    expect([appearances, documents, graphs, calculator], [0, 0, 1, 2]);
    state.setNotepadDocument(NotepadDocument.fresh(name: 'Notes'));
    expect([appearances, documents, graphs, calculator], [0, 1, 1, 2]);
    state.setThemeMode(ThemeMode.light);
    expect(appearances, 1);
    await state.flushPersistence();
  });
}
