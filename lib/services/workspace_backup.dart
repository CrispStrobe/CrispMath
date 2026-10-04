import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../engine/app_state.dart';
import '../engine/linked_graph.dart';
import '../engine/notepad.dart';
import '../engine/scene_3d/scene_state.dart';
import 'document_history.dart';

class WorkspaceBackup {
  static const maxBytes = 16 * 1024 * 1024;
  final Map<String, dynamic> state;
  final List<DocumentCheckpoint> checkpoints;
  WorkspaceBackup._(this.state, this.checkpoints);
  factory WorkspaceBackup.fromState(Map<String, dynamic> state) =>
      WorkspaceBackup._(normalize(state), const []);
  static String _digest(Object data) =>
      sha256.convert(utf8.encode(jsonEncode(data))).toString();

  static Uint8List encode(AppState state,
      {List<DocumentCheckpoint> checkpoints = const []}) {
    final data = normalize(state.exportToJson());
    final payload = {
      'state': data,
      'checkpoints': checkpoints.map((c) => c.toJson()).toList()
    };
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode({
      'format': 'crispmath.backup',
      'version': 1,
      ...payload,
      'sha256': _digest(payload),
    })));
    if (bytes.length > maxBytes) {
      throw const FormatException('Backup exceeds 16 MB');
    }
    return bytes;
  }

  static WorkspaceBackup decode(Uint8List bytes) {
    if (bytes.length > maxBytes) {
      throw const FormatException('Backup exceeds 16 MB');
    }
    final raw = jsonDecode(utf8.decode(bytes));
    if (raw is! Map ||
        raw['format'] != 'crispmath.backup' ||
        raw['version'] != 1 ||
        raw['state'] is! Map ||
        raw['checkpoints'] is! List ||
        raw['sha256'] !=
            _digest(
                {'state': raw['state'], 'checkpoints': raw['checkpoints']})) {
      throw const FormatException('Unsupported or damaged workspace backup');
    }
    final checkpoints =
        (raw['checkpoints'] as List).map(DocumentCheckpoint.fromJson).toList();
    if (checkpoints.length > 100 ||
        utf8.encode(jsonEncode(raw['checkpoints'])).length >
            DocumentHistory.maxBytes) {
      throw const FormatException('Checkpoint history exceeds storage limits');
    }
    return WorkspaceBackup._(
        normalize(Map<String, dynamic>.from(raw['state'])), checkpoints);
  }

  /// Construct all models before changing AppState. Retain only recognized data;
  /// never import API keys, user sessions, AI preferences or calculation caches.
  static Map<String, dynamic> normalize(Map<String, dynamic> raw) {
    final result = <String, dynamic>{'version': 1};
    try {
      for (final key in ['locale', 'numberFormat', 'themeMode']) {
        if (raw.containsKey(key)) result[key] = raw[key] as String;
      }
      if (raw.containsKey('currentNotepadDocId')) {
        result['currentNotepadDocId'] = raw['currentNotepadDocId'] as String?;
      }
      for (final key in ['highContrast', 'exactIntegerMode']) {
        if (raw.containsKey(key)) result[key] = raw[key] as bool;
      }
      if (raw.containsKey('textScale')) {
        final value = (raw['textScale'] as num).toDouble();
        if (!value.isFinite || value < .5 || value > 3) {
          throw const FormatException('Invalid text scale');
        }
        result['textScale'] = value;
      }
      if (raw.containsKey('history')) {
        final rows = raw['history'] as List;
        if (rows.length > 10000) {
          throw const FormatException('Too much history');
        }
        result['history'] = rows
            .map((r) => CalculationEntry.fromJson(Map<String, dynamic>.from(r))
                .toJson())
            .toList();
      }
      if (raw.containsKey('userFunctions')) {
        result['userFunctions'] = (raw['userFunctions'] as List)
            .map((r) =>
                UserFunction.fromJson(Map<String, dynamic>.from(r)).toJson())
            .toList();
      }
      if (raw.containsKey('variables')) {
        result['variables'] = Map<String, String>.from(raw['variables']);
      }
      if (raw.containsKey('functions')) {
        result['functions'] =
            (raw['functions'] as List).cast<String>().toList();
      }
      if (raw.containsKey('parameters')) {
        result['parameters'] = <String, dynamic>{};
        for (final entry in (raw['parameters'] as Map).entries) {
          final slot = int.parse(entry.key as String);
          if (slot < 0 || slot > 100) {
            throw const FormatException('Invalid graph slot');
          }
          final values = <String, double>{};
          for (final p in (entry.value as Map).entries) {
            final value = (p.value as num).toDouble();
            if (!value.isFinite) {
              throw const FormatException('Invalid graph parameter');
            }
            values[p.key as String] = value;
          }
          result['parameters'][entry.key] = values;
        }
      }
      if (raw.containsKey('notepadDocuments')) {
        final documents = raw['notepadDocuments'] as List;
        if (documents.length > 1000) {
          throw const FormatException('Too many worksheets');
        }
        final ids = <String>{};
        result['notepadDocuments'] = documents.map((r) {
          final doc = validateWorksheetSource(r);
          if (!ids.add(doc.id) || doc.id == kWelcomeNotepadDocId) {
            throw const FormatException('Duplicate or reserved worksheet ID');
          }
          return worksheetSource(doc);
        }).toList();
      }
      if (raw.containsKey('graphLinks')) {
        result['graphLinks'] = <String, dynamic>{};
        for (final entry in (raw['graphLinks'] as Map).entries) {
          final slot = int.parse(entry.key as String);
          if (slot < 0 || slot > 100) {
            throw const FormatException('Invalid graph slot');
          }
          result['graphLinks'][entry.key] =
              LinkedGraphSource.fromJson(Map<String, dynamic>.from(entry.value))
                  .toJson();
        }
      }
      if (raw.containsKey('scene3D')) {
        final scene =
            Scene3D.fromJson(Map<String, dynamic>.from(raw['scene3D']));
        if (scene.objects.length > 1000 ||
            scene.zoom <= 0 ||
            scene.range <= 0) {
          throw const FormatException('Invalid 3D scene size or viewport');
        }
        final data = scene.toJson();
        final pending = <Object?>[data];
        while (pending.isNotEmpty) {
          final value = pending.removeLast();
          if (value is num && !value.isFinite) {
            throw const FormatException('Non-finite 3D geometry');
          }
          if (value is Map) {
            pending.addAll(value.values);
          }
          if (value is List) {
            pending.addAll(value);
          }
        }
        result['scene3D'] = data;
      }
    } catch (error) {
      throw FormatException('Invalid workspace backup: $error');
    }
    return result;
  }

  List<NotepadDocument> get documents =>
      (state['notepadDocuments'] as List? ?? [])
          .map(validateWorksheetSource)
          .toList();

  /// Keep both versions when the same ID has different source. No clock wins.
  Map<String, dynamic> mergeDocuments(AppState local) {
    final merged = local.exportToJson();
    final docs = local.notepadDocuments.values
        .where((d) => d.id != kWelcomeNotepadDocId)
        .map(worksheetSource)
        .toList();
    String content(NotepadDocument doc) => jsonEncode({
          'lx': doc.useLatexInput,
          'l': [
            for (final row in doc.lines)
              {'s': row.source, 'rf': row.resultFormat.index, 'p': row.pinned}
          ]
        });
    final byName = <String, Set<String>>{};
    for (final doc in local.notepadDocuments.values) {
      byName.putIfAbsent(doc.name, () => {}).add(content(doc));
    }
    for (final incoming in documents) {
      final existing = local.notepadDocuments[incoming.id];
      if (existing == null) {
        docs.add(worksheetSource(incoming));
        continue;
      }
      final a = worksheetSource(existing)
        ..remove('u')
        ..remove('c');
      final b = worksheetSource(incoming)
        ..remove('u')
        ..remove('c');
      if (jsonEncode(a) == jsonEncode(b)) continue;
      final copyName =
          '${incoming.name.substring(0, incoming.name.length.clamp(0, 185))} (imported)';
      final incomingContent = content(incoming);
      if (byName[copyName]?.contains(incomingContent) == true) {
        continue;
      }
      byName.putIfAbsent(copyName, () => {}).add(incomingContent);
      final copy = NotepadDocument.fresh(name: copyName);
      copy.useLatexInput = incoming.useLatexInput;
      copy.lines.clear();
      for (final row in incoming.lines) {
        copy.lines.add(NotepadLine.fresh(source: row.source)
          ..pinned = row.pinned
          ..resultFormat = row.resultFormat);
      }
      docs.add(worksheetSource(copy));
    }
    merged['notepadDocuments'] = docs;
    return normalize(merged);
  }

  static const recoveryKey = 'crisp.workspaceRecovery';
  static Future<void> saveRecovery(AppState state) async {
    final prefs = await SharedPreferences.getInstance();
    final text =
        utf8.decode(encode(state, checkpoints: await DocumentHistory().all()));
    if (!await prefs.setString(recoveryKey, text)) {
      throw StateError('Recovery backup could not be saved');
    }
  }

  static Future<WorkspaceBackup?> recovery() async {
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString(recoveryKey);
    return text == null ? null : decode(Uint8List.fromList(utf8.encode(text)));
  }

  static Future<void> save(AppState state) async {
    final bytes = encode(state, checkpoints: await DocumentHistory().all());
    await FilePicker.saveFile(
        fileName: 'CrispMath-backup.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes);
  }

  static Future<WorkspaceBackup?> open() async {
    final picked = await FilePicker.pickFiles(
        type: FileType.custom, allowedExtensions: ['json'], withData: true);
    if (picked == null) return null;
    final file = picked.files.single;
    if (file.size > maxBytes) {
      throw const FormatException('Backup exceeds 16 MB');
    }
    return decode(file.bytes ?? await file.xFile.readAsBytes());
  }
}
