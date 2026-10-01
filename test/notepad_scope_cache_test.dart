import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
