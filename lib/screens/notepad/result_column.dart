// lib/screens/notepad/result_column.dart
//
// The result column beside each worksheet line.

part of '../notepad_screen.dart';

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
    if (line.source.trim().isEmpty) return const SizedBox.shrink();
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
    // A typeset expression cannot wrap like ordinary text. Give it its full
    // intrinsic width and let the user scroll to every term on narrow screens.
    if (body is Math) {
      body = SingleChildScrollView(
        key: ValueKey('notepad-result-scroll:${line.id}'),
        scrollDirection: Axis.horizontal,
        child: body,
      );
    }
    // Speak the complete computed value, including multi-digit math rendered
    // as separate glyph widgets. The label describes the same visible body.
    body = Semantics(
      key: ValueKey('notepad-result:${line.id}'),
      container: true, label: res, excludeSemantics: true, child: body);
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
        child: SingleChildScrollView(
          key: const ValueKey('notepad-result-actions-scroll'),
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
            if (line.resultEvidence != null)
              ListTile(
                leading: const Icon(Icons.info_outline,
                    semanticLabel: 'Result details'),
                title: Text(WorkflowLocalizations.of(context)
                    .text(WorkflowLabel.resultDetails)),
                onTap: () {
                  final evidence = line.resultEvidence!;
                  Navigator.of(sheetContext).pop();
                  showResultEvidenceDialog(context, evidence);
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
