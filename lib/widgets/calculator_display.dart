/// lib/widgets/calculator_display.dart
/// Enhanced calculator display with LaTeX toggle for history

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../engine/app_state.dart';

class CalculatorDisplay extends StatefulWidget {
  const CalculatorDisplay({
    super.key,
    required this.appState,
    required this.onHistoryEntryTap,
  });

  final AppState appState;
  final void Function(String result) onHistoryEntryTap;

  @override
  State<CalculatorDisplay> createState() => _CalculatorDisplayState();
}

class _CalculatorDisplayState extends State<CalculatorDisplay> {
  bool _showLatexHistory = false;

  /// Converts a plain text expression to LaTeX for display in history
  String _toLatex(String text) {
    String latex = text;
    
    // Replace standard operators with LaTeX equivalents
    latex = latex.replaceAll('*', r'\cdot ');
    
    // Convert fractions
    latex = latex.replaceAllMapped(RegExp(r'\(([^/]+)\)/\(([^/]+)\)'), (m) {
      return r'\frac{' + '${m.group(1)}' + r'}{' + '${m.group(2)}' + r'}';
    });
    
    // Ensure standard functions are rendered upright
    latex = latex.replaceAllMapped(RegExp(r'(\b(sin|cos|tan|ln|log|det|lim|sqrt|abs|gamma)\b)(?![a-zA-Z])'), (m) {
      return '\\${m.group(1)}';
    });
    
    // Handle powers
    latex = latex.replaceAllMapped(RegExp(r'([a-zA-Z0-9)]+)\^([a-zA-Z0-9]+)'), (m) {
      return '${m.group(1)}^{${m.group(2)}}';
    });
    
    return latex;
  }

  Widget _buildExpressionDisplay(String expression) {
    if (_showLatexHistory && expression.isNotEmpty) {
      // Try to render as LaTeX
      try {
        return Math.tex(
          _toLatex(expression),
          textStyle: TextStyle(fontSize: 20, color: Colors.grey[500]),
          onErrorFallback: (err) => Text(
            expression,
            style: TextStyle(fontSize: 20, color: Colors.grey[500]),
            textAlign: TextAlign.right,
          ),
        );
      } catch (e) {
        // Fallback to plain text if LaTeX rendering fails
        return Text(
          expression,
          style: TextStyle(fontSize: 20, color: Colors.grey[500]),
          textAlign: TextAlign.right,
        );
      }
    } else {
      // Plain text display
      return Text(
        expression,
        style: TextStyle(fontSize: 20, color: Colors.grey[500]),
        textAlign: TextAlign.right,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, child) {
        return Column(
          children: [
            // Toggle button for LaTeX/Plain text display
            if (widget.appState.history.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'History Display:',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: false,
                          label: Text('Plain', style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.text_fields, size: 16),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          label: Text('LaTeX', style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.functions, size: 16),
                        ),
                      ],
                      selected: {_showLatexHistory},
                      onSelectionChanged: (Set<bool> newSelection) {
                        setState(() {
                          _showLatexHistory = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            
            // History display
            Expanded(
              child: widget.appState.history.isEmpty
                ? const Center(
                    child: Text(
                      'Calculation history will appear here.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    itemCount: widget.appState.history.length,
                    itemBuilder: (context, index) {
                      final entry = widget.appState.history[index];
                      return InkWell(
                        onTap: () => widget.onHistoryEntryTap(entry.result),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Expression display (with LaTeX toggle)
                              _buildExpressionDisplay(entry.expression),
                              const SizedBox(height: 4),
                              // Result display (always plain text for now)
                              Text(
                                "= ${entry.result}",
                                style: TextStyle(fontSize: 28, color: Colors.blue[300]),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        );
      },
    );
  }
}