// test/notepad_flatzinc_test.dart
//
// Round E.4 — inline `fzn:` directive in Notepad. Covers:
//
//   - classifyNotepadLine recognises `fzn:` with single-line and
//     multi-line bodies; the directive wins over comment stripping
//     (FlatZinc uses `%` for comments, not `//`).
//   - flatzincOutputVarsIn extracts scalar output_var names.
//   - parseFlatZincScalarOutputs parses standard FlatZinc output.
//   - NotepadEvaluator dispatches an fzn: line through a stub
//     flatzincDispatcher, populates cachedResult + cachedExports,
//     and the exports flow into the scope of downstream lines.
//   - Missing flatzincDispatcher surfaces a friendly error.
//   - Unsatisfiable output blocks dependents via blockedBy.
//   - End-to-end with the real dart_csp FlatZinc.solve binding.

import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:dart_csp/dart_csp.dart';
import 'package:flutter_test/flutter_test.dart';

NotepadDocument _docOf(List<({String source, String? cached})> spec) {
  return NotepadDocument(
    id: 'fzn-test',
    name: 'FZN',
    createdAt: DateTime.utc(2026, 5, 26),
    updatedAt: DateTime.utc(2026, 5, 26),
    lines: [
      for (final s in spec)
        NotepadLine(
          id: 'l${spec.indexOf(s)}',
          source: s.source,
          cachedResult: s.cached,
        ),
    ],
  );
}

void main() {
  group('classifyNotepadLine — fzn: directive', () {
    test('single-line fzn:', () {
      final p = classifyNotepadLine('fzn: var 0..3: x; solve satisfy;',
          lineIndex: 0, firstCodeLineIndex: 0);
      expect(p.kind, NotepadLineKind.flatzinc);
      expect(p.body, 'var 0..3: x; solve satisfy;');
    });

    test('multi-line fzn: body preserves newlines', () {
      const src = 'fzn:\n'
          'var 0..3: x :: output_var;\n'
          'constraint int_eq(x, 2);\n'
          'solve satisfy;';
      final p = classifyNotepadLine(src, lineIndex: 0, firstCodeLineIndex: 0);
      expect(p.kind, NotepadLineKind.flatzinc);
      expect(p.body, contains('output_var'));
      expect(p.body, contains('int_eq(x, 2)'));
      // Sanity: the body has the four FlatZinc statements but not
      // the `fzn:` prefix.
      expect(p.body!.startsWith('var'), isTrue);
    });

    test('case-sensitive: FZN: is treated as an expression', () {
      final p = classifyNotepadLine('FZN: var 0..3: x;',
          lineIndex: 0, firstCodeLineIndex: 0);
      expect(p.kind, isNot(NotepadLineKind.flatzinc));
    });

    test('leading whitespace allowed before fzn:', () {
      final p = classifyNotepadLine('   fzn: solve satisfy;',
          lineIndex: 0, firstCodeLineIndex: 0);
      expect(p.kind, NotepadLineKind.flatzinc);
    });
  });

  group('flatzincOutputVarsIn', () {
    test('captures scalar output_var names', () {
      final names = flatzincOutputVarsIn(
        'var 0..9: x :: output_var;\n'
        'var 0..9: y :: output_var;\n'
        'var 0..9: hidden;\n',
      );
      expect(names, {'x', 'y'});
    });

    test('skips output_array (arrays do not enter scope)', () {
      final names = flatzincOutputVarsIn(
        'array[1..3] of var 1..3: a :: output_array([1..3]);\n'
        'var 0..9: x :: output_var;\n',
      );
      expect(names, {'x'});
    });

    test('empty source → empty set', () {
      expect(flatzincOutputVarsIn(''), isEmpty);
    });
  });

  group('parseFlatZincScalarOutputs', () {
    test('parses scalar assignments from first solution', () {
      const output = 'x = 3;\n'
          'y = 4;\n'
          '----------\n';
      final got = parseFlatZincScalarOutputs(output);
      expect(got, {'x': '3', 'y': '4'});
    });

    test('takes only the first solution when multiple present', () {
      const output = 'x = 1;\n----------\nx = 2;\n----------\n==========';
      final got = parseFlatZincScalarOutputs(output);
      expect(got, {'x': '1'});
    });

    test('skips array1d lines', () {
      const output = 'q = array1d(1..4, [2, 4, 1, 3]);\n'
          'x = 7;\n'
          '----------\n';
      final got = parseFlatZincScalarOutputs(output);
      // array1d contains `(...)` which the scalar regex rejects.
      expect(got, {'x': '7'});
    });

    test('unsatisfiable output → empty map', () {
      const output = '=====UNSATISFIABLE=====\n';
      expect(parseFlatZincScalarOutputs(output), isEmpty);
    });
  });

  group('NotepadEvaluator with FlatZinc dispatcher', () {
    NotepadEngineDispatcher echo() => (expr) async => expr;

    test('fzn: line populates cachedResult + cachedExports', () async {
      final doc = _docOf([
        (
          source: 'fzn: var 0..9: x :: output_var; solve satisfy;',
          cached: null,
        ),
      ]);
      Future<NotepadFlatZincResult> stub(String source) async {
        return const NotepadFlatZincResult(
          formatted: 'x = 7;\n----------\n',
          scalarBindings: {'x': '7'},
        );
      }

      final ev = NotepadEvaluator(
        dispatcher: echo(),
        flatzincDispatcher: stub,
      );
      await ev.evaluateAll(doc);
      expect(doc.lines[0].cachedResult, contains('x = 7'));
      expect(doc.lines[0].cachedError, isNull);
      expect(doc.lines[0].cachedExports, {'x': '7'});
    });

    test('downstream lines see exported FlatZinc bindings in scope', () async {
      final doc = _docOf([
        (
          source: 'fzn: var 0..9: x :: output_var; solve satisfy;',
          cached: null,
        ),
        (source: 'x * 2', cached: null),
      ]);
      Future<NotepadFlatZincResult> stub(String _) async =>
          const NotepadFlatZincResult(
            formatted: 'x = 7;\n----------\n',
            scalarBindings: {'x': '7'},
          );

      final ev = NotepadEvaluator(
        dispatcher: echo(),
        flatzincDispatcher: stub,
      );
      await ev.evaluateAll(doc);
      // The echo dispatcher returns whatever string it gets; the
      // preprocessor should have substituted `x` with `(7)`.
      expect(doc.lines[1].cachedResult, '(7) * 2');
    });

    test('missing flatzincDispatcher surfaces a friendly error', () async {
      final doc = _docOf([
        (source: 'fzn: solve satisfy;', cached: null),
      ]);
      final ev = NotepadEvaluator(dispatcher: echo());
      await ev.evaluateAll(doc);
      expect(doc.lines[0].cachedError, isNotNull);
      expect(doc.lines[0].cachedError, contains('FlatZinc dispatcher'));
    });

    test('empty fzn: body is rejected with a clear error', () async {
      final doc = _docOf([
        (source: 'fzn:', cached: null),
      ]);
      final ev = NotepadEvaluator(
        dispatcher: echo(),
        flatzincDispatcher: (_) async => const NotepadFlatZincResult(
          formatted: '',
          scalarBindings: {},
        ),
      );
      await ev.evaluateAll(doc);
      expect(doc.lines[0].cachedError, contains('empty FlatZinc body'));
    });

    test('unsatisfiable model blocks downstream dependents', () async {
      final doc = _docOf([
        (
          source: 'fzn: var 0..9: x :: output_var; solve satisfy;',
          cached: null,
        ),
        (source: 'x + 1', cached: null),
      ]);
      Future<NotepadFlatZincResult> stub(String _) async =>
          const NotepadFlatZincResult(
            formatted: '=====UNSATISFIABLE=====\n',
            scalarBindings: {},
          );

      final ev = NotepadEvaluator(
        dispatcher: echo(),
        flatzincDispatcher: stub,
      );
      await ev.evaluateAll(doc);
      expect(doc.lines[0].cachedError, contains('unsatisfiable'));
      // Downstream line that references `x` should be blocked.
      expect(
          doc.lines[1].cachedError, startsWith(NotepadErrorPrefix.blockedBy));
    });

    test('fzn: body identifiers do not appear as free variables', () async {
      // Use uppercase identifiers so they aren't filtered by
      // kReservedNotepadNames — this ensures the early-return in
      // freeVariablesOfLine is what's keeping them out of the tag.
      final doc = _docOf([
        (
          source: 'fzn: var 0..9: Foo :: output_var; '
              'var 0..9: Bar :: output_var; '
              'solve satisfy;',
          cached: null,
        ),
      ]);
      Future<NotepadFlatZincResult> stub(String _) async =>
          const NotepadFlatZincResult(
            formatted: 'Foo = 0;\nBar = 0;\n----------\n',
            scalarBindings: {'Foo': '0', 'Bar': '0'},
          );

      final ev = NotepadEvaluator(
        dispatcher: echo(),
        flatzincDispatcher: stub,
      );
      await ev.evaluateAll(doc);
      expect(doc.lines[0].cachedFreeVars, isEmpty);
    });
  });

  group('end-to-end with the real FlatZinc backend', () {
    NotepadEngineDispatcher echo() => (expr) async => expr;

    Future<NotepadFlatZincResult> realDispatcher(String source) async {
      final formatted = await FlatZinc.solve(source);
      return NotepadFlatZincResult(
        formatted: formatted,
        scalarBindings: parseFlatZincScalarOutputs(formatted),
      );
    }

    test('fzn: line solves a tiny model and exports the value', () async {
      final doc = _docOf([
        (
          source: 'fzn:\n'
              'var 0..9: x :: output_var;\n'
              'constraint int_eq(x, 5);\n'
              'solve satisfy;',
          cached: null,
        ),
        (source: 'x + 100', cached: null),
      ]);
      final ev = NotepadEvaluator(
        dispatcher: echo(),
        flatzincDispatcher: realDispatcher,
      );
      await ev.evaluateAll(doc);
      expect(doc.lines[0].cachedExports['x'], '5');
      expect(doc.lines[0].cachedResult, contains('x = 5'));
      // Echo returns the preprocessed expression — the `x` should
      // have been substituted with `(5)` before dispatch.
      expect(doc.lines[1].cachedResult, '(5) + 100');
    });
  });
}
