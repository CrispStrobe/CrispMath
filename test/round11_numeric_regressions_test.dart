import 'package:crisp_math/engine/unit_expression.dart';
import 'package:crisp_math/engine/unit_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void checkQuantity(String source, double expected, String unit) {
  final result = UnitExpressionEvaluator.tryEvaluate(source);
  expect(result, isNotNull, reason: source);
  final parts = result!.split(' ');
  expect(parts.skip(1).join(' ').replaceAll('μ', 'µ'), unit.replaceAll('μ', 'µ'));
  final value = double.parse(parts.first);
  expect(value.isFinite, isTrue);
  if (expected == 0) {
    expect(value, 0);
  } else {
    expect(value / expected, closeTo(1, 1e-10), reason: '$source → $result');
  }
}

void main() {
  test('electrical and magnetic SI relationships compose through prefixes', () {
    checkQuantity('3 µF * 12 V in µC', 36, 'µC');
    checkQuantity('2 mH * 3 A / 4 ms in V', 1.5, 'V');
    checkQuantity('6 mWb / 3 cm² in T', 20, 'T');
    checkQuantity('2 A * 3 s in C', 6, 'C');
    checkQuantity('4 eV in J', 6.408706536e-19, 'J');
    checkQuantity('250 mL / 2 s in L/min', 7.5, 'L/min');
    checkQuantity('6 C / 3 V in F', 2, 'F');
    checkQuantity('3 T * 2 m² in Wb', 6, 'Wb');
    checkQuantity('2 H * 3 A in Wb', 6, 'Wb');
    checkQuantity('1 J in eV', 1 / 1.602176634e-19, 'eV');
  });
  test('implicit derived output preserves tiny nonzero energy', () {
    checkQuantity('4 eV', 6.408706536e-19, 'J');
    checkQuantity('1 pA * 1 ps', 1e-24, 'C');
    checkQuantity('1 pN * 1 pm', 1e-24, 'J');
  });
  test('scientific presentation preserves relative accuracy at both extremes', () {
    for (final value in [6.408706536e-19, 1.23456789012e-200, 1.23456789012e200]) {
      final rendered = double.parse(UnitConverter.formatNumber(value));
      expect(rendered / value, closeTo(1, 1e-11));
    }
    expect(UnitConverter.formatNumber(0), '0');
  });
  test('temperature spellings and incompatible dimensions remain guarded', () {
    checkQuantity('32 °F in K', 273.15, 'K');
    checkQuantity('0 °C in K', 273.15, 'K');
    expect(UnitExpressionEvaluator.tryEvaluate('2 F in °F'), startsWith('Error:'));
    expect(UnitExpressionEvaluator.tryEvaluate('2 C in °C'), startsWith('Error:'));
    expect(UnitExpressionEvaluator.tryEvaluate('2 C + 3 V'), startsWith('Error:'));
    expect(UnitExpressionEvaluator.tryEvaluate('2 °C * 3 V'), startsWith('Error:'));
    expect(UnitExpressionEvaluator.tryEvaluate('2 mH in h'), startsWith('Error:'));
  });
}
