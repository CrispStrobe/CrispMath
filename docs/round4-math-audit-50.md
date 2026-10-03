# Fourth independent 50-problem audit

Two agents independently derive 25 algebra/calculus and 25 numeric/statistical/
unit/constraint reference answers before consulting earlier fixtures or app output.
Freshness review replaces three repeated algebra questions before execution;
references and replacement derivations remain recorded. All suites, builds and
browser execution run on hosted GitHub CI under the shared VPS resource policy.

- [Algebra references](round4-math-algebra.md)
- [Numeric references](round4-math-numeric.md)
- Fixtures: `test/fixtures/round4_{algebra,numeric}_tasks.json`.

## Initial findings

[Linux/WASM audit](https://github.com/CrispStrobe/CrispMath/actions/runs/37096643452)
and [packaged macOS](https://github.com/CrispStrobe/CrispMath/actions/runs/37096645075)
use source `82de30f`. Linux, WASM and packaged macOS each initially pass
46/50: all 25 algebra problems pass, and the same four numeric findings remain:

1. `sqrt(49)/sqrt(121)` produces a rounded decimal instead of exact `7/11`.
2. Linear regression with predictors near 10^9 produces an undefined fit for
   the exact line with slope 2 and intercept -1,999,999,999.
3. Large response offsets preserve the coefficients but produce undefined R²
   for a perfect line, whose R² must be 1.
4. `1 kPa in N/cm^2` is rejected instead of converting to `0.1 N/cm²`.

All three runtimes reproduce those four failures; prior 360 cases remain green.
Reference answers remain unchanged; exact requests cannot pass through decimal
comparisons. Physical-device checks remain deferred, and beta approval does not
resolve the earlier 4.3(a) App Review finding. Application repairs are included in externally approved TestFlight build 15.

## Repairs and controls

- Exact constant arithmetic accepts square roots only when both the reduced
  rational numerator and denominator are perfect nonnegative squares. BigInt
  Newton iteration retains large integer precision within existing bit, node,
  exponent and depth limits. Irrational, complex, symbolic and excessive inputs
  decline to the existing CAS route; successful radicals retain exact evidence.
- Linear regression centers observations before accumulating variation and
  scales deviations to prevent squared-magnitude overflow. Constant predictors
  remain undefined; constant responses retain their exact constant fit and
  undefined R². Focused tests check coefficients and residuals absolutely so
  the corpus's relative tolerance cannot hide a large intercept error.
- Compound unit targets compose a catalog/derived numerator and denominator,
  including metric prefixes and square/cube powers. Correct dimensions and
  scales are required; offset temperatures and malformed targets decline.
- Nine actual desktop/phone worksheet entry controls verify exact roots,
  reciprocal powers, logarithm/exponential integrals, scaled tangent limits
  and pressure conversion. Checks retain source/build provenance, persistence,
  reload, screenshots and justified computation evidence.

## Repaired validation

Application repairs and build-15 preparation are at `0c69d79`.
[Native/WASM audit](https://github.com/CrispStrobe/CrispMath/actions/runs/37097115089)
confirms all 410 native and WASM cases pass, together with 76 actual worksheet
entries. [Full analysis/unit/browser CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37097116216)
passes analysis, focused checks, 48 Python tooling tests and 5,500 unit/widget
tests with eight documented skips, but fails the debug graph interaction described
below. [Packaged macOS](https://github.com/CrispStrobe/CrispMath/actions/runs/37097117775)
and [Pages](https://github.com/CrispStrobe/CrispMath/actions/runs/37097263043)
pass all 410 runtime checks. [Vercel preview](https://github.com/CrispStrobe/CrispMath/actions/runs/37097264586)
fails at its sign-in redirect before any application checks; final validation uses
the public production deployment.

## Findings from screenshots and debug interaction

Review of the successful numeric UI screenshots at `0c69d79` reveals unit
names and a limit dummy variable incorrectly listed as free worksheet symbols.
Lexical binding now excludes recognized unit syntax and calculus dummy variables
from global substitution, free-variable badges, dependencies and input evidence.
Real coefficients, approach points and quantity/scalar magnitudes remain reactive,
even when their names resemble units. Scientific numerical exponents remain part
of their literals. Nine focused scope tests include actual worksheet unit dispatch and injectable
limit routing;
three further runtime controls verify unit/global collisions, local limit variables
and reactive approach points. Desktop/phone controls now set same-name globals
before evaluating the corresponding limit and pressure conversion.

The [baseline full feature run](https://github.com/CrispStrobe/CrispMath/actions/runs/37097116216)
passes units and release-browser checks but fails the debug Apply → Fit → Undo
sequence. Accepted graph bounds were applied after the 300 ms controller cleanup
wait, allowing a quick Fit to sample old bounds and then be overwritten. Accepted
bounds now apply immediately; only controller disposal waits. A widget regression
checks the actual rendered viewport before that delay; the real browser sequence
continues to enforce fitted/undo bounds without hiding the race with extra sleeps.

Baseline [Pages](https://github.com/CrispStrobe/CrispMath/actions/runs/37097263043)
passes 410 runtime checks and 76 worksheet entries. Baseline Vercel preview
redirects unauthenticated CI to Vercel sign-in; its failure occurs before any app
checks. Final validation uses the public production alias.

At `3d66dc7`, numeric runtime checks pass but a headless unit fixture attempts
an unavailable native limit. The fixture is corrected to assert actual scoped
operation arguments and compute this continuous polynomial through exact direct
substitution; real CAS limit computation remains covered on native/WASM and live
UI paths. A curly-brace lint in the shared parser is also corrected.

The final candidate `39c3591576bd0ab2d82e9a4e28ac1fd76e336d1e` passes
[Linux/WASM](https://github.com/CrispStrobe/CrispMath/actions/runs/37098494268),
[full unit/browser/gallery](https://github.com/CrispStrobe/CrispMath/actions/runs/37098495947),
[packaged macOS](https://github.com/CrispStrobe/CrispMath/actions/runs/37098497595),
[Pages](https://github.com/CrispStrobe/CrispMath/actions/runs/37098499383) and
[Vercel](https://github.com/CrispStrobe/CrispMath/actions/runs/37098500927).
Each runtime passes all 413 accumulated checks, including unchanged preceding
fixtures and the three new scope controls. Linux/WASM, Pages and Vercel also
pass all 82 actual desktop/phone worksheet entries. Full CI passes analysis,
focused regressions, 5,511 unit/widget tests (eight documented skips), 48 tooling
tests, release/debug browser assertions, actual touch tracing, performance gates
and the 12-scene populated web gallery. Reviewed mobile screenshots confirm the
correct results under global x/N/cm collisions with no false free-variable badges.

The 500/2,000-row edit medians are 0.525/0.858 seconds on desktop and
2.332/3.218 seconds with 4× browser CPU throttling. These are CI browser timings,
not physical-device performance measurements. The source-tagged performance and
actual touch tap/drag reports pass with no recorded page errors.

Build 15 delivery follows the completed validation; actual Apple results follow.

## Signed build 15

[Release CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37099298115)
uses source `39c3591576bd0ab2d82e9a4e28ac1fd76e336d1e`, version 1.2.0 (15).
All 48 release-tooling tests pass. The actual signed bundle passes photo-library
and camera purpose-string validation and version/build checks. The publication
gate records the same package and validated source, green browser/gallery jobs,
361 production files and fingerprint
`f0580e6e5a0ad0eb19ff3a7c83eaa7a5c3467671b9fec1fd7b88584104af23c2`.
The binary upload succeeds; Apple reports VALID processing and Internal Testers
assignment. [External TestFlight verification](https://github.com/CrispStrobe/CrispMath/actions/runs/37099901727)
confirms version 1.2.0 (15), matching source and verification source, beta review
APPROVED, internal/external IN_BETA_TESTING and Public Beta assignment. The beta
submission record matches build ID `a33926e8-4a4f-4112-96fa-8345c1c537ea`;
Apple returns no submission timestamp. The [public beta](https://testflight.apple.com/join/E6HdVhTx)
is available. No App Review submission occurred. Physical-device testing remains
deferred; the earlier 4.3(a) rejection remains unresolved.
