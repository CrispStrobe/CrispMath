import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_calc/engine/step_diagnostics.dart';
import 'package:crisp_calc/engine/calculator_engine.dart';

void main() {
  group('StepDiagnostics normalize', () {
    // Test the normalization logic by constructing StepDiagnosticResult
    // manually and checking match behavior.
    test('whitespace is stripped', () {
      expect(_matchesNormalized('x^2 / 2', 'x^2/2'), true);
      expect(_matchesNormalized('  x  + 1  ', 'x+1'), true);
    });

    test('middle dot replaced with asterisk', () {
      expect(_matchesNormalized('2·x', '2*x'), true);
    });

    test('double-star replaced with caret', () {
      expect(_matchesNormalized('x**2', 'x^2'), true);
    });

    test('parentheses stripped', () {
      expect(_matchesNormalized('(x)^2/2', 'x^2/2'), true);
      expect(_matchesNormalized('sin((x))', 'sinx'), true);
    });

    test('case insensitive', () {
      expect(_matchesNormalized('SIN(X)', 'sin(x)'), true);
      expect(_matchesNormalized('Exp(X)', 'exp(x)'), true);
    });

    test('absolute value bars stripped', () {
      expect(_matchesNormalized('ln|x|', 'lnx'), true);
    });

    test('pipe-separated alternates match any', () {
      expect(_matchesNormalized('2*x', '2x|2*x|x*2'), true);
      expect(_matchesNormalized('x*2', '2x|2*x|x*2'), true);
      expect(_matchesNormalized('3x', '2x|2*x|x*2'), false);
    });
  });

  group('StepDiagnosticResult', () {
    test('constructor stores all fields', () {
      const r = StepDiagnosticResult(
        name: 'test',
        operation: 'diff',
        expression: 'x^2',
        expected: '2*x',
        actual: '2*x',
        passed: true,
      );
      expect(r.name, 'test');
      expect(r.operation, 'diff');
      expect(r.expression, 'x^2');
      expect(r.expected, '2*x');
      expect(r.actual, '2*x');
      expect(r.passed, true);
    });

    test('failed result stores false', () {
      const r = StepDiagnosticResult(
        name: 'test',
        operation: 'diff',
        expression: 'x^2',
        expected: '3*x',
        actual: '2*x',
        passed: false,
      );
      expect(r.passed, false);
    });
  });

  group('StepDiagnostics.run (headless, no bridge)', () {
    test('returns results for all specs', () {
      final engine = CalculatorEngine();
      final results = StepDiagnostics.run(engine);
      // Without the native bridge, all specs run but may fail (Error:
      // requires native library). The important thing is that run()
      // doesn't crash and returns the right count.
      expect(results.length, greaterThanOrEqualTo(37));
      for (final r in results) {
        expect(r.name.isNotEmpty, true);
        expect(['diff', 'integrate', 'solve'], contains(r.operation));
        expect(r.expression.isNotEmpty, true);
        expect(r.expected.isNotEmpty, true);
        expect(r.actual.isNotEmpty, true);
      }
    });

    test('each spec has a unique name', () {
      final engine = CalculatorEngine();
      final results = StepDiagnostics.run(engine);
      final names = results.map((r) => r.name).toSet();
      expect(names.length, results.length,
          reason: 'spec names should be unique');
    });

    test('diff specs are first, then integrate, then solve', () {
      final engine = CalculatorEngine();
      final results = StepDiagnostics.run(engine);
      final ops = results.map((r) => r.operation).toList();
      // All diffs should come before any integrates, all integrates
      // before any solves
      final firstInt = ops.indexOf('integrate');
      final lastDiff = ops.lastIndexOf('diff');
      final firstSolve = ops.indexOf('solve');
      final lastInt = ops.lastIndexOf('integrate');
      if (firstInt >= 0) expect(lastDiff < firstInt, true);
      if (firstSolve >= 0) expect(lastInt < firstSolve, true);
    });
  });
}

/// Mirror the normalization + matching logic from StepDiagnostics for testing.
/// (The actual methods are private, so we reimplement the same algorithm.)
bool _matchesNormalized(String actual, String expected) {
  final na = _normalize(actual);
  for (final alt in expected.split('|')) {
    if (na.contains(_normalize(alt))) return true;
  }
  return false;
}

String _normalize(String s) {
  return s
      .replaceAll('·', '*')
      .replaceAll('**', '^')
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll('(', '')
      .replaceAll(')', '')
      .replaceAll('|', '')
      .toLowerCase();
}
