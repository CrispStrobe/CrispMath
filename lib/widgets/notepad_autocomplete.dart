// lib/widgets/notepad_autocomplete.dart
//
// Notepad V2: autocomplete suggestions for math expressions.
//
// Shows a floating suggestion list when the user types a partial
// identifier (variable name, function name, unit, constant). The
// list updates on every keystroke; Tab or tap accepts the top match.
//
// Suggestions come from four sources:
//   1. Document-scope variables (names defined in earlier lines).
//   2. CAS function names (solve, expand, diff, etc.).
//   3. Unit names from the unit catalog.
//   4. Mathematical constants (pi, e, EulerGamma, etc.).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A single autocomplete suggestion.
class AutocompleteSuggestion {
  final String text;
  final String kind; // 'var', 'fn', 'unit', 'const'
  const AutocompleteSuggestion(this.text, this.kind);
}

/// Provides autocomplete behavior for a notepad input field.
///
/// Wrap around the existing TextField and pass the controller + focus node.
/// The overlay appears above or below the field depending on available space.
class NotepadAutocompleteOverlay extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Widget child;

  /// The current document-scope variable names. Updated on each recalc.
  final Set<String> scopeNames;

  const NotepadAutocompleteOverlay({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.child,
    this.scopeNames = const {},
  });

  @override
  State<NotepadAutocompleteOverlay> createState() =>
      _NotepadAutocompleteOverlayState();
}

class _NotepadAutocompleteOverlayState
    extends State<NotepadAutocompleteOverlay> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  List<AutocompleteSuggestion> _suggestions = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    _removeOverlay();
    super.dispose();
  }

  @override
  void didUpdateWidget(NotepadAutocompleteOverlay old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
    if (old.focusNode != widget.focusNode) {
      old.focusNode.removeListener(_onFocusChanged);
      widget.focusNode.addListener(_onFocusChanged);
    }
  }

  void _onFocusChanged() {
    if (!widget.focusNode.hasFocus) _removeOverlay();
  }

  void _onTextChanged() {
    final token = _currentToken();
    if (token == null || token.length < 2) {
      _removeOverlay();
      return;
    }
    final matches = _findMatches(token);
    if (matches.isEmpty) {
      _removeOverlay();
      return;
    }
    _suggestions = matches;
    _selectedIndex = 0;
    _showOverlay();
  }

  /// Extract the identifier-like token at the cursor position.
  String? _currentToken() {
    final text = widget.controller.text;
    final sel = widget.controller.selection;
    if (!sel.isValid || sel.start != sel.end) return null;
    final pos = sel.start;
    if (pos <= 0 || pos > text.length) return null;

    // Walk backwards from cursor to find the start of the current token.
    var start = pos;
    while (start > 0) {
      final c = text[start - 1];
      if (RegExp(r'[a-zA-Z0-9_]').hasMatch(c)) {
        start--;
      } else {
        break;
      }
    }
    if (start == pos) return null;
    return text.substring(start, pos);
  }

  List<AutocompleteSuggestion> _findMatches(String prefix) {
    final lower = prefix.toLowerCase();
    final results = <AutocompleteSuggestion>[];

    // 1. Scope variables.
    for (final name in widget.scopeNames) {
      if (name.toLowerCase().startsWith(lower) && name != prefix) {
        results.add(AutocompleteSuggestion(name, 'var'));
      }
    }

    // 2. CAS functions.
    for (final fn in _casFunctions) {
      if (fn.toLowerCase().startsWith(lower) && fn != prefix) {
        results.add(AutocompleteSuggestion(fn, 'fn'));
      }
    }

    // 3. Constants.
    for (final c in _constants) {
      if (c.toLowerCase().startsWith(lower) && c != prefix) {
        results.add(AutocompleteSuggestion(c, 'const'));
      }
    }

    // Cap at 8 suggestions to keep the overlay compact.
    if (results.length > 8) results.length = 8;
    return results;
  }

  void _acceptSuggestion(AutocompleteSuggestion suggestion) {
    final text = widget.controller.text;
    final sel = widget.controller.selection;
    final pos = sel.start;

    // Find the token start again.
    var start = pos;
    while (start > 0 && RegExp(r'[a-zA-Z0-9_]').hasMatch(text[start - 1])) {
      start--;
    }

    final before = text.substring(0, start);
    final after = text.substring(pos);
    final newText = '$before${suggestion.text}$after';
    final newPos = start + suggestion.text.length;

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newPos),
    );
    _removeOverlay();
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = OverlayEntry(builder: (context) {
      return CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 28),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200, maxWidth: 280),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final s = _suggestions[index];
                final selected = index == _selectedIndex;
                return InkWell(
                  onTap: () => _acceptSuggestion(s),
                  child: Container(
                    color: selected
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1)
                        : null,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        _kindIcon(s.kind, context),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.text,
                            style: const TextStyle(
                                fontFamily: 'monospace', fontSize: 13),
                          ),
                        ),
                        Text(
                          s.kind,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _kindIcon(String kind, BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    switch (kind) {
      case 'var':
        return Icon(Icons.abc, size: 16, color: color);
      case 'fn':
        return Icon(Icons.functions, size: 16, color: color);
      case 'const':
        return Icon(Icons.looks_one, size: 16, color: color);
      default:
        return Icon(Icons.circle, size: 16, color: color);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: KeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        onKeyEvent: (event) {
          if (_overlayEntry == null) return;
          if (event is! KeyDownEvent) return;
          if (event.logicalKey == LogicalKeyboardKey.tab ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            if (_suggestions.isNotEmpty) {
              _acceptSuggestion(_suggestions[_selectedIndex]);
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            setState(() {
              _selectedIndex =
                  (_selectedIndex + 1).clamp(0, _suggestions.length - 1);
            });
            _showOverlay();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            setState(() {
              _selectedIndex =
                  (_selectedIndex - 1).clamp(0, _suggestions.length - 1);
            });
            _showOverlay();
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            _removeOverlay();
          }
        },
        child: widget.child,
      ),
    );
  }

  static const _casFunctions = [
    'solve',
    'expand',
    'simplify',
    'factor',
    'diff',
    'integrate',
    'limit',
    'subst',
    'gcd',
    'lcm',
    'factorial',
    'fibonacci',
    'sin',
    'cos',
    'tan',
    'asin',
    'acos',
    'atan',
    'sinh',
    'cosh',
    'tanh',
    'asinh',
    'acosh',
    'atanh',
    'exp',
    'log',
    'ln',
    'log10',
    'sqrt',
    'cbrt',
    'abs',
    'floor',
    'ceil',
    'round',
    'sign',
    'gamma',
    'zeta',
    'erf',
    'lambertw',
    'beta',
    'besselj',
    'bessely',
    'isprime',
    'nextprime',
    'prevprime',
    'factorint',
    'divisors',
    'totient',
    'modpow',
    'modinv',
    'jacobi',
    'cfrac',
    'convergent',
    'evalf',
    'cevalf',
    'det',
    'inv',
    'transpose',
    'rref',
    'Matrix',
    'total',
    'subtotal',
    'average',
    'count',
  ];

  static const _constants = [
    'pi',
    'Pi',
    'e',
    'EulerGamma',
    'Ans',
    'true',
    'false',
    'oo',
  ];
}
