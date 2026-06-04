import 'package:crisp_calc/engine/unit_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Dimensions arithmetic', () {
    test('force = mass * acceleration (kg·m/s²)', () {
      const mass = Dimensions(mass: 1);
      const accel = Dimensions(length: 1, time: -2);
      final force = mass * accel;
      expect(force, const Dimensions(mass: 1, length: 1, time: -2));
    });

    test('energy / time = power', () {
      const energy = Dimensions(mass: 1, length: 2, time: -2); // J
      const time = Dimensions(time: 1);
      final power = energy / time;
      expect(power, const Dimensions(mass: 1, length: 2, time: -3)); // W
    });

    test('velocity = length / time', () {
      const length = Dimensions(length: 1);
      const time = Dimensions(time: 1);
      final velocity = length / time;
      expect(velocity, const Dimensions(length: 1, time: -1));
    });

    test('same / same = dimensionless', () {
      const mass = Dimensions(mass: 1);
      final ratio = mass / mass;
      expect(ratio.isZero, isTrue);
      expect(ratio, Dimensions.dimensionless);
    });

    test('dimensionless isZero is true', () {
      expect(Dimensions.dimensionless.isZero, isTrue);
    });

    test('non-dimensionless isZero is false', () {
      expect(const Dimensions(length: 1).isZero, isFalse);
    });

    test('equality and hashCode', () {
      const a = Dimensions(mass: 1, length: 2, time: -2);
      const b = Dimensions(mass: 1, length: 2, time: -2);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('inequality', () {
      const a = Dimensions(mass: 1);
      const b = Dimensions(length: 1);
      expect(a == b, isFalse);
    });
  });

  group('Dimensions.toBaseUnitsString', () {
    test('newton = m·kg/s^2', () {
      const newton = Dimensions(mass: 1, length: 1, time: -2);
      // Order follows addPart sequence: m (length), kg (mass), s (time).
      expect(newton.toBaseUnitsString(), 'm·kg/s^2');
    });

    test('joule = m^2·kg/s^2', () {
      const joule = Dimensions(mass: 1, length: 2, time: -2);
      expect(joule.toBaseUnitsString(), 'm^2·kg/s^2');
    });

    test('hertz = 1/s', () {
      const hertz = Dimensions(time: -1);
      expect(hertz.toBaseUnitsString(), '1/s');
    });

    test('dimensionless returns empty string', () {
      expect(Dimensions.dimensionless.toBaseUnitsString(), '');
    });

    test('simple mass = kg', () {
      const mass = Dimensions(mass: 1);
      expect(mass.toBaseUnitsString(), 'kg');
    });

    test('area = m^2', () {
      const area = Dimensions(length: 2);
      expect(area.toBaseUnitsString(), 'm^2');
    });
  });

  group('Dimensions.of(UnitDimension)', () {
    test('length maps to length=1', () {
      final d = Dimensions.of(UnitDimension.length);
      expect(d, const Dimensions(length: 1));
    });

    test('velocity maps to length=1, time=-1', () {
      final d = Dimensions.of(UnitDimension.velocity);
      expect(d, const Dimensions(length: 1, time: -1));
    });

    test('angle maps to dimensionless', () {
      final d = Dimensions.of(UnitDimension.angle);
      expect(d.isZero, isTrue);
    });
  });

  group('DerivedUnits', () {
    test('bySymbol finds known units', () {
      expect(DerivedUnits.bySymbol('N'), isNotNull);
      expect(DerivedUnits.bySymbol('J'), isNotNull);
      expect(DerivedUnits.bySymbol('W'), isNotNull);
      expect(DerivedUnits.bySymbol('Pa'), isNotNull);
      expect(DerivedUnits.bySymbol('Hz'), isNotNull);
    });

    test('bySymbol returns null for unknown', () {
      expect(DerivedUnits.bySymbol('A'), isNull);
      expect(DerivedUnits.bySymbol('foo'), isNull);
    });

    test('bySymbolWithPrefixes resolves kN', () {
      final kn = DerivedUnits.bySymbolWithPrefixes('kN');
      expect(kn, isNotNull);
      expect(kn!.scale, 1000.0);
      expect(kn.dim, const Dimensions(mass: 1, length: 1, time: -2));
    });

    test('bySymbolWithPrefixes resolves MJ', () {
      final mj = DerivedUnits.bySymbolWithPrefixes('MJ');
      expect(mj, isNotNull);
      expect(mj!.scale, 1e6);
    });

    test('bySymbolWithPrefixes resolves mW', () {
      final mw = DerivedUnits.bySymbolWithPrefixes('mW');
      expect(mw, isNotNull);
      expect(mw!.scale, 0.001);
    });

    test('bySymbolWithPrefixes returns null for nonsense', () {
      expect(DerivedUnits.bySymbolWithPrefixes('xN'), isNull);
      expect(DerivedUnits.bySymbolWithPrefixes('abc'), isNull);
    });

    test('matchingBaseDim finds newton for mass*length/time^2', () {
      const dim = Dimensions(mass: 1, length: 1, time: -2);
      final match = DerivedUnits.matchingBaseDim(dim);
      expect(match, isNotNull);
      expect(match!.symbol, 'N');
    });

    test('matchingBaseDim finds hertz for 1/time', () {
      const dim = Dimensions(time: -1);
      final match = DerivedUnits.matchingBaseDim(dim);
      expect(match, isNotNull);
      expect(match!.symbol, 'Hz');
    });

    test('matchingBaseDim returns null for unmatched dims', () {
      const dim = Dimensions(length: 3); // cubic meters — no derived unit
      expect(DerivedUnits.matchingBaseDim(dim), isNull);
    });

    test('DerivedUnit toSi / fromSi round-trip', () {
      final kn = DerivedUnits.bySymbolWithPrefixes('kN')!;
      expect(kn.toSi(5.0), 5000.0);
      expect(kn.fromSi(5000.0), 5.0);
    });
  });
}
