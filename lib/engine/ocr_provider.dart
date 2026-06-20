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

import '../utils/latex_conversion_utils.dart';

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

// Pre-compiled RegExp patterns (avoid recompilation per OCR call).
final _reSqrtParen = RegExp(r'√\(([^)]+)\)');
final _reSqrtDigit = RegExp(r'√(\d+)');
final _reDigitODigit = RegExp(r'(?<=\d)O(?=\d)');
final _reWhitespace = RegExp(r'\s+');
final _reDollarDelim = RegExp(r'^\$+|\$+$');
final _reLatexDelim = RegExp(r'^\\[\[\(]|\\[\]\)]$');
final _reSpacedOpen = RegExp(r'\s*\{\s*');
final _reSpacedClose = RegExp(r'\s*\}\s*');
final _reBeginEnv = RegExp(r'\\begin\{[^}]*\}');
final _reEndEnv = RegExp(r'\\end\{[^}]*\}');
final _reInWord = RegExp(r'\\in(?![a-zA-Z])');
final _reBackslashCmd = RegExp(r'\\[a-zA-Z]+');

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
  s = s.replaceAllMapped(_reSqrtParen, (m) => 'sqrt(${m[1]})');
  s = s.replaceAllMapped(_reSqrtDigit, (m) => 'sqrt(${m[1]})');
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
  s = s.replaceAllMapped(_reDigitODigit, (m) => '0');

  // Whitespace cleanup.
  s = s.replaceAll(_reWhitespace, ' ');

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
    if (idx == -1) {
      buf.write(s.substring(i));
      break;
    }
    buf.write(s.substring(i, idx));
    final group = _extractBraceGroup(s, idx + needle.length - 1);
    if (group == null) {
      buf.write(s.substring(idx));
      break;
    }
    // Recursively process inner content for nested \cmd
    final inner = _replaceCmd(group.$1, cmd, transform);
    buf.write(transform(inner));
    i = group.$2;
  }
  return buf.toString();
}

/// Normalize OCR LaTeX output into compact form suitable for
/// [LatexConversionUtils.fromLatex].
///
/// OCR models produce various formats:
///   - pix2tex: BPE tokens with \u0120 markers
///   - BTTR/HMER: space-separated (\frac { a } { b })
/// This normalizes to compact LaTeX (\frac{a}{b}) then applies
/// additional fixes for tokens that fromLatex doesn't handle.
String latexToEngineSyntax(String latex) {
  var s = latex.trim();

  // Strip BPE space markers (pix2tex uses \u0120 / Ġ).
  s = s.replaceAll('\u0120', ' ');

  // Strip LaTeX delimiters.
  s = s.replaceAll(_reDollarDelim, '');
  s = s.replaceAll(_reLatexDelim, '');

  // Normalize spaced braces for LaTeX commands.
  // BTTR/HMER output "\frac { a } { b }", pix2tex outputs "\frac{a}{b}".
  // Collapse spaces around braces so parsing works for both formats.
  s = s.replaceAll(_reSpacedOpen, '{');
  s = s.replaceAll(_reSpacedClose, '}');
  // Restore spaces between tokens that aren't brace-adjacent.
  // "a}+{b" is fine, but "a}b" needs no space (it's inside braces).
  // The main case: "}{" between frac groups must stay collapsed.

  // --- OCR-specific preprocessing (not needed for keypad input) ---

  // Strip formatting wrappers (brace-balanced for nesting)
  for (final cmd in [
    'mathbf',
    'mathrm',
    'mathcal',
    'mathbb',
    'mathit',
    'mathsf',
    'boldsymbol',
    'text',
    'textbf',
    'textit',
    'textrm',
    'operatorname',
    'fbox',
  ]) {
    s = _replaceCmd(s, cmd, (c) => c);
  }

  // Strip environments (array, matrix — not evaluable as 1D expressions)
  s = s.replaceAll(_reBeginEnv, '');
  s = s.replaceAll(_reEndEnv, '');
  s = s.replaceAll('\\\\', ' '); // LaTeX newlines

  // Formatting/spacing → strip
  for (final cmd in [
    'qquad',
    'quad',
    'hspace',
    'vspace',
    'hfill',
    'displaystyle',
    'textstyle',
    'scriptstyle',
    'scriptscriptstyle',
    'nolimits',
    'limits',
    'hline',
    'phantom',
    'hphantom',
    'vphantom',
    'color',
    'textcolor',
    'boxed',
    'cancel',
    'bcancel',
    'xcancel',
    'sp',
  ]) {
    s = s.replaceAll('\\$cmd', '');
  }

  // Decoration → strip
  for (final cmd in [
    'bullet',
    'bigstar',
    'diamond',
    'clubsuit',
    'heartsuit',
    'spadesuit',
    'diamondsuit',
    'triangle',
    'square',
    'blacksquare',
    'checkmark',
    'dagger',
  ]) {
    s = s.replaceAll('\\$cmd', '');
  }

  // Dots (OCR-specific variants)
  s = s.replaceAll(r'\vdots', '...');
  s = s.replaceAll(r'\ddots', '...');

  // Arrows — \rightarrow → \to (so fromLatex can parse limits),
  // all others → ' -> ' display form.
  s = s.replaceAll(r'\rightarrow', r'\to');
  s = s.replaceAll(r'\longrightarrow', r'\to');
  for (final a in [
    'leftarrow',
    'Rightarrow',
    'Leftarrow',
    'leftrightarrow',
    'Leftrightarrow',
    'mapsto',
    'gets',
    'uparrow',
    'downarrow',
    'tharpoondown',
    'rightharpoonup',
  ]) {
    s = s.replaceAll('\\$a', ' -> ');
  }

  // Extra delimiters not in fromLatex
  s = s.replaceAll(r'\lfloor', '(');
  s = s.replaceAll(r'\rfloor', ')');
  s = s.replaceAll(r'\lceil', '(');
  s = s.replaceAll(r'\rceil', ')');
  s = s.replaceAll(r'\langle', '(');
  s = s.replaceAll(r'\rangle', ')');
  s = s.replaceAll(r'\mid', '|');

  // Extra symbols not in fromLatex
  s = s.replaceAll(r'\prime', "'");
  s = s.replaceAll(r'\forall', '');
  s = s.replaceAll(r'\exists', '');
  s = s.replaceAll(r'\notin', ' not in ');
  s = s.replaceAll(_reInWord, ' in ');
  s = s.replaceAll(r'\subset', ' subset ');
  s = s.replaceAll(r'\cup', ' union ');
  s = s.replaceAll(r'\cap', ' intersect ');
  s = s.replaceAll(r'\perp', '_perp');
  s = s.replaceAll(r'\parallel', '_parallel');
  s = s.replaceAll(r'\ell', 'l');
  s = s.replaceAll(r'\hbar', 'hbar');
  s = s.replaceAll(r'\imath', 'i');
  s = s.replaceAll(r'\jmath', 'j');
  s = s.replaceAll(r'\partial', 'd');

  // Extra Greek not in fromLatex
  for (final g in [
    'epsilon',
    'varepsilon',
    'zeta',
    'eta',
    'vartheta',
    'iota',
    'kappa',
    'nu',
    'xi',
    'varpi',
    'varrho',
    'varsigma',
    'tau',
    'upsilon',
    'varphi',
    'chi',
    'psi',
    'Xi',
  ]) {
    s = s.replaceAll('\\$g', g);
  }

  // \binom{n}{k} → binomial(n, k)
  for (;;) {
    final idx = s.indexOf(r'\binom{');
    if (idx == -1) break;
    final n = _extractBraceGroup(s, idx + 6); // after \binom
    if (n == null) break;
    final k = _extractBraceGroup(s, n.$2);
    if (k == null) break;
    s = '${s.substring(0, idx)}binomial(${n.$1}, ${k.$1})${s.substring(k.$2)}';
  }

  // Whitespace cleanup before passing to fromLatex
  s = s.replaceAll(_reWhitespace, ' ').trim();

  // --- Delegate to the comprehensive keypad converter ---
  // fromLatex handles: \frac, \sqrt, \int, \sum, \prod, \lim,
  // derivatives, trig/hyp/log, Greek, operators, |abs|, etc.
  s = LatexConversionUtils.fromLatex(s);

  // --- Catch-all: strip any remaining \commands ---
  s = s.replaceAll(_reBackslashCmd, '');

  // Braces → parens (any remaining after fromLatex)
  s = s.replaceAll('{', '(');
  s = s.replaceAll('}', ')');

  s = s.replaceAll(_reWhitespace, ' ');
  return s.trim();
}
