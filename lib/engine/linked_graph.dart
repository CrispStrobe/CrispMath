import 'notepad.dart';
import 'notepad_evaluator.dart';

class LinkedGraphSource {
  final String documentId;
  final String lineId;
  const LinkedGraphSource(this.documentId, this.lineId);
  Map<String, dynamic> toJson() => {'document': documentId, 'line': lineId};
  static LinkedGraphSource fromJson(Map<String, dynamic> json) =>
      LinkedGraphSource(json['document'] as String, json['line'] as String);
}

class LinkedGraphResolution {
  final String source;
  final String? expression;
  final Map<String, String> scope;
  final String? error;
  const LinkedGraphResolution(
      this.source, this.expression, this.scope, this.error);
}

LinkedGraphResolution resolveLinkedGraph(NotepadDocument? doc, String lineId,
    {Map<String, String> globals = const {}}) {
  if (doc == null) {
    return const LinkedGraphResolution(
        '', null, {}, 'Source document is missing.');
  }
  final index = doc.lines.indexWhere((l) => l.id == lineId);
  if (index < 0) {
    return const LinkedGraphResolution('', null, {}, 'Source line is missing.');
  }
  final line = doc.lines[index];
  final first = firstCodeLineIndexOf(doc);
  final parsed = classifyNotepadLine(line.source,
      lineIndex: index, firstCodeLineIndex: first);
  if (![
    NotepadLineKind.expression,
    NotepadLineKind.assignment,
    NotepadLineKind.plot
  ].contains(parsed.kind)) {
    return LinkedGraphResolution(line.source, null, {},
        'Choose an expression, assignment or plot line.');
  }
  if (line.cachedError != null) {
    return LinkedGraphResolution(
        line.source, null, {}, 'Fix the source line before plotting.');
  }
  final imports = <String, String>{};
  if (first >= 0) {
    final use = classifyNotepadLine(doc.lines[first].source,
        lineIndex: first, firstCodeLineIndex: first);
    if (use.kind == NotepadLineKind.useDirective) {
      for (final name in use.imports) {
        if (globals[name] != null) imports[name] = globals[name]!;
      }
    }
  }
  final scope = buildNotepadScope(doc, externalScope: imports);
  for (var i = index - 1; i >= 0; i--) {
    final previous = doc.lines[i];
    if (previous.cachedError == null && previous.cachedResult != null) {
      scope['Ans'] = previous.cachedResult!;
      scope['ans'] = previous.cachedResult!;
      break;
    }
  }
  scope.remove('line${index + 1}');
  if (parsed.kind == NotepadLineKind.assignment) scope.remove(parsed.name);
  for (var i = 0; i < doc.lines.length; i++) {
    final l = doc.lines[i];
    if (l.cachedError == null) continue;
    scope.remove('line${i + 1}');
    final p =
        classifyNotepadLine(l.source, lineIndex: i, firstCodeLineIndex: first);
    if (p.kind == NotepadLineKind.assignment) scope.remove(p.name);
  }
  final variable =
      parsed.kind == NotepadLineKind.plot ? parsed.name ?? 'x' : 'x';
  final body = parsed.body ?? '';
  if (body.trim().isEmpty) {
    return LinkedGraphResolution(
        line.source, null, {}, 'The source expression is empty.');
  }
  final bound = <String, String>{};
  String? missing;
  final expression =
      body.replaceAllMapped(RegExp(r'\b[A-Za-z_][A-Za-z_0-9]*\b'), (m) {
    final name = m[0]!;
    if (name == variable) return 'x';
    if (scope.containsKey(name)) {
      bound[name] = scope[name]!;
      return '(${scope[name]})';
    }
    final tail = body.substring(m.end).trimLeft();
    if (!kReservedNotepadNames.contains(name) &&
        !tail.startsWith('(') &&
        name != 'I' &&
        name != 'oo') {
      missing ??= name;
    }
    return name;
  });
  if (missing != null) {
    return LinkedGraphResolution(line.source, null, bound,
        'Define $missing in this document or import it with use.');
  }
  return LinkedGraphResolution(line.source, expression, bound, null);
}

/// Return the effective document assignment, including forward definitions.
/// Imports and automatic aliases have no editable assignment in this document.
String? linkedVariableLine(NotepadDocument? document, String variable) {
  if (document == null) return null;
  final first = firstCodeLineIndexOf(document);
  for (var i = document.lines.length - 1; i >= 0; i--) {
    final line = document.lines[i];
    final parsed = classifyNotepadLine(line.source,
        lineIndex: i, firstCodeLineIndex: first);
    if (parsed.kind == NotepadLineKind.assignment && parsed.name == variable) {
      return line.id;
    }
  }
  return null;
}
