// lib/engine/notepad_export.dart
//
// Notepad V2 Tier C: structured export of a notepad document.
//
// Produces structured representations suitable for:
//   - PDF generation (via package:pdf when added)
//   - Markdown export (already exists as Copy-as-Markdown)
//   - HTML export
//   - LaTeX export
//
// Each line is classified and formatted according to its kind.

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'notepad.dart';
import 'notepad_evaluator.dart';

/// A single exported line with its classification and formatted parts.
class ExportedLine {
  final String kind; // 'heading', 'divider', 'expression', 'comment', etc.
  final String source;
  final String? result;
  final String? formattedResult; // With per-line format applied.

  const ExportedLine({
    required this.kind,
    required this.source,
    this.result,
    this.formattedResult,
  });
}

/// A fully exported document ready for rendering in any target format.
class ExportedDocument {
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ExportedLine> lines;

  const ExportedDocument({
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.lines,
  });
}

/// Export a NotepadDocument to a structured representation.
ExportedDocument exportDocument(NotepadDocument doc) {
  final firstCode = firstCodeLineIndexOf(doc);
  final exportedLines = <ExportedLine>[];

  for (var i = 0; i < doc.lines.length; i++) {
    final line = doc.lines[i];
    final parsed = classifyNotepadLine(
      line.source,
      lineIndex: i,
      firstCodeLineIndex: firstCode,
    );

    final formattedResult = line.cachedResult != null &&
            line.resultFormat != LineResultFormat.auto
        ? formatLineResult(line.cachedResult!, line.resultFormat)
        : null;

    exportedLines.add(ExportedLine(
      kind: parsed.kind.name,
      source: line.source,
      result: line.cachedResult,
      formattedResult: formattedResult ?? line.cachedResult,
    ));
  }

  return ExportedDocument(
    name: doc.name,
    createdAt: doc.createdAt,
    updatedAt: doc.updatedAt,
    lines: exportedLines,
  );
}

/// Export to Markdown format.
String exportToMarkdown(NotepadDocument doc) {
  final exported = exportDocument(doc);
  final buf = StringBuffer();
  buf.writeln('# ${exported.name}');
  buf.writeln();

  for (final line in exported.lines) {
    switch (line.kind) {
      case 'heading':
        buf.writeln(line.source); // Already starts with ##
        buf.writeln();
      case 'divider':
        buf.writeln('---');
        buf.writeln();
      case 'comment':
        buf.writeln('> ${line.source.replaceFirst(RegExp(r'^[\s]*(?://|#)\s?'), '')}');
      case 'blank':
        buf.writeln();
      case 'aggregate':
        final res = line.formattedResult ?? '';
        buf.writeln('**${line.source}**: $res');
      default:
        if (line.formattedResult != null && line.formattedResult!.isNotEmpty) {
          buf.writeln('`${line.source}` → `${line.formattedResult}`');
        } else {
          buf.writeln('`${line.source}`');
        }
    }
  }

  return buf.toString();
}

/// Export to LaTeX format.
String exportToLatex(NotepadDocument doc) {
  final exported = exportDocument(doc);
  final buf = StringBuffer();
  buf.writeln(r'\documentclass{article}');
  buf.writeln(r'\usepackage{amsmath}');
  buf.writeln(r'\begin{document}');
  buf.writeln(r'\section*{' + _latexEscape(exported.name) + '}');
  buf.writeln();

  for (final line in exported.lines) {
    switch (line.kind) {
      case 'heading':
        final text = line.source.replaceFirst(RegExp(r'^##\s*'), '');
        buf.writeln(r'\subsection*{' + _latexEscape(text) + '}');
      case 'divider':
        buf.writeln(r'\hrule');
        buf.writeln(r'\vspace{0.5em}');
      case 'comment':
        final text = line.source.replaceFirst(RegExp(r'^[\s]*(?://|#)\s?'), '');
        buf.writeln(r'\textit{' + _latexEscape(text) + '}');
      case 'blank':
        buf.writeln(r'\vspace{0.5em}');
      default:
        if (line.formattedResult != null && line.formattedResult!.isNotEmpty) {
          buf.writeln(
              r'\[ \text{' + _latexEscape(line.source) + r'} = ' + _latexEscape(line.formattedResult!) + r' \]');
        } else {
          buf.writeln(r'\[ ' + _latexEscape(line.source) + r' \]');
        }
    }
  }

  buf.writeln(r'\end{document}');
  return buf.toString();
}

String _latexEscape(String s) {
  return s
      .replaceAll(r'\', r'\textbackslash{}')
      .replaceAll('&', r'\&')
      .replaceAll('%', r'\%')
      .replaceAll(r'$', r'\$')
      .replaceAll('#', r'\#')
      .replaceAll('_', r'\_')
      .replaceAll('{', r'\{')
      .replaceAll('}', r'\}')
      .replaceAll('~', r'\textasciitilde{}')
      .replaceAll('^', r'\textasciicircum{}');
}

/// Export to PDF. Returns the raw PDF bytes.
Future<pw.Document> exportToPdf(NotepadDocument doc) async {
  final exported = exportDocument(doc);
  final pdf = pw.Document();

  final headingStyle = pw.TextStyle(
    fontSize: 16,
    fontWeight: pw.FontWeight.bold,
  );
  final exprStyle = pw.TextStyle(
    fontSize: 11,
    font: pw.Font.courier(),
  );
  final resultStyle = pw.TextStyle(
    fontSize: 11,
    font: pw.Font.courier(),
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue900,
  );
  final commentStyle = pw.TextStyle(
    fontSize: 10,
    fontStyle: pw.FontStyle.italic,
    color: PdfColors.grey700,
  );
  final aggregateStyle = pw.TextStyle(
    fontSize: 11,
    fontWeight: pw.FontWeight.bold,
  );

  final widgets = <pw.Widget>[];

  // Title
  widgets.add(pw.Text(exported.name,
      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)));
  widgets.add(pw.SizedBox(height: 8));

  for (final line in exported.lines) {
    switch (line.kind) {
      case 'heading':
        widgets.add(pw.SizedBox(height: 8));
        widgets.add(pw.Text(
          line.source.replaceFirst(RegExp(r'^##\s*'), ''),
          style: headingStyle,
        ));
        widgets.add(pw.SizedBox(height: 4));
      case 'divider':
        widgets.add(pw.Divider(thickness: 0.5));
      case 'comment':
        widgets.add(pw.Text(
          line.source.replaceFirst(RegExp(r'^[\s]*(?://|#)\s?'), ''),
          style: commentStyle,
        ));
      case 'blank':
        widgets.add(pw.SizedBox(height: 6));
      case 'aggregate':
        final res = line.formattedResult ?? '';
        widgets.add(pw.Row(children: [
          pw.Expanded(child: pw.Text(line.source, style: aggregateStyle)),
          pw.Text(res, style: resultStyle),
        ]));
      default:
        // Expression line — show source and result side-by-side.
        if (line.formattedResult != null &&
            line.formattedResult!.isNotEmpty) {
          widgets.add(pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Text(line.source, style: exprStyle),
              ),
              pw.SizedBox(width: 8),
              pw.Text('=', style: exprStyle),
              pw.SizedBox(width: 8),
              pw.Expanded(
                flex: 2,
                child: pw.Text(line.formattedResult!, style: resultStyle),
              ),
            ],
          ));
        } else if (line.source.trim().isNotEmpty) {
          widgets.add(pw.Text(line.source, style: exprStyle));
        }
    }
  }

  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    build: (context) => widgets,
    footer: (context) => pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'CrispCalc — ${exported.name}',
        style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
      ),
    ),
  ));

  return pdf;
}
