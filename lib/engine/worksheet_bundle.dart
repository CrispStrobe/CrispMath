import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

import 'graph_sampling.dart';
import 'notepad.dart';
import 'notepad_export.dart';
import 'numeric_fallback.dart';

/// Immutable capture: every preview and exported format uses the same values.
class WorksheetBundle {
  final ExportedDocument document;
  final List<String?> errors;
  final List<WorksheetGraph> graphs;
  final List<String> warnings;
  WorksheetBundle.capture(NotepadDocument source,
      {List<String> expressions = const [], List<String> warnings = const []})
      : document = exportDocument(source),
        errors =
            List.unmodifiable(source.lines.map((line) => line.cachedError)),
        graphs =
            List.unmodifiable(expressions.take(12).map(WorksheetGraph.new)),
        warnings = List.unmodifiable([
          ...warnings,
          if (expressions.length > 12)
            'Only the first 12 linked graphs are included.',
        ]);

  String resultAt(int index) {
    final line = document.lines[index];
    return errors[index] ??
        line.formattedResult ??
        (const {'expression', 'assignment', 'aggregate', 'plot'}
                .contains(line.kind)
            ? 'Not calculated'
            : '');
  }

  String html() {
    final out = StringBuffer(
        '<!doctype html><html lang="en"><meta charset="utf-8">'
        '<meta name="viewport" content="width=device-width,initial-scale=1">'
        '<title>${escape(document.name)}</title><style>'
        'body{font:16px system-ui;max-width:960px;margin:24px auto;padding:16px}'
        'table{border-collapse:collapse;width:100%;margin:16px 0}'
        'td,th{border:1px solid #aaa;padding:8px;text-align:left;overflow-wrap:anywhere}'
        'svg{width:100%;max-width:640px;height:auto}code{white-space:pre-wrap}'
        '</style><h1>${escape(document.name)}</h1>'
        '<p>Worksheet snapshot. Graphs use x/y from -5 to 5; tables use x from -5 to 5; blank values are undefined.</p>');
    for (final warning in warnings) {
      out.write('<p>${escape(warning)}</p>');
    }
    out.write(
        '<table><thead><tr><th>Source</th><th>Result</th></tr></thead><tbody>');
    for (var i = 0; i < document.lines.length; i++) {
      final line = document.lines[i];
      out.write('<tr><td><code>${escape(line.source)}</code></td><td>'
          '${escape(resultAt(i))}</td></tr>');
    }
    out.write('</tbody></table>');
    for (final graph in graphs) {
      out.write('<section><h2>${escape(graph.expression)}</h2>${graph.svg}'
          '<table><thead><tr><th>x</th><th>y</th></tr></thead><tbody>');
      for (final row in graph.values) {
        out.write(
            '<tr><td>${row.$1}</td><td>${row.$2 ?? "Undefined"}</td></tr>');
      }
      out.write('</tbody></table></section>');
    }
    out.write('</html>');
    return out.toString();
  }

  String markdown() {
    final out = StringBuffer('# ${document.name}\n\n');
    for (var i = 0; i < document.lines.length; i++) {
      out.writeln('    ${document.lines[i].source}');
      final result = resultAt(i);
      if (result.isNotEmpty) out.writeln('    → $result');
    }
    for (final graph in graphs) {
      out.writeln(
          '\n## ${graph.expression}\n\n${graph.svg}\n\nx | y\n--- | ---');
      for (final row in graph.values) {
        out.writeln('${row.$1} | ${row.$2 ?? "Undefined"}');
      }
    }
    for (final warning in warnings) {
      out.writeln('\n$warning');
    }
    return out.toString();
  }

  String latex() {
    String text(String value) => value
        .split('')
        .map((c) => switch (c) {
              '\\' => r'\textbackslash{}',
              '&' || '%' || r'$' || '#' || '_' || '{' || '}' => '\\$c',
              '~' => r'\textasciitilde{}',
              '^' => r'\textasciicircum{}',
              _ => c,
            })
        .join();
    final out = StringBuffer(r'\documentclass{article}'
        '\n'
        r'\usepackage{amsmath,tikz}'
        '\n'
        r'\begin{document}'
        '\n');
    out.writeln('\\section*{${text(document.name)}}');
    for (var i = 0; i < document.lines.length; i++) {
      out.writeln(
          '\\noindent ${text(document.lines[i].source)} \\quad ${text(resultAt(i))}\\par');
    }
    for (final graph in graphs) {
      out.writeln('\\subsection*{${text(graph.expression)}}');
      out.writeln(r'\begin{tikzpicture}[x=.01cm,y=-.01cm]');
      for (final segment
          in graph.curvePath.split('M').where((s) => s.trim().isNotEmpty)) {
        final coordinates =
            segment.trim().split('L').map((p) => '(${p.trim()})').join(' -- ');
        out.writeln('\\draw[blue] $coordinates;');
      }
      out.writeln(r'\end{tikzpicture}');
      out.writeln(r'\begin{tabular}{rr} x & y \\');
      for (final row in graph.values) {
        out.writeln('${row.$1} & ${row.$2 ?? "Undefined"} ' r'\\');
      }
      out.writeln(r'\end{tabular}');
    }
    for (final warning in warnings) {
      out.writeln('${text(warning)}\\par');
    }
    out.writeln(r'\end{document}');
    return out.toString();
  }

  Future<Uint8List> pdf() async {
    final font =
        pw.Font.ttf(await rootBundle.load('assets/fonts/DejaVuSans.ttf'));
    final pdf = pw.Document(
        theme: pw.ThemeData.withFont(
            base: font, bold: font, italic: font, boldItalic: font));
    final widgets = <pw.Widget>[
      pw.Text(document.name, style: const pw.TextStyle(fontSize: 20)),
      pw.Text(
          'Snapshot; graph x/y and table x range -5 to 5. Undefined values are explicit.'),
      for (final warning in warnings) pw.Text(warning),
      for (var i = 0; i < document.lines.length; i++)
        pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Text('${document.lines[i].source}\n${resultAt(i)}')),
      for (final graph in graphs) ...[
        pw.Text(graph.expression),
        pw.SvgImage(svg: graph.svg, width: 480, height: 240),
        pw.TableHelper.fromTextArray(headers: [
          'x',
          'y'
        ], data: [
          for (final row in graph.values)
            [row.$1.toString(), row.$2?.toString() ?? 'Undefined'],
        ]),
      ],
    ];
    pdf.addPage(pw.MultiPage(build: (_) => widgets));
    return pdf.save();
  }

  static String escape(String value) => const HtmlEscape().convert(value);
}

class WorksheetGraph {
  final String expression;
  late final List<(double, double?)> values;
  late final String svg;
  late final String curvePath;
  WorksheetGraph(this.expression) {
    final compiled = NumericFallbackEvaluator.compile(expression);
    values = List.unmodifiable(List.generate(11, (i) {
      final x = i - 5.0;
      final y = compiled?.evaluate({'x': x});
      return (x, y != null && y.isFinite ? y : null);
    }));
    final points = sampleGraph({
      'functions': [expression],
      'mode': 'cartesian',
      'xMin': -5,
      'xMax': 5,
      'yMin': -5,
      'yMax': 5,
      'width': 640
    }).curves.single;
    final path = StringBuffer();
    var connected = false;
    double? lastY;
    for (final point in points) {
      // Clip gaps and large jumps rather than drawing a line across poles.
      if (!point.ok || point.y.abs() > 5) {
        connected = false;
        lastY = null;
        continue;
      }
      if (lastY != null && (point.y - lastY).abs() > 2) connected = false;
      final x = (point.x + 5) * 64;
      final y = (5 - point.y) * 32;
      path.write(
          '${connected ? "L" : "M"}${x.toStringAsFixed(2)},${y.toStringAsFixed(2)} ');
      connected = true;
      lastY = point.y;
    }
    curvePath = path.toString();
    svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 320" role="img"'
        ' aria-label="${WorksheetBundle.escape(expression)}"><rect width="640" height="320" fill="white"/>'
        '<path d="M0,160H640 M320,0V320" stroke="#888" fill="none"/>'
        '<path d="$path" stroke="#1769aa" stroke-width="2" fill="none"/></svg>';
  }
}
