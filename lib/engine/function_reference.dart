// lib/engine/function_reference.dart
//
// P6 Function Reference data model + catalogue.
//
// Each entry has:
//
//   - A stable `id` used for i18n keys.
//   - A `category` for filtering.
//   - A canonical `signature` shown in the detail panel (e.g.
//     `solve(equation, variable)`).
//   - A `shortDescription` for the list row (one sentence).
//   - `examples`: 2–3 (input, expected, hint) triples that the
//     dialog can render in the detail panel. The first example's
//     `hint` doubles as the "in CrispMath, X returns Y; the
//     underlying call is SymEngine's / MPFR's / FLINT's Z" prose
//     that PLAN P6 §97 asks for.
//   - `seeAlso`: ids of related FunctionRef entries (for cross-
//     links inside the dialog).
//   - `workedExampleId`: optional id of a `WorkedExample` to
//     cross-link to. Lets the dialog offer "See worked example" on
//     entries that have a paste-ready problem under the same
//     concept. The widget will look this up in
//     `WorkedExamples.all`; an unknown id degrades to no button.
//
// Round 96 shipped the scaffolding + 3 seed entries. Round 97
// fills out CAS (`expand` / `simplify` / `factor` / `diff` /
// `integrate` / `subst` / `limit` / `gcd` / `lcm` / `factorial` /
// `fibonacci`) and grows the precision arc to cover `e(N)`,
// `sqrt(2, N)`, `EulerGamma(N)`, `factorint`, `nextprime`,
// `prevprime`. PLAN names `series` / `taylor` too — those aren't
// in the bridge yet (no SymEngine `series_expansion` binding),
// so they're deferred. Round 98 fills the matrix category:
// `Matrix(...)` literal syntax, `det`, `inv`, `transpose`,
// `rref`, plus a combined matrix-arithmetic entry. Eigenvalues
// and eigenvectors added June 2026 (pure-Dart QR algorithm,
// no bridge binding needed). Round 99 fills the
// statistics / constraints / sudoku categories with 19 module-
// surface entries — these aren't directly callable from the
// calculator (the stats tests live in the Statistics module
// UI; the DSL operators live inside the Constraints module's
// DSL editor; the Sudoku variants are module presets), so they
// carry `runnable: false` which suppresses the Try-in-Calculator
// action on those rows. The See-worked-example cross-link is
// the proper landing — those worked-examples entries dispatch
// `open:<module>` sentinels that the WE dialog already handles.

import 'worked_examples.dart' show WorkedExample;

/// Top-level categories. The values are deliberately broader than
/// the worked-examples categories so they cover both calc-bound
/// functions (cas, numberTheory, precision, matrix) and module
/// surfaces (statistics, constraints, sudoku, graphing, units).
enum FunctionRefCategory {
  cas,
  numberTheory,
  precision,
  matrix,
  graphing,
  statistics,
  constraints,
  sudoku,
  units,
  logic,
}

/// A concrete example for the detail panel. `expected` is the
/// string CrispMath returns; `hint` is a one-line interpretive
/// note.
class FunctionRefExample {
  final String input;
  final String expected;
  final String hint;
  const FunctionRefExample({
    required this.input,
    required this.expected,
    required this.hint,
  });
}

class FunctionRef {
  final String id;
  final FunctionRefCategory category;
  final String signature;
  final String shortDescription;
  final List<FunctionRefExample> examples;
  final List<String> seeAlso;

  /// Optional cross-link to a [WorkedExample] id. Wires the
  /// "See worked example" button on the detail panel.
  final String? workedExampleId;

  /// Whether the first example's `input` is a calculator-runnable
  /// expression. Defaults to true (CAS / number theory / precision /
  /// matrix entries are all callable from the calculator). Set to
  /// false for Round 99 module-surface entries (stats hypothesis
  /// tests live in the Statistics module UI, DSL operators live
  /// inside the Constraints module's DSL editor, Sudoku variants are
  /// module presets) — the dialog hides the "Try in Calculator"
  /// action button when this is false, since pasting `welchT(...)`
  /// into the calculator would just produce an unknown-function
  /// error. The cross-link to a worked example (which dispatches
  /// `open:<module>?...` sentinels) is the proper landing for these.
  final bool runnable;

  /// Optional navigation sentinel (`open:<module>?...` or `dsl:<id>`)
  /// that takes the user straight to the relevant module — pre-filled
  /// where a preset exists. Round 99 follow-up: module-surface entries
  /// (`runnable: false`) previously only offered a two-hop "See worked
  /// example" cross-link; an `openTarget` lets the dialog show a direct
  /// "Open module" button that routes through the shared
  /// `module_navigation` dispatcher. Null leaves the entry with only
  /// its existing buttons.
  final String? openTarget;

  const FunctionRef({
    required this.id,
    required this.category,
    required this.signature,
    required this.shortDescription,
    this.examples = const [],
    this.seeAlso = const [],
    this.workedExampleId,
    this.runnable = true,
    this.openTarget,
  });
}

class FunctionReferences {
  /// V1 catalogue. Rounds 98-99 grow matrix / statistics /
  /// constraints categories — the dialog handles the "empty
  /// category" case so adding entries doesn't require dialog
  /// changes.
  static const List<FunctionRef> all = [
    // === CAS =================================================================
    FunctionRef(
      id: 'solve',
      category: FunctionRefCategory.cas,
      signature: 'solve(equation, variable)',
      shortDescription:
          'Symbolically solve an equation for one variable; returns a list of '
          'solutions.',
      examples: [
        FunctionRefExample(
          input: 'solve(x^2 - 1, x)',
          expected: '[-1, 1]',
          hint: 'In CrispMath, `solve(x^2 - 1, x)` returns a Python-style list '
              'of roots. The underlying call is SymEngine\'s `solve()` (the '
              'rational-root branch for polynomials), wrapped by the bridge '
              'and serialised back to a Dart string.',
        ),
        FunctionRefExample(
          input: 'solve(2*x + 3 = 0, x)',
          expected: '[-3/2]',
          hint: '`=` on the input is accepted as equation syntax — the '
              'preprocessor normalises `lhs = rhs` to `lhs - rhs` before the '
              'bridge call.',
        ),
        FunctionRefExample(
          input: 'solve(x^2 + 1, x)',
          expected: '[-I, I]',
          hint: 'Complex roots come back as SymEngine\'s `I` literal. Mix into '
              'further calls (e.g. `expand((-I)*(I))`) and the bridge keeps '
              'them symbolic.',
        ),
        FunctionRefExample(
          input: 'solve(x^2 - 4 > 0)',
          expected: 'x < -2 ∨ x > 2',
          hint: 'Polynomial INEQUALITIES are solved too: the roots split the '
              'line into intervals and each interval\'s sign decides '
              'membership. Also handles ≤/≥, exact surd endpoints '
              '(x ≤ -sqrt(2) ∨ x ≥ sqrt(2)), and the ≠ / single-point / '
              'ℝ / ∅ cases. Works even without the native engine.',
        ),
      ],
      seeAlso: ['expand', 'factor', 'simplify'],
      workedExampleId: 'quadraticFormula',
    ),
    FunctionRef(
      id: 'expand',
      category: FunctionRefCategory.cas,
      signature: 'expand(expression)',
      shortDescription:
          'Distribute products and powers into a sum-of-monomials form.',
      examples: [
        FunctionRefExample(
          input: 'expand((x + 1)^2)',
          expected: 'x^2 + 2*x + 1',
          hint: 'In CrispMath, `expand((x + 1)^2)` returns the binomial '
              'expansion. The underlying call is SymEngine\'s `expand()`, '
              'which flattens `Pow` and `Mul` nodes and collects like terms.',
        ),
        FunctionRefExample(
          input: 'expand((x + 2)^5)',
          expected: 'x^5 + 10*x^4 + 40*x^3 + 80*x^2 + 80*x + 32',
          hint: 'Coefficients match Pascal\'s triangle row 5: 1, 5, 10, 10, '
              '5, 1, each multiplied by the appropriate power of 2.',
        ),
        FunctionRefExample(
          input: 'expand((a + b)*(a - b))',
          expected: 'a^2 - b^2',
          hint: 'The classic difference-of-squares identity — useful when '
              'pairing with `factor` to cycle between forms.',
        ),
      ],
      seeAlso: ['simplify', 'factor', 'solve'],
      workedExampleId: 'expandBinomial',
    ),
    FunctionRef(
      id: 'simplify',
      category: FunctionRefCategory.cas,
      signature: 'simplify(expression)',
      shortDescription:
          'Combine like terms, cancel common factors, and apply standard '
          'algebraic identities.',
      examples: [
        FunctionRefExample(
          input: 'simplify((x^2 - 4)/(x - 2))',
          expected: 'x + 2',
          hint: 'In CrispMath, `simplify` cancels the common `(x - 2)` factor. '
              'The underlying call is SymEngine\'s `simplify()`, which '
              'tries `rational_simplify` plus a small bag of rewrite rules.',
        ),
        FunctionRefExample(
          input: 'simplify(x*x + 2*x^2)',
          expected: '3*x^2',
          hint: 'Like-term collection on polynomial input — internally this is '
              'just `expand` followed by coefficient merge.',
        ),
        FunctionRefExample(
          input: 'simplify(sin(x)^2 + cos(x)^2)',
          expected: '1',
          hint: 'Pythagorean identity; SymEngine applies the trig rewrite rule '
              'before returning the literal `1`.',
        ),
      ],
      seeAlso: ['expand', 'factor', 'subst'],
      workedExampleId: 'simplifyRational',
    ),
    FunctionRef(
      id: 'factor',
      category: FunctionRefCategory.cas,
      signature: 'factor(expression)',
      shortDescription:
          'Factor a polynomial over the rationals into irreducible pieces.',
      examples: [
        FunctionRefExample(
          input: 'factor(x^2 - 1)',
          expected: '(x - 1)*(x + 1)',
          hint: 'In CrispMath, `factor(x^2 - 1)` returns the difference-of-'
              'squares factorisation. The underlying call is SymEngine\'s '
              '`factor()`, which uses Berlekamp / Cantor–Zassenhaus for '
              'univariate polynomials over Q.',
        ),
        FunctionRefExample(
          input: 'factor(x^3 - 8)',
          expected: '(x - 2)*(x^2 + 2*x + 4)',
          hint: 'Sum/difference-of-cubes identity: one linear factor times an '
              'irreducible quadratic over Q.',
        ),
        FunctionRefExample(
          input: 'factor(x^4 - 1)',
          expected: '(x - 1)*(x + 1)*(x^2 + 1)',
          hint: 'Factoring stops at irreducibility over Q — `x^2 + 1` does '
              'not split further without admitting complex roots.',
        ),
      ],
      seeAlso: ['expand', 'solve', 'gcd'],
      workedExampleId: 'factorCubic',
    ),
    FunctionRef(
      id: 'diff',
      category: FunctionRefCategory.cas,
      signature: 'diff(expression, variable)',
      shortDescription:
          'First-order symbolic derivative with respect to one variable.',
      examples: [
        FunctionRefExample(
          input: 'diff(x^3 - 4*x + 7, x)',
          expected: '3*x^2 - 4',
          hint: 'In CrispMath, `diff(...)` applies the power and constant '
              'rules term-by-term. The underlying call is SymEngine\'s '
              '`diff()`, which walks the expression tree and emits a new '
              'symbolic `Add` node.',
        ),
        FunctionRefExample(
          input: 'diff(sin(x^2), x)',
          expected: '2*x*cos(x^2)',
          hint: 'Chain rule: SymEngine applies `diff(sin(u))/du * du/dx` for '
              'the inner `u = x^2`.',
        ),
        FunctionRefExample(
          input: 'diff(exp(x)*x, x)',
          expected: 'x*exp(x) + exp(x)',
          hint: 'Product rule — note SymEngine keeps the result unfactored. '
              'Pipe through `factor` to collect `exp(x)`.',
        ),
      ],
      seeAlso: ['integrate', 'limit', 'subst'],
      workedExampleId: 'derivPoly',
    ),
    FunctionRef(
      id: 'integrate',
      category: FunctionRefCategory.cas,
      signature: 'integrate(expression, variable[, lower, upper])',
      shortDescription:
          'Indefinite integral (3 args) or definite integral (5 args) with '
          'numeric fallback.',
      examples: [
        FunctionRefExample(
          input: 'integrate(x*sin(x), x)',
          expected: 'sin(x) - x*cos(x)',
          hint: 'In CrispMath, indefinite `integrate(...)` delegates to '
              'SymEngine\'s `integrate()`. Integration by parts is applied '
              'automatically when one factor differentiates to a polynomial.',
        ),
        FunctionRefExample(
          input: 'integrate(x^2, x, 0, 1)',
          expected: '1/3',
          hint:
              'Definite form: when SymEngine has a closed-form antiderivative '
              'it applies the fundamental theorem. If symbolic fails, '
              'CrispMath falls back to Simpson\'s rule (200 panels).',
        ),
        FunctionRefExample(
          input: 'integrate(1/(x^2 - 1), x)',
          expected: '1/2*log(x - 1) - 1/2*log(x + 1)',
          hint: 'Rational functions integrate EXACTLY: partial fractions over '
              'linear + quadratic factors give log / atan terms '
              '(1/(x²+1) → atan(x)), Hermite reduction handles repeated '
              'factors, and Rothstein–Trager covers log-derivative numerators '
              'even over irreducible cubics — ∫(3x²+1)/(x³+x+1) = '
              'log(x³+x+1). All in exact rational arithmetic, on every '
              'platform.',
        ),
      ],
      seeAlso: ['diff', 'limit', 'subst'],
      workedExampleId: 'integralByParts',
    ),
    FunctionRef(
      id: 'subst',
      category: FunctionRefCategory.cas,
      signature: 'subst(expression, variable, value)',
      shortDescription:
          'Substitute `value` for every free occurrence of `variable` in '
          '`expression`. Also exposed as `substitute(...)`.',
      examples: [
        FunctionRefExample(
          input: 'subst(x^2 + 1, x, 2)',
          expected: '5',
          hint: 'In CrispMath, `subst` rewrites the expression tree and then '
              'tries one simplify pass. The underlying call is SymEngine\'s '
              '`xreplace()` (variable-only replacement, not pattern matching).',
        ),
        FunctionRefExample(
          input: 'subst(sin(x), x, pi/2)',
          expected: '1',
          hint: 'Numeric constants `pi`, `e`, and the imaginary unit `I` are '
              'recognised by SymEngine and folded through the trig identity.',
        ),
        FunctionRefExample(
          input: 'subst(a*x + b, x, 10)',
          expected: '10*a + b',
          hint: 'Substitution is symbolic — unrelated free variables `a` and '
              '`b` survive untouched.',
        ),
      ],
      seeAlso: ['solve', 'simplify', 'diff'],
    ),
    FunctionRef(
      id: 'limit',
      category: FunctionRefCategory.cas,
      signature: 'limit(expression, variable, point)',
      shortDescription:
          'Numerical limit as `variable` approaches `point`. `point` may be '
          'a finite value or `oo` / `-oo`.',
      examples: [
        FunctionRefExample(
          input: 'limit(sin(x)/x, x, 0)',
          expected: '1',
          hint:
              'In CrispMath, `limit(...)` is a numerical approach: the bridge '
              'evaluates the expression at a sequence of points converging '
              'on `point` and reports the limit when consecutive samples '
              'agree to the working precision. No symbolic Series.',
        ),
        FunctionRefExample(
          input: 'limit(1/x, x, oo)',
          expected: '0',
          hint: 'The literal `oo` is the SymEngine infinity sentinel — the '
              'preprocessor recognises it before dispatch. Use `-oo` for '
              'negative infinity.',
        ),
        FunctionRefExample(
          input: 'limit((1 + 1/n)^n, n, oo)',
          expected: '2.71828...',
          hint: 'Approaches Euler\'s number. Because the path is numerical, '
              'the result is a float — use `e(N)` for the high-precision '
              'constant instead.',
        ),
      ],
      seeAlso: ['diff', 'integrate', 'e_precision'],
      workedExampleId: 'sinxOverX',
    ),
    FunctionRef(
      id: 'gcd',
      category: FunctionRefCategory.cas,
      signature: 'gcd(a, b)',
      shortDescription:
          'Greatest common divisor of two integers or polynomials.',
      examples: [
        FunctionRefExample(
          input: 'gcd(252, 105)',
          expected: '21',
          hint:
              'In CrispMath, integer `gcd(...)` uses the Euclidean recurrence '
              'gcd(a, b) = gcd(b, a mod b). The underlying call is '
              'SymEngine\'s `gcd()` which dispatches to GMP\'s `mpz_gcd` for '
              'the integer case.',
        ),
        FunctionRefExample(
          input: 'gcd(x^2 - 1, x - 1)',
          expected: 'x - 1',
          hint: 'Polynomial GCD via the subresultant PRS algorithm. Useful as '
              'a prelude to `simplify` for cancellation.',
        ),
        FunctionRefExample(
          input: 'gcd(0, 7)',
          expected: '7',
          hint: 'Convention: `gcd(0, n) = |n|`. Matches the mathematical '
              'definition treating 0 as a multiple of every integer.',
        ),
      ],
      seeAlso: ['lcm', 'factor', 'isprime'],
      workedExampleId: 'gcdEuclid',
    ),
    FunctionRef(
      id: 'lcm',
      category: FunctionRefCategory.cas,
      signature: 'lcm(a, b)',
      shortDescription: 'Least common multiple of two integers or polynomials.',
      examples: [
        FunctionRefExample(
          input: 'lcm(4, 6)',
          expected: '12',
          hint: 'In CrispMath, integer `lcm(...)` is computed via the identity '
              '`lcm(a, b) = |a*b| / gcd(a, b)`. The underlying call is '
              'SymEngine\'s `lcm()` which delegates to GMP\'s `mpz_lcm`.',
        ),
        FunctionRefExample(
          input: 'lcm(12, 18)',
          expected: '36',
          hint: '36 = 2²·3², which is the union of prime-power factors from '
              '12 = 2²·3 and 18 = 2·3².',
        ),
        FunctionRefExample(
          input: 'lcm(x^2 - 1, x + 1)',
          expected: 'x^2 - 1',
          hint: 'Polynomial LCM picks the higher-degree multiple — `x^2 - 1` '
              'already contains `x + 1` as a factor.',
        ),
      ],
      seeAlso: ['gcd', 'factor', 'factorint'],
    ),
    FunctionRef(
      id: 'polygcd',
      category: FunctionRefCategory.cas,
      signature: 'polygcd(p, q)',
      shortDescription:
          'Monic greatest common divisor of two univariate polynomials '
          'over ℚ.',
      examples: [
        FunctionRefExample(
          input: 'polygcd(x^2-1, x^2-2x+1)',
          expected: 'x - 1',
          hint: 'In CrispMath, `polygcd` runs the Euclidean algorithm on '
              'exact rational coefficients (pure Dart). Both polynomials '
              'share the factor `x - 1`; the result is normalised monic.',
        ),
        FunctionRefExample(
          input: 'polygcd(x^2+1, x-1)',
          expected: '1',
          hint: 'Coprime polynomials give the monic constant 1.',
        ),
      ],
      seeAlso: ['polydiv', 'polyresultant', 'polydiscriminant', 'factor'],
    ),
    FunctionRef(
      id: 'polydiv',
      category: FunctionRefCategory.cas,
      signature: 'polydiv(p, q)',
      shortDescription:
          'Polynomial long division of `p ÷ q` over ℚ. Returns the '
          'quotient and remainder.',
      examples: [
        FunctionRefExample(
          input: 'polydiv(x^2-1, x-1)',
          expected: 'x + 1',
          hint: 'Exact division — the remainder is zero. '
              '`x² - 1 = (x + 1)(x - 1)`.',
        ),
        FunctionRefExample(
          input: 'polydiv(x^2+3x+5, x+1)',
          expected: 'x + 2 remainder 3',
          hint: 'Non-exact: `x² + 3x + 5 = (x + 2)(x + 1) + 3`.',
        ),
      ],
      seeAlso: ['polygcd', 'polyresultant', 'polydiscriminant'],
    ),
    FunctionRef(
      id: 'polyresultant',
      category: FunctionRefCategory.cas,
      signature: 'polyresultant(p, q)',
      shortDescription:
          'Resultant Res(p, q) — zero exactly when `p` and `q` share a '
          'non-constant factor.',
      examples: [
        FunctionRefExample(
          input: 'polyresultant(x^2-1, x-1)',
          expected: '0',
          hint: 'Computed as the determinant of the Sylvester matrix. It '
              'vanishes here because both vanish at `x = 1`.',
        ),
        FunctionRefExample(
          input: 'polyresultant(x^2+1, x)',
          expected: '1',
          hint: 'A non-zero resultant certifies that the two polynomials are '
              'coprime over ℚ.',
        ),
      ],
      seeAlso: ['polygcd', 'polydiscriminant'],
    ),
    FunctionRef(
      id: 'polydiscriminant',
      category: FunctionRefCategory.cas,
      signature: 'polydiscriminant(p)',
      shortDescription:
          'Discriminant of a univariate polynomial (degree ≥ 1) — zero '
          'exactly when `p` has a repeated root.',
      examples: [
        FunctionRefExample(
          input: 'polydiscriminant(x^2-5x+6)',
          expected: '1',
          hint: 'For `x² + bx + c` the discriminant is `b² − 4c` — here '
              '25 − 24 = 1. CrispMath uses `(−1)^(n(n−1)/2)·Res(p, p′)/aₙ`.',
        ),
        FunctionRefExample(
          input: 'polydiscriminant(x^2-4x+4)',
          expected: '0',
          hint: '`(x − 2)²` has a double root, so the discriminant is 0.',
        ),
      ],
      seeAlso: ['polyresultant', 'polygcd', 'solve'],
    ),
    FunctionRef(
      id: 'polyfactor',
      category: FunctionRefCategory.cas,
      signature: 'polyfactor(p, mod=k)',
      shortDescription:
          'Factor a univariate polynomial over the finite field 𝔽ₖ '
          '(k prime) into monic irreducibles. For factorisation over ℚ '
          'use `factor`.',
      examples: [
        FunctionRefExample(
          input: 'polyfactor(x^2-1, mod=5)',
          expected: '(x + 1) · (x + 4)',
          hint: 'In CrispMath, `polyfactor` reduces the polynomial mod k, '
              'runs square-free factorisation, then Berlekamp\'s algorithm '
              '(pure Dart). Coefficients display as residues in [0, k), so '
              '`x − 1` appears as `x + 4` mod 5.',
        ),
        FunctionRefExample(
          input: 'polyfactor(x^4+1, mod=2)',
          expected: '(x + 1)^4',
          hint: '`x⁴ + 1` is irreducible over ℚ but is a perfect 4th power '
              'mod 2 — square-free factorisation recovers the multiplicity.',
        ),
        FunctionRefExample(
          input: 'polyfactor(x^3+x+1, mod=2)',
          expected: '(x^3 + x + 1)',
          hint: 'Irreducible over 𝔽₂ — a primitive polynomial used to build '
              'GF(8). A single factor is returned unchanged.',
        ),
      ],
      seeAlso: ['factor', 'polygcd', 'isprime'],
    ),
    // === Special functions (SymEngine + MPFR) ================================
    FunctionRef(
      id: 'gamma',
      category: FunctionRefCategory.cas,
      signature: 'gamma(x)',
      shortDescription: 'The Gamma function Γ(x) — the continuous extension of '
          '(x − 1)! to the reals and complex plane.',
      examples: [
        FunctionRefExample(
          input: 'gamma(5)',
          expected: '24',
          hint: 'For a positive integer n, Γ(n) = (n − 1)!, so Γ(5) = 4! = '
              '24. Evaluated numerically through SymEngine\'s `basic_evalf` '
              '(MPFR).',
        ),
        FunctionRefExample(
          input: 'gamma(0.5)',
          expected: '1.7724538509…',
          hint: 'Γ(½) = √π — the constant behind the Gaussian integral. '
              'Plottable: graph `gamma(x)` to see the poles at the '
              'non-positive integers.',
        ),
      ],
      seeAlso: ['beta', 'factorial', 'zeta'],
    ),
    FunctionRef(
      id: 'zeta',
      category: FunctionRefCategory.cas,
      signature: 'zeta(s)',
      shortDescription:
          'The Riemann zeta function ζ(s) = Σ 1/nˢ and its analytic '
          'continuation.',
      examples: [
        FunctionRefExample(
          input: 'zeta(2)',
          expected: '1.6449340668…',
          hint: 'The Basel problem: ζ(2) = π²/6 ≈ 1.6449. Evaluated '
              'numerically via MPFR.',
        ),
        FunctionRefExample(
          input: 'zeta(4)',
          expected: '1.0823232337…',
          hint: 'ζ(4) = π⁴/90. The even-integer values are all rational '
              'multiples of powers of π.',
        ),
      ],
      seeAlso: ['gamma', 'erf'],
    ),
    FunctionRef(
      id: 'erf',
      category: FunctionRefCategory.cas,
      signature: 'erf(x)',
      shortDescription:
          'The error function erf(x) = (2/√π) ∫₀ˣ e^(−t²) dt — central to '
          'the normal distribution.',
      examples: [
        FunctionRefExample(
          input: 'erf(1)',
          expected: '0.8427007929…',
          hint: 'erf is odd, with erf(0) = 0 and erf(x) → 1 as x → ∞. '
              'Plottable: graph `erf(x)` for the classic sigmoid.',
        ),
        FunctionRefExample(
          input: 'erfc(1)',
          expected: '0.1572992070…',
          hint: 'The complementary error function erfc(x) = 1 − erf(x).',
        ),
      ],
      seeAlso: ['gamma', 'zeta'],
    ),
    FunctionRef(
      id: 'lambertw',
      category: FunctionRefCategory.cas,
      signature: 'lambertw(x)',
      shortDescription: 'The Lambert W function — the inverse of x·eˣ, so '
          'W(x)·e^(W(x)) = x.',
      examples: [
        FunctionRefExample(
          input: 'lambertw(1)',
          expected: '0.5671432904…',
          hint: 'The omega constant Ω, the solution of Ω·e^Ω = 1. Solves '
              'equations of the form x·eˣ = c.',
        ),
        FunctionRefExample(
          input: 'lambertw(0)',
          expected: '0',
          hint: 'W(0) = 0, since 0·e⁰ = 0.',
        ),
      ],
      seeAlso: ['zeta', 'gamma'],
    ),
    FunctionRef(
      id: 'beta',
      category: FunctionRefCategory.cas,
      signature: 'beta(a, b)',
      shortDescription: 'The Beta function B(a, b) = Γ(a)·Γ(b) / Γ(a + b).',
      examples: [
        FunctionRefExample(
          input: 'beta(2, 3)',
          expected: '0.0833333333…',
          hint: 'B(2, 3) = 1!·2!/4! = 2/24 = 1/12. Underlies the Beta '
              'distribution in statistics.',
        ),
        FunctionRefExample(
          input: 'beta(1, 1)',
          expected: '1',
          hint: 'B(1, 1) = Γ(1)²/Γ(2) = 1 — a uniform Beta distribution.',
        ),
      ],
      seeAlso: ['gamma', 'factorial'],
    ),
    FunctionRef(
      id: 'besselj',
      category: FunctionRefCategory.cas,
      signature: 'besselj(n, x)',
      shortDescription:
          'Bessel function of the first kind Jₙ(x) — integer order n, '
          'real x. Plottable.',
      examples: [
        FunctionRefExample(
          input: 'besselj(0, 1)',
          expected: '0.765197686557967',
          hint: 'J₀ at x = 1. The Jₙ solve x²y″ + xy′ + (x² − n²)y = 0 — '
              'vibrating membranes, waveguides. Computed via MPFR\'s '
              '`mpfr_jn`. Plottable: graph `besselj(0, x)` for the damped '
              'oscillation.',
        ),
        FunctionRefExample(
          input: 'besselj(1, 0)',
          expected: '0',
          hint: 'Jₙ(0) = 0 for n ≥ 1, while J₀(0) = 1.',
        ),
      ],
      seeAlso: ['bessely', 'gamma', 'zeta'],
    ),
    FunctionRef(
      id: 'bessely',
      category: FunctionRefCategory.cas,
      signature: 'bessely(n, x)',
      shortDescription:
          'Bessel function of the second kind Yₙ(x) (Weber function) — '
          'integer order n, real x > 0. Plottable.',
      examples: [
        FunctionRefExample(
          input: 'bessely(0, 1)',
          expected: '0.0882569642156770',
          hint: 'The second independent solution of Bessel\'s equation; '
              'Yₙ(x) → −∞ as x → 0⁺. Via MPFR\'s `mpfr_yn`.',
        ),
        FunctionRefExample(
          input: 'bessely(1, 2)',
          expected: '-0.107032431540938',
          hint: 'Plottable: graph `bessely(0, x)` alongside `besselj(0, x)` '
              'for the paired oscillations.',
        ),
      ],
      seeAlso: ['besselj', 'gamma'],
    ),
    FunctionRef(
      id: 'factorial',
      category: FunctionRefCategory.cas,
      signature: 'factorial(n)   or   n!',
      shortDescription:
          'Exact integer factorial. Small `n` uses Dart `BigInt`; large `n` '
          'hands off to SymEngine.',
      examples: [
        FunctionRefExample(
          input: '5!',
          expected: '120',
          hint: 'In CrispMath, the `n!` postfix and `factorial(n)` are '
              'equivalent — the preprocessor rewrites the postfix to the '
              'call. For `n ≤ 1000` we evaluate in Dart with `BigInt` '
              'multiplication; beyond that the underlying call is '
              'SymEngine\'s `factorial()`.',
        ),
        FunctionRefExample(
          input: '100!',
          expected: '9332621544394415268169923885626670049071596826438162146859'
              '2963895217599993229915608941463976156518286253697920827223'
              '758251185210916864000000000000000000000000',
          hint: '158 digits, preserved exactly thanks to the BigInt path — '
              'switching to IEEE-754 here would round to 1.0 × 10^157.',
        ),
        FunctionRefExample(
          input: '0!',
          expected: '1',
          hint: 'Empty-product convention: 0! = 1. Required so that recursion '
              'n! = n · (n-1)! grounds out at 1.',
        ),
      ],
      seeAlso: ['fibonacci', 'gcd', 'isprime'],
      workedExampleId: 'factorial100',
    ),
    FunctionRef(
      id: 'fibonacci',
      category: FunctionRefCategory.cas,
      signature: 'fibonacci(n)   or   fib(n)',
      shortDescription: 'Nth Fibonacci number. `fib(n)` is the short alias.',
      examples: [
        FunctionRefExample(
          input: 'fib(10)',
          expected: '55',
          hint: 'In CrispMath, `fib(n)` and `fibonacci(n)` are the same call. '
              'For `n ≤ 90` we use a precomputed table; for larger `n` the '
              'underlying call is SymEngine\'s `fibonacci()`, which uses '
              'fast-doubling (O(log n) multiplications via GMP).',
        ),
        FunctionRefExample(
          input: 'fib(50)',
          expected: '12586269025',
          hint: 'The 50th Fibonacci number — well beyond the table cap of '
              'small terms but still fits in a 64-bit signed integer.',
        ),
        FunctionRefExample(
          input: 'fib(200)',
          expected: '280571172992510140037611932413038677189525',
          hint: 'Crosses into the GMP-backed path. Fast-doubling avoids the '
              'O(n) linear recurrence, so even fib(10000) is sub-second.',
        ),
      ],
      seeAlso: ['factorial', 'gcd', 'isprime'],
      workedExampleId: 'fibonacci50',
    ),
    FunctionRef(
      id: 'taylor',
      category: FunctionRefCategory.cas,
      signature: 'taylor(f, x, x0, n)   or   series(f, x, n)',
      shortDescription:
          'Taylor/Maclaurin polynomial of f about x0 (default 0), truncated '
          'after n terms (default 6). SymEngine series (FLINT-backed); '
          'works natively and on the web.',
      examples: [
        FunctionRefExample(
          input: 'taylor(sin(x), x, 0, 8)',
          expected: 'x - 1/6*x^3 + 1/120*x^5 - 1/5040*x^7',
          hint: 'Odd powers only — sine is an odd function. The expansion '
              'stops before x^8 (remainder O(x^8)); the coefficients are '
              '(-1)^k/(2k+1)!.',
        ),
        FunctionRefExample(
          input: 'series(exp(x), x, 4)',
          expected: '1 + x + 1/2*x^2 + 1/6*x^3',
          hint: '`series(f, x, n)` is the Maclaurin shorthand — expansion '
              'about 0. The exponential series coefficients are 1/k!.',
        ),
      ],
      seeAlso: ['diff', 'limit', 'simplify'],
    ),
    FunctionRef(
      id: 'linsolve',
      category: FunctionRefCategory.cas,
      signature: 'linsolve(eq1; eq2; …, x, y, …)   or   solvesys(…)',
      shortDescription:
          'Solve a system of linear equations symbolically (exact '
          'rationals/symbols). Equations are ";"-separated, the unknowns '
          'follow. Works natively and on the web.',
      examples: [
        FunctionRefExample(
          input: 'linsolve(x + y = 3; x - y = 1, x, y)',
          expected: 'x = 2, y = 1',
          hint: 'Each equation may be "lhs = rhs" or an expression '
              '(implicitly = 0). Solved exactly via SymEngine\'s '
              'linsolve().',
        ),
        FunctionRefExample(
          input: 'linsolve(2x = 3, x)',
          expected: 'x = 3/2',
          hint: 'Results stay exact rationals — no float rounding. '
              'Non-linear or under-determined systems return an error.',
        ),
      ],
      seeAlso: ['solve', 'expand'],
    ),
    FunctionRef(
      id: 'dsolve',
      category: FunctionRefCategory.cas,
      signature: "dsolve(a*y'' + b*y' + c*y = q(x))",
      shortDescription:
          'Solve an ODE exactly. Second order: linear constant-coefficient '
          '(homogeneous + undetermined coefficients). First order: '
          'separable, linear (integrating factor), Bernoulli, and exact '
          '(M dx + N dy = 0 with the implicit potential F(x, y) = C1).',
      examples: [
        FunctionRefExample(
          input: "dsolve(y'' + 3*y' + 2*y = 0)",
          expected: 'y = C1*exp(-x) + C2*exp(-2*x)',
          hint: 'Characteristic equation r^2 + 3r + 2 = 0 with roots '
              '-1 and -2; each root contributes one exponential mode. '
              'Complex pairs give exp*(cos + sin), double roots '
              '(C1 + C2*x)*exp.',
        ),
        FunctionRefExample(
          input: "dsolve(y' + y = x^2)",
          expected: 'y = C1*exp(-x) + x^2 - 2*x + 2',
          hint: 'Homogeneous solution plus a particular polynomial found '
              'by undetermined coefficients — all in exact rational '
              'arithmetic, so no floating-point drift in the '
              'coefficients.',
        ),
      ],
      seeAlso: ['solve', 'integrate', 'diff'],
    ),
    // === Number theory =======================================================
    FunctionRef(
      id: 'isprime',
      category: FunctionRefCategory.numberTheory,
      signature: 'isprime(n)',
      shortDescription: 'Probabilistic primality test on integers.',
      examples: [
        FunctionRefExample(
          input: 'isprime(2027)',
          expected: 'true',
          hint: 'In CrispMath, `isprime(n)` returns a boolean chip. The '
              'underlying call is GMP\'s `mpz_probab_prime_p` (25 Miller-'
              'Rabin rounds, error bound 4^-25 ≈ 9×10^-16) via SymEngine\'s '
              '`ntheory` module. 2027 is the 308th prime.',
        ),
        FunctionRefExample(
          input: 'isprime(2024)',
          expected: 'false',
          hint: '2024 = 2³·11·23.',
        ),
        FunctionRefExample(
          input: 'isprime(2^61 - 1)',
          expected: 'true',
          hint: 'The ninth Mersenne prime, M61. Miller-Rabin still settles in '
              'microseconds at this size — the cost is in the modular '
              'exponentiations, not the bit-length.',
        ),
      ],
      seeAlso: ['nextprime', 'prevprime', 'factorint'],
      workedExampleId: 'isprime',
    ),
    FunctionRef(
      id: 'nextprime',
      category: FunctionRefCategory.numberTheory,
      signature: 'nextprime(n)',
      shortDescription: 'Smallest prime strictly greater than `n`.',
      examples: [
        FunctionRefExample(
          input: 'nextprime(1000)',
          expected: '1009',
          hint: 'In CrispMath, `nextprime(n)` iterates from `n+1` and tests '
              'each candidate. The underlying call is SymEngine\'s '
              '`ntheory::nextprime()`, which uses FLINT\'s sieve over short '
              'windows when the gap is large.',
        ),
        FunctionRefExample(
          input: 'nextprime(2)',
          expected: '3',
          hint: 'Strictly greater — `nextprime(p)` is never `p` itself, even '
              'when `p` is prime.',
        ),
      ],
      seeAlso: ['isprime', 'prevprime', 'factorint'],
      workedExampleId: 'nextprime1000',
    ),
    FunctionRef(
      id: 'prevprime',
      category: FunctionRefCategory.numberTheory,
      signature: 'prevprime(n)',
      shortDescription:
          'Largest prime strictly less than `n`. Errors if no such prime '
          'exists (e.g. `prevprime(2)`).',
      examples: [
        FunctionRefExample(
          input: 'prevprime(100)',
          expected: '97',
          hint: 'In CrispMath, `prevprime(n)` walks downward from `n-1`. The '
              'underlying call is SymEngine\'s `ntheory::prevprime()`.',
        ),
        FunctionRefExample(
          input: 'prevprime(2)',
          expected: 'Error: no prime less than 2',
          hint: 'No primes exist below 2; the bridge raises rather than '
              'returning a sentinel. CrispMath surfaces the error chip.',
        ),
      ],
      seeAlso: ['isprime', 'nextprime', 'factorint'],
    ),
    FunctionRef(
      id: 'factorint',
      category: FunctionRefCategory.numberTheory,
      signature: 'factorint(n)',
      shortDescription:
          'Prime factorisation as `p₁^e₁ · p₂^e₂ · …` with Unicode '
          'superscript exponents.',
      examples: [
        FunctionRefExample(
          input: 'factorint(360)',
          expected: '2³ · 3² · 5',
          hint: 'In CrispMath, `factorint(n)` returns a rendered prime '
              'decomposition. The underlying call is FLINT\'s '
              '`fmpz_factor`, fronted by SymEngine\'s ntheory wrapper; '
              'CrispMath converts the (prime, exponent) list into the '
              'Unicode superscript display.',
        ),
        FunctionRefExample(
          input: 'factorint(2147483647)',
          expected: '2147483647',
          hint: 'The 8th Mersenne prime, M31. A single factor (itself) — '
              '`factorint` short-circuits when the input is prime.',
        ),
        FunctionRefExample(
          input: 'factorint(1)',
          expected: '1',
          hint: 'Edge case: by convention 1 has the empty factorisation; '
              'CrispMath renders this as the literal `1` rather than an '
              'empty string.',
        ),
      ],
      seeAlso: ['isprime', 'nextprime', 'gcd'],
      workedExampleId: 'factorint360',
    ),
    FunctionRef(
      id: 'divisors',
      category: FunctionRefCategory.numberTheory,
      signature: 'divisors(n)',
      shortDescription: 'All positive divisors of `n`, sorted ascending and '
          'comma-separated.',
      examples: [
        FunctionRefExample(
          input: 'divisors(12)',
          expected: '1, 2, 3, 4, 6, 12',
          hint: 'In CrispMath, `divisors(n)` is derived in pure Dart from '
              '`factorint(n)`: every product of prime powers pᵏ with '
              '0 ≤ k ≤ exponent. The count equals ∏(eᵢ + 1) — here '
              '(2+1)(1+1) = 6.',
        ),
        FunctionRefExample(
          input: 'divisors(28)',
          expected: '1, 2, 4, 7, 14, 28',
          hint: '28 is a perfect number: its proper divisors (all but 28 '
              'itself) sum to 28.',
        ),
      ],
      seeAlso: ['factorint', 'totient', 'gcd'],
      workedExampleId: 'divisors12',
    ),
    FunctionRef(
      id: 'totient',
      category: FunctionRefCategory.numberTheory,
      signature: 'totient(n)',
      shortDescription:
          "Euler's totient φ(n): the count of integers in 1..n that are "
          'coprime to `n`.',
      examples: [
        FunctionRefExample(
          input: 'totient(12)',
          expected: '4',
          hint: 'The four units modulo 12 are {1, 5, 7, 11}. CrispMath '
              "computes φ from the prime factorisation via FLINT's "
              '`fmpz_euler_phi`.',
        ),
        FunctionRefExample(
          input: 'totient(97)',
          expected: '96',
          hint: 'For a prime p, φ(p) = p − 1, since every smaller positive '
              'integer is coprime to p.',
        ),
      ],
      seeAlso: ['factorint', 'modinv', 'divisors'],
      workedExampleId: 'eulerTotient',
    ),
    FunctionRef(
      id: 'modpow',
      category: FunctionRefCategory.numberTheory,
      signature: 'modpow(a, e, m)',
      shortDescription:
          'Modular exponentiation `aᵉ mod m`. A negative exponent uses the '
          'modular inverse of `a` (when it exists).',
      examples: [
        FunctionRefExample(
          input: 'modpow(2, 100, 1000000007)',
          expected: '976371285',
          hint: "Square-and-multiply via GMP's `mpz_powm` — the workhorse "
              'behind modular arithmetic and (textbook) RSA / '
              'Diffie–Hellman. Never forms the gigantic `2¹⁰⁰` directly.',
        ),
        FunctionRefExample(
          input: 'modpow(3, -1, 11)',
          expected: '4',
          hint: 'A negative exponent inverts the base first, so '
              '`modpow(a, -1, m)` equals `modinv(a, m)` — here 3⁻¹ ≡ 4 '
              '(mod 11). Errors when gcd(a, m) ≠ 1.',
        ),
      ],
      seeAlso: ['modinv', 'totient', 'gcd'],
      workedExampleId: 'modpowCrypto',
    ),
    FunctionRef(
      id: 'modinv',
      category: FunctionRefCategory.numberTheory,
      signature: 'modinv(a, m)',
      shortDescription:
          'Modular inverse `a⁻¹ mod m` via the extended Euclidean '
          'algorithm. Errors when `gcd(a, m) ≠ 1`.',
      examples: [
        FunctionRefExample(
          input: 'modinv(3, 11)',
          expected: '4',
          hint: 'The unique x in [0, m) with a·x ≡ 1 (mod m), via GMP\'s '
              '`mpz_invert`. Check: 3·4 = 12 ≡ 1 (mod 11).',
        ),
        FunctionRefExample(
          input: 'modinv(2, 4)',
          expected: 'Error: no inverse: gcd(a, m) != 1',
          hint: 'Only units modulo m are invertible. gcd(2, 4) = 2 ≠ 1, so '
              'no inverse exists.',
        ),
      ],
      seeAlso: ['modpow', 'gcd', 'totient'],
    ),
    FunctionRef(
      id: 'jacobi',
      category: FunctionRefCategory.numberTheory,
      signature: 'jacobi(a, n)',
      shortDescription:
          'Jacobi symbol (a/n) ∈ {−1, 0, 1} for odd positive `n`; '
          'generalises the Legendre symbol.',
      examples: [
        FunctionRefExample(
          input: 'jacobi(2, 7)',
          expected: '1',
          hint: 'For prime n the Jacobi symbol equals the Legendre symbol — '
              'here 2 is a quadratic residue mod 7 (since 3² ≡ 2). Via '
              "GMP's `mpz_jacobi`.",
        ),
        FunctionRefExample(
          input: 'jacobi(6, 9)',
          expected: '0',
          hint: 'The symbol is 0 exactly when gcd(a, n) ≠ 1; here '
              'gcd(6, 9) = 3.',
        ),
      ],
      seeAlso: ['isprime', 'modpow', 'gcd'],
    ),
    FunctionRef(
      id: 'cfrac',
      category: FunctionRefCategory.numberTheory,
      signature: 'cfrac(x, n)',
      shortDescription:
          'Continued-fraction expansion `[a₀; a₁, …]` of `x` to `n` terms. '
          '`x` may be `pi` / `e` / `EulerGamma` / `sqrt(2)`, a rational '
          '`p/q`, or a decimal.',
      examples: [
        FunctionRefExample(
          input: 'cfrac(pi, 10)',
          expected: '[3; 7, 15, 1, 292, 1, 1, 1, 2, 1]',
          hint: 'In CrispMath, `cfrac` runs an exact BigInt expansion over a '
              'high-precision MPFR approximation of the constant. The large '
              'term 292 is precisely why the convergent 355/113 is such a '
              'remarkable approximation of π.',
        ),
        FunctionRefExample(
          input: 'cfrac(415/93, 4)',
          expected: '[4; 2, 6, 7]',
          hint: 'For an exact rational the expansion is finite — this is just '
              "Euclid's algorithm recording its quotients.",
        ),
      ],
      seeAlso: ['convergent', 'pi_precision', 'gcd'],
      workedExampleId: 'contFracPi',
    ),
    FunctionRef(
      id: 'convergent',
      category: FunctionRefCategory.numberTheory,
      signature: 'convergent(x, k)',
      shortDescription:
          'The k-th convergent `p/q` of `x`’s continued fraction — a '
          'best rational approximation for its denominator size.',
      examples: [
        FunctionRefExample(
          input: 'convergent(pi, 3)',
          expected: '355/113',
          hint: 'Milü — Zu Chongzhi’s 5th-century approximation of π, correct '
              'to six decimal places. CrispMath folds the first k+1 partial '
              'quotients of `cfrac` into the rational.',
        ),
        FunctionRefExample(
          input: 'convergent(pi, 1)',
          expected: '22/7',
          hint: 'The schoolbook approximation of π; `convergent(x, 0)` is the '
              'integer part ⌊x⌋.',
        ),
      ],
      seeAlso: ['cfrac', 'pi_precision'],
    ),
    // === Precision arc =======================================================
    FunctionRef(
      id: 'pi_precision',
      category: FunctionRefCategory.precision,
      signature: 'pi(N)',
      shortDescription:
          'π to N decimal digits via MPFR; returns the literal digit string.',
      examples: [
        FunctionRefExample(
          input: 'pi(50)',
          expected: '3.14159265358979323846264338327950288419716939937510',
          hint: 'In CrispMath, `pi(N)` is a special-cased call routed to the '
              'high-precision path before SymEngine sees it. The underlying '
              'call is MPFR\'s `mpfr_const_pi` at precision ⌈N·log2(10)⌉ + '
              '16 guard bits, followed by base-10 conversion.',
        ),
        FunctionRefExample(
          input: 'pi(100)',
          expected: '3.14159265358979323846264338327950288419716939937510'
              '58209749445923078164062862089986280348253421170679',
          hint: 'At N = 100 the working precision is ≈ 348 bits. The guard '
              'bits prevent base conversion from showing rounded trailing '
              'digits.',
        ),
      ],
      seeAlso: ['e_precision', 'sqrt_precision', 'eulergamma_precision'],
      workedExampleId: 'piPrecision',
    ),
    FunctionRef(
      id: 'e_precision',
      category: FunctionRefCategory.precision,
      signature: 'e(N)',
      shortDescription: 'Euler\'s number e to N decimal digits via MPFR.',
      examples: [
        FunctionRefExample(
          input: 'e(50)',
          expected: '2.71828182845904523536028747135266249775724709369995',
          hint: 'In CrispMath, `e(N)` mirrors the `pi(N)` pipeline: MPFR\'s '
              '`mpfr_const_e` (which uses the Taylor series Σ 1/k!) at '
              'precision ⌈N·log2(10)⌉ + 16 guard bits, then base-10 '
              'rendering.',
        ),
        FunctionRefExample(
          input: 'e(20)',
          expected: '2.71828182845904523536',
          hint: 'Short enough to memorise — useful as a quick precision '
              'sanity check against `limit((1 + 1/n)^n, n, oo)`.',
        ),
      ],
      seeAlso: ['pi_precision', 'sqrt_precision', 'limit'],
      workedExampleId: 'ePrecision',
    ),
    FunctionRef(
      id: 'sqrt_precision',
      category: FunctionRefCategory.precision,
      signature: 'sqrt(k, N)',
      shortDescription:
          'Square root of integer `k` to N decimal digits via MPFR. The '
          '2-argument form picks the high-precision path.',
      examples: [
        FunctionRefExample(
          input: 'sqrt(2, 50)',
          expected: '1.41421356237309504880168872420969807856967187537694',
          hint: 'In CrispMath, the 2-argument `sqrt(k, N)` is the high-'
              'precision route. The underlying call is MPFR\'s '
              '`mpfr_sqrt_ui` at precision ⌈N·log2(10)⌉ + 16 guard bits. '
              'The 1-argument `sqrt(2)` instead returns the symbolic '
              '`sqrt(2)` via SymEngine.',
        ),
        FunctionRefExample(
          input: 'sqrt(3, 30)',
          expected: '1.73205080756887729352744634150',
          hint: 'Useful for verification — `sqrt(3, N)` should agree with '
              '`pi_precision` digits derived independently.',
        ),
      ],
      seeAlso: ['pi_precision', 'e_precision', 'simplify'],
    ),
    FunctionRef(
      id: 'eulergamma_precision',
      category: FunctionRefCategory.precision,
      signature: 'EulerGamma(N)',
      shortDescription:
          'Euler–Mascheroni constant γ ≈ 0.5772… to N decimal digits via '
          'MPFR.',
      examples: [
        FunctionRefExample(
          input: 'EulerGamma(20)',
          expected: '0.57721566490153286061',
          hint:
              'In CrispMath, `EulerGamma(N)` uses MPFR\'s `mpfr_const_euler`, '
              'which evaluates γ via the Brent–McMillan formula '
              '(modified Bessel functions). Precision is ⌈N·log2(10)⌉ + 16 '
              'guard bits, matching the `pi(N)` and `e(N)` pipeline.',
        ),
        FunctionRefExample(
          input: 'EulerGamma(50)',
          expected: '0.57721566490153286060651209008240243104215933593992',
          hint: 'γ has no known closed form. The MPFR routine is the '
              'standard reference implementation; CrispMath just renders '
              'the digit string.',
        ),
      ],
      seeAlso: ['pi_precision', 'e_precision', 'sqrt_precision'],
    ),
    FunctionRef(
      id: 'evalf',
      category: FunctionRefCategory.precision,
      signature: 'evalf(expr, N)',
      shortDescription:
          'Evaluate any real expression to N decimal digits via MPFR — '
          'arbitrary-precision numeric value of `expr`.',
      examples: [
        FunctionRefExample(
          input: 'evalf(ln(10), 50)',
          expected: '2.3025850929940456840179914546843642076011014886288',
          hint: 'In CrispMath, `evalf` parses any expression and routes it '
              'through SymEngine\'s `basic_evalf` at ⌈N·log2(10)⌉ + 8 bits. '
              'The generic counterpart to `pi(N)` / `e(N)` — works on '
              'logs, roots, sums, and the special functions.',
        ),
        FunctionRefExample(
          input: 'evalf(zeta(2), 30)',
          expected: '1.64493406684822643647241516665',
          hint: 'Combine with special functions for high-precision values: '
              'ζ(2) = π²/6. Non-real results are rejected (high-precision '
              'complex is a separate path).',
        ),
      ],
      seeAlso: ['pi_precision', 'zeta', 'gamma'],
    ),
    FunctionRef(
      id: 'cevalf',
      category: FunctionRefCategory.precision,
      signature: 'cevalf(expr, N)',
      shortDescription:
          'Complex arbitrary-precision evaluation — like `evalf` but '
          'keeps the imaginary part, returning `a + b·I` to N digits via '
          'MPC.',
      examples: [
        FunctionRefExample(
          input: 'cevalf((1+I)^10, 20)',
          expected: '32.0*I',
          hint: 'In CrispMath, `cevalf` routes through SymEngine\'s '
              '`basic_evalf` on the MPC (complex) path. (1+i)¹⁰ = 32i. Use '
              'the literal `I` for the imaginary unit.',
        ),
        FunctionRefExample(
          input: 'cevalf(sqrt(-2), 30)',
          expected: '1.41421356…*I',
          hint: '√(−2) = i·√2. Where `evalf` rejects a non-real result, '
              '`cevalf` returns the full complex value.',
        ),
      ],
      seeAlso: ['evalf', 'pi_precision'],
    ),
    // === Matrix / linear algebra =============================================
    FunctionRef(
      id: 'matrix_literal',
      category: FunctionRefCategory.matrix,
      signature: 'Matrix([[a, b, ...], [c, d, ...], ...])',
      shortDescription:
          'Matrix literal: a list of rows, each row a list of cell '
          'expressions. Cells can be numbers, fractions, or symbolic.',
      examples: [
        FunctionRefExample(
          input: 'Matrix([[1, 2], [3, 4]])',
          expected: 'Matrix([[1, 2], [3, 4]])',
          hint: 'In CrispMath, the `Matrix(...)` literal is recognised by the '
              'matrix evaluator before the engine sees the expression. The '
              'underlying call is SymEngine\'s `DenseMatrix` constructor — '
              'the row/col layout is fixed at construction.',
        ),
        FunctionRefExample(
          input: 'Matrix([[1/2, 0], [0, 1/3]])',
          expected: 'Matrix([[1/2, 0], [0, 1/3]])',
          hint: 'Cells stay symbolic — rationals don\'t collapse to floats. '
              'Same goes for free symbols: `Matrix([[a, b], [c, d]])` is '
              'accepted and propagated through `det` / `inv` / `rref`.',
        ),
        FunctionRefExample(
          input: 'Matrix([[1, 2, 3], [4, 5, 6]])',
          expected: 'Matrix([[1, 2, 3], [4, 5, 6]])',
          hint: 'Non-square matrices are fine for `transpose` and `rref` but '
              'will fail for `det` / `inv`, which require square input.',
        ),
      ],
      seeAlso: ['det', 'inv', 'transpose', 'rref', 'eigenvalues'],
    ),
    FunctionRef(
      id: 'det',
      category: FunctionRefCategory.matrix,
      signature: 'det(Matrix(...))',
      shortDescription:
          'Determinant of a square matrix. Returns a symbolic scalar.',
      examples: [
        FunctionRefExample(
          input: 'det(Matrix([[1, 2], [3, 4]]))',
          expected: '-2',
          hint: 'In CrispMath, `det(M)` evaluates as a single scalar. The '
              'underlying call is SymEngine\'s `DenseMatrix::det()`, which '
              'uses the Bareiss fraction-free algorithm — exact for '
              'symbolic / rational entries, no float blow-up.',
        ),
        FunctionRefExample(
          input: 'det(Matrix([[1, 2, 3], [0, 1, 4], [5, 6, 0]]))',
          expected: '1',
          hint: 'Classic 3×3 textbook example — Laplace cofactor expansion '
              'gives the same answer in 6 terms.',
        ),
        FunctionRefExample(
          input: 'det(Matrix([[a, b], [c, d]]))',
          expected: 'a*d - b*c',
          hint: 'Symbolic entries pass through unchanged. Bareiss keeps the '
              'result as a SymEngine `Add` rather than a float.',
        ),
      ],
      seeAlso: ['inv', 'transpose', 'rref', 'matrix_literal'],
      workedExampleId: 'matrixDet',
    ),
    FunctionRef(
      id: 'inv',
      category: FunctionRefCategory.matrix,
      signature: 'inv(Matrix(...))',
      shortDescription:
          'Inverse of a square non-singular matrix. Errors when `det = 0`.',
      examples: [
        FunctionRefExample(
          input: 'inv(Matrix([[4, 7], [2, 6]]))',
          expected: 'Matrix([[3/5, -7/10], [-1/5, 2/5]])',
          hint: 'In CrispMath, `inv(M)` returns `adj(M)/det(M)`. The '
              'underlying call is SymEngine\'s `DenseMatrix::inv()`, which '
              'uses Gauss–Jordan elimination over the rationals — entries '
              'come back as exact fractions, not floats.',
        ),
        FunctionRefExample(
          input: 'inv(Matrix([[1, 0], [0, 1]]))',
          expected: 'Matrix([[1, 0], [0, 1]])',
          hint: 'Identity matrix is self-inverse — a quick smoke test that '
              'the bridge round-trips correctly.',
        ),
        FunctionRefExample(
          input: 'inv(Matrix([[1, 2], [2, 4]]))',
          expected: 'Error: inv failed: singular matrix',
          hint: 'Singular input (det = 0) errors out cleanly rather than '
              'returning bogus large numbers. The error chip surfaces in '
              'the calculator history.',
        ),
      ],
      seeAlso: ['det', 'rref', 'transpose', 'matrix_literal'],
      workedExampleId: 'matrixInverse',
    ),
    FunctionRef(
      id: 'transpose',
      category: FunctionRefCategory.matrix,
      signature: 'transpose(Matrix(...))',
      shortDescription:
          'Transpose: swap rows and columns. Works on rectangular matrices.',
      examples: [
        FunctionRefExample(
          input: 'transpose(Matrix([[1, 2], [3, 4]]))',
          expected: 'Matrix([[1, 3], [2, 4]])',
          hint: 'In CrispMath, `transpose(M)` is implemented Dart-side because '
              'the bridge doesn\'t expose a transpose entry point. We '
              'allocate a fresh `SymEngineMatrix` with swapped dimensions '
              'and copy cells element-by-element.',
        ),
        FunctionRefExample(
          input: 'transpose(Matrix([[1, 2, 3], [4, 5, 6]]))',
          expected: 'Matrix([[1, 4], [2, 5], [3, 6]])',
          hint: 'Rectangular input: a 2×3 becomes a 3×2 — useful for paired '
              'sample data layouts.',
        ),
        FunctionRefExample(
          input: 'transpose(transpose(Matrix([[1, 2], [3, 4]])))',
          expected: 'Matrix([[1, 2], [3, 4]])',
          hint: 'Idempotent under two applications. Verifies the cell-swap '
              'preserves the symbolic content untouched.',
        ),
      ],
      seeAlso: ['det', 'inv', 'rref', 'matrix_literal'],
    ),
    FunctionRef(
      id: 'rref',
      category: FunctionRefCategory.matrix,
      signature: 'rref(Matrix(...))',
      shortDescription:
          'Reduced row echelon form via Gauss–Jordan elimination. Works '
          'over symbolic / rational entries.',
      examples: [
        FunctionRefExample(
          input: 'rref(Matrix([[1, 2, 5], [3, 4, 11]]))',
          expected: 'Matrix([[1, 0, -1], [0, 1, 3]])',
          hint: 'In CrispMath, `rref` runs Gauss–Jordan in Dart and calls '
              'SymEngine\'s `simplify()` per cell update. The bridge '
              'doesn\'t expose `rref` directly, so the algorithm walks '
              'columns left-to-right, scales the pivot row, then '
              'eliminates the column above and below.',
        ),
        FunctionRefExample(
          input: 'rref(Matrix([[1, 2], [2, 4]]))',
          expected: 'Matrix([[1, 2], [0, 0]])',
          hint: 'Rank-deficient input: the second row reduces to all zeros. '
              'Useful for spotting linear dependence visually.',
        ),
        FunctionRefExample(
          input: 'rref(Matrix([[2, 4], [0, 6]]))',
          expected: 'Matrix([[1, 0], [0, 1]])',
          hint: 'Pivot scaling normalises leading entries to 1. Symbolic '
              'non-zero detection is the soft spot — see the algorithm '
              'note in `matrix_evaluator.dart`.',
        ),
      ],
      seeAlso: ['det', 'inv', 'transpose', 'matrix_literal'],
      workedExampleId: 'rref',
    ),
    FunctionRef(
      id: 'matrix_arithmetic',
      category: FunctionRefCategory.matrix,
      signature: 'Matrix(...) + / - / *  Matrix(...)',
      shortDescription:
          'Element-wise addition / subtraction and matrix multiplication '
          'on `Matrix(...)` literals.',
      examples: [
        FunctionRefExample(
          input: 'Matrix([[1, 2], [3, 4]]) + Matrix([[5, 6], [7, 8]])',
          expected: 'Matrix([[6, 8], [10, 12]])',
          hint: 'In CrispMath, matrix binary ops are dispatched by the '
              'matrix evaluator when both operands parse as `Matrix(...)` '
              'literals. The underlying call is SymEngine\'s `add_dense_'
              'dense`; subtraction goes through `add_dense_dense` with '
              'an element-wise negation of the right-hand side.',
        ),
        FunctionRefExample(
          input: 'Matrix([[1, 2], [3, 4]]) * Matrix([[1, 0], [0, 1]])',
          expected: 'Matrix([[1, 2], [3, 4]])',
          hint: 'Multiplication is the standard row-by-column dot product '
              'via SymEngine\'s `mul_dense_dense`. Right-multiplication '
              'by the identity is a sanity check.',
        ),
        FunctionRefExample(
          input: 'Matrix([[1, 2], [3, 4]]) - Matrix([[1, 1], [1, 1]])',
          expected: 'Matrix([[0, 1], [2, 3]])',
          hint: 'Subtraction is element-wise; dimension mismatch errors '
              'cleanly with `Error: matrix - failed: …`.',
        ),
      ],
      seeAlso: ['det', 'inv', 'matrix_literal'],
    ),
    FunctionRef(
      id: 'eigenvalues',
      category: FunctionRefCategory.matrix,
      signature: 'eigenvalues(Matrix(...))',
      shortDescription:
          'Eigenvalues of a square numeric matrix via pure-Dart QR '
          'algorithm. Returns the set of eigenvalues, including complex '
          'conjugate pairs for non-symmetric matrices.',
      examples: [
        FunctionRefExample(
          input: 'eigenvalues(Matrix([[2, 1], [1, 2]]))',
          expected: '{3, 1}',
          hint: 'Symmetric 2×2 — closed-form via the characteristic '
              'polynomial. Eigenvalues are always real for symmetric '
              'matrices.',
        ),
        FunctionRefExample(
          input: 'eigenvalues(Matrix([[1, 0], [0, 1]]))',
          expected: '{1, 1}',
          hint: 'The identity matrix has all eigenvalues equal to 1.',
        ),
        FunctionRefExample(
          input: 'eigenvalues(Matrix([[0, -1], [1, 0]]))',
          expected: '{0 + 1i, 0 - 1i}',
          hint: 'Rotation matrix — eigenvalues are complex conjugates '
              '±i. The QR algorithm handles real Schur form 2×2 blocks.',
        ),
      ],
      seeAlso: ['eigenvectors', 'det', 'inv', 'matrix_literal'],
    ),
    FunctionRef(
      id: 'eigenvectors',
      category: FunctionRefCategory.matrix,
      signature: 'eigenvectors(Matrix(...))',
      shortDescription:
          'Eigenvalues and eigenvectors of a square numeric matrix. '
          'Returns both eigenvalues and their corresponding eigenvectors '
          '(normalised). Available for 2×2 matrices with real eigenvalues.',
      examples: [
        FunctionRefExample(
          input: 'eigenvectors(Matrix([[2, 1], [1, 2]]))',
          expected: 'Eigenvalues: {3, 1}\nEigenvectors: ...',
          hint: 'For 2×2 matrices with real eigenvalues, eigenvectors '
              'are computed via null-space of (A − λI). For larger '
              'matrices or complex eigenvalues, only eigenvalues are '
              'returned.',
        ),
      ],
      seeAlso: ['eigenvalues', 'det', 'inv', 'matrix_literal'],
    ),
    // === Statistics ==========================================================
    // All stats entries are module-surface (runnable: false). The
    // hypothesis tests live in the Statistics module's "Tests" tab
    // (lib/screens/statistics_screen.dart, _TestKind enum); the
    // engine code is `lib/engine/hypothesis_tests.dart`. Cross-link
    // to `statsHypothesisTests` (the `open:statistics?tab=tests`
    // sentinel) so "See worked example" lands the user there.
    FunctionRef(
      id: 'mean',
      category: FunctionRefCategory.statistics,
      signature: 'Descriptive Stats → Sample mean',
      shortDescription:
          'Sample arithmetic mean of a numeric list. Surfaced in the '
          'Statistics module\'s Descriptive Stats tab alongside the '
          'standard summary statistics.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'data = [1, 2, 3, 4, 5]',
          expected: 'mean = 3.0',
          hint: 'In CrispMath, `mean` is computed by `DescriptiveStats.mean` '
              '(see `lib/engine/statistics.dart`) — a single-pass sum / n. '
              'For paired or grouped data the Stats module also exposes '
              'standard deviation, median, quartiles, and the IQR.',
        ),
        FunctionRefExample(
          input: 'data = [2.1, 2.3, 1.9, 2.0, 2.4]',
          expected: 'mean = 2.14',
          hint: 'Floating-point input — the implementation accumulates in '
              '`double`, so very large or mixed-magnitude lists may need '
              'a stable summation algorithm if you need >15 digits.',
        ),
      ],
      seeAlso: ['one_sample_t', 'welch_t', 'linreg'],
      workedExampleId: 'statsHypothesisTests',
      // Statistics-preset follow-up: land on the Descriptive Stats tab
      // pre-filled with a spread-out sample (not the Tests tab).
      openTarget: 'open:statistics?preset=statsDescriptive',
    ),
    FunctionRef(
      id: 'one_sample_t',
      category: FunctionRefCategory.statistics,
      signature: 'Tests → One-sample t',
      shortDescription:
          'One-sample t-test: does a sample mean differ from a hypothesised '
          'population mean μ₀? Reports t, df = n−1, and a two-sided p-value.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'data = [...], μ₀ = 70',
          expected: 't, df = n-1, p',
          hint: 'In CrispMath, `oneSampleT` lives in '
              '`lib/engine/hypothesis_tests.dart`. The underlying call computes '
              't = (x̄ − μ₀) / (s / √n), then reads the two-sided p-value off '
              '`TDistribution.cdf` with df = n − 1.',
        ),
        FunctionRefExample(
          input: 'data = [74, 78, 81, 69, 76, 80, 77], μ₀ = 70',
          expected: 't ≈ 4.0, df = 6, p ≈ 0.007',
          hint: 'The sample sits clearly above μ₀ = 70, so the test rejects '
              'H₀ (mean = 70) at α = 0.05. Compare with `paired_t`, which is a '
              'one-sample t on the difference vector.',
        ),
      ],
      seeAlso: ['mean', 'paired_t', 'welch_t'],
      workedExampleId: 'statsHypothesisTests',
      openTarget: 'open:statistics?preset=statsOneSampleT',
    ),
    FunctionRef(
      id: 'welch_t',
      category: FunctionRefCategory.statistics,
      signature: 'Tests → Two-sample t (Welch)',
      shortDescription:
          'Two-sample t-test with unequal variances (Welch–Satterthwaite). '
          'Robust default when the two groups may have different spreads.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'A = [...], B = [...]',
          expected: 't, df, p',
          hint:
              'In CrispMath, `welchT` lives in `lib/engine/hypothesis_tests.dart`. '
              'The underlying call computes the test statistic '
              't = (x̄_A − x̄_B) / √(s_A²/n_A + s_B²/n_B), then approximates '
              'the degrees of freedom via Welch–Satterthwaite, and reads the '
              'p-value off `TDistribution.cdf`.',
        ),
        FunctionRefExample(
          input: 'A = [1, 2, 3], B = [4, 5, 6]',
          expected: 't = -3.674, df ≈ 4, p ≈ 0.021',
          hint:
              'Tiny-sample case — the Welch df ≈ 4 even though n_A + n_B = 6, '
              'because the two-sample t-distribution adjusts for the variance '
              'estimate uncertainty.',
        ),
      ],
      seeAlso: ['paired_t', 'wilcoxon', 'anova_1'],
      workedExampleId: 'statsHypothesisTests',
      // Round 99 follow-up: one-tap landing on the Tests tab pre-filled
      // with two unequal-variance groups (StatisticsPresets).
      openTarget: 'open:statistics?preset=statsWelchTwoSample',
    ),
    FunctionRef(
      id: 'paired_t',
      category: FunctionRefCategory.statistics,
      signature: 'Tests → Paired t',
      shortDescription:
          'Paired t-test on within-subject differences against μ₀ = 0. '
          'Use when the same units are measured twice (before/after).',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'before = [...], after = [...]',
          expected: 't, df = n-1, p',
          hint: 'In CrispMath, `pairedT` reduces to a one-sample t-test on the '
              'difference vector d = after − before. The underlying call is '
              'the same `TDistribution.cdf` route used by `welchT`, but with '
              'df = n - 1 (no Welch adjustment because there\'s only one '
              'variance estimate to make).',
        ),
        FunctionRefExample(
          input: 'before = [1, 2, 3], after = [4, 5, 6]',
          expected: 't = ∞ (zero variance in d), p = 0',
          hint: 'Edge case: identical shifts produce zero variance in the '
              'differences, which the implementation surfaces as the limiting '
              'p = 0 rather than a NaN.',
        ),
      ],
      seeAlso: ['welch_t', 'sign_test', 'wilcoxon'],
      workedExampleId: 'statsHypothesisTests',
      openTarget: 'open:statistics?preset=statsPairedT',
    ),
    FunctionRef(
      id: 'anova_1',
      category: FunctionRefCategory.statistics,
      signature: 'Tests → One-way ANOVA',
      shortDescription:
          'One-way ANOVA across K independent groups. Tests whether group '
          'means differ; reports an F-statistic and p-value.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'groups = [[...], [...], [...]]',
          expected: 'F, df1 = K-1, df2 = N-K, p',
          hint: 'In CrispMath, `anovaOneWay` partitions total SS into '
              'between-group SS and within-group SS. The underlying call is '
              'F = MS_between / MS_within with df1 = K - 1 and df2 = N - K, '
              'then `FDistribution.sf` for the upper-tail p-value.',
        ),
        FunctionRefExample(
          input: 'groups = [[1, 2], [3, 4], [5, 6]]',
          expected: 'F = 16, df1 = 2, df2 = 3, p ≈ 0.025',
          hint: 'Equal-spread, well-separated means produce a high F. Reject '
              'H₀ (all means equal) at α = 0.05.',
        ),
      ],
      seeAlso: ['welch_t', 'chi2_independence', 'wilcoxon'],
      workedExampleId: 'statsHypothesisTests',
      // Round 99 follow-up: one-tap landing on the Tests tab pre-filled
      // with three separated groups (StatisticsPresets).
      openTarget: 'open:statistics?preset=statsAnovaThreeGroups',
    ),
    FunctionRef(
      id: 'chi2_goodness',
      category: FunctionRefCategory.statistics,
      signature: 'Tests → χ² goodness-of-fit',
      shortDescription:
          'Chi-squared goodness-of-fit test: do observed counts match a '
          'hypothesised distribution?',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'observed = [10, 20, 30], expected = [15, 20, 25]',
          expected: 'χ² = 2.67, df = 2, p ≈ 0.264',
          hint:
              'In CrispMath, `chiSquareGof` evaluates Σ (O - E)² / E and reads '
              'the upper-tail p-value off `ChiSquaredDistribution.sf` with '
              'df = k - 1 where k is the number of categories. Underlying '
              'cell counts are assumed ≥ 5 — the implementation does not '
              'auto-Yates-correct.',
        ),
        FunctionRefExample(
          input: 'observed = [50, 50], expected = [50, 50]',
          expected: 'χ² = 0, df = 1, p = 1.0',
          hint: 'Perfect match → χ² = 0 → fail to reject H₀ at any α.',
        ),
      ],
      seeAlso: ['chi2_independence', 'fisher_exact', 'sign_test'],
      workedExampleId: 'statsHypothesisTests',
      // Round 99 follow-up: one-tap landing on the Tests tab pre-filled
      // with observed counts vs a uniform expectation (StatisticsPresets).
      openTarget: 'open:statistics?preset=statsChiSquareGof',
    ),
    FunctionRef(
      id: 'chi2_independence',
      category: FunctionRefCategory.statistics,
      signature: 'Tests → χ² test of independence',
      shortDescription:
          'Chi-squared independence test on a contingency table — are two '
          'categorical variables independent?',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'table = [[10, 20], [15, 25]]',
          expected: 'χ² ≈ 0.06, df = 1, p ≈ 0.81',
          hint:
              'In CrispMath, `chiSquareIndependence` computes expected counts '
              'from row × column marginals (E_ij = row_i · col_j / total), '
              'then Σ (O - E)² / E with df = (rows - 1) · (cols - 1). The '
              'underlying p-value comes from `ChiSquaredDistribution.sf`.',
        ),
        FunctionRefExample(
          input: 'table = [[8, 2], [1, 9]]',
          expected: 'χ² ≈ 7.2, df = 1, p ≈ 0.007',
          hint: 'Strong off-diagonal concentration → low p. For sparse 2×2 '
              'tables prefer `fisher_exact`, which doesn\'t rely on the '
              'large-sample chi-squared approximation.',
        ),
      ],
      seeAlso: ['chi2_goodness', 'fisher_exact', 'anova_1'],
      workedExampleId: 'statsHypothesisTests',
      openTarget: 'open:statistics?preset=statsChiSquareIndep',
    ),
    FunctionRef(
      id: 'fisher_exact',
      category: FunctionRefCategory.statistics,
      signature: 'Tests → Fisher\'s exact (2×2)',
      shortDescription:
          'Fisher\'s exact test on a 2×2 contingency table. Exact '
          'hypergeometric p-value — no large-sample approximation.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'table = [[8, 2], [1, 9]]',
          expected: 'p ≈ 0.0055',
          hint:
              'In CrispMath, `fisherExact` enumerates all 2×2 tables with the '
              'same marginals and sums the hypergeometric probabilities of '
              'tables at least as extreme as observed. The underlying call '
              'computes log-Choose terms to avoid overflow on large totals, '
              'then exponentiates; two-sided p follows R\'s convention '
              '(sum of tail probabilities ≤ observed).',
        ),
        FunctionRefExample(
          input: 'table = [[5, 5], [5, 5]]',
          expected: 'p = 1.0',
          hint: 'Symmetric table → no evidence of association.',
        ),
      ],
      seeAlso: ['chi2_independence', 'chi2_goodness', 'sign_test'],
      workedExampleId: 'statsHypothesisTests',
      openTarget: 'open:statistics?preset=statsFisherExact',
    ),
    FunctionRef(
      id: 'wilcoxon',
      category: FunctionRefCategory.statistics,
      signature: 'Tests → Wilcoxon rank-sum',
      shortDescription:
          'Wilcoxon rank-sum / Mann–Whitney U — nonparametric two-sample '
          'test on ranks. Robust to non-normal data.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'A = [...], B = [...]',
          expected: 'W, z, p',
          hint: 'In CrispMath, `wilcoxonRankSum` pools both samples, assigns '
              'midrank-corrected ranks, sums the ranks of group A, and '
              'reports the normal-approximation z. The underlying call '
              'applies a tie correction to the variance and reads the '
              'two-sided p-value off the normal CDF.',
        ),
        FunctionRefExample(
          input: 'A = [1, 2, 3], B = [4, 5, 6]',
          expected: 'W = 6, z ≈ -1.96, p ≈ 0.05',
          hint: 'Tiny-sample case — the normal approximation is borderline at '
              'n_A + n_B = 6. For very small samples the exact permutation '
              'distribution should be preferred (not yet shipped).',
        ),
      ],
      seeAlso: ['welch_t', 'sign_test', 'anova_1'],
      workedExampleId: 'statsHypothesisTests',
      openTarget: 'open:statistics?preset=statsWilcoxon',
    ),
    FunctionRef(
      id: 'sign_test',
      category: FunctionRefCategory.statistics,
      signature: 'Tests → Paired sign test',
      shortDescription:
          'Paired sign test — nonparametric median-based test on paired '
          'differences. Counts how often `after > before`.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'before = [...], after = [...]',
          expected: 's, n, p',
          hint:
              'In CrispMath, `pairedSign` discards pairs with zero difference, '
              'counts positives among the remaining n, and tests against '
              'Binomial(n, 0.5). The underlying p-value uses the exact '
              'binomial tail — no normal approximation, so it\'s the right '
              'choice for very small paired samples.',
        ),
        FunctionRefExample(
          input: 'before = [1, 2, 3, 4], after = [2, 3, 5, 4]',
          expected: 's = 3, n = 3, p = 0.25',
          hint: 'One tied pair (4 → 4) is dropped, leaving n = 3 positives '
              'out of 3 informative pairs. The two-sided exact p is '
              '2 · min(Binom(3, 0.5).cdf(3), …).',
        ),
      ],
      seeAlso: ['paired_t', 'wilcoxon', 'fisher_exact'],
      workedExampleId: 'statsHypothesisTests',
      openTarget: 'open:statistics?preset=statsSignTest',
    ),
    FunctionRef(
      id: 'linreg',
      category: FunctionRefCategory.statistics,
      signature: 'Regression → Linear fit',
      shortDescription:
          'Ordinary least-squares linear regression y = a·x + b on paired '
          '(x, y) data. Reports the slope, intercept and coefficient of '
          'determination R².',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'x = [...], y = [...]',
          expected: 'y = a·x + b, R²',
          hint: 'In CrispMath, the Regression tab fits via the closed-form '
              'least-squares estimators a = Sxy / Sxx and b = ȳ − a·x̄ (see '
              '`lib/engine/statistics.dart`). The same tab also offers '
              'polynomial and exponential models.',
        ),
        FunctionRefExample(
          input: 'x = [1, 2, 3, 4, 5, 6], y = [2.1, 3.9, 6.2, 7.8, 10.1, 11.9]',
          expected: 'y ≈ 1.99·x + 0.05, R² ≈ 1.00',
          hint: 'Points lying close to y = 2x give a slope ≈ 2 and an R² near '
              '1 — an almost perfect linear fit.',
        ),
      ],
      seeAlso: ['mean', 'one_sample_t', 'poly_fit', 'exp_fit'],
      openTarget: 'open:statistics?preset=statsLinearRegression',
    ),
    FunctionRef(
      id: 'poly_fit',
      category: FunctionRefCategory.statistics,
      signature: 'Regression → Polynomial fit',
      shortDescription:
          'Least-squares polynomial regression y = c₀ + c₁x + … + c_d·xᵈ of a '
          'chosen degree d on paired (x, y) data. Reports the coefficients '
          'and R².',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'x = [...], y = [...], degree d',
          expected: 'y = Σ cₖ·xᵏ, R²',
          hint: 'The Regression tab\'s degree selector (2–5) sets d; a higher '
              'degree fits more curvature but risks overfitting. Backed by '
              'Statistics.polynomialFit (`lib/engine/statistics.dart`).',
        ),
      ],
      seeAlso: ['linreg', 'exp_fit', 'mean'],
    ),
    FunctionRef(
      id: 'exp_fit',
      category: FunctionRefCategory.statistics,
      signature: 'Regression → Exponential fit',
      shortDescription:
          'Least-squares exponential regression y = a·e^(b·x) on paired '
          '(x, y) data (fit via a log-linear transform). Reports a, b and R².',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'x = [...], y = [...]',
          expected: 'y = a·e^(b·x), R²',
          hint: 'Fits growth / decay data; internally regresses ln(y) against '
              'x, so every y must be positive. Backed by Statistics.expFit.',
        ),
      ],
      seeAlso: ['linreg', 'poly_fit', 'mean'],
    ),
    FunctionRef(
      id: 'normal_dist',
      category: FunctionRefCategory.statistics,
      signature: 'Distributions → Normal',
      shortDescription:
          'Normal (Gaussian) distribution N(μ, σ): cumulative probability '
          'P(X ≤ x) and the inverse-CDF quantile for a given probability p.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'μ = 100, σ = 15, x = 130',
          expected: 'P(X ≤ 130) ≈ 0.977',
          hint: 'In CrispMath, the Distributions tab evaluates the normal CDF '
              'via the error function (`Normal.cdf` in '
              '`lib/engine/statistics.dart`); x = μ + 2σ sits at the ≈ 97.7th '
              'percentile.',
        ),
        FunctionRefExample(
          input: 'μ = 100, σ = 15, p = 0.95',
          expected: 'quantile ≈ 124.7',
          hint: 'The 0.95 quantile is the inverse CDF — the value below which '
              '95 % of the mass lies (≈ μ + 1.645σ). Pairs with `erf`, which '
              'underlies the CDF.',
        ),
      ],
      seeAlso: ['erf', 'mean'],
      openTarget: 'open:statistics?preset=statsNormalDist',
    ),
    FunctionRef(
      id: 'binomial_dist',
      category: FunctionRefCategory.statistics,
      signature: 'Distributions → Binomial',
      shortDescription:
          'Binomial distribution B(n, p) over n independent trials with '
          'success probability p: mean n·p, variance n·p·(1−p), the point '
          'mass P(X = k) and the cumulative P(X ≤ k).',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'n = 20, p = 0.1, k = 2',
          expected: 'mean = 2, P(X = 2) ≈ 0.285',
          hint: 'In CrispMath, the Distributions tab evaluates the binomial '
              'PMF C(n, k)·pᵏ·(1−p)^(n−k) (`Binomial.pmf` in '
              '`lib/engine/statistics.dart`); with a 10 % defect rate over 20 '
              'items the most likely defect count is the mean, 2.',
        ),
        FunctionRefExample(
          input: 'n = 20, p = 0.1, k = 2',
          expected: 'P(X ≤ 2) ≈ 0.677',
          hint: 'The CDF sums the PMF from 0 to k. Here ≈ 68 % of batches show '
              'at most two defects. Variance is n·p·(1−p) = 1.8, so the '
              'stddev ≈ 1.34.',
        ),
      ],
      seeAlso: ['normal_dist', 'mean'],
      openTarget: 'open:statistics?preset=statsBinomialDist',
    ),
    // === Constraints DSL =====================================================
    // All constraints entries are module-surface (runnable: false).
    // The DSL parser is `lib/engine/csp_solver.dart` (class
    // `DslToFlatZinc`); each operator is transpiled to a FlatZinc
    // constraint, which the dart_csp solver consumes. Cross-link to
    // the rich gallery of DSL worked examples.
    FunctionRef(
      id: 'vars',
      category: FunctionRefCategory.constraints,
      signature: 'vars: x, y in 1..9',
      shortDescription:
          'Declare integer decision variables and their domain. Always the '
          'first line of a CrispMath DSL program.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'vars: a, b, c in 1..20',
          expected: '(declares three CP-int variables)',
          hint: 'In CrispMath, the `vars:` line is parsed by `DslToFlatZinc` '
              '(see `lib/engine/csp_solver.dart`) and emits one FlatZinc '
              '`var int: x :: …` declaration per name. The domain bounds '
              'are concrete integers; symbolic domains aren\'t supported.',
        ),
        FunctionRefExample(
          input: 'vars: x in 0..1',
          expected: '(boolean-shaped int)',
          hint: 'A `0..1` domain models a boolean variable. FlatZinc has a '
              'separate `var bool` type — the parser doesn\'t pick it up, '
              'but the solver handles the 0/1 int just as efficiently.',
        ),
      ],
      seeAlso: ['all_different', 'minimize', 'maximize'],
      workedExampleId: 'dslMagicSquare',
    ),
    FunctionRef(
      id: 'all_different',
      category: FunctionRefCategory.constraints,
      signature: 'allDifferent(a, b, c, …)',
      shortDescription:
          'Global "all values pairwise distinct" constraint. The flagship '
          'CP constraint — much stronger propagation than n·(n-1)/2 '
          'pairwise `!=` clauses.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'allDifferent(a, b, c)',
          expected: '(adds the constraint)',
          hint: 'In CrispMath, `allDifferent` transpiles to FlatZinc\'s '
              '`all_different_int([a, b, c])`. The underlying solver '
              '(dart_csp) implements bound-consistency propagation via '
              'Régin\'s matching algorithm — much faster than pairwise on '
              'large argument lists.',
        ),
        FunctionRefExample(
          input: 'allDifferent(row1) and allDifferent(row2) and ...',
          expected: '(Sudoku row constraints)',
          hint: 'The Sudoku presets in the Sudoku module are built on stacks '
              'of `allDifferent` constraints — one per row, column, box, '
              'and any variant zones.',
        ),
      ],
      seeAlso: ['vars', 'no_overlap', 'cumulative'],
      workedExampleId: 'dslMagicSquare',
    ),
    FunctionRef(
      id: 'no_overlap',
      category: FunctionRefCategory.constraints,
      signature: 'noOverlap(s1=d1, s2=d2, …)',
      shortDescription:
          'Disjunctive scheduling: tasks with given start variables and '
          'fixed durations cannot overlap in time on a single machine.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'noOverlap(s1=4, s2=3, s3=2)',
          expected: '(disjunctive constraint on three tasks)',
          hint: 'In CrispMath, `noOverlap` transpiles to FlatZinc\'s '
              '`disjunctive([s1, s2, s3], [4, 3, 2])`. The underlying '
              'solver uses edge-finding plus Vilím\'s θ-tree propagator — '
              'the same algorithm as MiniZinc\'s built-in.',
        ),
        FunctionRefExample(
          input:
              'noOverlap(s1=4, s2=3, s3=2) and minimize max(s1+4, s2+3, s3+2)',
          expected: '(makespan minimization on a single machine)',
          hint: 'Classic single-machine sequencing problem. Combine with '
              '`minimize` over the makespan expression to get the optimal '
              'schedule. See the worked example for the full DSL program.',
        ),
      ],
      seeAlso: ['cumulative', 'minimize', 'all_different'],
      workedExampleId: 'dslSchedulingMakespan',
    ),
    FunctionRef(
      id: 'cumulative',
      category: FunctionRefCategory.constraints,
      signature: 'cumulative(s1=d1@r1, …; capacity=C)',
      shortDescription:
          'Cumulative scheduling on a renewable resource of fixed capacity. '
          'Each task has a duration and a per-task resource demand.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'cumulative(s1=2@2, s2=3@1, s3=2@2; capacity=3)',
          expected: '(at most 3 units of resource used at any time)',
          hint: 'In CrispMath, `cumulative` transpiles to FlatZinc\'s '
              '`cumulative([starts], [durations], [resources], capacity)`. '
              'The underlying solver uses timetable propagation plus '
              'energetic reasoning — capacity-aware versions of the '
              '`noOverlap` propagators.',
        ),
        FunctionRefExample(
          input:
              'cumulative(crew tasks; capacity=3) and cumulative(equip tasks; capacity=3)',
          expected: '(RCPSP — two parallel cumulative overlays)',
          hint: 'The Resource-Constrained Project Scheduling Problem (RCPSP) '
              'stacks multiple `cumulative` constraints, one per resource '
              'type. See the `dslRcpsp` worked example for a two-resource '
              'project.',
        ),
      ],
      seeAlso: ['no_overlap', 'minimize', 'all_different'],
      workedExampleId: 'dslCumulativeScheduling',
    ),
    FunctionRef(
      id: 'minimize',
      category: FunctionRefCategory.constraints,
      signature: 'minimize <linear-expression>',
      shortDescription:
          'Objective: minimize a linear expression over the decision '
          'variables. Combine with constraints to solve optimization CSPs.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'minimize x + y',
          expected: '(finds the assignment with smallest x + y)',
          hint: 'In CrispMath, `minimize` emits FlatZinc\'s '
              '`solve minimize __obj__;` after constructing the objective '
              'variable via linear-expression parsing. The underlying '
              'solver uses branch-and-bound — feasibility check, then tighten '
              'the upper bound on every improving solution.',
        ),
        FunctionRefExample(
          input: 'minimize coins_1 + coins_5 + coins_10 + coins_25',
          expected: '(coin-change: pay 17¢ with fewest coins)',
          hint: 'See the `dslCoinChange` worked example — minimize over a sum '
              'of indicator variables to find the smallest set of coins '
              'totalling the target.',
        ),
      ],
      seeAlso: ['maximize', 'vars', 'no_overlap'],
      workedExampleId: 'dslCoinChange',
    ),
    FunctionRef(
      id: 'maximize',
      category: FunctionRefCategory.constraints,
      signature: 'maximize <linear-expression>',
      shortDescription:
          'Objective: maximize a linear expression. Mirror image of '
          '`minimize` — same branch-and-bound, opposite direction.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'maximize 3*a + 2*b',
          expected: '(finds the assignment with largest 3a + 2b)',
          hint: 'In CrispMath, `maximize` emits FlatZinc\'s '
              '`solve maximize __obj__;`. The underlying solver does '
              'branch-and-bound just like `minimize` but with the '
              'lower-bound tightening flipped.',
        ),
        FunctionRefExample(
          input:
              'maximize sum(profit_i * x_i) subject to sum(weight_i * x_i) <= C',
          expected:
              '(knapsack — pack the highest-value bundle within capacity)',
          hint: 'Classic 0/1 knapsack. The DSL handles this naturally as a '
              '`vars: x_1, ... in 0..1` declaration plus a linear capacity '
              'constraint and a linear objective.',
        ),
      ],
      seeAlso: ['minimize', 'vars', 'all_different'],
      workedExampleId: 'constraintEditor',
    ),
    // === Round 108 DSL globals: logic combinators, cardinality,
    // regular, symmetry breaking, and relational constraints. All are
    // mini-DSL operators (runnable: false) surfaced as help-mode chips.
    FunctionRef(
      id: 'at_least',
      category: FunctionRefCategory.constraints,
      signature: 'atLeast(k, a=1, b=2, …)',
      shortDescription:
          'At least k of the given `name=value` conditions must hold. Each '
          'condition is reified to a boolean and their sum is bounded below.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'atLeast(2, x=1, y=1, z=1)',
          expected: '(at least two of x, y, z equal 1)',
          hint: 'Conditions may target any value, not just booleans — '
              '`atLeast(1, a=3, b=5)` means a is 3 or b is 5 (or both).',
        ),
      ],
      seeAlso: ['at_most', 'exactly', 'implies'],
    ),
    FunctionRef(
      id: 'at_most',
      category: FunctionRefCategory.constraints,
      signature: 'atMost(k, a=1, b=2, …)',
      shortDescription:
          'At most k of the given `name=value` conditions may hold — the '
          'reified conditions sum to k or fewer.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'atMost(1, shift_a=1, shift_b=1, shift_c=1)',
          expected: '(no more than one of these shifts is taken)',
          hint: 'Pair with `atLeast` on the same conditions to pin an exact '
              'count, or use `exactly` directly.',
        ),
      ],
      seeAlso: ['at_least', 'exactly', 'implies'],
    ),
    FunctionRef(
      id: 'exactly',
      category: FunctionRefCategory.constraints,
      signature: 'exactly(k, a=1, b=2, …)',
      shortDescription:
          'Exactly k of the given `name=value` conditions hold — the reified '
          'conditions sum to exactly k.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'exactly(1, ann=1, bob=1)',
          expected: '(exactly one of Ann/Bob chose option 1)',
          hint: 'The workhorse of logic-grid riddles — "exactly one person '
              'owns the cat", "exactly two houses are blue", and so on.',
        ),
      ],
      seeAlso: ['at_least', 'at_most', 'implies'],
    ),
    FunctionRef(
      id: 'implies',
      category: FunctionRefCategory.constraints,
      signature: 'implies(a=1, b=2)',
      shortDescription:
          'Material implication over two `name=value` conditions: if the '
          'first holds then the second must too (a=1 ⇒ b=2).',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'implies(bob=1, cy=2)',
          expected: '(if Bob picked 1, Cy must pick 2)',
          hint: 'Chains of `implies` encode the clue logic of Einstein / '
              'zebra puzzles. See the `logicGrid` worked example.',
        ),
      ],
      seeAlso: ['exactly', 'at_least', 'all_different'],
    ),
    FunctionRef(
      id: 'gcc',
      category: FunctionRefCategory.constraints,
      signature: 'gcc(x, y, z; 1=2, 2=1)',
      shortDescription:
          'Global cardinality: each listed value must occur an exact number '
          'of times among the variables (value 1 twice, value 2 once, …).',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'gcc(d1, d2, d3, d4, d5; 0=2)',
          expected: '(exactly two of the five days are off)',
          hint: 'Rostering and timetabling staple — fix how many times each '
              'shift/value appears. See the `nurseRostering` worked example.',
        ),
      ],
      seeAlso: ['among', 'nvalue', 'all_different'],
    ),
    FunctionRef(
      id: 'among',
      category: FunctionRefCategory.constraints,
      signature: 'among(x, y, z; values=1,3,5; count=c)',
      shortDescription:
          'The declared variable c equals how many of the listed variables '
          'take a value in the given set.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'among(x, y, z; values=1,3; count=c)',
          expected: '(c = number of x, y, z that are 1 or 3)',
          hint: 'Constrain or minimize c to control how many variables fall '
              'into a category.',
        ),
      ],
      seeAlso: ['gcc', 'nvalue'],
    ),
    FunctionRef(
      id: 'nvalue',
      category: FunctionRefCategory.constraints,
      signature: 'nvalue(x, y, z; count=c)',
      shortDescription:
          'The declared variable c equals the number of DISTINCT values taken '
          'by the listed variables. Minimize c to use as few as possible.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'nvalue(a, b, c, d, e; count=colors)  +  minimize colors',
          expected: '(chromatic number — fewest colours)',
          hint: 'With graph-adjacency `!=` constraints, minimizing nvalue '
              'finds the chromatic number. See the `chromaticNumber` example.',
        ),
      ],
      seeAlso: ['gcc', 'among', 'minimize'],
    ),
    FunctionRef(
      id: 'at_most_in_a_row',
      category: FunctionRefCategory.constraints,
      signature: 'atMostInARow(x, y, z; value=1; max=2)',
      shortDescription:
          'No run of more than `max` consecutive `value`s across the sequence '
          '— compiled to a small finite automaton (regular constraint).',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'atMostInARow(d1, d2, d3, d4, d5; value=1; max=2)',
          expected: '(never three day-shifts back to back)',
          hint: 'Encodes fatigue / pattern rules that plain counting can\'t. '
              'The DFA has one state per run length 0..max.',
        ),
      ],
      seeAlso: ['gcc', 'no_overlap'],
    ),
    FunctionRef(
      id: 'value_precedence',
      category: FunctionRefCategory.constraints,
      signature: 'valuePrecedence(x, y, z; order=1,2,3)',
      shortDescription:
          'Symmetry breaking: value order[i+1] may not first appear before '
          'order[i]. Collapses interchangeable-value duplicates (e.g. map '
          'colours) so enumeration lists one representative per class.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'valuePrecedence(a, b, c; order=1,2,3)',
          expected: '(canonical labelling — a is pinned to value 1)',
          hint: 'Add to any problem whose values are interchangeable to cut '
              'the k! relabelling duplicates out of the solution set.',
        ),
      ],
      seeAlso: ['all_different', 'table'],
    ),
    FunctionRef(
      id: 'table',
      category: FunctionRefCategory.constraints,
      signature: 'table(x, y, z; (1,2,3), (4,5,6))',
      shortDescription:
          'The tuple (x, y, z) must equal one of the listed rows. Encodes '
          'arbitrary relations: compatibility matrices, allowed combinations, '
          'logic-grid clue tables.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'table(main, side; (1,1), (1,3), (2,2))',
          expected: '(only these (main, side) pairings are allowed)',
          hint: 'Any relation with no clean formula fits a table. See the '
              '`menuPairing` worked example.',
        ),
      ],
      seeAlso: ['element', 'value_precedence', 'all_different'],
    ),
    FunctionRef(
      id: 'element',
      category: FunctionRefCategory.constraints,
      signature: 'element(idx; list=10,20,30; value=v)',
      shortDescription:
          'Indexed lookup: list[idx] == value, with a 0-based index. Models '
          'indirection like "the cost of the chosen option is v".',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'element(idx; list=40,15,30; value=cost)  +  minimize cost',
          expected: '(pick the cheapest option → idx = 1, cost = 15)',
          hint: 'Combine with `minimize`/`maximize` over the looked-up value '
              'to optimize a choice among tabulated costs.',
        ),
      ],
      seeAlso: ['table', 'minimize'],
    ),
    FunctionRef(
      id: 'diff_n',
      category: FunctionRefCategory.constraints,
      signature: 'diffN((x1, y1, w1, h1), (x2, y2, w2, h2), …)',
      shortDescription:
          'Non-overlapping 2D rectangles: each tuple places a w×h rectangle at '
          'lower-left (x, y). Models packing, tiling, and floor-planning; the '
          'DSL tab draws the solved layout to scale.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input:
              'vars: ax, ay, bx, by in 0..3\ndiffN((ax,ay,2,2), (bx,by,2,1))',
          expected: '(the 2×2 and 2×1 tiles never overlap)',
          hint: 'Coordinate variables must be declared; width and height are '
              'integer literals. The container size is inferred from the '
              'coordinate ranges.',
        ),
      ],
      seeAlso: ['no_overlap', 'cumulative', 'all_different'],
    ),
    FunctionRef(
      id: 'circuit',
      category: FunctionRefCategory.constraints,
      signature: 'circuit(next0, next1, …; labels=A, B, …)',
      shortDescription:
          'A single Hamiltonian tour over successor variables: next[i] is the '
          'node visited after node i, and the tour must reach every node once '
          'and close back to the start. Models TSP and routing; the DSL tab '
          'draws the tour as a directed node-graph. `subcircuit` allows '
          'unvisited nodes (self-loops).',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'vars: a, b, c in 0..2\ncircuit(a, b, c)',
          expected: '(a→b→c→a and its reverse — the tours through all 3 nodes)',
          hint: 'Each successor variable must be declared with a domain '
              'covering 0..n-1. Add `; labels=…` to name the nodes in the '
              'chart; use `subcircuit` when some nodes may be skipped.',
        ),
      ],
      seeAlso: ['all_different', 'diff_n', 'no_overlap'],
    ),
    FunctionRef(
      id: 'soft',
      category: FunctionRefCategory.constraints,
      signature: 'soft(weight): x = 5',
      shortDescription:
          'A MaxCSP preference: the solver satisfies it when it can, '
          'contributing weight (default 1) to the score. When preferences '
          'conflict, the assignment maximizing total satisfied weight wins. '
          'The DSL tab shows a satisfaction score and which preferences held.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'vars: a, b in 0..2\na != b\nsoft(3): a = 1\nsoft(2): b = 1',
          expected: '(a=1 kept — heavier — b=1 dropped: score 3/5)',
          hint: 'The body is a simple comparison (`x = 5`, `x < 3`, `x = y`). '
              'Cannot be combined with `minimize`/`maximize` — both are '
              'objectives.',
        ),
      ],
      seeAlso: ['all_different', 'minimize', 'implies'],
    ),
    // === Round 108b: Advanced-tab vector / modular / root operations
    // that previously had no help popover. Runnable calculator
    // expressions except where the invocation is operator/dialog-based.
    FunctionRef(
      id: 'dot',
      category: FunctionRefCategory.matrix,
      signature: 'dot([a1, a2, …], [b1, b2, …])',
      shortDescription:
          'Dot (scalar) product of two equal-length vectors: Σ aᵢ·bᵢ. '
          'Returns a scalar.',
      examples: [
        FunctionRefExample(
          input: 'dot([1, 2, 3], [4, 5, 6])',
          expected: '32',
          hint: 'The dot product is |a||b|cos θ — zero exactly when the '
              'vectors are orthogonal.',
        ),
      ],
      seeAlso: ['cross', 'norm', 'matrix_literal'],
    ),
    FunctionRef(
      id: 'cross',
      category: FunctionRefCategory.matrix,
      signature: 'cross([a1, a2, a3], [b1, b2, b3])',
      shortDescription:
          'Cross product of two 3-vectors: the vector orthogonal to both, '
          'with length |a||b|sin θ.',
      examples: [
        FunctionRefExample(
          input: 'cross([1, 0, 0], [0, 1, 0])',
          expected: '[0, 0, 1]',
          hint: 'Right-hand rule: x × y = z. Defined only for 3-vectors.',
        ),
      ],
      seeAlso: ['dot', 'norm', 'matrix_literal'],
    ),
    FunctionRef(
      id: 'norm',
      category: FunctionRefCategory.matrix,
      signature: 'norm([v1, v2, …])',
      shortDescription: 'Euclidean length (2-norm) of a vector: √(Σ vᵢ²).',
      examples: [
        FunctionRefExample(
          input: 'norm([3, 4])',
          expected: '5',
          hint: 'The 3-4-5 right triangle. `norm` is the magnitude that '
              '`unit` divides by.',
        ),
      ],
      seeAlso: ['unit', 'dot', 'matrix_literal'],
    ),
    FunctionRef(
      id: 'unit',
      category: FunctionRefCategory.matrix,
      signature: 'unit([v1, v2, …])',
      shortDescription:
          'Unit vector in the direction of v: v / norm(v). Same direction, '
          'length 1.',
      examples: [
        FunctionRefExample(
          input: 'unit([3, 4])',
          expected: '[3/5, 4/5]',
          hint: 'Normalizing keeps direction, discards magnitude — undefined '
              'for the zero vector.',
        ),
      ],
      seeAlso: ['norm', 'dot', 'matrix_literal'],
    ),
    FunctionRef(
      id: 'mod',
      category: FunctionRefCategory.numberTheory,
      signature: 'a mod n',
      shortDescription:
          'Modulo: the remainder of a ÷ n. The `mod` keypad key inserts the '
          'operator between two integers.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: '17 mod 5',
          expected: '2',
          hint: 'Pairs with `modpow` / `modinv` for modular arithmetic; '
              '`a mod n` equals `a − n·⌊a/n⌋`.',
        ),
      ],
      seeAlso: ['modpow', 'modinv', 'gcd'],
    ),
    FunctionRef(
      id: 'nth_root',
      category: FunctionRefCategory.cas,
      signature: 'ⁿ√x  (n-th root of x)',
      shortDescription:
          'The n-th root of x, i.e. x^(1/n). The keypad key opens a small '
          'dialog for the degree n and the radicand x.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'ⁿ√x with n = 3, x = 27',
          expected: '3',
          hint: 'The cube root of 27. For n = 2 use the dedicated √ key; '
              '`ⁿ√x` covers any degree.',
        ),
      ],
      seeAlso: ['sqrt_precision', 'evalf'],
    ),
    // === Round 108c: elementary trig / log / root functions (Trig
    // + Num tabs) that had no help popover.
    FunctionRef(
      id: 'sin',
      category: FunctionRefCategory.cas,
      signature: 'sin(x)',
      shortDescription: 'Sine of x (x in radians).',
      examples: [
        FunctionRefExample(
          input: 'sin(0)',
          expected: '0',
          hint:
              'Period 2π, range [-1, 1]. The calculator treats the argument as radians.',
        ),
      ],
      seeAlso: ['cos', 'tan', 'asin'],
    ),
    FunctionRef(
      id: 'cos',
      category: FunctionRefCategory.cas,
      signature: 'cos(x)',
      shortDescription: 'Cosine of x (x in radians).',
      examples: [
        FunctionRefExample(
          input: 'cos(0)',
          expected: '1',
          hint: 'Period 2π, range [-1, 1]; cos is sin shifted by π/2.',
        ),
      ],
      seeAlso: ['sin', 'tan', 'acos'],
    ),
    FunctionRef(
      id: 'tan',
      category: FunctionRefCategory.cas,
      signature: 'tan(x)',
      shortDescription: 'Tangent of x = sin(x)/cos(x) (x in radians).',
      examples: [
        FunctionRefExample(
          input: 'tan(0)',
          expected: '0',
          hint: 'Period π; undefined where cos(x)=0 (x = π/2 + kπ).',
        ),
      ],
      seeAlso: ['sin', 'cos', 'atan'],
    ),
    FunctionRef(
      id: 'asin',
      category: FunctionRefCategory.cas,
      signature: 'asin(x)',
      shortDescription: 'Inverse sine (arcsine): the angle whose sine is x.',
      examples: [
        FunctionRefExample(
          input: 'asin(1)',
          expected: 'pi/2',
          hint: 'Domain [-1, 1], principal range [-π/2, π/2].',
        ),
      ],
      seeAlso: ['sin', 'acos', 'atan'],
    ),
    FunctionRef(
      id: 'acos',
      category: FunctionRefCategory.cas,
      signature: 'acos(x)',
      shortDescription:
          'Inverse cosine (arccosine): the angle whose cosine is x.',
      examples: [
        FunctionRefExample(
          input: 'acos(1)',
          expected: '0',
          hint: 'Domain [-1, 1], principal range [0, π].',
        ),
      ],
      seeAlso: ['cos', 'asin', 'atan'],
    ),
    FunctionRef(
      id: 'atan',
      category: FunctionRefCategory.cas,
      signature: 'atan(x)',
      shortDescription:
          'Inverse tangent (arctangent): the angle whose tangent is x.',
      examples: [
        FunctionRefExample(
          input: 'atan(0)',
          expected: '0',
          hint: 'Domain all reals, principal range (-π/2, π/2).',
        ),
      ],
      seeAlso: ['tan', 'asin', 'acos'],
    ),
    FunctionRef(
      id: 'sinh',
      category: FunctionRefCategory.cas,
      signature: 'sinh(x)',
      shortDescription: 'Hyperbolic sine: (eˣ − e⁻ˣ)/2.',
      examples: [
        FunctionRefExample(
          input: 'sinh(0)',
          expected: '0',
          hint: 'Odd function, unbounded; the catenary family.',
        ),
      ],
      seeAlso: ['cosh', 'tanh', 'asinh'],
    ),
    FunctionRef(
      id: 'cosh',
      category: FunctionRefCategory.cas,
      signature: 'cosh(x)',
      shortDescription: 'Hyperbolic cosine: (eˣ + e⁻ˣ)/2.',
      examples: [
        FunctionRefExample(
          input: 'cosh(0)',
          expected: '1',
          hint: 'Even function, minimum 1 at x=0; shape of a hanging chain.',
        ),
      ],
      seeAlso: ['sinh', 'tanh', 'acosh'],
    ),
    FunctionRef(
      id: 'tanh',
      category: FunctionRefCategory.cas,
      signature: 'tanh(x)',
      shortDescription: 'Hyperbolic tangent: sinh(x)/cosh(x).',
      examples: [
        FunctionRefExample(
          input: 'tanh(0)',
          expected: '0',
          hint: 'Odd, range (-1, 1); a common neural-network activation.',
        ),
      ],
      seeAlso: ['sinh', 'cosh', 'atanh'],
    ),
    FunctionRef(
      id: 'asinh',
      category: FunctionRefCategory.cas,
      signature: 'asinh(x)',
      shortDescription: 'Inverse hyperbolic sine.',
      examples: [
        FunctionRefExample(
          input: 'asinh(0)',
          expected: '0',
          hint: 'Domain all reals; asinh(x) = ln(x + √(x²+1)).',
        ),
      ],
      seeAlso: ['sinh', 'acosh', 'atanh'],
    ),
    FunctionRef(
      id: 'acosh',
      category: FunctionRefCategory.cas,
      signature: 'acosh(x)',
      shortDescription: 'Inverse hyperbolic cosine.',
      examples: [
        FunctionRefExample(
          input: 'acosh(1)',
          expected: '0',
          hint: 'Domain x ≥ 1; acosh(x) = ln(x + √(x²−1)).',
        ),
      ],
      seeAlso: ['cosh', 'asinh', 'atanh'],
    ),
    FunctionRef(
      id: 'atanh',
      category: FunctionRefCategory.cas,
      signature: 'atanh(x)',
      shortDescription: 'Inverse hyperbolic tangent.',
      examples: [
        FunctionRefExample(
          input: 'atanh(0)',
          expected: '0',
          hint: 'Domain (-1, 1); atanh(x) = ½·ln((1+x)/(1−x)).',
        ),
      ],
      seeAlso: ['tanh', 'asinh', 'acosh'],
    ),
    FunctionRef(
      id: 'ln',
      category: FunctionRefCategory.cas,
      signature: 'ln(x)',
      shortDescription: 'Natural logarithm (base e) of x.',
      examples: [
        FunctionRefExample(
          input: 'ln(1)',
          expected: '0',
          hint: 'Inverse of exp; domain x > 0. ln(e) = 1.',
        ),
      ],
      seeAlso: ['exp', 'log', 'sqrt'],
    ),
    FunctionRef(
      id: 'log',
      category: FunctionRefCategory.cas,
      signature: 'log(x)',
      shortDescription: 'Base-10 (common) logarithm of x.',
      examples: [
        FunctionRefExample(
          input: 'log(100)',
          expected: '2',
          hint: 'Domain x > 0. For other bases use ln(x)/ln(b).',
        ),
      ],
      seeAlso: ['ln', 'exp', 'sqrt'],
    ),
    FunctionRef(
      id: 'exp',
      category: FunctionRefCategory.cas,
      signature: 'exp(x)',
      shortDescription: 'Exponential function e^x.',
      examples: [
        FunctionRefExample(
          input: 'exp(0)',
          expected: '1',
          hint: 'Inverse of ln; always positive, its own derivative.',
        ),
      ],
      seeAlso: ['ln', 'log', 'sinh'],
    ),
    FunctionRef(
      id: 'abs',
      category: FunctionRefCategory.cas,
      signature: 'abs(x)',
      shortDescription:
          'Absolute value (magnitude) of x — also the modulus of a complex number.',
      examples: [
        FunctionRefExample(
          input: 'abs(-3)',
          expected: '3',
          hint: 'abs(x) = √(x²); for a+bi returns √(a²+b²).',
        ),
      ],
      seeAlso: ['norm', 'sqrt', 'evalf'],
    ),
    FunctionRef(
      id: 'sqrt',
      category: FunctionRefCategory.cas,
      signature: 'sqrt(x)',
      shortDescription: 'Square root of x (principal, non-negative branch).',
      examples: [
        FunctionRefExample(
          input: 'sqrt(16)',
          expected: '4',
          hint: 'sqrt(x) = x^(1/2). For other degrees use the ⁿ√x key.',
        ),
      ],
      seeAlso: ['nth_root', 'ln', 'abs'],
    ),
    // === Round 108d: mathematical constants surfaced on the keypad
    // (π on Num; i, γ, ∞ on Advanced). Not directly "runnable" on their
    // own, so runnable: false.
    FunctionRef(
      id: 'pi',
      category: FunctionRefCategory.cas,
      signature: 'π',
      shortDescription:
          'The circle constant π ≈ 3.14159 — a circle\'s circumference over '
          'its diameter. The keypad key inserts the symbol.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: '2·π·r',
          expected: '(circumference of a circle of radius r)',
          hint: 'For π to a chosen number of digits use the π(N) key '
              '(pi_precision).',
        ),
      ],
      seeAlso: ['pi_precision', 'e_precision', 'euler_gamma'],
    ),
    FunctionRef(
      id: 'imaginary_unit',
      category: FunctionRefCategory.cas,
      signature: 'i',
      shortDescription:
          'The imaginary unit i, with i² = −1. Represented internally as '
          'SymEngine\'s `I`.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'i^2',
          expected: '-1',
          hint: 'Complex results come back in terms of I — e.g. '
              'solve(x^2 + 1 = 0) → x = ±i.',
        ),
      ],
      seeAlso: ['solve', 'evalf', 'cevalf'],
    ),
    FunctionRef(
      id: 'euler_gamma',
      category: FunctionRefCategory.cas,
      signature: 'γ',
      shortDescription:
          'The Euler–Mascheroni constant γ ≈ 0.57722 — the limit of '
          '(Σ 1/k − ln n) as n → ∞.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'γ',
          expected: '≈ 0.5772156649',
          hint: 'Inserts `EulerGamma`; for γ to a chosen number of digits use '
              'the γ(N) key (eulergamma_precision).',
        ),
      ],
      seeAlso: ['eulergamma_precision', 'pi', 'e_precision'],
    ),
    FunctionRef(
      id: 'infinity',
      category: FunctionRefCategory.cas,
      signature: '∞',
      shortDescription:
          'Positive infinity ∞ — used as a bound in limits and improper '
          'integrals rather than as a value to compute with.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'lim(1/x, x, ∞)',
          expected: '0',
          hint: 'Inserts `\\infty`; pair with `lim` or `∫` to describe '
              'limiting / improper behaviour.',
        ),
      ],
      seeAlso: ['limit', 'integrate'],
    ),
    // === Sudoku variants =====================================================
    // Sudoku entries describe the variant rules — they're presets in
    // the Sudoku module, not DSL operators. All carry runnable: false
    // and cross-link to the `killerSudoku` worked example (which
    // dispatches `open:sudoku?preset=killer9x9`).
    FunctionRef(
      id: 'sudoku_regular',
      category: FunctionRefCategory.sudoku,
      signature: 'Sudoku → Regular preset',
      shortDescription:
          'Classic Sudoku rules: each row, column, and box contains every '
          'digit exactly once. Presets ship for 4×4, 6×6, 8×8, 9×9, 10×10, '
          '12×12, 15×15, and 16×16.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'Sudoku module → preset → "Regular 9×9"',
          expected: '(loads a standard 9×9 grid)',
          hint:
              'In CrispMath, the Regular variant lives in `lib/engine/sudoku.dart` '
              'as `SudokuVariant.regular`. The underlying solver instantiates '
              'one `allDifferent` per row, column, and box (27 in total for '
              '9×9), and hands them off to `dart_csp`.',
        ),
      ],
      seeAlso: ['sudoku_x', 'sudoku_disjoint', 'sudoku_killer'],
      workedExampleId: 'killerSudoku',
    ),
    FunctionRef(
      id: 'sudoku_x',
      category: FunctionRefCategory.sudoku,
      signature: 'Sudoku → X preset',
      shortDescription:
          'Sudoku-X: regular Sudoku rules plus both main diagonals are also '
          'allDifferent. Ships as an 8×8 preset.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'Sudoku module → preset → "X 8×8"',
          expected: '(loads an 8×8 grid with diagonal constraints)',
          hint:
              'In CrispMath, Sudoku-X is `SudokuVariant.x` (`lib/engine/sudoku.dart`). '
              'The underlying solver adds two extra `allDifferent` constraints '
              'on top of the regular row/column/box trio — one per diagonal.',
        ),
      ],
      seeAlso: ['sudoku_regular', 'sudoku_disjoint', 'sudoku_killer'],
      workedExampleId: 'killerSudoku',
    ),
    FunctionRef(
      id: 'sudoku_disjoint',
      category: FunctionRefCategory.sudoku,
      signature: 'Sudoku → Disjoint Groups preset',
      shortDescription:
          'Disjoint Groups: regular rules plus an additional allDifferent '
          'across cells in the same in-box position across all boxes.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'Sudoku module → preset → "Disjoint 8×8"',
          expected: '(loads an 8×8 grid with disjoint-group constraints)',
          hint:
              'In CrispMath, this is `SudokuVariant.disjoint`. For an N×N grid '
              'with √N × √N boxes, the constraint adds N more `allDifferent` '
              'overlays — one per in-box position. The 8×8 ships as a single '
              'preset.',
        ),
      ],
      seeAlso: ['sudoku_regular', 'sudoku_x', 'sudoku_killer'],
      workedExampleId: 'killerSudoku',
    ),
    FunctionRef(
      id: 'sudoku_killer',
      category: FunctionRefCategory.sudoku,
      signature: 'Sudoku → Killer preset',
      shortDescription:
          'Killer Sudoku: no givens; instead, the grid is partitioned into '
          '"cages", each cage allDifferent and summing to a given target.',
      runnable: false,
      examples: [
        FunctionRefExample(
          input: 'Sudoku module → preset → "Killer 9×9"',
          expected: '(loads a 9×9 cage-puzzle)',
          hint: 'In CrispMath, this is `SudokuVariant.killer`. The underlying '
              'solver layers per-cage `allDifferent` + a per-cage `sum = '
              'target` over the regular row/column/box trio. The 4×4 and '
              '9×9 killer presets both ship.',
        ),
      ],
      seeAlso: ['sudoku_regular', 'sudoku_x', 'sudoku_disjoint'],
      workedExampleId: 'killerSudoku',
    ),

    // === Logic / relational ===================================================
    FunctionRef(
      id: 'eq_op',
      category: FunctionRefCategory.logic,
      signature: 'a == b',
      shortDescription:
          'Equality test — returns true when both sides evaluate to the same value.',
      examples: [
        FunctionRefExample(
            input: '2 == 2',
            expected: 'true',
            hint: 'Lowered to SymEngine\'s Eq(2, 2) and folded to True.'),
        FunctionRefExample(
            input: 'x == 5',
            expected: 'Eq(x, 5)',
            hint: 'Symbolic — stays as an equation when x is free.'),
      ],
      seeAlso: ['ne_op', 'and_op'],
      workedExampleId: 'booleanEqualityFold',
    ),
    FunctionRef(
      id: 'ne_op',
      category: FunctionRefCategory.logic,
      signature: 'a != b',
      shortDescription:
          'Inequality test — returns true when the two sides differ.',
      examples: [
        FunctionRefExample(
            input: '3 != 4',
            expected: 'true',
            hint: 'Lowered to SymEngine\'s Ne(3, 4).'),
        FunctionRefExample(
            input: '5 != 5',
            expected: 'false',
            hint: 'Equal values yield false.'),
      ],
      seeAlso: ['eq_op'],
    ),
    FunctionRef(
      id: 'lt_op',
      category: FunctionRefCategory.logic,
      signature: 'a < b',
      shortDescription: 'Strict less-than comparison.',
      examples: [
        FunctionRefExample(
            input: '2 < 5',
            expected: 'true',
            hint: 'Lowered to SymEngine\'s Lt(2, 5).'),
        FunctionRefExample(
            input: '5 < 5',
            expected: 'false',
            hint: 'Not strictly less — use <= for non-strict.'),
      ],
      seeAlso: ['le_op', 'gt_op', 'ge_op'],
    ),
    FunctionRef(
      id: 'le_op',
      category: FunctionRefCategory.logic,
      signature: 'a <= b',
      shortDescription: 'Less-than-or-equal comparison.',
      examples: [
        FunctionRefExample(
            input: '5 <= 5',
            expected: 'true',
            hint: 'Lowered to SymEngine\'s Le(5, 5).'),
        FunctionRefExample(
            input: '6 <= 5',
            expected: 'false',
            hint: 'Strictly greater fails the test.'),
      ],
      seeAlso: ['lt_op', 'ge_op'],
    ),
    FunctionRef(
      id: 'gt_op',
      category: FunctionRefCategory.logic,
      signature: 'a > b',
      shortDescription: 'Strict greater-than comparison.',
      examples: [
        FunctionRefExample(
            input: '10 > 3',
            expected: 'true',
            hint: 'Lowered to SymEngine\'s Gt(10, 3).'),
      ],
      seeAlso: ['ge_op', 'lt_op'],
    ),
    FunctionRef(
      id: 'ge_op',
      category: FunctionRefCategory.logic,
      signature: 'a >= b',
      shortDescription: 'Greater-than-or-equal comparison.',
      examples: [
        FunctionRefExample(
            input: '5 >= 5',
            expected: 'true',
            hint: 'Lowered to SymEngine\'s Ge(5, 5).'),
      ],
      seeAlso: ['gt_op', 'le_op'],
    ),
    FunctionRef(
      id: 'and_op',
      category: FunctionRefCategory.logic,
      signature: 'a and b',
      shortDescription:
          'Logical conjunction — true only when both operands are true.',
      examples: [
        FunctionRefExample(
            input: 'isprime(7) and 7 < 10',
            expected: 'true',
            hint: 'Both predicates hold → true.'),
        FunctionRefExample(
            input: '2 == 2 and 3 == 4',
            expected: 'false',
            hint: 'One false operand → false.'),
      ],
      seeAlso: ['or_op', 'not_op', 'xor_op'],
      workedExampleId: 'booleanIsprimeAnd',
    ),
    FunctionRef(
      id: 'or_op',
      category: FunctionRefCategory.logic,
      signature: 'a or b',
      shortDescription:
          'Logical disjunction — true when at least one operand is true.',
      examples: [
        FunctionRefExample(
            input: '1 == 2 or 3 == 3',
            expected: 'true',
            hint: 'One true suffices.'),
      ],
      seeAlso: ['and_op', 'not_op', 'xor_op'],
      workedExampleId: 'booleanOrChain',
    ),
    FunctionRef(
      id: 'not_op',
      category: FunctionRefCategory.logic,
      signature: 'not a',
      shortDescription:
          'Logical negation — flips true to false and vice versa.',
      examples: [
        FunctionRefExample(
            input: 'not isprime(4)',
            expected: 'true',
            hint: '4 is not prime → not false → true.'),
        FunctionRefExample(
            input: 'not 2 == 2',
            expected: 'false',
            hint: 'Negates the equality.'),
      ],
      seeAlso: ['and_op', 'or_op'],
      workedExampleId: 'booleanNotPrime',
    ),
    FunctionRef(
      id: 'xor_op',
      category: FunctionRefCategory.logic,
      signature: 'a xor b',
      shortDescription: 'Exclusive or — true when exactly one operand is true.',
      examples: [
        FunctionRefExample(
            input: '2 == 2 xor 3 == 3',
            expected: 'false',
            hint: 'Both true → xor is false.'),
        FunctionRefExample(
            input: '2 == 2 xor 3 == 4',
            expected: 'true',
            hint: 'Exactly one true → xor is true.'),
      ],
      seeAlso: ['or_op', 'and_op'],
    ),
    FunctionRef(
      id: 'if_cond',
      category: FunctionRefCategory.logic,
      signature: 'if(condition, then, else)',
      shortDescription:
          'Conditional — evaluates the condition, returns the then-branch if true, else-branch if false.',
      examples: [
        FunctionRefExample(
            input: 'if(isprime(7), 100, 200)',
            expected: '100',
            hint: '7 is prime → condition is true → returns 100.'),
        FunctionRefExample(
            input: 'if(2 > 5, 10, 20)',
            expected: '20',
            hint: '2 is not > 5 → returns the else-branch.'),
      ],
      seeAlso: ['and_op', 'or_op', 'eq_op'],
      workedExampleId: 'booleanIfFold',
    ),
  ];
}
