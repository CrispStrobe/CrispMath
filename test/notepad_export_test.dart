// test/notepad_export_test.dart
//
// Tests for notepad export (Markdown, LaTeX, structured).

import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_export.dart';

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
}
