// lib/services/calculator_history_file.dart
//
// Portable **Calculator history** files: one file carries the calculation
// history only (not the whole workspace). This is deliberately a separate
// artifact from the whole-state JSON export in AppState.exportToJson and
// from WorksheetFile (source documents).
//
// File format (JSON, UTF-8, versioned):
//
//   {
//     "format": "crispmath.calculatorHistory",
//     "version": 1,
//     "entries": [ { "e": "8/3", "r": "2.66666666667",
//                    "raw": "2.6666666666666665",
//                    "evidence": { "accuracy": "exact",
//                                  "method": "simplification" },
//                    "t": "calculation",
//                    "lm": "2026-10-30T10:00:00.000Z" }, … ]
//   }
//
// Entry objects are exactly the `CalculationEntry.toJson()` shape, so a file
// round-trips expression, displayed result, unrounded `raw` (what `Ans` uses),
// result evidence, entry type and timestamp, in stored order (index 0 = newest,
// matching `AppState.history`).
//
// Limits and guarantees (enforced, never silently applied):
//   * at most [maxEntries] (200) entries — the AppState history cap. A larger
//     file is rejected; it is never truncated;
//   * at most [maxBytes] per file (checked before parsing);
//   * at most [maxFieldLength] UTF-16 code units per text field;
//   * `version` must be exactly [currentVersion]; other versions are rejected
//     rather than guessed at;
//   * unknown top-level fields, unknown entry fields and unknown evidence
//     fields are rejected (a typo or a partially-written file must not import);
//   * timestamps must be parseable ISO-8601 strings within 1970-2200 UTC;
//   * only known entry types and known evidence accuracy/method names are
//     accepted;
//   * [decode] is all-or-nothing: it either returns a complete, fully validated
//     list or throws [FormatException]. A caller can therefore decode first and
//     only then call `AppState.replaceHistory`, so an invalid file can never
//     leave the app with a partially imported history.
//
// Platform behaviour:
//   * [open] returns null when the user cancels the picker. A chosen but
//     invalid file throws [FormatException] — cancellation and corruption are
//     different outcomes on purpose.
//   * [save] returns the path the OS wrote the file to, or null when the user
//     cancelled **or** when running on web. On web the bytes are handed to the
//     browser as a download and no path exists, so null there means "download
//     started", not "a file was confirmed on disk". Callers must not claim a
//     saved file when this returns null.
//
// No `dart:io` import: this file compiles for web as well as native.
//
// Caller pattern (decode/open first, mutate only on success):
//
//   // Import
//   final entries = await CalculatorHistoryFile.open(); // null = cancelled
//   if (entries == null) return;                        // keep current history
//   await AppState().replaceHistory(entries);           // atomic, exact, saved
//
//   // Export
//   final path = await CalculatorHistoryFile.save(AppState().history);
//   // path == null: cancelled, or (web) a download that cannot be confirmed.

import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../engine/app_state.dart';
import '../engine/result_evidence.dart';

// JSON is emitted incrementally so even heavily escaped input cannot allocate
// an unbounded encoded body before the size check.
class _LimitedByteSink extends ByteConversionSinkBase {
  _LimitedByteSink(this.limit);

  final int limit;
  final BytesBuilder _bytes = BytesBuilder(copy: false);

  @override
  void add(List<int> chunk) {
    if (_bytes.length + chunk.length > limit) {
      throw ArgumentError('Cannot write history file: '
          '${CalculatorHistoryFile._sizeLimitMessage}');
    }
    _bytes.add(chunk);
  }

  @override
  void close() {}

  Uint8List takeBytes() => _bytes.takeBytes();
}

class CalculatorHistoryFile {
  CalculatorHistoryFile._();

  /// Discriminator stored in the file; must match exactly on import.
  static const formatId = 'crispmath.calculatorHistory';

  /// Only version this build reads or writes.
  static const currentVersion = 1;

  /// Mirrors `AppState.historyCap`; larger histories are never truncated.
  static const maxEntries = 200;

  /// Largest history file accepted. Checked before any parsing.
  static const maxBytes = 4 * 1024 * 1024;

  /// Largest accepted field in UTF-16 code units (expression, result, raw,
  /// sourceDomain). Large enough for exact results such as 1000!, while the
  /// separate byte limit also bounds the total encoded file.
  static const maxFieldLength = 64 * 1024;

  /// File extension used by [save] / [open].
  static const extension = 'crisphistory';

  static const _payloadKeys = {'format', 'version', 'entries'};
  static const _entryKeys = {'e', 'r', 'raw', 'evidence', 't', 'lm'};
  static const _evidenceKeys = {'accuracy', 'method', 'unchanged', 'sourceDomain'};

  static const _minTimestampYear = 1970;
  static const _maxTimestampYear = 2200;

  static const _sizeLimitMessage =
      'History file exceeds the ${maxBytes ~/ (1024 * 1024)} MB limit';

  // ---------------------------------------------------------------------------
  // In-memory codec
  // ---------------------------------------------------------------------------

  /// Serialize [entries] to the versioned UTF-8 file body.
  ///
  /// Throws [ArgumentError] when the list cannot be represented faithfully,
  /// including if it exceeds [maxEntries], [maxFieldLength] or [maxBytes].
  /// Encoding never truncates, because the resulting file must always decode.
  static Uint8List encode(List<CalculationEntry> entries) {
    if (entries.length > maxEntries) {
      throw ArgumentError.value(
        entries.length,
        'entries',
        'History is capped at $maxEntries entries; refusing to write a '
            'truncated file',
      );
    }
    final payload = <String, dynamic>{
      'format': formatId,
      'version': currentVersion,
      'entries': [for (final entry in entries) entry.toJson()],
    };
    try {
      _validate(payload);
    } on FormatException catch (error) {
      throw ArgumentError('Cannot write history file: ${error.message}');
    }
    final output = _LimitedByteSink(maxBytes);
    final encoder = JsonUtf8Encoder('  ').startChunkedConversion(output);
    encoder.add(payload);
    encoder.close();
    return output.takeBytes();
  }

  /// Parse and fully validate a history file.
  ///
  /// Throws [FormatException] — with the offending entry index where useful —
  /// for an oversized file, invalid UTF-8/JSON, an unsupported format or
  /// version, more than [maxEntries] entries, a malformed/mistyped field, an
  /// unparseable or out-of-range timestamp, or invalid result evidence.
  /// Nothing is returned unless the whole file is valid.
  static List<CalculationEntry> decode(Uint8List bytes) {
    if (bytes.length > maxBytes) {
      throw const FormatException(_sizeLimitMessage);
    }
    final Object? payload;
    try {
      payload = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      throw const FormatException(
        'History file is not valid UTF-8 JSON',
      );
    }
    return _validate(payload);
  }

  static List<CalculationEntry> _validate(Object? payload) {
    if (payload is! Map) {
      throw const FormatException('Not a CrispMath history file');
    }
    if (payload['format'] != formatId) {
      throw const FormatException(
        'Unsupported file: expected a $formatId document',
      );
    }
    final version = payload['version'];
    if (version is! int || version != currentVersion) {
      throw FormatException(
        'Unsupported history file version: ${version ?? 'missing'} '
        '(supported: $currentVersion)',
      );
    }
    final unknownKeys = payload.keys
        .where((key) => key is! String || !_payloadKeys.contains(key))
        .toList();
    if (unknownKeys.isNotEmpty) {
      throw FormatException(
        'Unexpected field(s) in history file: ${unknownKeys.join(', ')}',
      );
    }
    final rawEntries = payload['entries'];
    if (rawEntries is! List) {
      throw const FormatException('History file has no entry list');
    }
    if (rawEntries.length > maxEntries) {
      throw FormatException(
        'History file has ${rawEntries.length} entries; the limit is '
        '$maxEntries. The import was refused — nothing was truncated',
      );
    }
    final entries = <CalculationEntry>[];
    for (var index = 0; index < rawEntries.length; index++) {
      entries.add(_entryFromJson(rawEntries[index], index));
    }
    return entries;
  }

  static CalculationEntry _entryFromJson(Object? raw, int index) {
    if (raw is! Map) {
      throw FormatException('History entry $index: expected an object');
    }
    final unknownKeys = raw.keys
        .where((key) => key is! String || !_entryKeys.contains(key))
        .toList();
    if (unknownKeys.isNotEmpty) {
      throw FormatException(
        'History entry $index: unexpected field(s): ${unknownKeys.join(', ')}',
      );
    }
    final rawResult = raw['raw'];
    final rawEvidence = raw['evidence'];
    final typeName = _text(raw['t'], index, 't');
    final type = HistoryEntryType.values
        .where((candidate) => candidate.name == typeName)
        .firstOrNull;
    if (type == null) {
      throw FormatException(
        'History entry $index: unknown entry type "$typeName"',
      );
    }
    return CalculationEntry(
      expression: _text(raw['e'], index, 'e'),
      result: _text(raw['r'], index, 'r'),
      rawResult:
          rawResult == null ? null : _text(rawResult, index, 'raw'),
      resultEvidence:
          rawEvidence == null ? null : _evidence(rawEvidence, index),
      type: type,
      lastModified: _timestamp(raw['lm'], index),
    );
  }

  static String _text(Object? value, int index, String field) {
    if (value is! String) {
      throw FormatException('History entry $index: "$field" must be text');
    }
    if (value.length > maxFieldLength) {
      throw FormatException(
        'History entry $index: "$field" exceeds $maxFieldLength UTF-16 code units',
      );
    }
    return value;
  }

  static DateTime _timestamp(Object? value, int index) {
    if (value is! String) {
      throw FormatException(
        'History entry $index: "lm" must be an ISO-8601 timestamp',
      );
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw FormatException(
        'History entry $index: "lm" is not a valid ISO-8601 timestamp',
      );
    }
    if (parsed.year < _minTimestampYear || parsed.year > _maxTimestampYear) {
      throw FormatException(
        'History entry $index: timestamp year ${parsed.year} is outside '
        '$_minTimestampYear-$_maxTimestampYear',
      );
    }
    return parsed;
  }

  static ResultEvidence _evidence(Object? value, int index) {
    if (value is! Map) {
      throw FormatException(
        'History entry $index: "evidence" must be an object',
      );
    }
    final unknownKeys = value.keys
        .where((key) => key is! String || !_evidenceKeys.contains(key))
        .toList();
    if (unknownKeys.isNotEmpty) {
      throw FormatException(
        'History entry $index: unexpected evidence field(s): '
        '${unknownKeys.join(', ')}',
      );
    }
    final unchanged = value['unchanged'];
    if (unchanged != null && unchanged is! bool) {
      throw FormatException(
        'History entry $index: evidence "unchanged" must be a boolean',
      );
    }
    final sourceDomain = value['sourceDomain'];
    if (sourceDomain != null) _text(sourceDomain, index, 'sourceDomain');
    final evidence = ResultEvidence.fromJson(value);
    if (evidence == null) {
      throw FormatException(
        'History entry $index: evidence has an unknown accuracy or method',
      );
    }
    return evidence;
  }

  // ---------------------------------------------------------------------------
  // File picker
  // ---------------------------------------------------------------------------

  /// Suggested file name: `calculation-history-YYYY-MM-DD.crisphistory`.
  static String fileName([DateTime? now]) {
    final date = (now ?? DateTime.now()).toUtc();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return 'calculation-history-${date.year}-$month-$day.$extension';
  }

  /// Ask the user where to write [entries] and write the history file.
  ///
  /// Returns the path written on native platforms, or null when the user
  /// cancelled. **On web this always returns null**: the browser downloads the
  /// bytes and no path is reported, so null there means "a download may have
  /// started", never "a file was saved". Callers must treat null as
  /// "not confirmed saved".
  ///
  /// Throws [ArgumentError] if [entries] cannot be encoded (see [encode]).
  static Future<String?> save(List<CalculationEntry> entries) async {
    final bytes = encode(entries);
    final path = await FilePicker.saveFile(
      dialogTitle: 'Save calculation history',
      fileName: fileName(),
      type: FileType.custom,
      allowedExtensions: [extension],
      bytes: bytes,
    );
    if (kIsWeb) return null;
    return path;
  }

  /// Ask the user for a history file and return its entries.
  ///
  /// Returns null when the user cancels the picker. Throws [FormatException]
  /// for an oversized, malformed or unsupported file — callers must not apply
  /// anything in that case, because the current history is untouched.
  static Future<List<CalculationEntry>?> open() async {
    final result = await FilePicker.pickFiles(
      dialogTitle: 'Open calculation history',
      type: FileType.custom,
      allowedExtensions: [extension, 'json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.single;
    if (file.size > maxBytes) {
      throw const FormatException(_sizeLimitMessage);
    }
    final bytes = file.bytes ?? await file.xFile.readAsBytes();
    return decode(bytes);
  }
}
