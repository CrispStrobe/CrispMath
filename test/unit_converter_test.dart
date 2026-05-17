// test/unit_converter_test.dart
//
// Math correctness for the unit converter. Each test verifies a known
// conversion to within 1e-9 relative tolerance — these are pure
// constant relationships, so we shouldn't need looser bounds.

import 'package:crisp_calc/engine/unit_catalog.dart';
import 'package:crisp_calc/engine/unit_converter.dart';
import 'package:flutter_test/flutter_test.dart';

const _eps = 1e-9;

Unit _u(String symbol) {
  final u = UnitCatalog.bySymbol(symbol);
  if (u == null) throw StateError('test bug: unknown unit $symbol');
  return u;
}

double _convert(double v, String from, String to) {
  final r = UnitConverter.convert(v, _u(from), _u(to));
  if (!r.ok) throw StateError('conversion failed: ${r.error}');
  return r.value;
}

void main() {
  group('UnitCatalog — coverage', () {
    test('every dimension has at least three units', () {
      for (final d in UnitCatalog.allDimensions()) {
        expect(UnitCatalog.unitsFor(d).length, greaterThanOrEqualTo(3),
            reason: 'dim=$d');
      }
    });

    test('every unit symbol is unique', () {
      final seen = <String>{};
      for (final d in UnitCatalog.allDimensions()) {
        for (final u in UnitCatalog.unitsFor(d)) {
          expect(seen.add(u.symbol), isTrue,
              reason: 'duplicate symbol ${u.symbol}');
        }
      }
    });

    test('bySymbol round-trips for every known unit', () {
      for (final d in UnitCatalog.allDimensions()) {
        for (final u in UnitCatalog.unitsFor(d)) {
          final found = UnitCatalog.bySymbol(u.symbol);
          expect(found, isNotNull, reason: 'lookup ${u.symbol}');
          expect(found!.dimension, equals(u.dimension));
        }
      }
    });
  });

  group('length conversions', () {
    test('1 km = 1000 m', () {
      expect(_convert(1, 'km', 'm'), closeTo(1000.0, _eps));
    });
    test('1 mi ≈ 1.609344 km', () {
      expect(_convert(1, 'mi', 'km'), closeTo(1.609344, _eps));
    });
    test('1 ft = 12 in', () {
      expect(_convert(1, 'ft', 'in'), closeTo(12.0, _eps));
    });
    test('1 yd = 3 ft', () {
      expect(_convert(1, 'yd', 'ft'), closeTo(3.0, _eps));
    });
    test('1 mi = 5280 ft', () {
      expect(_convert(1, 'mi', 'ft'), closeTo(5280.0, 1e-6));
    });
    test('1 nmi = 1852 m', () {
      expect(_convert(1, 'nmi', 'm'), closeTo(1852.0, _eps));
    });
    test('round-trip km → mi → km', () {
      final out = _convert(_convert(7, 'km', 'mi'), 'mi', 'km');
      expect(out, closeTo(7.0, _eps));
    });
    test('1 m = 1000 mm', () {
      expect(_convert(1, 'm', 'mm'), closeTo(1000.0, _eps));
    });
    test('1 cm = 10 mm', () {
      expect(_convert(1, 'cm', 'mm'), closeTo(10.0, _eps));
    });
  });

  group('time conversions', () {
    test('1 min = 60 s', () {
      expect(_convert(1, 'min', 's'), closeTo(60.0, _eps));
    });
    test('1 h = 3600 s', () {
      expect(_convert(1, 'h', 's'), closeTo(3600.0, _eps));
    });
    test('1 d = 24 h', () {
      expect(_convert(1, 'd', 'h'), closeTo(24.0, _eps));
    });
    test('1 wk = 7 d', () {
      expect(_convert(1, 'wk', 'd'), closeTo(7.0, _eps));
    });
    test('1 s = 1000 ms', () {
      expect(_convert(1, 's', 'ms'), closeTo(1000.0, _eps));
    });
    test('1 yr ≈ 365.25 days', () {
      expect(_convert(1, 'yr', 'd'), closeTo(365.25, _eps));
    });
  });

  group('mass conversions', () {
    test('1 kg = 1000 g', () {
      expect(_convert(1, 'kg', 'g'), closeTo(1000.0, _eps));
    });
    test('1 lb ≈ 0.45359237 kg', () {
      expect(_convert(1, 'lb', 'kg'), closeTo(0.45359237, _eps));
    });
    test('1 lb = 16 oz', () {
      expect(_convert(1, 'lb', 'oz'), closeTo(16.0, 1e-9));
    });
    test('1 t = 1000 kg', () {
      expect(_convert(1, 't', 'kg'), closeTo(1000.0, _eps));
    });
    test('1 st = 14 lb', () {
      expect(_convert(1, 'st', 'lb'), closeTo(14.0, 1e-9));
    });
  });

  group('temperature conversions (offset matters!)', () {
    // The interesting tests — temperature is an affine transform, not
    // a scale. 0 °C is not 0 K.
    test('0 °C = 273.15 K', () {
      expect(_convert(0, '°C', 'K'), closeTo(273.15, _eps));
    });
    test('100 °C = 373.15 K', () {
      expect(_convert(100, '°C', 'K'), closeTo(373.15, _eps));
    });
    test('0 °C = 32 °F', () {
      expect(_convert(0, '°C', '°F'), closeTo(32.0, 1e-9));
    });
    test('100 °C = 212 °F', () {
      expect(_convert(100, '°C', '°F'), closeTo(212.0, 1e-9));
    });
    test('-40 °C = -40 °F (the famous coincidence)', () {
      expect(_convert(-40, '°C', '°F'), closeTo(-40.0, 1e-9));
    });
    test('0 K = -273.15 °C', () {
      expect(_convert(0, 'K', '°C'), closeTo(-273.15, _eps));
    });
    test('absolute zero in F', () {
      expect(_convert(0, 'K', '°F'), closeTo(-459.67, 1e-9));
    });
    test('round-trip °C → °F → °C', () {
      final out = _convert(_convert(25, '°C', '°F'), '°F', '°C');
      expect(out, closeTo(25.0, 1e-9));
    });
  });

  group('velocity conversions', () {
    test('100 km/h ≈ 27.7778 m/s', () {
      expect(_convert(100, 'km/h', 'm/s'), closeTo(27.77777777777778, 1e-9));
    });
    test('60 mph ≈ 26.8224 m/s', () {
      expect(_convert(60, 'mph', 'm/s'), closeTo(26.8224, _eps));
    });
    test('100 km/h ≈ 62.1371 mph', () {
      expect(_convert(100, 'km/h', 'mph'), closeTo(62.13711922373339, 1e-9));
    });
    test('1 kn = 1 nmi/h precisely', () {
      // 1 knot = 1 nautical mile per hour. So 1 kn * 3600 s = 1852 m.
      expect(_convert(1, 'kn', 'm/s') * 3600.0, closeTo(1852.0, _eps));
    });
    test('1 c = 299792458 m/s', () {
      expect(_convert(1, 'c', 'm/s'), closeTo(299792458.0, _eps));
    });
  });

  group('angle conversions', () {
    test('180° = π rad', () {
      expect(_convert(180, '°', 'rad'),
          closeTo(3.141592653589793, 1e-12));
    });
    test('360° = 2π rad', () {
      expect(_convert(360, '°', 'rad'),
          closeTo(6.283185307179586, 1e-12));
    });
    test('1 turn = 360°', () {
      expect(_convert(1, 'turn', '°'), closeTo(360.0, 1e-9));
    });
    test('1 turn = 400 grad', () {
      expect(_convert(1, 'turn', 'grad'), closeTo(400.0, 1e-9));
    });
    test('1° = 60 arcmin', () {
      expect(_convert(1, '°', 'arcmin'), closeTo(60.0, 1e-9));
    });
    test('1° = 3600 arcsec', () {
      expect(_convert(1, '°', 'arcsec'), closeTo(3600.0, 1e-9));
    });
  });

  group('error handling', () {
    test('cross-dimension conversion fails cleanly', () {
      final r = UnitConverter.convert(1, _u('m'), _u('s'));
      expect(r.ok, isFalse);
      expect(r.error, contains('different dimensions'));
    });

    test('NaN input fails cleanly', () {
      final r = UnitConverter.convert(double.nan, _u('m'), _u('km'));
      expect(r.ok, isFalse);
    });

    test('infinity fails cleanly', () {
      final r =
          UnitConverter.convert(double.infinity, _u('m'), _u('km'));
      expect(r.ok, isFalse);
    });
  });

  group('format', () {
    test('whole numbers strip the decimal point', () {
      expect(UnitConverter.format(5.0, _u('km')), equals('5 km'));
    });
    test('non-trivial decimals are kept', () {
      expect(UnitConverter.format(1.5, _u('m')), equals('1.5 m'));
    });
    test('zero formats cleanly', () {
      expect(UnitConverter.format(0.0, _u('s')), equals('0 s'));
    });
    test('very large values use scientific notation', () {
      final s = UnitConverter.format(1.234e15, _u('m'));
      expect(s, contains('e+15'));
    });
    test('very small values use scientific notation', () {
      final s = UnitConverter.format(1.234e-8, _u('s'));
      expect(s, contains('e-8'));
    });
  });
}
