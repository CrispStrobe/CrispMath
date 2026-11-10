// test/notepad_export_test.dart
//
// Tests for notepad export (Markdown, LaTeX, structured).

import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_export.dart';
import 'package:crisp_math/engine/worksheet_bundle.dart';

void main() {
  NotepadDocument makeDoc({
    String name = 'Test',
    List<(String source, String? result)> lines = const [],
  }) {
    return NotepadDocument(
      id: 'test',
      name: name,
      createdAt: DateTime.utc(2026, 6, 1),
      updatedAt: DateTime.utc(2026, 6, 1),
      lines: [
        for (final l in lines)
          NotepadLine(id: 'l${lines.indexOf(l)}', source: l.$1)
            ..cachedResult = l.$2,
      ],
    );
  }

  group('exportDocument', () {
    test('classifies heading lines', () {
      final doc = makeDoc(lines: [('## Section', null)]);
      final exported = exportDocument(doc);
      expect(exported.lines[0].kind, 'heading');
    });

    test('classifies divider lines', () {
      final doc = makeDoc(lines: [('---', null)]);
      final exported = exportDocument(doc);
      expect(exported.lines[0].kind, 'divider');
    });

    test('classifies expression lines with results', () {
      final doc = makeDoc(lines: [('2 + 3', '5')]);
      final exported = exportDocument(doc);
      expect(exported.lines[0].kind, 'expression');
      expect(exported.lines[0].result, '5');
      expect(exported.lines[0].formattedResult, '5');
    });

    test('classifies comment lines', () {
      final doc = makeDoc(lines: [('// note', null)]);
      final exported = exportDocument(doc);
      expect(exported.lines[0].kind, 'comment');
    });

    test('classifies blank lines', () {
      final doc = makeDoc(lines: [('', null)]);
      final exported = exportDocument(doc);
      expect(exported.lines[0].kind, 'blank');
    });

    test('applies per-line format override', () {
      final doc = makeDoc(lines: [('x', '255')]);
      doc.lines[0].resultFormat = LineResultFormat.hex;
      final exported = exportDocument(doc);
      expect(exported.lines[0].formattedResult, '0xff');
    });

    test('document metadata', () {
      final doc = makeDoc(name: 'My Doc');
      final exported = exportDocument(doc);
      expect(exported.name, 'My Doc');
      expect(exported.createdAt, DateTime.utc(2026, 6, 1));
    });
  });

  group('exportToMarkdown', () {
    test('starts with document name as heading', () {
      final doc = makeDoc(name: 'Budget');
      final md = exportToMarkdown(doc);
      expect(md.startsWith('# Budget'), true);
    });

    test('headings pass through', () {
      final doc = makeDoc(lines: [('## Income', null)]);
      final md = exportToMarkdown(doc);
      expect(md, contains('## Income'));
    });

    test('dividers render as ---', () {
      final doc = makeDoc(lines: [('---', null)]);
      final md = exportToMarkdown(doc);
      expect(md, contains('---'));
    });

    test('expressions with results', () {
      final doc = makeDoc(lines: [('2 + 3', '5')]);
      final md = exportToMarkdown(doc);
      expect(md, contains('`2 + 3` → `5`'));
    });

    test('comments as blockquotes', () {
      final doc = makeDoc(lines: [('// This is a note', null)]);
      final md = exportToMarkdown(doc);
      expect(md, contains('> This is a note'));
    });

    test('full document round-trip', () {
      final doc = makeDoc(name: 'Test', lines: [
        ('## Section 1', null),
        ('x = 42', '42'),
        ('x + 8', '50'),
        ('---', null),
        ('// done', null),
        ('total', '92'),
      ]);
      final md = exportToMarkdown(doc);
      expect(md, contains('# Test'));
      expect(md, contains('## Section 1'));
      expect(md, contains('`x = 42` → `42`'));
      expect(md, contains('---'));
      expect(md, contains('> done'));
      expect(md, contains('**total**: 92'));
    });
  });

  group('exportToLatex', () {
    test('has document structure', () {
      final doc = makeDoc(name: 'Report');
      final tex = exportToLatex(doc);
      expect(tex, contains(r'\documentclass'));
      expect(tex, contains(r'\begin{document}'));
      expect(tex, contains(r'\end{document}'));
      expect(tex, contains('Report'));
    });

    test('headings become subsections', () {
      final doc = makeDoc(lines: [('## Results', null)]);
      final tex = exportToLatex(doc);
      expect(tex, contains(r'\subsection*{Results}'));
    });

    test('dividers become hrule', () {
      final doc = makeDoc(lines: [('---', null)]);
      final tex = exportToLatex(doc);
      expect(tex, contains(r'\hrule'));
    });

    test('expressions in math mode', () {
      final doc = makeDoc(lines: [('2 + 3', '5')]);
      final tex = exportToLatex(doc);
      expect(tex, contains(r'\['));
    });

    test('special characters are escaped', () {
      final doc = makeDoc(lines: [('100% tax & #1', '100')]);
      final tex = exportToLatex(doc);
      expect(tex, contains(r'\%'));
      expect(tex, contains(r'\&'));
      expect(tex, contains(r'\#'));
    });
  });

  group('plot exports', () {
    const expected = 'Plot of (2)*t^2; t in [-2, 2]';

    NotepadDocument plotDocument() => makeDoc(lines: [
          ('plot(a*t^2,t,-r,r)', '__plot__:(2)*t^2|t|-2|2'),
        ]);

    test('shared PDF and bundle content receives evaluated plot metadata', () {
      final doc = plotDocument();
      // A plot is not a scalar: a previously selected result format must not
      // alter its interval or expose the private cached representation.
      doc.lines.single.resultFormat = LineResultFormat.hex;
      final line = exportDocument(doc).lines.single;
      expect(line.kind, 'plot');
      expect(line.source, 'plot(a*t^2,t,-r,r)');
      expect(line.result, expected);
      expect(line.formattedResult, expected);
      expect(line.result, isNot(contains('__plot__')));
      expect(WorksheetBundle.capture(doc).resultAt(0), expected);
      // Export is a snapshot; it does not rewrite the persisted calculation.
      expect(doc.lines.single.cachedResult, '__plot__:(2)*t^2|t|-2|2');
    });

    test('Markdown preserves source and resolved expression/range', () {
      final md = exportToMarkdown(plotDocument());
      expect(md, contains('`plot(a*t^2,t,-r,r)`'));
      expect(md, contains('> $expected'));
      expect(md, isNot(contains('__plot__')));
    });

    test('LaTeX describes plots as text rather than scalar equality', () {
      final tex = exportToLatex(plotDocument());
      expect(tex, contains('Plot of (2)*t'));
      expect(tex, contains('t in [-2, 2]'));
      expect(tex, contains(r'\textasciicircum{}2'));
      expect(tex, isNot(contains('__plot__')));
      expect(tex, isNot(contains(r'\_\_plot\_\_')));
      expect(tex, isNot(contains(r'} = ')));
    });

    test('PDF serializes the same readable document content', () async {
      final doc = plotDocument();
      // exportToPdf consumes this shared content model before layout. Check
      // the actual content here, then exercise PDF layout/serialization too.
      expect(exportDocument(doc).lines.single.formattedResult, expected);
      final pdf = await exportToPdf(doc);
      final bytes = await pdf.save();
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    test('worksheet bundle HTML and text also omit the sentinel', () {
      final bundle = WorksheetBundle.capture(plotDocument());
      for (final content in [bundle.html(), bundle.markdown(), bundle.latex()]) {
        expect(content, contains('t in [-2, 2]'));
        expect(content, isNot(contains('__plot__')));
        expect(content, isNot(contains(r'\_\_plot\_\_')));
      }
    });

    test('uncalculated plots retain requested symbolic bounds honestly', () {
      final doc = makeDoc(lines: [('plot(sin(t),t,-pi,pi)', null)]);
      final line = exportDocument(doc).lines.single;
      expect(line.formattedResult,
          'Plot not calculated: sin(t); t in [-pi, pi]');
      expect(exportToMarkdown(doc), contains('Plot not calculated'));
    });

    test('malformed cached plots do not leak internal encoding', () {
      for (final cache in [
        '__plot__:sin(x)|x|bad|10',
        '__plot__:sin(x)|x|-Infinity|Infinity',
        '__plot__:sin(x)|x|4|2',
      ]) {
        final doc = makeDoc(lines: [('plot(sin(x))', cache)]);
        final line = exportDocument(doc).lines.single;
        expect(line.result,
            'Plot not calculated: sin(x); x in [-10, 10]');
        expect(exportToMarkdown(doc), isNot(contains('__plot__')));
        expect(exportToLatex(doc), isNot(contains(r'\_\_plot\_\_')));
      }
    });

    test('a failed plot cannot export its old successful result', () {
      final doc = plotDocument();
      doc.lines.single.cachedError = 'Invalid plot range';
      final result = exportDocument(doc).lines.single.formattedResult;
      expect(result, 'Plot unavailable: Invalid plot range');
      expect(result, isNot(contains('Plot of')));
      expect(exportToMarkdown(doc), isNot(contains('__plot__')));
    });
  });
}
