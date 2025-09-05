/// lib/screens/calculator_screen.dart - Enhanced with SymbolicMathBridge functions

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../engine/app_state.dart';
import '../engine/calculator_engine.dart';
import '../widgets/keypad_grid.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => CalculatorScreenState();
}

class CalculatorScreenState extends State<CalculatorScreen> with SingleTickerProviderStateMixin {
  final AppState _appState = AppState();
  final CalculatorEngine _engine = CalculatorEngine();

  late TabController _tabController;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  
  String _resultPreview = '';
  bool _justCalculated = false;
  bool _modalIsOpen = false;
  
  final Map<String, String> _memory = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // Added one more tab for advanced functions
    _controller.addListener(_onInputChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inputFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.removeListener(_onInputChanged);
    _controller.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }
  
  void requestFocus() {
    print('MAIN: requestFocus() called from main.dart');
    if (!_inputFocusNode.hasFocus) {
      print('MAIN: Requesting focus...');
      _inputFocusNode.requestFocus();
    } else {
      print('MAIN: Already has focus');
    }
  }
  
  void _onInputChanged() {
    bool isModifying = false;

    if (!isModifying && _justCalculated && _controller.text.isNotEmpty) {
      final input = _controller.text;
      final isSimpleInput = !input.contains('(');

      if (isSimpleInput) {
        isModifying = true;
        final lastResult = _appState.history.firstOrNull?.result ?? '0';

        _controller.removeListener(_onInputChanged);

        if (['+', '-', '*', '/', '^', '%'].contains(input)) {
          final resultToUse = _extractNumericFromSolveResult(lastResult);
          _controller.text = resultToUse + input;
        }

        _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length));
        
        setState(() { _justCalculated = false; });
        _controller.addListener(_onInputChanged);
        isModifying = false;
      } else {
        setState(() { _justCalculated = false; });
      }
    }
    
    _handleFunctionAutocomplete();
    if (!isModifying) {
        setState(() => _updateLivePreview());
    }
  }

  void _handleFunctionAutocomplete() {
    final text = _controller.text;
    final cursorPos = _controller.selection.baseOffset;
    if (cursorPos < 0) return;

    int wordStart = cursorPos;
    while (wordStart > 0 && RegExp(r'[a-zA-Z]').hasMatch(text[wordStart - 1])) {
        wordStart--;
    }

    if (wordStart < cursorPos) {
        final word = text.substring(wordStart, cursorPos);
        if (word == 'solve') {
        print('AUTO: Auto-completing "solve" to "solve()"');
        _controller.removeListener(_onInputChanged);
        final textBefore = text.substring(0, wordStart);
        final textAfter = text.substring(cursorPos);
        _controller.text = '$textBefore$word()$textAfter';
        _controller.selection = TextSelection.collapsed(offset: wordStart + word.length + 1);
        _controller.addListener(_onInputChanged);
        
        print('AUTO: solve() inserted, cursor positioned inside parentheses');
        }
    }
  }
  
  void _updateLivePreview() {
    String currentText = _controller.text.trim();
    
    if (currentText.isEmpty || 
        currentText.toLowerCase().startsWith('solve') ||
        currentText.contains('=') ||
        currentText.length < 2 ||
        RegExp(r'^[a-zA-Z]+$').hasMatch(currentText)) {
        setState(() { _resultPreview = ''; });
        return;
    }
    
    if (!RegExp(r'[\d\+\-\*/\^\(\)\.\,]').hasMatch(currentText)) {
        setState(() { _resultPreview = ''; });
        return;
    }
    
    try {
        final preprocessed = _preprocessNativeExpression(_preprocessExpression(currentText));
        final rawResult = _engine.evaluate(preprocessed);
        
        // APPLY COMPLEX NUMBER NORMALIZATION TO PREVIEW
        final normalizedResult = _normalizeComplexResult(rawResult);
        
        if (normalizedResult != "Error" && 
            normalizedResult != currentText && 
            normalizedResult != preprocessed) {
            
            // Check if it's a simple numeric result
            final numericResult = double.tryParse(normalizedResult);
            if (numericResult != null) {
                setState(() { _resultPreview = normalizedResult; });
            } else if (!normalizedResult.contains('Error')) {
                // Show symbolic results too, but cleaned up
                setState(() { _resultPreview = normalizedResult; });
            } else {
                setState(() { _resultPreview = ''; });
            }
        } else {
        setState(() { _resultPreview = ''; });
        }
    } catch (e) {
        setState(() { _resultPreview = ''; });
    }
  }

  void _debugKeyboardInput(KeyEvent event) {
    if (event is KeyDownEvent) {
      print('=== KEYBOARD DEBUG ===');
      print('Logical Key: ${event.logicalKey}');
      print('Physical Key: ${event.physicalKey}');
      print('Character: "${event.character}"');
      print('Key Label: "${event.logicalKey.keyLabel}"');
      print('========================');
    }
  }

  bool handleKeyboardInput(KeyEvent event) {
    _debugKeyboardInput(event);
    if (event is! KeyDownEvent) return false;

    final physicalKey = event.physicalKey;
    final logicalKey = event.logicalKey;
    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

    // --- GERMAN KEYBOARD LAYOUT FIX ---
    // Handles specific physical keys that are misinterpreted by Flutter on macOS.
    // This is more reliable than using logical keys or characters for these specific cases.

    // Key: `+` and `*` (Physical location of `]` on a US keyboard)
    if (physicalKey == PhysicalKeyboardKey.bracketRight) {
      _insertTextAndPositionCursor(isShiftPressed ? '*' : '+');
      return true;
    }
    // Key: `-` (Physical location of `/` on a US keyboard)
    if (physicalKey == PhysicalKeyboardKey.slash) {
      // Shift + `-` on German layout is `_`, which we can ignore for the calculator.
      if (!isShiftPressed) {
        _insertTextAndPositionCursor('-');
        return true;
      }
    }
    // Key: `/` (This is Shift + 7 on a German keyboard)
    if (physicalKey == PhysicalKeyboardKey.digit7 && isShiftPressed) {
      _insertTextAndPositionCursor('/');
      return true;
    }

    // --- GENERAL KEY HANDLING ---

    // A set of keys that should not produce character input.
    final Set<LogicalKeyboardKey> modifierKeys = <LogicalKeyboardKey>{
      LogicalKeyboardKey.shiftLeft,
      LogicalKeyboardKey.shiftRight,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.controlRight,
      LogicalKeyboardKey.altLeft,
      LogicalKeyboardKey.altRight,
      LogicalKeyboardKey.metaLeft,
      LogicalKeyboardKey.metaRight,
      LogicalKeyboardKey.capsLock,
      LogicalKeyboardKey.escape,
      LogicalKeyboardKey.fn,
    };

    // Handle special action keys first
    if (logicalKey == LogicalKeyboardKey.enter || logicalKey == LogicalKeyboardKey.numpadEnter) {
      _onButtonPressed("EXE");
      return true;
    }
    if (logicalKey == LogicalKeyboardKey.escape) {
      _onButtonPressed('C');
      return true;
    }
    if (logicalKey == LogicalKeyboardKey.backspace) {
      _onButtonPressed('⌫');
      return true;
    }

    // For most other keys, trust the `event.character` if it's not from a modifier key.
    if (event.character != null && event.character!.isNotEmpty && !modifierKeys.contains(logicalKey)) {
      _insertTextAndPositionCursor(event.character!);
      return true;
    }

    // Fallback for Numpad keys that might not produce a character on all platforms
    switch (logicalKey) {
      case LogicalKeyboardKey.numpadAdd:
        _insertTextAndPositionCursor('+');
        return true;
      case LogicalKeyboardKey.numpadSubtract:
        _insertTextAndPositionCursor('-');
        return true;
      case LogicalKeyboardKey.numpadMultiply:
        _insertTextAndPositionCursor('*');
        return true;
      case LogicalKeyboardKey.numpadDivide:
        _insertTextAndPositionCursor('/');
        return true;
      case LogicalKeyboardKey.numpadDecimal:
      case LogicalKeyboardKey.period:
        _insertTextAndPositionCursor('.');
        return true;
      case LogicalKeyboardKey.equal:
        _onButtonPressed("EXE");
        return true;
    }

    return false; // Indicate that the key event was not handled
  }

  void _onButtonPressed(String value) {
    switch (value) {
      case 'C':
        _controller.clear();
        setState(() { _justCalculated = false; });
        break;
      case '⌫':
        _handleBackspace();
        break;
      case 'EXE':
        if (_controller.text.isNotEmpty) {
          _calculate(_controller.text);
        }
        break;
      case '◀':
        if (_inputFocusNode.hasFocus) {
          final selection = _controller.selection;
          if (selection.baseOffset > 0) {
            final newPosition = selection.baseOffset - 1;
            _controller.selection = TextSelection.collapsed(offset: newPosition);
          }
        }
        break;
      case '▶':
        if (_inputFocusNode.hasFocus) {
          final selection = _controller.selection;
          if (selection.baseOffset < _controller.text.length) {
            final newPosition = selection.baseOffset + 1;
            _controller.selection = TextSelection.collapsed(offset: newPosition);
          }
        }
        break;
      
      // Enhanced function handling
      case 'solve':
        _insertTextAndPositionCursor('solve()', cursorOffset: -1);
        _showSolveFunctionPicker();
        break;

      case 'f(x)':
        _showFunctionPicker();
        break;

      case 'd/dx':
        _insertTextAndPositionCursor('d/dx()', cursorOffset: -1);
        break;

      case 'factor':
        _insertTextAndPositionCursor('factor()', cursorOffset: -1);
        break;

      case 'expand':
        _insertTextAndPositionCursor('expand()', cursorOffset: -1);
        break;

      case 'simplify':
        _insertTextAndPositionCursor('simplify()', cursorOffset: -1);
        break;

      case 'gcd':
        _insertTextAndPositionCursor('gcd(,)', cursorOffset: -2);
        break;

      case 'lcm':
        _insertTextAndPositionCursor('lcm(,)', cursorOffset: -2);
        break;

      // Constants from SymbolicMathBridge
      case 'π':
        _insertTextAndPositionCursor('pi');
        break;

      case 'e':
        _insertTextAndPositionCursor('E');
        break;

      case 'γ':
        _insertTextAndPositionCursor('EulerGamma');
        break;

      // Function buttons that need cursor inside parentheses
      case 'sin(':
      case 'cos(':
      case 'tan(':
      case 'ln(':
      case 'log(':
      case 'sqrt(':
      case 'abs(':
      case 'asin(':
      case 'acos(':
      case 'atan(':
      case 'sinh(':
      case 'cosh(':
      case 'tanh(':
        final funcName = value.substring(0, value.length - 1);
        _insertTextAndPositionCursor('$funcName()', cursorOffset: -1);
        break;

      default:
        _insertTextAndPositionCursor(value);
        break;
    }
  }

  // COMPLEX NUMBER FIX: Enhanced result normalization
  String _normalizeComplexResult(String result) {
    if (result.isEmpty) return result;
    
    String normalized = result.trim();
    
    print('NORMALIZE: Input: "$normalized"');
    
    // Handle SymEngine's complex number format: "a + b*I" or "a - b*I"
    // Pattern matches: number + number*I, number - number*I, number*I, etc.
    
    // Remove zero imaginary parts completely
    // Matches: "+ 0*I", "+ 0.0*I", "- 0*I", "- 0.0*I", etc.
    normalized = normalized.replaceAll(RegExp(r'\s*[+\-]\s*0(\.0*)?(\s*\*\s*I|\s*I)\s*'), '');
    
    // Remove imaginary unit artifacts that are just multiplied by zero
    normalized = normalized.replaceAll(RegExp(r'\s*\+\s*0\.0\s*\*\s*I\s*\*\s*\d+'), '');
    normalized = normalized.replaceAll(RegExp(r'\s*\*\s*I\s*\*\s*\d+\s*$'), '');
    
    // Clean up standalone zero imaginary parts
    normalized = normalized.replaceAll(RegExp(r'^\s*0(\.0*)?\s*\*\s*I\s*$'), '0');
    
    // Handle pure imaginary numbers (like "I" -> "i" or "2*I" -> "2i")
    normalized = normalized.replaceAll(RegExp(r'(\d+)\s*\*\s*I\b'), r'\1i');
    normalized = normalized.replaceAll(RegExp(r'\bI\b'), 'i');
    
    // Clean up extra spaces and normalize operators
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s*\+\s*'), ' + ');
    normalized = normalized.replaceAll(RegExp(r'\s*\-\s*'), ' - ');
    normalized = normalized.replaceAll(RegExp(r'\s*\*\s*'), '*');
    
    // Remove leading/trailing spaces
    normalized = normalized.trim();
    
    // If we ended up with just operators, return the original
    if (RegExp(r'^[\+\-\*\s]*$').hasMatch(normalized)) {
      normalized = result;
    }
    
    print('NORMALIZE: Output: "$normalized"');
    
    return normalized;
  }
  
  void _insertTextAndPositionCursor(String text, {int cursorOffset = 0}) {
    print('\n=== TEXT INSERTION DEBUG ===');
    print('Inserting: "$text"');
    print('Cursor offset: $cursorOffset');
    print('Before insertion:');
    print('  Text: "${_controller.text}"');
    print('  Selection: ${_controller.selection}');
    
    final selection = _controller.selection;
    final currentText = _controller.text;

    final newText = currentText.replaceRange(selection.start, selection.end, text);
    final newPosition = selection.start + text.length + cursorOffset;
    
    print('Calculated new state:');
    print('  New text: "$newText"');
    print('  New cursor position: $newPosition');

    if (_inputFocusNode.hasFocus) {
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newPosition.clamp(0, newText.length)),
      );
    } else {
      _inputFocusNode.requestFocus();
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newPosition.clamp(0, newText.length)),
        );
      });
    }
    
    print('After atomic update:');
    print('  Actual text: "${_controller.text}"');
    print('  Actual selection: ${_controller.selection}');
    print('=== END TEXT INSERTION DEBUG ===\n');
  }
  
  void _handleBackspace() {
    print('\n=== BACKSPACE DEBUG ===');
    final selection = _controller.selection;
    final currentText = _controller.text;
    
    print('Before backspace:');
    print('  Text: "$currentText"');
    print('  Selection: $selection');

    if (!selection.isValid) return;

    if (!selection.isCollapsed) {
      _insertTextAndPositionCursor('');
      return;
    }

    if (selection.start > 0) {
      final currentText = _controller.text;
      final newText = currentText.substring(0, selection.start - 1) + currentText.substring(selection.start);
      final newPos = selection.start - 1;

        print('Single cursor backspace:');
        print('  Removing char at position ${selection.start - 1}');
        print('  New text: "$newText"');
        print('  New cursor: $newPos');

      if (_inputFocusNode.hasFocus) {
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newPos),
        );
      } else {
        _inputFocusNode.requestFocus();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: newPos),
          );
        });
      }
    }
    
    print('After backspace:');
    print('  Text: "${_controller.text}"');
    print('  Selection: ${_controller.selection}');
    print('=== END BACKSPACE DEBUG ===\n');
  }

  void _calculate(String expression) {
    print('\n=== CALCULATING: "$expression" ===');
    try {
      String result;
      
      // Handle different function types
      if (expression.trim().startsWith('solve(') && expression.trim().endsWith(')')) {
        print('CALC: Detected solve() function, handling specially');
        result = _handleSolveFunction(expression.trim());
      } else if (expression.trim().startsWith('d/dx(') && expression.trim().endsWith(')')) {
        print('CALC: Detected differentiation function');
        result = _handleDifferentiateFunction(expression.trim());
      } else if (expression.trim().startsWith('factor(') && expression.trim().endsWith(')')) {
        print('CALC: Detected factor function');
        result = _handleFactorFunction(expression.trim());
      } else if (expression.trim().startsWith('expand(') && expression.trim().endsWith(')')) {
        print('CALC: Detected expand function');
        result = _handleExpandFunction(expression.trim());
      } else if (expression.trim().startsWith('simplify(') && expression.trim().endsWith(')')) {
        print('CALC: Detected simplify function');
        result = _handleSimplifyFunction(expression.trim());
      } else if (expression.trim().startsWith('gcd(') && expression.trim().endsWith(')')) {
        print('CALC: Detected GCD function');
        result = _handleGcdFunction(expression.trim());
      } else if (expression.trim().startsWith('lcm(') && expression.trim().endsWith(')')) {
        print('CALC: Detected LCM function');
        result = _handleLcmFunction(expression.trim());
      } else {
        // Normal expression evaluation with preprocessing
        final preprocessed = _preprocessNativeExpression(_preprocessExpression(expression));
        print('CALC: Preprocessed expression: "$preprocessed"');
        
        final rawResult = _engine.evaluate(preprocessed);
        print('CALC: Raw result from engine: "$rawResult"');
        
        // APPLY COMPLEX NUMBER NORMALIZATION
        result = _normalizeComplexResult(rawResult);
      }
      
      print('CALC: Final result: "$result"');
      
      setState(() {
        _appState.addHistoryEntry(expression, result);
        _resultPreview = '';
        _justCalculated = true;
        
        _controller.removeListener(_onInputChanged);
        _controller.clear();
        _controller.addListener(_onInputChanged);
      });
      
      print('CALC: Added to history, cleared input, set _justCalculated = true');
    } catch (e) {
      print('CALC: Calculation error: $e');
      setState(() => _appState.addHistoryEntry(expression, "Error: ${e.toString()}"));
    }
    print('=== END CALCULATION ===\n');
  }

  String _handleSolveFunction(String expression) {
    print('SOLVE: Processing solve function: "$expression"');
    
    try {
      final solveContent = expression.substring(6, expression.length - 1).trim();
      print('SOLVE: Content inside solve(): "$solveContent"');
      
      String equation;
      String variable;
      
      final parts = solveContent.split(',');
      if (parts.length == 1) {
        equation = parts[0].trim();
        variable = _detectVariable(equation);
        print('SOLVE: Auto-detected variable: "$variable"');
      } else if (parts.length == 2) {
        equation = parts[0].trim();
        variable = parts[1].trim();
        print('SOLVE: Explicit variable provided: "$variable"');
      } else {
        print('SOLVE: Error - Too many parameters');
        return 'Error: solve() format: solve(equation) or solve(equation, variable)';
      }
      
      print('SOLVE: Equation: "$equation", Variable: "$variable"');
      
      if (equation.contains('=')) {
        final eqParts = equation.split('=');
        if (eqParts.length == 2) {
          final leftSide = eqParts[0].trim();
          final rightSide = eqParts[1].trim();
          
          if (rightSide == '0' || rightSide.isEmpty) {
            equation = leftSide;
          } else {
            equation = '$leftSide - ($rightSide)';
          }
          print('SOLVE: Converted equation to: "$equation"');
        }
      }
      
      final preprocessed = _preprocessNativeExpression(_preprocessExpression(equation));
      print('SOLVE: Preprocessed equation: "$preprocessed"');
      
      return _engine.solve(preprocessed, variable);
      
    } catch (e) {
      print('SOLVE: Error parsing solve function: $e');
      return 'Error: Invalid solve() syntax';
    }
  }

  String _handleDifferentiateFunction(String expression) {
    try {
      final content = expression.substring(5, expression.length - 1).trim();
      final parts = content.split(',');
      
      String expr = parts[0].trim();
      String variable = parts.length > 1 ? parts[1].trim() : _detectVariable(expr);
      
      final preprocessed = _preprocessNativeExpression(_preprocessExpression(expr));
      return _engine.differentiate(preprocessed, variable);
    } catch (e) {
      return 'Error: Invalid d/dx() syntax';
    }
  }

  String _handleFactorFunction(String expression) {
    try {
      final content = expression.substring(7, expression.length - 1).trim();
      final preprocessed = _preprocessNativeExpression(_preprocessExpression(content));
      return _engine.factor(preprocessed);
    } catch (e) {
      return 'Error: Invalid factor() syntax';
    }
  }

  String _handleExpandFunction(String expression) {
    try {
      final content = expression.substring(7, expression.length - 1).trim();
      final preprocessed = _preprocessNativeExpression(_preprocessExpression(content));
      return _engine.expand(preprocessed);
    } catch (e) {
      return 'Error: Invalid expand() syntax';
    }
  }

  String _handleSimplifyFunction(String expression) {
    try {
      final content = expression.substring(9, expression.length - 1).trim();
      final preprocessed = _preprocessNativeExpression(_preprocessExpression(content));
      return _engine.expand(preprocessed); // SymEngine uses expand for simplification
    } catch (e) {
      return 'Error: Invalid simplify() syntax';
    }
  }

  String _handleGcdFunction(String expression) {
    try {
      final content = expression.substring(4, expression.length - 1).trim();
      final parts = content.split(',');
      if (parts.length != 2) {
        return 'Error: gcd() requires exactly 2 arguments';
      }
      
      final a = _preprocessNativeExpression(_preprocessExpression(parts[0].trim()));
      final b = _preprocessNativeExpression(_preprocessExpression(parts[1].trim()));
      return _engine.gcd(a, b);
    } catch (e) {
      return 'Error: Invalid gcd() syntax';
    }
  }

  String _handleLcmFunction(String expression) {
    try {
      final content = expression.substring(4, expression.length - 1).trim();
      final parts = content.split(',');
      if (parts.length != 2) {
        return 'Error: lcm() requires exactly 2 arguments';
      }
      
      final a = _preprocessNativeExpression(_preprocessExpression(parts[0].trim()));
      final b = _preprocessNativeExpression(_preprocessExpression(parts[1].trim()));
      return _engine.lcm(a, b);
    } catch (e) {
      return 'Error: Invalid lcm() syntax';
    }
  }

  String _detectVariable(String equation) {
    print('SOLVE: Auto-detecting variable in: "$equation"');
    
    final knownTokens = {
      'e', 'pi', 'sin', 'cos', 'tan', 'ln', 'log', 'sqrt', 'abs', 
      'exp', 'deg', 'rad', 'gamma', 'factorial'
    };
    
    final variablePattern = RegExp(r'\b([a-zA-Z])\b');
    final matches = variablePattern.allMatches(equation);
    
    final foundVariables = <String>{};
    for (final match in matches) {
      final variable = match.group(1)!.toLowerCase();
      if (!knownTokens.contains(variable)) {
        foundVariables.add(variable);
      }
    }
    
    print('SOLVE: Found potential variables: $foundVariables');
    
    final commonVariables = ['x', 'y', 'z', 't', 'n', 'a', 'b', 'c'];
    for (final common in commonVariables) {
      if (foundVariables.contains(common)) {
        print('SOLVE: Selected common variable: "$common"');
        return common;
      }
    }
    
    if (foundVariables.isNotEmpty) {
      final firstVar = foundVariables.first;
      print('SOLVE: Selected first variable: "$firstVar"');
      return firstVar;
    }
    
    print('SOLVE: No variables detected, defaulting to "x"');
    return 'x';
  }

  String _preprocessNativeExpression(String expression) {
    String p = expression;
    
    // Convert German decimal comma to period
    p = p.replaceAll(',', '.');

    // Handle implicit multiplication for numbers and parentheses
    p = p.replaceAllMapped(RegExp(r'(\d|\))(\()'), (m) => '${m[1]}*${m[2]}');
    
    // Handle implicit multiplication for variables
    p = p.replaceAllMapped(RegExp(r'(\b[a-zA-Z]\b)(\()'), (m) => '${m[1]}*${m[2]}');
    p = p.replaceAllMapped(RegExp(r'(\))(\d|\b[a-zA-Z]\b)'), (m) => '${m[1]}*${m[2]}');
    
    // Handle factorial notation
    p = p.replaceAllMapped(RegExp(r'(\d+)!'), (m) {
      final n = int.tryParse(m.group(1)!) ?? 0;
      if (n <= 20) {
        int f = 1;
        for (int i = 1; i <= n; i++) { f *= i; }
        return f.toString();
      } else {
        return 'gamma(${n + 1})';
      }
    });
    
    return p;
  }
  
  String _extractNumericFromSolveResult(String solveResult) {
    final match = RegExp(r'[a-zA-Z]\s*=\s*([+-]?[\d.]+)\s*$').firstMatch(solveResult);
    if (match != null && !match.group(1)!.contains(',')) {
      return match.group(1)!.trim();
    }
    return solveResult;
  }
  
  void _showSolveFunctionPicker() {
    final selectionBeforeModal = _controller.selection;
    setState(() { _modalIsOpen = true; });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Select equation or continue typing:', style: Theme.of(context).textTheme.titleMedium),
              ),
              ListTile(
                leading: Icon(Icons.keyboard_return),
                title: Text('Continue Typing'),
                onTap: () {
                  Navigator.of(context).pop();
                  _inputFocusNode.requestFocus();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _controller.selection = selectionBeforeModal;
                  });
                },
              ),
              const Divider(),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: _appState.graphFunctions.asMap().entries
                    .where((e) => e.value.isNotEmpty)
                    .map((e) => ListTile(
                      title: Text('Solve Y${e.key + 1} = 0'),
                      subtitle: Text('where Y${e.key + 1} = ${e.value}'),
                      onTap: () {
                        Navigator.of(context).pop();

                        final currentText = _controller.text;
                        final openParen = currentText.lastIndexOf('(');
                        final closeParen = currentText.indexOf(')', openParen);

                        if (openParen != -1 && closeParen != -1) {
                          final textToInsert = 'Y${e.key+1}=0, x';
                          final newText = currentText.replaceRange(openParen + 1, closeParen, textToInsert);
                          final newCursorPos = openParen + 1 + textToInsert.length;
                          
                          _inputFocusNode.requestFocus();
                          _controller.value = TextEditingValue(
                            text: newText,
                            selection: TextSelection.collapsed(offset: newCursorPos),
                          );
                        }
                      },
                    )).toList(),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() => setState(() { _modalIsOpen = false; }));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_modalIsOpen && mounted && !_inputFocusNode.hasFocus) {
        _inputFocusNode.requestFocus();
        _controller.selection = selectionBeforeModal;
      }
    });
  }

   void _showFunctionPicker() {
    final List<Widget> options = _appState.graphFunctions.asMap().entries
      .where((entry) => entry.value.isNotEmpty)
      .map((entry) {
        int index = entry.key;
        String func = entry.value;
        return ListTile(
          title: Text('Y${index + 1} = $func'),
          onTap: () {
            Navigator.of(context).pop();
            _insertTextAndPositionCursor('Y${index+1}()', cursorOffset: -1);
          },
        );
      }).toList();

    _showPicker(title: 'Select function or continue typing:', options: options);
  }

  void _showPicker({required String title, required List<Widget> options}) {
    final selectionBeforeModal = _controller.selection;
    setState(() { _modalIsOpen = true; });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(title, style: Theme.of(context).textTheme.titleMedium),
              ),
              ListTile(
                leading: Icon(Icons.keyboard_return),
                title: Text('Continue Typing'),
                subtitle: Text('Dismiss this panel'),
                onTap: () {
                  Navigator.of(context).pop();
                  _inputFocusNode.requestFocus();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _controller.selection = selectionBeforeModal;
                  });
                },
              ),
              const Divider(),
              Flexible(child: ListView(shrinkWrap: true, children: options)),
            ],
          ),
        );
      },
    ).whenComplete(() => setState(() { _modalIsOpen = false; }));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_modalIsOpen && !_inputFocusNode.hasFocus) {
        _inputFocusNode.requestFocus();
        _controller.selection = selectionBeforeModal;
      }
    });
  }

  String _preprocessExpression(String expression) {
    String processed = expression;

    final funcCallRegex = RegExp(r'Y(\d+)\((.*?)\)');
    processed = processed.replaceAllMapped(funcCallRegex, (match) {
      try {
        final funcIndex = int.parse(match.group(1)!) - 1;
        final argValue = match.group(2)!;

        if (funcIndex >= 0 && funcIndex < _appState.graphFunctions.length) {
          String funcBody = _appState.graphFunctions[funcIndex];
          if (funcBody.isNotEmpty) {
            final variable = _detectVariable(funcBody);
            String substitutedBody = funcBody.replaceAll(variable, '($argValue)');
            return '($substitutedBody)';
          }
        }
      } catch (e) {
        return match.group(0)!;
      }
      return match.group(0)!;
    });

    final simpleFuncRegex = RegExp(r'Y(\d+)');
    processed = processed.replaceAllMapped(simpleFuncRegex, (match) {
        try {
            final funcIndex = int.parse(match.group(1)!) - 1;
            if (funcIndex >= 0 && funcIndex < _appState.graphFunctions.length) {
                String funcBody = _appState.graphFunctions[funcIndex];
                if (funcBody.isNotEmpty) return '($funcBody)';
            }
        } catch (e) { return match.group(0)!; }
        return match.group(0)!;
    });

    return processed;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) => handleKeyboardInput(event) 
        ? KeyEventResult.handled 
        : KeyEventResult.ignored,
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            print('BACKGROUND: Background tapped, ensuring focus');
            if (!_inputFocusNode.hasFocus) {
              _inputFocusNode.requestFocus();
            }
          },
          child: Column(
            children: [
              Expanded(flex: 3, child: ListenableBuilder(listenable: _appState, builder: (context, child) {
                return ListView.builder(
                  itemCount: _appState.history.length, reverse: true,
                  itemBuilder: (context, index) {
                    final entry = _appState.history[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(entry.expression, style: TextStyle(fontSize: 20, color: Colors.grey[500])),
                          const SizedBox(height: 4),
                          Text("= ${entry.result}", style: TextStyle(fontSize: 28, color: Colors.blue[300])),
                        ],
                      ),
                    );
                  },
                );
              })),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  TextField(
                    controller: _controller,
                    focusNode: _inputFocusNode,
                    showCursor: true, 
                    autofocus: true,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300),
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: _justCalculated ? (_appState.history.firstOrNull?.result ?? '0') : '0',
                      hintStyle: TextStyle(fontSize: 48, color: _justCalculated ? Colors.grey[500] : Colors.grey[700]),
                    ),
                  ),
                  if (_resultPreview.isNotEmpty)
                    Text("= $_resultPreview", style: TextStyle(fontSize: 24, color: Colors.grey[600])),
                ]),
              ),
              Expanded(flex: 5, child: Column(children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  onTap: (index) {
                    print('TAB: Tab $index selected, ensuring focus');
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!_inputFocusNode.hasFocus) {
                        _inputFocusNode.requestFocus();
                      }
                    });
                  },
                  tabs: const [
                    Tab(text: 'Num'), 
                    Tab(text: 'Trig'), 
                    Tab(text: 'CAS'), 
                    Tab(text: 'Advanced'),
                    Tab(text: 'Mem')
                  ]
                ),
                Expanded(child: TabBarView(controller: _tabController, children: [
                    // Basic numbers and operations
                    KeypadGrid(buttons: const ['C','⌫','%','/','7','8','9','*','4','5','6','-','1','2','3','+','0','.','^','EXE'], onButtonPressed: _onButtonPressed),
                    
                    // Trigonometric and basic functions
                    KeypadGrid(buttons: const ['sin(','cos(','tan(','x','asin(','acos(','atan(','(','sinh(','cosh(','tanh(',')','ln(','log(','√','EXE'], onButtonPressed: _onButtonPressed),
                    
                    // Computer Algebra System functions
                    KeypadGrid(buttons: const ['solve','factor','expand','d/dx','simplify','f(x)','∫','◀','gcd','lcm','=','▶',',','π','e','γ'], onButtonPressed: _onButtonPressed),
                    
                    // Advanced mathematical functions
                    KeypadGrid(buttons: const ['abs(','gamma','!','∞','matrix','det','inv','◀','asinh(','acosh(','atanh(','▶','fib','prime','mod','EXE'], onButtonPressed: _onButtonPressed),
                    
                    // Memory operations
                    KeypadGrid(buttons: const ['STO','M1','M2','M3','DEL','M4','M5','M6','◀','M7','M8','M9','▶'], onButtonPressed: _onButtonPressed),
                ])),
              ])),
            ],
          ),
        ),
      ),
    );
  }
}