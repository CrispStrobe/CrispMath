// lib/widgets/calculator_input_bar.dart
//
// The calculator's LaTeX input row plus its always-visible action
// toolbar (reset focus, backspace, ◀/▶, =/EXE). Extracted from
// CalculatorScreen (Round 108) so the responsive behaviour is unit-
// testable in isolation.
//
// The field is right-bound — new characters appear on the right. On
// wide (tablet / desktop / landscape) layouts the toolbar sits to the
// LEFT of the field, out of the way. On phone-width layouts that fixed
// ~5-button toolbar starved the field so long numbers had no room to
// display, so there the row STACKS: the field takes the full width on
// its own line and the toolbar drops beneath it.

import 'package:flutter/material.dart';

import '../controllers/latex_controller.dart';
import 'latex_input_field.dart';
import '../localization/workflow_localizations.dart';

class CalculatorInputBar extends StatefulWidget {
  const CalculatorInputBar({
    super.key,
    required this.controller,
    required this.onResetFocus,
    required this.onEvaluate,
    this.resultPreview = '',
    this.stackBelowWidth = 480,
  });

  final LatexController controller;

  /// Recovers from a stuck keyboard-focus state (the ↻ button).
  final VoidCallback onResetFocus;

  /// Submits the current expression (the =/EXE button).
  final VoidCallback onEvaluate;

  /// Live "= …" preview shown under the field; hidden when empty.
  final String resultPreview;

  /// Layouts narrower than this (logical px) stack the field above the
  /// toolbar; wider ones keep the single-row form. Phone widths top out
  /// around 430pt, so the 480 default stacks all phones.
  final double stackBelowWidth;

  @override
  State<CalculatorInputBar> createState() => _CalculatorInputBarState();
}

class _CalculatorInputBarState extends State<CalculatorInputBar> {
  late final TextEditingController _editor;
  final _editorFocus = FocusNode();
  bool _plain = false;
  bool _syncing = false;
  LatexController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _editor = TextEditingController();
    _syncFromMath();
    controller.addListener(_syncFromMath);
    _editor.addListener(_syncToMath);
  }

  void _syncFromMath() {
    if (_syncing) return;
    _syncing = true;
    _editor.value = TextEditingValue(
        text: controller.text, selection: controller.selection);
    _syncing = false;
  }

  void _syncToMath() {
    if (_syncing) return;
    _syncing = true;
    controller.setEditingValue(_editor.value);
    _syncing = false;
  }

  @override
  void didUpdateWidget(CalculatorInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(_syncFromMath);
      controller.addListener(_syncFromMath);
      _syncFromMath();
    }
  }

  @override
  void dispose() {
    controller.removeListener(_syncFromMath);
    _editor.removeListener(_syncToMath);
    _editor.dispose();
    _editorFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = WorkflowLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < widget.stackBelowWidth;
        final actions = <Widget>[
          IconButton(
            icon: Icon(_plain ? Icons.functions : Icons.edit_outlined),
            tooltip: t.text(_plain
                ? WorkflowLabel.mathPreview
                : WorkflowLabel.editExpression),
            onPressed: () {
              setState(() => _plain = !_plain);
              if (_plain) {
                _editorFocus.requestFocus();
              } else {
                _editorFocus.unfocus();
              }
            },
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: t.text(WorkflowLabel.resetFocus),
            onPressed: widget.onResetFocus,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.backspace_outlined),
            tooltip: t.text(WorkflowLabel.backspace),
            onPressed: controller.backspace,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: t.text(WorkflowLabel.cursorLeft),
            onPressed: () => controller.moveCursor(-1),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: t.text(WorkflowLabel.cursorRight),
            onPressed: () => controller.moveCursor(1),
            visualDensity: VisualDensity.compact,
          ),
          FilledButton.icon(
            icon: const Icon(Icons.keyboard_return, size: 18),
            label: Semantics(
                label: t.text(WorkflowLabel.evaluate),
                excludeSemantics: true,
                child: const Text('=')),
            onPressed: widget.onEvaluate,
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ];

        final field = Container(
          alignment: Alignment.centerRight,
          constraints: const BoxConstraints(minHeight: 60),
          child: _plain
              ? TextField(
                  controller: _editor,
                  focusNode: _editorFocus,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => widget.onEvaluate(),
                  decoration: InputDecoration(
                      labelText: t.text(WorkflowLabel.expression)),
                )
              : SingleChildScrollView(
                  reverse: true,
                  scrollDirection: Axis.horizontal,
                  child: LatexInputField(controller: controller),
                ),
        );

        final preview = widget.resultPreview.isEmpty
            ? null
            : Container(
                height: 28,
                alignment: Alignment.centerRight,
                child: Text('= ${widget.resultPreview}',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600])),
              );

        if (stack) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: double.infinity, child: field),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
                if (preview != null) preview,
              ],
            ),
          );
        }

        return Container(
          height: 120,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  children: [
                    ...actions,
                    const SizedBox(width: 8),
                    Expanded(child: field),
                  ],
                ),
              ),
              if (preview != null) preview,
            ],
          ),
        );
      },
    );
  }
}
