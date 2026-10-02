import 'result_evidence.dart';
// lib/engine/notepad_evaluator.dart
//
// Per-line classification + document-scope construction + scope
// substitution for the Notepad surface (Phase 2 of the notepad V1
// implementation plan).
//
// Pure Dart — no engine bridge. Phase 3 layers a dependency graph
// + `EngineService` dispatch on top of these primitives; Phase 6
// wires the `use` directive's resolved imports to AppState's
// global namespaces.

import 'notepad.dart';
import 'numeric_fallback.dart';
import 'symbolic_expr.dart';
import '../services/integral_arguments.dart';

part 'notepad_syntax.dart';

/// Per-document dependency graph keyed by line index.
/// `graph[i]` = set of line indices that line `i` depends on.
///
/// Built by mapping each in-scope name back to the line that
/// produced it (assignment name → its line; `lineN` alias → line
/// at index N-1). External-scope names (from `use` imports) are
/// not in the graph since they aren't doc-internal nodes.
///
/// Blank, comment, and `useDirective` lines have empty dependency
/// sets and never appear as targets of another line's edge.
class NotepadDependencyGraph {
  /// Edges keyed by source: `dependsOn[i]` = lines `i` depends on.
  final Map<int, Set<int>> dependsOn;

  /// Reverse edges keyed by target: `dependents[i]` = lines that
  /// depend on `i`. Used for downstream-only invalidation.
  final Map<int, Set<int>> dependents;

  const NotepadDependencyGraph({
    required this.dependsOn,
    required this.dependents,
  });
}

NotepadDependencyGraph buildDependencyGraph(
  NotepadDocument doc, {
  Map<String, String> externalScope = const {},
}) {
  // Map each in-doc scope name to the line index that produced it.
  // Both the auto-alias and the explicit name (for assignments)
  // point at the same line, so a reference to either flows the
  // same edge.
  final nameToLine = <String, int>{};
  final firstCode = firstCodeLineIndexOf(doc);
  final parsedLines = <int, ParsedNotepadLine>{};
  for (var i = 0; i < doc.lines.length; i++) {
    final parsed = classifyNotepadLine(doc.lines[i].source,
        lineIndex: i, firstCodeLineIndex: firstCode);
    parsedLines[i] = parsed;
    switch (parsed.kind) {
      case NotepadLineKind.assignment:
        nameToLine[parsed.name!] = i;
        nameToLine['line${i + 1}'] = i;
        break;
      case NotepadLineKind.aggregate:
      case NotepadLineKind.expression:
        nameToLine['line${i + 1}'] = i;
        break;
      case NotepadLineKind.flatzinc:
        nameToLine['line${i + 1}'] = i;
        // Statically extract output_var names from the FlatZinc
        // source so downstream refs route correctly even before
        // the line has been evaluated for the first time.
        for (final name in flatzincOutputVarsIn(parsed.body ?? '')) {
          nameToLine[name] = i;
        }
        break;
      case NotepadLineKind.blank:
      case NotepadLineKind.comment:
      case NotepadLineKind.useDirective:
      case NotepadLineKind.heading:
      case NotepadLineKind.divider:
      case NotepadLineKind.plot:
        break;
    }
  }

  // External-scope names take precedence on lookup, but they aren't
  // in-doc nodes — references to them produce no graph edges.
  final inDocScopeKeys = nameToLine.keys.toSet();

  final dependsOn = <int, Set<int>>{
    for (var i = 0; i < doc.lines.length; i++) i: <int>{},
  };
  final dependents = <int, Set<int>>{
    for (var i = 0; i < doc.lines.length; i++) i: <int>{},
  };

  for (var i = 0; i < doc.lines.length; i++) {
    final parsed = parsedLines[i]!;
    void addDependency(int target) {
      dependsOn[i]!.add(target);
      dependents[target]!.add(i);
    }

    // These inputs are implicit in preprocessing and aggregate evaluation;
    // omitting them leaves stale answers after an incremental edit.
    if (parsed.kind == NotepadLineKind.aggregate) {
      for (var prior = i - 1; prior >= 0; prior--) {
        final kind = parsedLines[prior]!.kind;
        if (kind == NotepadLineKind.aggregate) {
          if (parsed.name != 'total') break;
          continue;
        }
        if (kind == NotepadLineKind.assignment ||
            kind == NotepadLineKind.expression ||
            kind == NotepadLineKind.flatzinc) {
          addDependency(prior);
        }
      }
    } else if (parsed.kind != NotepadLineKind.flatzinc &&
        _ansPattern.hasMatch(parsed.body ?? '')) {
      for (var prior = i - 1; prior >= 0; prior--) {
        if (_stripComment(doc.lines[prior].source).trim().isNotEmpty) {
          addDependency(prior);
          break;
        }
      }
    }
    final refs = dependenciesOfLine(parsed, inDocScopeKeys);
    for (final name in refs) {
      // Ignore external-scope names (they have no in-doc node).
      if (externalScope.containsKey(name) && !inDocScopeKeys.contains(name)) {
        continue;
      }
      final target = nameToLine[name];
      if (target == null) continue;
      // A line referencing itself by its own auto-alias / name is
      // a self-loop. Surface it as a one-element cycle.
      dependsOn[i]!.add(target);
      dependents[target]!.add(i);
    }
  }

  return NotepadDependencyGraph(
    dependsOn: dependsOn,
    dependents: dependents,
  );
}

/// Kahn's algorithm in pure functional form. Returns the line
/// indices in dependency order (every line appears after all the
/// lines it depends on). Lines that are part of a cycle are
/// excluded from the result — the caller pairs this with
/// [findCycleParticipants] to error those lines instead.
List<int> kahnTopologicalOrder(NotepadDependencyGraph graph) {
  final remainingDeps = {
    for (final entry in graph.dependsOn.entries)
      entry.key: Set<int>.from(entry.value),
  };
  final queue = <int>[
    for (final entry in remainingDeps.entries)
      if (entry.value.isEmpty) entry.key,
  ]..sort();
  final order = <int>[];
  var cursor = 0;
  while (cursor < queue.length) {
    final node = queue[cursor++];
    order.add(node);
    final children = graph.dependents[node] ?? const <int>{};
    final newlyReady = <int>[];
    for (final child in children) {
      remainingDeps[child]!.remove(node);
      if (remainingDeps[child]!.isEmpty) newlyReady.add(child);
    }
    newlyReady.sort();
    queue.addAll(newlyReady);
  }
  return order;
}

/// Indices of every line that is part of any cycle (including
/// self-loops). Computed as the complement of [kahnTopologicalOrder]:
/// anything Kahn can't drain is on a cycle.
Set<int> findCycleParticipants(NotepadDependencyGraph graph) {
  final ordered = kahnTopologicalOrder(graph).toSet();
  return {
    for (final i in graph.dependsOn.keys)
      if (!ordered.contains(i)) i,
  };
}

/// Transitive closure of [start]'s dependents in [graph], inclusive.
/// Used by `evaluateFrom` to limit recompute work to the subgraph
/// rooted at the edited line.
Set<int> downstreamFrom(int start, NotepadDependencyGraph graph) {
  final out = <int>{start};
  final stack = <int>[start];
  while (stack.isNotEmpty) {
    final node = stack.removeLast();
    for (final child in graph.dependents[node] ?? const <int>{}) {
      if (out.add(child)) stack.add(child);
    }
  }
  return out;
}

// ---------------------------------------------------------------------------
// Phase 3: error encoding.
// ---------------------------------------------------------------------------

/// String prefixes used on `NotepadLine.cachedError` so the UI can
/// pattern-match on the error kind without a separate structured
/// type. Format is `<prefix>:<payload>`; payload format is per-kind.
class NotepadErrorPrefix {
  static const String blockedBy = 'blockedBy:';
  static const String circularReference = 'circularReference:';
  static const String evaluation = 'evaluation:';
  static const String useDirective = 'useDirective:';

  /// `blockedBy:<lineId>:<alias>` — dependent of an errored line.
  /// The UI parses alias (e.g. `line3`) for the chip label and
  /// uses lineId to scroll-to-line on tap.
  static String blocked(String lineId, String alias) =>
      '$blockedBy$lineId:$alias';

  /// `circularReference:a→b→a` — cycle participants. Body is the
  /// cycle's name path joined with `→`; the UI renders verbatim.
  static String circular(List<String> namePath) =>
      '$circularReference${namePath.join('→')}';

  /// `evaluation:<engine error string>` — engine returned a raw
  /// error. The existing `EngineErrorFormatter` handles the
  /// payload presentation.
  static String fromEngine(String engineError) => '$evaluation$engineError';
}

// ---------------------------------------------------------------------------
// Phase 3: orchestrator.
// ---------------------------------------------------------------------------

/// Signature of the engine-dispatch callback the evaluator calls
/// for each non-blocked line. Tests inject a stub; production
/// wiring uses `EngineService.evaluateAsync`.
typedef NotepadEngineDispatcher = Future<String> Function(
    String preprocessedExpression);

/// Result of running a `fzn:` line: the standard FlatZinc output
/// text (for `cachedResult`) plus the scalar `output_var` bindings
/// extracted from the first solution (for `cachedExports`). Errors
/// from the FlatZinc parser / solver bubble up as a thrown
/// exception — the evaluator catches them and writes the message
/// into `cachedError`.
class NotepadFlatZincResult {
  final String formatted;
  final Map<String, String> scalarBindings;
  const NotepadFlatZincResult({
    required this.formatted,
    required this.scalarBindings,
  });
}

/// Signature of the FlatZinc dispatcher. Tests inject a stub that
/// returns canned bindings; production wires this to
/// `FlatZinc.solve(source)` + [parseFlatZincScalarOutputs].
typedef NotepadFlatZincDispatcher = Future<NotepadFlatZincResult> Function(
    String flatzincSource);

/// Orchestrates per-line evaluation across a `NotepadDocument`:
/// builds the dependency graph, processes lines in topological
/// order, propagates blocked-by errors downstream, flags cycle
/// participants, and updates each line's cached fields in place.
///
/// Engine calls are funnelled through [dispatcher] so the
/// evaluator stays testable without a real `SymEngine` bridge.
class NotepadEvaluationCancelled implements Exception {
  const NotepadEvaluationCancelled();
}

/// Stops a batch between rows and discards results returning after cancellation.
/// Does not kill the shared engine worker or race its next command.
class NotepadEvaluationCancellation {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
  void check() {
    if (_cancelled) throw const NotepadEvaluationCancelled();
  }
}

class NotepadEvaluator {
  final NotepadEvaluationCancellation? cancellation;
  final void Function(int completed, int total, String lineId)? onProgress;
  final NotepadEngineDispatcher dispatcher;
  final Future<ComputedResult> Function(String)? detailedDispatcher;

  /// Optional FlatZinc dispatcher. When null, `fzn:` lines fail
  /// with a "FlatZinc dispatcher not wired" error — useful in
  /// tests that don't care about FlatZinc support. Production
  /// wiring (NotepadScreen) always passes a real callback that
  /// hits dart_csp's FlatZinc.solve.
  final NotepadFlatZincDispatcher? flatzincDispatcher;

  /// Optional [externalScope] — populated by Phase 6 from the doc's
  /// `use` directive resolved against `AppState.userVariables` /
  /// `userFunctions`. Phase 3 just sees the map and uses it for
  /// scope lookup; the `use` directive line itself never gets
  /// dispatched.
  final Map<String, String> externalScope;

  NotepadEvaluator({
    required this.dispatcher,
    this.cancellation,
    this.onProgress,
    this.detailedDispatcher,
    this.flatzincDispatcher,
    this.externalScope = const {},
  });

  /// Recompute every line in [doc] in topological order. Mutates
  /// the lines' cache fields in place and returns the same doc.
  Future<NotepadDocument> evaluateAll(NotepadDocument doc) async {
    return _evaluateSubset(doc, indices: null);
  }

  /// Recompute the line at [startLineIndex] and every line
  /// transitively downstream of it. Lines outside that subgraph
  /// keep their current cache values.
  Future<NotepadDocument> evaluateFrom(
    NotepadDocument doc,
    int startLineIndex,
  ) async {
    return evaluateChanged(doc, {startLineIndex});
  }

  /// Recalculate the union of all edited rows and their dependents. Multiple
  /// edits in one debounce window must not drop the earlier edit's subgraph.
  Future<NotepadDocument> evaluateChanged(
      NotepadDocument doc, Set<int> changed) async {
    final graph = buildDependencyGraph(doc, externalScope: externalScope);
    final subset = <int>{};
    for (final index in changed) {
      if (index >= 0 && index < doc.lines.length) {
        subset.addAll(downstreamFrom(index, graph));
      }
    }
    return _evaluateSubset(doc, indices: subset, dependencyGraph: graph);
  }

  /// Core driver. If [indices] is null, every line is in scope;
  /// otherwise only the listed indices get re-evaluated (cache
  /// for the rest is reused as-is for blocked-by lookups).
  Future<NotepadDocument> _evaluateSubset(
    NotepadDocument doc, {
    required Set<int>? indices,
    NotepadDependencyGraph? dependencyGraph,
  }) async {
    cancellation?.check();
    final graph = dependencyGraph ??
        buildDependencyGraph(doc, externalScope: externalScope);
    final order = kahnTopologicalOrder(graph);
    final ordered = order.toSet();
    final cycleNodes = graph.dependsOn.keys.where((i) => !ordered.contains(i));
    final total = indices?.length ?? doc.lines.length;
    var completed = 0;
    final slice = Stopwatch()..start();
    onProgress?.call(0, total, '');
    void progress(int index) {
      onProgress?.call(++completed, total, doc.lines[index].id);
    }

    final firstCode = firstCodeLineIndexOf(doc);
    final parseCache = NotepadLineParseCache();

    // Cycle nodes first — they never get an engine call. Their
    // downstream gets blockedBy via the standard path below.
    for (final i in cycleNodes) {
      if (indices != null && !indices.contains(i)) continue;
      cancellation?.check();
      final cyclePath = _cycleNamePath(i, graph, doc, firstCode);
      doc.lines[i].cachedResult = null;
      doc.lines[i].cachedError = NotepadErrorPrefix.circular(cyclePath);
      doc.lines[i].resultEvidence = null;
      doc.lines[i].cachedFreeVars = [];
      progress(i);
    }

    // Process the Kahn-acyclic part in dependency order.
    _scopeKeysCache = null; // force rebuild on first blocked line
    var numericScope = _NumericScopeIndex.tryCreate(doc, externalScope);
    for (final i in order) {
      if (indices != null && !indices.contains(i)) continue;
      cancellation?.check();
      if (slice.elapsedMilliseconds >= 8) {
        await Future<void>.delayed(Duration.zero);
        cancellation?.check();
        slice.reset();
      }
      if (numericScope != null && !numericScope.matches(doc, externalScope)) {
        numericScope = _NumericScopeIndex.tryCreate(doc, externalScope);
      }
      await _evaluateLine(
          doc, i, graph, firstCode, parseCache, numericScope?.scope);
      if (numericScope != null &&
          !numericScope.recordResult(doc, i, externalScope)) {
        numericScope = _NumericScopeIndex.tryCreate(doc, externalScope);
      }
      progress(i);
    }
    return doc;
  }

  /// Evaluate (or skip + error) a single line. Mutates the line.
  Future<void> _evaluateLine(
    NotepadDocument doc,
    int lineIndex,
    NotepadDependencyGraph graph,
    int firstCode,
    NotepadLineParseCache parseCache,
    Map<String, String>? indexedScope,
  ) async {
    final line = doc.lines[lineIndex];
    line.resultEvidence = null;
    final parsed = classifyNotepadLine(line.source,
        lineIndex: lineIndex, firstCodeLineIndex: firstCode);

    // Skip non-evaluable kinds.
    switch (parsed.kind) {
      case NotepadLineKind.blank:
      case NotepadLineKind.comment:
      case NotepadLineKind.heading:
      case NotepadLineKind.divider:
        line.cachedResult = null;
        line.cachedError = null;
        line.cachedFreeVars = [];
        return;
      case NotepadLineKind.plot:
        // Store the plot spec in cachedResult as a sentinel the UI
        // recognizes. Format: `__plot__:expr|var|lo|hi`.
        line.cachedResult =
            '__plot__:${parsed.body}|${parsed.name}|${parsed.imports.join('|')}';
        line.cachedError = null;
        line.cachedFreeVars = [];
        return;
      case NotepadLineKind.useDirective:
        line.cachedResult = null;
        // Preserve a pre-existing useDirective: error so callers
        // (Phase 6's screen-level `use` resolver) can set
        // `unknownImport:<name>` against AppState BEFORE the
        // evaluator runs without losing it on the way through.
        // Parse-level errors (invalidImport, emptyImportList) still
        // win because we set them unconditionally here when the
        // pre-existing cachedError isn't already one of ours.
        if (line.cachedError == null ||
            !line.cachedError!.startsWith(NotepadErrorPrefix.useDirective)) {
          line.cachedError = parsed.directiveError == null
              ? null
              : '${NotepadErrorPrefix.useDirective}${parsed.directiveError}';
        }
        line.cachedFreeVars = [];
        return;
      case NotepadLineKind.flatzinc:
        await _evaluateFlatZincLine(line, parsed);
        return;
      case NotepadLineKind.aggregate:
        _evaluateAggregate(doc, lineIndex, line, parsed.name!);
        return;
      case NotepadLineKind.assignment:
      case NotepadLineKind.expression:
        break;
    }

    // Blocked-by upstream propagation. Pick the lowest-index
    // errored dependency as the canonical "blame" line — UI shows
    // its alias on the chip.
    final upstreamErrored = (graph.dependsOn[lineIndex] ?? const <int>{})
        .where((idx) => doc.lines[idx].cachedError != null)
        .toList()
      ..sort();
    if (upstreamErrored.isNotEmpty) {
      final blameIdx = upstreamErrored.first;
      final blame = doc.lines[blameIdx];
      line.cachedResult = null;
      line.cachedError =
          NotepadErrorPrefix.blocked(blame.id, 'line${blameIdx + 1}');
      // Free-var tracking is still useful even when blocked — the
      // user might be debugging via the tag.
      line.cachedFreeVars = freeVariablesOfLine(
        parsed,
        _scopeKeysFor(doc, firstCode),
      ).toList();
      return;
    }

    // Build the line's scope view + free vars.
    final body = parsed.body ?? '';
    final referencedNames = {
      ...identifierWordsIn(body),
      ..._scopeIdentifierRegex.allMatches(body).map((match) => match[0]!),
    };
    var scope = indexedScope == null
        ? buildNotepadScope(doc,
            externalScope: externalScope,
            parseCache: parseCache,
            names: referencedNames)
        : {
            for (final name in referencedNames)
              if (indexedScope.containsKey(name)) name: indexedScope[name]!,
          };
    // Numeric replacements cannot introduce more identifiers. Symbolic values
    // retain the complete scope and the existing ordered substitution behavior.
    if (scope.values.any((value) => !_scalarScopeValue.hasMatch(value))) {
      scope = buildNotepadScope(doc,
          externalScope: externalScope, parseCache: parseCache);
    }
    final scopeKeys = {...scope.keys};
    if (parsed.isFunction || _mayCallNotepadFunction(body)) {
      scopeKeys.addAll(_scopeKeysFor(doc, firstCode));
    }
    final freeVars = freeVariablesOfLine(parsed, scopeKeys).toList()..sort();

    // Strip this line's own contributions to avoid self-substitution
    // (`x = x + 1` shouldn't see its own previous result). Cycle
    // detection above already errored true cycles; this guards the
    // single-step self-reference case where the line writes its
    // own alias.
    scope.remove('line${lineIndex + 1}');
    if (parsed.kind == NotepadLineKind.assignment) {
      scope.remove(parsed.name!);
    }

    for (final parameter in parsed.parameters ?? const <String>[]) {
      scope.remove(parameter);
    }
    final inputAccuracy =
        _dependencyAccuracy(doc, lineIndex, graph, scope, referencedNames, firstCode);
    String? preprocessed;
    try {
      preprocessed = preprocessNotepadLine(parsed,
          doc: doc, lineIndex: lineIndex, scope: scope);
    } on FormatException catch (error) {
      line.cachedResult = null;
      line.cachedError =
          NotepadErrorPrefix.fromEngine('Error: ${error.message}');
      line.cachedFreeVars = freeVars;
      return;
    }
    if (parsed.isFunction) {
      final diagnosis = SymbolicExpressionEvaluator.diagnose(preprocessed!);
      final error = engineErrorForDiagnosis(diagnosis);
      if (diagnosis.isIncomplete || error != null) {
        line.cachedResult = null;
        line.cachedError =
            error == null ? null : NotepadErrorPrefix.fromEngine(error);
        line.cachedFreeVars = freeVars;
        return;
      }
      line.cachedResult = preprocessed;
      line.cachedError = null;
      line.cachedFreeVars = freeVars;
      line.resultEvidence = ResultEvidence(
          inputAccuracy ?? ResultAccuracy.symbolic,
          ComputationMethod.symbolicEvaluation);
      return;
    }
    if (preprocessed == null) {
      // Shouldn't happen for assignment/expression, but be defensive.
      line.cachedResult = null;
      line.cachedError = null;
      line.cachedFreeVars = freeVars;
      return;
    }

    // A half-typed line is a valid *prefix*, not a mistake. Recalc runs
    // 300 ms after every keystroke, so on the way to `2 + 3` the
    // evaluator sees `2`, `2 `, `2 +` — and dispatching `2 +` is what
    // used to paint "Error: evaluate failed: [object Object]" under the
    // cursor while the user was still typing. Leave the line blank
    // instead and let the result appear when the expression is
    // finished. Only genuine prefixes are silenced; anything actually
    // wrong (`foo(1)`, `2+3)`) still goes to the dispatcher and errors
    // as before.
    if (SymbolicExpressionEvaluator.isIncomplete(preprocessed)) {
      line.cachedResult = null;
      line.cachedError = null;
      line.cachedFreeVars = freeVars;
      return;
    }

    final dispatchedSource = line.source;
    String result;
    ResultEvidence? evidence;
    try {
      if (detailedDispatcher != null) {
        final computed = await detailedDispatcher!(preprocessed);
        result = computed.value;
        evidence = computed.evidence;
      } else {
        result = await dispatcher(preprocessed);
      }
    } catch (e) {
      result = 'Error: dispatcher threw: $e';
    }

    cancellation?.check();
    if (line.source != dispatchedSource) {
      throw const NotepadEvaluationCancelled();
    }
    if (!result.startsWith('Error') && inputAccuracy != null) {
      // Substituting a rounded upstream decimal into exact arithmetic does
      // not recover its lost precision. Keep that uncertainty through aliases
      // and captured functions, rather than labelling a decimal-derived
      // rational as an exact answer.
      final accuracy = inputAccuracy == ResultAccuracy.approximate ||
              evidence?.accuracy == ResultAccuracy.approximate
          ? ResultAccuracy.approximate
          : ResultAccuracy.unknown;
      evidence = ResultEvidence(
          accuracy,
          evidence?.method == ComputationMethod.integerArithmetic
              ? ComputationMethod.numericFallback
              : evidence?.method ?? ComputationMethod.symbolicEvaluation,
          unchanged: evidence?.unchanged ?? false,
          sourceDomain: evidence?.sourceDomain);
      if (_cachedNumericValue(result)) {
        final numeric = NumericFallbackEvaluator.evalNumeric(result);
        if (numeric != null && numeric.isFinite) {
          // toString keeps enough digits to round-trip a double. Display
          // rounding belongs to the UI; downstream caches keep those digits.
          result = numeric.toString();
          if (result.endsWith('.0')) {
            result = result.substring(0, result.length - 2);
          }
        }
      }
    }
    line.resultEvidence = evidence;
    if (result.startsWith('Error')) {
      line.cachedResult = null;
      line.cachedError = NotepadErrorPrefix.fromEngine(result);
      line.cachedFreeVars = freeVars;
    } else {
      line.cachedResult = result;
      line.cachedError = null;
      line.cachedFreeVars = freeVars;
    }
  }

  static bool _cachedNumericValue(String value) => RegExp(
          r'^[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?(?:/[+-]?\d+)?$')
      .hasMatch(value.replaceAll(RegExp(r'\s+'), ''));

  ResultAccuracy? _dependencyAccuracy(
      NotepadDocument doc,
      int index,
      NotepadDependencyGraph graph,
      Map<String, String> scope,
      Set<String> referencedNames,
      int firstCode) {
    ResultAccuracy? uncertainty;
    final localNames = <String>{};
    for (final dependency in graph.dependsOn[index] ?? const <int>{}) {
      final upstream = doc.lines[dependency];
      final parsed = classifyNotepadLine(upstream.source,
          lineIndex: dependency, firstCodeLineIndex: firstCode);
      localNames.add('line${dependency + 1}');
      if (parsed.name != null) localNames.add(parsed.name!);
      localNames.addAll(upstream.cachedExports.keys);
      final accuracy = upstream.resultEvidence?.accuracy;
      if (accuracy == ResultAccuracy.approximate) {
        return ResultAccuracy.approximate;
      }
      if (accuracy == ResultAccuracy.unknown ||
          (accuracy == null && upstream.cachedResult != null) ||
          (accuracy == ResultAccuracy.symbolic &&
              !parsed.isFunction &&
              upstream.cachedResult != null &&
              _cachedNumericValue(upstream.cachedResult!))) {
        uncertainty = ResultAccuracy.unknown;
      }
    }
    // Imported values have no precision metadata. A numerical import cannot
    // become exact solely because its cached spelling is a decimal literal.
    for (final name in referencedNames) {
      if (!localNames.contains(name) &&
          externalScope.containsKey(name) &&
          scope.containsKey(name) &&
          _cachedNumericValue(scope[name]!)) {
        uncertainty = ResultAccuracy.unknown;
      }
    }
    return uncertainty;
  }

  /// Evaluate a `total`/`subtotal`/`average`/`count` aggregate line.
  ///
  /// Scans backwards from [lineIndex] collecting numeric results from
  /// preceding lines. For `subtotal` and `total`, the scan stops at
  /// the previous aggregate line (or the top of the doc). For
  /// `average` and `count`, the same range applies. A `total` scans
  /// from the very top of the doc, ignoring intervening aggregates.
  void _evaluateAggregate(
    NotepadDocument doc,
    int lineIndex,
    NotepadLine line,
    String kind,
  ) {
    final values = <double>[];
    final scanFromTop = kind == 'total';
    final startIndex =
        scanFromTop ? 0 : _previousAggregateIndex(doc, lineIndex) + 1;

    final firstCode = firstCodeLineIndexOf(doc);
    for (var i = startIndex; i < lineIndex; i++) {
      final other = doc.lines[i];
      // Skip aggregate lines so subtotal results don't double-count
      // into a later total.
      final otherParsed = classifyNotepadLine(other.source,
          lineIndex: i, firstCodeLineIndex: firstCode);
      if (otherParsed.kind == NotepadLineKind.aggregate) continue;
      if (other.cachedResult == null) continue;
      final d = double.tryParse(other.cachedResult!.trim());
      if (d != null && d.isFinite) values.add(d);
    }

    String result;
    switch (kind) {
      case 'total':
      case 'subtotal':
        final sum = values.fold<double>(0, (a, b) => a + b);
        result = _formatAggregate(sum);
      case 'average':
        if (values.isEmpty) {
          line.cachedResult = null;
          line.cachedError = 'Error: no numeric values to average';
          line.cachedFreeVars = [];
          return;
        }
        final avg = values.fold<double>(0, (a, b) => a + b) / values.length;
        result = _formatAggregate(avg);
      case 'count':
        result = values.length.toString();
      default:
        result = 'Error: unknown aggregate $kind';
    }

    line.cachedResult = result;
    line.cachedError = null;
    line.cachedFreeVars = [];
  }

  /// Find the index of the nearest aggregate line above [lineIndex].
  /// Returns -1 if no prior aggregate exists.
  int _previousAggregateIndex(NotepadDocument doc, int lineIndex) {
    final firstCode = firstCodeLineIndexOf(doc);
    for (var i = lineIndex - 1; i >= 0; i--) {
      final parsed = classifyNotepadLine(doc.lines[i].source,
          lineIndex: i, firstCodeLineIndex: firstCode);
      if (parsed.kind == NotepadLineKind.aggregate) return i;
    }
    return -1;
  }

  static String _formatAggregate(double v) {
    if ((v - v.roundToDouble()).abs() < 1e-9 && v.abs() < 1e15) {
      return v.round().toString();
    }
    final s = v.toStringAsPrecision(10);
    return s.contains('.')
        ? s.replaceAll(_trailingZeros, '').replaceAll(_trailingDot, '')
        : s;
  }

  /// Dispatch a `fzn:` line to the FlatZinc backend. On success the
  /// formatted FlatZinc output goes to `cachedResult` and the
  /// parsed scalar bindings populate `cachedExports`. Without a
  /// `flatzincDispatcher` wired, surfaces a friendly error so the
  /// missing-dispatcher case isn't silent.
  Future<void> _evaluateFlatZincLine(
    NotepadLine line,
    ParsedNotepadLine parsed,
  ) async {
    final body = parsed.body ?? '';
    final dispatchedSource = line.source;
    if (body.trim().isEmpty) {
      line.cachedResult = null;
      line.cachedError =
          '${NotepadErrorPrefix.evaluation}Error: empty FlatZinc body';
      line.cachedFreeVars = [];
      line.cachedExports = {};
      return;
    }
    final dispatch = flatzincDispatcher;
    if (dispatch == null) {
      line.cachedResult = null;
      line.cachedError =
          '${NotepadErrorPrefix.evaluation}Error: FlatZinc dispatcher not wired';
      line.cachedFreeVars = [];
      line.cachedExports = {};
      return;
    }
    try {
      final result = await dispatch(body);
      cancellation?.check();
      if (line.source != dispatchedSource) {
        throw const NotepadEvaluationCancelled();
      }
      // Treat a UNSATISFIABLE marker as an error so dependents
      // block correctly — there is no value to substitute.
      if (result.formatted.contains('=====UNSATISFIABLE=====')) {
        line.cachedResult = null;
        line.cachedError = '${NotepadErrorPrefix.evaluation}Error: '
            'unsatisfiable FlatZinc model';
        line.cachedFreeVars = [];
        line.cachedExports = {};
        return;
      }
      line.cachedResult = result.formatted;
      line.cachedError = null;
      line.cachedFreeVars = [];
      line.cachedExports = Map<String, String>.from(result.scalarBindings);
    } on NotepadEvaluationCancelled {
      rethrow;
    } catch (e) {
      cancellation?.check();
      line.cachedResult = null;
      line.cachedError = '${NotepadErrorPrefix.evaluation}Error: $e';
      line.cachedFreeVars = [];
      line.cachedExports = {};
    }
  }

  /// Build a name path through a cycle for display. Picks the line
  /// names along one back-edge walk; if no name exists for a node
  /// (a plain expression with no assignment), falls back to its
  /// `lineN` alias.
  List<String> _cycleNamePath(
    int start,
    NotepadDependencyGraph graph,
    NotepadDocument doc,
    int firstCode,
  ) {
    final path = <String>[];
    final visited = <int>{};
    var current = start;
    while (true) {
      path.add(_displayNameFor(current, doc, firstCode));
      if (visited.contains(current)) break;
      visited.add(current);
      final deps = graph.dependsOn[current] ?? const <int>{};
      // Walk into the first dependency that's also a cycle node;
      // if none, break (shouldn't happen for cycle participants
      // but guards against malformed input).
      final cycleDeps =
          deps.where((idx) => visited.contains(idx) || idx == start).toList();
      if (cycleDeps.isEmpty) {
        // Fall back to any dependency to surface SOMETHING in the
        // error path — this branch is mostly defensive.
        if (deps.isEmpty) break;
        current = deps.first;
      } else {
        current = cycleDeps.first;
      }
      if (path.length > doc.lines.length + 2) break; // safety bound
    }
    return path;
  }

  String _displayNameFor(int index, NotepadDocument doc, int firstCode) {
    final parsed = classifyNotepadLine(doc.lines[index].source,
        lineIndex: index, firstCodeLineIndex: firstCode);
    if (parsed.kind == NotepadLineKind.assignment) return parsed.name!;
    return 'line${index + 1}';
  }

  /// Scope keys (variable names) are stable across a single eval pass —
  /// they depend on line source text, not cached results. Cache them to
  /// avoid O(N) buildNotepadScope per blocked line.
  Set<String>? _scopeKeysCache;

  Set<String> _scopeKeysFor(NotepadDocument doc, int firstCode) {
    return _scopeKeysCache ??=
        notepadScopeNames(doc, externalScope: externalScope);
  }
}
