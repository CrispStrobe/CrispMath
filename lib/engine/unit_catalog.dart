// lib/engine/unit_catalog.dart
//
// Catalog of physical units we know how to convert. Each unit has a
// symbol, a human name, and a (scale, offset) pair that takes it to
// the canonical SI base unit for its dimension: `value_in_base =
// value * scale + offset`. The offset handles temperatures (°C, °F),
// which aren't simple proportionals to Kelvin. Everything else has
// offset = 0.
//
// V1 covers six dimensions: length, time, mass, temperature,
// velocity (a derived dimension we keep separate for UX clarity),
// and angle. Composite-dimension arithmetic (e.g. force = mass *
// acceleration) is V2 — for now the converter only works within a
// single dimension category, which covers ~95% of homework and
// engineering quick-conversion use cases.

enum UnitDimension { length, time, mass, temperature, velocity, angle }

class Unit {
  /// Short symbol the user picks from a dropdown. e.g. "km", "°C".
  final String symbol;

  /// Human-readable name shown alongside the symbol.
  final String name;

  /// Multiplier into the canonical base unit for [dimension].
  final double scale;

  /// Additive offset (after scaling) into the base unit. Zero except
  /// for temperatures: °C → K is (x * 1.0) + 273.15, °F → K is
  /// (x * 5/9) + (459.67 * 5/9).
  final double offset;

  final UnitDimension dimension;

  const Unit({
    required this.symbol,
    required this.name,
    required this.dimension,
    required this.scale,
    this.offset = 0.0,
  });

  /// Convert a value expressed in this unit to its dimension's base.
  double toBase(double value) => value * scale + offset;

  /// Inverse of [toBase].
  double fromBase(double baseValue) => (baseValue - offset) / scale;
}

class UnitCatalog {
  /// All known units, grouped by dimension. Order within a list is the
  /// order the picker shows.
  static const Map<UnitDimension, List<Unit>> _byDimension = {
    // === Length (base: metre) ============================================
    UnitDimension.length: [
      Unit(symbol: 'm', name: 'metre', dimension: UnitDimension.length, scale: 1.0),
      Unit(symbol: 'km', name: 'kilometre', dimension: UnitDimension.length, scale: 1000.0),
      Unit(symbol: 'cm', name: 'centimetre', dimension: UnitDimension.length, scale: 0.01),
      Unit(symbol: 'mm', name: 'millimetre', dimension: UnitDimension.length, scale: 0.001),
      Unit(symbol: 'μm', name: 'micrometre', dimension: UnitDimension.length, scale: 1e-6),
      Unit(symbol: 'nm', name: 'nanometre', dimension: UnitDimension.length, scale: 1e-9),
      Unit(symbol: 'mi', name: 'mile', dimension: UnitDimension.length, scale: 1609.344),
      Unit(symbol: 'yd', name: 'yard', dimension: UnitDimension.length, scale: 0.9144),
      Unit(symbol: 'ft', name: 'foot', dimension: UnitDimension.length, scale: 0.3048),
      Unit(symbol: 'in', name: 'inch', dimension: UnitDimension.length, scale: 0.0254),
      Unit(symbol: 'nmi', name: 'nautical mile', dimension: UnitDimension.length, scale: 1852.0),
      Unit(symbol: 'AU', name: 'astronomical unit', dimension: UnitDimension.length, scale: 1.495978707e11),
      Unit(symbol: 'ly', name: 'light-year', dimension: UnitDimension.length, scale: 9.4607304725808e15),
    ],

    // === Time (base: second) =============================================
    UnitDimension.time: [
      Unit(symbol: 's', name: 'second', dimension: UnitDimension.time, scale: 1.0),
      Unit(symbol: 'ms', name: 'millisecond', dimension: UnitDimension.time, scale: 0.001),
      Unit(symbol: 'μs', name: 'microsecond', dimension: UnitDimension.time, scale: 1e-6),
      Unit(symbol: 'ns', name: 'nanosecond', dimension: UnitDimension.time, scale: 1e-9),
      Unit(symbol: 'min', name: 'minute', dimension: UnitDimension.time, scale: 60.0),
      Unit(symbol: 'h', name: 'hour', dimension: UnitDimension.time, scale: 3600.0),
      Unit(symbol: 'd', name: 'day', dimension: UnitDimension.time, scale: 86400.0),
      Unit(symbol: 'wk', name: 'week', dimension: UnitDimension.time, scale: 604800.0),
      Unit(symbol: 'yr', name: 'year (365.25 d)', dimension: UnitDimension.time, scale: 31557600.0),
    ],

    // === Mass (base: kilogram) ===========================================
    UnitDimension.mass: [
      Unit(symbol: 'kg', name: 'kilogram', dimension: UnitDimension.mass, scale: 1.0),
      Unit(symbol: 'g', name: 'gram', dimension: UnitDimension.mass, scale: 0.001),
      Unit(symbol: 'mg', name: 'milligram', dimension: UnitDimension.mass, scale: 1e-6),
      Unit(symbol: 't', name: 'tonne', dimension: UnitDimension.mass, scale: 1000.0),
      Unit(symbol: 'lb', name: 'pound', dimension: UnitDimension.mass, scale: 0.45359237),
      Unit(symbol: 'oz', name: 'ounce', dimension: UnitDimension.mass, scale: 0.028349523125),
      Unit(symbol: 'st', name: 'stone', dimension: UnitDimension.mass, scale: 6.35029318),
    ],

    // === Temperature (base: Kelvin) ======================================
    // Temperature is the only dimension where offset != 0. °C and °F
    // are NOT scale multiples of Kelvin — converting between them
    // requires the full affine transform.
    UnitDimension.temperature: [
      Unit(symbol: 'K', name: 'kelvin', dimension: UnitDimension.temperature, scale: 1.0),
      Unit(symbol: '°C', name: 'celsius', dimension: UnitDimension.temperature, scale: 1.0, offset: 273.15),
      // °F → K: K = (F - 32) * 5/9 + 273.15
      //       = F * 5/9 + (273.15 - 32 * 5/9)
      //       = F * 5/9 + 255.3722...
      // So scale = 5/9, offset = 273.15 - 32*5/9 = 255.37222...
      Unit(symbol: '°F', name: 'fahrenheit', dimension: UnitDimension.temperature, scale: 5.0 / 9.0, offset: 459.67 * 5.0 / 9.0),
    ],

    // === Velocity (base: m/s) ============================================
    UnitDimension.velocity: [
      Unit(symbol: 'm/s', name: 'metre per second', dimension: UnitDimension.velocity, scale: 1.0),
      Unit(symbol: 'km/h', name: 'kilometre per hour', dimension: UnitDimension.velocity, scale: 1000.0 / 3600.0),
      Unit(symbol: 'mph', name: 'mile per hour', dimension: UnitDimension.velocity, scale: 1609.344 / 3600.0),
      Unit(symbol: 'ft/s', name: 'foot per second', dimension: UnitDimension.velocity, scale: 0.3048),
      Unit(symbol: 'kn', name: 'knot', dimension: UnitDimension.velocity, scale: 1852.0 / 3600.0),
      Unit(symbol: 'c', name: 'speed of light', dimension: UnitDimension.velocity, scale: 299792458.0),
    ],

    // === Angle (base: radian) ============================================
    UnitDimension.angle: [
      Unit(symbol: 'rad', name: 'radian', dimension: UnitDimension.angle, scale: 1.0),
      // 1 degree = π/180 radians ≈ 0.017453292519943295
      Unit(symbol: '°', name: 'degree', dimension: UnitDimension.angle, scale: 0.017453292519943295),
      // 1 gradian = π/200 radians
      Unit(symbol: 'grad', name: 'gradian', dimension: UnitDimension.angle, scale: 0.015707963267948967),
      // 1 turn = 2π radians
      Unit(symbol: 'turn', name: 'turn', dimension: UnitDimension.angle, scale: 6.283185307179586),
      // 1 arcminute = 1/60 degree
      Unit(symbol: 'arcmin', name: 'arcminute', dimension: UnitDimension.angle, scale: 0.017453292519943295 / 60.0),
      Unit(symbol: 'arcsec', name: 'arcsecond', dimension: UnitDimension.angle, scale: 0.017453292519943295 / 3600.0),
    ],
  };

  static List<Unit> unitsFor(UnitDimension dim) => _byDimension[dim] ?? const [];

  static List<UnitDimension> allDimensions() =>
      UnitDimension.values.toList(growable: false);

  /// Look up a unit by its [symbol]. Returns null if not found.
  /// Used by V2's inline parser; the dialog driver uses [unitsFor].
  static Unit? bySymbol(String symbol) {
    for (final units in _byDimension.values) {
      for (final u in units) {
        if (u.symbol == symbol) return u;
      }
    }
    return null;
  }
}
