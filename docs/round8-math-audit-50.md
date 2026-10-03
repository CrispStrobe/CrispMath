# Eighth independent mathematical audit

Fifty questions and independent references were frozen at
`26c751eb8b5de09bd0376fb76fabb54726262106` before observing app outputs: [algebra/calculus](round8-math-algebra.md) and
[numeric/statistics/units/constraints](round8-math-numeric.md). Each fixture
contains 25 questions. Prior exact duplicates are replaced before the joint
freeze; their replacements are documented in the reference drafts. References
remain unchanged after the first app observation.

The accumulated runtime corpus now contains 637 questions. The initial [native/WebAssembly run](https://github.com/CrispStrobe/CrispMath/actions/runs/37136327061)
and [packaged Mac run](https://github.com/CrispStrobe/CrispMath/actions/runs/37136328622)
are preserved. Native passes 47/50 new problems (25/25 algebra, 22/25 numeric)
and all previous 587. Three failures are an unchanged factorial quotient,
normal CDF 0.25249247216358117 instead of 0.2524925375469229, and valid compound
unit target `kg*m/s` rejected as null. Packaged Mac also passes 47/50 with the
same three failures. WebAssembly
passes 47/50 (24/25 algebra and 23/25 numeric): factorial works there, but
`solve(x^2-2*I*x-2,x)` reports solve failure rather than the frozen complex
roots. Thus four distinct questions fail on at least one platform. All previous
587 runtime questions pass on all three. Initial JSONs remain on stage15 cold
storage with source/run IDs. Positive and negative
regression controls and actual desktop/phone and Pages/Vercel checks follow below.
All builds, app execution, analysis and test batches run on hosted
CI. Only small reports and selected screenshots are downloaded to cold storage.

Physical iPhone/iPad tests remain deferred. Handwriting accuracy, real
Siri/Files-provider and two-device cloud checks, and Apple's 4.3(a) App Review
rejection remain separate open items. Build 19 is now the verified approved
public beta after all production gates and delivery checks pass.

## Shared repairs and bounds

- Factorial calls and postfix notation use the exact constant grammar, including
  arithmetic and nested arguments. Nonnegative integer arguments are capped at
  2048 before iteration; each multiplication retains the existing bit budget.
  Symbolic, undefined and excessive arguments decline exact certification.
- Normal CDF and direct survival probabilities share bounded incomplete-gamma
  evaluation. Standardization and density avoid preventable overflow; quantile
  bisection uses bounded standardized coordinates and direct upper tails.
  Wilcoxon hypothesis tests use the same direct survival API. Independent
  controls include representable tails at z=8/9/10 and a 1e-100 quantile.
- Composite unit targets accept contiguous products and left-associative
  divisions, prefixes and squared/cubed dimensions. Parsing is bounded to
  sixteen factors and 1024 characters, rejects offset-unit products and
  nonfinite scales, and retains dimension mismatch errors.
- A shared Gaussian-rational linear/quadratic solver avoids backend-specific
  complex coefficient failures. Source, depth, node, exponent, degree and
  coefficient allocation bounds apply. Variable denominators and unknown
  coefficients decline this route; existing source-domain handling remains.

Four app regression files and strict independent UI comparison controls
cover these repairs. Live tests enter 70 new worksheet cases across
desktop/phone, four reactive trace edit states and the real normal-CDF form twice.
Its six-decimal-place display
checks routing and geometry; finer accuracy is certified by frozen runtime
references and module regressions, not by the rounded screen.

The first repaired candidate passed all 637 runtime calculations on packaged
Mac, but focused/full units found leading-coefficient cancellation could resize
a fixed-length buffer. That valid equation declined solving; growable bounded
coefficient buffers now handle vanishing degrees, with additional controls.
The new actual worksheet checks also preserved a real trace badge defect:
`trace(Matrix([[-2,1],[0,3]]))` computed exact 1 but retained free name `trace`.
Evaluation and worksheet classification now share one matrix unary-operation
registry. Tests retain free argument dependencies and reject assignment
shadowing, while unknown calls stay visible. Actual reactive trace edits verify
dependent recomputation and restoration.

Final production source is c02ae7b2ff37ee76da5de2acfdfe9f0c2ea5a515;
helper-only d6319e67d79cfdb6eb2eb40e006271c562a65bd5 retains identical production
source. The production tree contains 368 files with SHA256 fingerprint
`862243195034f245e44e3fc881a9a26a982f561709f29a96a913158ce305b5af`.

## Final verification

[Full feature CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37138935788)
passes clean analysis, 5,677 unit/widget tests (eight skips), 433 focused
regressions, release/debug browser checks and twelve populated web views.
[Native Linux/WebAssembly](https://github.com/CrispStrobe/CrispMath/actions/runs/37138931799)
and [packaged Mac](https://github.com/CrispStrobe/CrispMath/actions/runs/37138933578)
each pass all 637 accumulated runtime questions, including all fifty new ones.
The same-host worksheet performance gates pass: desktop 500/2000 rows take
550.80/959.26 ms against limits 1600.44/3555.72 ms; CPU-throttled phone 500/2000
rows take 2121.62/6649.33 ms against limits 8918.45/41989.71 ms. These are hosted
browser measurements, not physical-device timings.

[Pages live checks](https://github.com/CrispStrobe/CrispMath/actions/runs/37139286564)
and [production Vercel](https://github.com/CrispStrobe/CrispMath/actions/runs/37139288891)
pass. Both deployments pass all 637 runtime questions, 284 actual worksheet
entries, 26 edit states and ten actual statistics-screen checks.
The [immutable-bundle probe](https://github.com/CrispStrobe/CrispMath/actions/runs/37139929279)
passes 77 tooling controls and production parity, plus 70 new worksheet entries,
four reactive trace edits and two Normal CDF screens.
[Native Apple gallery](https://github.com/CrispStrobe/CrispMath/actions/runs/37139012893)
passes 33 populated views: eleven each on iPhone/iPad simulators and native Mac.
Four selected graph/worksheet images are visually reviewed.

[Signed build 19](https://github.com/CrispStrobe/CrispMath/actions/runs/37143330448)
passes bundle privacy/version/signature checks, validated production parity,
upload and Apple processing (`VALID`), with Internal Testers assigned.
[External beta verification](https://github.com/CrispStrobe/CrispMath/actions/runs/37144064147)
confirms build UUID `a2e86e31-bf31-429c-bc93-2a83f1afd2dc`, beta review `APPROVED`
and Public Beta assignment with external state `IN_BETA_TESTING`.
Apple returns a null submitted-date field; no approval date is inferred.
[Public TestFlight](https://testflight.apple.com/join/E6HdVhTx) now includes build 19.
No App Review submission or physical-device verification occurred.

The first final-source iOS gallery attempt stalled after successful simulator
boot, CocoaPods and Xcode compilation, before any VM-service driver connection,
test-start marker or screenshot. After 45 minutes of capture, we cancelled it
and preserved the completed log plus tiny partial manifest/simulator JSON on
cold storage. We retried only the iOS job on a fresh hosted runner at the same
c02 source, retaining the successful native Mac gallery. The interrupted attempt
is recorded separately. The same-source retry succeeds: VM-driver connections
occur 30 seconds after
the iPhone build and 27 seconds after the iPad build, and actual native tests
pass in 50/49 seconds. The verifier confirms 22 iOS images. No product or
assertion changes were needed for this infrastructure retry; the precise cause
of the first connection stall is not established.
