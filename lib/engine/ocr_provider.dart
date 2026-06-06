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
  static OcrProvider? active;
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

/// Extract a brace-balanced group starting at [start] (must point to '{').
/// Returns the content between the braces and the index after the closing '}'.
(String, int)? _extractBraceGroup(String s, int start) {
  if (start >= s.length || s[start] != '{') return null;
  int depth = 0;
  for (int i = start; i < s.length; i++) {
    if (s[i] == '{') depth++;
    if (s[i] == '}') {
      depth--;
      if (depth == 0) return (s.substring(start + 1, i), i + 1);
    }
  }
  return null; // unmatched
}

/// Replace \cmd{content} → fn(content) with balanced brace matching.
/// Recurses into extracted content to handle nesting.
String _replaceCmd(String s, String cmd, String Function(String) transform) {
  final needle = '\\$cmd{';
  final buf = StringBuffer();
  int i = 0;
  while (i < s.length) {
    final idx = s.indexOf(needle, i);
    if (idx == -1) { buf.write(s.substring(i)); break; }
    buf.write(s.substring(i, idx));
    final group = _extractBraceGroup(s, idx + needle.length - 1);
    if (group == null) { buf.write(s.substring(idx)); break; }
    // Recursively process inner content for nested \cmd
    final inner = _replaceCmd(group.$1, cmd, transform);
    buf.write(transform(inner));
    i = group.$2;
  }
  return buf.toString();
}

/// Replace \frac{a}{b} → (a)/(b), handling nested braces.
String _replaceFrac(String s) {
  final buf = StringBuffer();
  int i = 0;
  while (i < s.length) {
    final fracIdx = s.indexOf(r'\frac{', i);
    if (fracIdx == -1) {
      buf.write(s.substring(i));
      break;
    }
    buf.write(s.substring(i, fracIdx));
    final num = _extractBraceGroup(s, fracIdx + 5);
    if (num == null) {
      buf.write(s.substring(fracIdx));
      break;
    }
    final den = _extractBraceGroup(s, num.$2);
    if (den == null) {
      buf.write(r'\frac{');
      buf.write(num.$1);
      buf.write('}');
      i = num.$2;
      continue;
    }
    // Recursively handle nested \frac in numerator/denominator
    final numContent = _replaceFrac(num.$1);
    final denContent = _replaceFrac(den.$1);
    buf.write('($numContent)/($denContent)');
    i = den.$2;
  }
  return buf.toString();
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

  // Strip BPE space markers (pix2tex uses \u0120 / Ġ).
  s = s.replaceAll('\u0120', ' ');

  // Strip LaTeX delimiters.
  s = s.replaceAll(RegExp(r'^\$+|\$+$'), '');
  s = s.replaceAll(RegExp(r'^\\[\[\(]|\\[\]\)]$'), '');

  // Normalize spaced braces for LaTeX commands.
  // BTTR/HMER output "\frac { a } { b }", pix2tex outputs "\frac{a}{b}".
  // Collapse spaces around braces so parsing works for both formats.
  s = s.replaceAll(RegExp(r'\s*\{\s*'), '{');
  s = s.replaceAll(RegExp(r'\s*\}\s*'), '}');
  // Restore spaces between tokens that aren't brace-adjacent.
  // "a}+{b" is fine, but "a}b" needs no space (it's inside braces).
  // The main case: "}{" between frac groups must stay collapsed.

  // --- Structural commands (brace-balanced matching for nesting) ---

  // \frac{a}{b} → (a)/(b)
  s = _replaceFrac(s);

  // \sqrt{x} → sqrt(x), handles nested braces
  s = _replaceCmd(s, 'sqrt', (c) => 'sqrt($c)');

  // \mathbf{X} → X, \mathrm{X} → X, etc. (formatting → strip)
  for (final cmd in [
    'mathbf', 'mathrm', 'mathcal', 'mathbb', 'mathit', 'mathsf',
    'boldsymbol', 'text', 'textbf', 'textit', 'textrm',
    'operatorname', 'hat', 'bar', 'tilde', 'vec', 'dot', 'ddot',
    'overline', 'underline', 'overbrace', 'underbrace', 'fbox',
  ]) {
    s = _replaceCmd(s, cmd, (c) => c);
  }

  // \sqrt[n]{x} → x^(1/n) — regex ok here since [n] is simple
  s = s.replaceAllMapped(
    RegExp(r'\\sqrt\[(\d+)\]'),
    (m) => '^(1/${m[1]}) * ',  // approximate: nth root
  );

  // x^{expr} → x^(expr) for multi-char, x^n for single-char.
  s = s.replaceAllMapped(
    RegExp(r'\^\{([^}]+)\}'),
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

  // --- Strip environments (array, matrix, etc. — not evaluable) ---
  s = s.replaceAll(RegExp(r'\\begin\{[^}]*\}'), '');
  s = s.replaceAll(RegExp(r'\\end\{[^}]*\}'), '');
  // LaTeX newlines (\\) inside arrays — must use actual double-backslash
  s = s.replaceAll('\\\\', ' ');

  // --- Named functions ---
  for (final fn in [
    'sin', 'cos', 'tan', 'arcsin', 'arccos', 'arctan',
    'sinh', 'cosh', 'tanh', 'ln', 'log', 'exp',
    'lim', 'max', 'min', 'det', 'gcd', 'mod',
  ]) {
    s = s.replaceAll('\\$fn', fn);
  }

  // --- Symbols ---
  // Greek lowercase
  for (final g in [
    'alpha', 'beta', 'gamma', 'delta', 'epsilon', 'varepsilon',
    'zeta', 'eta', 'theta', 'vartheta', 'iota', 'kappa',
    'lambda', 'mu', 'nu', 'xi', 'pi', 'varpi',
    'rho', 'varrho', 'sigma', 'varsigma', 'tau', 'upsilon',
    'phi', 'varphi', 'chi', 'psi', 'omega',
  ]) {
    s = s.replaceAll('\\$g', g);
  }
  // Greek uppercase
  for (final g in [
    'Gamma', 'Delta', 'Theta', 'Lambda', 'Xi', 'Pi',
    'Sigma', 'Upsilon', 'Phi', 'Psi', 'Omega',
  ]) {
    s = s.replaceAll('\\$g', g);
  }

  // Operators and relations
  s = s.replaceAll(r'\cdot', '*');
  s = s.replaceAll(r'\times', '*');
  s = s.replaceAll(r'\div', '/');
  s = s.replaceAll(r'\pm', '+/-');
  s = s.replaceAll(r'\mp', '-/+');
  s = s.replaceAll(r'\leq', '<=');
  s = s.replaceAll(r'\geq', '>=');
  s = s.replaceAll(r'\neq', '!=');
  s = s.replaceAll(r'\approx', '~=');
  s = s.replaceAll(r'\equiv', '==');
  s = s.replaceAll(r'\infty', 'oo');
  s = s.replaceAll(r'\int', 'integrate');
  s = s.replaceAll(r'\sum', 'sum');
  s = s.replaceAll(r'\prod', 'product');
  s = s.replaceAll(r'\partial', 'd');
  s = s.replaceAll(r'\nabla', 'nabla');

  // Delimiters
  s = s.replaceAll(r'\left', '');
  s = s.replaceAll(r'\right', '');
  s = s.replaceAll(r'\lfloor', 'floor(');
  s = s.replaceAll(r'\rfloor', ')');
  s = s.replaceAll(r'\lceil', 'ceil(');
  s = s.replaceAll(r'\rceil', ')');
  s = s.replaceAll(r'\langle', '(');
  s = s.replaceAll(r'\rangle', ')');
  s = s.replaceAll(r'\lvert', 'abs(');
  s = s.replaceAll(r'\rvert', ')');
  s = s.replaceAll(r'\mid', '|');
  s = s.replaceAll(r'\|', '||');

  // Arrows → strip (not evaluable)
  for (final a in [
    'rightarrow', 'leftarrow', 'Rightarrow', 'Leftarrow',
    'leftrightarrow', 'Leftrightarrow', 'longrightarrow',
    'mapsto', 'to', 'gets', 'uparrow', 'downarrow',
    'tharpoondown', 'rightharpoonup',
  ]) {
    s = s.replaceAll('\\$a', '->');
  }

  // Dots
  s = s.replaceAll(r'\ldots', '...');
  s = s.replaceAll(r'\cdots', '...');
  s = s.replaceAll(r'\vdots', '...');
  s = s.replaceAll(r'\ddots', '...');
  s = s.replaceAll(r'\dots', '...');

  // Misc symbols
  s = s.replaceAll(r'\prime', "'");
  s = s.replaceAll(r'\forall', '');
  s = s.replaceAll(r'\exists', '');
  s = s.replaceAll(r'\in', ' in ');
  s = s.replaceAll(r'\notin', ' not in ');
  s = s.replaceAll(r'\subset', ' subset ');
  s = s.replaceAll(r'\cup', ' union ');
  s = s.replaceAll(r'\cap', ' intersect ');
  s = s.replaceAll(r'\emptyset', '{}');
  s = s.replaceAll(r'\perp', '_perp');
  s = s.replaceAll(r'\parallel', '_parallel');
  s = s.replaceAll(r'\circ', '*');
  s = s.replaceAll(r'\star', '*');
  s = s.replaceAll(r'\dagger', '');
  s = s.replaceAll(r'\ell', 'l');
  s = s.replaceAll(r'\hbar', 'hbar');
  s = s.replaceAll(r'\imath', 'i');
  s = s.replaceAll(r'\jmath', 'j');

  // Formatting/spacing → strip
  for (final cmd in [
    'qquad', 'quad', 'hspace', 'vspace', 'hfill',
    'displaystyle', 'textstyle', 'scriptstyle', 'scriptscriptstyle',
    'limits', 'nolimits', 'hline', 'phantom', 'hphantom', 'vphantom',
    'color', 'textcolor', 'boxed', 'cancel', 'bcancel', 'xcancel',
    'sp', // superscript alias
  ]) {
    s = s.replaceAll('\\$cmd', '');
  }

  // Decoration → strip
  for (final cmd in [
    'bullet', 'bigstar', 'star', 'diamond', 'clubsuit',
    'heartsuit', 'spadesuit', 'diamondsuit', 'triangle',
    'square', 'blacksquare', 'checkmark',
  ]) {
    s = s.replaceAll('\\$cmd', '');
  }

  // Catch-all: strip any remaining \command that we missed
  // (better to lose formatting than to crash the engine)
  s = s.replaceAll(RegExp(r'\\[a-zA-Z]+'), '');

  // Braces → parens.
  s = s.replaceAll('{', '(');
  s = s.replaceAll('}', ')');

  // Whitespace cleanup.
  s = s.replaceAll(RegExp(r'\s+'), ' ');

  return s.trim();
}
