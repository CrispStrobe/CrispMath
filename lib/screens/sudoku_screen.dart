// lib/screens/sudoku_screen.dart
//
// Analysis-hub Sudoku solver module. It shows how a puzzle is solved
// algorithmically rather than offering a game to play. UX flow:
//
//   1. User picks a preset puzzle (size + difficulty), generates one, or
//      taps cells to enter the clues of their own puzzle.
//   2. Solve runs [SudokuExplainer], which records every step with its
//      reason: naked or hidden single, cage sum, locked candidates,
//      naked or hidden pair/triple, guess, contradiction or backtrack,
//      plus the pencil marks after the step.
//   3. The visualizer starts on the first step; the user steps through
//      or plays the replay. Each frame names the reason, tints the units
//      it reasoned about, outlines the cells it reasoned from, crosses
//      out the candidates it removed and shows the rest. A summary counts
//      every technique, and a search tree draws the guesses.
//
// A puzzle the explainer cannot handle (a Killer without cages) falls
// back to the generic CSP trace from [SudokuSolver.solveWithTrace].
//
// V1 supports 4×4 and 9×9 grids. PLAN.md tracks the variant
// roadmap (6×6, 8×8, 10×10, 12×12, 15×15, 16×16, 25×25,
// irregular regions, killer).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/app_state.dart';
import '../engine/sudoku.dart';
import '../engine/sudoku_explainer.dart';
import '../localization/app_localizations.dart';
import '../widgets/function_ref_help_popover.dart';
import '../widgets/help_target.dart';
import '../widgets/module_help_dialog.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/sudoku_search_tree.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  // Round 95 (P6): the field initialiser stays on `standard9x9Easy`
  // so the existing "open without args" entry point is unchanged.
  // `initState` may overwrite this if the user got here via an
  // `open:sudoku?preset=<id>` worked-example sentinel.
  SudokuPuzzle _puzzle = SudokuPresets.standard9x9Easy;
  // Clues are captured at puzzle load so the visualizer can tell
  // user/preset values apart from solver-filled ones. Round 87:
  // NEVER re-captured on user edit — before round 87, every user
  // entry was being added to _clueIndexes so the user couldn't
  // overwrite their own digits.
  late Set<int> _clueIndexes = _captureClueIndexes(_puzzle);
  // Live editable cells. Mutated by tap-to-enter and by the
  // visualizer when replaying frames.
  late List<int> _displayed = List<int>.from(_puzzle.cells);

  /// Round 87: focus node for cell-keyboard input. When a cell is
  /// selected, pressing a digit key fills it; Backspace / Delete /
  /// 0 clears it; arrow keys move the selection.
  final FocusNode _keyboardFocus = FocusNode();

  int? _selected;
  SudokuTrace? _trace;

  /// Phone layout only: scrolls the narrow list so the grid and the
  /// replay controls are visible right after a solve.
  final ScrollController _scrollController = ScrollController();

  /// Explained steps behind [_trace] (one per frame), or null for the
  /// Killer CSP replay.
  SudokuExplanation? _explanation;
  int _frameIndex = 0;
  Timer? _ticker;
  bool _playing = false;
  bool _solving = false;
  bool _generating = false;
  SudokuHintLevel _hintLevel = SudokuHintLevel.off;
  // Advanced (SAC-pruned) candidates for the current displayed grid.
  // Null when not yet computed for the current grid. Lifecycle:
  //   - Invalidated to null on any puzzle / displayed-cells change.
  //   - Recomputed asynchronously when [_hintLevel] is advanced.
  //   - The request-id pattern below cancels stale in-flight
  //     computes so a fast sequence of edits only commits the
  //     latest result.
  List<Set<int>>? _advancedCandidates;
  bool _computingAdvanced = false;
  int _advancedRequestId = 0;
  // Round 108: kills the in-flight advanced-hint isolate when a newer
  // edit supersedes it, so stale computes don't keep burning CPU.
  void Function()? _advancedCancel;
  SudokuDifficulty _genDifficulty = SudokuDifficulty.easy;
  _Speed _speed = _Speed.medium;

  /// Round 65: uniqueness check result for the *currently displayed*
  /// puzzle. Null when not yet computed (or cleared on any edit /
  /// preset switch). True = exactly one solution; false = zero or
  /// many. The check is opt-in via a "Check uniqueness" button
  /// because for non-unique 9×9 (e.g. killer9x9) it can take
  /// seconds to confirm.
  bool? _unique;
  bool _checkingUnique = false;

  /// V2: when the user picks a different size or variant via the
  /// top selectors (not via a preset), we wipe the grid. Round 87:
  /// instead of falling to an empty grid, look for a preset
  /// matching the new (layout, variant) first — so the "Rätsel"
  /// dropdown stays in sync. Only when no preset exists for the
  /// combination do we fall through to an empty grid (which lets
  /// the user compose their own).
  ///
  /// V3-Killer: an empty Killer puzzle is invalid (the cages
  /// list is required), so Killer mode always loads a preset.
  void _switchLayoutOrVariant(
      SudokuLayout? newLayout, SudokuVariant? newVariant) {
    final layout = newLayout ?? _puzzle.layout;
    final variant = newVariant ?? _puzzle.variant;
    // Round 109: re-picking the chip that is already active is a
    // no-op. The pickers fire even for the selected chip, and this
    // method used to re-resolve the very same (layout, variant) to a
    // preset — silently replacing the user's edited or generated grid
    // (clues included) and stopping the replay.
    if (layout.side == _puzzle.layout.side &&
        layout.boxRows == _puzzle.layout.boxRows &&
        layout.boxCols == _puzzle.layout.boxCols &&
        variant == _puzzle.variant) {
      return;
    }
    _stopVisualizer();
    // Round 87: try to find a preset that matches the new (layout,
    // variant) exactly. If found, load it — keeps the preset
    // dropdown showing the active entry. Falls through to an empty
    // grid only when no preset matches the combination.
    final match = SudokuPresets.all.where((p) =>
        p.puzzle.layout.side == layout.side && p.puzzle.variant == variant);
    if (match.isNotEmpty) {
      _loadPreset(match.first.puzzle);
      return;
    }
    if (variant == SudokuVariant.killer) {
      // Killer can't be empty — fall back to any Killer preset.
      final any = SudokuPresets.all
          .firstWhere((p) => p.puzzle.variant == SudokuVariant.killer);
      _loadPreset(any.puzzle);
      return;
    }
    final empty = SudokuPuzzle(
      layout: layout,
      cells: List<int>.filled(layout.side * layout.side, 0),
      variant: variant,
    );
    setState(() {
      _puzzle = empty;
      _clueIndexes = {};
      _displayed = List<int>.from(empty.cells);
      _selected = null;
      _trace = null;
      _explanation = null;
      _frameIndex = 0;
      _unique = null;
      _advancedCandidates = null;
    });
    _maybeRecomputeAdvanced();
  }

  @override
  void initState() {
    super.initState();
    // Round 95 (P6): drain a pending sudoku preset id stashed by
    // a worked-example `open:sudoku?preset=<id>` sentinel. Match
    // against `SudokuPresets.all` and replace the default puzzle
    // before the first build. Unknown ids degrade gracefully —
    // the field initialiser's standard9x9Easy stays in effect.
    final pendingPreset = AppState().consumePendingSudokuPresetId();
    if (pendingPreset != null) {
      for (final entry in SudokuPresets.all) {
        if (entry.id == pendingPreset) {
          _puzzle = entry.puzzle;
          _clueIndexes = _captureClueIndexes(_puzzle);
          _displayed = List<int>.from(_puzzle.cells);
          break;
        }
      }
    }
    _syncGeneratorDifficultyToPreset();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _advancedCancel?.call(); // kill any in-flight advanced-hint isolate
    _scrollController.dispose();
    _keyboardFocus.dispose();
    super.dispose();
  }

  Set<int> _captureClueIndexes(SudokuPuzzle p) => {
        for (var i = 0; i < p.cells.length; i++)
          if (p.cells[i] != 0) i,
      };

  /// The difficulty a preset was published with, or null when the
  /// preset does not state one (the Killer cages have no difficulty
  /// tier, and their generation is disabled anyway).
  static SudokuDifficulty? _presetDifficulty(String id) {
    switch (id) {
      case 'small4x4Easy':
      case 'standard9x9Easy':
      case 'standard9x9XEasy':
        return SudokuDifficulty.easy;
      case 'small4x4Hard':
      case 'standard9x9Hard':
        return SudokuDifficulty.hard;
      case 'small4x4Medium':
      case 'medium6x6':
      case 'eight8x8':
      case 'eight8x8X':
      case 'eight8x8Disjoint':
      case 'eight8x8Killer':
      case 'ten10x10':
      case 'twelve12x12':
      case 'fifteen15x15':
      case 'standard9x9Medium':
        return SudokuDifficulty.medium;
      default:
        return null;
    }
  }

  /// The generator chips describe the next generated puzzle, so they
  /// follow a preset's published difficulty instead of leaving a
  /// default "Medium" highlighted under a hard preset. A custom or
  /// generated grid keeps the user's own generator choice.
  void _syncGeneratorDifficultyToPreset() {
    for (final entry in SudokuPresets.all) {
      if (!identical(entry.puzzle, _puzzle)) continue;
      final difficulty = _presetDifficulty(entry.id);
      if (difficulty != null) _genDifficulty = difficulty;
      return;
    }
  }

  void _loadPreset(SudokuPuzzle p) {
    _stopVisualizer();
    setState(() {
      _puzzle = p;
      _clueIndexes = _captureClueIndexes(p);
      _displayed = List<int>.from(p.cells);
      _selected = null;
      _trace = null;
      _explanation = null;
      _frameIndex = 0;
      _unique = null;
      _advancedCandidates = null;
      _syncGeneratorDifficultyToPreset();
    });
    _maybeRecomputeAdvanced();
  }

  void _onTapCell(int idx) {
    setState(() => _selected = idx);
    // Round 87: keep keyboard focus on the screen so digit keys
    // route to _setDigit rather than getting lost.
    _keyboardFocus.requestFocus();
  }

  /// Round 87: write digit [d] (or clear, when null/0) into the
  /// currently selected cell. Originally re-captured _clueIndexes
  /// on every edit so user entries became un-editable clues — the
  /// re-capture is now removed. _clueIndexes only changes via
  /// _loadPreset / _generate / _switchLayoutOrVariant.
  void _setDigit(int? d) {
    final sel = _selected;
    if (sel == null) return;
    if (_clueIndexes.contains(sel)) return; // preset clue — read-only
    setState(() {
      _displayed[sel] = d ?? 0;
      _puzzle = _puzzle.withCell(
          sel ~/ _puzzle.layout.side, sel % _puzzle.layout.side, d ?? 0);
      _trace = null;
      _explanation = null;
      _frameIndex = 0;
      _unique = null;
      _advancedCandidates = null;
    });
    _maybeRecomputeAdvanced();
  }

  /// Round 87: invoked by [DragTarget<int>] on a cell when the user
  /// drops a digit from the [_DigitPad]. The selection moves to
  /// the drop target so subsequent keyboard input lands on the
  /// same cell.
  void _onDropDigitOnCell(int idx, int? digit) {
    if (_clueIndexes.contains(idx)) return;
    setState(() => _selected = idx);
    _setDigit(digit);
  }

  Future<void> _generate() async {
    _stopVisualizer();
    setState(() => _generating = true);
    // Use the current puzzle's layout as the target so the user's
    // 4×4 / 9×9 selection drives generation too.
    final puzzle = await SudokuGenerator.generate(
      layout: _puzzle.layout,
      difficulty: _genDifficulty,
      variant: _puzzle.variant,
    );
    if (!mounted) return;
    setState(() {
      _generating = false;
      _puzzle = puzzle;
      _clueIndexes = _captureClueIndexes(puzzle);
      _displayed = List<int>.from(puzzle.cells);
      _selected = null;
      _trace = null;
      _explanation = null;
      _frameIndex = 0;
      _unique = null;
      _advancedCandidates = null;
    });
    _maybeRecomputeAdvanced();
  }

  /// Solve and open the step visualizer. Explained solves start on the
  /// first step so each reason can be read; the Killer CSP replay
  /// auto-plays as before (its frames carry no reasons to read).
  Future<void> _solve() async {
    _stopVisualizer();
    setState(() => _solving = true);
    SudokuExplanation? explanation;
    SudokuTrace trace;
    if (SudokuExplainer.supports(_puzzle)) {
      explanation = SudokuExplainer.explain(_puzzle);
      trace = SudokuTrace(
        frames: [
          for (final step in explanation.steps)
            SudokuTraceFrame(
              assigned: step.cells,
              justChangedIndex: step.kind == SudokuStepKind.contradiction
                  ? null
                  : step.cell,
            ),
        ],
        solution: explanation.solution,
        error: explanation.error,
      );
    } else {
      trace = await SudokuSolver.solveWithTrace(_puzzle);
    }
    if (!mounted) return;
    setState(() {
      _solving = false;
      _trace = trace;
      _explanation = explanation;
      _frameIndex = 0;
      if (trace.frames.isNotEmpty) {
        _displayed = List<int>.from(trace.frames.first.assigned);
      }
    });
    if (explanation == null && trace.solved && trace.frames.length > 1) {
      _playPause();
    }
    _revealReplay();
  }

  void _showFrame(int i) {
    final trace = _trace;
    if (trace == null) return;
    setState(() {
      _stopVisualizer();
      _frameIndex = i.clamp(0, trace.frames.length - 1);
      _displayed = List<int>.from(trace.frames[_frameIndex].assigned);
    });
  }

  Future<void> _checkUnique() async {
    setState(() => _checkingUnique = true);
    // Capture the puzzle snapshot at click time so a later edit
    // doesn't attribute the result to a different state.
    final snapshot = _puzzle;
    final result = await SudokuSolver.hasUniqueSolution(snapshot);
    if (!mounted) return;
    // Only commit the result if the puzzle hasn't changed in the
    // meantime — otherwise the indicator would be misleading.
    if (!identical(_puzzle, snapshot)) {
      setState(() => _checkingUnique = false);
      return;
    }
    setState(() {
      _checkingUnique = false;
      _unique = result;
    });
  }

  /// Switches the hint level. Off and basic are pure UI decisions
  /// (rendering branches off `_hintLevel`); advanced additionally
  /// kicks off the async SAC-pruning compute below.
  void _setHintLevel(SudokuHintLevel level) {
    setState(() {
      _hintLevel = level;
      // Drop any cached advanced result so a flip to advanced
      // forces a fresh compute against the current grid (rather
      // than briefly flashing a stale set from a previous puzzle).
      _advancedCandidates = null;
    });
    _maybeRecomputeAdvanced();
  }

  /// Recompute advanced hints if (and only if) advanced mode is on
  /// and the visualizer isn't replaying a trace. Uses a monotonic
  /// request id so a sequence of quick edits cancels stale results
  /// — only the latest in-flight compute commits to state.
  ///
  /// Round 108: the compute now runs on a background isolate. A newer
  /// edit kills the previous worker outright ([_advancedCancel]) instead
  /// of letting a stale, uninterruptible solve run to completion, so the
  /// UI isolate stays free and CPU isn't wasted on abandoned results.
  Future<void> _maybeRecomputeAdvanced() async {
    if (_hintLevel != SudokuHintLevel.advanced || _trace != null) {
      return;
    }
    _advancedCancel?.call();
    final id = ++_advancedRequestId;
    setState(() => _computingAdvanced = true);
    final livePuzzle = SudokuPuzzle(
      layout: _puzzle.layout,
      cells: _displayed,
      variant: _puzzle.variant,
      cages: _puzzle.cages,
    );
    final handle = SudokuSolver.computeCandidatesPrunedInBackground(livePuzzle);
    _advancedCancel = handle.cancel;
    final result = await handle.result;
    if (!mounted || id != _advancedRequestId) return;
    setState(() {
      _computingAdvanced = false;
      _advancedCancel = null;
      // A cancelled/failed compute returns null — keep the prior hints
      // rather than blanking them.
      if (result != null) _advancedCandidates = result;
    });
  }

  void _stopVisualizer() {
    _ticker?.cancel();
    _ticker = null;
    _playing = false;
  }

  void _playPause() {
    if (_trace == null) return;
    if (_playing) {
      setState(_stopVisualizer);
      return;
    }
    // If we're at the end, snap to start so play starts fresh.
    if (_frameIndex >= _trace!.frames.length - 1) {
      _frameIndex = 0;
      _displayed = List<int>.from(_trace!.frames.first.assigned);
    }
    setState(() => _playing = true);
    _ticker = Timer.periodic(_speed.interval, (_) => _advance());
  }

  void _advance() {
    if (_trace == null) return;
    if (_frameIndex >= _trace!.frames.length - 1) {
      setState(_stopVisualizer);
      return;
    }
    setState(() {
      _frameIndex++;
      _displayed = List<int>.from(_trace!.frames[_frameIndex].assigned);
    });
  }

  void _restart() {
    if (_trace == null) return;
    setState(() {
      _stopVisualizer();
      _frameIndex = 0;
      _displayed = List<int>.from(_trace!.frames.first.assigned);
    });
  }

  void _setSpeed(_Speed s) {
    setState(() => _speed = s);
    if (_playing) {
      _ticker?.cancel();
      _ticker = Timer.periodic(s.interval, (_) => _advance());
    }
  }

  /// Phone layout: after a solve the list is parked on the setup form, so
  /// scroll back to the grid. The replay block sits directly below it,
  /// giving board and reason in one viewport.
  void _revealReplay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (MediaQuery.sizeOf(context).width >= 720) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  /// Round 87: keyboard handler. Digit keys (1..9, plus 0 = clear)
  /// fill the selected cell. Backspace / Delete also clear. Arrow
  /// keys move the selection. Returns "handled" so the event
  /// doesn't bubble to other listeners (e.g. the AppBar).
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final side = _puzzle.layout.side;

    // Digit input: '1'..'9' + numpad. For 16×16 the user reaches
    // 10..16 via drag-and-drop from the digit pad (single-key
    // 10..16 is ambiguous on a regular keyboard).
    const digitKeys = <(int, LogicalKeyboardKey, LogicalKeyboardKey)>[
      (1, LogicalKeyboardKey.digit1, LogicalKeyboardKey.numpad1),
      (2, LogicalKeyboardKey.digit2, LogicalKeyboardKey.numpad2),
      (3, LogicalKeyboardKey.digit3, LogicalKeyboardKey.numpad3),
      (4, LogicalKeyboardKey.digit4, LogicalKeyboardKey.numpad4),
      (5, LogicalKeyboardKey.digit5, LogicalKeyboardKey.numpad5),
      (6, LogicalKeyboardKey.digit6, LogicalKeyboardKey.numpad6),
      (7, LogicalKeyboardKey.digit7, LogicalKeyboardKey.numpad7),
      (8, LogicalKeyboardKey.digit8, LogicalKeyboardKey.numpad8),
      (9, LogicalKeyboardKey.digit9, LogicalKeyboardKey.numpad9),
    ];
    for (final entry in digitKeys) {
      final (digit, top, numpad) = entry;
      if (digit > side) break;
      if (key == top || key == numpad) {
        _setDigit(digit);
        return KeyEventResult.handled;
      }
    }
    if (key == LogicalKeyboardKey.digit0 ||
        key == LogicalKeyboardKey.numpad0 ||
        key == LogicalKeyboardKey.backspace ||
        key == LogicalKeyboardKey.delete) {
      _setDigit(null);
      return KeyEventResult.handled;
    }
    // Arrow keys move the selection by one cell.
    final sel = _selected;
    if (sel != null) {
      var r = sel ~/ side, c = sel % side;
      if (key == LogicalKeyboardKey.arrowLeft && c > 0) {
        setState(() => _selected = r * side + (c - 1));
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowRight && c < side - 1) {
        setState(() => _selected = r * side + (c + 1));
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowUp && r > 0) {
        setState(() => _selected = (r - 1) * side + c);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowDown && r < side - 1) {
        setState(() => _selected = (r + 1) * side + c);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final layout = _puzzle.layout;
    final isWide = MediaQuery.of(context).size.width >= 720;
    final highlightIdx =
        _trace == null ? null : _trace!.frames[_frameIndex].justChangedIndex;

    // V3/Round 73: pencil-mark candidates per empty cell against
    // the *displayed* grid. Always disabled while the visualizer is
    // replaying a trace (two competing "what's in this cell"
    // overlays is confusing).
    //
    //   - `basic` runs the cheap synchronous eliminator on every
    //     build, so candidates stay live as the user edits.
    //   - `advanced` uses the SAC-pruned set cached in
    //     `_advancedCandidates`. While that's being recomputed
    //     (after an edit or a level flip) we fall back to the basic
    //     set so the grid never blanks — the spinner subtitle below
    //     tells the user a tighter set is on the way.
    final step = _explanation?.steps[_frameIndex];
    List<Set<int>>? candidates = step?.candidates;
    if (_hintLevel != SudokuHintLevel.off && _trace == null) {
      final livePuzzle = SudokuPuzzle(
        layout: layout,
        cells: _displayed,
        variant: _puzzle.variant,
        cages: _puzzle.cages,
      );
      if (_hintLevel == SudokuHintLevel.advanced &&
          _advancedCandidates != null) {
        candidates = _advancedCandidates;
      } else {
        candidates = SudokuSolver.computeCandidates(livePuzzle);
      }
    }

    // Round 88: compute conflicts against the live displayed grid
    // so the SudokuGrid can red-wash any cell participating in a
    // constraint violation. Skip during visualizer playback (the
    // mid-frame solver state legitimately has duplicates the user
    // shouldn't see flagged).
    // An explained contradiction marks the cell left without candidates.
    final conflicts = _trace == null
        ? SudokuSolver.computeConflicts(_puzzle, _displayed)
        : {
            if (step?.kind == SudokuStepKind.contradiction) ...[
              if (step?.cell != null) step!.cell!,
              if (step?.cageSum != null) ...step!.focusCells,
            ],
          };

    final gridBlock = Padding(
      padding: const EdgeInsets.all(16),
      child: SudokuGrid(
        layout: layout,
        cells: _displayed,
        clueIndexes: _clueIndexes,
        selectedIndex: _selected,
        highlightIndex: highlightIdx,
        candidates: candidates,
        cages: _puzzle.cages,
        onTapCell: _onTapCell,
        // Round 87: drag-and-drop digit entry from the digit
        // pad. Non-null digit fills the cell; null clears it.
        // Wired only when the visualizer isn't active.
        onDropDigit: _trace == null ? _onDropDigitOnCell : null,
        conflictIndexes: conflicts,
        unitIndexes: step == null
            ? null
            : {...?step.unit?.cells, ...?step.secondUnit?.cells},
        focusIndexes: step?.focusCells.toSet(),
        struckCandidates: step == null || step.removed.isEmpty
            ? null
            : step.removedCandidates,
      ),
    );

    final controlsBlock = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SizeVariantPickers(
            layout: _puzzle.layout,
            variant: _puzzle.variant,
            onLayoutChanged: (l) => _switchLayoutOrVariant(l, null),
            onVariantChanged: (v) => _switchLayoutOrVariant(null, v),
            labels: t,
          ),
          const SizedBox(height: 12),
          _PresetPicker(
            current: _puzzle,
            onPick: _loadPreset,
            labelOf: (p) => _localizedPresetLabel(t, p),
          ),
          const SizedBox(height: 12),
          _GeneratorRow(
            difficulty: _genDifficulty,
            generating: _generating,
            // Killer generation isn't shipped in V1 — cage
            // partition + per-cage sum is a separate solver
            // pass. Keep the controls visible but disabled so
            // the UX is consistent across variants.
            disabled: _puzzle.variant == SudokuVariant.killer,
            onDifficulty: (d) => setState(() => _genDifficulty = d),
            onGenerate: _generate,
            labels: t,
          ),
          const SizedBox(height: 16),
          Text(t.sudokuEnterClues,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          _DigitPad(
            side: layout.side,
            onPress: _setDigit,
          ),
          const SizedBox(height: 8),
          _HintLevelPicker(
            level: _hintLevel,
            computing: _computingAdvanced,
            onChanged: _setHintLevel,
            labels: t,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _solving ? null : _solve,
            icon: _solving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(t.sudokuSolveButton),
          ),
          const SizedBox(height: 8),
          // Wrap rather than Row so a narrow right panel can flow
          // the chip below the button instead of overflowing.
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              OutlinedButton.icon(
                onPressed: _checkingUnique ? null : _checkUnique,
                icon: _checkingUnique
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.fingerprint, size: 18),
                label: Text(t.sudokuCheckUnique),
              ),
              if (_unique != null)
                Chip(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: _unique!
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Theme.of(context).colorScheme.errorContainer,
                  label: Text(
                    _unique!
                        ? t.sudokuUniqueSolution
                        : t.sudokuMultipleSolutions,
                    style: TextStyle(
                      color: _unique!
                          ? Theme.of(context).colorScheme.onSecondaryContainer
                          : Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    // One replay block, rendered under the grid on phones and at the
    // bottom of the side panel from tablet width up. Building it once
    // keeps a single set of play/step controls.
    final replayBlock = _trace == null
        ? null
        : _ReplayBlock(
            trace: _trace!,
            explanation: _explanation,
            frameIndex: _frameIndex,
            playing: _playing,
            speed: _speed,
            caption: _captionForFrame(t, _trace!, _frameIndex),
            side: _puzzle.layout.side,
            labels: t,
            onPlayPause: _playPause,
            onRestart: _restart,
            onScrub: _showFrame,
            onStep: (delta) => _showFrame(_frameIndex + delta),
            onSpeed: _setSpeed,
            onSelectStep: _showFrame,
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(t.moduleSudokuTitle),
        actions: const [ModuleHelpButton(kind: ModuleHelpKind.sudoku)],
      ),
      // Round 87: Focus + onKeyEvent wrap so digit / arrow / delete
      // keys land on _handleKey when the user has selected a cell.
      // autofocus true so the user can start typing without an
      // initial tap on the screen background.
      body: Focus(
        focusNode: _keyboardFocus,
        autofocus: true,
        onKeyEvent: _handleKey,
        child: isWide
            ? Row(
                children: [
                  Expanded(child: gridBlock),
                  SizedBox(
                    width: 360,
                    // Round 70: the right panel got taller after the
                    // uniqueness chip + variant picker landed. Wrap in
                    // a scroll view so short windows don't overflow
                    // the column at the bottom.
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          controlsBlock,
                          if (replayBlock != null)
                            Padding(
                              key: const ValueKey('sudoku-replay-section'),
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: replayBlock,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            // Phone/narrow layout: grid, then the replay and its reason,
            // then the setup controls. The replay must be reachable
            // without scrolling past the whole setup form.
            : ListView(
                controller: _scrollController,
                children: [
                  gridBlock,
                  if (replayBlock != null)
                    Padding(
                      key: const ValueKey('sudoku-replay-section'),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: replayBlock,
                    ),
                  controlsBlock,
                ],
              ),
      ),
    );
  }

  String _localizedPresetLabel(AppLocalizations t, SudokuPuzzle p) {
    // Match by identity — the presets are constants.
    for (final preset in SudokuPresets.all) {
      if (identical(preset.puzzle, p)) {
        return t.sudokuPresetLabel(preset.id);
      }
    }
    // Custom (user-entered) — call it "custom".
    return t.sudokuPresetCustom;
  }

  /// Round 81: format the constraint-context caption for the
  /// visualizer's current frame. Joins every overlay the just-
  /// assigned cell sits in into a " · "-separated string. Returns
  /// the localized "starting position" caption for the very first
  /// frame (no cell has changed yet).
  String _captionForFrame(
    AppLocalizations t,
    SudokuTrace trace,
    int frameIndex,
  ) {
    final step = _explanation?.steps[frameIndex];
    if (step != null) return _explainStep(t, step, _puzzle.layout.side);
    final frame = trace.frames[frameIndex];
    final idx = frame.justChangedIndex;
    if (idx == null) return t.sudokuConstraintStartingPosition;
    final ctx = _puzzle.contextAt(idx);
    final parts = <String>[
      t.sudokuConstraintRow(ctx.row),
      t.sudokuConstraintCol(ctx.col),
      t.sudokuConstraintBox(ctx.box),
      if (ctx.cageIndex != null && ctx.cageSum != null)
        t.sudokuConstraintCage(ctx.cageIndex!, ctx.cageSum!),
      if (ctx.onMainDiagonal) t.sudokuConstraintMainDiagonal,
      if (ctx.onAntiDiagonal) t.sudokuConstraintAntiDiagonal,
      if (ctx.disjointGroup != null)
        t.sudokuConstraintDisjointGroup(ctx.disjointGroup!),
    ];
    return parts.join(' · ');
  }
}

/// One explained step in words. Cells use the common r3c5 notation.
String _explainStep(AppLocalizations t, SudokuExplainedStep step, int side) {
  String cell(int i) => 'r${i ~/ side + 1}c${i % side + 1}';
  String cells(List<int> list) => list.map(cell).join(', ');
  String digits(List<int> list) => list.join(', ');
  String unit(SudokuUnit u) => switch (u.kind) {
        SudokuUnitKind.row => t.sudokuConstraintRow(u.number),
        SudokuUnitKind.column => t.sudokuConstraintCol(u.number),
        SudokuUnitKind.box => t.sudokuConstraintBox(u.number),
        SudokuUnitKind.mainDiagonal => t.sudokuConstraintMainDiagonal,
        SudokuUnitKind.antiDiagonal => t.sudokuConstraintAntiDiagonal,
        SudokuUnitKind.disjointGroup =>
          t.sudokuConstraintDisjointGroup(u.number),
      };
  switch (step.kind) {
    case SudokuStepKind.start:
      return t.sudokuStepStart(step.cells.where((v) => v != 0).length);
    case SudokuStepKind.nakedSingle:
      return t.sudokuStepNakedSingle(
          cell(step.cell!), step.value!, step.eliminations);
    case SudokuStepKind.hiddenSingle:
      return t.sudokuStepHiddenSingle(
          unit(step.unit!), step.value!, cell(step.cell!));
    case SudokuStepKind.cageCombination:
      return t.sudokuStepCage(
          step.cageSum!,
          step.focusCells.length,
          step.combinations.map((c) => '{${c.join(', ')}}').join(' '),
          step.eliminations);
    case SudokuStepKind.lockedCandidates:
      return t.sudokuStepLocked(step.digits.single, unit(step.unit!),
          unit(step.secondUnit!), step.removed.length);
    case SudokuStepKind.nakedSubset:
      return t.sudokuStepNakedSubset(step.focusCells.length,
          cells(step.focusCells), digits(step.digits), unit(step.unit!),
          step.eliminations);
    case SudokuStepKind.hiddenSubset:
      return t.sudokuStepHiddenSubset(step.digits.length, digits(step.digits),
          unit(step.unit!), cells(step.focusCells), step.eliminations);
    case SudokuStepKind.guess:
      return step.alternatives.isEmpty
          ? t.sudokuStepLastOption(cell(step.cell!), step.value!)
          : t.sudokuStepGuess(
              cell(step.cell!), step.value!, step.alternatives.join(', '));
    case SudokuStepKind.contradiction:
      if (step.cageSum != null) {
        return t.sudokuStepContradictionCage(step.cageSum!);
      }
      return step.cell != null
          ? t.sudokuStepContradictionCell(cell(step.cell!))
          : t.sudokuStepContradictionUnit(unit(step.unit!), step.value!);
    case SudokuStepKind.backtrack:
      return t.sudokuStepBacktrack(cell(step.cell!));
    case SudokuStepKind.solved:
      return t.sudokuStepSolved;
  }
}

/// Solve statistics under the visualizer.
class _ExplanationSummary extends StatelessWidget {
  final SudokuExplanation explanation;
  final AppLocalizations labels;

  const _ExplanationSummary({required this.explanation, required this.labels});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Phone widths carry the explanation as the primary reading, so the
    // summary uses the body size there and the compact size in the side
    // panel. Everything wraps; no fixed heights.
    final style = MediaQuery.sizeOf(context).width < 720
        ? theme.textTheme.bodyMedium
        : theme.textTheme.bodySmall;
    final e = explanation;
    // The localized summaries omit techniques that never occurred, and
    // return an empty string when there are none: no "Guesses 0" line.
    final stats = labels
        .sudokuExplainStats(e.nakedSingles, e.hiddenSingles, e.guesses,
            e.backtracks, e.maxDepth)
        .trim();
    final eliminations = labels
        .sudokuExplainEliminations(
            e.cageSteps, e.lockedCandidates, e.nakedSubsets, e.hiddenSubsets)
        .trim();
    return Column(
      key: const ValueKey('sudoku-explanation-summary'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stats.isNotEmpty) Text(stats, style: style),
        if (eliminations.isNotEmpty) Text(eliminations, style: style),
        if (e.logicOnly) Text(labels.sudokuExplainLogicOnly, style: style),
        if (e.truncated)
          Text(labels.sudokuExplainTruncated(e.steps.length), style: style),
      ],
    );
  }
}

/// Replay controls, current reason, solve summary and search tree. Built
/// once per frame and placed under the grid on phones or in the side
/// panel from tablet width up.
class _ReplayBlock extends StatelessWidget {
  final SudokuTrace trace;
  final SudokuExplanation? explanation;
  final int frameIndex;
  final bool playing;
  final _Speed speed;
  final String caption;
  final int side;
  final AppLocalizations labels;
  final VoidCallback onPlayPause;
  final VoidCallback onRestart;
  final ValueChanged<int> onScrub;
  final ValueChanged<int> onStep;
  final ValueChanged<_Speed> onSpeed;
  final ValueChanged<int> onSelectStep;

  const _ReplayBlock({
    required this.trace,
    required this.explanation,
    required this.frameIndex,
    required this.playing,
    required this.speed,
    required this.caption,
    required this.side,
    required this.labels,
    required this.onPlayPause,
    required this.onRestart,
    required this.onScrub,
    required this.onStep,
    required this.onSpeed,
    required this.onSelectStep,
  });

  @override
  Widget build(BuildContext context) {
    final explanation = this.explanation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _VisualizerControls(
          total: trace.frames.length,
          current: frameIndex,
          playing: playing,
          speed: speed,
          caption: caption,
          onPlayPause: onPlayPause,
          onRestart: onRestart,
          onScrub: onScrub,
          onStep: onStep,
          onSpeed: onSpeed,
          labels: labels,
        ),
        if (explanation != null) ...[
          const SizedBox(height: 8),
          _ExplanationSummary(explanation: explanation, labels: labels),
          if (explanation.tree.isNotEmpty) ...[
            const SizedBox(height: 12),
            SudokuSearchTreeView(
              explanation: explanation,
              currentNode: explanation.steps[frameIndex].node,
              currentStep: frameIndex,
              side: side,
              onSelectStep: onSelectStep,
              labels: labels,
            ),
          ],
        ],
        if (trace.error != null) ...[
          const SizedBox(height: 8),
          Text(trace.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
      ],
    );
  }
}

enum _Speed {
  slow(Duration(milliseconds: 800)),
  medium(Duration(milliseconds: 250)),
  fast(Duration(milliseconds: 50));

  final Duration interval;
  const _Speed(this.interval);
}

/// Round 73: three-level hint mode.
///
/// - `off` — no pencil marks.
/// - `basic` — sync naive elimination (rows / cols / boxes /
///   diagonals / cage residue). Cheap enough to recompute on every
///   keystroke.
/// - `advanced` — async singleton arc consistency via the dart_csp
///   solver. Catches hidden singles + naked pairs / triples that
///   the naive eliminator misses, at the cost of seconds-per-edit
///   on hard 9×9 puzzles. Opt-in only.
enum SudokuHintLevel { off, basic, advanced }

class _PresetPicker extends StatelessWidget {
  final SudokuPuzzle current;
  final ValueChanged<SudokuPuzzle> onPick;
  final String Function(SudokuPuzzle) labelOf;

  const _PresetPicker({
    required this.current,
    required this.onPick,
    required this.labelOf,
  });

  @override
  Widget build(BuildContext context) {
    // Round 109: the field must always display the puzzle that is
    // actually loaded, so the value is derived from [current] here
    // instead of being left to the FormField's own state. `initialValue`
    // only seeds that state once, so a generated, hand-edited or
    // layout-switched grid could leave the field naming a preset it no
    // longer holds — or naming nothing at all. Keying the field on the
    // matched preset re-seeds it whenever the loaded puzzle changes, and
    // the localized "Custom" placeholder names the state in between.
    //
    // Match by identity so the dropdown shows the active preset when
    // one is loaded. Returning a non-item value here trips the
    // DropdownButton "exactly one item with this value" assertion.
    final matched = SudokuPresets.all
        .map((e) => e.puzzle)
        .where((p) => identical(p, current))
        .firstOrNull;
    return DropdownButtonFormField<SudokuPuzzle>(
      key: ObjectKey(matched),
      initialValue: matched,
      isExpanded: true, // round 70: stop long preset labels from
      // overflowing the 360 px right panel; text now ellipsises.
      hint: matched == null
          ? Text(labelOf(current), overflow: TextOverflow.ellipsis)
          : null,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).sudokuPresetLabelChooser,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        for (final preset in SudokuPresets.all)
          DropdownMenuItem(
            value: preset.puzzle,
            child: Text(
              labelOf(preset.puzzle),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (p) {
        if (p != null) onPick(p);
      },
    );
  }
}

/// Round 87: each digit button is also a [Draggable<int>] so the
/// user can drag a digit onto a grid cell instead of select-then-tap.
/// Tapping still works for non-drag users. The clear button drags
/// a null (sentinel via [Draggable<int>] with data = 0; receiver
/// treats 0 as "clear").
class _DigitPad extends StatelessWidget {
  final int side;
  final ValueChanged<int?> onPress;

  const _DigitPad({required this.side, required this.onPress});

  Widget _digitFeedback(BuildContext context, String label) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(6),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var d = 1; d <= side; d++)
          Draggable<int>(
            data: d,
            feedback: _digitFeedback(context, '$d'),
            childWhenDragging: Opacity(
              opacity: 0.4,
              child: _digitButton(context, '$d', () => onPress(d)),
            ),
            child: _digitButton(context, '$d', () => onPress(d)),
          ),
        // Clear button — also draggable. Data 0 = "clear this cell".
        Draggable<int>(
          data: 0,
          feedback: _digitFeedback(context, t.sudokuClearCell),
          childWhenDragging: Opacity(
            opacity: 0.4,
            child: _clearButton(context, t, () => onPress(null)),
          ),
          child: _clearButton(context, t, () => onPress(null)),
        ),
      ],
    );
  }

  Widget _digitButton(BuildContext context, String label, VoidCallback onTap) =>
      SizedBox(
        width: 40,
        height: 40,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: onTap,
          child: Text(label),
        ),
      );

  Widget _clearButton(
          BuildContext context, AppLocalizations t, VoidCallback onTap) =>
      SizedBox(
        height: 40,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.clear, size: 16),
          label: Text(t.sudokuClearCell),
        ),
      );
}

class _VisualizerControls extends StatelessWidget {
  final int total;
  final int current;
  final bool playing;
  final _Speed speed;
  final String caption;
  final VoidCallback onPlayPause;
  final VoidCallback onRestart;
  final ValueChanged<int> onScrub;
  final ValueChanged<int> onStep;
  final ValueChanged<_Speed> onSpeed;
  final AppLocalizations labels;

  const _VisualizerControls({
    required this.total,
    required this.current,
    required this.playing,
    required this.speed,
    required this.caption,
    required this.onPlayPause,
    required this.onRestart,
    required this.onScrub,
    required this.onStep,
    required this.onSpeed,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(labels.sudokuVisualizerHeader,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              Text('${current + 1} / $total',
                  style: const TextStyle(fontFamily: 'monospace')),
            ],
          ),
          // Round 81: constraint-context caption — names the row /
          // column / box / cage / diagonal / disjoint-group overlays
          // the just-assigned cell sits in.
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Semantics(
              // Announce the new reason when replay steps move.
              liveRegion: true,
              child: Text(
                caption,
                style: (MediaQuery.sizeOf(context).width < 720
                        ? Theme.of(context).textTheme.bodyMedium
                        : Theme.of(context).textTheme.bodySmall)
                    ?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Slider(
            min: 0,
            max: (total - 1).toDouble(),
            divisions: total > 1 ? total - 1 : null,
            value: current.toDouble().clamp(0, (total - 1).toDouble()),
            onChanged: (v) => onScrub(v.round()),
          ),
          // Round 87: switched from Row to Wrap. Previous Row
          // overflowed by ~135 px in the 360 px right panel
          // (restart icon + play icon + 12 px gap + 3-segment
          // speed button = ~440 px). Wrap lets the speed segments
          // flow to a second line on narrow panels.
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              IconButton(
                tooltip: labels.sudokuRestart,
                icon: const Icon(Icons.restart_alt),
                onPressed: onRestart,
              ),
              IconButton(
                tooltip: labels.sudokuStepPrevious,
                icon: const Icon(Icons.skip_previous),
                onPressed: current > 0 ? () => onStep(-1) : null,
              ),
              IconButton(
                tooltip: playing ? labels.sudokuPause : labels.sudokuPlay,
                icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                onPressed: onPlayPause,
              ),
              IconButton(
                tooltip: labels.sudokuStepNext,
                icon: const Icon(Icons.skip_next),
                onPressed: current < total - 1 ? () => onStep(1) : null,
              ),
              _speedSelector(context),
            ],
          ),
        ],
      ),
    );
  }

  String _speedLabel(_Speed s) => switch (s) {
        _Speed.slow => labels.sudokuSpeedSlow,
        _Speed.medium => labels.sudokuSpeedMed,
        _Speed.fast => labels.sudokuSpeedFast,
      };

  /// Phones and enlarged text get a compact dropdown for the speed; the
  /// segmented control stays where all three labels fit. Both expose the
  /// same three speeds.
  Widget _speedSelector(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 720 ||
        MediaQuery.textScalerOf(context).scale(14) > 20;
    if (!compact) {
      return SegmentedButton<_Speed>(
        segments: [
          ButtonSegment(
            value: _Speed.slow,
            label: Text(labels.sudokuSpeedSlow),
          ),
          ButtonSegment(
            value: _Speed.medium,
            label: Text(labels.sudokuSpeedMed),
          ),
          ButtonSegment(
            value: _Speed.fast,
            label: Text(labels.sudokuSpeedFast),
          ),
        ],
        selected: {speed},
        onSelectionChanged: (s) => onSpeed(s.first),
      );
    }
    return DropdownButtonHideUnderline(
      child: DropdownButton<_Speed>(
        value: speed,
        isDense: true,
        borderRadius: BorderRadius.circular(6),
        selectedItemBuilder: (context) => [
          for (final s in _Speed.values)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.speed, size: 18),
                const SizedBox(width: 4),
                Text(_speedLabel(s)),
              ],
            ),
        ],
        items: [
          for (final s in _Speed.values)
            DropdownMenuItem(value: s, child: Text(_speedLabel(s))),
        ],
        onChanged: (s) {
          if (s != null) onSpeed(s);
        },
      ),
    );
  }
}

class _SizeVariantPickers extends StatelessWidget {
  final SudokuLayout layout;
  final SudokuVariant variant;
  final ValueChanged<SudokuLayout> onLayoutChanged;
  final ValueChanged<SudokuVariant> onVariantChanged;
  final AppLocalizations labels;

  const _SizeVariantPickers({
    required this.layout,
    required this.variant,
    required this.onLayoutChanged,
    required this.onVariantChanged,
    required this.labels,
  });

  String _sizeLabel(SudokuLayout l) => '${l.side}×${l.side}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Size picker — wrap so 4 segments fit on narrow phones.
        Wrap(
          spacing: 4,
          children: [
            for (final l in SudokuLayout.all)
              ChoiceChip(
                label: Text(_sizeLabel(l)),
                selected: l.side == layout.side,
                onSelected: (_) => onLayoutChanged(l),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Wrap rather than SegmentedButton so the three variant
        // labels can flow to a second line on narrow right panels
        // (round 70: the segmented version overflowed by 80+ px at
        // the standard 360 px panel width).
        Wrap(
          spacing: 4,
          children: [
            // Round 105b (P6): in help mode each variant chip opens
            // the Function Reference popover for that variant's rules
            // instead of switching to it.
            for (final v in SudokuVariant.values)
              HelpTarget(
                onHelpTap: () => showFunctionRefHelpPopover(
                  context,
                  switch (v) {
                    SudokuVariant.regular => 'sudoku_regular',
                    SudokuVariant.x => 'sudoku_x',
                    SudokuVariant.killer => 'sudoku_killer',
                    SudokuVariant.disjoint => 'sudoku_disjoint',
                  },
                ),
                child: ChoiceChip(
                  label: Text(switch (v) {
                    SudokuVariant.regular => labels.sudokuVariantRegular,
                    SudokuVariant.x => labels.sudokuVariantX,
                    SudokuVariant.killer => labels.sudokuVariantKiller,
                    SudokuVariant.disjoint => labels.sudokuVariantDisjoint,
                  }),
                  selected: variant == v,
                  onSelected: (_) => onVariantChanged(v),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _GeneratorRow extends StatelessWidget {
  final SudokuDifficulty difficulty;
  final bool generating;
  final bool disabled;
  final ValueChanged<SudokuDifficulty> onDifficulty;
  final VoidCallback onGenerate;
  final AppLocalizations labels;

  const _GeneratorRow({
    required this.difficulty,
    required this.generating,
    required this.disabled,
    required this.onDifficulty,
    required this.onGenerate,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    // The difficulty chips belong to the generator: the heading keeps
    // them from reading as the loaded preset's difficulty (a hard preset
    // must not appear as "Medium").
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labels.sudokuGenerateSection,
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        // Round 70: Wrap so the difficulty picker + Generate button
        // flow onto a second line on narrow right panels rather than
        // overflowing horizontally.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Wrap(
              spacing: 4,
              children: [
                for (final d in SudokuDifficulty.values)
                  ChoiceChip(
                    label: Text(switch (d) {
                      SudokuDifficulty.easy => labels.sudokuDifficultyEasy,
                      SudokuDifficulty.medium => labels.sudokuDifficultyMedium,
                      SudokuDifficulty.hard => labels.sudokuDifficultyHard,
                    }),
                    selected: difficulty == d,
                    onSelected: disabled ? null : (_) => onDifficulty(d),
                  ),
              ],
            ),
            FilledButton.icon(
              onPressed: (generating || disabled) ? null : onGenerate,
              icon: generating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.shuffle),
              label: Text(labels.sudokuGenerateButton),
            ),
          ],
        ),
      ],
    );
  }
}

/// Round 73: three-state hint-level selector replacing the V3
/// on/off switch. Chips wrap, so it survives the 360 px right
/// panel without overflow. A spinner subtitle appears while the
/// advanced level is recomputing.
class _HintLevelPicker extends StatelessWidget {
  final SudokuHintLevel level;
  final bool computing;
  final ValueChanged<SudokuHintLevel> onChanged;
  final AppLocalizations labels;

  const _HintLevelPicker({
    required this.level,
    required this.computing,
    required this.onChanged,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(labels.sudokuShowHints,
                  style: Theme.of(context).textTheme.titleSmall),
            ),
            Tooltip(
              message: labels.sudokuHintLevelAdvancedHelp,
              child: Icon(
                Icons.help_outline,
                size: 18,
                color: scheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final l in SudokuHintLevel.values)
              ChoiceChip(
                label: Text(switch (l) {
                  SudokuHintLevel.off => labels.sudokuHintLevelOff,
                  SudokuHintLevel.basic => labels.sudokuHintLevelBasic,
                  SudokuHintLevel.advanced => labels.sudokuHintLevelAdvanced,
                }),
                selected: level == l,
                onSelected: (_) => onChanged(l),
              ),
          ],
        ),
        if (computing) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  labels.sudokuHintLevelComputing,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
