// lib/screens/notepad/line_row.dart
//
// One worksheet line: source editor row, drag handle and delete button.

part of '../notepad_screen.dart';

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
    // Empty and expression rows keep the same editor ancestry. Reparenting
    // the editor can reset the browser editing element during the input event.
    // Section headings: `## text` — larger, bold, theme-colored.
    // Fold/unfold toggle + hidden-line-count chip when collapsed.
    if (_lineKind == NotepadLineKind.heading) {
      return _maybeHighlight(Padding(
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
      ), context);
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
            padding:
                EdgeInsets.symmetric(vertical: _isBlank ? 2 : 4, horizontal: 8),
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
          padding:
              EdgeInsets.symmetric(vertical: _isBlank ? 2 : 4, horizontal: 8),
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
      // Blank, normal and heading rows place the editor under different
      // parents. Keep its editing connection and focus through those changes.
      key: GlobalObjectKey(controller),
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
