// lib/engine/constants_catalog.dart
//
// Curated list of physical, mathematical, and chemistry constants
// with their canonical numeric values. Values follow CODATA 2022
// where applicable, otherwise are exact SI definitions (the speed of
// light, the elementary charge, Avogadro's number, Boltzmann's
// constant, Planck's constant are all defined exactly since the
// 2019 SI redefinition).
//
// Used by ConstantsDialog (Settings → "Constants reference"). The
// dialog inserts the value at the calculator's current cursor so
// "9.81 m/s²" or "1.602176634e-19 C" doesn't have to be retyped.

enum ConstantCategory { mathematical, physical, chemistry, astronomy }

class PhysicalConstant {
  /// Conventional symbol — `c`, `π`, `kB`. Used for display only.
  final String symbol;

  /// Human-readable name shown alongside the symbol.
  final String name;

  /// Numeric value in SI base units. We always store the exact
  /// expansion; the UI does the rendering / unit conversion.
  final double value;

  /// Unit string for display. Empty for pure numbers (π, e, φ).
  final String unit;

  final ConstantCategory category;

  /// One-line note about the constant — what it measures, why it
  /// matters. Optional.
  final String? note;

  const PhysicalConstant({
    required this.symbol,
    required this.name,
    required this.value,
    required this.unit,
    required this.category,
    this.note,
  });
}

class ConstantsCatalog {
  /// All known constants. Order within a category is the order the
  /// dialog shows.
  static const List<PhysicalConstant> all = [
    // === Mathematical (exact / arbitrary precision) ===================
    PhysicalConstant(
      symbol: 'π',
      name: 'pi',
      value: 3.141592653589793,
      unit: '',
      category: ConstantCategory.mathematical,
      note: 'Circumference of a unit-diameter circle.',
    ),
    PhysicalConstant(
      symbol: 'e',
      name: "Euler's number",
      value: 2.718281828459045,
      unit: '',
      category: ConstantCategory.mathematical,
      note: 'Base of the natural logarithm.',
    ),
    PhysicalConstant(
      symbol: 'φ',
      name: 'Golden ratio',
      value: 1.618033988749895,
      unit: '',
      category: ConstantCategory.mathematical,
      note: '(1 + √5) / 2.',
    ),
    PhysicalConstant(
      symbol: 'γ',
      name: 'Euler-Mascheroni constant',
      value: 0.5772156649015329,
      unit: '',
      category: ConstantCategory.mathematical,
      note: 'lim(H_n − ln n) as n → ∞.',
    ),
    PhysicalConstant(
      symbol: 'G_Catalan',
      name: "Catalan's constant",
      value: 0.9159655941772190,
      unit: '',
      category: ConstantCategory.mathematical,
      note: 'Σ (−1)^k / (2k+1)².',
    ),

    // === Physical (CODATA / exact SI) =================================
    PhysicalConstant(
      symbol: 'c',
      name: 'Speed of light in vacuum',
      value: 299792458.0,
      unit: 'm/s',
      category: ConstantCategory.physical,
      note: 'Exact by SI definition since 1983.',
    ),
    PhysicalConstant(
      symbol: 'h',
      name: "Planck's constant",
      value: 6.62607015e-34,
      unit: 'J·s',
      category: ConstantCategory.physical,
      note: 'Exact by 2019 SI redefinition.',
    ),
    PhysicalConstant(
      symbol: 'ℏ',
      name: 'Reduced Planck constant',
      value: 1.054571817e-34,
      unit: 'J·s',
      category: ConstantCategory.physical,
      note: 'h / (2π).',
    ),
    PhysicalConstant(
      symbol: 'G',
      name: 'Gravitational constant',
      value: 6.67430e-11,
      unit: 'N·m²/kg²',
      category: ConstantCategory.physical,
      note: 'CODATA 2022 recommended value.',
    ),
    PhysicalConstant(
      symbol: 'g',
      name: 'Standard gravity',
      value: 9.80665,
      unit: 'm/s²',
      category: ConstantCategory.physical,
      note: 'Defined value for surface gravity, by convention.',
    ),
    PhysicalConstant(
      symbol: 'k_B',
      name: 'Boltzmann constant',
      value: 1.380649e-23,
      unit: 'J/K',
      category: ConstantCategory.physical,
      note: 'Exact by 2019 SI redefinition.',
    ),
    PhysicalConstant(
      symbol: 'e',
      name: 'Elementary charge',
      value: 1.602176634e-19,
      unit: 'C',
      category: ConstantCategory.physical,
      note: 'Exact by 2019 SI redefinition.',
    ),
    PhysicalConstant(
      symbol: 'ε₀',
      name: 'Vacuum permittivity',
      value: 8.8541878128e-12,
      unit: 'F/m',
      category: ConstantCategory.physical,
      note: 'Electric constant.',
    ),
    PhysicalConstant(
      symbol: 'μ₀',
      name: 'Vacuum permeability',
      value: 1.25663706212e-6,
      unit: 'N/A²',
      category: ConstantCategory.physical,
      note: 'Magnetic constant.',
    ),
    PhysicalConstant(
      symbol: 'm_e',
      name: 'Electron mass',
      value: 9.1093837015e-31,
      unit: 'kg',
      category: ConstantCategory.physical,
    ),
    PhysicalConstant(
      symbol: 'm_p',
      name: 'Proton mass',
      value: 1.67262192369e-27,
      unit: 'kg',
      category: ConstantCategory.physical,
    ),
    PhysicalConstant(
      symbol: 'm_n',
      name: 'Neutron mass',
      value: 1.67492749804e-27,
      unit: 'kg',
      category: ConstantCategory.physical,
    ),
    PhysicalConstant(
      symbol: 'σ',
      name: 'Stefan-Boltzmann constant',
      value: 5.670374419e-8,
      unit: 'W/(m²·K⁴)',
      category: ConstantCategory.physical,
    ),
    PhysicalConstant(
      symbol: 'R_∞',
      name: 'Rydberg constant',
      value: 10973731.568160,
      unit: '1/m',
      category: ConstantCategory.physical,
    ),

    // === Chemistry ====================================================
    PhysicalConstant(
      symbol: 'N_A',
      name: 'Avogadro constant',
      value: 6.02214076e23,
      unit: '1/mol',
      category: ConstantCategory.chemistry,
      note: 'Exact by 2019 SI redefinition.',
    ),
    PhysicalConstant(
      symbol: 'R',
      name: 'Gas constant',
      value: 8.314462618,
      unit: 'J/(mol·K)',
      category: ConstantCategory.chemistry,
      note: 'N_A · k_B.',
    ),
    PhysicalConstant(
      symbol: 'F',
      name: 'Faraday constant',
      value: 96485.33212,
      unit: 'C/mol',
      category: ConstantCategory.chemistry,
      note: 'N_A · e.',
    ),
    PhysicalConstant(
      symbol: 'V_m',
      name: 'Molar volume of ideal gas (273.15 K, 100 kPa)',
      value: 0.022711954,
      unit: 'm³/mol',
      category: ConstantCategory.chemistry,
    ),
    PhysicalConstant(
      symbol: 'u',
      name: 'Atomic mass constant',
      value: 1.66053906660e-27,
      unit: 'kg',
      category: ConstantCategory.chemistry,
      note: '1/12 of the mass of a ¹²C atom.',
    ),

    // === Astronomy ====================================================
    PhysicalConstant(
      symbol: 'M_⊙',
      name: 'Solar mass',
      value: 1.98892e30,
      unit: 'kg',
      category: ConstantCategory.astronomy,
    ),
    PhysicalConstant(
      symbol: 'R_⊕',
      name: 'Earth radius (mean)',
      value: 6371000.0,
      unit: 'm',
      category: ConstantCategory.astronomy,
    ),
    PhysicalConstant(
      symbol: 'M_⊕',
      name: 'Earth mass',
      value: 5.9722e24,
      unit: 'kg',
      category: ConstantCategory.astronomy,
    ),
    PhysicalConstant(
      symbol: 'AU',
      name: 'Astronomical unit',
      value: 1.495978707e11,
      unit: 'm',
      category: ConstantCategory.astronomy,
      note: 'Defined exactly since 2012.',
    ),
    PhysicalConstant(
      symbol: 'pc',
      name: 'Parsec',
      value: 3.0856775814913673e16,
      unit: 'm',
      category: ConstantCategory.astronomy,
    ),
    PhysicalConstant(
      symbol: 'ly',
      name: 'Light-year',
      value: 9.4607304725808e15,
      unit: 'm',
      category: ConstantCategory.astronomy,
      note: 'c · (Julian year).',
    ),
  ];

  static List<PhysicalConstant> byCategory(ConstantCategory c) =>
      all.where((k) => k.category == c).toList(growable: false);

  /// Case-insensitive substring match against symbol, name, or unit.
  /// Empty query returns the full list.
  static List<PhysicalConstant> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((k) {
      return k.symbol.toLowerCase().contains(q) ||
          k.name.toLowerCase().contains(q) ||
          k.unit.toLowerCase().contains(q);
    }).toList(growable: false);
  }
}
