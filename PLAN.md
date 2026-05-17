# CrispCalc — Repair & Completion Plan

Living document. Each task: `[ ]` pending · `[~]` in-progress · `[x]` done.
Completed items are moved (with date) to `HISTORY.md`.

See `HISTORY.md` for the most recent work: 60 new unit tests covering plane,
conic, numerical helpers and full AppState persistence; the calculator
history clear button; persistent history / variables / graph functions;
and the light/dark/system theme picker.

---

## P1 — Open follow-ups

- [x] ~~Make `CrispCalc` repo public.~~ Done 2026-05-17 — see HISTORY.
- [ ] **Native `limit`.** The native bridge doesn't expose a `limit`
  entry point and SymEngine itself doesn't ship a general
  `limit(f, x, a)` — there's nothing to bind to yet. To unblock, work
  has to land in the bridge's C++ layer first, then a one-line Dart
  binding follows. Three tiers, increasing effort:
  1. **Series-based**: use SymEngine's `series_n` to compute a Taylor
     expansion at the point and return the constant term. Handles
     analytic functions with finite limits. Misses `sin(x)/x`, most
     transcendental ratios.
  2. **L'Hôpital loop**: handcrafted in C++ over SymEngine's `diff`
     and `subs`. Handles 0/0 and ∞/∞ for ratios; iterates until the
     limit is determinate or a step budget is hit. Covers the common
     calculus-textbook cases.
  3. **Gruntz algorithm**: full general limit-finding. Real CAS
     engineering — port from SymPy's reference implementation. Wide
     coverage but a multi-week project.
  Numerical one-sided / infinity limits (`lib/engine/numerical.dart`)
  stay as the safety net regardless of which tier ships. Native
  `integrate` was bound similarly — see HISTORY round 7.
- [x] ~~**`flutter build macos --release`: SymEngine wrapper symbols dropped.**~~
  Fixed 2026-05-17 — see HISTORY round 13. Bridge plugin now uses an
  `+load` keepalive with an asm-clobber `DoNotOptimize` loop over every
  `flutter_symengine_*` function pointer. Release builds keep all 45
  wrapper symbols.
- [ ] **iOS smoke test.** Not run since the recent changes.

## P2 — Engine + native bridge

- [ ] **High-precision evaluation.** `SymbolicMathBridge.evaluateWithPrecision`
  / `gmpPower` / `mpfrHighPrecisionPi` still throw — wire them when the
  C++ wrapper exposes the corresponding symbols.
- [x] ~~**Matrix arithmetic end-to-end.** Confirm `det(Matrix([[…]]))`,
  `inv(...)`, `transpose(...)` round-trip cleanly through the engine
  with a release SymEngine build.~~ Done 2026-05-17 — see HISTORY
  round 16. Required a new `MatrixEvaluator` that routes matrix
  expressions through the FFI matrix bindings (SymEngine's text
  parser doesn't recognize `Matrix(...)` literals). 6/6 self-test
  checks pass in the release build; trigger them with the
  `CRISPCALC_DIAGNOSTIC=matrix` env var or via Settings → "Matrix
  self-test".

## P2 — UX polish

- [x] ~~**More translations.** German is up to date; Spanish / French
  would be cheap follow-ups.~~ Done 2026-05-17 — see HISTORY round 17.
  Full FR and ES locales (~95 strings each) plus a per-locale
  non-emptiness test suite (20 checks) so missing strings would fail
  CI rather than a runtime UI lookup.
- [x] ~~**Variable substitution dialog** — no more typing `subst(...)`.~~
  Done 2026-05-17 — see HISTORY round 14.
- [x] ~~**Plot annotations** — mark extrema and roots on the graph
  when an analysis is open.~~ Done 2026-05-17 — see HISTORY round 15.
  Toggleable from the graphing screen toolbar; uses numerical scan
  with bisection / parabolic refinement so no SymEngine round-trip
  per point.

## P3 — Long tail

- [x] ~~Symbolic Gauss / RREF on matrices.~~ Done 2026-05-17 — see
  HISTORY round 19. `rref(...)` is wired into the matrix evaluator,
  the keypad, and the self-test battery; the canonical 2×3 textbook
  example reduces correctly in release.
- [x] ~~CI: GitHub Actions to run `flutter analyze` + `flutter test` on PR.~~
  In place since round 8 (`.github/workflows/ci.yml`). Round 18 also
  switched the macOS build workflow to `--release` and added a
  headless matrix-diagnostic step, so the bridge plugin's release
  symbol-keep regression risk is caught in CI now.
- [x] ~~History view filtering / search.~~ Done 2026-05-17 — see
  HISTORY round 14.

---

## P4 — Production-readiness (gaps for a real release)

Things that matter once real users install the app, separate from any
single feature. Roughly in priority order — top items unblock the next.

### Operability

- [ ] **Crash reporting (opt-in)**. Today a release crash on a user's
  device is invisible to us. Add a privacy-respecting crash reporter
  (Sentry self-hosted, or just a "send a crash log" button that emails
  the report rather than uploading silently). Opt-in only — keeps the
  "no telemetry" promise from the About screen honest.
- [ ] **Storage hardening**. History persists via `shared_preferences`
  which has no size guarantees and is the wrong tool for a growing log.
  At minimum: LRU cap on history entries. Better: move to `sembast` or
  `sqflite`. Also: export-to-file (JSON / LaTeX / PDF) so the user can
  back up before reinstall.
- [ ] **Distribution pipeline**. macOS and iOS builds are unsigned, so
  the App Store / TestFlight / hardened-runtime paths aren't open. Apple
  Developer enrollment + notarization workflow + automatic version
  bumping on tag. Same shape for Android via Play.
- [ ] **Long-evaluation off-main-thread**. Big integrals or matrix ops
  can freeze the UI for several seconds. Wrap bridge calls in a Dart
  isolate (or at least `compute()`) and show the progress overlay
  (`lib/widgets/progress_overlay.dart` already exists, just isn't wired
  in for engine calls).

### Quality

- [ ] **UI flow tests**. Widget tests today cover "app boots." Every
  calculator gesture — enter expression, tap solve, store as variable,
  open substitute dialog, run analysis — has zero test coverage. A
  button rename can break a flow without CI flagging it. Add coverage
  for the 10 most-used flows.
- [ ] **Integration tests via `integration_test` package**. The
  matrix-diagnostic env-var hack is a stand-in for what should be a
  real integration suite that drives the actual UI in CI. Once the
  package is in place, port the matrix battery and add flows that the
  widget tests can't easily exercise.
- [ ] **Golden tests for plot painter + LaTeX rendering**. Subtle
  regressions in those two surfaces are invisible until a user
  complains. Pixel-comparison goldens in CI catch them deterministically.
- [ ] **Accessibility audit**. Add `Semantics` widgets to keypad
  buttons, label every IconButton, verify keyboard navigation for the
  full settings flow, audit color contrast in both themes, test with
  VoiceOver / TalkBack. Currently the keypad is a wall of unlabeled
  buttons to a screen reader.

### User experience

- [ ] **Real error messages**. A student typing `det(x)` gets
  "Error: evaluate failed: SymbolicMathException: evaluate - parse
  failed". Replace with plain-language explanations + the offending
  fragment underlined + a fix suggestion. Map the common error classes
  (parse error, dimension mismatch, missing variable, etc.) to
  curated messages.
- [ ] **Onboarding tour**. First launch shows a 4-card tour: keypad
  tabs, history scroll, function picker, analysis hub. Skippable.
  Discoverable features stop being a problem.
- [ ] **User documentation**. The README is a developer README. Add a
  user-facing docs site (or in-app help screen) listing every supported
  function with one-line examples, the LaTeX↔engine mapping table, and
  the matrix syntax cheatsheet. The function index alone is a
  high-traffic page elsewhere.
- [ ] **Share / export**. Copy a result as LaTeX. Share a calculation
  via the platform share sheet. Export the history (or a selection) as
  PDF for homework hand-in.

### Polish

- [ ] **Localize the picker dialogs**. `IntegralDialog`,
  `LimitDialog`, `NthRootDialog`, `SubstituteDialog` are still
  hardcoded English. The DE/FR/ES infrastructure is in place; this is
  mechanical — move strings to `AppLocalizations` and remove the
  `const Text('Limit')` literals.
- [ ] **Perf instrumentation**. Frame-timing overlay in debug, jank
  detection in CI for one canonical flow, repeatable benchmark for the
  graph painter at common viewport sizes. Currently we don't know if
  CrispCalc feels sluggish on a low-end Android device.

---

## P5 — Differentiation (where competing calculator apps win today)

Where the category bar is set higher than our current feature set.

### Learning / "how do I do this" features

- [ ] **Step-by-step solutions**. The dominant feature of solver-style
  apps: show *why* a derivative or integral is what it is, not just the
  answer. Realistic path: instrument `differentiate` / `integrate` /
  `solve` in the bridge to also return the rule sequence (chain rule,
  product rule, u-substitution, etc.) and render it in the UI as an
  expandable steps list.
- [ ] **Worked-example library**. Curated catalogue of problem types
  (related rates, optimization, vector projection, eigenvalue) with
  click-to-try examples. Discoverability + learning.
- [ ] **Plain-language step explanations**. After a step is shown
  symbolically, render a one-sentence English/DE/FR/ES description of
  the rule applied. Accessibility win and pedagogical win.

### Input

- [ ] **Photo OCR of handwritten or printed equations**. Camera input
  is table-stakes for the consumer-grade math-help category. Possible
  on-device with TFLite or Apple's `VisionKit` (iOS only); cloud OCR
  is faster to ship but conflicts with our on-device promise.
- [ ] **Pen / handwriting input**. Apple Pencil + macOS trackpad
  handwriting recognition (`PKCanvasView` + `MLHandwritingRecognizer`)
  for math expressions. Niche but high-end feature.

### Math surface area

- [ ] **Statistics + probability module**. Descriptive stats on a list
  of numbers, linear / polynomial / exponential regression, normal
  /binomial /t /chi-square distributions and quantiles, basic
  hypothesis tests. Standard on graphing calculators, currently absent.
- [ ] **Unit-aware arithmetic**. `5 km / 30 min in mph`, `1 mile + 5 ft`,
  full SI prefix handling. Killer feature for engineering / physics
  users.
- [ ] **3D graphing**. Surface plots, parametric 3D curves, intersection
  with planes (we already have plane analysis). Touch-rotate / pinch-
  zoom on the 3D canvas.
- [ ] **User-defined function namespace**. Today's graph slots Y1..Y10
  are a partial story. Allow named functions (`f(x) = x^2 + 1`),
  composition (`g(f(x))`), and a tab to browse / edit / rename them.

### Engagement / sharing

- [ ] **Interactive parameter sliders**. Replace constants in a graphed
  function with named parameters, attach a slider widget per parameter,
  drag to animate the curve. Single biggest "wow" feature in modern
  graphing calculators.
- [ ] **Shareable links / state encoding**. URL-encode the full
  calculator state (graphed functions, viewport, stored variables) so
  a teacher can drop a link in a class chat and the student lands on
  the same view.
- [ ] **Web build**. Flutter Web + a WASM build of SymEngine widens
  reach 10x (instant-try from any browser, embeddable in textbooks /
  docs sites). Significant porting work but plausible — the bridge
  plugin would need a WASM backend.

---

## Out of scope this round

- C++ implementation of symbolic `limit` and `integrate`.
- Rewriting the LaTeX↔engine parsing as a real grammar.
- Full accessibility audit.
