# Second independent 100-case audit

Drafted on 2 October 2026 after the preceding audit completed. Two agents drafted
40 algebra and 40 numeric references independently before comparing old corpora;
the parent drafted 20 worksheet/graph/export problems. Some questions may overlap
previous coverage. This is another audit, not a claim of 100 new features.

- [Algebra and calculus references](round2-math-algebra.md)
- [Numeric, statistics, units and constraints](round2-math-numeric.md)
- [Worksheets, graphs and exports](round2-math-workflows.md)

Fixtures are `test/fixtures/round2_{algebra,numeric,workflow}_tasks.json`.
Run using `tool/crispmath_cli.sh --tasks FILE --require-native --report FILE`.
GitHub CI runs these through the actual native CLI and browser WASM worker;
deployment workflows also run them against Pages and Vercel. Fifteen additional
independently derived arithmetic, provenance and integral-binding controls are typed through the real desktop and
phone UI, with source provenance, reload checks and screenshots.

## Initial results and fixes

[Initial CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37049929017),
source `c581c56`, passed 93/100 new WASM checks: 40/40 algebra, 33/40 numeric
and 20/20 workflow. Native passed 33/40 numeric and 20/20 workflow; the algebra
batch crashed in native antiderivative substitution and did not produce a report.
The preceding additional 100-case corpus still passed on both runtimes.

The seven numeric failures were a rounded large-integer remainder, loss of exact
power/reciprocal forms, zero singleton sample deviation, and three unavailable
unit conversions (watt-hours, squared prefixes and compound speed). The first
new actual-UI control also exposed a decimal result instead of the requested
exact negative-base reciprocal.

Fixes add bounded exact constant arithmetic, safely replace scalar symbols
without the crashing FFI substitution, retain undefined singleton sample values,
and support properly scaled derived and compound conversion targets. Rational
integration checks cancel exact common factors before rejecting actual poles;
this avoids principal-value answers for ordinary improper integrals while
preserving removable holes. Independent expected mathematical values remain
unchanged. FTC endpoint evaluation exposed a second native crash in composed logarithms.
Real endpoints now use Dart evaluation with approximate evidence; a targeted
constant logarithm/absolute-value guard also protects direct calculator input.
Four independent safety cases supplement the unchanged 100-case draft.

Populated native screenshots then exposed two additional worksheet defects.
Derived cached decimal values had incorrectly acquired exact rational evidence;
uncertainty now follows dependency edges, including captured functions, without
changing exact literal-decimal arithmetic. Three runtime probes cover this.
Definite-integral dummy variables also appeared as free variables and could be
replaced by a worksheet value with the same name. They now bind locally through
function expansion, substitution and dependency tracking; bounds remain reactive.
Parenthesized rational bounds retain exact polynomial integration through the
bounded constant parser. Three more runtime probes and actual dispatcher/UI
regressions cover these semantics.

## Verification

Application changes are at `8701bcf`. Final validation:

- [Native Linux and browser WASM](https://github.com/CrispStrobe/CrispMath/actions/runs/37056547900)
  each pass **310 runtime cases**: original and fresh 50-case sets, preceding
  additional 100, second-round 100, four native safety controls, three numerical
  dependency controls and three integral-binding controls. Eleven preceding and
  fifteen new actual worksheet controls run on desktop/phone (52 entries),
  verifying results, evidence, persistence, source revision and reload.
- [Packaged sandboxed macOS](https://github.com/CrispStrobe/CrispMath/actions/runs/37056554064)
  passes the same 310 cases, native CAS/series assertions and actual OCR.
- [Full analysis, unit/widget, release/debug browser validation](https://github.com/CrispStrobe/CrispMath/actions/runs/37056551314)
  passes analysis, focused regressions and **5,446 unit/widget tests**, with
  eight documented skips. Release/debug browser checks and performance gates
  also pass, along with the populated 12-scene web gallery.
- [Pages](https://github.com/CrispStrobe/CrispMath/actions/runs/37056868479) and
  [Vercel](https://github.com/CrispStrobe/CrispMath/actions/runs/37056871842)
  each pass all 310 runtime cases and 52 actual worksheet entry controls against
  the deployed applications, plus handwriting, imports/exports, recovery/history
  and workflow galleries. Both live build manifests report source `8701bcf`.
- [Native Apple gallery](native-apple-gallery.md) passes all 33 captures and
  content assertions: 11 populated scenes each on iPhone and iPad simulators and the actual native macOS app. Capture
  revision `c5955f2` includes the dummy-variable fix; `8701bcf` only adds exact
  expression-bound support and brace corrections, which do not alter these
  literal-bound scenes. No physical-device result is claimed.

The final dependency-edit performance gate passes. Median edits for 500/2,000
rows are 0.60/1.03 s on desktop and 2.71/7.33 s with the phone viewport and
4× browser CPU throttling; the committed baseline is 0.65/1.63 s and
4.31/20.84 s respectively. These are CI browser measurements, not physical
device performance claims.

All compilation, suites and browser execution run on hosted CI. VPS load, memory
and disk were checked first; local work is limited to small edits and report
review. Physical iPhone/iPad checks remain deferred by the user. Previous math
fixes are verified, while imperative reassignment remains an explicit reactive
worksheet feature boundary. Later math changes are not in TestFlight build 13.
