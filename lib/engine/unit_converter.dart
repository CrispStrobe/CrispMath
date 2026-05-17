// lib/engine/unit_converter.dart
//
// Single-dimension unit conversion. Convert a numeric value from one
// unit to another within the same UnitDimension. Both inputs must be
// finite; cross-dimension conversion is an error (you don't convert
// metres to kilograms).
//
// Pure math, no Flutter dependencies — testable as plain Dart.

import 'unit_catalog.dart';

class ConversionResult {
  final double value;
  final Unit unit;
  final bool ok;
  final String? error;

  const ConversionResult.success(this.value, this.unit)
      : ok = true,
        error = null;

  const ConversionResult.failure(this.error)
      : value = 0.0,
        unit = const Unit(
          symbol: '',
          name: '',
          dimension: UnitDimension.length,
          scale: 1.0,
        ),
        ok = false;
}

class UnitConverter {
  /// Convert [value] from [from] to [to]. Both units must share the
  /// same [UnitDimension]; otherwise the result carries an error.
  /// Returns a finite result with reasonable precision; the renderer
  /// is responsible for formatting trailing zeros.
  static ConversionResult convert(double value, Unit from, Unit to) {
    if (from.dimension != to.dimension) {
      return ConversionResult.failure(
          'Cannot convert ${from.symbol} (${from.dimension.name}) '
          'to ${to.symbol} (${to.dimension.name}): '
          'different dimensions.');
    }
    if (!value.isFinite) {
      return const ConversionResult.failure('Input is not a finite number.');
    }
    final inBase = from.toBase(value);
    final out = to.fromBase(inBase);
    if (!out.isFinite) {
      return const ConversionResult.failure(
          'Conversion produced a non-finite result.');
    }
    return ConversionResult.success(out, to);
  }

  /// Format a result value alongside its unit symbol. Trims trailing
  /// zeros so 5.000 becomes 5 but 5.5 stays 5.5. Uses scientific
  /// notation for very large or very small magnitudes.
  static String format(double value, Unit unit) {
    final abs = value.abs();
    String text;
    if (abs == 0) {
      text = '0';
    } else if (abs >= 1e9 || (abs > 0 && abs < 1e-4)) {
      text = value.toStringAsExponential(6);
    } else {
      // Up to ~10 significant digits, then strip trailing zeros.
      text = value.toStringAsFixed(10);
      // Remove trailing zeros after the decimal point.
      if (text.contains('.')) {
        text = text.replaceAll(RegExp(r'0+$'), '');
        if (text.endsWith('.')) text = text.substring(0, text.length - 1);
      }
    }
    return '$text ${unit.symbol}';
  }
}
