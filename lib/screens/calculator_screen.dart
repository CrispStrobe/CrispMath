/// lib/screens/calculator_screen.dart - Refactored and Modular

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// Engine imports
import '../engine/app_state.dart';
import '../engine/calculator_engine.dart';
import '../engine/analysis_engine.dart';

// Widget imports
import '../widgets/calculator_keypad.dart';
import '../widgets/latex_input_field.dart';
import '../widgets/memory_dialogs.dart';
import '../widgets/function_picker_dialogs.dart';

// Utils imports
import '../utils/keyboard_input_handler.dart';
import '../utils/latex_conversion_utils.dart';
import '../utils/expression_preprocessing_utils.dart';

// Other imports
import '../controllers/latex_controller.dart';
import '../localization/app_localizations.dart';
import '../screens/matrix_editor_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => CalculatorScreenState();
}

class CalculatorScreenState extends State<CalculatorScreen> with SingleTickerProviderStateMixin {
  final AppState _appState = AppState();
  final CalculatorEngine _engine = CalculatorEngine();
  late final AnalysisEngine _analysisEngine;
  final Map<String, String> _memory = {};

  late TabController _tabController;
  final LatexController _latexController = LatexController();
  
  String _resultPreview = '';
  bool _justCalculated = false;

  @override
  void initState() {
    super.initState();
    _analysisEngine = AnalysisEngine(_engine);
    _tabController = TabController(length: 5, vsync: this);
    _latexController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _latexController.removeListener(_onInputChanged);
    _latexController.dispose();
    super.dispose();
  }
  
  /// Allows parent widgets to request focus for the input field.
  void requestFocus() {
    print("Requesting focus for CalculatorScreen.");
  }

  /// Called whenever the input text changes.
  void _onInputChanged() {
    if (_justCalculated && _latexController.text.isNotEmpty) {
      final currentInput = _latexController.text.trim();
      
      // Check if user typed just an operator after calculation (including LaTeX operators)
      if (_isOperator(currentInput) || 
          (currentInput.length <= 6 && currentInput.startsWith(r'\cdot'))) {
        
        final lastResult = _appState.history.isNotEmpty ? _appState.history.first.result : '0';
        final cleanResult = ExpressionPreprocessingUtils.extractNumericFromSolveResult(lastResult);
        
        print('AUTO_ANS: Detected operator "$currentInput" after calculation, inserting Ans');
        
        // Remove listener to avoid recursion
        _latexController.removeListener(_onInputChanged);
        _latexController.clear();
        _latexController.insert('Ans$currentInput');
        _latexController.addListener(_onInputChanged);
        
        setState(() => _justCalculated = false);
        return;
      }
      
      // For any other input, clear the flag  
      setState(() => _justCalculated = false);
    }
    
    _updateLivePreview();
    setState(() {}); // Rebuild to show updated text
  }

  void _updateLivePreview() {
    String currentText = _latexController.text.trim();
    
    if (currentText.isEmpty || 
        currentText.toLowerCase().startsWith('solve') ||
        currentText.contains('=') ||
        currentText.length < 2 ||
        RegExp(r'^[a-zA-Z]+$').hasMatch(currentText)) {
        setState(() { _resultPreview = ''; });
        return;
    }
    
    if (!RegExp(r'[\d\+\-\*/\^\(\)\.\,\\]').hasMatch(currentText)) {
        setState(() { _resultPreview = ''; });
        return;
    }
    
    try {
        final convertedExpression = LatexConversionUtils.fromLatex(currentText);
        final substituted = ExpressionPreprocessingUtils.substituteVariables(convertedExpression, _appState);
        final preprocessed = ExpressionPreprocessingUtils.preprocessNativeExpression(
            ExpressionPreprocessingUtils.preprocessExpression(substituted, _appState)
        );
        final rawResult = _engine.evaluate(preprocessed);
        
        final normalizedResult = ExpressionPreprocessingUtils.normalizeComplexResult(rawResult);
        
        if (normalizedResult != "Error" && 
            normalizedResult != currentText && 
            normalizedResult != preprocessed) {
            
            final numericResult = double.tryParse(normalizedResult);
            if (numericResult != null) {
                setState(() { _resultPreview = normalizedResult; });
            } else if (!normalizedResult.contains('Error')) {
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

  bool _handleKeyboardInput(KeyEvent event) {
    KeyboardInputHandler.debugKeyboardInput(event);
    
    return KeyboardInputHandler.handleKeyboardInput(
      event,
      (text) => _latexController.insert(text),
      () => _latexController.backspace(),
      () => _latexController.clear(),
      () => _onButtonPressed("EXE"),
      (amount) => _latexController.moveCursor(amount),
    );
  }

  void _handleMemoryAction(String action) {
    if (action.startsWith('DELETE_')) {
      final memName = action.substring(7); // Remove 'DELETE_' prefix
      final memIndex = int.parse(memName.substring(1)) - 1; // M1 -> 0
      setState(() {
        _memory.remove('M$memIndex');
      });
    } else if (action == 'CLEAR_ALL') {
      setState(() {
        _memory.clear();
      });
    } else {
      // Regular button press, delegate to existing handler
      _onButtonPressed(action);
    }
  }

  void _onButtonPressed(String value) async {
    if (_justCalculated && _isOperator(value) && _appState.history.isNotEmpty) {
      _latexController.insert('Ans');
    }

    switch (value) {
      case 'C':
        _latexController.clear();
        setState(() { _justCalculated = false; });
        break;
      
      case '⌫':
        _latexController.backspace();
        break;
      
      case 'EXE':
        if (_latexController.text.isNotEmpty) {
          await _calculate(_latexController.text);
        }
        break;
      
      case '◀':
        _latexController.moveCursor(-1);
        break;
      
      case '▶':
        _latexController.moveCursor(1);
        break;

      // -- Storage --
      case 'STO':
        MemoryDialogs.showStoreDialog(context, _appState, _memory);
        break;

      // Memory buttons M1-M9:
      case 'M1': case 'M2': case 'M3': case 'M4': case 'M5': 
      case 'M6': case 'M7': case 'M8': case 'M9':
        final memIndex = int.parse(value.substring(1)) - 1;
        if (_memory.containsKey('M$memIndex')) {
          _latexController.insert(_memory['M$memIndex']!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Memory M${memIndex + 1} is empty')),
          );
        }
        break;

      case 'DEL':
        MemoryDialogs.showDeleteMemoryDialog(context, _memory, () => setState(() {}));
        break;
      
      // --- LaTeX Template Insertions ---
      case '/': // This is the BUTTON press, should create fractions
        _latexController.insert(r'\frac{}{}', cursorOffsetFromEnd: -4);
        break;
      
      case 'sqrt':
        _latexController.insert(r'\sqrt{}', cursorOffsetFromEnd: -1);
        break;
      
      case 'sin':
        _latexController.insert(r'\sin()', cursorOffsetFromEnd: -1);
        break;
      
      case 'cos':
        _latexController.insert(r'\cos()', cursorOffsetFromEnd: -1);
        break;
      
      case 'tan':
        _latexController.insert(r'\tan()', cursorOffsetFromEnd: -1);
        break;
      
      case 'ln':
        _latexController.insert(r'\ln()', cursorOffsetFromEnd: -1);
        break;
      
      case 'log':
        _latexController.insert(r'\log()', cursorOffsetFromEnd: -1);
        break;
      
      case 'abs':
        _latexController.insert(r'abs()', cursorOffsetFromEnd: -1);
        break;

      case 'asin':
        _latexController.insert(r'\arcsin()', cursorOffsetFromEnd: -1);
        break;
      
      case 'acos':
        _latexController.insert(r'\arccos()', cursorOffsetFromEnd: -1);
        break;
      
      case 'atan':
        _latexController.insert(r'\arctan()', cursorOffsetFromEnd: -1);
        break;

      case 'sinh':
        _latexController.insert(r'\sinh()', cursorOffsetFromEnd: -1);
        break;
      
      case 'cosh':
        _latexController.insert(r'\cosh()', cursorOffsetFromEnd: -1);
        break;
      
      case 'tanh':
        _latexController.insert(r'\tanh()', cursorOffsetFromEnd: -1);
        break;

      case '^':
        _latexController.insert(r'^{}', cursorOffsetFromEnd: -1);
        break;

      case '_':
        _latexController.insert(r'_{}', cursorOffsetFromEnd: -1);
        break;

      case 'π':
        _latexController.insert(r'\pi');
        break;
      
      case 'e':
        _latexController.insert('E');
        break;
      
      case 'γ':
        _latexController.insert('EulerGamma');
        break;

      case 'solve':
        _latexController.insert('solve()', cursorOffsetFromEnd: -1);
        FunctionPickerDialogs.showSolveFunctionPicker(context, _appState, 
            (text) => _latexController.insert(text));
        break;

      case 'factor':
        _latexController.insert('factor()', cursorOffsetFromEnd: -1);
        break;

      case 'expand':
        _latexController.insert('expand()', cursorOffsetFromEnd: -1);
        break;

      case 'simplify':
        _latexController.insert('simplify()', cursorOffsetFromEnd: -1);
        break;

      case 'd/dx':
        _latexController.insert(r'\frac{d}{dx}()', cursorOffsetFromEnd: -1);
        break;

      case 'gcd':
        _latexController.insert('gcd(,)', cursorOffsetFromEnd: -2);
        break;

      case 'lcm':
        _latexController.insert('lcm(,)', cursorOffsetFromEnd: -2);
        break;

      case '∫':
        final result = await FunctionPickerDialogs.showIntegralDialog(context);
        if (result != null) _latexController.insert(result);
        break;
      
      case 'ⁿ√x':
        final result = await FunctionPickerDialogs.showNthRootDialog(context);
        if (result != null) _latexController.insert(result);
        break;
      
      case 'lim':
        final result = await FunctionPickerDialogs.showLimitDialog(context);
        if (result != null) _latexController.insert(result);
        break;
      
      case 'matrix':
        final result = await Navigator.of(context).push<String>(
          MaterialPageRoute(builder: (context) => const MatrixEditorScreen()),
        );
        if (result != null) _latexController.insert(result);
        break;

      case 'f(x)':
        FunctionPickerDialogs.showFunctionPicker(context, _appState, 
            (text) => _latexController.insert(text));
        break;

      case 'Ans':
        if (_appState.history.isNotEmpty) {
          _latexController.insert('Ans');
        }
        break;

      // === Advanced Mathematical Functions ===
      
      case 'gamma':
        _latexController.insert(r'\Gamma()', cursorOffsetFromEnd: -1);
        break;
      
      case '!':
        _latexController.insert('!');
        break;
      
      case '∞':
        _latexController.insert(r'\infty');
        break;
      
      case 'fib':
        _latexController.insert('fib()', cursorOffsetFromEnd: -1);
        break;
      
      case 'prime':
        _latexController.insert('isprime()', cursorOffsetFromEnd: -1);
        break;
      
      case 'mod':
        _latexController.insert(' \\bmod ', cursorOffsetFromEnd: 0);
        break;

      // === Matrix Operations ===
      
      case 'det':
        _latexController.insert('det()', cursorOffsetFromEnd: -1);
        break;
      
      case 'inv':
        _latexController.insert('inv()', cursorOffsetFromEnd: -1);
        break;
      
      case 'transpose':
        _latexController.insert('transpose()', cursorOffsetFromEnd: -1);
        break;

      // === Hyperbolic Inverse Functions ===
      
      case 'asinh':
        _latexController.insert(r'asinh()', cursorOffsetFromEnd: -1);
        break;
      
      case 'acosh':
        _latexController.insert(r'acosh()', cursorOffsetFromEnd: -1);
        break;
      
      case 'atanh':
        _latexController.insert(r'atanh()', cursorOffsetFromEnd: -1);
        break;

      default:
        _latexController.insert(value);
        break;
    }
  }

  // Helper method to check if a value is an operator
  bool _isOperator(String value) {
    return ['+', '-', '*', '/', '^', '%', '=', r'\cdot', r'\times', r'\div'].contains(value);
  }

  Future<void> _calculate(String expression) async {
    print('\n=== CALCULATING: "$expression" ===');
    try {
      // STEP 1: Check for assignment (variable = value)
      final assignmentMatch = RegExp(r'^([a-zA-Z][a-zA-Z0-9]*)\s*=\s*(.+)$').firstMatch(expression.trim());
      if (assignmentMatch != null) {
        await _handleAssignment(expression, assignmentMatch);
        return;
      }

      // STEP 2: Check for function definition (F1 = expression, Y1 = expression)
      final functionMatch = RegExp(r'^([FY])(\d+)\s*=\s*(.+)$').firstMatch(expression.trim());
      if (functionMatch != null) {
        await _handleFunctionDefinition(expression, functionMatch);
        return;
      }

      // STEP 3: Convert LaTeX to engine-compatible syntax
      String convertedExpression = LatexConversionUtils.fromLatex(expression);
      print('CALC: Converted from LaTeX: "$convertedExpression"');
      
      String result;
      
      // Handle different function types using the specialized handlers
      if (convertedExpression.trim().startsWith('solve(') && convertedExpression.trim().endsWith(')')) {
        print('CALC: Detected solve() function, handling specially');
        result = _handleSolveFunction(convertedExpression.trim());
      } else if (convertedExpression.trim().startsWith('d/dx(') && convertedExpression.trim().endsWith(')')) {
        print('CALC: Detected differentiation function');
        result = _handleDifferentiateFunction(convertedExpression.trim());
      } else if (convertedExpression.trim().startsWith('factor(') && convertedExpression.trim().endsWith(')')) {
        print('CALC: Detected factor function');
        result = _handleFactorFunction(convertedExpression.trim());
      } else if (convertedExpression.trim().startsWith('expand(') && convertedExpression.trim().endsWith(')')) {
        print('CALC: Detected expand function');
        result = _handleExpandFunction(convertedExpression.trim());
      } else if (convertedExpression.trim().startsWith('simplify(') && convertedExpression.trim().endsWith(')')) {
        print('CALC: Detected simplify function');
        result = _handleSimplifyFunction(convertedExpression.trim());
      } else if (convertedExpression.trim().startsWith('gcd(') && convertedExpression.trim().endsWith(')')) {
        print('CALC: Detected GCD function');
        result = _handleGcdFunction(convertedExpression.trim());
      } else if (convertedExpression.trim().startsWith('lcm(') && convertedExpression.trim().endsWith(')')) {
        print('CALC: Detected LCM function');
        result = _handleLcmFunction(convertedExpression.trim());
      } else {
        // Normal expression evaluation with preprocessing
        convertedExpression = ExpressionPreprocessingUtils.substituteVariables(convertedExpression, _appState);
        
        final preprocessed = ExpressionPreprocessingUtils.preprocessNativeExpression(
            ExpressionPreprocessingUtils.preprocessExpression(convertedExpression, _appState)
        );
        print('CALC: Preprocessed expression: "$preprocessed"');
        
        final rawResult = _engine.evaluate(preprocessed);
        print('CALC: Raw result from engine: "$rawResult"');
        
        result = ExpressionPreprocessingUtils.normalizeComplexResult(rawResult);
      }
      
      print('CALC: Final result: "$result"');
      
      setState(() {
        _appState.addHistoryEntry(LatexConversionUtils.latexToReadable(expression), result);
        _resultPreview = '';
        _justCalculated = true;
        _latexController.clear();
      });
      
      print('CALC: Added to history, cleared input, set _justCalculated = true');
    } catch (e) {
      print('CALC: Calculation error: $e');
      setState(() => _appState.addHistoryEntry(expression, "Error: ${e.toString()}"));
    }
    print('=== END CALCULATION ===\n');
  }

  Future<void> _handleAssignment(String originalExpression, RegExpMatch match) async {
    final name = match.group(1)!;
    final valueExpression = match.group(2)!;
    
    print('ASSIGNMENT: Variable "$name" = "$valueExpression"');
    
    try {
      final convertedValue = LatexConversionUtils.fromLatex(valueExpression);
      final substitutedValue = ExpressionPreprocessingUtils.substituteVariables(convertedValue, _appState);
      final preprocessed = ExpressionPreprocessingUtils.preprocessNativeExpression(
          ExpressionPreprocessingUtils.preprocessExpression(substitutedValue, _appState)
      );
      final evaluatedValue = _engine.evaluate(preprocessed);
      final normalizedValue = ExpressionPreprocessingUtils.normalizeComplexResult(evaluatedValue);
      
      if (normalizedValue != "Error" && !normalizedValue.contains("Error")) {
        _appState.setVariable(name, normalizedValue);
        setState(() {
          _appState.addHistoryEntry(originalExpression, "Stored $name = $normalizedValue");
          _justCalculated = true;
          _latexController.clear();
        });
      } else {
        setState(() {
          _appState.addHistoryEntry(originalExpression, "Error: Could not evaluate $valueExpression");
          _latexController.clear();
        });
      }
    } catch (e) {
      setState(() {
        _appState.addHistoryEntry(originalExpression, "Error: Invalid assignment");
        _latexController.clear();
      });
    }
  }

  Future<void> _handleFunctionDefinition(String originalExpression, RegExpMatch match) async {
    final functionType = match.group(1)!;
    final functionIndex = int.parse(match.group(2)!) - 1;
    final functionExpression = match.group(3)!;
    
    print('FUNCTION_DEF: $functionType${functionIndex + 1} = "$functionExpression"');
    
    try {
      final convertedExpression = LatexConversionUtils.fromLatex(functionExpression);
      
      if (functionType == 'Y') {
        if (functionIndex >= 0 && functionIndex < _appState.graphFunctions.length) {
          _appState.updateFunction(functionIndex, convertedExpression);
          setState(() {
            _appState.addHistoryEntry(originalExpression, "Stored Y${functionIndex + 1}");
            _justCalculated = true;
            _latexController.clear();
          });
        } else {
          setState(() => _appState.addHistoryEntry(originalExpression, "Error: Invalid function index"));
        }
      } else if (functionType == 'F') {
        if (functionIndex >= 0 && functionIndex < _appState.userFunctions.length) {
          _appState.updateUserFunction(functionIndex, convertedExpression);
          setState(() {
            _appState.addHistoryEntry(originalExpression, "Stored F${functionIndex + 1}");
            _justCalculated = true;
            _latexController.clear();
          });
        } else {
          setState(() => _appState.addHistoryEntry(originalExpression, "Error: Invalid function index"));
        }
      }
    } catch (e) {
      setState(() {
        _appState.addHistoryEntry(originalExpression, "Error: Invalid function definition");
        _latexController.clear();
      });
    }
  }

  String _handleSolveFunction(String expression) {
    try {
      final solveContent = expression.substring(6, expression.length - 1).trim();
      String equation, variable;
      
      final parts = solveContent.split(',');
      if (parts.length == 1) {
        equation = parts[0].trim();
        variable = ExpressionPreprocessingUtils.detectVariable(equation);
      } else if (parts.length == 2) {
        equation = parts[0].trim();
        variable = parts[1].trim();
      } else {
        return 'Error: solve() format: solve(equation) or solve(equation, variable)';
      }
      
      if (equation.contains('=')) {
        final eqParts = equation.split('=');
        if (eqParts.length == 2) {
          final leftSide = eqParts[0].trim();
          final rightSide = eqParts[1].trim();
          equation = rightSide == '0' || rightSide.isEmpty ? leftSide : '$leftSide - ($rightSide)';
        }
      }
      
      final preprocessed = ExpressionPreprocessingUtils.preprocessNativeExpression(
          ExpressionPreprocessingUtils.preprocessExpression(equation, _appState)
      );
      
      return _engine.solve(preprocessed, variable);
    } catch (e) {
      return 'Error: Invalid solve() syntax';
    }
  }

  String _handleDifferentiateFunction(String expression) {
    try {
      final content = expression.substring(5, expression.length - 1).trim();
      final parts = content.split(',');
      
      String expr = parts[0].trim();
      String variable = parts.length > 1 ? parts[1].trim() : ExpressionPreprocessingUtils.detectVariable(expr);
      
      final preprocessed = ExpressionPreprocessingUtils.preprocessNativeExpression(
          ExpressionPreprocessingUtils.preprocessExpression(expr, _appState)
      );
      return _engine.differentiate(preprocessed, variable);
    } catch (e) {
      return 'Error: Invalid d/dx() syntax';
    }
  }

  String _handleFactorFunction(String expression) {
    try {
      final content = expression.substring(7, expression.length - 1).trim();
      final preprocessed = ExpressionPreprocessingUtils.preprocessNativeExpression(
          ExpressionPreprocessingUtils.preprocessExpression(content, _appState)
      );
      return _engine.factor(preprocessed);
    } catch (e) {
      return 'Error: Invalid factor() syntax';
    }
  }

  String _handleExpandFunction(String expression) {
    try {
      final content = expression.substring(7, expression.length - 1).trim();
      final preprocessed = ExpressionPreprocessingUtils.preprocessNativeExpression(
          ExpressionPreprocessingUtils.preprocessExpression(content, _appState)
      );
      return _engine.expand(preprocessed);
    } catch (e) {
      return 'Error: Invalid expand() syntax';
    }
  }

  String _handleSimplifyFunction(String expression) {
    try {
      final content = expression.substring(9, expression.length - 1).trim();
      final preprocessed = ExpressionPreprocessingUtils.preprocessNativeExpression(
          ExpressionPreprocessingUtils.preprocessExpression(content, _appState)
      );
      return _engine.expand(preprocessed);
    } catch (e) {
      return 'Error: Invalid simplify() syntax';
    }
  }

  String _handleGcdFunction(String expression) {
    try {
      final content = expression.substring(4, expression.length - 1).trim();
      final parts = content.split(',');
      if (parts.length != 2) return 'Error: gcd() requires exactly 2 arguments';
      
      final a = ExpressionPreprocessingUtils.preprocessNativeExpression(
          ExpressionPreprocessingUtils.preprocessExpression(parts[0].trim(), _appState)
      );
      final b = ExpressionPreprocessingUtils.preprocessNativeExpression(
          ExpressionPreprocessingUtils.preprocessExpression(parts[1].trim(), _appState)
      );
      return _engine.gcd(a, b);
    } catch (e) {
      return 'Error: Invalid gcd() syntax';
    }
  }

  String _handleLcmFunction(String expression) {
    try {
      final content = expression.substring(4, expression.length - 1).trim();
      final parts = content.split(',');
      if (parts.length != 2) return 'Error: lcm() requires exactly 2 arguments';
      
      final a = ExpressionPreprocessingUtils.preprocessNativeExpression(
          ExpressionPreprocessingUtils.preprocessExpression(parts[0].trim(), _appState)
      );
      final b = ExpressionPreprocessingUtils.preprocessNativeExpression(
          ExpressionPreprocessingUtils.preprocessExpression(parts[1].trim(), _appState)
      );
      return _engine.lcm(a, b);
    } catch (e) {
      return 'Error: Invalid lcm() syntax';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          final keyEvent = KeyDownEvent(
            physicalKey: event.physicalKey,
            logicalKey: event.logicalKey,
            character: event.character,
            timeStamp: Duration.zero,
            synthesized: false,
          );
          _handleKeyboardInput(keyEvent);
        }
      },
      child: SafeArea(
        child: Column(
          children: [
            // History display
            Expanded(
              flex: 3, 
              child: ListenableBuilder(
                listenable: _appState, 
                builder: (context, child) {
                  return ListView.builder(
                    itemCount: _appState.history.length, 
                    reverse: true,
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
                }
              )
            ),
            
            const Divider(height: 1),
            
            // LaTeX input field
            Container(
              height: 120,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 60),
                        child: SingleChildScrollView(
                          reverse: true,
                          scrollDirection: Axis.horizontal,
                          child: LatexInputField(controller: _latexController),
                        ),
                      ),
                    ),
                  ),
                  if (_resultPreview.isNotEmpty)
                    Container(
                      height: 28,
                      alignment: Alignment.centerRight,
                      child: Text("= $_resultPreview", style: TextStyle(fontSize: 20, color: Colors.grey[600])),
                    ),
                ],
              ),
            ),
            
            // Keypad - Use the existing CalculatorKeypad widget
            Expanded(
              flex: 5, 
              child: CalculatorKeypad(
                tabController: _tabController,
                onButtonPressed: _onButtonPressed,
                localizations: AppLocalizations.of(context),
                appState: _appState,
                onVariableTap: (name) => _latexController.insert(name),
                memory: _memory, // Pass memory
                onMemoryAction: _handleMemoryAction, // Pass button handler
              ),
            ),
          ],
        ),
      ),
    );
  }
}