import '../widgets/result_evidence_badge.dart';
// lib/screens/notepad_screen.dart
//
// Phases 4 + 5 of the Notepad V1 plan: UI skeleton (Phase 4) +
// live recalc pipeline (Phase 5) over the data model (Phase 1),
// parser/scope (Phase 2), and dependency-graph evaluator (Phase 3).
//
// Phase 5: every edit schedules a 300 ms-debounced
// `evaluateFrom(doc, lineIndex)`. New edits cancel any in-flight
// engine call via `EngineService.cancelInFlight()` so the worker
// isolate's monotonic run-id drops the stale result. Per-row
// state surfaces a pending indicator while the dispatcher is mid-
// flight. The dispatcher itself wraps `EngineService.evaluateAsync`
// after passing the notepad-preprocessed body through the same
// native-format step the calculator uses
// (`preprocessNativeExpression`) — no global-AppState reach-in
// (those imports land in Phase 6 via the `use` directive).
//
// Strings are intentionally hardcoded English. Phase 8 will pull
// them into `AppLocalizations` across en/de/fr/es with the locale
// non-emptiness test as the guardrail.

import '../widgets/notepad_activity.dart';
import '../widgets/selected_listenable_builder.dart';
import '../services/notepad_dispatcher.dart';
import '../services/worksheet_file.dart';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:printing/printing.dart';

import '../engine/app_state.dart';
import '../engine/linked_graph.dart';
import '../engine/calculator_engine.dart';
import '../widgets/native_bridge_status_listenable.dart';
import '../engine/notepad.dart';
import '../localization/workflow_localizations.dart';
import '../engine/notepad_evaluator.dart';
import '../engine/notepad_export.dart';
import '../engine/worksheet_bundle.dart';
import '../widgets/worksheet_export_dialog.dart';
import '../widgets/document_history_dialog.dart';
import '../services/crisp_assist_service_stub.dart'
    if (dart.library.io) '../services/crisp_assist_service.dart';
import '../widgets/crisp_assist_dialog.dart';
import '../widgets/handwriting_input_dialog.dart';
import '../widgets/module_help_dialog.dart';
import '../engine/ocr_provider.dart';
import '../engine/scan_cleanup.dart';
import '../widgets/ocr_capture_dialog.dart';
import 'package:image_picker/image_picker.dart';
import '../engine/notepad_templates.dart';
import '../engine/notepad_undo.dart' as undo;
import '../localization/app_localizations.dart';
import '../utils/error_formatter.dart';
import '../utils/expression_preprocessing_utils.dart';
import '../utils/math_display_utils.dart';
import '../widgets/boolean_chip.dart';
import '../widgets/mini_plot_widget.dart';
import '../widgets/notepad_autocomplete.dart';
import '../widgets/syntax_highlighting_controller.dart';
import '../widgets/function_reference_dialog.dart';
import '../widgets/help_target.dart';
import '../widgets/history_help_modal.dart';
import '../widgets/notepad_manager_dialog.dart';
import '../widgets/store_result_dialogs.dart';
import '../widgets/worked_examples_dialog.dart';

part 'notepad/line_row.dart';
part 'notepad/result_column.dart';

/// Layout breakpoint matching the app shell's nav-rail switch
/// (decision #17). At or above this width the input + result render
/// side-by-side; below, the result stacks under the input.
const double _kSideBySideBreakpoint = 720;

class NotepadScreen extends StatefulWidget {
  const NotepadScreen({super.key, this.onOpenCommands});

  /// Optional: open the shell's command palette, so command search is
  /// reachable by touch from this tab too.
  final VoidCallback? onOpenCommands;

  @override
  State<NotepadScreen> createState() => NotepadScreenState();
}

class NotepadScreenState extends State<NotepadScreen> {
  final AppState _appState = AppState();
  // Round 91: a main-isolate CalculatorEngine purely for the
  // precision-arc pre-pass (pi/e/EulerGamma/sqrt2 with precision,
  // isprime/nextprime/prevprime, factorint). The heavy
  // CAS calls still route through EngineService's worker isolate;
  // this instance is only invoked for short standalone calls that
  // would otherwise hit SymEngine without a precision-arc binding.
  final CalculatorEngine _engine = CalculatorEngine();

  /// Per-line text controllers, keyed by `NotepadLine.id`. Created
  /// lazily on first build and disposed when the line goes away (or
  /// the active doc changes). Holding them in state — rather than
  /// `controller: TextEditingController(text: line.source)` inline —
  /// is required for `ReorderableListView`: reordering rebuilds the
  /// children and an inline controller would lose focus + cursor
  /// position on every keystroke.
  final Map<String, TextEditingController> _controllers = {};

  /// Focus nodes per line.id. Used by the "blocked by line N" chip
  /// to scroll-to and focus the upstream errored line.
  final Map<String, FocusNode> _focusNodes = {};

  /// Tracks the document id whose controllers are currently in
  /// [_controllers] — switching docs disposes the old map and
  /// rebuilds for the new one.
  String? _activeControllerDocId;

  /// Inline rename state. When non-null, the AppBar title swaps to
  /// a TextField pre-filled with the current doc name.
  TextEditingController? _renameController;
  FocusNode? _renameFocus;

  /// Snackbar-undo slot (decision #18). The just-deleted doc or
  /// line lives here until the 5-second snackbar dismisses; the
  /// Undo action restores it.
  _PendingDeletion? _pendingDeletion;

  /// Notepad V2: collapsed heading line IDs. Transient — not persisted.
  final Set<String> _collapsedHeadings = {};

  /// Notepad V2: per-document undo history, keyed by doc id.
  final Map<String, undo.UndoHistory> _undoHistories = {};
  undo.UndoHistory _undoFor(NotepadDocument doc) =>
      _undoHistories.putIfAbsent(doc.id, () => undo.UndoHistory());

  void _dismissPendingLineUndo(NotepadDocument doc) {
    final pending = _pendingDeletion;
    if (pending == null ||
        pending.kind != _PendingDeletionKind.line ||
        pending.doc.id != doc.id) {
      return;
    }
    _pendingDeletion = null;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Scroll controller for the line list so blocked-by chips can
  /// scroll the upstream line into view on tap.
  final ScrollController _listScrollController = ScrollController();

  // --- Phase 5: live recalc ------------------------------------------------

  /// Debounce timer for per-edit recalc (decision #9, 300 ms).
  Timer? _recalcTimer;

  /// Line ids currently being (re-)evaluated — drives the per-row
  /// "pending" visual.
  final Set<String> _pendingLineIds = {};

  // Serialize individual engine commands, but cancel obsolete row batches.
  Future<void>? _activeRecalc;
  NotepadEvaluationCancellation? _recalcCancellation;
  final Map<String, Set<String>> _dirtyLineIds = {};
  int _recalcGeneration = 0;
  int _recalcCompleted = 0, _recalcTotal = 0;
  final ValueNotifier<int> _recalcProgress = ValueNotifier(0);
  bool _recalcFailed = false;
  bool _recalcCancelled = false;

  void _interruptRecalc(NotepadDocument? doc) {
    _recalcGeneration++;
    _recalcCancellation?.cancel();
    if (doc != null) {
      _dirtyLineIds.putIfAbsent(doc.id, () => {}).addAll(_pendingLineIds);
      if (_pendingLineIds.isNotEmpty) {
        for (final line in doc.lines) {
          if (!_pendingLineIds.contains(line.id)) continue;
          line.cachedResult = null;
          line.cachedError = null;
          line.resultEvidence = null;
          line.cachedExports = {};
        }
      }
    }
  }

  void _cancelRecalc() {
    final doc = _currentDoc;
    _recalcTimer?.cancel();
    _interruptRecalc(doc);
    if (doc != null) {
      _persistDoc(doc);
    }
    setState(() {
      _pendingLineIds.clear();
      _recalcFailed = false;
      _recalcCancelled = true;
    });
  }

  /// Snapshot of the global number-format settings we last
  /// evaluated against. When `_onAppStateChanged` sees either
  /// drift, it kicks a full recalc so previously-cached
  /// `cachedResult` strings get re-formatted under the new
  /// setting (the cache stores the already-formatted string, so a
  /// settings change otherwise has no visible effect until the
  /// user edits a line). Tracks `decimalPlaces` (the canonical
  /// int setting) AND the legacy enum to be safe — the slider
  /// can move within "auto" (enum-stable) and we still need a
  /// recalc.
  NumberDisplayFormat? _lastNumberFormat;
  int? _lastDecimalPlaces;

  /// Evaluator is rebuilt per recalc so the `externalScope` reflects
  /// the doc's current `use` directive resolved against
  /// `AppState.userVariables` (Phase 6).

  @override
  void initState() {
    super.initState();
    _lastNumberFormat = _appState.numberFormat;
    _lastDecimalPlaces = _appState.decimalPlaces;
    _appState.notepadChanges.addListener(_onAppStateChanged);
    // On web the SymEngine WASM bridge loads asynchronously; recompute the
    // whole doc once it becomes available so lines that fell back to the
    // pure-Dart subset (or errored) pick up the full CAS.
    nativeBridgeStatusListenable.addListener(_onBridgeStatusChanged);
  }

  @override
  void dispose() {
    _appState.notepadChanges.removeListener(_onAppStateChanged);
    nativeBridgeStatusListenable.removeListener(_onBridgeStatusChanged);
    _recalcTimer?.cancel();
    _interruptRecalc(_currentDoc);
    unawaited(_appState.persistNotepadNow());
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final f in _focusNodes.values) {
      f.dispose();
    }
    _renameController?.dispose();
    _renameFocus?.dispose();
    _listScrollController.dispose();
    _recalcProgress.dispose();
    super.dispose();
  }

  /// The WASM/native bridge flipped state (typically loading → ready on
  /// web). Recompute the active document so stale "requires native" /
  /// pure-Dart-fallback results are replaced by the real CAS answer.
  void _onBridgeStatusChanged() {
    if (!mounted || !nativeBridgeReady) return;
    final doc = _currentDoc;
    if (doc != null) _runRecalc(doc, startIndex: null);
  }

  void _onAppStateChanged() {
    if (!mounted) return;
    // Detect a NumberDisplayFormat change and recompute so cached
    // result strings reflect the new setting. Other AppState
    // notifications (variable edits, doc updates we triggered
    // ourselves) just trigger a repaint via setState.
    if (_lastNumberFormat != _appState.numberFormat ||
        _lastDecimalPlaces != _appState.decimalPlaces) {
      _lastNumberFormat = _appState.numberFormat;
      _lastDecimalPlaces = _appState.decimalPlaces;
      final doc = _currentDoc;
      if (doc != null) {
        _runRecalc(doc, startIndex: null);
      }
    }
    setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Controller lifecycle
  // ---------------------------------------------------------------------------

  /// Rebuild [_controllers] / [_focusNodes] for the doc currently
  /// in focus. Called at the top of build() so the maps always
  /// match the active doc's line set.
  void _syncControllersFor(NotepadDocument? doc) {
    final docId = doc?.id;
    if (_activeControllerDocId != docId) {
      // Doc switched — dispose everything and start fresh.
      for (final c in _controllers.values) {
        c.dispose();
      }
      for (final f in _focusNodes.values) {
        f.dispose();
      }
      _controllers.clear();
      _focusNodes.clear();
      final previousDoc = _appState.notepadDocuments[_activeControllerDocId];
      _interruptRecalc(previousDoc);
      _activeControllerDocId = docId;
      // Phase 5: drop any in-flight recalc tied to the old doc, and
      // re-arm the "initial full-eval on open" trigger for the new doc.
      _recalcTimer?.cancel();
      _pendingLineIds.clear();
      _recalcCancelled = false;
    }
    if (doc == null) return;

    final liveIds = doc.lines.map((l) => l.id).toSet();
    // Prune controllers for lines that have been deleted.
    final stale = _controllers.keys.where((k) => !liveIds.contains(k)).toList();
    for (final id in stale) {
      _controllers.remove(id)?.dispose();
      _focusNodes.remove(id)?.dispose();
    }
    // Create controllers for newly-appeared lines.
    for (final line in doc.lines) {
      if (!_controllers.containsKey(line.id)) {
        final c = SyntaxHighlightingController(text: line.source);
        _controllers[line.id] = c;
      }
      if (!_focusNodes.containsKey(line.id)) {
        _focusNodes[line.id] = FocusNode();
      }
      // Update the controller text if the source changed
      // out-of-band (e.g. undo restored a previous value) and the
      // user isn't actively editing. We compare strings rather
      // than replacing wholesale to avoid clobbering cursor state.
      final c = _controllers[line.id]!;
      if (c.text != line.source && !_focusNodes[line.id]!.hasFocus) {
        c.text = line.source;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Doc lookup helpers
  // ---------------------------------------------------------------------------

  NotepadDocument? get _currentDoc {
    final id = _appState.currentNotepadDocId;
    if (id == null) return null;
    return _appState.notepadDocuments[id];
  }

  /// Other docs sorted alphabetically by name for the ⋮ → Open
  /// submenu. Welcome and the current doc are excluded — Welcome
  /// gets its own menu entry, current is disabled-via-omission.
  List<NotepadDocument> _otherDocsForMenu() {
    final current = _appState.currentNotepadDocId;
    final out = _appState.notepadDocuments.values
        .where((d) => d.id != current && d.id != kWelcomeNotepadDocId)
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return out;
  }

  /// Compute the next "Untitled N" name that isn't already in use.
  /// `Untitled` (no suffix) is preferred when free; otherwise we go
  /// `Untitled 2`, `Untitled 3`, …
  String _nextUntitledName(String base) {
    final used = _appState.notepadDocuments.values.map((d) => d.name).toSet();
    if (!used.contains(base)) return base;
    var n = 2;
    while (used.contains('$base $n')) {
      n++;
    }
    return '$base $n';
  }

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  void _persistDoc(NotepadDocument doc) {
    doc.updatedAt = DateTime.now().toUtc();
    _appState.setNotepadDocument(doc);
  }

  /// Lightweight in-memory update without disk I/O or global rebuild.
  /// Persistence is deferred to the debounced recalc timer.
  void _persistDocLazy(NotepadDocument doc) {
    doc.updatedAt = DateTime.now().toUtc();
    _appState.setNotepadDocument(doc, notify: false);
  }

  void _onLineEdited(NotepadDocument doc, NotepadLine line, String value,
      [int? knownIndex]) {
    if (line.source == value) return;
    _dismissPendingLineUndo(doc);
    final prev = line.source;
    final index = knownIndex ?? doc.lines.indexOf(line);
    final firstCode = firstCodeLineIndexOf(doc);
    final oldParsed = classifyNotepadLine(prev,
        lineIndex: index, firstCodeLineIndex: firstCode);
    final newParsed = classifyNotepadLine(value,
        lineIndex: index, firstCodeLineIndex: firstCode);
    if (oldParsed.name != newParsed.name || oldParsed.kind != newParsed.kind) {
      final graph = buildDependencyGraph(doc);
      _dirtyLineIds
          .putIfAbsent(doc.id, () => {})
          .addAll(downstreamFrom(index, graph).map((i) => doc.lines[i].id));
    }
    line.source = value;
    _undoFor(doc).record(undo.UndoOp(
      kind: undo.UndoOpKind.edit,
      index: index,
      lineId: line.id,
      previousValue: prev,
    ));
    // Drop stale cache immediately so the row stops showing a wrong
    // value during the 300 ms debounce window. The recalc below
    // re-populates it.
    line.cachedResult = null;
    line.resultEvidence = null;
    line.cachedError = null;
    line.cachedFreeVars = [];
    // In-memory only — disk persist deferred to recalc timer.
    _persistDocLazy(doc);
    _recalcProgress.value++;
    if (oldParsed.kind == NotepadLineKind.useDirective ||
        newParsed.kind == NotepadLineKind.useDirective) {
      _scheduleFullRecalc(doc);
    } else {
      _scheduleRecalc(doc, index);
    }
  }

  void _appendLine(NotepadDocument doc) {
    _dismissPendingLineUndo(doc);
    final line = NotepadLine.fresh(source: '');
    doc.lines.add(line);
    _undoFor(doc).record(undo.UndoOp(
      kind: undo.UndoOpKind.insert,
      index: doc.lines.length - 1,
      lineId: line.id,
    ));
    _persistDoc(doc);
    // Focus the new line on the next frame so the user can type.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNodes[line.id]?.requestFocus();
    });
  }

  void _performUndo(NotepadDocument doc, {bool dismissSnackbar = true}) {
    if (dismissSnackbar) _dismissPendingLineUndo(doc);
    final op = _undoFor(doc).undo();
    if (op == null) return;
    final modified = undo.applyUndo(doc, op);
    if (modified) {
      _syncControllersFor(doc);
      _persistDoc(doc);
      setState(() {});
      _scheduleFullRecalc(doc);
    }
  }

  void _performRedo(NotepadDocument doc) {
    _dismissPendingLineUndo(doc);
    final op = _undoFor(doc).redo();
    if (op == null) return;
    final modified = undo.applyRedo(doc, op);
    if (modified) {
      _syncControllersFor(doc);
      _persistDoc(doc);
      setState(() {});
      _scheduleFullRecalc(doc);
    }
  }

  // --- Item 15: Search within document ---

  bool _searchOpen = false;
  String _searchQuery = '';

  void _toggleSearch() {
    setState(() {
      _searchOpen = !_searchOpen;
      if (!_searchOpen) _searchQuery = '';
    });
  }

  Widget _buildDocSidebar() {
    final docs = _appState.notepadDocuments.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final currentId = _appState.currentNotepadDocId;
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            t.notepadManageTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final selected = doc.id == currentId;
              return ListTile(
                dense: true,
                selected: selected,
                selectedTileColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                title: Text(
                  doc.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${doc.lines.length} lines',
                  style: const TextStyle(fontSize: 11),
                ),
                onTap: () => _openDocument(doc.id),
                trailing: doc.id == kWelcomeNotepadDocId
                    ? const Icon(Icons.menu_book,
                        size: 16, semanticLabel: 'Welcome sample')
                    : null,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextButton.icon(
            icon: const Icon(Icons.add, size: 18, semanticLabel: 'Add'),
            label: Text(t.notepadNewDocument),
            onPressed: _newDocument,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(NotepadDocument doc) {
    // Count only rows the user can actually see: a match inside a
    // collapsed section was reported but never highlighted.
    final visible = _visibleLineIndices(doc);
    final matchCount = _searchQuery.isEmpty
        ? 0
        : visible
            .where((i) => _lineMatchesSearch(doc.lines[i]))
            .length;
    final hiddenMatches = _searchQuery.isEmpty
        ? 0
        : doc.lines
                .where((l) => _lineMatchesSearch(l))
                .length -
            matchCount;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search…',
                border: InputBorder.none,
                suffixText: _searchQuery.isEmpty
                    ? ''
                    : hiddenMatches > 0
                        ? '$matchCount shown · $hiddenMatches hidden'
                        : '$matchCount matches',
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close,
                size: 18, semanticLabel: 'Close search'),
            onPressed: _toggleSearch,
          ),
        ],
      ),
    );
  }

  /// Whether a line matches the current search query.
  bool _lineMatchesSearch(NotepadLine line) {
    if (_searchQuery.isEmpty) return false;
    return line.source.toLowerCase().contains(_searchQuery.toLowerCase());
  }

  void _toggleCollapse(String lineId) {
    setState(() {
      if (_collapsedHeadings.contains(lineId)) {
        _collapsedHeadings.remove(lineId);
      } else {
        _collapsedHeadings.add(lineId);
      }
    });
  }

  /// Build the list of line indices that are currently visible
  /// (not hidden under a collapsed heading).
  List<int> _visibleLineIndices(NotepadDocument doc) {
    final visible = <int>[];
    String? collapsedUntilNextHeading;
    for (var i = 0; i < doc.lines.length; i++) {
      final line = doc.lines[i];
      final isHeading = line.source.trim().startsWith('## ');
      if (isHeading) {
        // A heading always shows; it also ends any prior collapse.
        collapsedUntilNextHeading = null;
        visible.add(i);
        if (_collapsedHeadings.contains(line.id)) {
          collapsedUntilNextHeading = line.id;
        }
      } else if (collapsedUntilNextHeading != null) {
        // Hidden under a collapsed heading — skip.
        continue;
      } else {
        visible.add(i);
      }
    }
    return visible;
  }

  int _hiddenLinesUnder(NotepadDocument doc, int headingIndex) {
    var count = 0;
    for (var i = headingIndex + 1; i < doc.lines.length; i++) {
      if (doc.lines[i].source.trim().startsWith('## ')) break;
      count++;
    }
    return count;
  }

  String? _scopeNamesCacheDocId;
  Set<String>? _cachedScopeNames;

  Set<String> _docScopeNames(NotepadDocument doc) {
    if (_scopeNamesCacheDocId == doc.id && _cachedScopeNames != null) {
      return _cachedScopeNames!;
    }
    _scopeNamesCacheDocId = doc.id;
    _cachedScopeNames = notepadScopeNames(doc);
    return _cachedScopeNames!;
  }

  void _invalidateScopeCache() {
    _cachedScopeNames = null;
  }

  void _cycleLineFormat(NotepadDocument doc, NotepadLine line) {
    const formats = LineResultFormat.values;
    final next = formats[(line.resultFormat.index + 1) % formats.length];
    setState(() {
      line.resultFormat = next;
    });
    _persistDoc(doc);
  }

  void _deleteLine(NotepadDocument doc, int index) {
    if (index < 0 || index >= doc.lines.length) return;
    final removed = doc.lines.removeAt(index);
    final deleteOp = undo.UndoOp(
      kind: undo.UndoOpKind.delete,
      index: index,
      lineId: removed.id,
      previousValue: removed.source,
      deletedLine: removed,
    );
    _undoFor(doc).record(deleteOp);
    _persistDoc(doc);
    _pendingDeletion =
        _PendingDeletion.line(doc: doc, line: removed, index: index);
    // Deleting a line that other lines reference invalidates those
    // downstream — recompute from the spot where the line used to live.
    // No-op when the doc is now empty (no recalc target).
    if (doc.lines.isNotEmpty) {
      _scheduleFullRecalc(doc);
    }
    _showUndoSnackbar(
      label: AppLocalizations.of(context).notepadLineDeleted,
      onUndo: () {
        final pending = _pendingDeletion;
        if (pending == null || pending.kind != _PendingDeletionKind.line ||
            !identical(_undoFor(doc).nextUndo, deleteOp)) {
          return;
        }
        _pendingDeletion = null;
        _performUndo(doc, dismissSnackbar: false);
      },
    );
  }

  void _reorderLines(NotepadDocument doc, int oldIndex, int newIndex) {
    _dismissPendingLineUndo(doc);
    // onReorderItem already adjusts newIndex for the removed item.
    final moved = doc.lines.removeAt(oldIndex);
    doc.lines.insert(newIndex, moved);
    _undoFor(doc).record(undo.UndoOp(
      kind: undo.UndoOpKind.reorder,
      index: oldIndex,
      newIndex: newIndex,
      lineId: moved.id,
    ));
    _persistDoc(doc);
    // Positional aliases (`lineN`) shift on reorder; assignment names
    // follow the line. Either way, the safe thing is a full recompute
    // from the lowest affected index.
    _scheduleFullRecalc(doc);
  }

  Future<void> _launchNotepadOcr(BuildContext context) async {
    var provider = OcrProviders.active;

    final layoutProvider = OcrProviders.available
        .where((p) => p.name.contains('Layout'))
        .firstOrNull;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, semanticLabel: 'Camera'),
            title: const Text('Take photo'),
            subtitle: const Text('Single formula'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading:
                const Icon(Icons.photo_library, semanticLabel: 'Photo library'),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
          if (layoutProvider != null)
            ListTile(
              leading: const Icon(Icons.article_outlined,
                  semanticLabel: 'Document page'),
              title: const Text('Document page'),
              subtitle: const Text('Detect layout, OCR formula regions'),
              onTap: () {
                provider = layoutProvider;
                Navigator.pop(ctx, ImageSource.gallery);
              },
            ),
        ]),
      ),
    );
    if (source == null || !mounted) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1024);
    if (picked == null || !mounted) return;

    final bytes = await picked.readAsBytes();

    final activeProvider = provider;
    if (activeProvider == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No OCR provider configured.')),
      );
      return;
    }

    // Try scan cleanup (deskew, crop, whiten) for camera photos.
    final cleaned = await decodeAndCleanup(bytes);
    final Uint8List ocrBytes;
    final int imgWidth;
    final int imgHeight;
    if (cleaned != null) {
      ocrBytes = cleaned.pixels;
      imgWidth = cleaned.width;
      imgHeight = cleaned.height;
    } else {
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      imgWidth = descriptor.width;
      imgHeight = descriptor.height;
      descriptor.dispose();
      buffer.dispose();
      ocrBytes = bytes;
    }
    final result =
        await activeProvider.recognize(ocrBytes, imgWidth, imgHeight);
    if (!context.mounted) return;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OCR failed.')),
      );
      return;
    }

    final expression = await showOcrCaptureDialog(context, result);
    if (expression == null || expression.isEmpty || !context.mounted) return;

    // Insert as a new line in the current doc
    final doc = _currentDoc;
    if (doc != null) {
      final line = NotepadLine.fresh(source: expression);
      doc.lines.add(line);
      _persistDoc(doc);
      _scheduleRecalc(doc, doc.lines.length - 1);
    }
  }

  Future<void> _showTranslateDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        String? translated;
        String? error;
        bool loading = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Row(children: [
              Icon(Icons.auto_awesome,
                  semanticLabel: 'AI', color: cs.primary, size: 20),
              const SizedBox(width: 8),
              const Text('AI Translate'),
            ]),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Describe the math in natural language:',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'e.g. "derivative of x cubed minus 4x"',
                      isDense: true,
                      suffixIcon: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send, size: 18),
                              onPressed: controller.text.trim().isEmpty
                                  ? null
                                  : () {
                                      // Trigger the same onSubmitted logic
                                      final field =
                                          FocusScope.of(ctx).focusedChild;
                                      field?.unfocus();
                                    },
                            ),
                    ),
                    onSubmitted: (_) async {
                      if (controller.text.trim().isEmpty || loading) return;
                      setDialogState(() {
                        loading = true;
                        error = null;
                      });
                      try {
                        final svc = CrispAssistService();
                        final cfg = CrispAssistConfig(
                          apiUrl: AppState().crispAssistApiUrl,
                          apiKey: AppState().crispAssistApiKey,
                          model: AppState().crispAssistModel,
                        );
                        final t = await svc.translate(
                          userInput: controller.text.trim(),
                          config: cfg,
                        );
                        svc.dispose();
                        setDialogState(() {
                          translated = t.trim();
                          loading = false;
                        });
                      } catch (e) {
                        setDialogState(() {
                          error = e.toString();
                          loading = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  if (loading) const Center(child: CircularProgressIndicator()),
                  if (error != null)
                    Text(error!,
                        style: TextStyle(color: cs.error, fontSize: 12)),
                  if (translated != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        translated!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              if (translated != null)
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(translated),
                  child: const Text('Insert'),
                ),
            ],
          ),
        );
      },
    );
    if (result == null || result.isEmpty || !mounted) return;
    final doc = _currentDoc;
    if (doc != null) {
      final line = NotepadLine.fresh(source: result);
      doc.lines.add(line);
      _persistDoc(doc);
      _scheduleRecalc(doc, doc.lines.length - 1);
    }
  }

  void recalculateAll() => _recalculateAll();

  void _newDocument() {
    final base = AppLocalizations.of(context).notepadDefaultDocName;
    final doc = NotepadDocument.fresh(name: _nextUntitledName(base));
    _appState.setNotepadDocument(doc);
    _appState.setCurrentNotepadDoc(doc.id);
  }

  /// Adopt validated source and evaluate after the controller switch completes.
  void openImportedWorksheet(NotepadDocument doc) {
    _recalcTimer?.cancel();
    _interruptRecalc(_currentDoc);
    FocusScope.of(context).unfocus();
    _undoHistories.remove(doc.id);
    _appState.setNotepadDocument(doc);
    _appState.setCurrentNotepadDoc(doc.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _currentDoc?.id == doc.id) _scheduleFullRecalc(doc);
    });
  }

  /// Create the guided a=3, f(x)=x²+a, f(4) worksheet, calculate it and
  /// link f to the graph. Also started from the first-run tour.
  Future<void> exploreLinkedWorksheet() async {
    final labels = WorkflowLocalizations.of(context);
    final doc = NotepadTemplates.connectedWorksheet(
        name: labels.text(WorkflowLabel.connectedWorksheetName));
    _recalcTimer?.cancel();
    _interruptRecalc(_currentDoc);
    FocusScope.of(context).unfocus();
    _appState.setNotepadDocument(doc);
    _appState.setCurrentNotepadDoc(doc.id);
    // scopeRevision also changes when calculation caches update. Guard the
    // ordered source/identity snapshot instead, so real results can complete.
    final sources = [for (final line in doc.lines) (line.id, line.source)];
    bool sourceUnchanged() => doc.lines.length == sources.length &&
        doc.lines.indexed.every((row) =>
            (row.$2.id, row.$2.source) == sources[row.$1]);
    // Let the document/controller switch finish before using the real pipeline.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || _currentDoc?.id != doc.id || !sourceUnchanged()) {
      return;
    }
    _recalcTimer?.cancel();
    final calculation = _runRecalc(doc);
    final generation = _recalcGeneration;
    await calculation;
    if (!mounted || generation != _recalcGeneration ||
        _currentDoc?.id != doc.id || !sourceUnchanged() ||
        doc.lines.any((line) => line.cachedError != null) ||
        doc.lines.last.cachedResult == null) {
      return;
    }
    try {
      _appState.linkNotepadLine(doc.id, doc.lines[1].id, openGraph: false);
    } on StateError catch (error) {
      if (!mounted || _currentDoc?.id != doc.id) return;
      final full = _appState.graphFunctions.every((source) => source.isNotEmpty);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
          full ? labels.text(WorkflowLabel.worksheetGraphFull) :
          labels.text(WorkflowLabel.worksheetLinkFailed, error.message.toString()))));
    }
  }

  /// The graph link that points at a line of [doc], if any. Shared by
  /// the AppBar graph action and the future worksheet rows.
  LinkedGraphSource? _linkedSourceFor(NotepadDocument doc) =>
      _appState.graphLinks.values
          .where((source) =>
              source.documentId == doc.id &&
              doc.lines.any((line) => line.id == source.lineId))
          .firstOrNull;

  Future<void> _openWorksheetFile() async {
    try {
      final doc = await WorksheetFileService.open();
      if (doc == null || !mounted) return;
      openImportedWorksheet(doc);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${AppLocalizations.of(context).notepadFileOpenFailed}: $error')));
    }
  }

  Future<void> _saveWorksheetFile() async {
    final doc = _currentDoc;
    if (doc == null) return;
    try {
      final saved = await WorksheetFileService.save(doc);
      if (!mounted || !saved) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).notepadFileSaved)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${AppLocalizations.of(context).notepadFileSaveFailed}: $error')));
    }
  }

  void _moveLineFocus(NotepadDocument? doc, int offset) {
    if (doc == null || doc.lines.isEmpty) return;
    final current =
        doc.lines.indexWhere((l) => _focusNodes[l.id]?.hasFocus == true);
    final next =
        (current < 0 ? 0 : current + offset).clamp(0, doc.lines.length - 1);
    _focusNodes[doc.lines[next].id]?.requestFocus();
  }

  void _openDocument(String id) {
    _appState.setCurrentNotepadDoc(id);
    final doc = _appState.notepadDocuments[id];
    if (doc == null) return;
    final first = firstCodeLineIndexOf(doc);
    final missing = doc.lines.indexed.any((entry) =>
        entry.$2.cachedResult == null &&
        entry.$2.cachedError == null &&
        const {
          NotepadLineKind.expression,
          NotepadLineKind.assignment,
          NotepadLineKind.aggregate,
          NotepadLineKind.plot
        }.contains(classifyNotepadLine(entry.$2.source,
                lineIndex: entry.$1, firstCodeLineIndex: first)
            .kind));
    if (missing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _currentDoc?.id == doc.id) _scheduleFullRecalc(doc);
      });
    }
  }

  void _openWelcomeSample() {
    if (!_appState.notepadDocuments.containsKey(kWelcomeNotepadDocId)) {
      _appState.setNotepadDocument(buildWelcomeNotepadDocument(
        locale: _appState.locale.languageCode,
      ));
    }
    _appState.setCurrentNotepadDoc(kWelcomeNotepadDocId);
  }

  void _duplicateCurrent() {
    final doc = _currentDoc;
    if (doc == null) return;
    final now = DateTime.now().toUtc();
    final copy = NotepadDocument(
      id: generateNotepadId(),
      name: '${doc.name} (copy)',
      createdAt: now,
      updatedAt: now,
      lines: doc.lines
          .map((l) => NotepadLine(
                id: generateNotepadId(),
                source: l.source,
                cachedResult: l.cachedResult,
                resultEvidence: l.resultEvidence,
                cachedError: l.cachedError,
                cachedFreeVars: List<String>.from(l.cachedFreeVars),
              ))
          .toList(),
    );
    _appState.setNotepadDocument(copy);
    _appState.setCurrentNotepadDoc(copy.id);
  }

  void _deleteCurrent() {
    final doc = _currentDoc;
    if (doc == null) return;
    final previousCurrent = _appState.currentNotepadDocId;
    _appState.deleteNotepadDocument(doc.id);
    _pendingDeletion = _PendingDeletion.doc(
      doc: doc,
      previousCurrentId: previousCurrent,
    );
    _showUndoSnackbar(
      label: AppLocalizations.of(context).notepadDocumentDeleted(doc.name),
      onUndo: () {
        final pending = _pendingDeletion;
        if (pending == null || pending.kind != _PendingDeletionKind.doc) {
          return;
        }
        _appState.setNotepadDocument(pending.doc);
        if (pending.previousCurrentId == pending.doc.id) {
          _appState.setCurrentNotepadDoc(pending.doc.id);
        }
        _pendingDeletion = null;
      },
    );
  }

  void _copyAsMarkdown() {
    final doc = _currentDoc;
    if (doc == null) return;
    final buf = StringBuffer();
    buf.writeln('# ${doc.name}');
    buf.writeln();
    buf.writeln('```');
    for (final line in doc.lines) {
      final src = line.source;
      final res = line.cachedResult;
      if (res != null && res.isNotEmpty) {
        buf.writeln('$src  // → $res');
      } else {
        buf.writeln(src);
      }
    }
    buf.writeln('```');
    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).notepadCopiedAsMarkdown),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _previewExport() {
    final doc = _currentDoc;
    if (doc == null) return;
    final expressions = <String>[];
    final warnings = <String>[];
    for (final entry in _appState.graphLinks.entries) {
      if (entry.value.documentId != doc.id) continue;
      final resolved = _appState.linkedGraphResolution(entry.key);
      if (resolved.error != null) {
        warnings.add('${resolved.source}: ${resolved.error}');
      } else if (resolved.expression != null) {
        expressions.add(resolved.expression!);
      }
    }
    final bundle = WorksheetBundle.capture(doc,
        expressions: expressions, warnings: warnings);
    showDialog<void>(
        context: context,
        builder: (_) => WorksheetExportDialog(bundle: bundle));
  }

  Future<void> _exportPdf() async {
    final doc = _currentDoc;
    if (doc == null) return;
    final pdf = await exportToPdf(doc);
    if (!mounted) return;
    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name: '${doc.name}.pdf',
    );
  }

  // ---------------------------------------------------------------------------
  // Phase 5: dispatcher + recalc scheduling
  // ---------------------------------------------------------------------------

  late final _notepadDispatcher = NotepadDispatcher(
      engine: _engine,
      formatNumber: _appState.formatNumber,
      yieldLocalWork: false);

  /// Resolve the doc's optional `use name1, name2, ...` directive
  /// against the global namespaces (decision #20). Variables in
  /// `AppState.userVariables` are inlined directly into the
  /// document-local scope (a name → value-string map that
  /// [NotepadEvaluator]'s `externalScope` consumes). Unknown names
  /// — neither a global variable nor a user function — bubble up
  /// as an `unknownImport:<name>` error attached to the use line.
  ///
  /// V1 limitation: user functions in `AppState.userFunctions` (which
  /// take arguments) can't be substituted via a flat name → value
  /// map, so they're treated as unknown imports for now. Calling
  /// user functions from inside a notepad doc is a polish item for
  /// Phase 7.
  _UseDirectiveResolution _resolveUseDirective(NotepadDocument doc) {
    final firstCode = firstCodeLineIndexOf(doc);
    if (firstCode < 0) return _UseDirectiveResolution.empty();
    final parsed = classifyNotepadLine(
      doc.lines[firstCode].source,
      lineIndex: firstCode,
      firstCodeLineIndex: firstCode,
    );
    if (parsed.kind != NotepadLineKind.useDirective) {
      return _UseDirectiveResolution.empty();
    }
    // Parse-level errors (invalid identifier, empty list) keep the
    // evaluator's existing handling — we don't second-guess them.
    if (parsed.directiveError != null) {
      return _UseDirectiveResolution(
        useLineIndex: firstCode,
        externalScope: const {},
        unknownImports: const [],
      );
    }
    final scope = <String, String>{};
    final unknown = <String>[];
    for (final name in parsed.imports) {
      final v = _appState.userVariables[name];
      if (v != null) {
        scope[name] = v;
        continue;
      }
      // V1 doesn't support user-function imports; treat as unknown.
      unknown.add(name);
    }
    return _UseDirectiveResolution(
      useLineIndex: firstCode,
      externalScope: scope,
      unknownImports: unknown,
    );
  }

  void _scheduleFullRecalc(NotepadDocument doc) {
    _interruptRecalc(doc);
    _dirtyLineIds
        .putIfAbsent(doc.id, () => {})
        .addAll(doc.lines.map((line) => line.id));
    _recalcTimer?.cancel();
    _recalcTimer = Timer(const Duration(milliseconds: 300), () {
      _runRecalc(doc);
    });
  }

  /// Debounce a recalc starting from [startIndex]. Each fresh
  /// keystroke pushes the firing 300 ms further out.
  void _scheduleRecalc(NotepadDocument doc, int startIndex) {
    if (startIndex < 0 || startIndex >= doc.lines.length) return;
    _interruptRecalc(doc);
    _dirtyLineIds.putIfAbsent(doc.id, () => {}).add(doc.lines[startIndex].id);
    _recalcTimer?.cancel();
    _recalcTimer = Timer(const Duration(milliseconds: 300), () {
      // Flush deferred persistence before recalc.
      _appState.persistNotepadNow();
      _runRecalc(doc, startIndex: startIndex);
    });
  }

  /// Wait for the current command, then run the accumulated edits. Cancelling
  /// the token prevents an obsolete command from committing its late result.
  Future<void> _runRecalc(
    NotepadDocument doc, {
    int? startIndex,
  }) async {
    if (!mounted) return;
    _interruptRecalc(doc);
    if (startIndex != null && startIndex < doc.lines.length) {
      _dirtyLineIds.putIfAbsent(doc.id, () => {}).add(doc.lines[startIndex].id);
    }
    final generation = _recalcGeneration;
    final previous = _activeRecalc;
    final completer = Completer<void>();
    _activeRecalc = completer.future;
    try {
      if (previous != null) await previous;
      if (!mounted || generation != _recalcGeneration) return;
      final cancellation = NotepadEvaluationCancellation();
      _recalcCancellation = cancellation;
      final dirty = _dirtyLineIds.remove(doc.id) ?? <String>{};
      final changed = startIndex == null
          ? null
          : <int>{
              for (var i = 0; i < doc.lines.length; i++)
                if (dirty.contains(doc.lines[i].id)) i,
            };
      await _runRecalcBody(doc,
          changed: changed, cancellation: cancellation, generation: generation);
    } finally {
      completer.complete();
      if (identical(_activeRecalc, completer.future)) _activeRecalc = null;
    }
  }

  Future<void> _runRecalcBody(
    NotepadDocument doc, {
    required Set<int>? changed,
    required NotepadEvaluationCancellation cancellation,
    required int generation,
  }) async {
    if (!mounted) return;

    // Phase 6: resolve `use name1, name2, ...` against AppState
    // before each eval pass so a user variable changing elsewhere
    // is picked up on the next recalc. We set the unknown-import
    // error on the use line up front (before the evaluator runs) —
    // the evaluator's useDirective branch is patched to preserve
    // a pre-existing `useDirective:` error, so this survives the
    // evaluator's pass.
    final useResolution = _resolveUseDirective(doc);
    if (useResolution.useLineIndex >= 0 &&
        useResolution.useLineIndex < doc.lines.length) {
      final useLine = doc.lines[useResolution.useLineIndex];
      if (useResolution.unknownImports.isNotEmpty) {
        useLine.cachedResult = null;
        useLine.cachedError =
            '${NotepadErrorPrefix.useDirective}unknownImport:${useResolution.unknownImports.first}';
        useLine.cachedFreeVars = [];
      } else if (useLine.cachedError != null &&
          useLine.cachedError!.startsWith(NotepadErrorPrefix.useDirective)) {
        // Stale unknown-import from a previous resolution: clear it
        // now since the imports resolve cleanly this time.
        useLine.cachedError = null;
      }
    }

    final progressClock = Stopwatch()..start();
    final evaluator = NotepadEvaluator(
      cancellation: cancellation,
      onProgress: (completed, total, lineId) {
        if (!mounted || generation != _recalcGeneration) return;
        _pendingLineIds.remove(lineId);
        _recalcCompleted = completed;
        _recalcTotal = total;
        if (completed == total || progressClock.elapsedMilliseconds >= 50) {
          _recalcProgress.value++;
          progressClock.reset();
        }
      },
      dispatcher: _notepadDispatcher.evaluate,
      detailedDispatcher: _notepadDispatcher.evaluateDetailed,
      flatzincDispatcher: _notepadDispatcher.solveFlatZinc,
      externalScope: useResolution.externalScope,
    );

    final indices = <int>{};
    if (changed == null) {
      for (var i = 0; i < doc.lines.length; i++) {
        indices.add(i);
      }
    } else {
      final graph = buildDependencyGraph(
        doc,
        externalScope: useResolution.externalScope,
      );
      for (final index in changed) {
        indices.addAll(downstreamFrom(index, graph));
      }
    }
    setState(() {
      _recalcFailed = false;
      _recalcCancelled = false;
      _recalcCompleted = 0;
      _recalcTotal = indices.length;
      _pendingLineIds.clear();
      for (final i in indices) {
        if (i < doc.lines.length) {
          _pendingLineIds.add(doc.lines[i].id);
        }
      }
    });

    try {
      if (changed == null) {
        await evaluator.evaluateAll(doc);
      } else {
        await evaluator.evaluateChanged(doc, changed);
      }
    } on NotepadEvaluationCancelled {
      // A replacement request owns pending rows and persistence now.
      return;
    } catch (_) {
      _recalcFailed = true;
    }

    if (!mounted || generation != _recalcGeneration) return;

    _invalidateScopeCache();
    setState(() {
      _pendingLineIds.clear();
    });
    _persistDoc(doc);
  }

  /// Manual "Recalculate all" entry point from the ⋮ menu — runs a
  /// full evaluateAll() over the current doc. Useful when the user
  /// has just opened a doc shipped without cached values (the
  /// built-in Welcome sample is the main case) or wants to force a
  /// re-eval after toggling a global setting that the dispatcher
  /// reads. Edits during normal use already trigger debounced
  /// per-line recalc via [_scheduleRecalc]; this is the one-shot
  /// catch-all.
  void _recalculateAll() {
    final doc = _currentDoc;
    if (doc == null) return;
    _recalcTimer?.cancel();
    _runRecalc(doc, startIndex: null);
  }

  void _showUndoSnackbar(
      {required String label, required VoidCallback onUndo}) {
    final messenger = ScaffoldMessenger.of(context);
    // clearSnackBars (not hideCurrentSnackBar) so a queued undo from a
    // previous delete cannot resurface after this one has elapsed.
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(label),
        duration: const Duration(seconds: 4),
        // Flutter defaults snackbars with actions to persistent.
        persist: false,
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        action: SnackBarAction(
          label: AppLocalizations.of(context).notepadUndo,
          onPressed: onUndo,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Rename flow
  // ---------------------------------------------------------------------------

  void _startRename() {
    final doc = _currentDoc;
    if (doc == null) return;
    _renameController?.dispose();
    _renameFocus?.dispose();
    _renameController = TextEditingController(text: doc.name);
    _renameFocus = FocusNode();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _renameFocus?.requestFocus();
      _renameController?.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _renameController?.text.length ?? 0,
      );
    });
  }

  void _commitRename() {
    final doc = _currentDoc;
    final controller = _renameController;
    if (doc == null || controller == null) {
      _cancelRename();
      return;
    }
    final newName = controller.text.trim();
    if (newName.isNotEmpty && newName != doc.name) {
      doc.name = newName;
      _persistDoc(doc);
    }
    _cancelRename();
  }

  void _cancelRename() {
    _renameController?.dispose();
    _renameFocus?.dispose();
    _renameController = null;
    _renameFocus = null;
    setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Blocked-by → scroll to upstream
  // ---------------------------------------------------------------------------

  void _scrollToLineId(String lineId) {
    final doc = _currentDoc;
    if (doc == null) return;
    final idx = doc.lines.indexWhere((l) => l.id == lineId);
    if (idx < 0) return;
    _focusNodes[doc.lines[idx].id]?.requestFocus();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final doc = _currentDoc;
    _syncControllersFor(doc);

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        for (final meta in [true, false]) ...{
          SingleActivator(LogicalKeyboardKey.keyN, meta: meta, control: !meta):
              _newDocument,
          SingleActivator(LogicalKeyboardKey.keyO, meta: meta, control: !meta):
              () => unawaited(_openWorksheetFile()),
          SingleActivator(LogicalKeyboardKey.keyS, meta: meta, control: !meta):
              () => unawaited(_saveWorksheetFile()),
          SingleActivator(LogicalKeyboardKey.enter, meta: meta, control: !meta):
              _recalculateAll,
          SingleActivator(LogicalKeyboardKey.enter,
              meta: meta, control: !meta, shift: true): () {
            if (doc != null) _appendLine(doc);
          },
        },
        const SingleActivator(LogicalKeyboardKey.arrowDown, alt: true): () =>
            _moveLineFocus(doc, 1),
        const SingleActivator(LogicalKeyboardKey.arrowUp, alt: true): () =>
            _moveLineFocus(doc, -1),
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true): () {
          if (doc != null) _performUndo(doc);
        },
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true):
            () {
          if (doc != null) _performRedo(doc);
        },
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () {
          if (doc != null) _performUndo(doc);
        },
        const SingleActivator(LogicalKeyboardKey.keyZ,
            control: true, shift: true): () {
          if (doc != null) _performRedo(doc);
        },
        // Item 15: Cmd+F / Ctrl+F opens search.
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true): () {
          if (doc != null) _toggleSearch();
        },
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () {
          if (doc != null) _toggleSearch();
        },
      },
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
            builder: (context, screenConstraints) => Scaffold(
                  appBar: AppBar(
                    title: _buildTitle(doc),
                    actions: _buildActions(doc,
                        compact: screenConstraints.maxWidth < 600),
                  ),
                  body: LayoutBuilder(
                    builder: (context, constraints) {
                      final wideEnough = constraints.maxWidth >= 1000;
                      final docBody = doc == null
                          ? _buildEmptyState()
                          : Column(
                              children: [
                                if (_pendingLineIds.isNotEmpty ||
                                    _recalcFailed ||
                                    _recalcCancelled)
                                  ListenableBuilder(
                                    listenable: _recalcProgress,
                                    builder: (context, _) {
                                      if (_pendingLineIds.isEmpty &&
                                          !_recalcFailed &&
                                          !_recalcCancelled) {
                                        return const SizedBox.shrink();
                                      }
                                      return NotepadActivity(
                                          busy: _pendingLineIds.isNotEmpty,
                                          failed: _recalcFailed,
                                          cancelled: _recalcCancelled,
                                          completed: _recalcCompleted,
                                          total: _recalcTotal,
                                          onCancel: _cancelRecalc,
                                          onRetry: _recalculateAll);
                                    },
                                  ),
                                if (_searchOpen) _buildSearchBar(doc),
                                Expanded(child: _buildDocBody(doc)),
                              ],
                            );
                      if (!wideEnough) return docBody;
                      // Wide layout: left-rail document list + main doc.
                      return Row(
                        children: [
                          SizedBox(
                            width: 240,
                            child: _buildDocSidebar(),
                          ),
                          const VerticalDivider(width: 1),
                          Expanded(child: docBody),
                        ],
                      );
                    },
                  ),
                )),
      ),
    );
  }

  Widget _buildTitle(NotepadDocument? doc) {
    if (doc == null) return const Text('Notepad');
    if (_renameController != null) {
      return TextField(
        controller: _renameController,
        focusNode: _renameFocus,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
        ),
        style: Theme.of(context).textTheme.titleLarge,
        onSubmitted: (_) => _commitRename(),
        onTapOutside: (_) => _commitRename(),
      );
    }
    return InkWell(
      onTap: _startRename,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Text(doc.name),
      ),
    );
  }

  List<Widget> _buildActions(NotepadDocument? doc, {bool compact = false}) {
    final t = AppLocalizations.of(context);
    return [
      // Round 108: module help — explains the live-formula model and the
      // `use` / `fzn:` / `Ans in <unit>` directives.
      const ModuleHelpButton(kind: ModuleHelpKind.notepad),
      // Round 93 (P6): worked-examples library is now reachable from
      // the notepad AppBar rather than buried in Settings. Always
      // visible — discovery is the whole point of this round.
      // Round 94 scopes the surface to notepad so module-bound
      // categories (constraints / sudoku / statistics / units) are
      // hidden from the filter row.
      // OCR camera button
      if (!compact)
        IconButton(
          icon:
              const Icon(Icons.camera_alt_outlined, semanticLabel: 'Scan math'),
          tooltip: 'Scan math',
          onPressed: () => _launchNotepadOcr(context),
        ),
      // Handwriting input
      if (!compact)
        IconButton(
          icon: const Icon(Icons.draw_outlined, semanticLabel: 'Write math'),
          tooltip: 'Write math',
          onPressed: () async {
            final expr = await showHandwritingInputDialog(context);
            if (expr == null || expr.isEmpty || !mounted) return;
            final doc = _currentDoc;
            if (doc != null) {
              final line = NotepadLine.fresh(source: expr);
              doc.lines.add(line);
              _persistDoc(doc);
              _scheduleRecalc(doc, doc.lines.length - 1);
            }
          },
        ),
      if (!compact)
        IconButton(
          icon: const Icon(Icons.picture_as_pdf_outlined,
              semanticLabel: 'Export PDF'),
          tooltip: 'Export as PDF',
          onPressed: () async {
            if (_currentDoc == null) return;
            final pdf = await exportToPdf(_currentDoc!);
            await Printing.layoutPdf(
              onLayout: (format) async => pdf.save(),
              name:
                  _currentDoc!.name.isNotEmpty ? _currentDoc!.name : 'Notepad',
            );
          },
        ),
      if (!compact)
        IconButton(
          icon: const Icon(Icons.menu_book_outlined,
              semanticLabel: 'Worked examples'),
          tooltip: t.workedExamplesTitle,
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => const WorkedExamplesDialog(
              surface: WorkedExamplesSurface.notepad,
            ),
          ),
        ),
      // Worksheet-level actions live here as glyphs instead of a
      // full-width button row: the same actions, no lost line. On a
      // phone the app bar is already crowded, so these stay in the
      // document menu instead of squeezing the title.
      if (!compact && doc != null &&
          doc.lines.any((line) => line.source.trim().isNotEmpty)) ...[
        IconButton(
          icon: const Icon(Icons.history),
          tooltip: WorkflowLocalizations.of(context)
              .text(WorkflowLabel.worksheetHistory),
          onPressed: () => _onMenuSelected('document-history'),
        ),
        IconButton(
          icon: const Icon(Icons.ios_share),
          tooltip: WorkflowLocalizations.of(context)
              .text(WorkflowLabel.worksheetExport),
          onPressed: _previewExport,
        ),
        if (_linkedSourceFor(doc) != null)
          IconButton(
            icon: const Icon(Icons.show_chart),
            tooltip: WorkflowLocalizations.of(context)
                .text(WorkflowLabel.worksheetGraph),
            onPressed: () {
              final linked = _linkedSourceFor(doc);
              if (linked == null) return;
              _linkLine(
                  doc, doc.lines.firstWhere((line) => line.id == linked.lineId));
            },
          ),
      ],
      if (doc != null)
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: t.notepadAddLine,
          onPressed: () => _appendLine(doc),
        ),
      PopupMenuButton<String>(
        tooltip: t.notepadDocumentMenu,
        onSelected: _onMenuSelected,
        itemBuilder: (context) {
          final items = <PopupMenuEntry<String>>[
            PopupMenuItem(value: 'new', child: Text(t.notepadNewDocument)),
            if (doc != null)
              PopupMenuItem(
                value: 'search-document',
                child: Text(WorkflowLocalizations.of(context)
                    .text(WorkflowLabel.searchDocument)),
              ),
            if (widget.onOpenCommands != null)
              PopupMenuItem(
                value: 'search-commands',
                child: Text(WorkflowLocalizations.of(context)
                    .text(WorkflowLabel.searchCommands)),
              ),
            PopupMenuItem(value: 'explore-linked', child: Text(
                WorkflowLocalizations.of(context).text(WorkflowLabel.exploreWorksheet))),
            PopupMenuItem(value: 'open-file', child: Text(t.notepadOpenFile)),
            if (doc != null)
              PopupMenuItem(value: 'save-file', child: Text(t.notepadSaveFile)),
            if (compact) ...[
              const PopupMenuItem(value: 'scan', child: Text('Scan math')),
              const PopupMenuItem(value: 'write', child: Text('Write math')),
              const PopupMenuItem(
                  value: 'examples', child: Text('Worked examples')),
            ],
            // Template picker sub-items.
            for (final tmpl in NotepadTemplates.all)
              PopupMenuItem(
                value: 'template:${tmpl.id}',
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined,
                        size: 16, semanticLabel: 'Template'),
                    const SizedBox(width: 8),
                    Flexible(
                        child:
                            Text(tmpl.name, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
          ];
          final others = _otherDocsForMenu();
          if (others.isNotEmpty) {
            items.add(const PopupMenuDivider());
            for (final d in others) {
              items.add(PopupMenuItem(
                value: 'open:${d.id}',
                child: Text(d.name),
              ));
            }
          }
          items.add(const PopupMenuDivider());
          items.add(PopupMenuItem(
            value: 'open-welcome',
            child: Text(t.notepadOpenWelcomeSample),
          ));
          items.add(PopupMenuItem(
            value: 'manage',
            child: Text(t.notepadManageNotepads),
          ));
          if (doc != null) {
            items.add(const PopupMenuDivider());
            items.add(PopupMenuItem(
              value: 'recalc',
              child: Text(t.notepadRecalculateAll),
            ));
            items.add(PopupMenuItem(
              value: 'rename',
              child: Text(t.notepadRename),
            ));
            items.add(PopupMenuItem(
              value: 'duplicate',
              child: Text(t.notepadDuplicate),
            ));
            items.add(PopupMenuItem(
              value: 'copy-markdown',
              child: Text(t.notepadCopyAsMarkdown),
            ));
            items.add(PopupMenuItem(
              value: 'document-history',
              child: Text(WorkflowLocalizations.of(context).text(WorkflowLabel.worksheetHistory)),
            ));
            items.add(PopupMenuItem(
              value: 'export-preview',
              child: Text(WorkflowLocalizations.of(context).text(WorkflowLabel.worksheetExport)),
            ));
            if (_linkedSourceFor(doc) != null) {
              items.add(PopupMenuItem(
                value: 'open-linked-graph',
                child: Text(WorkflowLocalizations.of(context)
                    .text(WorkflowLabel.worksheetGraph)),
              ));
            }
            items.add(const PopupMenuItem(
              value: 'export-pdf',
              child: Text('Export PDF'),
            ));
            if (AppState().crispAssistEnabled) {
              items.add(const PopupMenuItem(
                value: 'ai-translate',
                child: Text('AI Translate'),
              ));
            }
            items.add(PopupMenuItem(
              value: 'toggle-latex',
              child: Row(children: [
                Icon(
                    doc.useLatexInput
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 18,
                    semanticLabel: doc.useLatexInput ? 'Checked' : 'Unchecked'),
                const SizedBox(width: 8),
                const Flexible(child: Text('LaTeX input')),
              ]),
            ));
            items.add(PopupMenuItem(
              value: 'delete',
              child: Text(t.notepadDeleteDocument),
            ));
          }
          return items;
        },
      ),
    ];
  }

  void _onMenuSelected(String value) async {
    if (value == 'search-commands') {
      widget.onOpenCommands?.call();
      return;
    }
    if (value == 'search-document') {
      if (!_searchOpen) _toggleSearch();
      return;
    }
    if (value == 'open-linked-graph') {
      final doc = _currentDoc;
      final linked = doc == null ? null : _linkedSourceFor(doc);
      if (doc == null || linked == null) return;
      _linkLine(doc, doc.lines.firstWhere((line) => line.id == linked.lineId));
      return;
    }
    if (value == 'explore-linked') {
      await exploreLinkedWorksheet();
      return;
    }
    if (value.startsWith('template:')) {
      final id = value.substring('template:'.length);
      final tmpl = NotepadTemplates.all.firstWhere(
        (t) => t.id == id,
        orElse: () => NotepadTemplates.all.first,
      );
      final doc = tmpl.createDocument();
      _appState.setNotepadDocument(doc);
      _appState.setCurrentNotepadDoc(doc.id);
      return;
    }
    if (value == 'new') {
      _newDocument();
    } else if (value == 'open-file') {
      unawaited(_openWorksheetFile());
    } else if (value == 'save-file') {
      unawaited(_saveWorksheetFile());
    } else if (value == 'scan') {
      _launchNotepadOcr(context);
    } else if (value == 'write') {
      final source = await showHandwritingInputDialog(context);
      if (source == null || source.isEmpty || !mounted || _currentDoc == null) {
        return;
      }
      final doc = _currentDoc!;
      doc.lines.add(NotepadLine.fresh(source: source));
      _persistDoc(doc);
      _scheduleRecalc(doc, doc.lines.length - 1);
    } else if (value == 'examples') {
      showDialog<void>(
          context: context,
          builder: (_) => const WorkedExamplesDialog(
              surface: WorkedExamplesSurface.notepad));
    } else if (value == 'open-welcome') {
      _openWelcomeSample();
    } else if (value == 'manage') {
      showNotepadManagerDialog(context, onSwitchTo: (_) {});
    } else if (value.startsWith('open:')) {
      _openDocument(value.substring('open:'.length));
    } else if (value == 'recalc') {
      _recalculateAll();
    } else if (value == 'rename') {
      _startRename();
    } else if (value == 'duplicate') {
      _duplicateCurrent();
    } else if (value == 'copy-markdown') {
      _copyAsMarkdown();
    } else if (value == 'document-history') {
      if (_currentDoc != null) {
        showDialog<void>(
            context: context,
            builder: (_) => DocumentHistoryDialog(
                currentDocument: () => _currentDoc!,
                onRestore: openImportedWorksheet));
      }
    } else if (value == 'export-preview') {
      _previewExport();
    } else if (value == 'export-pdf') {
      _exportPdf();
    } else if (value == 'ai-translate') {
      _showTranslateDialog(context);
    } else if (value == 'toggle-latex') {
      final doc = _currentDoc;
      if (doc != null) {
        setState(() => doc.useLatexInput = !doc.useLatexInput);
        _persistDoc(doc);
      }
    } else if (value == 'delete') {
      _deleteCurrent();
    }
  }

  Widget _buildEmptyState() {
    final t = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notes,
                size: 64, color: Colors.grey, semanticLabel: 'Notes'),
            const SizedBox(height: 16),
            Text(
              t.notepadEmptyTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(t.notepadEmptyBody, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.add, semanticLabel: 'New'),
                  label: Text(t.notepadNewDocument),
                  onPressed: _newDocument,
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.show_chart),
                  label: Text(WorkflowLocalizations.of(context).text(
                      WorkflowLabel.exploreWorksheet)),
                  onPressed: exploreLinkedWorksheet,
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.menu_book,
                      semanticLabel: 'Welcome sample'),
                  label: Text(t.notepadOpenWelcomeSample),
                  onPressed: _openWelcomeSample,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _linkLine(NotepadDocument doc, NotepadLine line) {
    try {
      _appState.linkNotepadLine(doc.id, line.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is StateError ? e.message : e.toString())));
    }
  }

  Widget _buildDocBody(NotepadDocument doc) {
    final requestedLine = _appState.consumeRequestedNotepadLine();
    if (requestedLine != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToLineId(requestedLine);
          _focusNodes[requestedLine]?.requestFocus();
        }
      });
    }
    return LayoutBuilder(builder: (context, constraints) {
      final sideBySide = constraints.maxWidth >= _kSideBySideBreakpoint;
      // Build visible-line index list, hiding lines under collapsed
      // headings. A heading line is always visible; lines between a
      // collapsed heading and the next heading/divider are hidden.
      final visibleIndices = _visibleLineIndices(doc);

      // Pinned lines render as a sticky section above the scrolling list.
      final pinnedIndices = <int>[
        for (var i = 0; i < doc.lines.length; i++)
          if (doc.lines[i].pinned) i,
      ];

      final listView = ReorderableListView.builder(
        scrollController: _listScrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        buildDefaultDragHandles: false,
        itemCount: visibleIndices.length,
        onReorderItem: (oldVisIdx, newVisIdx) {
          final oldReal = visibleIndices[oldVisIdx];
          final newReal = newVisIdx < visibleIndices.length
              ? visibleIndices[newVisIdx]
              : doc.lines.length;
          _reorderLines(doc, oldReal, newReal);
        },
        itemBuilder: (context, visIdx) {
          final realIndex = visibleIndices[visIdx];
          final line = doc.lines[realIndex];
          final isHeading = line.source.trim().startsWith('## ');
          final isCollapsed = _collapsedHeadings.contains(line.id);
          // Count hidden lines for the collapse chip.
          final hiddenCount =
              isHeading && isCollapsed ? _hiddenLinesUnder(doc, realIndex) : 0;
          return SelectedListenableBuilder(
            key: ValueKey(line.id),
            listenable: _recalcProgress,
            select: () => (
              _pendingLineIds.contains(line.id),
              line.source,
              line.cachedResult,
              line.cachedError,
              line.resultEvidence,
              line.cachedFreeVars,
            ),
            builder: (context) => _NotepadLineRow(
              line: line,
              index: realIndex,
              sideBySide: sideBySide,
              isPending: _pendingLineIds.contains(line.id),
              controller: _controllers[line.id]!,
              focusNode: _focusNodes[line.id]!,
              onChanged: (v) => _onLineEdited(doc, line, v, realIndex),
              onDelete: () => _deleteLine(doc, realIndex),
              onPlot: () => _linkLine(doc, line),
              onScrollToLineId: _scrollToLineId,
              engine: _engine,
              appState: _appState,
              onFormatCycle: () => _cycleLineFormat(doc, line),
              scopeNames: _docScopeNames(doc),
              isCollapsedHeading: isHeading && isCollapsed,
              hiddenLineCount: hiddenCount,
              highlightSearch: _lineMatchesSearch(line),
              useLatexInput: doc.useLatexInput,
              onToggleCollapse:
                  isHeading ? () => _toggleCollapse(line.id) : null,
            ),
          );
        },
      );

      if (pinnedIndices.isEmpty) return listView;

      // Show pinned lines in a non-scrolling section at the top.
      return Column(
        children: [
          ListenableBuilder(
            listenable: _recalcProgress,
            builder: (context, _) => Container(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final pi in pinnedIndices)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.push_pin,
                              size: 14, semanticLabel: 'Pinned'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              doc.lines[pi].source,
                              style: const TextStyle(
                                  fontFamily: 'monospace', fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _pendingLineIds.contains(doc.lines[pi].id)
                                ? '…'
                                : doc.lines[pi].cachedResult ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(child: listView),
        ],
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Row
// ---------------------------------------------------------------------------

class _UseDirectiveResolution {
  final int useLineIndex;
  final Map<String, String> externalScope;
  final List<String> unknownImports;

  const _UseDirectiveResolution({
    required this.useLineIndex,
    required this.externalScope,
    required this.unknownImports,
  });

  factory _UseDirectiveResolution.empty() => const _UseDirectiveResolution(
        useLineIndex: -1,
        externalScope: {},
        unknownImports: [],
      );
}

// ---------------------------------------------------------------------------
// Snackbar-undo state holder
// ---------------------------------------------------------------------------

enum _PendingDeletionKind { doc, line }

class _PendingDeletion {
  final _PendingDeletionKind kind;
  final NotepadDocument doc;
  final NotepadLine? line;
  final int? lineIndex;
  final String? previousCurrentId;

  _PendingDeletion._({
    required this.kind,
    required this.doc,
    this.line,
    this.lineIndex,
    this.previousCurrentId,
  });

  factory _PendingDeletion.doc({
    required NotepadDocument doc,
    required String? previousCurrentId,
  }) =>
      _PendingDeletion._(
        kind: _PendingDeletionKind.doc,
        doc: doc,
        previousCurrentId: previousCurrentId,
      );

  factory _PendingDeletion.line({
    required NotepadDocument doc,
    required NotepadLine line,
    required int index,
  }) =>
      _PendingDeletion._(
        kind: _PendingDeletionKind.line,
        doc: doc,
        line: line,
        lineIndex: index,
      );
}
