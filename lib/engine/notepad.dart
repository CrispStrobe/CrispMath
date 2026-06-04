// lib/engine/notepad.dart
//
// Data model for the Notepad / document mode (P5 strategic next).
// Persisted as JSON inside AppState's shared_preferences blob.
//
// One AppState owns many NotepadDocuments. Each document owns an
// ordered list of NotepadLines. Per-line cached values (result,
// error, free-variable tag) are populated by the notepad evaluator
// (Phase 3) and survive reloads so re-opening a doc shows the last
// known results without an immediate re-eval.

import 'dart:math';

/// Per-line result display format. `auto` defers to the global
/// `AppState.numberFormat`; the others override it for this line only.
enum LineResultFormat {
  auto,
  decimal,
  fraction,
  scientific,
  hex,
  binary,
}

/// Format a numeric result string according to a [LineResultFormat].
/// Returns null if the format doesn't apply (non-numeric result, or
/// the value can't be represented in the target format).
String? formatLineResult(String result, LineResultFormat format) {
  if (format == LineResultFormat.auto) return null; // Use global format.
  final trimmed = result.trim();
  final d = double.tryParse(trimmed);
  if (d == null || !d.isFinite) return null;

  switch (format) {
    case LineResultFormat.auto:
      return null;
    case LineResultFormat.decimal:
      // Full decimal, no scientific notation.
      if (d == d.roundToDouble() && d.abs() < 1e15) {
        return d.toInt().toString();
      }
      return d
          .toStringAsFixed(10)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    case LineResultFormat.fraction:
      // Approximate as p/q using continued-fraction convergents.
      return _toFraction(d);
    case LineResultFormat.scientific:
      return d.toStringAsExponential(6);
    case LineResultFormat.hex:
      if (d == d.roundToDouble() && d.abs() < 1e15) {
        final i = d.toInt();
        return i < 0
            ? '-0x${(-i).toRadixString(16)}'
            : '0x${i.toRadixString(16)}';
      }
      return null; // Can't hex-format non-integers.
    case LineResultFormat.binary:
      if (d == d.roundToDouble() && d.abs() < 1e15) {
        final i = d.toInt();
        return i < 0
            ? '-0b${(-i).toRadixString(2)}'
            : '0b${i.toRadixString(2)}';
      }
      return null;
  }
}

/// Approximate a double as a fraction p/q using the continued-fraction
/// algorithm. Returns `p/q` or the integer if denominator is 1.
String _toFraction(double x) {
  if (x == x.roundToDouble() && x.abs() < 1e15) return x.toInt().toString();

  final negative = x < 0;
  var v = x.abs();
  int p0 = 0, q0 = 1, p1 = 1, q1 = 0;

  for (var i = 0; i < 30; i++) {
    final a = v.floor();
    final p2 = a * p1 + p0;
    final q2 = a * q1 + q0;
    if (q2 > 1000000) break; // Denominator too large — stop.
    p0 = p1;
    q0 = q1;
    p1 = p2;
    q1 = q2;
    final remainder = v - a;
    if (remainder < 1e-10) break;
    v = 1 / remainder;
  }

  if (q1 == 0) return x.toString();
  final sign = negative ? '-' : '';
  return q1 == 1 ? '$sign$p1' : '$sign$p1/$q1';
}

/// Stable id assigned to the built-in Welcome sample document. Lets
/// the seed-on-first-launch logic and the "Open Welcome sample"
/// overflow-menu action both refer to the same document without
/// double-creating it.
const String kWelcomeNotepadDocId = '__welcome__';

class NotepadDocument {
  final String id;
  String name;
  final DateTime createdAt;
  DateTime updatedAt;
  final List<NotepadLine> lines;

  /// Notepad V2: when true, input fields render inline LaTeX via
  /// `LatexController` instead of plain monospace text. Persisted
  /// per-document so the user can toggle per doc.
  bool useLatexInput;

  NotepadDocument({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.lines,
    this.useLatexInput = false,
  });

  /// Mint a fresh document with a generated id, current timestamps,
  /// and a single empty line. Used by the "+ New document" action
  /// and the first-launch `Untitled` seed.
  factory NotepadDocument.fresh({required String name}) {
    final now = DateTime.now().toUtc();
    return NotepadDocument(
      id: generateNotepadId(),
      name: name,
      createdAt: now,
      updatedAt: now,
      lines: [NotepadLine.fresh(source: '')],
    );
  }

  Map<String, dynamic> toJson() => {
        'i': id,
        'n': name,
        'c': createdAt.toIso8601String(),
        'u': updatedAt.toIso8601String(),
        'l': lines.map((l) => l.toJson()).toList(),
        if (useLatexInput) 'lx': true,
      };

  static NotepadDocument fromJson(Map<String, dynamic> j) {
    final nowFallback = DateTime.now().toUtc();
    return NotepadDocument(
      id: (j['i'] as String?) ?? generateNotepadId(),
      name: (j['n'] as String?) ?? 'Untitled',
      createdAt: _parseIso(j['c']) ?? nowFallback,
      updatedAt: _parseIso(j['u']) ?? nowFallback,
      lines: (j['l'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((raw) => NotepadLine.fromJson(Map<String, dynamic>.from(raw)))
          .toList(),
      useLatexInput: j['lx'] == true,
    );
  }
}

class NotepadLine {
  final String id;
  String source;

  /// Last engine result for this line's source. Cleared on edit and
  /// repopulated when evaluation finishes (Phase 5).
  String? cachedResult;

  /// Last engine error (raw, formatter-ready). Mutually exclusive
  /// with [cachedResult] in steady state.
  String? cachedError;

  /// Identifiers in the line's source that didn't resolve in the
  /// document's scope at evaluation time. Surfaced by the UI as the
  /// `free: x, y` tag (decision #15). List, not Set, for JSON.
  List<String> cachedFreeVars;

  /// Names this line contributes to the document scope beyond its
  /// auto-alias (`lineN`) and assignment LHS. Currently populated
  /// only by `fzn:` lines (Round E.4): each scalar output_var from
  /// the FlatZinc solution lands here, so downstream lines can
  /// reference the solved values by their FlatZinc names.
  Map<String, String> cachedExports;

  /// Per-line result display format override (Notepad V2).
  /// `auto` defers to the global number-format setting.
  LineResultFormat resultFormat;

  /// Notepad V2 Tier C: pinned lines stick to the top of the viewport.
  bool pinned;

  NotepadLine({
    required this.id,
    required this.source,
    this.cachedResult,
    this.cachedError,
    List<String>? cachedFreeVars,
    Map<String, String>? cachedExports,
    this.resultFormat = LineResultFormat.auto,
    this.pinned = false,
  })  : cachedFreeVars = cachedFreeVars ?? <String>[],
        cachedExports = cachedExports ?? <String, String>{};

  factory NotepadLine.fresh({required String source}) => NotepadLine(
        id: generateNotepadId(),
        source: source,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'i': id,
      's': source,
    };
    if (cachedResult != null) map['r'] = cachedResult;
    if (cachedError != null) map['e'] = cachedError;
    if (cachedFreeVars.isNotEmpty) map['f'] = cachedFreeVars;
    if (cachedExports.isNotEmpty) map['x'] = cachedExports;
    if (resultFormat != LineResultFormat.auto) {
      map['rf'] = resultFormat.index;
    }
    if (pinned) map['p'] = true;
    return map;
  }

  static NotepadLine fromJson(Map<String, dynamic> j) => NotepadLine(
        id: (j['i'] as String?) ?? generateNotepadId(),
        source: (j['s'] as String?) ?? '',
        cachedResult: j['r'] as String?,
        cachedError: j['e'] as String?,
        cachedFreeVars: (j['f'] as List<dynamic>? ?? const [])
            .map((v) => v.toString())
            .toList(),
        cachedExports: (j['x'] is Map)
            ? Map<String, String>.from(
                (j['x'] as Map)
                    .map((k, v) => MapEntry(k.toString(), v.toString())),
              )
            : <String, String>{},
        resultFormat: _parseResultFormat(j['rf']),
        pinned: j['p'] == true,
      );

  static LineResultFormat _parseResultFormat(dynamic v) {
    if (v is int && v >= 0 && v < LineResultFormat.values.length) {
      return LineResultFormat.values[v];
    }
    return LineResultFormat.auto;
  }
}

DateTime? _parseIso(dynamic v) {
  if (v is! String) return null;
  return DateTime.tryParse(v);
}

final Random _rng = Random.secure();

/// Timestamp-prefixed identifier with an 8-hex random suffix.
/// Globally unique enough for a single-user local document store;
/// cheap, no dependency. Exposed (not private) so test code can
/// validate the format / inject fakes if needed.
String generateNotepadId() {
  final ts = DateTime.now().toUtc().microsecondsSinceEpoch.toRadixString(36);
  final suffix = _rng.nextInt(0x100000000).toRadixString(16).padLeft(8, '0');
  return '${ts}_$suffix';
}

/// The static "Welcome" sample doc — always reachable from the
/// AppBar overflow menu, seeded on first launch alongside an empty
/// `Untitled`. Recreated from this constant if the user deletes it
/// and then re-opens via the menu (decision #7).
///
/// The doc name and comment lines are localized via the [locale]
/// parameter (BCP-47 language tag prefix, e.g. 'en', 'de', 'fr',
/// 'es'). Math expressions are universal and unchanged.
NotepadDocument buildWelcomeNotepadDocument({String locale = 'en'}) {
  final now = DateTime.now().toUtc();

  final String name;
  final String comment1;
  final String comment2;

  switch (locale) {
    case 'de':
      name = 'Willkommen';
      comment1 =
          '// Willkommen — bearbeiten Sie eine Zeile und die Ergebnisse aktualisieren sich rechts';
      comment2 =
          '// Ändern Sie oben den Steuersatz und beobachten Sie die Aktualisierung';
    case 'fr':
      name = 'Bienvenue';
      comment1 =
          '// Bienvenue — modifiez une ligne et les résultats se mettent à jour à droite';
      comment2 =
          '// Changez le taux ci-dessus et observez la mise à jour du total';
    case 'es':
      name = 'Bienvenida';
      comment1 =
          '// Bienvenida — edita cualquier línea y los resultados se actualizan a la derecha';
      comment2 =
          '// Cambia el impuesto de arriba y observa cómo se actualiza el total';
    default:
      name = 'Welcome';
      comment1 = '// Welcome — edit any line and results update on the right';
      comment2 = '// Change tax above and watch the total update';
  }

  return NotepadDocument(
    id: kWelcomeNotepadDocId,
    name: name,
    createdAt: now,
    updatedAt: now,
    lines: [
      NotepadLine.fresh(source: comment1),
      NotepadLine.fresh(source: 'tax = 0.085'),
      NotepadLine.fresh(source: '142.50 * (1 + tax)'),
      NotepadLine.fresh(source: '5 km + 3000 m'),
      NotepadLine.fresh(source: 'Ans in miles'),
      NotepadLine.fresh(source: comment2),
    ],
  );
}
