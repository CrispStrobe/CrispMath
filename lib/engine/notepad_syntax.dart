part of 'notepad_evaluator.dart';

/// Reuses classification while observing source edits during asynchronous runs.
/// Each entry is keyed by position, source and first-code position so directive
/// changes and document edits invalidate the relevant classification.
class NotepadLineParseCache {
  final _entries =
      <int, ({String source, int firstCode, ParsedNotepadLine parsed})>{};
  ParsedNotepadLine parse(String source,
      {required int lineIndex, required int firstCodeLineIndex}) {
    final entry = _entries[lineIndex];
    if (entry != null &&
        entry.source == source &&
        entry.firstCode == firstCodeLineIndex) {
      return entry.parsed;
    }
    final parsed = classifyNotepadLine(source,
        lineIndex: lineIndex, firstCodeLineIndex: firstCodeLineIndex);
    _entries[lineIndex] =
        (source: source, firstCode: firstCodeLineIndex, parsed: parsed);
    return parsed;
  }
}

// Consume numbers before looking for names: the e/E in a scientific literal
// belongs to that number, including decimal mantissas and signed exponents.
const _notepadNumberToken = r'(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?';
final _scopeIdentifierRegex = RegExp('$_notepadNumberToken|'
    r'(?<![A-Za-z0-9_])[A-Za-z_][A-Za-z0-9_]*(?![A-Za-z0-9_])');
final _scalarScopeValue = RegExp(r'^[+-]?\d+(?:\.\d+)?$');

/// Incremental bindings only for documents with unambiguous numeric ownership.
/// Checks source, identity and cached values between rows, so external edits
/// disable the index rather than allowing it to serve stale bindings.
class _NumericScopeIndex {
  _NumericScopeIndex(
      NotepadDocument doc, Map<String, String> externalScope, this.names)
      : lines = List.of(doc.lines),
        sources = doc.lines.map((line) => line.source).toList(),
        results = doc.lines.map((line) => line.cachedResult).toList(),
        external = Map.of(externalScope),
        scope = buildNotepadScope(doc, externalScope: externalScope),
        revision = doc.scopeRevision;

  int revision;
  final List<NotepadLine> lines;
  final List<String> sources;
  final List<String?> results;
  final List<String?> names;
  final Map<String, String> external;
  final Map<String, String> scope;

  static _NumericScopeIndex? tryCreate(
      NotepadDocument doc, Map<String, String> external) {
    if (external.values.any((value) => !_scalarScopeValue.hasMatch(value))) {
      return null;
    }
    final names = <String?>[];
    final seen = <String>{};
    final firstCode = firstCodeLineIndexOf(doc);
    for (var i = 0; i < doc.lines.length; i++) {
      final line = doc.lines[i];
      final parsed = classifyNotepadLine(line.source,
          lineIndex: i, firstCodeLineIndex: firstCode);
      if (parsed.isFunction ||
          parsed.kind == NotepadLineKind.flatzinc ||
          parsed.kind == NotepadLineKind.plot ||
          (line.cachedResult != null &&
              !_scalarScopeValue.hasMatch(line.cachedResult!))) {
        return null;
      }
      final name =
          parsed.kind == NotepadLineKind.assignment ? parsed.name : null;
      if (name != null &&
          (!seen.add(name) || RegExp(r'^line\d+$').hasMatch(name))) {
        return null;
      }
      names.add(name);
    }
    return _NumericScopeIndex(doc, external, names);
  }

  bool matches(NotepadDocument doc, Map<String, String> externalScope) {
    if (doc.lines.length != lines.length ||
        externalScope.length != external.length) {
      return false;
    }
    if (doc.scopeRevision != revision) return false;
    for (final entry in external.entries) {
      if (externalScope[entry.key] != entry.value) return false;
    }
    return true;
  }

  bool recordResult(
      NotepadDocument doc, int index, Map<String, String> externalScope) {
    if (doc.lines.length != lines.length ||
        !identical(doc.lines[index], lines[index])) {
      return false;
    }
    final result = doc.lines[index].cachedResult;
    final ownChanges = result == results[index] ? 0 : 1;
    if (doc.scopeRevision != revision + ownChanges) return false;
    revision = doc.scopeRevision;
    results[index] = result;
    if (!matches(doc, externalScope) ||
        (result != null && !_scalarScopeValue.hasMatch(result))) {
      return false;
    }
    void update(String key) {
      final value = result ?? external[key];
      if (value == null) {
        scope.remove(key);
      } else {
        scope[key] = value;
      }
    }

    // Non-code rows never contribute an alias to buildNotepadScope.
    final parsed = classifyNotepadLine(sources[index],
        lineIndex: index, firstCodeLineIndex: firstCodeLineIndexOf(doc));
    if (parsed.kind != NotepadLineKind.blank &&
        parsed.kind != NotepadLineKind.comment &&
        parsed.kind != NotepadLineKind.useDirective) {
      update('line${index + 1}');
    }
    final name = names[index];
    if (name != null) update(name);
    return true;
  }
}

final _ansPattern = RegExp(r'(?<![A-Za-z0-9_])Ans(?![A-Za-z0-9_])');
final _dividerRegex = RegExp(r'^-{3,}\s*$');
final _trailingZeros = RegExp(r'0+$');
final _trailingDot = RegExp(r'\.$');

/// Kind of a single notepad line, surfaced to Phase 3 so the
/// dependency walker knows how to treat it.
enum NotepadLineKind {
  /// Empty / whitespace-only.
  blank,

  /// `//` or `#` to EOL — entire line was a comment.
  comment,

  /// `use name1, name2, ...` directive — only valid as the first
  /// non-blank, non-comment line of the document (decision #20).
  useDirective,

  /// `<name> = <expr>` with LHS matching a single identifier that
  /// isn't a reserved CAS keyword (decision #14).
  assignment,

  /// `fzn: <FlatZinc source>` — the body (possibly multi-line via
  /// the textarea's `maxLines: null`) is sent to dart_csp's
  /// FlatZinc frontend. Round E.4 inline directive variant.
  flatzinc,

  /// Aggregate keyword — `total`, `subtotal`, `average`, `count`.
  /// Resolved by the evaluator without an engine call by scanning
  /// the cached results of preceding lines.
  aggregate,

  /// Section heading — line starts with `## `. Rendered as styled
  /// text; no engine dispatch, no result, no scope contribution.
  heading,

  /// Horizontal divider — line is exactly `---` (3+ hyphens).
  /// Rendered as a visual separator; same semantics as heading.
  divider,

  /// Inline plot — `plot(expr)` or `plot(expr, var, lo, hi)`.
  /// Rendered as a compact chart widget instead of a text result.
  plot,

  /// Anything else — passed verbatim to the engine.
  expression,
}

/// Parse-once result for a line.
class ParsedNotepadLine {
  final NotepadLineKind kind;

  /// For `assignment`: the LHS identifier (case-sensitive).
  final String? name;

  /// Lexical parameters; null denotes an ordinary scalar assignment.
  final List<String>? parameters;
  bool get isFunction => parameters != null;

  /// For `assignment` and `expression`: the post-comment-strip
  /// body. `null` for blank, comment, and useDirective.
  final String? body;

  /// For `useDirective`: deduped, non-empty identifier list.
  final List<String> imports;

  /// For `useDirective`: structured error code if the directive
  /// is malformed (e.g. an invalid identifier in the import list,
  /// or an empty list). Phase 6 maps this to an
  /// `AppLocalizations` string.
  final String? directiveError;

  const ParsedNotepadLine._({
    required this.kind,
    this.name,
    this.parameters,
    this.body,
    this.imports = const [],
    this.directiveError,
  });

  factory ParsedNotepadLine.blank() =>
      const ParsedNotepadLine._(kind: NotepadLineKind.blank);

  factory ParsedNotepadLine.comment() =>
      const ParsedNotepadLine._(kind: NotepadLineKind.comment);

  factory ParsedNotepadLine.useDirective(List<String> imports,
          {String? error}) =>
      ParsedNotepadLine._(
        kind: NotepadLineKind.useDirective,
        imports: imports,
        directiveError: error,
      );

  factory ParsedNotepadLine.assignment(String name, String body,
          {List<String>? parameters}) =>
      ParsedNotepadLine._(
        kind: NotepadLineKind.assignment,
        parameters: parameters,
        name: name,
        body: body,
      );

  factory ParsedNotepadLine.flatzinc(String body) => ParsedNotepadLine._(
        kind: NotepadLineKind.flatzinc,
        body: body,
      );

  factory ParsedNotepadLine.aggregate(String aggregateKind) =>
      ParsedNotepadLine._(
        kind: NotepadLineKind.aggregate,
        name: aggregateKind,
      );

  factory ParsedNotepadLine.heading(String text) => ParsedNotepadLine._(
        kind: NotepadLineKind.heading,
        body: text,
      );

  factory ParsedNotepadLine.divider() =>
      const ParsedNotepadLine._(kind: NotepadLineKind.divider);

  /// [body] carries the expression; [name] carries the variable
  /// (default 'x'); [imports] carries [lo, hi] as strings.
  factory ParsedNotepadLine.plot({
    required String expression,
    String variable = 'x',
    String lo = '-10',
    String hi = '10',
  }) =>
      ParsedNotepadLine._(
        kind: NotepadLineKind.plot,
        body: expression,
        name: variable,
        imports: [lo, hi],
      );

  factory ParsedNotepadLine.expression(String body) => ParsedNotepadLine._(
        kind: NotepadLineKind.expression,
        body: body,
      );
}

/// Builtin / CAS-reserved identifiers that can't be reused as an
/// assignment LHS. Deliberately a superset — a false positive just
/// forces the user to pick a less-collision-y name; a false
/// negative would let them shadow a CAS function.
const Set<String> kReservedNotepadNames = {
  // Magic / notepad
  'Ans', 'ans', 'use', 'line',
  // Trig + inverse + hyperbolic
  'sin', 'cos', 'tan', 'asin', 'acos', 'atan', 'atan2',
  'sinh', 'cosh', 'tanh', 'asinh', 'acosh', 'atanh',
  // Logs & exp
  'exp', 'log', 'ln', 'log10', 'log2',
  // Roots, abs, rounding
  'sqrt', 'cbrt', 'abs', 'floor', 'ceil', 'ceiling', 'round', 'sign',
  // Complex conjugation is a builtin, not an unresolved worksheet symbol.
  'conjugate',
  // Number theory
  'gcd', 'lcm', 'factorial', 'fibonacci', 'isprime', 'nextprime',
  'prevprime', 'factorint', 'divisors', 'totient', 'modinv', 'modpow',
  'jacobi', 'factor', 'prime',
  // Precision arc Group B — continued fractions + polynomial arithmetic
  'cfrac', 'convergent', 'polygcd', 'polydiv', 'polyresultant',
  'polydiscriminant', 'polyfactor',
  // Special functions (SymEngine + MPFR, via basic_evalf)
  'zeta', 'erf', 'erfc', 'loggamma', 'lambertw', 'dirichlet_eta',
  'beta', 'lowergamma', 'uppergamma', 'polygamma',
  // Calculus / CAS ops
  'integrate', 'diff', 'limit', 'solve', 'expand', 'simplify', 'subst',
  'series', 'taylor', 'linsolve', 'eigenvalues', 'eigenvectors',
  'besselj', 'bessely', 'plot',
  // Matrix / linear algebra
  'Matrix', 'det', 'inv', 'transpose', 'rref',
  // Constants (commonly typed)
  'pi', 'Pi', 'PI', 'e', 'E', 'I', 'inf', 'oo', 'euler', 'EulerGamma', 'gamma',
  // Stats-ish
  'min', 'max', 'mean', 'median', 'sum', 'mod',
  // Notepad aggregates
  'total', 'subtotal', 'average', 'count',
};

/// Classify a single line.
///
/// [lineIndex] — position of this line in the document (0-based).
/// [firstCodeLineIndex] — index of the first non-blank, non-comment
/// line in the doc (-1 if the doc has no code lines). A `use` line
/// is only legal when `lineIndex == firstCodeLineIndex`; everywhere
/// else, `use ...` is reclassified as an expression so the engine
/// surfaces a single, consistent "name `use` not defined" error.
ParsedNotepadLine classifyNotepadLine(
  String source, {
  required int lineIndex,
  required int firstCodeLineIndex,
}) {
  if (source.trim().isEmpty) {
    return ParsedNotepadLine.blank();
  }
  // Section headings (`## text`) and dividers (`---`). Checked before
  // comment stripping because `#` is a comment marker and `## heading`
  // would otherwise be stripped to empty.
  final trimmed = source.trim();
  if (trimmed.startsWith('## ')) {
    return ParsedNotepadLine.heading(trimmed.substring(3).trim());
  }
  if (_dividerRegex.hasMatch(trimmed)) {
    return ParsedNotepadLine.divider();
  }

  // Inline plot: `plot(expr)` or `plot(expr, var, lo, hi)`.
  final plotMatch = _plotRegex.firstMatch(trimmed);
  if (plotMatch != null) {
    final args = plotMatch.group(1)!;
    final parts = _splitTopLevelCommas(args);
    if (parts.length == 1) {
      return ParsedNotepadLine.plot(expression: parts[0].trim());
    } else if (parts.length == 4) {
      return ParsedNotepadLine.plot(
        expression: parts[0].trim(),
        variable: parts[1].trim(),
        lo: parts[2].trim(),
        hi: parts[3].trim(),
      );
    }
    // Wrong arg count — fall through to expression so the engine errors.
  }

  // FlatZinc detection runs BEFORE comment stripping because the
  // body may contain `//` inside string literals or as part of a
  // future spec extension; FlatZinc itself uses `%` for comments,
  // so leaving the body verbatim is safe for the dart_csp parser.
  final fznMatch = _flatzincDirectiveRegex.firstMatch(source);
  if (fznMatch != null) {
    final body = fznMatch.group(1) ?? '';
    return ParsedNotepadLine.flatzinc(body);
  }
  final stripped = _stripComment(source).trim();
  if (stripped.isEmpty) {
    // Entire line was a comment.
    return ParsedNotepadLine.comment();
  }

  final useMatch = _useDirectiveRegex.firstMatch(stripped);
  if (useMatch != null) {
    if (lineIndex != firstCodeLineIndex) {
      return ParsedNotepadLine.expression(stripped);
    }
    final raw = useMatch.group(1)!.trimLeft();
    // Quick sanity: the import list must start with an
    // identifier-ish char (letter / digit / underscore) or a comma
    // (which signals an attempted-but-empty import). Anything else
    // (`= 5`, `+ 5`, `(foo)`) means the user didn't intend a use
    // directive, so fall through to expression.
    if (raw.isEmpty || !_importListStartRegex.hasMatch(raw[0])) {
      return ParsedNotepadLine.expression(stripped);
    }
    final names = <String>[];
    for (final part in raw.split(',')) {
      final n = part.trim();
      if (n.isEmpty) continue;
      if (!_identifierRegex.hasMatch(n)) {
        return ParsedNotepadLine.useDirective(
          names,
          error: 'invalidImport:$n',
        );
      }
      if (!names.contains(n)) names.add(n);
    }
    if (names.isEmpty) {
      return ParsedNotepadLine.useDirective(names, error: 'emptyImportList');
    }
    return ParsedNotepadLine.useDirective(names);
  }

  // Aggregate keywords — `total`, `subtotal`, `average`, `count`.
  // Recognized as bare keywords (the entire post-comment-strip line
  // is exactly the keyword, case-insensitive).
  final lowerStripped = stripped.toLowerCase();
  if (lowerStripped == 'total' ||
      lowerStripped == 'subtotal' ||
      lowerStripped == 'average' ||
      lowerStripped == 'count') {
    return ParsedNotepadLine.aggregate(lowerStripped);
  }

  final function =
      RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s*\(([^()]*)\)\s*=(?!=)\s*(.+)$')
          .firstMatch(stripped);
  if (function != null && !kReservedNotepadNames.contains(function[1])) {
    final parameters = function[2]!.trim().isEmpty
        ? <String>[]
        : function[2]!.split(',').map((p) => p.trim()).toList();
    if (parameters.toSet().length == parameters.length &&
        parameters.every((p) =>
            RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(p) &&
            !kReservedNotepadNames.contains(p))) {
      return ParsedNotepadLine.assignment(function[1]!, function[3]!.trim(),
          parameters: List.unmodifiable(parameters));
    }
  }
  final asgMatch = _assignmentRegex.firstMatch(stripped);
  if (asgMatch != null) {
    final name = asgMatch.group(1)!;
    final body = asgMatch.group(2)!.trim();
    if (!kReservedNotepadNames.contains(name) && body.isNotEmpty) {
      return ParsedNotepadLine.assignment(name, body);
    }
    // Reserved LHS or empty body — fall through to expression. The
    // engine will then complain about `Ans = 5` etc. with a clear
    // error rather than us silently shadowing a builtin.
  }

  return ParsedNotepadLine.expression(stripped);
}

/// Index of the first non-blank, non-comment line in [doc]. Returns
/// -1 if the doc is entirely empty / comments.
int firstCodeLineIndexOf(NotepadDocument doc) {
  for (var i = 0; i < doc.lines.length; i++) {
    final stripped = _stripComment(doc.lines[i].source).trim();
    if (stripped.isNotEmpty) return i;
  }
  return -1;
}

/// Build the document's name → cached-result scope.
///
/// Every line that produced a result contributes its 1-based
/// auto-alias (`line1`, `line2`, …); assignment lines additionally
/// contribute their explicit LHS. [externalScope] (typically
/// populated by Phase 6 from the doc's `use` imports) is seeded
/// first, so any in-doc assignment of the same name shadows it.
/// [names] limits the returned bindings without changing precedence. Callers
/// substituting symbolic values must retain the full scope because replacement
/// can introduce identifiers that weren't present in the original expression.
///
/// Callers that need to preprocess a *specific* line should remove
/// that line's own contributions from the returned scope before
/// calling [preprocessNotepadLine] — otherwise `x = x + 1` would
/// substitute its own previous result into itself. Cycle detection
/// proper lives in Phase 3.
Map<String, String> buildNotepadScope(
  NotepadDocument doc, {
  Map<String, String> externalScope = const {},
  NotepadLineParseCache? parseCache,
  Set<String>? names,
}) {
  final scope = <String, String>{};
  if (names != null && names.isEmpty) return scope;
  bool wanted(String name) => names == null || names.contains(name);
  for (final entry in externalScope.entries) {
    if (wanted(entry.key)) scope[entry.key] = entry.value;
  }
  final includeAliases =
      names == null || names.any((name) => RegExp(r'^line\d+$').hasMatch(name));

  final firstCode = firstCodeLineIndexOf(doc);
  for (var i = 0; i < doc.lines.length; i++) {
    final line = doc.lines[i];
    final parsed = parseCache?.parse(line.source,
            lineIndex: i, firstCodeLineIndex: firstCode) ??
        classifyNotepadLine(line.source,
            lineIndex: i, firstCodeLineIndex: firstCode);
    if (parsed.isFunction) {
      scope.remove(parsed.name);
      continue;
    }
    if (parsed.kind == NotepadLineKind.blank ||
        parsed.kind == NotepadLineKind.comment ||
        parsed.kind == NotepadLineKind.useDirective) {
      continue;
    }
    // FlatZinc lines contribute multiple scalar exports (one per
    // `:: output_var` annotation) plus their own `lineN` alias
    // bound to the formatted output text. Each export wins over a
    // pre-seeded external import.
    if (parsed.kind == NotepadLineKind.flatzinc) {
      final cached = line.cachedResult;
      if (cached != null && includeAliases && wanted('line${i + 1}')) {
        scope['line${i + 1}'] = cached;
      }
      for (final entry in line.cachedExports.entries) {
        if (wanted(entry.key)) scope[entry.key] = entry.value;
      }
      continue;
    }
    final cached = line.cachedResult;
    if (cached == null) continue;
    if (includeAliases && wanted('line${i + 1}')) {
      scope['line${i + 1}'] = cached;
    }
    if (parsed.kind == NotepadLineKind.assignment && wanted(parsed.name!)) {
      scope[parsed.name!] = cached;
    }
  }
  return scope;
}

/// Substitute scope names + `Ans` into [parsed]'s body, producing
/// the string Phase 3 will pass to the engine.
///
/// Returns `null` for line kinds that aren't sent to the engine
/// (blank, comment, useDirective).
///
/// Scope names are matched longest-first with word-boundary
/// anchors so e.g. `total2` substitutes before `total`, and a
/// name like `pi` doesn't accidentally splice into `epigraph`.
/// The substitution wraps the value in parens (`(value)`) so
/// surrounding operators bind correctly.
/// Resolve cross-document references of the form `{doc:name}.varName`
/// or `{doc:name}.lineN`. [allDocs] is the full set of notepad
/// documents keyed by id. Returns the input with all resolvable
/// cross-refs replaced by their cached values.
String resolveCrossDocRefs(String input, Map<String, NotepadDocument> allDocs) {
  return input.replaceAllMapped(_crossDocRefRegex, (match) {
    final docName = match.group(1)!;
    final varName = match.group(2)!;

    // Find the target document by name (case-insensitive).
    final targetDoc = allDocs.values.firstWhere(
      (d) => d.name.toLowerCase() == docName.toLowerCase(),
      orElse: () => NotepadDocument(
        id: '',
        name: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lines: [],
      ),
    );
    if (targetDoc.id.isEmpty) return match.group(0)!; // Not found.

    // Build the target doc's scope and look up the variable.
    final scope = buildNotepadScope(targetDoc);
    final value = scope[varName];
    if (value != null) return '($value)';

    return match.group(0)!; // Unresolved — leave as-is.
  });
}

/// Pattern: `{doc:name}.variable` where name can contain spaces.
final RegExp _crossDocRefRegex =
    RegExp(r'\{doc:([^}]+)\}\.([A-Za-z_][A-Za-z0-9_]*)');

String? preprocessNotepadLine(
  ParsedNotepadLine parsed, {
  required NotepadDocument doc,
  required int lineIndex,
  required Map<String, String> scope,
  Map<String, NotepadDocument>? allDocs,
}) {
  if (parsed.body == null) return null;
  // Calculus dummy variables and recognized unit tokens own their syntax.
  // Protect them before function expansion and scalar substitution; bounds,
  // limit points and quantity magnitudes still use document scope.
  final protected = _protectLexicalSyntaxBindings(parsed.body!, scope);
  var out = protected.source;
  out = expandNotepadFunctionCalls(out, doc);

  // Resolve cross-document references before anything else.
  if (allDocs != null && out.contains('{doc:')) {
    out = resolveCrossDocRefs(out, allDocs);
  }

  if (out.contains('Ans')) {
    final ansValue = _resolveAns(doc, lineIndex);
    if (ansValue != null) {
      out = out.replaceAll(_ansPattern, '($ansValue)');
    }
  }

  // Numeric bindings cannot introduce another scope identifier. Substitute
  // them in one scan instead of sorting and visiting the entire document scope.
  // Symbolic bindings retain the original ordered replacement semantics.
  final matches = _scopeIdentifierRegex.allMatches(out).toList();
  if (matches.every((match) =>
      scope[match[0]] == null ||
      _scalarScopeValue.hasMatch(scope[match[0]]!))) {
    final substituted = out.replaceAllMapped(_scopeIdentifierRegex, (match) {
      final value = scope[match[0]];
      return value == null ? match[0]! : '($value)';
    });
    return protected.restore(substituted);
  }
  final names = scope.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  for (final name in names) {
    if (!out.contains(name)) continue;
    out = out.replaceAllMapped(_scopeIdentifierRegex,
        (match) => match[0] == name ? '(${scope[name]!})' : match[0]!);
  }
  return protected.restore(out);
}

/// Walk backward from [lineIndex] to the first non-blank,
/// non-comment line above. Return its `cachedResult` if it has
/// one; otherwise null (the engine will then see the literal
/// `Ans` and error, which Phase 3 turns into a "blocked by
/// line N" badge on dependents).
String? _resolveAns(NotepadDocument doc, int lineIndex) {
  for (var i = lineIndex - 1; i >= 0; i--) {
    final line = doc.lines[i];
    final stripped = _stripComment(line.source).trim();
    if (stripped.isEmpty) continue;
    return line.cachedResult;
  }
  return null;
}

String _stripComment(String source) {
  final m = _commentRegex.firstMatch(source);
  if (m == null) return source;
  return source.substring(0, m.start);
}

/// `//` or `#` anywhere in a line. We don't currently have string
/// literals in expressions, so the simple first-match heuristic is
/// correct for V1. If string literals ever appear, this needs to
/// skip matches that fall inside quoted text.
final RegExp _commentRegex = RegExp(r'(//|#)');
final RegExp _useDirectiveRegex = RegExp(r'^use\s+(.+)$');
// `=(?!=)` keeps `name == value` out of the assignment route — that's
// a relational predicate (round 110) the engine handles via the
// preprocessor's `Eq(...)` rewrite.
final RegExp _assignmentRegex = RegExp(
  r'^([A-Za-z_][A-Za-z0-9_]*)\s*=(?!=)\s*(.+)$',
);
final RegExp _identifierRegex = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');
final RegExp _importListStartRegex = RegExp(r'[A-Za-z_0-9,]');
final RegExp _identifierWordRegex =
    RegExp('$_notepadNumberToken|([A-Za-z_][A-Za-z0-9_]*)');

Iterable<RegExpMatch> _identifierWordMatches(String source) =>
    _identifierWordRegex.allMatches(source).where((match) => match[1] != null);

/// `fzn:` directive — must be the first non-whitespace token on the
/// notepad line. Body captures everything after the colon and any
/// immediately following whitespace, including embedded newlines
/// (the screen's TextField uses `maxLines: null` so a single
/// NotepadLine.source can carry multi-line FlatZinc).
final RegExp _plotRegex = RegExp(r'^plot\((.+)\)\s*$');

/// Split a string by top-level commas (depth-0 only).
List<String> _splitTopLevelCommas(String s) {
  final parts = <String>[];
  int depth = 0;
  int start = 0;
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if (c == '(' || c == '[') depth++;
    if (c == ')' || c == ']') depth--;
    if (c == ',' && depth == 0) {
      parts.add(s.substring(start, i));
      start = i + 1;
    }
  }
  parts.add(s.substring(start));
  return parts;
}

final RegExp _flatzincDirectiveRegex = RegExp(
  r'^\s*fzn:\s*([\s\S]*)$',
  caseSensitive: true,
);

/// Names declared with a `:: output_var` annotation in a FlatZinc
/// source. Matched statically so the dependency graph can be built
/// before any evaluation runs. Only scalar output_var names are
/// surfaced; array outputs (`output_array(...)`) stay in the
/// formatted result text but don't enter the document scope, since
/// a single FlatZinc array doesn't map cleanly to a scalar scope
/// value.
Set<String> flatzincOutputVarsIn(String source) {
  final out = <String>{};
  for (final m in _flatzincOutputVarRegex.allMatches(source)) {
    out.add(m.group(1)!);
  }
  return out;
}

/// Parse the standard FlatZinc output format into `name → value`
/// pairs for scalar (non-array) assignments. Array lines (`name =
/// array1d(...);`) are skipped — see [flatzincOutputVarsIn] for the
/// rationale. Anything between `=====UNSATISFIABLE=====` or after
/// the first `----------` separator is also ignored, so multi-
/// solution outputs only contribute the first solution's bindings.
Map<String, String> parseFlatZincScalarOutputs(String output) {
  final out = <String, String>{};
  final firstSolution = output.split('\n----------').first;
  if (firstSolution.contains('=====UNSATISFIABLE=====')) return out;
  for (final line in firstSolution.split('\n')) {
    final m = _flatzincScalarLineRegex.firstMatch(line);
    if (m == null) continue;
    out[m.group(1)!] = m.group(2)!.trim();
  }
  return out;
}

final RegExp _flatzincOutputVarRegex = RegExp(
  r'\b([A-Za-z_][A-Za-z0-9_]*)\b\s*::\s*output_var\b',
);
final RegExp _flatzincScalarLineRegex = RegExp(
  // Value disallows `(` so array1d(...) / array2d(...) lines fall
  // through. A scalar value is a number, a sign-prefixed number,
  // or `true`/`false` — no parens.
  r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*([^;(]+?)\s*;\s*$',
);

// ---------------------------------------------------------------------------
// Phase 3: dependency graph + topological evaluation.
// ---------------------------------------------------------------------------

/// Every identifier-like word in [source]. Stable ordering of first
/// appearance; duplicates collapsed. Used by both the dependency
/// graph (filter against scope keys) and the free-var tag (filter
/// against scope keys + reserved CAS names).
Set<String> identifierWordsIn(String source) {
  final out = <String>{};
  for (final m in _identifierWordMatches(source)) {
    out.add(m.group(0)!);
  }
  return out;
}

/// Word spans owned by calculus operations, solve and inline unit syntax.
/// Formal output variables stay visible to free-variable analysis. Positions let
/// same name remain free in bounds, limit points or quantity magnitudes.
Map<int, ({int end, String name, bool outputVariable})> _lexicalSyntaxBindings(
    String source) {
  final bindings = <int, ({int end, String name, bool outputVariable})>{
    for (final span in UnitExpressionEvaluator.syntaxIdentifierSpans(source))
      span.start: (
        end: span.end,
        name: source.substring(span.start, span.end),
        outputVariable: false,
      ),
  };
  if (!source.contains('integrate') && !source.contains('limit') &&
      !source.contains('solve') && !source.contains('diff') &&
      !source.contains('d/dx') && !source.contains('series') &&
      !source.contains('taylor')) {
    return bindings;
  }
  final syntaxCalls = RegExp(r'(d/dx|[A-Za-z_][A-Za-z0-9_]*)\s*\(');
  for (final call in syntaxCalls.allMatches(source)) {
    final name = call[1];
    if (name != 'integrate' && name != 'limit' && name != 'solve' &&
        name != 'diff' && name != 'd/dx' && name != 'series' &&
        name != 'taylor') {
      continue;
    }
    final open = call.end - 1;
    var depth = 1;
    var end = open + 1;
    for (; end < source.length; end++) {
      if (source[end] == '(') depth++;
      if (source[end] == ')') depth--;
      if (depth == 0) break;
    }
    if (depth != 0) continue;
    final input = '$name${source.substring(open, end + 1)}';
    final args = name == 'integrate'
        ? parseIntegralArguments(input)
        : name == 'limit'
            ? parseLimitArguments(input)
            : name == 'solve'
                ? parseSolveArguments(input)
                : name == 'series' || name == 'taylor'
                    ? parseSeriesArguments(input)
                    : parseDifferentiationArguments(input);
    if (args == null) {
      continue;
    }
    if (name == 'd/dx') {
      // The supported operator spelling owns only these callee fragments;
      // ordinary variables named d or dx elsewhere remain mathematical names.
      bindings[call.start] =
          (end: call.start + 1, name: 'd', outputVariable: false);
      bindings[call.start + 2] =
          (end: call.start + 4, name: 'dx', outputVariable: false);
    }
    final outputVariable = name == 'diff' || name == 'd/dx' ||
        name == 'series' || name == 'taylor' ||
        (name == 'integrate' && args.length == 2);
    List<({int start, int end})> ranges(int start, int finish) {
      var position = start;
      final result = <({int start, int end})>[];
      var nesting = 0;
      for (var i = start; i < finish; i++) {
        if ('([{'.contains(source[i])) nesting++;
        if (')]}'.contains(source[i])) nesting--;
        if (source[i] == ',' && nesting == 0) {
          result.add((start: position, end: i));
          position = i + 1;
        }
      }
      result.add((start: position, end: finish));
      return result;
    }

    final callRanges = ranges(open + 1, end);
    final integrand = callRanges.first;
    var declaration = callRanges[1];
    if (name == 'integrate' && args.length == 4 && callRanges.length == 2) {
      var start = declaration.start;
      var finish = declaration.end;
      while (source[start].trim().isEmpty) {
        start++;
      }
      while (source[finish - 1].trim().isEmpty) {
        finish--;
      }
      declaration = ranges(start + 1, finish - 1).first;
    }
    final tokens = RegExp(
        r'[A-Za-z_][A-Za-z_0-9]*|(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?');
    for (final range in [integrand, declaration]) {
      for (final token
          in tokens.allMatches(source.substring(range.start, range.end))) {
        if (token[0] != args[1]) continue;
        final position = range.start + token.start;
        bindings[position] = (
          end: range.start + token.end,
          name: args[1],
          // A nested formal output cannot escape an enclosing bound scope.
          outputVariable: outputVariable &&
              (bindings[position]?.outputVariable ?? true),
        );
      }
    }
  }
  return bindings;
}

Set<String> _unboundIdentifierWords(String source,
    {bool includeOutputVariables = false}) {
  final bindings = _lexicalSyntaxBindings(source);
  return {
    for (final word in _identifierWordMatches(source))
      if (!bindings.containsKey(word.start) ||
          (includeOutputVariables && bindings[word.start]!.outputVariable)) word[0]!
  };
}

class _ProtectedSyntaxBindings {
  const _ProtectedSyntaxBindings(this.source, this.replacements);
  final String source;
  final Map<String, String> replacements;
  String restore(String value) {
    for (final replacement in replacements.entries) {
      value = value.replaceAll(replacement.key, replacement.value);
    }
    return value;
  }
}

_ProtectedSyntaxBindings _protectLexicalSyntaxBindings(
    String source, Map<String, String> scope) {
  final bindings = _lexicalSyntaxBindings(source);
  if (bindings.isEmpty) return _ProtectedSyntaxBindings(source, const {});
  final starts = bindings.keys.toList()..sort();
  final output = StringBuffer();
  final replacements = <String, String>{};
  var cursor = 0;
  var sequence = 0;
  for (final start in starts) {
    final binding = bindings[start]!;
    String token;
    do {
      // Private-use characters cannot be a scalar/function identifier, so
      // these markers cannot pick up a document binding during expansion.
      token = '\uE000${sequence++}\uE001';
    } while (source.contains(token) ||
        scope.values.any((value) => value.contains(token)));
    output.write(source.substring(cursor, start));
    output.write(token);
    replacements[token] = binding.name;
    cursor = binding.end;
  }
  output.write(source.substring(cursor));
  return _ProtectedSyntaxBindings(output.toString(), replacements);
}

/// In-document dependencies for a parsed line: the subset of
/// [scopeKeys] that appears as an identifier in [parsed]'s body.
/// `Ans` is handled separately by the evaluator and isn't a scope
/// key, so it doesn't show up here.
///
/// FlatZinc lines are independent — the body uses FlatZinc's own
/// variable namespace, which is unrelated to the document scope —
/// so they never produce dependency edges.
Set<String> dependenciesOfLine(
  ParsedNotepadLine parsed,
  Set<String> scopeKeys,
) {
  if (parsed.kind == NotepadLineKind.flatzinc) return const {};
  final body = parsed.body;
  if (body == null) return const {};
  final words = _unboundIdentifierWords(body);
  return words
      .where((word) =>
          scopeKeys.contains(word) &&
          !(parsed.parameters?.contains(word) ?? false))
      .toSet();
}

/// Identifiers in [parsed]'s body that don't resolve to anything —
/// neither a scope name nor a reserved CAS function / constant.
/// Surfaced by the UI as the `free: x, y` tag (decision #15).
///
/// Fully bound calculus variables and unit syntax are excluded. Differentiation
/// and indefinite integration retain their formal variable in symbolic output.
Set<String> freeVariablesOfLine(
  ParsedNotepadLine parsed,
  Set<String> scopeKeys,
) {
  // FlatZinc identifiers live in their own namespace; surfacing
  // them as "free vars" in the doc would be misleading noise.
  if (parsed.kind == NotepadLineKind.flatzinc) return const {};
  final body = parsed.body;
  if (body == null) return const {};
  final words = _unboundIdentifierWords(body, includeOutputVariables: true);
  return words
      .where((id) =>
          !scopeKeys.contains(id) &&
          !kReservedNotepadNames.contains(id) &&
          id != 'Ans' &&
          !(parsed.parameters?.contains(id) ?? false))
      .toSet();
}

/// Expand balanced calls with simultaneous lexical substitution. Definitions
/// already have their captured document bindings resolved by the dependency
/// walker. A function is never entered into the scalar substitution scope.
final _notepadCallPattern = RegExp(r'([A-Za-z_][A-Za-z0-9_]*)\s*\(');
bool _mayCallNotepadFunction(String input) => _notepadCallPattern
    .allMatches(input)
    .any((m) => !kReservedNotepadNames.contains(m[1]));

String expandNotepadFunctionCalls(String input, NotepadDocument doc) {
  if (!_mayCallNotepadFunction(input)) return input;
  final definitions =
      <String, ({ParsedNotepadLine parsed, NotepadLine line})>{};
  final first = firstCodeLineIndexOf(doc);
  for (var i = 0; i < doc.lines.length; i++) {
    final parsed = classifyNotepadLine(doc.lines[i].source,
        lineIndex: i, firstCodeLineIndex: first);
    if (parsed.isFunction) {
      definitions[parsed.name!] = (parsed: parsed, line: doc.lines[i]);
    } else if (parsed.kind == NotepadLineKind.assignment) {
      definitions.remove(parsed.name);
    }
  }
  String expand(String source, int depth) {
    if (depth > 32 || source.length > 100000) {
      throw const FormatException('Function expansion exceeds its limit');
    }
    final output = StringBuffer();
    var cursor = 0;
    for (final match in _scopeIdentifierRegex.allMatches(source)) {
      if (match.start < cursor) continue;
      final definition = definitions[match[0]];
      if (definition == null) continue;
      var open = match.end;
      while (open < source.length && source[open].trim().isEmpty) {
        open++;
      }
      if (open >= source.length || source[open] != '(') continue;
      var nesting = 1;
      var start = open + 1;
      var end = start;
      final arguments = <String>[];
      for (; end < source.length; end++) {
        final char = source[end];
        if (char == '(' || char == '[') nesting++;
        if (char == ')' || char == ']') nesting--;
        if (nesting == 0) {
          if (source.substring(start, end).trim().isNotEmpty ||
              arguments.isNotEmpty) {
            arguments.add(source.substring(start, end));
          }
          break;
        }
        if (char == ',' && nesting == 1) {
          arguments.add(source.substring(start, end));
          start = end + 1;
        }
      }
      if (nesting != 0) throw FormatException('Unclosed call to ${match[0]}');
      final parameters = definition.parsed.parameters!;
      if (arguments.length != parameters.length ||
          arguments.any((a) => a.trim().isEmpty)) {
        throw FormatException(
            '${match[0]} expects ${parameters.length} arguments');
      }
      final template = definition.line.cachedResult;
      if (template == null || definition.line.cachedError != null) {
        throw FormatException('Function ${match[0]} is unavailable');
      }
      final bindings = <String, String>{
        for (var i = 0; i < parameters.length; i++)
          parameters[i]: expand(arguments[i], depth + 1),
      };
      var expandedLength = template.length;
      final body = template.replaceAllMapped(_scopeIdentifierRegex, (m) {
        final value = bindings[m[0]];
        if (value == null) return m[0]!;
        expandedLength += value.length + 2 - m[0]!.length;
        if (expandedLength > 100000) {
          throw const FormatException('Function expansion exceeds its limit');
        }
        return '($value)';
      });
      output.write(source.substring(cursor, match.start));
      output.write('(${expand(body, depth + 1)})');
      if (output.length > 100000) {
        throw const FormatException('Function expansion exceeds its limit');
      }
      cursor = end + 1;
    }
    output.write(source.substring(cursor));
    final result = output.toString();
    if (result.length > 100000) {
      throw const FormatException('Function expansion exceeds its limit');
    }
    return result;
  }

  return expand(input, 0);
}

/// Scalar and function names available to dependency/free-variable UI helpers.
Set<String> notepadScopeNames(NotepadDocument doc,
    {Map<String, String> externalScope = const {}}) {
  final names =
      buildNotepadScope(doc, externalScope: externalScope).keys.toSet();
  final firstCode = firstCodeLineIndexOf(doc);
  for (var i = 0; i < doc.lines.length; i++) {
    final parsed = classifyNotepadLine(doc.lines[i].source,
        lineIndex: i, firstCodeLineIndex: firstCode);
    if (parsed.isFunction) names.add(parsed.name!);
  }
  return names;
}
