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
import '../services/notepad_dispatcher.dart';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:printing/printing.dart';

import '../engine/app_state.dart';
import '../engine/calculator_engine.dart';
import '../widgets/native_bridge_status_listenable.dart';
import '../engine/notepad.dart';
import '../engine/notepad_evaluator.dart';
import '../engine/notepad_export.dart';
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

/// Layout breakpoint matching the app shell's nav-rail switch
/// (decision #17). At or above this width the input + result render
/// side-by-side; below, the result stacks under the input.
const double _kSideBySideBreakpoint = 720;

class NotepadScreen extends StatefulWidget {
  const NotepadScreen({super.key});

  @override
  State<NotepadScreen> createState() => _NotepadScreenState();
}

class _NotepadScreenState extends State<NotepadScreen> {
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

  /// Scroll controller for the line list so blocked-by chips can
  /// scroll the upstream line into view on tap.
  final ScrollController _listScrollController = ScrollController();

  // --- Phase 5: live recalc ------------------------------------------------

  /// Debounce timer for per-edit recalc (decision #9, 300 ms).
  Timer? _recalcTimer;

  /// Line ids currently being (re-)evaluated — drives the per-row
  /// "pending" visual.
  final Set<String> _pendingLineIds = {};

  /// Tail of the active-recalc chain — new requests `await` this so
  /// at most one `_runRecalc` runs at a time. Pre-Phase-5 we tried
  /// to cancel the in-flight engine call with `cancelInFlight()`;
  /// the kill was async and the next `send()` raced against it,
  /// leaving the worker dead but `_commandPort` still pointing at
  /// the dead isolate's port — every dispatcher call then hung
  /// forever. Serialization side-steps that entirely: one request
  /// in flight, no concurrent kill races.
  Future<void>? _activeRecalc;
  bool _recalcFailed = false;

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
      _activeControllerDocId = docId;
      // Phase 5: drop any in-flight recalc tied to the old doc, and
      // re-arm the "initial full-eval on open" trigger for the new doc.
      _recalcTimer?.cancel();
      _pendingLineIds.clear();
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
    final prev = line.source;
    line.source = value;
    final index = knownIndex ?? doc.lines.indexOf(line);
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
    line.cachedError = null;
    line.cachedFreeVars = [];
    // In-memory only — disk persist deferred to recalc timer.
    _persistDocLazy(doc);
    _scheduleRecalc(doc, index);
  }

  void _appendLine(NotepadDocument doc) {
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

  void _performUndo(NotepadDocument doc) {
    final op = _undoFor(doc).undo();
    if (op == null) return;
    final modified = undo.applyUndo(doc, op);
    if (modified) {
      _syncControllersFor(doc);
      _persistDoc(doc);
      setState(() {});
      _scheduleRecalc(doc, 0);
    }
  }

  void _performRedo(NotepadDocument doc) {
    final op = _undoFor(doc).redo();
    if (op == null) return;
    final modified = undo.applyRedo(doc, op);
    if (modified) {
      _syncControllersFor(doc);
      _persistDoc(doc);
      setState(() {});
      _scheduleRecalc(doc, 0);
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
    final matchCount = _searchQuery.isEmpty
        ? 0
        : doc.lines
            .where((l) =>
                l.source.toLowerCase().contains(_searchQuery.toLowerCase()))
            .length;
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
                suffixText: _searchQuery.isEmpty ? '' : '$matchCount matches',
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
    _cachedScopeNames = buildNotepadScope(doc).keys.toSet();
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
    _undoFor(doc).record(undo.UndoOp(
      kind: undo.UndoOpKind.delete,
      index: index,
      lineId: removed.id,
      previousValue: removed.source,
    ));
    _persistDoc(doc);
    _pendingDeletion =
        _PendingDeletion.line(doc: doc, line: removed, index: index);
    // Deleting a line that other lines reference invalidates those
    // downstream — recompute from the spot where the line used to live.
    // No-op when the doc is now empty (no recalc target).
    if (doc.lines.isNotEmpty) {
      final clamped = index < doc.lines.length ? index : doc.lines.length - 1;
      _scheduleRecalc(doc, clamped);
    }
    _showUndoSnackbar(
      label: AppLocalizations.of(context).notepadLineDeleted,
      onUndo: () {
        final pending = _pendingDeletion;
        if (pending == null || pending.kind != _PendingDeletionKind.line) {
          return;
        }
        final lineIdx = pending.lineIndex!.clamp(0, pending.doc.lines.length);
        pending.doc.lines.insert(lineIdx, pending.line!);
        _persistDoc(pending.doc);
        _scheduleRecalc(pending.doc, lineIdx);
        _pendingDeletion = null;
      },
    );
  }

  void _reorderLines(NotepadDocument doc, int oldIndex, int newIndex) {
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
    _scheduleRecalc(doc, oldIndex < newIndex ? oldIndex : newIndex);
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

  void _newDocument() {
    final base = AppLocalizations.of(context).notepadDefaultDocName;
    final doc = NotepadDocument.fresh(name: _nextUntitledName(base));
    _appState.setNotepadDocument(doc);
    _appState.setCurrentNotepadDoc(doc.id);
  }

  void _openDocument(String id) {
    _appState.setCurrentNotepadDoc(id);
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

  late final _notepadDispatcher =
      NotepadDispatcher(engine: _engine, formatNumber: _appState.formatNumber);

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

  /// Debounce a recalc starting from [startIndex]. Each fresh
  /// keystroke pushes the firing 300 ms further out.
  void _scheduleRecalc(NotepadDocument doc, int startIndex) {
    if (startIndex < 0) return;
    _recalcTimer?.cancel();
    _recalcTimer = Timer(const Duration(milliseconds: 300), () {
      // Flush deferred persistence before recalc.
      _appState.persistNotepadNow();
      _runRecalc(doc, startIndex: startIndex);
    });
  }

  /// Run the evaluator for the given starting line (or the whole doc
  /// when [startIndex] is null). Cancels any in-flight engine call,
  /// marks downstream lines as pending so the UI greys their
  /// previous results, then awaits the evaluator. Stale completions
  /// (seq mismatch) get discarded.
  Future<void> _runRecalc(
    NotepadDocument doc, {
    int? startIndex,
  }) async {
    if (!mounted) return;
    // Chain after any previous run so we never have two evaluators
    // (and two engine dispatchers) racing on the same doc.
    final previous = _activeRecalc;
    final completer = Completer<void>();
    _activeRecalc = completer.future;
    if (previous != null) {
      try {
        await previous;
      } catch (_) {/* previous run swallowed its own errors */}
      if (!mounted) {
        completer.complete();
        return;
      }
    }

    try {
      await _runRecalcBody(doc, startIndex: startIndex);
    } finally {
      completer.complete();
      if (identical(_activeRecalc, completer.future)) {
        _activeRecalc = null;
      }
    }
  }

  Future<void> _runRecalcBody(
    NotepadDocument doc, {
    required int? startIndex,
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

    final evaluator = NotepadEvaluator(
      dispatcher: _notepadDispatcher.evaluate,
      flatzincDispatcher: _notepadDispatcher.solveFlatZinc,
      externalScope: useResolution.externalScope,
    );

    final indices = <int>{};
    if (startIndex == null) {
      for (var i = 0; i < doc.lines.length; i++) {
        indices.add(i);
      }
    } else if (startIndex >= 0 && startIndex < doc.lines.length) {
      final graph = buildDependencyGraph(
        doc,
        externalScope: useResolution.externalScope,
      );
      indices.addAll(downstreamFrom(startIndex, graph));
    }
    setState(() {
      _recalcFailed = false;
      _pendingLineIds.clear();
      for (final i in indices) {
        if (i < doc.lines.length) {
          _pendingLineIds.add(doc.lines[i].id);
        }
      }
    });

    try {
      if (startIndex == null) {
        await evaluator.evaluateAll(doc);
      } else if (startIndex >= 0 && startIndex < doc.lines.length) {
        await evaluator.evaluateFrom(doc, startIndex);
      }
    } catch (_) {
      _recalcFailed = true;
    }

    if (!mounted) return;

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
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(label),
        duration: const Duration(seconds: 5),
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
        child: Scaffold(
          appBar: AppBar(
            title: _buildTitle(doc),
            actions: _buildActions(doc),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final wideEnough = constraints.maxWidth >= 1200;
              final docBody = doc == null
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        if (_pendingLineIds.isNotEmpty || _recalcFailed)
                          NotepadActivity(
                              busy: _pendingLineIds.isNotEmpty,
                              failed: _recalcFailed,
                              onRetry: _recalculateAll),
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
        ),
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

  List<Widget> _buildActions(NotepadDocument? doc) {
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
      IconButton(
        icon: const Icon(Icons.camera_alt_outlined, semanticLabel: 'Scan math'),
        tooltip: 'Scan math',
        onPressed: () => _launchNotepadOcr(context),
      ),
      // Handwriting input
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
      IconButton(
        icon: const Icon(Icons.picture_as_pdf_outlined,
            semanticLabel: 'Export PDF'),
        tooltip: 'Export as PDF',
        onPressed: () async {
          if (_currentDoc == null) return;
          final pdf = await exportToPdf(_currentDoc!);
          await Printing.layoutPdf(
            onLayout: (format) async => pdf.save(),
            name: _currentDoc!.name.isNotEmpty ? _currentDoc!.name : 'Notepad',
          );
        },
      ),
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
      // Round 101 (P6): help-mode toggle. Mirrors the Calculator
      // AppBar control so the affordance carries across surfaces.
      ListenableBuilder(
        listenable: _appState.notepadChanges,
        builder: (context, _) {
          final on = _appState.helpMode;
          return IconButton(
            icon: Icon(
              on ? Icons.help : Icons.help_outline,
              semanticLabel: on ? 'Disable help mode' : 'Help mode',
              color: on ? Theme.of(context).colorScheme.primary : null,
            ),
            tooltip: on ? t.helpModeDisableTooltip : t.helpModeEnableTooltip,
            onPressed: _appState.toggleHelpMode,
          );
        },
      ),
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
                const Text('LaTeX input'),
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

  void _onMenuSelected(String value) {
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
          return _NotepadLineRow(
            key: ValueKey(line.id),
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
            onToggleCollapse: isHeading ? () => _toggleCollapse(line.id) : null,
          );
        },
      );

      if (pinnedIndices.isEmpty) return listView;

      // Show pinned lines in a non-scrolling section at the top.
      return Column(
        children: [
          Container(
            color: Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final pi in pinnedIndices)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
                          doc.lines[pi].cachedResult ?? '',
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
          Expanded(child: listView),
        ],
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Row
// ---------------------------------------------------------------------------

final _dividerPattern = RegExp(r'^-{3,}\s*$');

class _NotepadLineRow extends StatelessWidget {
  final NotepadLine line;
  final int index;
  final bool sideBySide;
  final bool isPending;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onDelete;
  final VoidCallback? onPlot;
  final void Function(String lineId) onScrollToLineId;

  /// Round 104b (P6): used by [_showLineHelp] to wire the Show-steps
  /// button on solve / diff / integrate rows. The notepad row didn't
  /// originally carry an engine reference; Round 104 deferred this
  /// wiring, Round 104b threads it through so help mode reaches the
  /// same [StepEngine] trace the Calculator history popover does.
  final CalculatorEngine engine;
  final AppState appState;

  final VoidCallback? onFormatCycle;
  final Set<String> scopeNames;
  final bool isCollapsedHeading;
  final int hiddenLineCount;
  final VoidCallback? onToggleCollapse;
  final bool highlightSearch;
  final bool useLatexInput;

  const _NotepadLineRow({
    super.key,
    required this.line,
    required this.index,
    required this.sideBySide,
    required this.isPending,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onDelete,
    this.onPlot,
    required this.onScrollToLineId,
    required this.engine,
    required this.appState,
    this.onFormatCycle,
    this.scopeNames = const {},
    this.isCollapsedHeading = false,
    this.hiddenLineCount = 0,
    this.onToggleCollapse,
    this.highlightSearch = false,
    this.useLatexInput = false,
  });

  bool get _isBlank => line.source.trim().isEmpty;
  Set<String> get _scopeNames => scopeNames;

  NotepadLineKind get _lineKind {
    // Lightweight classification for rendering — only checks heading
    // and divider patterns (the full classify needs firstCodeLineIndex
    // which we don't carry here).
    final t = line.source.trim();
    if (t.startsWith('## ')) return NotepadLineKind.heading;
    if (_dividerPattern.hasMatch(t)) return NotepadLineKind.divider;
    return NotepadLineKind.expression; // generic fallback
  }

  Widget _maybeHighlight(Widget child, BuildContext context) {
    if (!highlightSearch) return child;
    return Container(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Decision #12: blank rows collapse to a small height. We still
    // render a TextField so the user can type into the empty row,
    // but skip the result column and tighten the padding.
    if (_isBlank) {
      return Padding(
        key: ValueKey('row-${line.id}'),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _DragHandle(index: index),
            Expanded(child: _buildInputField(context, dense: true)),
            _DeleteButton(onPressed: onDelete),
          ],
        ),
      );
    }

    // Section headings: `## text` — larger, bold, theme-colored.
    // Fold/unfold toggle + hidden-line-count chip when collapsed.
    if (_lineKind == NotepadLineKind.heading) {
      return Padding(
        key: ValueKey('row-${line.id}'),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _DragHandle(index: index),
            if (onToggleCollapse != null)
              IconButton(
                icon: Icon(
                  isCollapsedHeading ? Icons.expand_more : Icons.expand_less,
                  size: 20,
                  semanticLabel: isCollapsedHeading
                      ? 'Expand section'
                      : 'Collapse section',
                ),
                onPressed: onToggleCollapse,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 28,
                  minHeight: 28,
                ),
                tooltip: isCollapsedHeading ? 'Expand' : 'Collapse',
              ),
            Expanded(child: _buildInputField(context, heading: true)),
            if (isCollapsedHeading && hiddenLineCount > 0)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text('$hiddenLineCount hidden'),
                  labelStyle: const TextStyle(fontSize: 11),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            _DeleteButton(onPressed: onDelete),
          ],
        ),
      );
    }

    // Horizontal dividers: `---` — render a line instead of result.
    if (_lineKind == NotepadLineKind.divider) {
      return Padding(
        key: ValueKey('row-${line.id}'),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _DragHandle(index: index),
            Expanded(
              child: Column(
                children: [
                  _buildInputField(context, dense: true),
                  const Divider(height: 1, thickness: 1),
                ],
              ),
            ),
            _DeleteButton(onPressed: onDelete),
          ],
        ),
      );
    }

    if (sideBySide) {
      return _maybeHighlight(
          Padding(
            key: ValueKey('row-${line.id}'),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: HelpTarget(
              onHelpTap: () => _showLineHelp(context),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _DragHandle(index: index),
                  Expanded(
                    flex: 3,
                    child: _buildInputField(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _NotepadResultColumn(
                      line: line,
                      isPending: isPending,
                      onScrollToLineId: onScrollToLineId,
                      onFormatCycle: onFormatCycle,
                      engine: engine,
                    ),
                  ),
                  if (!_isBlank && onPlot != null)
                    IconButton(
                        tooltip: 'Link line to graph',
                        icon: const Icon(Icons.show_chart),
                        onPressed: onPlot),
                  _DeleteButton(onPressed: onDelete),
                ],
              ),
            ),
          ),
          context);
    }

    // Stacked layout for narrow screens.
    return _maybeHighlight(
        Padding(
          key: ValueKey('row-${line.id}'),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: HelpTarget(
            onHelpTap: () => _showLineHelp(context),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DragHandle(index: index),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInputField(context),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 4, left: 4, bottom: 4),
                        child: _NotepadResultColumn(
                          line: line,
                          isPending: isPending,
                          onScrollToLineId: onScrollToLineId,
                          alignStart: true,
                          onFormatCycle: onFormatCycle,
                          engine: engine,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isBlank && onPlot != null)
                  IconButton(
                      tooltip: 'Link line to graph',
                      icon: const Icon(Icons.show_chart),
                      onPressed: onPlot),
                _DeleteButton(onPressed: onDelete),
              ],
            ),
          ),
        ),
        context);
  }

  /// Round 104 (P6): help-mode tap on a notepad line opens the shared
  /// [HistoryRowHelpModal]. Reuses the calculator-history routing
  /// table; the line's `source` is the expression, and the modal
  /// surfaces `cachedError` ahead of `cachedResult` so error lines
  /// still display sensibly. Round 104b wires Show-steps via the
  /// shared [runHistoryStepTrace] runner — solve / diff / integrate
  /// rows now re-render the same step-by-step dialog the Calculator
  /// uses.
  void _showLineHelp(BuildContext context) {
    final source = line.source.trim();
    if (source.isEmpty) return;
    final displayed = line.cachedError ?? line.cachedResult ?? '';
    final entry = CalculationEntry(
      expression: source,
      result: displayed,
    );
    final info = detectHistoryHelp(source);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => HistoryRowHelpModal(
        entry: entry,
        info: info,
        onShowSteps: info.hasSteps
            ? () {
                Navigator.of(dialogContext).pop();
                runHistoryStepTrace(
                  context: context,
                  info: info,
                  engine: engine,
                  appState: appState,
                );
              }
            : null,
        onLearnMore: info.refId == null
            ? null
            : () {
                Navigator.of(dialogContext).pop();
                showDialog<void>(
                  context: context,
                  builder: (_) =>
                      FunctionReferenceDialog(initialSearch: info.refId),
                );
              },
      ),
    );
  }

  Widget _buildInputField(BuildContext context,
      {bool dense = false, bool heading = false}) {
    final textField = TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      minLines: 1,
      maxLines: null,
      style: heading
          ? TextStyle(
              fontFamily: 'monospace',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            )
          : const TextStyle(fontFamily: 'monospace', fontSize: 14),
      decoration: InputDecoration(
        isDense: dense,
        border: InputBorder.none,
        hintText: 'line ${index + 1}',
        hintStyle: TextStyle(
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
    // Skip autocomplete for dense/heading/divider rows.
    if (dense || heading) return textField;
    final withAutocomplete = NotepadAutocompleteOverlay(
      controller: controller,
      focusNode: focusNode,
      scopeNames: _scopeNames,
      child: textField,
    );
    // Wrap in DragTarget so dragged results can be dropped into this line.
    final dragTarget = DragTarget<String>(
      onAcceptWithDetails: (details) {
        final value = details.data;
        final text = controller.text;
        final sel = controller.selection;
        final pos = sel.isValid ? sel.start : text.length;
        final before = text.substring(0, pos);
        final after = text.substring(pos);
        final newText = '$before$value$after';
        controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: pos + value.length),
        );
        onChanged(newText);
      },
      builder: (context, candidateData, rejectedData) {
        if (candidateData.isNotEmpty) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: withAutocomplete,
          );
        }
        return withAutocomplete;
      },
    );

    // When LaTeX input is active, show a live-rendered preview of the
    // expression below the text field. Only render when the input
    // contains LaTeX-ish content (backslash commands, braces, carets).
    if (!useLatexInput) return dragTarget;
    final src = controller.text.trim();
    if (src.isEmpty || !RegExp(r'[\\{}\^_]').hasMatch(src)) return dragTarget;
    final latex = MathDisplayUtils.toHistoryDisplayLatex(src);
    Widget preview;
    try {
      preview = Math.tex(
        latex,
        textStyle: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        onErrorFallback: (_) => const SizedBox.shrink(),
      );
    } catch (_) {
      return dragTarget;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        dragTarget,
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: preview,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Drag handle / delete button
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  final int index;
  const _DragHandle({required this.index});

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: index,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          Icons.drag_handle,
          size: 20,
          semanticLabel: 'Drag to reorder',
          color: Colors.grey[600],
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _DeleteButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.close,
          size: 18, semanticLabel: 'Delete line', color: Colors.grey[600]),
      tooltip: AppLocalizations.of(context).notepadDeleteLine,
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
    );
  }
}

// ---------------------------------------------------------------------------
// Result column
// ---------------------------------------------------------------------------

class _NotepadResultColumn extends StatelessWidget {
  final NotepadLine line;
  final bool isPending;
  final void Function(String lineId) onScrollToLineId;
  final bool alignStart;
  final VoidCallback? onFormatCycle;
  final CalculatorEngine engine;

  const _NotepadResultColumn({
    required this.line,
    required this.isPending,
    required this.onScrollToLineId,
    required this.engine,
    this.alignStart = false,
    this.onFormatCycle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final align = alignStart ? Alignment.centerLeft : Alignment.centerRight;
    final textAlign = alignStart ? TextAlign.left : TextAlign.right;

    // Phase 5 pending state: greyed-out previous value (or a small
    // spinner if no previous value to grey) + progress dot.
    if (isPending) {
      return Align(
        alignment: align,
        child: _buildPendingWidget(context, textAlign),
      );
    }

    if (line.cachedError != null) {
      return Align(
        alignment: align,
        child: _buildErrorWidget(context, line.cachedError!, textAlign),
      );
    }

    final rawRes = line.cachedResult;
    // Apply per-line format override if set.
    final res = rawRes != null && line.resultFormat != LineResultFormat.auto
        ? (formatLineResult(rawRes, line.resultFormat) ?? rawRes)
        : rawRes;
    final children = <Widget>[];
    if (res != null && res.isNotEmpty) {
      children.add(_buildResult(context, res, textAlign));
    }
    // Show a small format indicator when a non-auto format is active.
    if (rawRes != null &&
        rawRes.isNotEmpty &&
        line.resultFormat != LineResultFormat.auto) {
      children.add(GestureDetector(
        onTap: onFormatCycle,
        child: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            _formatLabel(line.resultFormat),
            style: TextStyle(
              fontSize: 10,
              color: cs.primary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: textAlign,
          ),
        ),
      ));
    }
    if (line.cachedFreeVars.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          AppLocalizations.of(context)
              .notepadFreeVars(line.cachedFreeVars.join(', ')),
          style: TextStyle(
            fontSize: 11,
            fontStyle: FontStyle.italic,
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: textAlign,
        ),
      ));
    }

    if (children.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: align,
      child: Column(
        crossAxisAlignment:
            alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildPendingWidget(BuildContext context, TextAlign textAlign) {
    final cs = Theme.of(context).colorScheme;
    final res = line.cachedResult;
    final style =
        TextStyle(fontSize: 16, color: cs.onSurface.withValues(alpha: 0.4));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (res != null && res.isNotEmpty)
          Flexible(child: Text(res, style: style, textAlign: textAlign)),
        if (res != null && res.isNotEmpty) const SizedBox(width: 6),
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: cs.primary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildResult(BuildContext context, String res, TextAlign textAlign) {
    final scheme = Theme.of(context).colorScheme;
    // Inline plot: the evaluator stores a `__plot__:` sentinel.
    final plotSpec = PlotSpec.tryParse(res);
    if (plotSpec != null) {
      return MiniPlotWidget(spec: plotSpec, engine: engine);
    }
    // FlatZinc lines (Round E.4) produce multi-line `name = value;`
    // output blocks plus separator markers — Math.tex can't render
    // that, so route them to a monospace SelectableText block. Use
    // the raw line source for detection so we don't have to re-
    // classify (the dispatcher already ran).
    if (line.source.trimLeft().startsWith('fzn:')) {
      return _buildFlatZincResult(context, res);
    }
    // Round 113 (P7): boolean predicates render as the same chip the
    // calculator history uses. `normalizeBooleanResult` lowercases
    // SymEngine's `True`/`False` before they reach the cache, so a
    // simple string match suffices.
    final trimmedRes = res.trim();
    if (trimmedRes == 'true' || trimmedRes == 'false') {
      return BooleanChip(value: trimmedRes == 'true', fontSize: 16);
    }
    final color = scheme.primary;
    final style = TextStyle(fontSize: 16, color: color);
    final latex = MathDisplayUtils.toHistoryDisplayLatex(res);
    Widget body;
    try {
      body = Math.tex(
        latex,
        textStyle: style,
        onErrorFallback: (_) => Text(res, style: style, textAlign: textAlign),
      );
    } catch (_) {
      body = Text(res, style: style, textAlign: textAlign);
    }
    return LongPressDraggable<String>(
      data: res,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            res.length > 30 ? '${res.substring(0, 30)}…' : res,
            style: style.copyWith(fontSize: 14),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: body),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () => _showResultActions(context, res, latex),
        onSecondaryTap: () => _showResultActions(context, res, latex),
        child: body,
      ),
    );
  }

  Widget _buildFlatZincResult(BuildContext context, String res) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => _showResultActions(context, res, res),
      onSecondaryTap: () => _showResultActions(context, res, res),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: SelectableText(
          res,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            color: scheme.onSurface,
          ),
        ),
      ),
    );
  }

  static String _formatLabel(LineResultFormat f) {
    switch (f) {
      case LineResultFormat.auto:
        return '';
      case LineResultFormat.decimal:
        return 'dec';
      case LineResultFormat.fraction:
        return 'frac';
      case LineResultFormat.scientific:
        return 'sci';
      case LineResultFormat.hex:
        return 'hex';
      case LineResultFormat.binary:
        return 'bin';
    }
  }

  void _showResultActions(BuildContext context, String plain, String latex) {
    final t = AppLocalizations.of(context);
    // Round 91: when the line is an assignment (`f = x^2 + 1`), Store
    // as function should bind on the RHS, not the entire source. Parse
    // once so both menu items see the same canonical body.
    final parsed = classifyNotepadLine(
      line.source,
      lineIndex: 0,
      firstCodeLineIndex: 0,
    );
    final functionBody = parsed.kind == NotepadLineKind.assignment
        ? (parsed.body ?? line.source)
        : line.source;
    final freeVars =
        ExpressionPreprocessingUtils.extractFreeVariables(functionBody);
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.content_copy, semanticLabel: 'Copy'),
              title: Text(t.notepadCopyResult),
              onTap: () {
                Clipboard.setData(ClipboardData(text: plain));
                Navigator.of(sheetContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.notepadCopiedResult),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.code, semanticLabel: 'Copy as LaTeX'),
              title: Text(t.notepadCopyAsLatex),
              onTap: () {
                Clipboard.setData(ClipboardData(text: latex));
                Navigator.of(sheetContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.notepadCopiedAsLatex),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.save_alt,
                  semanticLabel: 'Store as variable'),
              title: Text(t.storeAsVariable),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final saved = await StoreResultDialogs.promptStoreAsVariable(
                  context: context,
                  value: plain,
                );
                if (saved != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.storeSavedAs(saved)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            if (AppState().crispAssistEnabled)
              ListTile(
                leading: const Icon(Icons.auto_awesome,
                    semanticLabel: 'Explain with AI'),
                title: const Text('Explain with AI'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  showCrispAssistExplainDialog(
                    context,
                    expression: line.source,
                    result: plain,
                  );
                },
              ),
            if (freeVars.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.functions,
                    semanticLabel: 'Store as function'),
                title: Text(t.storeAsFunction),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final saved = await StoreResultDialogs.promptStoreAsFunction(
                    context: context,
                    expression: functionBody,
                  );
                  if (saved != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t.storeSavedAs(saved)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(
      BuildContext context, String rawError, TextAlign textAlign) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    if (rawError.startsWith(NotepadErrorPrefix.blockedBy)) {
      // blockedBy:<lineId>:<alias>
      final payload = rawError.substring(NotepadErrorPrefix.blockedBy.length);
      final sep = payload.indexOf(':');
      final lineId = sep < 0 ? '' : payload.substring(0, sep);
      final alias = sep < 0 ? payload : payload.substring(sep + 1);
      return ActionChip(
        avatar: Icon(Icons.block,
            size: 16, semanticLabel: 'Blocked', color: cs.error),
        label: Text(
          t.notepadBlockedBy(alias),
          style: TextStyle(color: cs.error, fontSize: 12),
        ),
        onPressed: () => onScrollToLineId(lineId),
      );
    }

    if (rawError.startsWith(NotepadErrorPrefix.circularReference)) {
      final path =
          rawError.substring(NotepadErrorPrefix.circularReference.length);
      return Chip(
        avatar: Icon(Icons.sync_problem,
            size: 16, semanticLabel: 'Circular reference', color: cs.error),
        label: Text(
          t.notepadCycle(path),
          style: TextStyle(color: cs.error, fontSize: 12),
        ),
        backgroundColor: cs.errorContainer.withValues(alpha: 0.3),
      );
    }

    if (rawError.startsWith(NotepadErrorPrefix.useDirective)) {
      final code = rawError.substring(NotepadErrorPrefix.useDirective.length);
      String label;
      if (code.startsWith('unknownImport:')) {
        label = t.notepadUnknownImport(code.substring('unknownImport:'.length));
      } else if (code.startsWith('invalidImport:')) {
        label = t.notepadInvalidImport(code.substring('invalidImport:'.length));
      } else if (code == 'emptyImportList') {
        label = t.notepadEmptyImportList;
      } else {
        label = t.notepadUseDirective(code);
      }
      return Text(
        label,
        style: TextStyle(color: cs.error, fontSize: 12),
        textAlign: textAlign,
      );
    }

    if (rawError.startsWith(NotepadErrorPrefix.evaluation)) {
      final engine = rawError.substring(NotepadErrorPrefix.evaluation.length);
      final formatted = EngineErrorFormatter.format(engine, t);
      return Text(
        formatted,
        style: TextStyle(color: cs.error, fontSize: 12),
        textAlign: textAlign,
      );
    }

    // Unknown prefix — render verbatim.
    return Text(
      rawError,
      style: TextStyle(color: cs.error, fontSize: 12),
      textAlign: textAlign,
    );
  }
}

// ---------------------------------------------------------------------------
// Phase 6: use-directive resolution result
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
