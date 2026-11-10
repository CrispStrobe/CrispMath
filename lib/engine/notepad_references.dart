/// A same-document result reference in worksheet source. Offsets use Dart's
/// UTF-16 string indices, matching TextSelection and substring.
class ResultReferenceSpan {
  const ResultReferenceSpan({
    required this.start,
    required this.end,
    required this.lineId,
  });

  final int start;
  final int end;
  final String lineId;
}

/// Encode a persistent row identity without making it a mathematical name.
/// Encoding also keeps imported IDs containing comment markers or braces safe.
String resultReferenceToken(String lineId) {
  if (lineId.isEmpty) {
    throw const FormatException('A result reference needs a source row.');
  }
  return '@{${Uri.encodeComponent(lineId)}}';
}

/// Find complete references outside comments and quoted text. The default is
/// tolerant while the user types; evaluation uses [strict] to reject malformed
/// references instead of retaining an earlier answer.
List<ResultReferenceSpan> resultReferencesIn(String source,
    {bool strict = false}) {
  final references = <ResultReferenceSpan>[];
  var offset = 0;
  while (offset < source.length) {
    final char = source[offset];
    if (char == '#' || source.startsWith('//', offset)) {
      final newline = source.indexOf('\n', offset);
      if (newline < 0) break;
      offset = newline + 1;
      continue;
    }
    if (char == '"' || char == "'") {
      final quote = char;
      offset++;
      while (offset < source.length) {
        if (source[offset] == '\\') {
          offset += 2;
        } else if (source[offset++] == quote) {
          break;
        }
      }
      continue;
    }
    if (!source.startsWith('@{', offset)) {
      offset++;
      continue;
    }
    final end = source.indexOf('}', offset + 2);
    String? lineId;
    if (end >= 0) {
      final payload = source.substring(offset + 2, end);
      // Raw whitespace, braces and comment characters are not canonical URI
      // components. Requiring their encoded spelling avoids ambiguous source.
      if (payload.isNotEmpty &&
          RegExp(r"^(?:[A-Za-z0-9_.!~*'()-]|%[0-9A-Fa-f]{2})+$")
              .hasMatch(payload)) {
        try {
          lineId = Uri.decodeComponent(payload);
        } on FormatException {
          // The strict path below reports one consistent source error.
        } on ArgumentError {
          // URI decoding can also reject invalid percent-encoded bytes.
        }
      }
    }
    if (lineId == null || lineId.isEmpty) {
      if (strict) {
        throw const FormatException(
            'Invalid result reference. Insert a result from this document.');
      }
      offset = end < 0 ? source.length : end + 1;
      continue;
    }
    references.add(ResultReferenceSpan(
        start: offset, end: end + 1, lineId: lineId));
    offset = end + 1;
  }
  return references;
}

/// Rewrite only existing references whose targets occur in [lineIdMap].
/// Dangling references remain dangling when copying a worksheet; they must not
/// accidentally bind to another row or silently change meaning.
String remapResultReferences(String source, Map<String, String> lineIdMap) {
  final references = resultReferencesIn(source);
  if (references.isEmpty || lineIdMap.isEmpty) return source;
  final out = StringBuffer();
  var cursor = 0;
  for (final reference in references) {
    out.write(source.substring(cursor, reference.start));
    final replacement = lineIdMap[reference.lineId];
    out.write(replacement == null
        ? source.substring(reference.start, reference.end)
        : resultReferenceToken(replacement));
    cursor = reference.end;
  }
  out.write(source.substring(cursor));
  return out.toString();
}
