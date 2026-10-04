import 'package:crisp_math/engine/unit_catalog.dart';
import 'package:crisp_math/engine/unit_expression.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bar pressure conversion', () {
    test('bar definition has pressure dimensions and a 100000 Pa scale', () {
      final bar = DerivedUnits.bySymbol('bar')!;
      expect(bar.dim, const Dimensions(mass: 1, length: -1, time: -2));
      expect(bar.toSi(1), 100000);
      expect(bar.fromSi(100000), 1);
      // Canonical SI pressure formatting must still choose the pascal.
      expect(DerivedUnits.matchingBaseDim(bar.dim)?.symbol, 'Pa');
    });

    for (final example in [
      ['1 kN/m² in bar', '0.01 bar'],
      ['1 bar in Pa', '100000 Pa'],
      ['1000 hPa in bar', '1 bar'],
      ['-2 mbar in Pa', '-200 Pa'],
      ['2 kbar in MPa', '200 MPa'],
      ['1 bar in N/cm²', '10 N/cm²'],
      ['2 bar + 50 kPa in kPa', '250 kPa'],
      ['1 bar/s in kPa/s', '100 kPa/s'],
    ]) {
      test(example.first, () {
        expect(UnitExpressionEvaluator.tryEvaluate(example.first), example.last);
      });
    }

    test('pressure cannot be converted to energy or length', () {
      expect(UnitExpressionEvaluator.tryEvaluate('1 bar in J'),
          startsWith('Error: cannot convert result'));
      expect(UnitExpressionEvaluator.tryEvaluate('1 m in bar'),
          startsWith('Error: cannot convert result'));
    });

    test('a symbol prefix is not accepted inside a longer unknown word', () {
      expect(UnitExpressionEvaluator.tryEvaluate('1 bargain in Pa'), isNull);
    });
  });
}
