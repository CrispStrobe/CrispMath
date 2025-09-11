/// lib/engine/analysis_engine.dart
/// Robust mathematical analysis engine with comprehensive error handling
/// and result normalization for curve sketching (Kurvendiskussion).

import 'dart:convert';
import 'calculator_engine.dart';

class AnalysisResult {
  final String originalFunction;
  final String firstDerivative;
  final String secondDerivative;
  final String yIntercept;
  final List<String> roots;
  final List<String> extrema;
  final List<String> inflectionPoints;
  final List<String> errors;

  AnalysisResult({
    required this.originalFunction,
    required this.firstDerivative,
    required this.secondDerivative,
    required this.yIntercept,
    required this.roots,
    required this.extrema,
    required this.inflectionPoints,
    required this.errors,
  });
}

class AnalysisEngine {
  final CalculatorEngine _engine;
  
  AnalysisEngine(this._engine);

  /// Normalizes complex number results and cleans up mathematical expressions
  String _normalizeResult(String result) {
    if (result.isEmpty) return result;
    
    String normalized = result.trim();
    
    // Remove complex number artifacts
    normalized = normalized.replaceAll(RegExp(r'\s*[+\-]\s*0(\.0*)?(\s*\*\s*I|\s*I)\s*'), '');
    normalized = normalized.replaceAll(RegExp(r'^\s*0(\.0*)?\s*\*\s*I\s*$'), '0');
    normalized = normalized.replaceAll(RegExp(r'\bI\b'), 'i');
    
    // Clean up decimal zeros (0.0 -> 0)
    normalized = normalized.replaceAll(RegExp(r'\.0+(?!\d)'), '');
    
    // Handle pure real numbers that show as "5.0 + 0.0*I"  
    normalized = normalized.replaceAll(RegExp(r'^([+-]?\d+(?:\.\d+)?)\s*\+\s*0\.0\s*\*\s*I$'), r'\1');
    
    // Fix Python-style exponents for display
    normalized = normalized.replaceAll('**2', '²');
    normalized = normalized.replaceAll('**3', '³');
    normalized = normalized.replaceAll('**4', '⁴');
    normalized = normalized.replaceAllMapped(RegExp(r'\*\*(\d+)'), (m) => '^${m.group(1)}');
    
    // Clean up multiplication for display (but preserve * in expressions)
    normalized = normalized.replaceAllMapped(RegExp(r'(\d+)\s*\*\s*([a-zA-Z])(?!\*)'), (m) => '${m.group(1)}${m.group(2)}');
    
    // Clean up spacing
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return normalized;
  }

  /// Normalizes expressions for DISPLAY ONLY - converts ** to superscripts
  String _normalizeForDisplay(String result) {
    String normalized = _normalizeResult(result);
    
    // Fix Python-style exponents for display ONLY
    normalized = normalized.replaceAll('**2', '²');
    normalized = normalized.replaceAll('**3', '³');
    normalized = normalized.replaceAll('**4', '⁴');
    normalized = normalized.replaceAllMapped(RegExp(r'\*\*(\d+)'), (m) => '^${m.group(1)}');
    
    // Clean up multiplication for display (but preserve * in expressions)
    normalized = normalized.replaceAllMapped(RegExp(r'(\d+)\s*\*\s*([a-zA-Z])(?!\*)'), (m) => '${m.group(1)}${m.group(2)}');
    
    return normalized;
  }

  /// Safely evaluates an expression with error handling
  String _safeEvaluate(String expression, {String? variable, String? value}) {
    try {
      String expr = expression;
      if (variable != null && value != null) {
        // Proper variable substitution using word boundaries
        expr = expr.replaceAll(RegExp(r'\b' + RegExp.escape(variable) + r'\b'), '($value)');
      }
      
      final result = _engine.evaluate(expr);
      return _normalizeResult(result);
    } catch (e) {
      print('EVAL_ERROR: Failed to evaluate "$expression": $e');
      return 'Error';
    }
  }

  /// Safely differentiates an expression
  String _safeDifferentiate(String expression, String variable) {
    try {
      print('DIFF: Differentiating "$expression" w.r.t. $variable');
      final result = _engine.differentiate(expression, variable);
      print('DIFF: Raw result: "$result"');
      final normalized = _normalizeResult(result);
      print('DIFF: Normalized result: "$normalized"');
      return normalized;
    } catch (e) {
      print('DIFF_ERROR: Failed to differentiate "$expression": $e');
      return 'Error';
    }
  }

  /// Safely solves an equation with improved edge case handling
  String _safeSolve(String expression, String variable) {
    try {
      // Handle edge cases first
      final cleanExpr = expression.trim();
      
      // If expression is just a constant (like "2" or "0"), handle specially
      if (!cleanExpr.contains(variable)) {
        final value = double.tryParse(cleanExpr);
        if (value != null) {
          if (value == 0) {
            return '[]'; // 0 = 0 has infinite solutions, but we'll say no specific solutions
          } else {
            return '[]'; // constant ≠ 0 has no solutions
          }
        }
        // For non-numeric constants, try evaluation
        final evalResult = _engine.evaluate(cleanExpr);
        final evalValue = double.tryParse(evalResult);
        if (evalValue != null) {
          return evalValue == 0 ? '[]' : '[]';
        }
      }
      
      final result = _engine.solve(expression, variable);
      return result; // Don't normalize solve results as they contain arrays
    } catch (e) {
      print('SOLVE_ERROR: Failed to solve "$expression": $e');
      
      // For certain solve errors, we can provide meaningful responses
      if (e.toString().contains('solve operation failed')) {
        // Check if it's a constant expression
        if (!expression.contains(variable)) {
          return '[]'; // No solutions for constant expressions
        }
      }
      
      return 'Error';
    }
  }

  /// Parses solution arrays like "[1, -1, sqrt(3)]" into clean list
  List<String> _parseSolutionArray(String solution) {
    if (solution == 'Error' || solution.isEmpty) return [];
    
    try {
      if (solution.startsWith('[') && solution.endsWith(']')) {
        final content = solution.substring(1, solution.length - 1).trim();
        if (content.isEmpty) return [];
        
        return content.split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty && s != 'Error')
            .map((s) => _normalizeResult(s))
            .toList();
      }
      
      // Single solution
      if (!solution.contains('Error')) {
        return [_normalizeResult(solution)];
      }
    } catch (e) {
      print('PARSE_ERROR: Failed to parse solution "$solution": $e');
    }
    
    return [];
  }

  /// Validates that a function expression is reasonable
  bool _isValidFunction(String function) {
    if (function.isEmpty) return false;
    if (function.contains('Error')) return false;
    if (!function.contains('x')) return false;
    
    // Test evaluation at x=0 to check if function is valid
    final testResult = _safeEvaluate(function, variable: 'x', value: '0');
    return testResult != 'Error';
  }

  /// Determines extremum type using second derivative test
  String _determineExtremumType(String secondDerivative, String point) {
    final concavityStr = _safeEvaluate(secondDerivative, variable: 'x', value: point);
    
    if (concavityStr == 'Error') return 'Critical Point';
    
    final concavity = double.tryParse(concavityStr);
    if (concavity == null) return 'Critical Point';
    
    if (concavity > 0) return 'Local Minimum';
    if (concavity < 0) return 'Local Maximum';
    return 'Inflection Point';
  }

  /// Performs comprehensive curve analysis with robust error handling
  Future<AnalysisResult> performCurveAnalysis(String function) async {
    print('ANALYSIS: Starting analysis of: "$function"');
    
    final List<String> errors = [];
    
    // Validate input function
    if (!_isValidFunction(function)) {
      errors.add('Invalid function: $function');
      return AnalysisResult(
        originalFunction: function,
        firstDerivative: 'Error',
        secondDerivative: 'Error',
        yIntercept: 'Error',
        roots: [],
        extrema: ['Error: Invalid function'],
        inflectionPoints: ['Error: Invalid function'],
        errors: errors,
      );
    }

    // Step 1: Calculate derivatives
    print('ANALYSIS: Calculating derivatives...');
    final firstDerivative = _safeDifferentiate(function, 'x');
    if (firstDerivative == 'Error') {
      errors.add('Failed to calculate first derivative');
    }
    
    final secondDerivative = firstDerivative != 'Error' 
        ? _safeDifferentiate(firstDerivative, 'x')
        : 'Error';
    if (secondDerivative == 'Error' && firstDerivative != 'Error') {
      errors.add('Failed to calculate second derivative');
    }

    // Step 2: Find Y-intercept (f(0)) - FIXED
    print('ANALYSIS: Finding Y-intercept...');
    final yIntercept = _safeEvaluate(function, variable: 'x', value: '0');
    if (yIntercept == 'Error') {
      errors.add('Failed to calculate Y-intercept');
    }

    // Step 3: Find roots (solve f(x) = 0)
    print('ANALYSIS: Finding roots...');
    final rootsStr = _safeSolve(function, 'x');
    final roots = _parseSolutionArray(rootsStr);
    print('ANALYSIS: Found ${roots.length} roots: $roots');

    // Step 4: Find critical points and extrema
    print('ANALYSIS: Finding extrema...');
    List<String> extrema = [];
    if (firstDerivative != 'Error') {
      final criticalPointsStr = _safeSolve(firstDerivative, 'x');
      final criticalPoints = _parseSolutionArray(criticalPointsStr);
      print('ANALYSIS: Found ${criticalPoints.length} critical points: $criticalPoints');
      
      if (criticalPoints.isEmpty) {
        // Check if first derivative is a constant
        final constCheck = double.tryParse(firstDerivative);
        if (constCheck != null) {
          if (constCheck == 0) {
            extrema.add('Function is constant (f\'(x) = 0 everywhere)');
          } else {
            extrema.add('No critical points (f\'(x) = $firstDerivative ≠ 0)');
          }
        } else {
          extrema.add('No critical points found');
        }
      } else {
        for (final point in criticalPoints) {
          final functionValue = _safeEvaluate(function, variable: 'x', value: point);
          if (functionValue != 'Error') {
            final type = secondDerivative != 'Error' 
                ? _determineExtremumType(secondDerivative, point)
                : 'Critical Point';
            extrema.add('$type: ($point, $functionValue)');
          } else {
            extrema.add('Critical Point: ($point, Error)');
            errors.add('Failed to evaluate function at critical point $point');
          }
        }
      }
    } else {
      extrema.add('Error: Cannot find extrema without first derivative');
    }

    // Step 5: Find inflection points
    print('ANALYSIS: Finding inflection points...');
    List<String> inflectionPoints = [];
    if (secondDerivative != 'Error') {
      final inflectionPointsStr = _safeSolve(secondDerivative, 'x');
      final inflectionPointsList = _parseSolutionArray(inflectionPointsStr);
      print('ANALYSIS: Found ${inflectionPointsList.length} potential inflection points: $inflectionPointsList');
      
      if (inflectionPointsList.isEmpty) {
        // Check if second derivative is a constant
        final constCheck = double.tryParse(secondDerivative);
        if (constCheck != null) {
          if (constCheck == 0) {
            inflectionPoints.add('Function has constant concavity (f\'\'(x) = 0 everywhere)');
          } else {
            inflectionPoints.add('No inflection points (f\'\'(x) = $secondDerivative ≠ 0)');
          }
        } else {
          inflectionPoints.add('No inflection points found');
        }
      } else {
        for (final point in inflectionPointsList) {
          final functionValue = _safeEvaluate(function, variable: 'x', value: point);
          if (functionValue != 'Error') {
            inflectionPoints.add('($point, $functionValue)');
          } else {
            inflectionPoints.add('($point, Error)');
            errors.add('Failed to evaluate function at inflection point $point');
          }
        }
      }
    } else {
      inflectionPoints.add('Error: Cannot find inflection points without second derivative');
    }

    print('ANALYSIS: Analysis complete. Errors: ${errors.length}');
    
    return AnalysisResult(
      originalFunction: function,
      firstDerivative: firstDerivative != 'Error' ? _normalizeForDisplay(firstDerivative) : 'Error',
      secondDerivative: secondDerivative != 'Error' ? _normalizeForDisplay(secondDerivative) : 'Error',
      yIntercept: yIntercept != 'Error' ? _normalizeForDisplay(yIntercept) : 'Error',
      roots: roots.isEmpty ? ['No real roots found'] : roots.map((r) => 'x = ${_normalizeForDisplay(r)}').toList(),
      extrema: extrema,
      inflectionPoints: inflectionPoints,
      errors: errors,
    );
  }
}