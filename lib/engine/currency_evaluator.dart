// lib/engine/currency_evaluator.dart
//
// Notepad V2 Tier C: offline currency conversion.
//
// Bundled exchange rates (USD-based, updated per app release).
// Recognizes `N USD in EUR`, `$150 in GBP`, `100 EUR in JPY`, etc.
// Returns null for non-currency expressions.

class CurrencyEvaluator {
  /// Try to evaluate [input] as a currency conversion.
  /// Returns a formatted result or null.
  static String? tryEvaluate(String input) {
    final trimmed = input.trim();

    // Pattern: <amount> <from> in <to>
    final match = _conversionRe.firstMatch(trimmed);
    if (match == null) return null;

    final amount = double.tryParse(match.group(1)!);
    if (amount == null) return null;

    final fromRaw = match.group(2)!.toUpperCase().trim();
    final toRaw = match.group(3)!.toUpperCase().trim();

    final fromRate = _rates[fromRaw];
    final toRate = _rates[toRaw];
    if (fromRate == null || toRate == null) return null;

    // Convert via USD as the base.
    final usd = amount / fromRate;
    final result = usd * toRate;

    // Format with 2 decimal places for most currencies,
    // 0 for JPY/KRW/VND.
    final decimals = _zeroDecimalCurrencies.contains(toRaw) ? 0 : 2;
    final formatted = result.toStringAsFixed(decimals);
    return '$formatted $toRaw';
  }

  // Pattern: optional $ prefix, number, currency code, "in", currency code.
  static final _conversionRe = RegExp(
    r'^\$?([\d,.]+)\s+([A-Za-z]{3})\s+in\s+([A-Za-z]{3})$',
    caseSensitive: false,
  );

  static const _zeroDecimalCurrencies = {'JPY', 'KRW', 'VND', 'CLP', 'ISK'};

  /// Bundled exchange rates relative to USD = 1.0.
  /// Source: approximate mid-market rates as of 2026-06-01.
  /// Updated per app release — no network calls.
  static const Map<String, double> _rates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'JPY': 157.5,
    'CHF': 0.90,
    'CAD': 1.37,
    'AUD': 1.53,
    'NZD': 1.67,
    'CNY': 7.24,
    'INR': 83.5,
    'BRL': 5.05,
    'MXN': 17.2,
    'KRW': 1330.0,
    'SGD': 1.34,
    'HKD': 7.82,
    'NOK': 10.7,
    'SEK': 10.9,
    'DKK': 6.87,
    'PLN': 4.03,
    'CZK': 23.1,
    'HUF': 362.0,
    'TRY': 32.5,
    'ZAR': 18.6,
    'THB': 35.5,
    'TWD': 31.2,
    'ILS': 3.72,
    'PHP': 56.5,
    'IDR': 15800.0,
    'MYR': 4.72,
    'VND': 25200.0,
    'AED': 3.67,
    'SAR': 3.75,
    'RUB': 92.0,
    'ARS': 875.0,
    'CLP': 920.0,
    'COP': 3950.0,
    'EGP': 30.9,
    'NGN': 1550.0,
    'KES': 155.0,
    'ISK': 137.0,
    'BGN': 1.80,
    'RON': 4.58,
    'HRK': 6.93,
    'UAH': 41.2,
  };

  /// All known currency codes, for autocomplete.
  static Set<String> get knownCodes => _rates.keys.toSet();
}
