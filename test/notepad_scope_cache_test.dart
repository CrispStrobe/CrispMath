import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<NotepadDocument> evaluate(List<String> sources,
      {Map<String, String> external = const {},
      String? Function(NotepadDocument, String, int)? intercept}) async {
    final doc = NotepadDocument.fresh(name: 'Indexed');
    doc.lines
      ..clear()
      ..addAll(sources.map((source) => NotepadLine.fresh(source: source)));
    var calls = 0;
    await NotepadEvaluator(
        externalScope: external,
        dispatcher: (source) async {
          final overridden = intercept?.call(doc, source, calls++);
          return overridden ??
              NumericFallbackEvaluator.evalNumeric(source)!.toInt().toString();
        }).evaluateAll(doc);
    return doc;
  }

  test('numeric scope observes source edits during dispatch', () async {
    final doc = await evaluate(['a = 1', 'b = 2', 'c = a + b'],
        intercept: (doc, source, call) {
      if (call == 0) doc.lines[1].source = 'b = 5';
      return null;
    });
    expect(doc.lines.last.cachedResult, '6');
  });

  test('numeric scope observes cache and import changes during dispatch',
      () async {
    final external = {'p': '2'};
    final doc = await evaluate(['a = 1', 'b = 2', 'c = a + p'],
        external: external, intercept: (doc, source, call) {
      if (call == 1) {
        doc.lines.first.cachedResult = '7';
        external['p'] = '4';
      }
      return null;
    });
    expect(doc.lines.last.cachedResult, '11');
  });

  test('symbolic results and duplicate names preserve full-scope behavior',
      () async {
    final symbolic = await evaluate(['a = 1', 'b = 2', 'c = a'],
        intercept: (doc, source, call) => call == 0 ? 'b+1' : null);
    expect(symbolic.lines.last.cachedResult, '3');
    final duplicates = await evaluate(['a = 1', 'a = 2', 'c = a + 1']);
    expect(duplicates.lines.last.cachedResult, '3');
  });

  test('filtered scopes preserve effective bindings, aliases and live edits',
      () {
    final doc = NotepadDocument.fresh(name: 'Filtered');
    doc.lines
      ..clear()
      ..addAll([
        NotepadLine.fresh(source: 'a = 2')..cachedResult = '2',
        NotepadLine.fresh(source: 'a = 3')..cachedResult = '3',
        NotepadLine.fresh(source: 'fzn: exports')
          ..cachedResult = 'output'
          ..cachedExports = {'b': '4', 'a': '5'},
        NotepadLine.fresh(source: 'a = 6')..cachedResult = '6',
      ]);
    final cache = NotepadLineParseCache();
    const external = {'a': '1', 'imported': '7', 'unused': '8'};
    void check() {
      final full = buildNotepadScope(doc, externalScope: external);
      for (final names in [
        <String>{},
        {'a'},
        {'b', 'imported', 'unknown'},
        {'line1', 'line3', 'a'},
      ]) {
        expect(
            buildNotepadScope(doc,
                externalScope: external, parseCache: cache, names: names),
            Map.fromEntries(full.entries.where((e) => names.contains(e.key))));
      }
    }

    check();
    doc.lines.last.cachedResult = null;
    check();
    doc.lines[1].source = 'c = 3';
    check();
    doc.lines.removeAt(0);
    check();
  });
  test('classification cache observes edits, positions and directive changes',
      () {
    final cache = NotepadLineParseCache();
    final first = cache.parse('use a', lineIndex: 0, firstCodeLineIndex: 0);
    expect(
        identical(
            first, cache.parse('use a', lineIndex: 0, firstCodeLineIndex: 0)),
        isTrue);
    expect(cache.parse('a = 2', lineIndex: 0, firstCodeLineIndex: 0).kind,
        NotepadLineKind.assignment);
    expect(cache.parse('use a', lineIndex: 0, firstCodeLineIndex: 1).kind,
        isNot(NotepadLineKind.useDirective));
    final doc = NotepadDocument.fresh(name: 'Cache');
    doc.lines
      ..clear()
      ..addAll([
        NotepadLine.fresh(source: 'a = 2')..cachedResult = '2',
        NotepadLine.fresh(source: 'a = 3')..cachedResult = '3',
        NotepadLine.fresh(source: 'a + 1')..cachedResult = '4',
      ]);
    expect(buildNotepadScope(doc, parseCache: cache), buildNotepadScope(doc));
    doc.lines[1].source = 'b = 3';
    expect(buildNotepadScope(doc, parseCache: cache), buildNotepadScope(doc));
    doc.lines.removeAt(0);
    expect(buildNotepadScope(doc, parseCache: cache), buildNotepadScope(doc));
  });
  test(
      'numeric fast substitution matches ordered replacement and preserves symbolic behavior',
      () {
    final doc = NotepadDocument.fresh(name: 'Substitution');
    String oldSubstitute(String source, Map<String, String> scope) {
      final names = scope.keys.toList()
        ..sort((a, b) => b.length.compareTo(a.length));
      for (final name in names) {
        source = source.replaceAll(
            RegExp(r'(?<![A-Za-z0-9_])' +
                RegExp.escape(name) +
                r'(?![A-Za-z0-9_])'),
            '(${scope[name]})');
      }
      return source;
    }

    final scopes = [
      {for (var i = 0; i < 100; i++) 'v$i': '${i - 50}'},
      {'a': '1.25', 'aa': '-2', 'b': 'a+1', 'e': '3'},
      {'a': '90071992547409931234567890', 'b': '-0.25'},
    ];
    for (final scope in scopes) {
      for (final source in [
        'v1+v10+v99',
        'v1*v1+v1',
        'a+aa+b',
        'a*b',
        'other_a+ab+a',
        '1e3 + e',
        'sin(a)+sqrt(b)'
      ]) {
        final parsed =
            classifyNotepadLine(source, lineIndex: 0, firstCodeLineIndex: 0);
        expect(
            preprocessNotepadLine(parsed, doc: doc, lineIndex: 0, scope: scope),
            oldSubstitute(source, scope),
            reason: '$source: $scope');
      }
    }
  });
}
