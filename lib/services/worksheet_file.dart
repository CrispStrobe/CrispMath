import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../engine/notepad.dart';

/// Portable source document. Imported values are recalculated locally.
class WorksheetFile {
  static const maxBytes = 8 * 1024 * 1024;

  static Uint8List encode(NotepadDocument doc) => Uint8List.fromList(
          utf8.encode(const JsonEncoder.withIndent('  ').convert({
        'format': 'crispmath.worksheet',
        'version': 1,
        'document': doc.toJson(),
      })));

  static NotepadDocument decode(Uint8List bytes) {
    if (bytes.length > maxBytes) {
      throw const FormatException('Worksheet exceeds the 8 MB limit');
    }
    final payload = jsonDecode(utf8.decode(bytes));
    if (payload is! Map ||
        payload['format'] != 'crispmath.worksheet' ||
        payload['version'] != 1 ||
        payload['document'] is! Map) {
      throw const FormatException('Unsupported CrispMath worksheet file');
    }
    final raw = payload['document'] as Map;
    if (raw['n'] is! String || raw['l'] is! List) {
      throw const FormatException('Invalid worksheet name or rows');
    }
    final rows = raw['l'] as List;
    if (rows.length > 10000 ||
        rows.any((r) => r is! Map || r['s'] is! String)) {
      throw const FormatException('Invalid worksheet rows');
    }
    final doc = NotepadDocument.fresh(name: raw['n'] as String);
    doc.useLatexInput = raw['lx'] == true;
    doc.lines.clear();
    for (final row in rows) {
      final line = NotepadLine.fresh(source: row['s'] as String);
      // Preserve presentation, but never trust imported calculation caches.
      final format = row['rf'];
      if (format is int &&
          format >= 0 &&
          format < LineResultFormat.values.length) {
        line.resultFormat = LineResultFormat.values[format];
      }
      line.pinned = row['p'] == true;
      doc.lines.add(line);
    }
    if (doc.lines.isEmpty) doc.lines.add(NotepadLine.fresh(source: ''));
    return doc;
  }

  static String fileName(String name) {
    final safe =
        name.replaceAll(RegExp(r'[^\p{L}\p{N} _.-]', unicode: true), '_');
    return '${safe.isEmpty ? 'Worksheet' : safe.substring(0, safe.length.clamp(0, 80))}.crispmath';
  }
}

class WorksheetFileService {
  static Future<NotepadDocument?> open() async {
    final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['crispmath', 'json'],
        withData: true);
    if (result == null) return null;
    final file = result.files.single;
    if (file.size > WorksheetFile.maxBytes) {
      throw const FormatException('Worksheet exceeds the 8 MB limit');
    }
    final bytes = file.bytes ?? await file.xFile.readAsBytes();
    return WorksheetFile.decode(bytes);
  }

  static Future<bool> save(NotepadDocument doc) async {
    final path = await FilePicker.saveFile(
        dialogTitle: 'Save worksheet',
        fileName: WorksheetFile.fileName(doc.name),
        type: FileType.custom,
        allowedExtensions: ['crispmath'],
        bytes: WorksheetFile.encode(doc));
    return kIsWeb || path != null;
  }
}
