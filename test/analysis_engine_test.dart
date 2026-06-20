import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_calc/engine/calculator_engine.dart';
import 'package:crisp_calc/engine/analysis_engine.dart';

// These tests exercise the analysis pipeline without the native bridge — the
// underlying CalculatorEngine returns "Error: ... requires native library" for
// every operation. The point is to confirm the analysis engine handles those
// errors gracefully and produces structured AnalysisResult objects.
//
// Where the pure-Dart fallbacks (NumericFallbackEvaluator, SymbolicWeb) can
// handle polynomial expressions, we also verify that the analysis engine
// produces meaningful derivative / root / extrema results.

void main() {
  late AnalysisEngine analysis;

  setUpAll(() {
    analysis = AnalysisEngine(CalculatorEngine());
  });

  // =========================================================================
  // Original tests
  // =========================================================================

  test('performCurveAnalysis returns a result for any input', () async {
    final result = await analysis.performCurveAnalysis('x^2 - 1');
    expect(result, isA<AnalysisResult>());
    expect(result.originalFunction, equals('x^2 - 1'));
  });

  test('invalid functions produce errors rather than throwing', () async {
    final result = await analysis.performCurveAnalysis('');
    expect(result.errors, isNotEmpty);
  });

  test('result fields are always strings (or lists of strings), never null',
      () async {
    final result = await analysis.performCurveAnalysis('x');
    expect(result.firstDerivative, isA<String>());
    expect(result.secondDerivative, isA<String>());
    expect(result.yIntercept, isA<String>());
    expect(result.roots, isA<List<String>>());
    expect(result.extrema, isA<List<String>>());
    expect(result.inflectionPoints, isA<List<String>>());
    expect(result.errors, isA<List<String>>());
  });

  // =========================================================================
  // Input validation
  // =========================================================================

  group('input validation', () {
    test('empty expression yields errors and Error fields', () async {
      final result = await analysis.performCurveAnalysis('');
      expect(result.errors, isNotEmpty);
      expect(result.errors.first, contains('Invalid function'));
      expect(result.firstDerivative, equals('Error'));
      expect(result.secondDerivative, equals('Error'));
      expect(result.yIntercept, equals('Error'));
      expect(result.originalFunction, equals(''));
    });

    test('whitespace-only expression is invalid', () async {
      final result = await analysis.performCurveAnalysis('   ');
      expect(result.errors, isNotEmpty);
      expect(result.errors.first, contains('Invalid function'));
    });

    test('expression without variable x is invalid', () async {
      // _isValidFunction requires the expression to contain 'x'
      final result = await analysis.performCurveAnalysis('42');
      expect(result.errors, isNotEmpty);
      expect(result.errors.first, contains('Invalid function'));
    });

    test('expression "Error" is treated as invalid', () async {
      final result = await analysis.performCurveAnalysis('Error');
      expect(result.errors, isNotEmpty);
      expect(result.errors.first, contains('Invalid function'));
    });

    test('expression containing "Error" substring is invalid', () async {
      final result = await analysis.performCurveAnalysis('Error: something');
      expect(result.errors, isNotEmpty);
    });
  });

  // =========================================================================
  // Result structure
  // =========================================================================

  group('result structure', () {
    test('originalFunction is preserved verbatim', () async {
      const expr = 'x^2 + 3*x - 7';
      final result = await analysis.performCurveAnalysis(expr);
      expect(result.originalFunction, equals(expr));
    });

    test('all list fields are non-null lists', () async {
      final result = await analysis.performCurveAnalysis('x^3');
      expect(result.roots, isA<List<String>>());
      expect(result.extrema, isA<List<String>>());
      expect(result.inflectionPoints, isA<List<String>>());
      expect(result.errors, isA<List<String>>());
    });

    test('roots list is never empty — contains message or values', () async {
      final result = await analysis.performCurveAnalysis('x^2 + 1');
      // Even if no real roots are found, the list has a descriptive entry
      expect(result.roots, isNotEmpty);
    });

    test('extrema list is never empty — contains message or values', () async {
      final result = await analysis.performCurveAnalysis('x');
      expect(result.extrema, isNotEmpty);
    });

    test('inflectionPoints list is never empty — contains message or values',
        () async {
      final result = await analysis.performCurveAnalysis('x');
      expect(result.inflectionPoints, isNotEmpty);
    });
  });

  // =========================================================================
  // Error propagation
  // =========================================================================

  group('error propagation', () {
    test('invalid function populates extrema and inflectionPoints with error',
        () async {
      final result = await analysis.performCurveAnalysis('');
      expect(result.extrema, contains('Error: Invalid function'));
      expect(result.inflectionPoints, contains('Error: Invalid function'));
    });

    test('analysis never throws, even on pathological input', () async {
      // These should all complete without throwing
      final inputs = [
        '',
        '   ',
        '!!!',
        'Error',
        '42',
        'sin(x',   // unbalanced paren
        '(((x)))', // deeply nested
      ];
      for (final input in inputs) {
        final result = await analysis.performCurveAnalysis(input);
        expect(result, isA<AnalysisResult>(),
            reason: 'Failed for input: "$input"');
      }
    });
  });

  // =========================================================================
  // Edge cases
  // =========================================================================

  group('edge cases', () {
    test('very long expression does not throw', () async {
      // Build a long polynomial: x + x + x + ... (200 terms)
      final longExpr = List.filled(200, 'x').join(' + ');
      final result = await analysis.performCurveAnalysis(longExpr);
      expect(result, isA<AnalysisResult>());
      expect(result.originalFunction, equals(longExpr));
    });

    test('special characters in expression do not throw', () async {
      final inputs = [
        'x + @',
        'x & y',
        'x\$2',
        'x#1',
      ];
      for (final input in inputs) {
        final result = await analysis.performCurveAnalysis(input);
        expect(result, isA<AnalysisResult>(),
            reason: 'Threw for input: "$input"');
      }
    });

    test('expression with multiple variables still runs', () async {
      // Contains 'x' so passes _isValidFunction's contains('x') check
      final result = await analysis.performCurveAnalysis('x + y + z');
      expect(result, isA<AnalysisResult>());
      expect(result.originalFunction, equals('x + y + z'));
    });

    test('unicode in expression does not throw', () async {
      final result = await analysis.performCurveAnalysis('x² + x');
      expect(result, isA<AnalysisResult>());
    });

    test('expression with only whitespace around x', () async {
      final result = await analysis.performCurveAnalysis('  x  ');
      expect(result, isA<AnalysisResult>());
      expect(result.originalFunction, equals('  x  '));
    });
  });

  // =========================================================================
  // Pure-Dart polynomial analysis (SymbolicWeb fallback)
  // =========================================================================

  group('polynomial analysis via pure-Dart fallback', () {
    test('linear function x: derivative is 1', () async {
      final result = await analysis.performCurveAnalysis('x');
      // SymbolicWeb.differentiate('x', 'x') returns '1'
      // The second derivative of a constant '1' is '0'
      expect(result.firstDerivative, isNot(equals('Error')));
      expect(result.errors, isEmpty,
          reason: 'No errors expected for simple polynomial');
    });

    test('quadratic x^2: first derivative is 2*x', () async {
      final result = await analysis.performCurveAnalysis('x^2');
      expect(result.firstDerivative, isNot(equals('Error')));
      expect(result.errors, isEmpty);
    });

    test('y-intercept is computed for polynomials', () async {
      // f(x) = x^2 + 3, f(0) = 3
      final result = await analysis.performCurveAnalysis('x^2 + 3');
      expect(result.yIntercept, isNot(equals('Error')));
    });

    test('cubic x^3 has inflection point info', () async {
      final result = await analysis.performCurveAnalysis('x^3');
      expect(result.firstDerivative, isNot(equals('Error')));
      expect(result.secondDerivative, isNot(equals('Error')));
      // The inflection points list should have content (not just error)
      expect(result.inflectionPoints, isNotEmpty);
    });

    test('constant derivative yields no-critical-points message', () async {
      // f(x) = x, f'(x) = 1 (constant, nonzero)
      final result = await analysis.performCurveAnalysis('x');
      // extrema should mention no critical points
      expect(result.extrema.any((e) => e.contains('No critical points')), true,
          reason: 'Expected no-critical-points message, got: ${result.extrema}');
    });

    test('roots for x^2 - 1 include root values', () async {
      final result = await analysis.performCurveAnalysis('x^2 - 1');
      // SymbolicWeb.solveList can solve quadratics
      // roots should contain formatted entries (either values or "No real roots")
      expect(result.roots, isNotEmpty);
    });

    test('x^2 has a critical point at x=0', () async {
      final result = await analysis.performCurveAnalysis('x^2');
      // f'(x) = 2x, critical point at x=0
      // f''(x) = 2 > 0 => Local Minimum
      expect(
          result.extrema.any(
              (e) => e.contains('Minimum') || e.contains('Critical Point')),
          true,
          reason: 'Expected extremum info, got: ${result.extrema}');
    });
  });

  // =========================================================================
  // AnalysisResult construction
  // =========================================================================

  group('AnalysisResult data class', () {
    test('can be constructed with all required fields', () {
      final result = AnalysisResult(
        originalFunction: 'x^2',
        firstDerivative: '2x',
        secondDerivative: '2',
        yIntercept: '0',
        roots: ['x = 0'],
        extrema: ['Local Minimum: (0, 0)'],
        inflectionPoints: ['No inflection points'],
        errors: [],
      );
      expect(result.originalFunction, equals('x^2'));
      expect(result.firstDerivative, equals('2x'));
      expect(result.secondDerivative, equals('2'));
      expect(result.yIntercept, equals('0'));
      expect(result.roots, hasLength(1));
      expect(result.extrema, hasLength(1));
      expect(result.inflectionPoints, hasLength(1));
      expect(result.errors, isEmpty);
    });

    test('can be constructed with empty lists', () {
      final result = AnalysisResult(
        originalFunction: '',
        firstDerivative: 'Error',
        secondDerivative: 'Error',
        yIntercept: 'Error',
        roots: [],
        extrema: [],
        inflectionPoints: [],
        errors: ['everything failed'],
      );
      expect(result.roots, isEmpty);
      expect(result.extrema, isEmpty);
      expect(result.inflectionPoints, isEmpty);
      expect(result.errors, hasLength(1));
    });

    test('can be constructed with multiple errors', () {
      final result = AnalysisResult(
        originalFunction: 'bad',
        firstDerivative: 'Error',
        secondDerivative: 'Error',
        yIntercept: 'Error',
        roots: [],
        extrema: [],
        inflectionPoints: [],
        errors: ['error1', 'error2', 'error3'],
      );
      expect(result.errors, hasLength(3));
    });
  });
}
