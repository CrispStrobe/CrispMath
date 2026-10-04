# Ninth independent mathematical audit

Fifty new mathematical questions and independent references are frozen at
`3bc82de` before any app output is observed: [algebra/calculus](round9-math-algebra.md)
and [numeric/statistics/units/constraints](round9-math-numeric.md). Each fixture
contains 25 questions. Exact duplicates and a hand-derivation sign correction
were resolved before observation and documented in the reference drafts.
SHA256 hashes of all four frozen reference files are saved on stage16 cold
storage. Existing CLI routes suffice; only hosted corpus registration and
reference tests are added before the initial audit. Previous rounds
supply 637 accumulated runtime questions; this round brings the corpus to
687. Confirmed failures retain their initial reports and unchanged expected
answers, with shared repairs and regression controls recorded here.

All builds, app execution, full analysis, test batches, Playwright and native
captures run on GitHub-hosted runners. Local work is limited to small edits,
status queries and selected report/image review; downloaded evidence goes to
cold storage. Physical iPhone/iPad checks remain deferred. Real Siri/Files,
two-device cloud, handwriting accuracy and Apple's 4.3(a) finding remain open.
Build 19 is the previously verified approved public beta; build 20 delivery
evidence is recorded below after all changed-production gates pass.

## Preserved initial evidence

At integration source `1ec3c2825c991d2a8e8be6cda72d660fbd2a93bd`, production
remains identical to the approved build 19. [Native Linux/WebAssembly audit](https://github.com/CrispStrobe/CrispMath/actions/runs/37144811266)
and [packaged Mac audit](https://github.com/CrispStrobe/CrispMath/actions/runs/37144813327)
run all 687 questions. Initial Linux and Mac each pass 684/687: all prior 637,
all 25 new algebra cases and 22/25 numeric cases. Their three failures are
Ohm-law prefix composition (`1 mA * 1 kΩ in V`), standalone squared-time units
(`1 m² / 1 s² in J/kg`) and a shifted-factor polynomial constraint objective.
Tiny original runtime JSONs and focused-reference failure evidence remain on
stage16 cold storage. The tiny/huge standard deviation, rare binomial, closed
t-distribution and zero-cell chi-square references pass. WASM also passes 684/687 with exactly the same three failures, all 25
new algebra cases and all previous 637; its historical actual UI checks pass.

Electrical current is absent from the dimension model/catalog; standalone
unit powers bypass the bounded atomic resolver; the shared integer-polynomial
parser splits on every sign/product and rejects grouped shifted factors.
Systematic bounded repairs and positive/negative controls are described below.

## Shared repairs and controls

Electrical current is a separate dimension propagated through arithmetic,
equality/hash and coherent ampere/volt/ohm definitions and SI prefixes. Powered
standalone units use the same bounded atomic resolver as compound factors,
including squared/cubed forms, finite-scale checks and affine-unit rejection.
Multiple denominator factors are printed as repeated divisions, matching the
parser's left-associative semantics; default display conversion rejects overflow.

The shared integer-polynomial parser now handles grouped sum/product/unary
expressions with canonical exact BigInt coefficients. It bounds source length,
expanded terms (64), factors (128), nesting (32) and coefficient bits (4096)
before allocation while retaining objective-domain guards. Reduced linear or
constant expressions remain valid; constant true/false constraints retain safe
solver routing. Independent static review found these cancellation/zero-arity
and display-overflow cases, which now have controls. Twenty-nine new regression
tests and two reference tests pass hosted verification. Build 20 follows all
changed-production gates.

The first repaired candidate `0d8dd15` passes all 687 runtime questions on
native Linux and packaged Mac. Full units expose a real input-budget regression:
canonical term combination allowed 65 repeated summands to bypass the previous
64-source-term limit. Separate global source-term/atom counters now retain that
limit before simplification, with oversized repeated/zero controls. Two existing
unit assertions described grouped objectives and ampere as unsupported; they
now assert the newly supported behavior while retaining other invalid-input
checks. Initial failure logs are preserved. The analyzer's reported missing
braces are corrected. Final full/runtime/live verification follows.

The next candidate `76b4e41` also passes all 687 runtime questions on WASM
and packaged Mac. Its sole remaining full-unit/focused failure is 65 zero
linear terms bypassing polynomial limits through the older linear fast path.
The shared linear parser now checks 1024 source characters, 64 raw terms and
128 atoms before coefficient parsing; decimal linear grammar and propagation
remain intact. Positive 64-term controls and unchanged negative 65-term controls
cover both routes.

Actual browser coverage adds 66 worksheet entries, four real descriptive-statistics
checks and two real constraint optimizations. Independent tooling controls retain
exact principal signs, complete roots, every matrix/Taylor coefficient and
visible tiny-value labels. Shared exact comparator arithmetic now preflights
scientific exponents and rational coefficient growth before allocation.
Native gallery capture has separate iPhone/iPad steps with bounded boot/drive
phases, streamed logs, failure diagnostics and owned-descendant cleanup. These
helper changes retain the same production code and screenshot assertions.

Candidate `5d72b82` passes all 687 runtime questions on native Linux, packaged
Mac and WASM, clean analysis, 5,709 full units (eight skips), 465 focused tests
and 91 tooling controls. The new actual worksheet check nevertheless exposes
a production classification gap: `series(abs((x+1)^3),x,-1,3)` returns the correct
constant `0`, but persists a misleading `free: x` badge. The unchanged reference
requires no free variable. Original report and a visually reviewed failure
image are preserved; earlier worksheet batches and all historical checks pass.
The shared result/dependency classification is being repaired with controls.
Pages/Vercel verification of this superseded candidate is cancelled; build 20
remains on hold until the repaired production passes all final gates.

Production `cd1991d` filters formal-output badges by the computed expression and
applies the same rule during incremental series/Taylor refresh. Ordinary source
dependencies remain reactive. Five new controls cover actual cusp zero/error,
constant versus symbolic calculus, both aliases, coefficient/order edits and
badge refresh without extra CAS calls. Hosted CI passes clean analysis, 5,714
units (eight skips), 470 focused tests and 91 tooling controls; native focused
checks pass 436 with one skip. Native, packaged Mac and WASM each pass 687/687.
All 66 new actual worksheet entries pass, including the unchanged constant-series
reference. The next browser failure is a driver locator: a reviewed CSP image
shows the correct objective `1` and assignment `x=1, y=-1`; Flutter exposes the
assignment as a read-only field rather than a text node. The corrected driver
will retain independent optimum/assignment, input and visible-geometry checks.
The original driver report and image are preserved. Fresh native gallery
passes all 33 populated Apple views; final live/site/probe gates remain pending.

The isolated hosted constraint diagnostic confirms Flutter creates an empty
disabled semantic textarea before selection. A hit-tested click on its measured
Flutter parent populates the real read-only value; Copy solutions independently
matches it on desktop and phone. The complete helper `7c0f244` now follows that
proven interaction, retains the original strict field-selection negative
controls, verifies the full integer assignment and optimum, checks actual source
readback and visible geometry, and rejects browser errors. No value injection,
forced click, production change or reference adjustment is needed.

[Full immutable-bundle probe](https://github.com/CrispStrobe/CrispMath/actions/runs/37151620364)
passes 92 tooling controls, all 66 worksheet entries, four real statistics checks
and both real constraint optima. It proves exact parity with validated production
`cd1991dd3ab2408ef7bc47334c156b36372a9c93`: 368 files, fingerprint
`66b34f42dc4df8b0d371e50e0c9b49567d2bc7a37ac9b4e17d33e92f2f8c475f`.
All four selected final Apple graph/notepad images are visually reviewed. Full
feature CI also passes release/debug checks, all four paired performance gates
and twelve populated web views. Final deployed and beta gates follow below.

## Final hosted and deployed verification

| Gate | Hosted run | Verified result |
| --- | --- | --- |
| Full feature validation | [37148985902](https://github.com/CrispStrobe/CrispMath/actions/runs/37148985902) | Clean analysis; 5,714 units, eight skips; 470 focused tests; 91 tooling controls; release/debug browser; four paired performance gates; twelve web views |
| Native Linux corpus | [37148985883 native job](https://github.com/CrispStrobe/CrispMath/actions/runs/37148985883/job/111278677430) | 687/687; all previous 637 and fifty new cases; zero unsupported; 436 focused tests, one skip |
| Packaged macOS | [37149045651](https://github.com/CrispStrobe/CrispMath/actions/runs/37149045651) | 687/687; packaged CAS, matrix, exact Taylor and OCR checks |
| Final WASM and actual UI | [37151622061](https://github.com/CrispStrobe/CrispMath/actions/runs/37151622061) | 687/687; 350 worksheet entries, 26 incremental edit states, 14 statistics checks and two constraint checks |
| Immutable-bundle probe | [37151620364](https://github.com/CrispStrobe/CrispMath/actions/runs/37151620364) | 92 tooling controls; 66 new worksheet entries, four statistics and two constraint checks; exact validated production parity |
| Published Pages | [37151623602](https://github.com/CrispStrobe/CrispMath/actions/runs/37151623602) | 687/687; 350 worksheet entries, 26 edit states, 14 statistics and two constraint checks; exact deployed source |
| Published production Vercel | [37151625320](https://github.com/CrispStrobe/CrispMath/actions/runs/37151625320) | 687/687; 350 worksheet entries, 26 edit states, 14 statistics and two constraint checks; exact deployed source |
| Native Apple gallery | [37149047636](https://github.com/CrispStrobe/CrispMath/actions/runs/37149047636) | 33 populated views: eleven each iPhone/iPad/macOS; four selected graph/worksheet images visually reviewed |

Gallery resolutions are 1290×2796, 2048×2732 and 2560×1800. Native capture
boot/drive phases are bounded, with streamed logs and owned-process cleanup.
Additional compatibility builds pass Linux, Windows, Android, web and unsigned
iOS. They do not establish physical-device behavior.

All production is `cd1991d`; final driver/deployment helper `7c0f244` retains
identical production. Tiny JSONs, selected PNGs, initial failed reports and
frozen reference hashes are kept on stage16 cold storage; app binaries and full
galleries stay in hosted artifacts. Cleanup moves 53 cold root-disk files
(97,084,601 bytes) and 248 older fast-disk evidence files (15,592,905 bytes), with
SHA256 verification and readable symlinks. It pauses before low-memory work;
remaining candidates, current evidence, source/config/toolchains and other
projects remain intact. No local builds, test batches or Playwright runs occur.

## Signed build 20 and external TestFlight

[Signed upload](https://github.com/CrispStrobe/CrispMath/actions/runs/37152766933)
packages helper source `7c0f24475081d748cd947398d94c82cd180ef7cb`, version
1.2.0 (20), after every final gate passes. Bundle privacy/version/signature and
validated production parity pass before upload. Apple processing is `VALID`,
and Internal Testers is assigned.

[External verification/submission](https://github.com/CrispStrobe/CrispMath/actions/runs/37153462920)
confirms build UUID `11d2c137-1b71-42d2-8399-2e0bc6b66f87`, beta review
`APPROVED`, Public Beta assignment and external state `IN_BETA_TESTING` at the
existing [public TestFlight link](https://testflight.apple.com/join/E6HdVhTx).
Apple's submittedDate is null; no submission or approval date is inferred.
No App Review submission occurs. Physical Apple, actual Siri/Files-provider,
two-device cloud checks, handwriting accuracy and Apple's 4.3(a) finding remain
open. Beta approval does not establish those checks or resolve App Review.

The fifty frozen references remain byte-identical to `3bc82de`. All three
initial mathematical failures, the actual worksheet classification defect and
the discovered parser-budget regressions are closed with shared fixes and
positive/negative controls. Diagnostic-only probes remain separately labelled;
the final complete probe and both deployed runs pass full coverage.
