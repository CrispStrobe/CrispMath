import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_calc/engine/unit_catalog.dart';

void main() {
  group('UnitDimension enum', () {
    test('has six dimensions', () {
      expect(UnitDimension.values.length, 6);
    });

    test('all dimensions have at least one unit', () {
      for (final dim in UnitDimension.values) {
        final units = UnitCatalog.unitsFor(dim);
        expect(units.isNotEmpty, true, reason: '${dim.name} should have units');
      }
    });
  });

  group('Dimensions', () {
    test('dimensionless is all zeros', () {
      expect(Dimensions.dimensionless.isZero, true);
    });

    test('multiplication adds exponents', () {
      const m = Dimensions(length: 1);
      const s = Dimensions(time: -1);
      final ms = m * s;
      expect(ms.length, 1);
      expect(ms.time, -1);
    });

    test('division subtracts exponents', () {
      const m = Dimensions(length: 1);
      const result = Dimensions(length: 1);
      final ratio = result / m;
      expect(ratio.isZero, true);
    });

    test('of() maps each UnitDimension', () {
      expect(Dimensions.of(UnitDimension.length), const Dimensions(length: 1));
      expect(Dimensions.of(UnitDimension.mass), const Dimensions(mass: 1));
      expect(Dimensions.of(UnitDimension.time), const Dimensions(time: 1));
      expect(Dimensions.of(UnitDimension.temperature),
          const Dimensions(temperature: 1));
      expect(Dimensions.of(UnitDimension.velocity),
          const Dimensions(length: 1, time: -1));
      expect(Dimensions.of(UnitDimension.angle), const Dimensions());
    });

    test('toBaseUnitsString formats correctly', () {
      expect(const Dimensions(length: 1).toBaseUnitsString(), 'm');
      expect(
          const Dimensions(length: 1, time: -2).toBaseUnitsString(), 'm/s^2');
      expect(const Dimensions(mass: 1, length: 2, time: -2).toBaseUnitsString(),
          'm^2·kg/s^2');
      expect(const Dimensions().toBaseUnitsString(), '');
    });

    test('equality and hashCode', () {
      const a = Dimensions(length: 1, mass: 2);
      const b = Dimensions(length: 1, mass: 2);
      const c = Dimensions(length: 1, mass: 3);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });
  });

  group('UnitCatalog', () {
    test('all units have non-empty symbols', () {
      for (final dim in UnitDimension.values) {
        for (final u in UnitCatalog.unitsFor(dim)) {
          expect(u.symbol.isNotEmpty, true,
              reason: '${u.name} symbol should not be empty');
        }
      }
    });

    test('all units have positive scale (except temperature offsets)', () {
      for (final dim in UnitDimension.values) {
        for (final u in UnitCatalog.unitsFor(dim)) {
          expect(u.scale > 0, true,
              reason: '${u.name} scale should be positive');
        }
      }
    });

    test('SI base units have scale 1.0', () {
      // meter, kilogram, second, kelvin
      final m = UnitCatalog.bySymbol('m');
      expect(m, isNotNull);
      expect(m!.scale, 1.0);

      final kg = UnitCatalog.bySymbol('kg');
      expect(kg, isNotNull);
      expect(kg!.scale, 1.0);

      final s = UnitCatalog.bySymbol('s');
      expect(s, isNotNull);
      expect(s!.scale, 1.0);

      final k = UnitCatalog.bySymbol('K');
      expect(k, isNotNull);
      expect(k!.scale, 1.0);
    });

    test('kilometer is 1000 meters', () {
      final km = UnitCatalog.bySymbol('km');
      expect(km, isNotNull);
      expect(km!.scale, 1000.0);
    });

    test('bySymbolWithPrefixes finds milli/micro', () {
      final mm = UnitCatalog.bySymbolWithPrefixes('mm');
      expect(mm, isNotNull);
      expect(mm!.scale, closeTo(0.001, 1e-10));
    });
  });

  group('DerivedUnits', () {
    test('Newton has correct dimensions (kg·m/s²)', () {
      final n = DerivedUnits.bySymbol('N');
      expect(n, isNotNull);
      expect(n!.dim, const Dimensions(mass: 1, length: 1, time: -2));
      expect(n.scale, 1.0);
    });

    test('Joule has correct dimensions (kg·m²/s²)', () {
      final j = DerivedUnits.bySymbol('J');
      expect(j, isNotNull);
      expect(j!.dim, const Dimensions(mass: 1, length: 2, time: -2));
    });

    test('Watt has correct dimensions (kg·m²/s³)', () {
      final w = DerivedUnits.bySymbol('W');
      expect(w, isNotNull);
      expect(w!.dim, const Dimensions(mass: 1, length: 2, time: -3));
    });

    test('Pascal has correct dimensions (kg/m·s²)', () {
      final pa = DerivedUnits.bySymbol('Pa');
      expect(pa, isNotNull);
      expect(pa!.dim, const Dimensions(mass: 1, length: -1, time: -2));
    });

    test('Hertz has correct dimensions (1/s)', () {
      final hz = DerivedUnits.bySymbol('Hz');
      expect(hz, isNotNull);
      expect(hz!.dim, const Dimensions(time: -1));
    });

    test('all five derived units are present', () {
      for (final sym in ['N', 'J', 'W', 'Pa', 'Hz']) {
        expect(DerivedUnits.bySymbol(sym), isNotNull,
            reason: '$sym should exist');
      }
    });

    test('prefixed derived units scale correctly', () {
      final kn = DerivedUnits.bySymbolWithPrefixes('kN');
      expect(kn, isNotNull);
      expect(kn!.scale, 1000.0);

      final mj = DerivedUnits.bySymbolWithPrefixes('MJ');
      expect(mj, isNotNull);
      expect(mj!.scale, 1e6);
    });
  });
}
