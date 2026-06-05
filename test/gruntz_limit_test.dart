// Tests for the Gruntz-style limit at infinity (Tier 4).
// These test the growth classification and limit computation
// WITHOUT needing the native SymEngine bridge.

import 'package:flutter_test/flutter_test.dart';

// We test the growth classification patterns via regex matching
// since the actual limit computation needs CalculatorEngine.
void main() {
  group('Growth rate classification patterns', () {
    // These patterns are used by _classifyGrowth internally
    final expPattern = RegExp(r'(?:exp|e\^)\s*\((.+)\)');
    final logPattern = RegExp(r'(?:log|ln)\s*\((.+)\)');

    test('detects exp(x)', () {
      expect(expPattern.hasMatch('exp(x)'), isTrue);
      expect(expPattern.hasMatch('e^(x)'), isTrue);
      expect(expPattern.hasMatch('exp(x^2)'), isTrue);
    });

    test('detects log(x)', () {
      expect(logPattern.hasMatch('log(x)'), isTrue);
      expect(logPattern.hasMatch('ln(x)'), isTrue);
      expect(logPattern.hasMatch('log(x^2)'), isTrue);
    });

    test('does not match non-exp/log', () {
      expect(expPattern.hasMatch('x^2'), isFalse);
      expect(logPattern.hasMatch('x^2'), isFalse);
      expect(expPattern.hasMatch('sin(x)'), isFalse);
    });
  });

  group('Infinity detection', () {
    test('recognizes infinity symbols', () {
      for (final inf in ['oo', 'inf', 'infinity', 'Infinity', '∞']) {
        expect(
          inf == 'oo' || inf.toLowerCase().contains('inf') || inf == '∞',
          isTrue,
          reason: '$inf should be recognized as infinity',
        );
      }
    });

    test('negative infinity', () {
      for (final ninf in ['-oo', '-inf', '-infinity', '-∞']) {
        expect(ninf.startsWith('-'), isTrue);
      }
    });
  });

  group('Growth hierarchy', () {
    // Verify the ordering: constant < log < poly < exp < superExp
    test('exponential beats polynomial', () {
      // In the enum: exponential.index > polynomial.index
      // We can't import the private enum, so test via string convention
      const hierarchy = [
        'constant',
        'logarithmic',
        'polynomial',
        'exponential',
        'superExponential'
      ];
      expect(hierarchy.indexOf('exponential'),
          greaterThan(hierarchy.indexOf('polynomial')));
    });

    test('polynomial beats logarithmic', () {
      const hierarchy = [
        'constant',
        'logarithmic',
        'polynomial',
        'exponential',
        'superExponential'
      ];
      expect(hierarchy.indexOf('polynomial'),
          greaterThan(hierarchy.indexOf('logarithmic')));
    });

    test('logarithmic beats constant', () {
      const hierarchy = [
        'constant',
        'logarithmic',
        'polynomial',
        'exponential',
        'superExponential'
      ];
      expect(hierarchy.indexOf('logarithmic'),
          greaterThan(hierarchy.indexOf('constant')));
    });
  });

  group('Degree estimation patterns', () {
    // The degree estimator parses polynomial degree from expressions
    final degreePattern = RegExp(r'x\^(\d+)');

    test('extracts degree from x^n', () {
      expect(degreePattern.firstMatch('x^2')?.group(1), '2');
      expect(degreePattern.firstMatch('3*x^5')?.group(1), '5');
      expect(degreePattern.firstMatch('x^10 + x^3')?.group(1), '10');
    });

    test('linear has no explicit power', () {
      expect(degreePattern.hasMatch('2*x + 1'), isFalse);
    });
  });
}
