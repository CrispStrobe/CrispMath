/// lib/screens/calculator_screen.dart:

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../engine/calculator_engine.dart';
import '../widgets/keypad_grid.dart';

/// The main calculator screen with proper = behavior like traditional calculators
class CalculatorScreen extends StatefulWidget {
  final bool Function(KeyEvent)? onKeyEvent;
  
  const CalculatorScreen({super.key, this.onKeyEvent});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();

  bool handleKeyboardInput(KeyEvent event) {
    final state = _CalculatorScreenState._currentState;
    return state?.handleKeyboardInput(event) ?? false;
  }
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  static _CalculatorScreenState? _currentState;
  
  late TabController _tabController;
  String _expression = '';
  String _result = '';
  String _lastResult = ''; // Store last calculation result
  bool _justCalculated = false; // Track if we just pressed =
  bool _isNewExpression = true; // Track if starting new expression

  final CalculatorEngine _engine = CalculatorEngine();

  @override
  void initState() {
    super.initState();
    _currentState = this;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _currentState = null;
    _tabController.dispose();
    super.dispose();
  }

  bool handleKeyboardInput(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      final character = event.character;
      
      // Handle digits
      if (key == LogicalKeyboardKey.digit0) _onButtonPressed('0');
      else if (key == LogicalKeyboardKey.digit1) _onButtonPressed('1');
      else if (key == LogicalKeyboardKey.digit2) _onButtonPressed('2');
      else if (key == LogicalKeyboardKey.digit3) _onButtonPressed('3');
      else if (key == LogicalKeyboardKey.digit4) _onButtonPressed('4');
      else if (key == LogicalKeyboardKey.digit5) _onButtonPressed('5');
      else if (key == LogicalKeyboardKey.digit6) _onButtonPressed('6');
      else if (key == LogicalKeyboardKey.digit7) _onButtonPressed('7');
      else if (key == LogicalKeyboardKey.digit8) _onButtonPressed('8');
      else if (key == LogicalKeyboardKey.digit9) _onButtonPressed('9');
      
      // Handle operators by character
      else if (character == '+') _onButtonPressed('+');
      else if (character == '-') _onButtonPressed('-');
      else if (character == '*') _onButtonPressed('*');
      else if (character == '/') _onButtonPressed('/');
      else if (character == '.') _onButtonPressed('.');
      
      // Handle special keys
      else if (key == LogicalKeyboardKey.equal || key == LogicalKeyboardKey.enter) _onButtonPressed('=');
      else if (key == LogicalKeyboardKey.backspace) _onButtonPressed('⌫');
      else if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.delete) _onButtonPressed('C');
      else return false;
      
      return true;
    }
    return false;
  }

  void _onButtonPressed(String value) {
    if (value == 'solve') {
      _showSolveDialog();
      return;
    }

    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '';
        _lastResult = '';
        _justCalculated = false;
        _isNewExpression = true;
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _isNewExpression = false;
        }
      } else if (value == '=') {
        if (_expression.isNotEmpty) {
          try {
            _result = _engine.evaluate(_expression);
            _lastResult = _result;
            _justCalculated = true;
            _isNewExpression = false;
          } catch (e) {
            _result = 'Error';
            _lastResult = '';
            _justCalculated = false;
          }
        }
      } else if (_isOperator(value)) {
        // Handle operators with proper calculator behavior
        if (_justCalculated && _lastResult.isNotEmpty) {
          // Start new expression with last result
          _expression = _lastResult + value;
          _result = '';
          _justCalculated = false;
          _isNewExpression = false;
        } else if (_expression.isNotEmpty) {
          // Add operator to current expression
          _expression += value;
          _isNewExpression = false;
        }
      } else {
        // Handle numbers and functions
        if (_justCalculated) {
          // Start completely new expression
          _expression = value;
          _result = '';
          _justCalculated = false;
          _isNewExpression = false;
        } else if (_isNewExpression && _expression.isEmpty) {
          // First input
          _expression = value;
          _isNewExpression = false;
        } else {
          // Continue building expression
          _expression += value;
          _isNewExpression = false;
        }
      }
    });
  }

  bool _isOperator(String value) {
    return ['+', '-', '*', '/', '^', '%'].contains(value);
  }

  void _showSolveDialog() {
    final TextEditingController equationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Solve Equation'),
          content: TextField(
            controller: equationController,
            decoration: const InputDecoration(
              hintText: 'e.g., x^2 - 4 = 0',
              labelText: 'Equation (in terms of x)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (equationController.text.isNotEmpty) {
                  String expression =
                      equationController.text.split('=')[0].trim();
                  
                  final solution = _engine.solve(expression, 'x');

                  setState(() {
                    _expression = "solve(${equationController.text})";
                    _result = "x = {$solution}";
                    _justCalculated = true;
                    _lastResult = '';
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Solve'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Enhanced Display Area with calculation history
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Previous result (if just calculated)
                    if (_justCalculated && _lastResult.isNotEmpty)
                      Container(
                        alignment: Alignment.centerRight,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '= $_lastResult',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    
                    // Current expression
                    Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _expression.isEmpty ? '0' : _expression,
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    
                    // Current result
                    if (_result.isNotEmpty)
                      Container(
                        alignment: Alignment.centerRight,
                        margin: const EdgeInsets.only(top: 12),
                        child: Text(
                          _justCalculated ? '= $_result' : _result,
                          style: TextStyle(
                            fontSize: _justCalculated ? 28 : 24,
                            color: _justCalculated ? Colors.blue[300] : Colors.grey[400],
                            fontWeight: _justCalculated ? FontWeight.w500 : FontWeight.w400,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Keypad Area
          Expanded(
            flex: 5,
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '123'),
                    Tab(text: 'f(x)'),
                    Tab(text: 'CAS'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      KeypadGrid(
                        buttons: const [
                          'C', '⌫', '%', '/',
                          '7', '8', '9', '*',
                          '4', '5', '6', '-',
                          '1', '2', '3', '+',
                          '0', '.', '00', '=',
                        ],
                        onButtonPressed: _onButtonPressed,
                      ),
                      KeypadGrid(
                        buttons: const [
                          'sin(', 'cos(', 'tan(', '^',
                          'ln(', 'log(', 'sqrt(', '(',
                          'e', 'pi', ')', 'C',
                          'abs(', '!', '%', '=',
                        ],
                        onButtonPressed: _onButtonPressed,
                      ),
                      KeypadGrid(
                        buttons: const [
                          '∫ dx', 'd/dx', 'lim', 'solve',
                          'matrix', 'vector', '[', ']',
                          'simplify', 'factor', '{', '}',
                          'expand', ',', ':', '=',
                        ],
                        onButtonPressed: _onButtonPressed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}