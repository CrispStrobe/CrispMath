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
import 'notepad_plot.dart';
import 'notepad_references.dart';

/// A single exported line with its classification and formatted parts.
class ExportedLine {
  final String kind; // 'heading', 'divider', 'expression', 'comment', etc.
  final String source;
  final String? result;
  final String? formattedResult; // With per-line format applied.
  final String? resultLabel;

  /// Readable identity within this static snapshot. Editable worksheet files
  /// retain persistent tokens instead of these presentation-only labels.
  String get displaySource =>
      resultLabel == null ? source : '$resultLabel: $source';

  const ExportedLine({
    required this.kind,
    required this.source,
    this.result,
    this.formattedResult,
    this.resultLabel,
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
  final references = _ExportResultReferences(doc);

  for (var i = 0; i < doc.lines.length; i++) {
    final line = doc.lines[i];
    final parsed = classifyNotepadLine(
      line.source,
      lineIndex: i,
      firstCodeLineIndex: firstCode,
    );
    final source = references.describe(line.source);
    final resultLabel = references.labels[line.id];

    // Plots are structured outputs, not scalar answers. Every exporter,
    // including the shared worksheet bundle/PDF path, receives readable
    // metadata rather than the evaluator's private cache encoding.
    if (parsed.kind == NotepadLineKind.plot) {
      final description = references.describe(_plotDescription(line, parsed,
          error: references.describeError(line.cachedError)));
      exportedLines.add(ExportedLine(
        kind: parsed.kind.name,
        source: source,
        result: description,
        formattedResult: description,
      ));
      continue;
    }

    final formattedResult =
        line.cachedResult != null && line.resultFormat != LineResultFormat.auto
            ? formatLineResult(line.cachedResult!, line.resultFormat)
            : null;

    exportedLines.add(ExportedLine(
      kind: parsed.kind.name,
      source: source,
      result: line.cachedResult,
      formattedResult: formattedResult ?? line.cachedResult,
      resultLabel: resultLabel,
    ));
  }

  return ExportedDocument(
    name: doc.name,
    createdAt: doc.createdAt,
    updatedAt: doc.updatedAt,
    lines: exportedLines,
  );
}

/// Snapshot labels are assigned from the current row order, with the same
/// label attached to the source and every reference to its result. They never
/// become executable aliases or alter the persisted worksheet source.
class _ExportResultReferences {
  _ExportResultReferences(NotepadDocument document) {
    final counts = <String, int>{};
    final mentioned = <String>{};
    for (final line in document.lines) {
      counts.update(line.id, (value) => value + 1, ifAbsent: () => 1);
      mentioned.addAll(
          resultReferencesIn(line.source).map((reference) => reference.lineId));
      final blocked = NotepadErrorPrefix.parseBlocked(line.cachedError ?? '');
      if (blocked != null) mentioned.add(blocked.lineId);
    }
    final firstCode = firstCodeLineIndexOf(document);
    for (var i = 0; i < document.lines.length; i++) {
      final line = document.lines[i];
      if (counts[line.id] != 1) {
        descriptions[line.id] = '[ambiguous result]';
        continue;
      }
      final parsed = classifyNotepadLine(line.source,
          lineIndex: i, firstCodeLineIndex: firstCode);
      final eligible = parsed.kind == NotepadLineKind.expression ||
          parsed.kind == NotepadLineKind.aggregate ||
          (parsed.kind == NotepadLineKind.assignment && !parsed.isFunction);
      if (!eligible) {
        descriptions[line.id] = '[unavailable result of line ${i + 1}]';
      } else {
        final label = 'result[${i + 1}]';
        descriptions[line.id] = label;
        if (mentioned.contains(line.id)) labels[line.id] = label;
      }
    }
  }

  final labels = <String, String>{};
  final descriptions = <String, String>{};

  String? describeError(String? error) {
    if (error == null) return null;
    if (error.startsWith(NotepadErrorPrefix.blockedBy)) {
      final blocked = NotepadErrorPrefix.parseBlocked(error);
      if (blocked == null) return 'A required result is unavailable.';
      final target = descriptions[blocked.lineId] ?? '[missing result]';
      return 'Blocked by $target. Fix the source calculation.';
    }
    if (error.startsWith(NotepadErrorPrefix.evaluation)) {
      return error.substring(NotepadErrorPrefix.evaluation.length);
    }
    if (error.startsWith(NotepadErrorPrefix.circularReference)) {
      return 'Circular reference: '
          '${error.substring(NotepadErrorPrefix.circularReference.length)}';
    }
    return error;
  }

  String describe(String source) {
    final out = StringBuffer();
    var cursor = 0;
    for (final reference in resultReferencesIn(source)) {
      out.write(source.substring(cursor, reference.start));
      out.write(descriptions[reference.lineId] ?? '[missing result]');
      cursor = reference.end;
    }
    out.write(source.substring(cursor));
    return out.toString();
  }
}

List<String> exportedNotepadDomainWarnings(NotepadDocument doc) {
  final references = _ExportResultReferences(doc);
  return [
    for (final line in doc.lines)
      if (line.resultEvidence?.sourceDomain != null)
        '${references.describe(line.source)}: '
            'original domain ${line.resultEvidence!.sourceDomain}',
  ];
}

List<String?> exportedNotepadErrors(NotepadDocument doc) {
  final references = _ExportResultReferences(doc);
  return [
    for (final line in doc.lines) references.describeError(line.cachedError),
  ];
}

String _plotDescription(NotepadLine line, ParsedNotepadLine parsed,
    {String? error}) {
  if (line.cachedError != null) {
    return 'Plot unavailable: ${error ?? line.cachedError}';
  }
  final spec = PlotSpec.tryParse(line.cachedResult);
  if (spec != null) {
    return 'Plot of ${spec.expression}; ${spec.variable} in '
        '[${_plotNumber(spec.lo)}, ${_plotNumber(spec.hi)}]';
  }
  // Retain the requested expression and symbolic bounds when no usable
  // evaluation is available. This is a description, not a rendered graph.
  return 'Plot not calculated: ${parsed.body}; ${parsed.name} in '
      '[${parsed.imports[0]}, ${parsed.imports[1]}]';
}

String _plotNumber(double value) =>
    value == value.roundToDouble() && value.abs() < 1e21
        ? value.toStringAsFixed(0)
        : value.toString();

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
        buf.writeln(
            '> ${line.source.replaceFirst(RegExp(r'^[\s]*(?://|#)\s?'), '')}');
      case 'blank':
        buf.writeln();
      case 'aggregate':
        final res = line.formattedResult ?? '';
        buf.writeln('**${line.displaySource}**: $res');
      case 'plot':
        buf.writeln('`${line.source}`');
        buf.writeln();
        buf.writeln('> ${line.formattedResult}');
        buf.writeln();
      default:
        if (line.formattedResult != null && line.formattedResult!.isNotEmpty) {
          buf.writeln('`${line.displaySource}` → `${line.formattedResult}`');
        } else {
          buf.writeln('`${line.displaySource}`');
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
  buf.writeln('\\section*{${_latexEscape(exported.name)}}');
  buf.writeln();

  for (final line in exported.lines) {
    switch (line.kind) {
      case 'heading':
        final text = line.source.replaceFirst(RegExp(r'^##\s*'), '');
        buf.writeln('\\subsection*{${_latexEscape(text)}}');
      case 'divider':
        buf.writeln(r'\hrule');
        buf.writeln(r'\vspace{0.5em}');
      case 'comment':
        final text = line.source.replaceFirst(RegExp(r'^[\s]*(?://|#)\s?'), '');
        buf.writeln('\\textit{${_latexEscape(text)}}');
      case 'blank':
        buf.writeln(r'\vspace{0.5em}');
      case 'plot':
        buf.writeln('\\noindent\\texttt{${_latexEscape(line.source)}}\\par');
        buf.writeln(
            '\\noindent ${_latexEscape(line.formattedResult!)}\\par');
      default:
        if (line.formattedResult != null && line.formattedResult!.isNotEmpty) {
          buf.writeln(r'\[ \text{' +
              _latexEscape(line.displaySource) +
              r'} = ' +
              _latexEscape(line.formattedResult!) +
              r' \]');
        } else {
          buf.writeln(r'\[ ' + _latexEscape(line.displaySource) + r' \]');
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
          pw.Expanded(child: pw.Text(line.displaySource, style: aggregateStyle)),
          pw.Text(res, style: resultStyle),
        ]));
      case 'plot':
        widgets.add(pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(line.source, style: exprStyle),
            pw.Text(line.formattedResult!, style: resultStyle),
            pw.SizedBox(height: 4),
          ],
        ));
      default:
        // Expression line — show source and result side-by-side.
        if (line.formattedResult != null && line.formattedResult!.isNotEmpty) {
          widgets.add(pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Text(line.displaySource, style: exprStyle),
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
          widgets.add(pw.Text(line.displaySource, style: exprStyle));
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
        'CrispMath — ${exported.name}',
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
      ),
    ),
  ));

  return pdf;
}
