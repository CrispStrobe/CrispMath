import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../engine/notepad.dart';

Map<String, dynamic> worksheetSource(NotepadDocument doc) => {
      'i': doc.id,
      'n': doc.name,
      'c': doc.createdAt.toIso8601String(),
      'u': doc.updatedAt.toIso8601String(),
      'lx': doc.useLatexInput,
      'l': [
        for (final row in doc.lines)
          {
            'i': row.id,
            's': row.source,
            'rf': row.resultFormat.index,
            'p': row.pinned,
          }
      ],
    };

/// Validate the entire source before restoring; computed caches are discarded.
NotepadDocument validateWorksheetSource(dynamic raw) {
  if (raw is! Map ||
      raw['i'] is! String ||
      (raw['i'] as String).isEmpty ||
      (raw['i'] as String).length > 200 ||
      raw['n'] is! String ||
      (raw['n'] as String).length > 200 ||
      raw['l'] is! List ||
      (raw['l'] as List).length > 10000) {
    throw const FormatException('Invalid worksheet source');
  }
  for (final key in ['c', 'u']) {
    if (raw[key] is! String || DateTime.tryParse(raw[key]) == null) {
      throw const FormatException('Invalid worksheet date');
    }
  }
  if (raw['lx'] != null && raw['lx'] is! bool) {
    throw const FormatException('Invalid input mode');
  }
  final ids = <String>{};
  final rows = <NotepadLine>[];
  for (final row in raw['l']) {
    if (row is! Map ||
        row['i'] is! String ||
        (row['i'] as String).isEmpty ||
        (row['i'] as String).length > 200 ||
        !ids.add(row['i']) ||
        row['s'] is! String ||
        (row['s'] as String).length > 1000000 ||
        (row['p'] != null && row['p'] is! bool) ||
        (row['rf'] != null &&
            (row['rf'] is! int ||
                row['rf'] < 0 ||
                row['rf'] >= LineResultFormat.values.length))) {
      throw const FormatException('Invalid or duplicate worksheet row');
    }
    rows.add(NotepadLine(
        id: row['i'],
        source: row['s'],
        pinned: row['p'] == true,
        resultFormat: LineResultFormat.values[row['rf'] ?? 0]));
  }
  if (rows.isEmpty) rows.add(NotepadLine.fresh(source: ''));
  return NotepadDocument(
      id: raw['i'],
      name: raw['n'],
      createdAt: DateTime.parse(raw['c']),
      updatedAt: DateTime.parse(raw['u']),
      lines: rows,
      useLatexInput: raw['lx'] == true);
}

class DocumentCheckpoint {
  final String id;
  final String label;
  final String documentId;
  final DateTime createdAt;
  final String _source;
  DocumentCheckpoint.capture(NotepadDocument doc, {required this.label})
      : documentId = doc.id,
        id = generateNotepadId(),
        createdAt = DateTime.now().toUtc(),
        _source = jsonEncode(worksheetSource(doc));
  DocumentCheckpoint._(
      this.id, this.label, this.documentId, this.createdAt, this._source);
  NotepadDocument get document => validateWorksheetSource(jsonDecode(_source));
  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'createdAt': createdAt.toIso8601String(),
        'source': jsonDecode(_source)
      };
  static DocumentCheckpoint fromJson(dynamic raw) {
    if (raw is! Map ||
        raw['id'] is! String ||
        raw['label'] is! String ||
        (raw['label'] as String).length > 120 ||
        raw['createdAt'] is! String ||
        DateTime.tryParse(raw['createdAt']) == null) {
      throw const FormatException('Invalid checkpoint');
    }
    final doc = validateWorksheetSource(raw['source']);
    return DocumentCheckpoint._(raw['id'], raw['label'], doc.id,
        DateTime.parse(raw['createdAt']), jsonEncode(worksheetSource(doc)));
  }

  List<String> compare(NotepadDocument current) {
    final saved = document;
    final changes = <String>[];
    if (saved.name != current.name) {
      changes.add('Name: ${saved.name} → ${current.name}');
    }
    if (saved.useLatexInput != current.useLatexInput) {
      changes.add('Input mode changed');
    }
    final positions = {
      for (var i = 0; i < current.lines.length; i++) current.lines[i].id: i
    };
    final before = {for (final row in saved.lines) row.id: row};
    final after = {for (final row in current.lines) row.id: row};
    for (var i = 0; i < saved.lines.length; i++) {
      final old = saved.lines[i];
      final now = after[old.id];
      if (now == null) {
        changes.add('Removed: ${old.source}');
        continue;
      }
      if (old.source != now.source) {
        changes.add('${old.source} → ${now.source}');
      }
      if (old.resultFormat != now.resultFormat || old.pinned != now.pinned) {
        changes.add('Presentation changed: ${now.source}');
      }
      if (positions[old.id] != i) changes.add('Moved: ${now.source}');
    }
    for (final row in current.lines) {
      if (!before.containsKey(row.id)) changes.add('Added: ${row.source}');
    }
    return changes;
  }
}

class DocumentHistory {
  static const storageKey = 'crisp.documentCheckpoints';
  static const maxBytes = 1024 * 1024;
  static Future<void> _writes = Future.value();
  Future<List<DocumentCheckpoint>> all() async {
    await _writes;
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString(storageKey);
    if (text == null) return [];
    final raw = jsonDecode(text);
    if (raw is! List) throw const FormatException('Invalid checkpoint history');
    return raw.map(DocumentCheckpoint.fromJson).toList();
  }

  Future<List<DocumentCheckpoint>> forDocument(String id) async =>
      (await all()).where((c) => c.documentId == id).toList().reversed.toList();

  Future<void> replaceAll(List<DocumentCheckpoint> incoming) {
    final entries = List<DocumentCheckpoint>.from(incoming)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    for (final id in entries.map((e) => e.documentId).toSet()) {
      while (entries.where((e) => e.documentId == id).length > 20) {
        entries.removeAt(entries.indexWhere((e) => e.documentId == id));
      }
    }
    while (entries.length > 100 ||
        utf8
                .encode(jsonEncode(entries.map((e) => e.toJson()).toList()))
                .length >
            maxBytes) {
      entries.removeAt(0);
    }
    final text = jsonEncode(entries.map((e) => e.toJson()).toList());
    if (entries.length > 100 || utf8.encode(text).length > maxBytes) {
      return Future.error(
          const FormatException('Checkpoint history exceeds storage limits'));
    }
    final operation = _writes.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString(storageKey, text)) {
        throw StateError('Checkpoint history could not be saved');
      }
    });
    _writes = operation.catchError((Object _) {});
    return operation;
  }

  Future<DocumentCheckpoint> save(NotepadDocument doc,
      {String label = 'Checkpoint'}) {
    final checkpoint = DocumentCheckpoint.capture(doc, label: label);
    if (label.length > 120 ||
        utf8.encode(jsonEncode([checkpoint.toJson()])).length > maxBytes) {
      return Future.error(
          const FormatException('Checkpoint exceeds the storage limit'));
    }
    final operation = _writes.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(storageKey);
      final entries = raw == null
          ? <DocumentCheckpoint>[]
          : (jsonDecode(raw) as List).map(DocumentCheckpoint.fromJson).toList();
      entries.add(checkpoint);
      while (entries.where((c) => c.documentId == doc.id).length > 20) {
        entries.removeAt(entries.indexWhere((c) => c.documentId == doc.id));
      }
      while (entries.length > 100 ||
          utf8
                  .encode(jsonEncode(entries.map((e) => e.toJson()).toList()))
                  .length >
              maxBytes) {
        entries.removeAt(0);
      }
      final ok = await prefs.setString(
          storageKey, jsonEncode(entries.map((e) => e.toJson()).toList()));
      if (!ok) throw StateError('Checkpoint could not be saved');
    });
    _writes = operation.catchError((Object _) {});
    return operation.then((_) => checkpoint);
  }
}
