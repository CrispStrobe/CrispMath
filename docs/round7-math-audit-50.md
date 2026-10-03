# Seventh independent mathematical audit

Fifty questions and hand-derived references were committed before observing app
outputs in `ffa36677f42b8e71644e89d7c5596675c87eeb26`:
[algebra/calculus references](round7-math-algebra.md) and
[numeric references](round7-math-numeric.md). Pre-output freshness replacements
are documented in those drafts; none used app answers. Both fixtures contain
25 questions and remain frozen throughout diagnosis.

The first hosted [native/WASM audit](https://github.com/CrispStrobe/CrispMath/actions/runs/37116981054)
and [packaged macOS run](https://github.com/CrispStrobe/CrispMath/actions/runs/37116922166)
found 34/50 passing on Linux native, 33/50 on packaged macOS, and 31/50
on WASM. All previous 537 runtime cases passed on each platform. Initial
reports are retained in stage14 CI evidence; the browser reports are on cold
storage to protect the shared disk. The accumulated runtime corpus has 587 cases before any
additional related negative or live controls. Nineteen distinct frozen questions failed on at least one platform. Initial
failures are preserved and traced to shared causes; expected answers remain
unchanged.

Confirmed failures cover complex conjugation/principal powers, roots excluded
by original denominators, endpoint logarithmic integrals, unsampled irrational
poles, polynomial absolute-value calculus, a rationalized infinity limit,
scientific literals and near-singular decimal matrices, singular-inverse
diagnostics, Student t tail intervals, chi-square significance, and erg/atm
conversion. Shared bounded proofs and stable tail routines repair these failures. Additional
live controls exposed scientific-token and builtin-name worksheet gaps, also
repaired through the shared scope scanner.

All builds, app execution, analysis, unit suites and Playwright batches run on
GitHub-hosted machines. The shared VPS only handles edits, status queries and
small report downloads. Physical-device testing remains deferred; handwriting
accuracy and Apple's 4.3(a) App Review rejection remain separate open issues.


| Finding | Shared correction |
| --- | --- |
| Unevaluated conjugation and backend-dependent negative fractional powers | Bounded Gaussian-rational conjugation and principal-argument power rewriting; symbolic, undefined and excessive inputs decline. |
| Repeated roots at excluded denominator holes | Remove every forbidden factor multiplicity before solving the candidate polynomial, retaining original source exclusions. |
| Log-squared endpoint error and finite result across irrational poles | Analytic limiting primitives for affine logarithm powers; exact bounded Sturm root certificates for rational integration intervals. |
| Polynomial absolute-value point/Taylor failures | Determine local sign and zero multiplicity; share point, Taylor and genuine-cusp checks. |
| Arithmetic infinity expression returned as a limit | Rationalize matched quadratic radicals and reject unevaluated compound infinity outputs. |
| Rounded scientific constants and decimal matrices | Parse decimal scales as bounded rationals before CAS/FFI; label rational matrix results exact only with closed-operation/input/output proof. |
| Opaque singular inverse error on WASM | Certify singular rational matrices before inversion and map opaque JS exceptions to readable diagnostics. |
| Lost t tail interval and incorrect chi-square p-value | Direct survival probabilities and stable narrow intervals; regularized incomplete gamma replaces singular-endpoint density integration. Actual hypothesis tests share those routines. |
| Missing erg/atm conversion | Add exact standard scales to the common dimension catalog, preserving SI prefixes and compound dimensions. |
| Correct scientific worksheet answer retained an exponent-name badge | Consume complete scientific numbers in shared name scanning, dependency analysis, scope substitution and function templates. Standalone exponent-like variable names remain reactive. |
| Builtin conjugation would display a false name badge | Register conjugate as a builtin while retaining dependencies and free arguments. |

Coverage is deliberately bounded: exact constants retain existing 16,384-bit
arithmetic/source/depth limits; complex proofs have 4,096-bit coefficient
limits; rational-domain Sturm checks support degree up to sixteen; absolute
polynomial branches and affine logarithm powers have explicit degree/order
limits. Principal negative rational powers use bounded numerator/denominator
magnitudes. Unsupported expressions retain normal CAS routing and honest
provenance; this audit does not certify every possible expression.

The actual worksheet check preserved the failed scientific-name badge even
though the answer and exact evidence were correct. New scope controls distinguish
complete lower/uppercase signed literals, decimal mantissas, standalone e308,
reactive coefficient dependencies and function parameters. A new unit assertion
was corrected to compare the independently derived a/1000 value: decimal 0.002
and rational 1/500 are equivalent display forms. Frozen mathematical references
were not changed.

The statistics live checker preserves four earlier descriptive checks and adds
GOF (observed 0,10; expected 5,5) and one-sample t (mean 1e10, SD 1, n=3) through
real desktop/phone forms. Expected displayed GOF p is 0.001565; t upper and
two-sided p values are 1.6667e-21 and 3.3333e-21. An initial tab locator failed
because Flutter exposed tab names through aria-labels instead of text; the
corrected locator uses real geometry and clicks with unchanged value assertions.

Final candidate b299ab1fd30c1adb90d439af47678aa801b118e7 has 366 production
files, fingerprint 0aab8294a63dddff32cd7ef62a6f473aab4fd8480f30525dc7ca0359c51e03e5.
The [full feature run](https://github.com/CrispStrobe/CrispMath/actions/runs/37120276425)
passes clean analysis, 5,648 unit/widget tests with eight documented skips,
404 focused regressions, release/debug browser checks, all four performance
gates and twelve populated web-gallery scenes. It ran 63 tooling controls;
the final [immutable-bundle probe](https://github.com/CrispStrobe/CrispMath/actions/runs/37123152551)
passes all 64 tooling controls and independently verifies production parity
against this same bundle. The probe passes 54 new actual worksheet entries,
four reactive edits and eight statistics checks, with visible semantic result
groups and read-back of both input fields on desktop and phone. Focus settling
and lowercase imaginary-unit display were corrected in the test driver without
changing mathematical references or app production source.

[Linux native](https://github.com/CrispStrobe/CrispMath/actions/runs/37120273069),
[packaged macOS](https://github.com/CrispStrobe/CrispMath/actions/runs/37120606466)
and [WASM runtime/worksheets](https://github.com/CrispStrobe/CrispMath/actions/runs/37121952366)
pass all 587 runtime cases, including 50/50 new questions. The Linux and WASM
workflow's later UI driver failures are preserved; the immutable-bundle probe
above resolves those driver issues. Actual cumulative worksheet coverage is
214 entries and 22 binding-edit states, with eight statistics checks.

Hosted Linux same-host paired performance gates pass at 500/2,000 rows:
desktop edit medians 0.849/1.647 seconds and 4x CPU-throttled phone medians
3.907/13.015 seconds. Paired baselines are 0.650/1.628 and 4.309/20.845 seconds.
These are browser edit latencies, not physical-device frame rates or directly
comparable timings to the previous macOS runner.

The [final Apple gallery](https://github.com/CrispStrobe/CrispMath/actions/runs/37121956172)
passes 33 populated scenes, eleven each on iPhone and iPad simulators and native
macOS. Its helper SHA 194faf1 has identical production source to b299ab1. Four
selected graph/worksheet images were visually reviewed: meaningful curves,
computed values and legible layout. The full galleries remain remote.

Final [Pages](https://github.com/CrispStrobe/CrispMath/actions/runs/37123153962)
and [production Vercel](https://github.com/CrispStrobe/CrispMath/actions/runs/37123155237)
pass all 587 runtime cases, 214 worksheet entries, 22 binding-edit states and
eight statistics checks. Their deployed helper/source SHA is
abf3d3e1ad91e4c3fddf5ce9092d91804b2bf5d8, with production parity as above.
[Signed build 18](https://github.com/CrispStrobe/CrispMath/actions/runs/37124118509)
passes tooling, signed privacy/version/signature checks and production parity
against full validation before upload. Apple processing is VALID and Internal
Testers are assigned. [External TestFlight verification](https://github.com/CrispStrobe/CrispMath/actions/runs/37124700154)
confirms build UUID f26bb783-4db8-4916-9b2d-66fee7405d2f, beta submission
APPROVED, Public Beta assigned and external state IN_BETA_TESTING. Apple's
submittedDate is null in the returned record; no timestamp is invented.
The [public beta](https://testflight.apple.com/join/E6HdVhTx) now offers build 18.
No App Review submission occurred. Physical iPhone/iPad checks remain deferred;
real Siri/Files-provider and two-device cloud checks remain pending. Handwriting
accuracy and Apple's 4.3(a) App Review rejection remain unresolved separately.

Cold task archival moved 4,462 historical files to CIFS with SHA-256 checks
and readable local symlinks. Net fast-storage reclamation was 115.93 MiB;
active stages, source and unrelated projects remained untouched.
