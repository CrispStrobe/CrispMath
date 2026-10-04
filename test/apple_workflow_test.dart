import 'dart:convert';
import 'dart:typed_data';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/services/apple_workflow.dart';
import 'package:crisp_math/services/worksheet_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('worksheet files preserve source and presentation, never cached answers',
      () {
    final original = NotepadDocument.fresh(name: 'Étude');
    original.useLatexInput = true;
    original.lines.single
      ..source = 'f(x)=x^2'
      ..cachedResult = 'incorrect imported cache'
      ..cachedError = 'incorrect imported error'
      ..pinned = true
      ..resultFormat = LineResultFormat.fraction;
    final imported = WorksheetFile.decode(WorksheetFile.encode(original));
    expect(imported.id, isNot(original.id));
    expect(imported.lines.single.id, isNot(original.lines.single.id));
    expect(imported.name, 'Étude');
    expect(imported.useLatexInput, isTrue);
    expect(imported.lines.single.source, 'f(x)=x^2');
    expect(imported.lines.single.cachedResult, isNull);
    expect(imported.lines.single.cachedError, isNull);
    expect(imported.lines.single.pinned, isTrue);
    expect(imported.lines.single.resultFormat, LineResultFormat.fraction);
  });

  test('empty imported worksheets remain editable', () {
    final doc = NotepadDocument.fresh(name: 'Empty')..lines.clear();
    expect(WorksheetFile.decode(WorksheetFile.encode(doc)).lines.single.source,
        '');
  });

  test('unknown schema, malformed rows and oversized files are rejected', () {
    for (final payload in [
      {},
      {'format': 'crispmath.worksheet', 'version': 2, 'document': {}},
      {
        'format': 'crispmath.worksheet',
        'version': 1,
        'document': {
          'n': 'Bad',
          'l': [
            {'s': 3}
          ]
        }
      },
    ]) {
      expect(
          () => WorksheetFile.decode(
              Uint8List.fromList(utf8.encode(jsonEncode(payload)))),
          throwsFormatException);
    }
    expect(() => WorksheetFile.decode(Uint8List(WorksheetFile.maxBytes + 1)),
        throwsFormatException);
  });

  test('filenames cannot introduce directories and retain Unicode names', () {
    expect(WorksheetFile.fileName('../Étude/a'), '.._Étude_a.crispmath');
    expect(WorksheetFile.fileName(''), 'Worksheet.crispmath');
    expect(WorksheetFile.fileName('a' * 100).length, 90);
  });

  test('native and web workflow links preserve percent and plus signs once',
      () {
    for (final uri in [
      Uri(scheme: 'crispmath', host: 'worksheet', queryParameters: {
        'name': '50% + study',
        'lines': 'a=3\nf(x)=x^2+a\nf(4)'
      }),
      Uri.https('example.test', '/app/', {
        'action': 'worksheet',
        'name': '50% + study',
        'lines': 'a=3\nf(x)=x^2+a\nf(4)'
      }),
    ]) {
      final doc =
          AppleWorkflowAction.fromUri(Uri.parse(uri.toString()))!.document!;
      expect(doc.name, '50% + study');
      expect(doc.lines.map((l) => l.source), ['a=3', 'f(x)=x^2+a', 'f(4)']);
    }
  });

  test('calculation links are bounded and unknown actions ignored', () {
    expect(
        AppleWorkflowAction.fromUri(
                Uri.parse('crispmath://calculate?expression=2%2B3'))!
            .expression,
        '2+3');
    expect(
        AppleWorkflowAction.fromUri(Uri.parse('crispmath://unknown')), isNull);
    expect(
        () => AppleWorkflowAction.fromUri(Uri.parse('crispmath://calculate')),
        throwsFormatException);
    expect(
        () => AppleWorkflowAction.fromUri(Uri(
            scheme: 'crispmath',
            host: 'worksheet',
            queryParameters: {'lines': 'x' * 100001})),
        throwsFormatException);
  });

  test('native Files events use the same validated import path', () {
    final doc = NotepadDocument.fresh(name: 'Files');
    final action = AppleWorkflowAction.fromNative(
        {'file': base64Encode(WorksheetFile.encode(doc))});
    expect(action!.document!.name, 'Files');
    expect(() => AppleWorkflowAction.fromNative({'file': 'not base64!'}),
        throwsFormatException);
  });
}
