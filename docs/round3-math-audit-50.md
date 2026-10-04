# Third independent 50-problem audit

Drafted on 3 October 2026, after the second audit completed. Two agents wrote
25 algebra/calculus and 25 numeric/statistics/units/constraint references before
consulting previous fixtures or app output. Mathematical answers remain fixed.
The real cube-root question uses explicit `cbrt(-8)` to distinguish it from
valid principal complex exponentiation.

- [Algebra/calculus references and derivations](round3-math-algebra.md)
- [Numeric/statistical/unit/constraint references](round3-math-numeric.md)

Fixtures are `test/fixtures/round3_{algebra,numeric}_tasks.json`. Execute through
`tool/crispmath_cli.sh --tasks FILE --require-native --report FILE`. These use
actual application engine, module and worksheet routes rather than stored answers.

## Initial findings

[Linux native and WASM](https://github.com/CrispStrobe/CrispMath/actions/runs/37092444940)
and [packaged macOS](https://github.com/CrispStrobe/CrispMath/actions/runs/37092446432),
source `b5886e8`, each pass **46/50** new problems. All preceding 310 runtime
cases still pass. The four new failures are identical across the runtimes:

1. The improper integral of `(x^2-4)/(x-2)` over 1..3 fails at the removable
   hole instead of returning 8. Pole detection already cancels the common factor,
   but numerical sampling still uses the original quotient.
2. Constant-response linear regression returns R²=1, although its total response
   variation is zero and the ratio is undefined. The slope and intercept are 0,5.
3. Cubic millimetres cannot convert to microlitres; 1 mm³ equals 1 μL.
4. The constraint parser rejects `x*x + y*y == 2` over [-2,2], which has exactly
   four signed solutions (±1,±1).

## Fixes and checks

- Definite integration checks genuine poles first, then uses exact cancellation
  to integrate the continuous extension through removable holes. Reversed bounds,
  endpoint holes, rational coefficients and remaining irrational poles have unit
  controls; ordinary source-domain exclusions remain meaningful outside integration.
- Linear, polynomial and exponential fits retain undefined R² for constant
  responses. Degenerate predictors leave the fit undefined. JSON uses null for
  nonfinite statistics; the real statistics widget must show `R² = Undefined`.
- Litre prefixes use the correct volume scale, including Greek μ, micro-sign µ
  and ASCII u aliases. Unit tests exercise actual conversions and dimensions.
- A bounded integer-polynomial adapter retains signed coefficients and repeated
  factors on both comparison sides, using BigInt arithmetic. Enumeration,
  optimization, explanations and propagation tracing share this routing. Tests
  cover comparator sets, unary/ternary predicates, large coefficients and malformed
  or unsupported input. There is no dependency change.
- Six independently derived actual worksheet entry controls cover a rational
  difference/ratio, translated and reversed polynomial integrals, a negative real
  cube root, microlitre prefixes and a rationalized square-root limit. Desktop and
  phone runs verify saved source/results/evidence, reload and build provenance.

## Verification

Application fixes are at `e8422a5`. [Native/WASM validation](https://github.com/CrispStrobe/CrispMath/actions/runs/37093130429)
and [packaged macOS](https://github.com/CrispStrobe/CrispMath/actions/runs/37093134180)
pass all **360 accumulated runtime cases**, including the unchanged 310 and
all 50 fresh problems. The native/WASM run also passes the new actual UI controls.
[Analysis/full unit CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37093132457)
passes **5,478 unit/widget tests**, with eight documented skips, and focused/tool
checks. Its broader browser job stopped at an offscreen Trace control: the old
script treated an accessibility node's existence as visible toolbar readiness.
The helper now scrolls the real toolbar, checks full viewport geometry and pointer
hit-testing, and records readiness alongside the original tap/drag assertions.
[Release/debug browser revalidation](https://github.com/CrispStrobe/CrispMath/actions/runs/37093888049)
passes release/debug browser assertions, real mobile touch tracing, performance
gates and the 12-scene web gallery. This includes the same app code, build-14
version preparation and the interaction-helper correction. The trace evidence
records actual taps/drags without page errors. The 500/2,000-row edit medians
are 0.586/0.965 seconds on desktop and 2.280/5.104 seconds with 4× browser CPU
throttling; these are browser measurements, not physical-device performance.

[Pages](https://github.com/CrispStrobe/CrispMath/actions/runs/37093349394) and
[Vercel](https://github.com/CrispStrobe/CrispMath/actions/runs/37093350797)
pass all 360 runtime cases and 64 actual desktop/phone worksheet entries,
plus imports/exports, handwriting, history/recovery and galleries. Both run the
repaired application revision `e8422a5`.

## Execution scope

All builds, suites, corpus batches and browser checks run on GitHub-hosted CI.
VPS load, available memory and free space were checked first. Cleanup archived
268.84 MiB of old CrispMath bundles to CIFS with verified hashes and readable
source symlinks; current evidence, source, toolchains and other projects remain
untouched. Physical iPhone/iPad checks remain deferred. Reactive self-reassignment
is still an explicit worksheet boundary, not a supported imperative assignment.

[Read-only Apple verification](https://github.com/CrispStrobe/CrispMath/actions/runs/37092308470)
now confirms build 13 beta review APPROVED and external IN_BETA_TESTING. The
[public beta](https://testflight.apple.com/join/E6HdVhTx) is available; later math
changes are not in build 13. Apple's earlier 4.3(a) App Review finding remains open.

## Signed build 14 delivery

[Release CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37094979914)
passes for source `e0a0614999ba5f22c592b8fd61c18a2c9aacaa71`, version 1.2.0,
build 14. The archive is signed; the actual signed bundle passes photo-library
and camera purpose-string and version/build checks. The upload gate requires
both browser and gallery success from run `37093888049` and matching production
source/dependency pins. Its provenance records 361 production files and fingerprint
`a752377f9b859906b8f59623eb243afd43fae80d252afd9fcdf5c22b410ac6ea`.
All 48 release-tooling tests pass. Controls cover wrong workflow/repository/source, failed/skipped jobs,
incomplete trees, changed application/runtime/dependency files and safe
CI/docs/test-only source changes. A stale build-13 fixture was corrected before
any upload; no duplicate binary was submitted.

Upload succeeds; Apple processing is VALID and Internal Testers assignment is
confirmed. This build includes the newer mathematical fixes omitted from build 13.
[External TestFlight verification/submission](https://github.com/CrispStrobe/CrispMath/actions/runs/37095571010)
passes for this exact uploaded source and build: Apple beta review is APPROVED,
internal and external states are IN_BETA_TESTING, and Public Beta assignment is
confirmed. The submission record matches build ID
`26a96c77-406f-4bf0-8571-68834fe068e5`; Apple returns no submitted-date timestamp.
The [public beta](https://testflight.apple.com/join/E6HdVhTx) now offers build 14.
No App Review submission occurred. Physical testing and the earlier 4.3(a)
finding remain pending.
