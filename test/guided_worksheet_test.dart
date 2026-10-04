import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/engine/notepad_templates.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:crisp_math/services/document_history.dart';
import 'package:crisp_math/engine/worksheet_bundle.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'fresh connected documents evaluate, preserve work, link and restore',
    () async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await state.load(force: true);
      final original = NotepadTemplates.connectedWorksheet(
        name: 'Existing work',
      );
      original.lines.first.source = 'a=7';
      state.setNotepadDocument(original);
      final first = NotepadTemplates.connectedWorksheet(
        name: 'Explore a function',
      );
      final second = NotepadTemplates.connectedWorksheet(
        name: 'Explore a function',
      );
      expect(first.id, isNot(second.id));
      expect(
        first.lines
            .map((line) => line.id)
            .toSet()
            .intersection(second.lines.map((line) => line.id).toSet()),
        isEmpty,
      );
      expect(first.lines.every((line) => line.cachedResult == null), isTrue);
      final evaluator = NotepadEvaluator(
        dispatcher: (source) async =>
            NumericFallbackEvaluator.evalNumeric(source)?.toString() ?? source,
      );
      await evaluator.evaluateAll(first);
      expect(double.parse(first.lines.last.cachedResult!), 19);
      state.setNotepadDocument(first);
      state.setNotepadDocument(second);
      state.consumeRequestedTab();
      final slot = state.linkNotepadLine(
        first.id,
        first.lines[1].id,
        openGraph: false,
      );
      expect(state.consumeRequestedTab(), isNull);
      expect(
        NumericFallbackEvaluator.evalNumeric(state.graphFunctions[slot], {
          'x': 4,
        }),
        19,
      );
      final history = DocumentHistory();
      final checkpoint = await history.save(first);
      first.lines.first.source = 'a=5';
      await evaluator.evaluateChanged(first, {0});
      state.setNotepadDocument(first);
      expect(double.parse(first.lines.last.cachedResult!), 21);
      expect(
        NumericFallbackEvaluator.evalNumeric(state.graphFunctions[slot], {
          'x': 4,
        }),
        21,
      );
      final editedBundle = WorksheetBundle.capture(
        first,
        expressions: [state.graphFunctions[slot]],
      );
      expect(editedBundle.markdown(), contains('a=5'));
      expect(editedBundle.markdown(), contains('21'));
      final restored = checkpoint.document;
      expect(restored.lines.every((line) => line.cachedResult == null), isTrue);
      await evaluator.evaluateAll(restored);
      state.setNotepadDocument(restored);
      expect(double.parse(restored.lines.last.cachedResult!), 19);
      expect(
        NumericFallbackEvaluator.evalNumeric(state.graphFunctions[slot], {
          'x': 4,
        }),
        19,
      );
      expect(state.notepadDocuments[original.id]!.lines.first.source, 'a=7');
      expect(state.notepadDocuments[second.id], same(second));
      await state.persistNotepadNow();
      await state.load(force: true);
      expect(state.graphLinks[slot]!.documentId, first.id);
      expect(state.notepadDocuments[original.id]!.lines.first.source, 'a=7');
      state.linkNotepadLine(first.id, first.lines[1].id);
      expect(
        state.consumeRequestedTab(),
        2,
        reason: 'Existing navigation default is preserved',
      );
    },
  );

  test(
    'full graph workspace is not overwritten by a guided document',
    () async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await state.load(force: true);
      for (var i = 0; i < state.graphFunctions.length; i++) {
        state.graphFunctions[i] = '$i*x';
      }
      final before = List<String>.of(state.graphFunctions);
      final doc = NotepadTemplates.connectedWorksheet(
        name: 'Explore a function',
      );
      await NotepadEvaluator(
        dispatcher: (source) async =>
            NumericFallbackEvaluator.evalNumeric(source)?.toString() ?? source,
      ).evaluateAll(doc);
      state.setNotepadDocument(doc);
      expect(
        () => state.linkNotepadLine(doc.id, doc.lines[1].id, openGraph: false),
        throwsStateError,
      );
      expect(state.graphFunctions, before);
      expect(state.graphLinks, isEmpty);
      expect(state.notepadDocuments[doc.id], same(doc));
    },
  );
}
