import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:crisp_math/widgets/worksheet_export_dialog.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/worksheet_bundle.dart';
import 'package:crisp_math/utils/share_link.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('exports freeze values, preserve errors and escape active markup',
      () async {
    final doc = NotepadDocument.fresh(name: '<script>alert(1)</script>');
    doc.lines.clear();
    doc.lines.add(NotepadLine.fresh(source: '2+2')..cachedResult = '4');
    doc.lines.add(NotepadLine.fresh(source: '<img src=x onerror=bad()>')
      ..cachedError = 'Invalid input');
    final bundle = WorksheetBundle.capture(doc, expressions: ['x^2', '1/x']);
    doc.lines.first.cachedResult = '999';
    expect(bundle.html(), contains('4'));
    expect(bundle.html(), isNot(contains('999')));
    expect(bundle.html(), contains('&lt;script&gt;'));
    expect(bundle.html(), isNot(contains('<img')));
    expect(bundle.html(), contains('Invalid input'));
    expect(bundle.graphs.first.values[7], (2.0, 4.0));
    expect(bundle.graphs.last.values[5], (0.0, null));
    expect(bundle.markdown(), contains('Undefined'));
    expect(bundle.latex(), startsWith(r'\documentclass'));
    expect(bundle.latex(), contains('0.0 & Undefined'));
    expect(bundle.latex(), isNot(contains('999')));
    final pdf = await bundle.pdf();
    expect(String.fromCharCodes(pdf.take(4)), '%PDF');
  });
  testWidgets('phone preview stays bounded and shows missing calculations',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final doc = NotepadDocument.fresh(name: 'Preview');
    doc.lines.clear();
    doc.lines.add(NotepadLine.fresh(source: '2+2'));
    final bundle = WorksheetBundle.capture(doc);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: WorksheetExportDialog(bundle: bundle))));
    await tester.pumpAndSettle();
    expect(find.text('Not calculated'), findsOneWidget);
    expect(find.text('Save HTML'), findsOneWidget);
    expect(find.text('Save PDF'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(bundle.html(), contains('Not calculated'));
  });

  test('bounded graph capture reports truncation', () {
    final bundle = WorksheetBundle.capture(
        NotepadDocument.fresh(name: 'Bounds'),
        expressions: List.filled(13, 'x'));
    expect(bundle.graphs.length, 12);
    expect(bundle.warnings.single, contains('12'));
  });
  test('share URL retains Pages path and decodes percent and plus once', () {
    final uri = Uri.parse(buildShareUrl('50% + x%20',
        tab: 1,
        baseUri: Uri.parse('https://example.org/CrispMath/?old=1#old')));
    expect(uri.path, '/CrispMath/');
    expect(uri.fragment, '');
    final parsed = ShareParams.fromUri(uri)!;
    expect(parsed.expression, '50% + x%20');
    expect(parsed.tab, 1);
  });
}
