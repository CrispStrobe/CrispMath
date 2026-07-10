# OCR LaTeX→Engine Parsing — Handover Prompt

> **Copy everything below the line into a new Claude Code session.**

---

## Task

Fix all remaining gaps in CrispMath's OCR LaTeX→engine syntax conversion pipeline. The pipeline converts LaTeX output from math OCR models (pix2tex, HMER, BTTR) into SymEngine-compatible expressions.

## Repository

`/mnt/akademie_storage/CrispMath` — Flutter app, git repo on `main`.

## Build/test commands

```bash
export PATH="/mnt/storage/flutter/bin:$PATH"
export PUB_CACHE="/tmp/pub-cache-local"
flutter pub get          # first time only
dart analyze             # must show: No issues found!
dart format --output=none --set-exit-if-changed lib/ test/  # must show: 0 changed
flutter test test/ocr_provider_test.dart test/latex_conversion_utils_test.dart  # targeted
flutter test             # full suite, 3513+ tests
```

**CRITICAL**: Always run `dart format` on every file you edit before committing. CI uses Flutter 3.44.0 / Dart 3.12.0 and will reject unformatted code. Commit message must end with `Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>`.

## Architecture

Two files form the pipeline, called in sequence:

### 1. `lib/engine/ocr_provider.dart` — `latexToEngineSyntax(String latex)`

OCR-specific preprocessing (lines 192–370):
- Strips BPE markers (`\u0120`), LaTeX delimiters (`$`, `\[`, `\]`)
- Normalizes spaced braces (`\frac { a } { b }` → `\frac{a}{b}`)
- Strips formatting wrappers (`\mathbf`, `\text`, `\operatorname`, etc.) via `_replaceCmd`
- Strips `\begin{...}` / `\end{...}` environments
- Converts Greek letters (30+ entries)
- **Delegates to `LatexConversionUtils.fromLatex(s)`** for the heavy lifting
- Catch-all: strips remaining `\commands`, converts `{}` → `()`

### 2. `lib/utils/latex_conversion_utils.dart` — `LatexConversionUtils.fromLatex(String latex)`

12-stage converter (lines 15–331):
1. Roots: `\sqrt[n]{expr}` → `(expr)^(1/n)`
2. Fractions: `\frac{a}{b}` → `(a)/(b)` (with d/dx detection)
3. Trig: `\sin{expr}` → `sin(expr)`, `\arcsin` → `asin`
4. Logs: `\log_{base}{expr}` → `log(expr)/log(base)`
5. Integrals: `\int_a^b expr dx` → `integrate(expr, (x, a, b))`
6. Limits: `\lim_{x \to a} expr` → `limit(expr, x, a)`
7. Sums/Products: `\sum_{i=a}^{b} expr` → `Sum(expr, (i, a, b))`
8. Powers/Subscripts: `x^{2y}` → `x^(2y)`
9. Greek letters: `\pi` → `pi`, `\gamma` → `EulerGamma`
10. Operators: `\cdot` → `*`, `\div` → `/`, `\times` → `*`
11. Absolute value: `|x|` → `abs(x)`
12. Sized delimiters: `\left(` → `(`, `\bigg(` → `(`

### Helper: `_extractBraceGroup(String s, int start)` in ocr_provider.dart

Extracts balanced `{...}` content starting at `start`. Returns `(content, endIndex)` or null. Used by `_replaceCmd` for nested brace-balanced stripping.

## Test files

- `test/ocr_provider_test.dart` — `latexToEngineSyntax` tests (16 tests in the group)
- `test/latex_conversion_utils_test.dart` — `fromLatex` tests (50+ tests)

## Gaps to fix (in priority order)

### 1. Comparison operators (HIGH — common in student math)

**Problem**: `\leq`, `\geq`, `\neq`, `\le`, `\ge`, `\ne` are not converted. The catch-all `\command` stripper removes them, losing semantic meaning.

**Fix location**: `lib/utils/latex_conversion_utils.dart` in stage 10 (operators), around line 290.

**Add**:
```dart
s = s.replaceAll(r'\leq', '<=');
s = s.replaceAll(r'\le', '<=');
s = s.replaceAll(r'\geq', '>=');
s = s.replaceAll(r'\ge', '>=');
s = s.replaceAll(r'\neq', '!=');
s = s.replaceAll(r'\ne', '!=');
s = s.replaceAll(r'\approx', '≈');
```

**Tests to add** (in `latex_conversion_utils_test.dart`):
```dart
expect(LatexConversionUtils.fromLatex(r'x \leq 5'), 'x <= 5');
expect(LatexConversionUtils.fromLatex(r'x \geq 0'), 'x >= 0');
expect(LatexConversionUtils.fromLatex(r'x \neq 1'), 'x != 1');
```

**Also update** `test/ocr_provider_test.dart` line 106-109 — the test currently works around this gap; restore proper expectations once fixed.

### 2. Binomial coefficients (HIGH — common in combinatorics/probability)

**Problem**: `\binom{n}{k}` is not handled. Gets stripped by catch-all.

**Fix location**: `lib/utils/latex_conversion_utils.dart` — add a new stage before the operators stage, or in `lib/engine/ocr_provider.dart` using `_replaceCmd` pattern.

**Approach**: Use the `_extractBraceGroup` pattern in `ocr_provider.dart` (before the `fromLatex` call):
```dart
// \binom{n}{k} → binomial(n, k)
while (s.contains(r'\binom{')) {
  final idx = s.indexOf(r'\binom{');
  final n = _extractBraceGroup(s, idx + 6); // after \binom
  if (n == null) break;
  final k = _extractBraceGroup(s, n.$2);
  if (k == null) break;
  s = s.substring(0, idx) + 'binomial(${n.$1}, ${k.$1})' + s.substring(k.$2);
}
```

Or in `fromLatex` using regex:
```dart
s = s.replaceAllMapped(RegExp(r'\\binom\{([^}]+)\}\{([^}]+)\}'),
    (m) => 'binomial(${m[1]}, ${m[2]})');
```

**Note**: SymEngine supports `binomial(n, k)` natively.

**Tests**:
```dart
expect(result, 'binomial(5, 2)');  // for \binom{5}{2}
expect(result, 'binomial(n, k)');  // for \binom{n}{k}
```

### 3. Higher-order derivatives (MEDIUM)

**Problem**: `\frac{d^2}{dx^2}` or `\frac{d^2 f}{dx^2}` not detected. Stage 2 (frac→d/dx detection) only matches when numerator is exactly `d` or `df`.

**Fix location**: `lib/utils/latex_conversion_utils.dart` — the d/dx detection in the fraction handler, around lines 53-80.

**Current regex** (approximately): checks if frac numerator starts with `d` and denominator starts with `d` followed by a variable.

**Needed**: Extend to detect `d^2`, `d^3`, etc. in the numerator and `dx^2`, `dx^3` in the denominator. Map to repeated differentiation:
```
\frac{d^2 f}{dx^2} → diff(diff(f, x), x)
\frac{d^2}{dx^2} f(x) → diff(diff(f(x), x), x)
```

**Tests**:
```dart
// d²y/dx² → diff(diff(y, x), x)
expect(fromLatex(r'\frac{d^2 y}{dx^2}'), contains('diff'));
```

### 4. Limit variants (MEDIUM)

**Problem**: `\lim_{x \to a^+}`, `\lim_{x \to a^-}`, `\lim_{x \to +\infty}` fail.

**Fix location**: `lib/utils/latex_conversion_utils.dart` stage 6 (limits), around line 175.

**Current regex**: `\lim_{(\w+)\s*\\to\s*(\S+)}` — captures single term for "approaches".

**Needed**: Handle `+\infty`, `-\infty`, `a^+`, `a^-`:
```dart
// Normalize limit target before regex:
s = s.replaceAll(r'+\infty', r'\infty');
s = s.replaceAll(r'-\infty', r'-oo');
// After limit extraction, strip ^+ and ^- (directional limits)
// SymEngine limit() supports dir='+' or dir='-' as 4th arg
```

**Tests**:
```dart
expect(fromLatex(r'\lim_{x \to +\infty} f(x)'), contains('oo'));
expect(fromLatex(r'\lim_{x \to 0^+} f(x)'), contains('limit'));
```

### 5. Sum/Product without upper limit (MEDIUM)

**Problem**: `\sum_{i=1}^{n}` works but `\sum_{i}`, `\sum_{i=1}` (no upper), `\sum^{n}` (no lower) fail silently.

**Fix location**: `lib/utils/latex_conversion_utils.dart` stage 7, around line 200.

**Approach**: Add fallback regex for partial limits:
```dart
// \sum_{i=a} expr (no upper) → Sum(expr, (i, a, oo))
// \sum_{i} expr (no range) → Sum(expr, i)
```

### 6. Norms (LOW — less common in OCR output)

**Problem**: `\|x\|` or `||x||` (L2 norm) not handled. Only single `|x|` → `abs(x)`.

**Fix location**: `lib/utils/latex_conversion_utils.dart` stage 11 (absolute value).

**Approach**: Before the `|x|` handler, convert `\|` → `|` and `||x||` → `norm(x)` or just `abs(x)`.

### 7. Set notation (LOW — not evaluable by SymEngine)

**Problem**: `\in`, `\subset`, `\cup`, `\cap` stripped.

**Approach**: Convert to readable text or pass through. Low priority since SymEngine can't evaluate set expressions anyway. Could map `\in` → `in`, `\cup` → `union`, etc. for display purposes.

## Workflow

1. Work on a feature branch: `git checkout -b fix/ocr-parsing-gaps`
2. For each gap:
   a. Add tests first (TDD)
   b. Implement the fix
   c. Run `dart format` on changed files
   d. Run `dart analyze` — must be zero issues
   e. Run targeted tests
   f. Commit with descriptive message
3. After all fixes:
   a. Run full test suite
   b. `git push -u origin fix/ocr-parsing-gaps`
   c. Merge: `git checkout main && git pull --rebase && git merge --ff-only fix/ocr-parsing-gaps && git push`

## Conventions

- Feature branches for non-trivial work, merge ff-only to main
- Never use `/tmp` for large files — use `/mnt/storage` or `/mnt/volume1`
- Localization: if adding new user-visible strings, add to all 4 locales (EN/DE/FR/ES) in `lib/localization/app_localizations.dart`
- The `_extractBraceGroup` helper in `ocr_provider.dart` handles nested braces correctly — prefer it over naive `[^}]+` regex for brace content
- SymEngine function names: `diff`, `integrate`, `limit`, `Sum`, `binomial`, `sin`, `cos`, `exp`, `log`, `abs`

## Current test counts

- `test/latex_conversion_utils_test.dart`: 50+ tests
- `test/ocr_provider_test.dart`: ~20 tests (16 in latexToEngineSyntax group)
- Full suite: 3513+ tests, all green
- CI: all 7 workflows green (CI, Web, iOS, Android, macOS, Linux, Windows)
