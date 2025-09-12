/// lib/widgets/latex_input_field.dart
/// Enhanced LaTeX input field that properly handles dialog-inserted LaTeX

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
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) setState(() => _showCursor = !_showCursor);
    });
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() => _showCursor = true);
      // Force a rebuild to ensure LaTeX is re-rendered after dialog insertion
      Future.microtask(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _cursorTimer?.cancel();
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  /// Enhanced LaTeX conversion that handles dialog-inserted LaTeX
  String _toLatex(String text) {
    return MathDisplayUtils.toHistoryDisplayLatex(text);
  }

  // legacy version for debug testing
  String _toLatex_old(String text) {
    if (text.isEmpty) return text;
    
    String latex = text;
    
    // Handle LaTeX commands that might be inserted from dialogs
    // These are already in LaTeX format, so we preserve them
    
    // Preserve existing LaTeX commands (don't convert if already LaTeX)
    final latexCommands = [
      r'\int', r'\sqrt', r'\frac', r'\lim', r'\sum', r'\prod',
      r'\sin', r'\cos', r'\tan', r'\ln', r'\log', r'\abs',
      r'\arcsin', r'\arccos', r'\arctan', r'\sinh', r'\cosh', r'\tanh',
      r'\pi', r'\infty', r'\gamma', r'\alpha', r'\beta', r'\theta',
      r'\cdot', r'\times', r'\div', r'\pm', r'\mp'
    ];
    
    bool hasLatexCommands = latexCommands.any((cmd) => latex.contains(cmd));
    
    if (hasLatexCommands) {
      // Text already contains LaTeX commands, minimal processing
      // Just ensure spacing is correct and handle cursor
      latex = latex.replaceAll(r'\|', '|'); // Handle cursor in LaTeX
      return latex;
    }
    
    // Convert plain text to LaTeX (for backward compatibility)
    // Replace standard operators with LaTeX equivalents
    latex = latex.replaceAll('*', r'\cdot ');
    
    // Convert simple fractions like (a)/(b) to \frac{a}{b}
    latex = latex.replaceAllMapped(RegExp(r'\(([^/]+)\)/\(([^/]+)\)'), (m) {
      return r'\frac{' + '${m.group(1)}' + r'}{' + '${m.group(2)}' + r'}';
    });
    
    // Convert simple powers like x^2 to x^{2}
    latex = latex.replaceAllMapped(RegExp(r'([a-zA-Z0-9)]+)\^([a-zA-Z0-9]+)'), (m) {
      return '${m.group(1)}^{${m.group(2)}}';
    });
    
    // Ensure standard functions are rendered upright
    latex = latex.replaceAllMapped(RegExp(r'(\b(sin|cos|tan|ln|log|det|lim|sqrt|abs|exp|gamma)\b)(?![a-zA-Z])'), (m) {
      return '\\${m.group(1)}';
    });
    
    // Handle cursor character
    latex = latex.replaceAll(r'\|', '|');
    
    return latex;
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.controller.selection;
    final text = widget.controller.text;
    final cursorPosition = selection.baseOffset.clamp(0, text.length);
    
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
            // Text before cursor
            if (beforeCursor.isNotEmpty)
              Math.tex(
                _toLatex(beforeCursor),
                textStyle: TextStyle(
                  fontSize: 40,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.3,
                ),
                mathStyle: MathStyle.display,
                onErrorFallback: (err) {
                  // If LaTeX rendering fails, show plain text
                  print('LaTeX Error for "$beforeCursor": $err');
                  return Text(
                    beforeCursor,
                    style: TextStyle(fontSize: 40, color: Colors.red.shade300, height: 1.3),
                  );
                },
              ),
            
            // Cursor
            Container(
              width: 2,
              height: 50,
              color: _showCursor ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
            ),
            
            // Text after cursor
            if (afterCursor.isNotEmpty)
              Math.tex(
                _toLatex(afterCursor),
                textStyle: TextStyle(
                  fontSize: 40,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.3,
                ),
                mathStyle: MathStyle.display,
                onErrorFallback: (err) {
                  // If LaTeX rendering fails, show plain text
                  print('LaTeX Error for "$afterCursor": $err');
                  return Text(
                    afterCursor,
                    style: TextStyle(fontSize: 40, color: Colors.red.shade300, height: 1.3),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}