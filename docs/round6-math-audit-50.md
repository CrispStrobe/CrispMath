# Sixth independent mathematical audit

Fifty questions and their hand-derived references were frozen before observing
CrispMath outputs: [algebra references](round6-math-algebra.md) and
[numeric references](round6-math-numeric.md). The two fixtures retain their
original inputs, expected values and tolerances from frozen reference commit
`9a21290ae4a703730749bbd364350e31a6f5c8b6`. Eighteen additional controls
exercise undefined derivatives, Taylor series at and away from a cusp,
non-x variables, rounding-alias scope and reactive worksheet series routing;
these supplement the fifty.

Initial [native/WASM CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37107577290)
and [packaged macOS CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37107578938)
passed 39/50 on native/macOS and 40/50 on WebAssembly. WebAssembly already
rejected the unequal directional limit that
native incorrectly represented as an unevaluated derivative. Complete macOS
and browser reports preserve all 519 accumulated cases; the initial native
focused-test failure skipped the first two fifty-case batches, so its report
covers 419 cases rather than claiming full baseline coverage.

| Finding | Underlying cause and correction |
| --- | --- |
| Negative rational floor/ceiling printed floating complex values | Route bounded rational rounding through BigInt arithmetic before CAS conversion; preserve exact integers beyond double precision. |
| Huge finite samples returned infinite mean, median or SD | Share compensated scaled moments, stable interpolation and independently computed SD across statistics and hypothesis tests; variance and sums may honestly overflow when unrepresentable. |
| `deg` conversion failed | Share the degree alias between the unit catalog and inline parser, preserving dimension checks and variable/unit syntax. |
| Quadratic objective rejected | Reuse exact polynomial grammar and finite-domain constraint machinery for bounded nonlinear objectives, retaining constraints and explicit complexity guards. |
| Multivariate quotient remained uncancelled | Exact bounded multivariate polynomial division retains the original denominator restriction, including removed holes. |
| Convergent sqrt/log endpoint integrals failed | Use analytic antiderivative endpoint limits with affine real-domain validation, reversed-bound controls and divergent-pole rejection. |
| Oscillatory vanishing limit returned a small approximation | Prove a vanishing polynomial amplitude times bounded real sin/cos tends to zero; do not snap small samples to zero. |
| Absolute-value limit fabricated a derivative expression | Reject unevaluated derivative/substitution limit outputs and independently check two-sided real samples. |
| Point differentiation and Taylor coefficients at a cusp | Share point-aware absolute-value derivative and multiplicity checks with production Taylor series. |
| Scaled and shifted cusp proofs declined valid inputs | Restore explicit multiplication in polynomial coefficients before exact point evaluation, including rational coefficients. |
| Taylor code accepted unevaluated formal coefficients | Prove the local polynomial branch away from affine absolute-value cusps; reject formal Derivative/Subs outputs in both native and fallback series. |
| Correct ceiling result displayed an unresolved-function badge | Register the existing ceiling alias in shared worksheet reserved names, preserving argument dependencies and incremental recomputation. |
| Working CLI Taylor series was unavailable in actual worksheets | Route explicit series/taylor calls through one validated parser and the existing engine operation; bind only the formal expression/declaration and retain coefficient, center and order dependencies. |
| Correct Taylor result retained a shifted unsimplified basis | Normalize only bounded exact polynomial results for readable output; preserve unsupported expressions and domain-sensitive rational forms. |
| Constant-leading pure Dart polynomials lost a non-x variable | Preserve the parser’s tracked variable on the final coefficient vector for all public polynomial operations; reject foreign identifiers before Taylor normalization, with y/t and absent-variable controls. |
| Taylor expansion failed for coefficients involving another variable | Prove bounded polynomial expressions constant in the requested variable before native dispatch; preserve their actual symbols and reject invalid centers or unsupported forms. |

The audit itself was hardened before fixes: nonzero numeric comparisons are
relative even at tiny scales, material imaginary components cannot disappear
under an absolute tolerance, scientific exponent signs remain numeric tokens,
and reports encode nonfinite diagnostics explicitly without losing failures or
subsequent tasks. Negative controls prove the comparator rejects zero in place
of a nonzero tiny probability and materially complex values.

These repairs deliberately prove bounded cases: exact polynomial division,
affine real sqrt/log endpoint families, polynomial envelopes times bounded
sin/cos, affine absolute-value cusps and single-variable polynomial Taylor
coefficients. Negative controls retain domain failures, divergent poles,
unequal directional limits, malformed arguments and complexity limits. Other
expressions continue through the existing CAS; this audit does not certify every
possible mathematical input.

Live tests also found a catalog synchronization race: replacing a one-result
search with another leaves the old semantic label briefly visible. The harness
now waits for the actual expected title, description and stable identifier,
while preserving strict content assertions and timeout diagnostics.

The final tested source is `73ca7815dd3b875e93a46f9dd3004ccb3b735550`.
Hosted verification passes all 537 accumulated runtime cases on Linux, WASM,
packaged macOS, Pages and production Vercel, including the unchanged fifty fresh
references. Actual desktop/phone browser checks pass 160 worksheet entries,
four statistics-screen checks and eighteen binding-edit states. Full validation
passes 5,599 unit/widget tests (eight skips), 52 tooling checks, clean analysis
and 355 focused regressions. Release/debug browser checks, all four
performance gates and twelve web-gallery scenes pass. Hosted 500/2,000-row edit medians are 0.623/1.275 s
on desktop and 1.749/4.598 s on the CPU-throttled phone profile. These
measure browser edit latency, not physical-device frame rate. Evidence: [Linux/WASM](https://github.com/CrispStrobe/CrispMath/actions/runs/37112739802),
[full feature validation](https://github.com/CrispStrobe/CrispMath/actions/runs/37113332090),
[packaged macOS](https://github.com/CrispStrobe/CrispMath/actions/runs/37112742016),
[Pages](https://github.com/CrispStrobe/CrispMath/actions/runs/37112766100) and
[production Vercel](https://github.com/CrispStrobe/CrispMath/actions/runs/37112767632).
Fresh populated native screenshots pass in
[Apple gallery CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37112800752): 33 captures, eleven each on iPhone
(1290×2796), iPad (2048×2732) and native macOS (2560×1800). Four selected
notepad/graph images are visually reviewed as populated and legible; full
artifacts remain remote. The manifests record the exact source and explicitly
identify simulator captures rather than physical-device testing.

[Signed build 17](https://github.com/CrispStrobe/CrispMath/actions/runs/37114719521)
passes the privacy-string, signature, version/build and actual live-validation
gates. Its 363 production files match the tested source, SHA-256 fingerprint
`cdc0789fa5dc2a87558aa81da4a77a2ced2db253fd97486755b1fcdc93ce115a`.
The upload succeeds, Apple processing is VALID and Internal Testers are assigned.
[External TestFlight verification](https://github.com/CrispStrobe/CrispMath/actions/runs/37115481288)
confirms the actual build-17 submission APPROVED, Public Beta assigned and both
internal/external states IN_BETA_TESTING. Build UUID is
`7cef584d-5e72-48a5-80f4-fb05c1d9f341`; Apple's submission date is null, so
no timestamp is inferred. The [public beta](https://testflight.apple.com/join/E6HdVhTx)
now offers 1.2.0 (17). No App Review submission is made.

No local app builds, corpus runs or browser batches run on the shared VPS.
Physical-device checks remain deferred to a separate session. The earlier Apple
App Review 4.3(a) finding is not resolved by these mathematical fixes.
