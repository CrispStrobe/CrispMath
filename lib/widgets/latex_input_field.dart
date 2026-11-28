// lib/widgets/latex_input_field.dart
// Enhanced LaTeX input field that properly handles dialog-inserted LaTeX

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../controllers/latex_controller.dart';
import 'dart:async';
import '../utils/math_display_utils.dart';

class LatexInputField extends StatefulWidget {
  const LatexInputField({super.key, required this.controller});

  final LatexController controller;

  @override
  State<LatexInputField> createState() => _LatexInputFieldState();
}

class _LatexInputFieldState extends State<LatexInputField> {
  Timer? _cursorTimer;
  final ValueNotifier<bool> _showCursor = ValueNotifier<bool>(true);

  // Typesetting a long expression (LaTeX conversion, Math.tex parse and
  // layout) is the expensive part of this field. The formula halves are
  // cached by text and color, so a rebuild that does not change them (the
  // cursor blink, an unrelated parent rebuild) reuses the same widgets and
  // Flutter skips their subtrees.
  _CachedMath? _before;
  _CachedMath? _after;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _startBlink();
  }

  @override
  void didUpdateWidget(LatexInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  void _startBlink() {
    _cursorTimer?.cancel();
    _showCursor.value = true;
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _showCursor.value = !_showCursor.value;
    });
  }

  void _onControllerChanged() {
    if (!mounted) return;
    // Keep the cursor solid while typing; only the cursor rebuilds for that.
    _startBlink();
    setState(() {});
  }

  @override
  void dispose() {
    _cursorTimer?.cancel();
    widget.controller.removeListener(_onControllerChanged);
    _showCursor.dispose();
    super.dispose();
  }

  Widget _math(_CachedMath? cached, String text, Color color,
      void Function(_CachedMath) store) {
    if (cached != null && cached.text == text && cached.color == color) {
      return cached.widget;
    }
    final built = Math.tex(
      MathDisplayUtils.toHistoryDisplayLatex(text),
      textStyle: TextStyle(fontSize: 40, color: color, height: 1.3),
      mathStyle: MathStyle.display,
      onErrorFallback: (err) {
        // If LaTeX rendering fails, show plain text
        return Text(
          text,
          style:
              TextStyle(fontSize: 40, color: Colors.red.shade300, height: 1.3),
        );
      },
    );
    store(_CachedMath(text, color, built));
    return built;
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.controller.selection;
    final text = widget.controller.text;
    final cursorPosition = selection.baseOffset.clamp(0, text.length);
    final color = Theme.of(context).colorScheme.onSurface;

    // Split text at cursor position
    final beforeCursor = text.substring(0, cursorPosition);
    final afterCursor = text.substring(cursorPosition);

    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      alignment: Alignment.centerRight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (beforeCursor.isNotEmpty)
              _math(_before, beforeCursor, color, (c) => _before = c),
            // A blink repaints only this 2-pixel layer, not the formula.
            RepaintBoundary(
              child: ValueListenableBuilder<bool>(
                valueListenable: _showCursor,
                builder: (context, visible, _) => Container(
                  width: 2,
                  height: 50,
                  color: visible ? color : Colors.transparent,
                ),
              ),
            ),
            if (afterCursor.isNotEmpty)
              _math(_after, afterCursor, color, (c) => _after = c),
          ],
        ),
      ),
    );
  }
}

class _CachedMath {
  const _CachedMath(this.text, this.color, this.widget);
  final String text;
  final Color color;
  final Widget widget;
}
