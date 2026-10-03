# Fifth independent 50-problem audit

Two agents freeze 25 algebra/calculus and 25 numeric/statistical/unit/constraint
questions with hand-derived references before inspecting app output. Algebra
freshness review replaces two prior questions with new derived references;
numeric input review finds no duplicates. Answers are never adapted to results.

- [Algebra references](round5-math-algebra.md)
- [Numeric references](round5-math-numeric.md)
- Fixtures: `test/fixtures/round5_{algebra,numeric}_tasks.json`.

## Initial findings

[Linux/WASM audit](https://github.com/CrispStrobe/CrispMath/actions/runs/37100677075)
uses source `ac0c9db4f6a082dc970a8b959fb8d1275e6c56ac`. Both runtimes pass
49/50 new questions: all 25 algebra cases and 24 numeric cases. The sole failure
is `1 kN/m² in bar`: actual null, expected `0.01 bar`. All preceding 413 runtime
checks remain green. The numeric pure-Dart reference unit test exposes the same
missing unit; other module reference answers pass.

The initial live harness passes all 18 actual desktop/phone worksheet entries,
before and after reload. These cover exact rational roots, mixed polynomial and
squared-denominator integrals, scaled logarithm/cosine limits, function expansion
under global-variable collisions, and conjugate multiplication. Numerical
quadrature remains labeled approximate; an exact request requires the exact
rational answer. [Packaged macOS](https://github.com/CrispStrobe/CrispMath/actions/runs/37100680485)
confirms the same 49/50 result with nativeBridge=true: all algebra cases pass,
and the sole numeric failure is the missing bar target.

## Repair and controls

Add bar as a pressure unit with SI scale 100000 Pa. Existing prefix synthesis
and compound parsing then support mbar/kbar and bar/s. Preserve Pa as canonical
SI pressure formatting. Eleven focused controls check the scale/dimensions,
forward/reverse conversions, prefixes, signed values, mixed-pressure addition,
compound rates, mismatched dimensions and longer unknown words.

The existing 50 reference answers remain unchanged. Add three actual worksheet
controls for `bar=7`, `m=2`, and `1 kN/m^2 in bar`: globals must not substitute
unit syntax or produce false free-variable badges; magnitude, target dimensions,
unit-conversion evidence and persistence/reload are asserted.

## Validation and further worksheet scope finding

The bar-only candidate `758a37d92ed01e782299ad7e37ea7e7d5d877c39` passes
[Linux/WASM](https://github.com/CrispStrobe/CrispMath/actions/runs/37101090839),
[full analysis/unit/browser/gallery](https://github.com/CrispStrobe/CrispMath/actions/runs/37101092689),
[packaged macOS](https://github.com/CrispStrobe/CrispMath/actions/runs/37101141319),
[Pages](https://github.com/CrispStrobe/CrispMath/actions/runs/37101094597),
[Vercel](https://github.com/CrispStrobe/CrispMath/actions/runs/37101096443).
All five runtime/deployment paths pass 463/463 accumulated checks with zero
failed or unsupported cases. Native/WASM and Pages/Vercel live reports pass
106 actual desktop/phone worksheet entries. Full CI passes 5,524 unit/widget
tests (eight documented skips), analysis, focused controls and 52 tooling tests,
release/debug assertions, performance gates and the populated gallery.

Review of saved browser results reveals that a solved variable is still listed
as free. An independent [immutable-app live probe](https://github.com/CrispStrobe/CrispMath/actions/runs/37102252890)
tests `x=9`, `solve(x^2-1,x)` against that exact, already-built source. The actual
worksheet returns `evaluation:Error: solve failed`, not the reference roots ±1.
The equation and declaration had both received the global scalar. This is an
additional contextual defect despite the earlier 463-case suite being green.

Protect explicit solve declarations and their equation scope from global
substitution, dependency edges and free-variable labels. Keep coefficients and
symbols outside calls reactive. Share validated balanced-argument parsing and
equation folding between the actual dispatcher and the portable CLI.
Source inspection exposes the same substitution risk for differentiation and
indefinite integration. Protect those formal variables too, while preserving
free-variable semantics for symbolic outputs when the name is unbound. Nested
formal output cannot escape an enclosing bound scope. The supported `d/dx`
operator owns its callee fragments locally; ordinary d/dx variables stay usable.

Twelve actual dispatcher/parser/scope unit controls, six further runtime fixtures
and nine actual desktop/phone scope cases cover quadratic/rational roots,
coefficient edits, formal derivatives/antiderivatives, alias/global collisions,
malformed arguments and nested/outside variable handling. Independent references
are unchanged. One-argument solve retains its existing variable inference.

The first scope candidate `9a75885f2a6f9d939b57bfbc6825f1d5a52a1f7f`,
version 1.2.0 (16), is under hosted validation:
[Linux/WASM](https://github.com/CrispStrobe/CrispMath/actions/runs/37102999149),
[full analysis/unit/browser/gallery](https://github.com/CrispStrobe/CrispMath/actions/runs/37103000874),
[packaged macOS](https://github.com/CrispStrobe/CrispMath/actions/runs/37103002421),
[Pages](https://github.com/CrispStrobe/CrispMath/actions/runs/37103004257),
[Vercel](https://github.com/CrispStrobe/CrispMath/actions/runs/37103005938).
This candidate passes the solve controls but exposes two fixture notation
assumptions and a real badge defect: formal x is absent from the filtered input
scope even when global x=9 is available. Value results are mathematically correct;
free-variable assertions remain strict. Recognize successfully available formal
names for badges without adding substitution, dependency or accuracy inputs.
Strict monomial assertions accept exact equivalent rational coefficients while
negative controls reject changed grouping, lost C, wrong powers or coefficients.
Additional actual evaluation controls retain free x when no global is available,
including the non-indexed function/document path.

The corrected candidate `e006eaca46c3de725a23b3471df5e748117d2176` is validating
[Linux/WASM](https://github.com/CrispStrobe/CrispMath/actions/runs/37103547049),
[full unit/browser/gallery](https://github.com/CrispStrobe/CrispMath/actions/runs/37103548740),
[packaged macOS](https://github.com/CrispStrobe/CrispMath/actions/runs/37103550327),
[Pages](https://github.com/CrispStrobe/CrispMath/actions/runs/37103552270),
[Vercel](https://github.com/CrispStrobe/CrispMath/actions/runs/37103554143).
Native/WASM and packaged macOS each pass all 469 runtime checks. Full unit CI
passes 5,535 tests with eight documented skips and 52 tooling tests; actual
browser checks pass 124 desktop/phone entries. These green checks prompted a
further lifecycle review before release.

Incremental edits deliberately do not make a derivative/antiderivative depend
on its formal variable's global scalar. Consequently, removing, renaming or
invalidating that scalar could leave the cached availability badge stale.
Refresh only formal-name badge metadata after evaluation using final available
scope names. Preserve symbolic cached results, evidence and CAS call counts;
do not add value dependencies. A regression checks rename/failure/removal and
restoration. Real desktop/phone UI controls perform seven binding edits per
viewport and assert the persisted badges, unchanged values and evidence.

The incremental app candidate `29273367886684638798575dec2050746752aacc` runs:
[Linux/WASM](https://github.com/CrispStrobe/CrispMath/actions/runs/37104038979),
[full unit/browser/gallery](https://github.com/CrispStrobe/CrispMath/actions/runs/37104040407),
[packaged macOS](https://github.com/CrispStrobe/CrispMath/actions/runs/37104042094),
[Pages](https://github.com/CrispStrobe/CrispMath/actions/runs/37104043517),
[Vercel](https://github.com/CrispStrobe/CrispMath/actions/runs/37104044832),
[fresh native Apple gallery](https://github.com/CrispStrobe/CrispMath/actions/runs/37104046317).
This app source passes all 469 native/macOS checks and 5,536 unit/widget tests
with eight skips. The new live helper successfully observes renamed globals and
updated badges, then incorrectly expects an error for incomplete `x=1+` input.
Actual persisted state correctly has no result/error and free x on both formal
rows. Correct the helper to assert that typing state and add balanced invalid
`x=diff(1)` to exercise a genuine evaluation error, preserving the references.
An immutable-app [corrected scope probe](https://github.com/CrispStrobe/CrispMath/actions/runs/37104713678)
passes against the unchanged production bundle: eighteen baseline scope entries
and seven edits per desktop/phone layout (fourteen successful edit states).
Only test-helper code changes in `1afa020`; native capture source remains `2927336`.
Final validation uses exact source `1afa020420871204fbda9fec577ee3c908d59015`:
[Linux/WASM](https://github.com/CrispStrobe/CrispMath/actions/runs/37104828561),
[full unit/browser/gallery](https://github.com/CrispStrobe/CrispMath/actions/runs/37104830979),
[packaged macOS](https://github.com/CrispStrobe/CrispMath/actions/runs/37104832830),
[Pages](https://github.com/CrispStrobe/CrispMath/actions/runs/37104834439),
[Vercel](https://github.com/CrispStrobe/CrispMath/actions/runs/37104836066).
All five final runs pass. Linux native, WASM, packaged macOS, Pages and Vercel
pass 469/469 accumulated runtime checks. Native/WASM and both published sites
pass 124 actual desktop/phone entries plus fourteen binding edit states, with
strict badges, mathematical values, evidence and reload checks. Full CI passes
5,536 unit/widget tests (eight documented skips), 52 tooling tests, analysis,
release/debug assertions, performance gates and the populated twelve-scene web
gallery. Hosted UI edit medians for 500/2,000-row documents are 0.536/0.956 s
on desktop and 1.790/5.049 s on the CPU-throttled phone profile; all four
performance gates pass. These are browser edit latencies, not physical-device
frame-rate measurements.

The fresh native gallery passes all 33 populated captures, eleven per platform:
iPhone 1290×2796, iPad 2048×2732 and native macOS 2560×1800. Native CAS/content
assertions pass. Three macOS images are visually reviewed; iPhone/iPad manifests
and calculation evidence are inspected. Full images remain in remote artifacts.
Capture source is `2927336`, preserving accurate provenance; `1afa020` changes
only the live test helper. All captures explicitly report physicalDeviceTest=false.

## Apple delivery

[Signed build-16 release](https://github.com/CrispStrobe/CrispMath/actions/runs/37105698802)
uses the successful final feature validation `37104830979` and frozen source
`1afa020420871204fbda9fec577ee3c908d59015`. All 52 tooling tests pass.
The actual signed bundle has photo-library/camera purpose strings and correct
version 1.2.0/build 16. Its publication gate confirms browser/gallery success,
361 production files and the identical source/dependency fingerprint
`ac39680cf22f3929d21777539595d66446ea125983c605db981e2f51e7e05d7f`.
Upload succeeds; Apple processing is VALID and Internal Testers are assigned.

[External TestFlight verification](https://github.com/CrispStrobe/CrispMath/actions/runs/37106359044)
confirms the actual beta submission APPROVED, internal/external IN_BETA_TESTING
and Public Beta assigned. Build/submission ID is
`1b484f10-8f35-4311-b549-28c22289b8a4`; Apple returns no submission timestamp.
The [public beta](https://testflight.apple.com/join/E6HdVhTx) now offers build 16.
The corrected core-local/optional-connected description is retained. No second
binary upload or App Review submission occurs during external verification;
physical tests remain deferred and guideline 4.3(a) remains unresolved.

## Truthful TestFlight metadata

The existing English beta description claimed all computation runs on-device,
although the app offers optional connected AI and cloud sync. An explicit
metadata-only path changes only that description, explaining core local
calculations and optional configured connected services. Meaningful API fixtures
cover preserved custom notes/other locales/privacy fields, wrong or changed
builds, an ignored patch, ambiguous English locales and idempotent retry.

[Metadata-only CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37100740297)
passes all 52 release-tool tests before preparing the key or writing to Apple.
Read-back comparison confirms exactly one changed field: the en-US beta
localization description. Existing build notes, locale attributes, groups and
submission records are unchanged. Uploaded build 15/source `39c3591` remains
VALID, beta review APPROVED and internal/external IN_BETA_TESTING. Tool and API
verification source is `ac0c9db`; `metadataOnly` and
`betaDescriptionUpdateVerified` are true. No binary upload or App Review
submission occurs in this metadata run.

## Execution scope and boundaries

All builds, unit/runtime corpora, browser checks and native capture run on hosted
GitHub CI. The shared VPS performs small edits, remote status queries and report
inspection only. Large app bundles/models are retained remotely; local downloads
are limited to small reports and reviewed screenshots.

Physical iPhone/iPad checks remain deferred. Real Supabase/two-device validation
needs credentials; handwriting quality needs better trained weights. External
beta approval does not resolve Apple's earlier guideline 4.3(a) rejection.

The follow-up cold-artifact audit archives two unopened OCR files to CIFS and
reclaims a further 18.33 MiB from root. Original paths remain readable symlinks;
SHA-256 source/destination/symlink reads match. The manifest is
`/mnt/storage/moved_from_root/2026-10-03-crispmath-ocr-followup/manifest.jsonl`.
Active reports, source/toolchains and other projects are untouched.
