import 'package:crisp_math/engine/csp_solver.dart';
import 'package:crisp_math/engine/unit_catalog.dart';
import 'package:crisp_math/engine/unit_expression.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('electrical SI units retain independent current dimensions', () {
    test('current contributes to equality hash arithmetic and base formatting', () {
      const current = Dimensions(current: 1);
      expect(current.isZero, isFalse);
      expect(current, isNot(Dimensions.dimensionless));
      expect({current, Dimensions.dimensionless}.length, 2);
      expect(current / current, Dimensions.dimensionless);
      expect(DerivedUnits.bySymbol('V')!.dim * current,
          DerivedUnits.bySymbol('W')!.dim);
      expect(DerivedUnits.bySymbol('Ω')!.dim * current,
          DerivedUnits.bySymbol('V')!.dim);
      expect(current.toBaseUnitsString(), 'A');
    });
    final conversions = <String, String>{
      '1 mA * 1 kΩ in V': '1 V',
      '2 mA * 3 kohm in V': '6 V',
      '1 V / 1 A in Ω': '1 Ω',
      '1 V / 1 A in ohm': '1 Ω',
      '3 A * 2 V in W': '6 W',
      '8 W / 2 A in V': '4 V',
      '12 V / 3 Ω in A': '4 A',
      '1 Ω in kg*m²/s³/A²': '1 kg*m²/s³/A²',
      '1 V in kg*m²/s³/A': '1 kg*m²/s³/A',
      '1 μA * 1 MΩ in V': '1 V',
      '1 µA * 1 MΩ in V': '1 V',
    };
    for (final entry in conversions.entries) {
      test(entry.key, () {
        expect(UnitExpressionEvaluator.tryEvaluate(entry.key), entry.value);
      });
    }
    test('current and voltage cannot convert to mechanical or scalar quantities', () {
      for (final source in ['1 A in m', '1 V in W', '1 Ω in J',
        '1 A in V', '1 Ω in kg*m²/s³']) {
        expect(UnitExpressionEvaluator.tryEvaluate(source), startsWith('Error:'),
            reason: source);
      }
      expect(UnitExpressionEvaluator.tryEvaluate('1 kΩx in Ω'), isNull);
    });
    test('fallback denominators preserve left-associative roundtrip dimensions', () {
      final dimensions = DerivedUnits.bySymbol('V')!.dim /
          const Dimensions(current: 2);
      final symbol = dimensions.toBaseUnitsString();
      expect(symbol, 'm^2·kg/s^3/A^3');
      expect(UnitExpressionEvaluator.tryEvaluate('1 V / 1 A² in $symbol'),
          '1 m²·kg/s³/A³');
    });
  });

  group('powered standalone factors share compound grammar', () {
    final conversions = <String, String>{
      '1 m² / 1 s² in J/kg': '1 J/kg',
      '1 m^2 / 1 s^2 in J/kg': '1 J/kg',
      '1 ms² in s²': '0.000001 s²',
      '1 ks^2 in s²': '1000000 s²',
      '1 A² * 1 Ω in W': '1 W',
      '1 s³ * 1 W in kg*m²': '1 kg*m²',
    };
    for (final entry in conversions.entries) {
      test(entry.key, () {
        final result = UnitExpressionEvaluator.tryEvaluate(entry.key);
        // Tiny values may use either ordinary or scientific notation.
        if (entry.key == '1 ms² in s²') {
          expect(result, isNotNull);
          expect(result!.split(' ').last, 's²');
          expect(double.parse(result.split(' ').first), 1e-6);
        } else {
          expect(result, entry.value);
        }
      });
    }
    test('affine powers malformed exponents and dimension mismatches fail', () {
      for (final source in ['1 °C² in K²', '1 °F^3 in K³',
        '1 s^4 in s²', '1 s^^2 in s²', '1 s²x in s²']) {
        expect(UnitExpressionEvaluator.tryEvaluate(source), isNull, reason: source);
      }
      expect(UnitExpressionEvaluator.tryEvaluate('1 s² in s³'),
          startsWith('Error:'));
      expect(UnitExpressionEvaluator.tryEvaluate('0 °C in K'), '273.15 K');
      expect(UnitExpressionEvaluator.tryEvaluate('1e309 A in A'), isNull);
      expect(UnitExpressionEvaluator.tryEvaluate('1e308 A * 1e308 Ω in V'),
          startsWith('Error:'));
      expect(UnitExpressionEvaluator.tryEvaluate('1e308 A in yA'),
          startsWith('Error:'));
      expect(UnitExpressionEvaluator.tryEvaluate('1 ym + 1e308 m'),
          startsWith('Error:'));
      // Finite source magnitudes whose powers are unrepresentable must not
      // manufacture a zero or infinite conversion scale.
      expect(UnitExpressionEvaluator.tryEvaluate(
          '1 Ym³*Ym³*Ym³*Ym³*Ym³ in m³'), isNull);
    });
  });

  group('bounded grouped integer polynomial objectives', () {
    test('shifted-factor objective returns an adjacent global minimizer', () async {
      final result = await CspSolver.solveDsl(
          'vars: x, y in -3..3\nx+y == 0\n'
          'minimize (x-2)*(x-2)+(y+1)*(y+1)');
      expect(result.ok, isTrue, reason: result.error);
      expect(result.objective, 1);
      expect(result.solutions, isNotEmpty);
      for (final solution in result.solutions) {
        final x = solution['x'] as int;
        final y = solution['y'] as int;
        expect(x + y, 0);
        expect((x - 2) * (x - 2) + (y + 1) * (y + 1), 1);
        expect([1, 2], contains(x));
      }
    });
    test('grouped nonlinear constraint has a complete finite root set', () async {
      final result = await CspSolver.solveDsl(
          'vars: x in -3..3\n(x-1)*(x+1) == 0');
      expect(result.ok, isTrue, reason: result.error);
      expect(result.solutions.map((s) => s['x']), unorderedEquals([-1, 1]));
      expect(result.truncated, isFalse);
    });
    test('unary signs precedence and repeated factors stay exact', () async {
      final result = await CspSolver.solveDsl(
          'vars: x in -3..3\nmaximize -(x-1)*(x-1)+2*x');
      // -x²+4x-1 has its integer maximum three at x=2.
      expect(result.ok, isTrue, reason: result.error);
      expect(result.objective, 3);
      expect(result.solutions.every((s) => s['x'] == 2), isTrue);
    });
    test('cancelling and zero products retain the remaining exact objective', () async {
      final result = await CspSolver.solveDsl(
          'vars: x in -2..2\n'
          'minimize (x-1)*(x-1)-(x-1)*(x-1)+x*x+0*(x+2)');
      expect(result.ok, isTrue, reason: result.error);
      expect(result.objective, 0);
      expect(result.solutions.every((s) => s['x'] == 0), isTrue);
    });
    test('grouped cancellation may reduce an objective or comparison to linear', () async {
      final result = await CspSolver.solveDsl(
          'vars: x in -2..2\n'
          '(x+1)*(x-1)-x*x+x >= 0\n'
          'minimize (x+1)*(x-1)-x*x+x');
      // Each expression is exactly x-1; x>=1 and min(x-1)=0.
      expect(result.ok, isTrue, reason: result.error);
      expect(result.objective, 0);
      expect(result.solutions.every((s) => s['x'] == 1), isTrue);
    });
    test('constant grouped comparisons retain all or reject all assignments', () async {
      final trueResult = await CspSolver.solveDsl(
          'vars: x in 0..1\n(1+1) == 2');
      expect(trueResult.ok, isTrue, reason: trueResult.error);
      expect(trueResult.solutions.map((s) => s['x']), unorderedEquals([0, 1]));
      final falseResult = await CspSolver.solveDsl(
          'vars: x in 0..1\n(1+1) == 3');
      expect(falseResult.ok, isTrue, reason: falseResult.error);
      expect(falseResult.solutions, isEmpty);
      final cancelled = await CspSolver.solveDsl(
          'vars: x in -1..1\n(x+1)*(x-1)-x*x == -1');
      expect(cancelled.ok, isTrue, reason: cancelled.error);
      expect(cancelled.solutions.map((s) => s['x']), unorderedEquals([-1, 0, 1]));
    });
    test('source budget boundary permits zero and repeated exact terms', () async {
      for (final term in ['0*x', 'x*x']) {
        final result = await CspSolver.solveDsl(
            'vars: x in -1..1\nminimize ${List.filled(64, term).join('+')}');
        expect(result.ok, isTrue, reason: result.error);
        expect(result.objective, 0);
        expect(result.solutions, isNotEmpty);
      }
    });
    test('unsupported syntax and resource budgets fail before optimization', () async {
      final expansion = List.filled(9, '(x+y)').join('*');
      final nested = '${List.filled(40, '(').join()}x*x'
          '${List.filled(40, ')').join()}';
      for (final expression in ['(x-1)/(x+1)', '(x-1)^2',
        '(x-1)(x+1)', '(z-1)*(z+1)', '(x-1)*(x+1',
        expansion, nested, List.filled(65, 'x*x').join('+'),
        List.filled(65, '0*x').join('+')]) {
        final result = await CspSolver.solveDsl(
            'vars: x, y in -2..2\nminimize $expression');
        expect(result.ok, isFalse, reason: expression);
        expect(result.error, isNotNull);
      }
      final wide = await CspSolver.solveDsl(
          'vars: x in -100..100\nminimize (x-1)*(x-1)');
      expect(wide.ok, isFalse);
      expect(wide.error, contains('resource limit'));
    });
  });
}
