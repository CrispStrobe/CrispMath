// lib/engine/ocr_provider.dart
//
// OCR provider abstraction for math equation recognition.
//
// Three tiers:
//   Tier 1 — On-device text OCR (google_mlkit_text_recognition)
//   Tier 2 — Cloud LLM (Claude/GPT-4o with user-supplied API key)
//   Tier 3 — On-device neural math OCR (pix2tex via CrispEmbed/ggml)
//
// Each tier implements OcrProvider. The active provider is selected
// in Settings; the UI doesn't care which backend runs.

import 'dart:typed_data';

/// Result of an OCR operation.
class OcrResult {
  /// The recognized text / math expression in engine-ready syntax.
  /// For tier 1 (general OCR): raw text, needs post-processing.
  /// For tier 2 (LLM): engine syntax (solve(...), diff(...), etc.).
  /// For tier 3 (pix2tex): LaTeX, needs conversion to engine syntax.
  final String text;

  /// The raw output before any post-processing (e.g. raw LaTeX from
  /// pix2tex, or raw LLM response). Stored for debugging / the audit
  /// log.
  final String rawOutput;

  /// Confidence score (0.0–1.0) when available, null otherwise.
  final double? confidence;

  /// Which provider produced this result.
  final String providerName;

  const OcrResult({
    required this.text,
    required this.rawOutput,
    this.confidence,
    required this.providerName,
  });
}

/// Abstract OCR provider. Each backend implements this.
abstract class OcrProvider {
  /// Human-readable name for Settings UI.
  String get name;

  /// Whether this provider is available on the current platform.
  /// E.g. ML Kit is only available on Android/iOS; CrispEmbed
  /// requires the native library to be loaded.
  bool get isAvailable;

  /// Whether this provider requires a network connection.
  bool get requiresNetwork;

  /// Whether this provider requires an API key.
  bool get requiresApiKey;

  /// Recognize math from an image.
  /// [imageBytes] — the raw image data (JPEG or PNG).
  /// [width], [height] — image dimensions in pixels.
  /// Returns null if recognition fails.
  Future<OcrResult?> recognize(Uint8List imageBytes, int width, int height);
}

/// Registry of available OCR providers. The UI queries this to build
/// the provider picker in Settings.
class OcrProviders {
  static final List<OcrProvider> _providers = [];

  static void register(OcrProvider provider) {
    _providers.add(provider);
  }

  static List<OcrProvider> get all => List.unmodifiable(_providers);

  static List<OcrProvider> get available =>
      _providers.where((p) => p.isAvailable).toList();

  /// The currently selected provider (persisted in AppState).
  static OcrProvider? _active;
  static OcrProvider? get active => _active;
  static set active(OcrProvider? p) => _active = p;
}

/// Post-process raw OCR text into engine-ready syntax.
///
/// Handles common OCR artifacts:
///   - Unicode superscripts → ^ notation (² → ^2, ³ → ^3)
///   - Unicode subscripts → variable suffixes
///   - × → *, ÷ → /, · → *
///   - √ → sqrt()
///   - Common misreads (O vs 0, l vs 1)
String postProcessOcrText(String raw) {
  var s = raw.trim();

  // Unicode superscripts → ^N.
  s = s.replaceAll('²', '^2');
  s = s.replaceAll('³', '^3');
  s = s.replaceAll('⁴', '^4');
  s = s.replaceAll('⁵', '^5');
  s = s.replaceAll('⁶', '^6');
  s = s.replaceAll('⁷', '^7');
  s = s.replaceAll('⁸', '^8');
  s = s.replaceAll('⁹', '^9');
  s = s.replaceAll('⁰', '^0');
  s = s.replaceAll('ⁿ', '^n');

  // Unicode operators.
  s = s.replaceAll('×', '*');
  s = s.replaceAll('÷', '/');
  s = s.replaceAll('·', '*');
  s = s.replaceAll('−', '-'); // minus sign vs hyphen
  s = s.replaceAll('±', '+/-'); // best effort

  // Square root symbol.
  s = s.replaceAllMapped(RegExp(r'√\(([^)]+)\)'), (m) => 'sqrt(${m[1]})');
  s = s.replaceAllMapped(RegExp(r'√(\d+)'), (m) => 'sqrt(${m[1]})');
  s = s.replaceAll('√', 'sqrt');

  // Greek letters commonly found in math.
  s = s.replaceAll('π', 'pi');
  s = s.replaceAll('α', 'alpha');
  s = s.replaceAll('β', 'beta');
  s = s.replaceAll('θ', 'theta');
  s = s.replaceAll('λ', 'lambda');
  s = s.replaceAll('Σ', 'sum');
  s = s.replaceAll('∫', 'integrate');
  s = s.replaceAll('∞', 'oo');

  // Common OCR misreads in math context.
  // Only apply when surrounded by digits/operators (heuristic).
  s = s.replaceAllMapped(
    RegExp(r'(?<=\d)O(?=\d)'),
    (m) => '0',
  );

  // Whitespace cleanup.
  s = s.replaceAll(RegExp(r'\s+'), ' ');

  return s.trim();
}

/// Convert LaTeX (from pix2tex) to CrispCalc engine syntax.
///
/// Handles common LaTeX constructs:
///   \frac{a}{b} → (a)/(b)
///   x^{n}       → x^n  (or x^(n) for multi-char)
///   \sqrt{x}    → sqrt(x)
///   \sin, \cos  → sin, cos
///   \pi         → pi
///   \int        → integrate
///   \lim        → limit
String latexToEngineSyntax(String latex) {
  var s = latex.trim();

  // Strip LaTeX delimiters.
  s = s.replaceAll(RegExp(r'^\$+|\$+$'), '');
  s = s.replaceAll(RegExp(r'^\\[\[\(]|\\[\]\)]$'), '');

  // \frac{a}{b} → (a)/(b).
  s = s.replaceAllMapped(
    RegExp(r'\\frac\{([^}]+)\}\{([^}]+)\}'),
    (m) => '(${m[1]})/(${m[2]})',
  );

  // \sqrt{x} → sqrt(x); \sqrt[n]{x} → x^(1/n).
  s = s.replaceAllMapped(
    RegExp(r'\\sqrt\[(\d+)\]\{([^}]+)\}'),
    (m) => '(${m[2]})^(1/${m[1]})',
  );
  s = s.replaceAllMapped(
    RegExp(r'\\sqrt\{([^}]+)\}'),
    (m) => 'sqrt(${m[1]})',
  );

  // x^{expr} → x^(expr) for multi-char, x^n for single-char.
  s = s.replaceAllMapped(
    RegExp(r'\^{([^}]+)}'),
    (m) {
      final exp = m[1]!;
      return exp.length == 1 ? '^$exp' : '^($exp)';
    },
  );

  // _{expr} → _expr (subscripts, used as variable names).
  s = s.replaceAllMapped(
    RegExp(r'_\{([^}]+)\}'),
    (m) => '_${m[1]}',
  );

  // Named functions: \sin → sin, \cos → cos, etc.
  for (final fn in [
    'sin', 'cos', 'tan', 'arcsin', 'arccos', 'arctan',
    'sinh', 'cosh', 'tanh', 'ln', 'log', 'exp', 'lim',
    'max', 'min', 'det', 'gcd',
  ]) {
    s = s.replaceAll('\\$fn', fn);
  }

  // Special symbols.
  s = s.replaceAll(r'\pi', 'pi');
  s = s.replaceAll(r'\infty', 'oo');
  s = s.replaceAll(r'\int', 'integrate');
  s = s.replaceAll(r'\sum', 'sum');
  s = s.replaceAll(r'\cdot', '*');
  s = s.replaceAll(r'\times', '*');
  s = s.replaceAll(r'\div', '/');
  s = s.replaceAll(r'\pm', '+/-');
  s = s.replaceAll(r'\leq', '<=');
  s = s.replaceAll(r'\geq', '>=');
  s = s.replaceAll(r'\neq', '!=');
  s = s.replaceAll(r'\left', '');
  s = s.replaceAll(r'\right', '');

  // Braces → parens.
  s = s.replaceAll('{', '(');
  s = s.replaceAll('}', ')');

  // Whitespace cleanup.
  s = s.replaceAll(RegExp(r'\s+'), ' ');

  return s.trim();
}
