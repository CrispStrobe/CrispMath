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
unit target `kg*m/s` rejected as null. Shared root causes are being traced;
Packaged Mac also passes 47/50 with the same three failures. WebAssembly
passes 47/50 (24/25 algebra and 23/25 numeric): factorial works there, but
`solve(x^2-2*I*x-2,x)` reports solve failure rather than the frozen complex
roots. Thus four distinct questions fail on at least one platform. All previous
587 runtime questions pass on all three. Initial JSONs remain on stage15 cold
storage with source/run IDs. Final cross-platform and live results are pending. Positive and negative
regression controls and actual desktop/phone and Pages/Vercel checks follow. All builds, app execution, analysis and test batches run on hosted
CI. Only small reports and selected screenshots are downloaded to cold storage.

Physical iPhone/iPad tests remain deferred. Handwriting accuracy, real
Siri/Files-provider and two-device cloud checks, and Apple's 4.3(a) App Review
rejection remain separate open items. Build 18 remains the approved public beta
until a changed production build has passed all gates and delivery verification.

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

Three app regression files and strict independent UI comparison controls are
ready for hosted verification. Live tests enter66 new worksheet cases across
desktop/phone and the real normal-CDF form twice. Its six-decimal-place display
checks routing and geometry; finer accuracy is certified by frozen runtime
references and module regressions, not by the rounded screen.
