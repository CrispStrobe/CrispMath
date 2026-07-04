# CrispCalc — Plan

Living worklist. `[ ]` pending · `[~]` in-progress · `[x]` done.
Completed items with details are in `HISTORY.md`.

---

## Strategic context (June 2026)

**Five paradigms** in the 2026 calculator category: (1) OS-bundled
calculator+notes, (2) notepad/natural-language, (3) AI math
solvers, (4) graphing, (5) scientific/power-user.

**CrispCalc's position**: competitive-to-ahead on scientific/power-user
with unique CAS+CSP+stats+units+cross-platform breadth. Behind on
input paradigm (notepad shipped June 2026) and AI (CrispAssist shipped).

**The bet**: notepad mode + CrispAssist reposition CrispCalc from
"strongest engine nobody knows about" to "only CAS-grade calculator
with a 2026 input surface."

---

## CAS depth roadmap (July 2026)

Goal: close the gap between CrispCalc's symbolic core and what users
of professional CAS software expect. The breadth story (units, dates,
stats, number theory, linear algebra, plotting, notepad) is already
competitive; the depth gaps are simplification, integration, series,
ODEs, systems, and inequalities. Ordered stages C1–C4 (numbering kept
separate from the app-worklist tiers below).

**Ground truth (verified 2026-07-04).** `simplify` and `factor` are
*real* since bridge `59ba08c` / math-stack `9b4b3c0c`: simplify =
SymEngine `simplify()` + univariate rational cancellation; factor =
FLINT `fmpz_poly_factor` (univariate ℤ) + `fmpz_mpoly_factor`
(multivariate, native only — aborts under wasm32, gated). `integrate`
never touches SymEngine (no C-API binding; the engine-side
implementation is the pure-Dart StepEngine rule walker + Simpson
fallback). No series/taylor binding, no ODE solver, no symbolic
system solver, no inequality solver.

### C1 — Truthfulness + verified regression corpus

- [x] **Stale-claim sweep.** Code comments describing simplify/factor
  as expand-aliases updated to the real wrapper behavior (2026-07-04).
- [x] **CAS regression corpus.** 58 expression → operation → expected
  cases, every expected value certified by an independent open-source
  CAS (`tool/cas_corpus_verify.py`, SymPy). Two runners: pure-Dart
  subset in `flutter test`, full corpus against native SymEngine via
  `integration_test/cas_corpus_native_test.dart -d macos`. Found and
  fixed two real bugs on day one (near-integer truncation in 7 result
  formatters; SymbolicLimit blind to complex-formatted evaluate
  output). Known gaps are enforced expected-failures (`knownGap`).
  Details in HISTORY.md 2026-07-04.
- [ ] **Honest capability signaling.** Where an operation returns a
  weaker-than-asked result (e.g. simplify can't reduce trig
  identities), the UI/docs must say so rather than imply success.

### C2 — Bind what SymEngine already has (needs xcframework rebuild)

- [x] **`series` / `taylor`.** Landed 2026-07-04: wrapper
  `flutter_symengine_series` (math-stack feat/series-linsolve), bridge
  1.4.0 `series()` + `hasSeries`, engine + calculator dispatch
  (`taylor(f,x,x0,n)` / `series(f,x,n)`), function reference (4
  locales), 5 SymPy-certified corpus cases. Native only; WASM exports
  still pending (web gated off via hasSeries=false).
- [x] **`linsolve`.** Landed 2026-07-04 alongside series:
  `linsolve(eq1; eq2, x, y)` (alias `solvesys`), exact symbolic
  solutions in symbol order, 3 corpus cases. Same WASM caveat.
- [ ] **Fill the empty binary-function FFI table** in the bridge
  (`symbolic_math_bridge_io.dart` — "none implemented in your C
  wrapper"): atan2, log-base, nroot, …
- [ ] **Re-enable disabled backends** in math-stack: WITH_LLVM (fast
  repeated numeric eval for plotting), WITH_ARB (rigorous ball
  arithmetic). WITH_ECM/PRIMESIEVE only if the ~90-bit factorint cap
  starts to bite.

### C3 — Grow the pure-Dart mathematics (no native rebuild)

- [ ] **Rational-function integration** (Hermite reduction +
  Lazard–Rioboo–Trager on the exact `Rational`/`Polynomial` stack).
  Complete algorithm for a whole input class; composes with the
  existing rule walker.
- [ ] **ODE solving, education subset.** First order: separable,
  linear, exact, Bernoulli. Second order: constant coefficients
  (homogeneous + undetermined coefficients). Pattern-based `dsolve`,
  step-by-step traces like the existing StepEngine.
- [ ] **Polynomial inequality solving.** Root isolation (already
  have) + sign analysis → interval answers:
  `solve(x^2-4>0)` → `x < -2 ∨ x > 2`.
- [ ] **Identity simplification pass** layered over engine output:
  Pythagorean/angle trig identities, log/exp rules, radical
  denesting. Pure Dart, since the native core won't do this well.

### C4 — Platform + surface parity

- [ ] **Arbitrary precision on web.** MPFR/FLINT compile under
  Emscripten; extend the WASM build so `evalf`/number theory stop
  being native-only.
- [ ] **User-defined functions V2.** Multi-letter names, multiple
  parameters, piecewise; today UDFs are single-letter/single-arg.
- [ ] **Plot types.** Parametric + polar + implicit 2D; contour lines
  and hidden-surface handling in the 3D surface view.

**Non-goals** (documented so nobody starts them casually): a complete
decision-procedure integrator (Risch), Gröbner-basis general
polynomial-system solving, and a full assumptions facility. These are
multi-year CAS-team projects; for queries beyond the local engine,
CrispAssist remains the escape hatch (as verifier/frontend).

---

## Open work items (priority order)

### Tier 1 — Ship blockers

- [ ] **Distribution pipeline.** Apple Developer enrollment +
  notarization + TestFlight/App Store. Android via Play. **Load-bearing
  prerequisite** for everything below to reach users.
- [x] **Bundle CrispEmbed native lib per platform.** PR merged. CI
  builds all 8 targets (Linux/macOS/Windows/iOS/Android×3 + Flutter
  bundle). All green.
- [x] **iOS smoke test.** CI build passes (deployment target bumped
  to 15.0 for CrispEmbed). All 7 CI workflows green.

### Tier 2 — High-value features

- [x] **CrispAssist (verifier-frontend, never solver).** Complete:
  streaming SSE, Anthropic + OpenAI support, provider preset chips,
  Explain/Narrate/Translate UI. 29 unit + 8 mock + 4 live tests.
  Live-tested: Scaleway ✅ Mistral ✅ (correct engine syntax).
- [~] **Inline LaTeX input.** Feature-complete: controller (105 lines),
  live-preview widget (127 lines), 12-stage LaTeX→engine converter
  (331 lines), 59+ unit tests. Wired into Calculator, Graphing,
  Curve Analysis, Function Editor screens. Needs device testing.
- [~] **Handwritten math OCR (cross-platform).** Three-tier approach:
  1. **Cloud LLM** (done): CloudLlmOcrProvider sends images to
     Claude/GPT-4V for handwritten + printed recognition. Cross-
     platform, auto-registered as Tier 3 provider.
  2. **On-device HMER** (DenseNet+GRU, 13 MB Q4_K): registered.
  3. **On-device BTTR** (DenseNet+Transformer, 4–25 MB): registered.
  All on-device models use CrispEmbedOcr (same FFI, model-type
  auto-detected from GGUF). CROHME benchmarked (all 986 test images):

  | Model | Raw match | Parsed match | Size (Q8_0) |
  |-------|-----------|--------------|-------------|
  | BTTR | 49.2% | **49.8%** | 13 MB |
  | HMER | 36.1% | **36.3%** | 7 MB |
  | pix2tex | 28.8% | **34.3%** | 31 MB |

  "Parsed match" = after `latexToEngineSyntax` normalizes both sides.
  10-round iterative failure analysis gained **87 new matches** (+29
  BTTR, +25 HMER, +33 pix2tex) via brace-balanced `\frac`/`\sqrt`,
  space-tolerant subscripts, Greek differentials, bare-arg functions,
  non-greedy captures, `\ldots`, trig powers, BPE normalization.
  Results: `/mnt/storage/crohme_eval/results_v2.jsonl`.
  **Future providers**: Poe, Langdock, Requesty (keys available).
- [x] **ggml graph decoder.** Merged to CrispEmbed main. 27x speedup
  via single-thread optimization. Cosine >0.99 on all test images,
  all argmax tokens identical. Validated with Q4_K on 5 math images.
- [x] **MiniZinc solver (dart_csp_fzn).** CLI binary + FlatZinc parser
  + solver all implemented in dart_csp. Notepad `fzn:` prefix works
  (18 tests pass). CLI tested with boolean + N-queens problems.

### Tier 3 — Polish + completeness

- [x] **Function Reference i18n.** DE/FR/ES complete (562 tests pass).
- [x] **Accessibility V2.** Keyboard nav (Ctrl+1-6) + ~225 icon
  semanticLabels across 24 files. Calculator keypad has full keyboard
  input + semantic labels. Notepad has Ctrl+Z/Y + Ctrl+F.
- [x] **Accessibility V3.** High-contrast theme (thick card borders,
  ColorScheme.highContrastDark/Light). Configurable text scale
  (80%–150%) via MediaQuery.textScaler. Both in Settings, persisted.
- [x] **PDF export.** Multi-page A4 via `package:pdf` + `printing`.
- [x] **CSV history export.** JSON/CSV format toggle in export dialog.
- [x] **Statistics clipboard paste.** Paste buttons on Descriptive
  and Regression data TextFields for quick CSV/clipboard import.
- [x] **Matrix eigenvalues/eigenvectors.** Pure-Dart QR algorithm
  with Hessenberg reduction, closed-form 2x2, complex eigenvalue
  support. Buttons in matrix editor (eigenvalues + eigenvectors).
  11 tests.
- [x] **Crash reporting (opt-in).** Ring buffer + email/GitHub issue.
- [x] **Perf instrumentation.** PerfOverlay (Ctrl+Shift+P toggle).
- [x] **Symbolic limit.** Tiers 1-4 complete. Gruntz-style growth-rate
  analysis handles exp/log/poly dominance at infinity (~300 lines).

### CrispEmbed integration — June 2026 batch

Four features from CrispEmbed to integrate into CrispCalc, in order:

- [x] **1. MixTex model catalog.** Added MixTex (Swin-Tiny + RoBERTa,
  Chinese+English LaTeX OCR) to `ocr_model_catalog.dart`. Quantized
  F16→Q8_0 (89 MB) + Q4_K (57 MB). Published to HuggingFace
  `cstr/mixtex-zhen-gguf`. Registered in native + web provider init.
  Same `crispembed_math_ocr_init` API — auto-detected from GGUF arch.

- [x] **2. Rebuild CrispEmbed dep.** Merged feat/posformer-port→main
  (78 commits). Pinned pubspec ref to d0631bc. Rebuilt WASM binary
  (1.2 MB, includes MixTex). Picks up GGML graph optimizations,
  Q8_0 layout, BLAS-accelerated decoder matmuls.

- [x] **3. General OCR pipeline.** Wired `CrispOcrPipeline` (DBNet +
  TrOCR) into CrispCalc. Added `_GeneralOcrProvider` in
  `ocr_providers_init.dart` with temp-file PPM bridge. Added DBNet
  (7/12 MB) and TrOCR-small-printed (42/63 MB) to model catalog.
  Published to HuggingFace `cstr/dbnet-ic15-gguf` + `cstr/trocr-small-printed-gguf`.

- [x] **4. Surya text detector.** Created `CrispTextDetect` Dart FFI
  wrapper in CrispEmbed worktree (feat/surya-dart → main, 125c804).
  Added Surya-det models (41/23 MB) to catalog. Wired as preferred
  text detection backend (falls back to DBNet if Surya not downloaded).
  Published to `cstr/surya-det-gguf`.

### CrispCalc UI + wiring — June 2026

- [x] **5. Provider selector UI.** Rewrote OcrSettingsDialog with
  runtime provider switcher (radio-style ListTiles). Shows all 9
  catalog sections (PP-FormulaNet, Texo, MixTex, pix2tex,
  handwritten, Surya, DBNet, TrOCR, layout). No deprecated APIs.

- [x] **6. Layout-aware OCR pipeline.** Added `_LayoutOcrProvider`
  that chains RT-DETRv2 layout detection → math OCR for formula
  regions. Crops formula bounding boxes and dispatches to the
  active math provider. Non-formula regions annotated with type.
  Registered when layout model is downloaded.

- [x] **7. Tests.** 54 tests in `ocr_integration_test.dart`:
  catalog integrity (MixTex, DBNet, Surya, TrOCR, layout),
  provider registry (register, switch, available filter),
  OcrModelVariant helpers (sizeLabel, license gates),
  latexToEngineSyntax, provider switching, layout detection
  in camera flow, mock provider behavior.

- [x] **8. Provider name in handwriting dialog.** Shows active
  model name below the drawing canvas before recognition.

- [x] **9. Web OCR settings dialog.** Replaced stub with functional
  dialog: IndexedDB model browser, download/delete, provider
  selector, license gates. Works without dart:io.

- [x] **10. Document page OCR in camera flow.** Added "Document page"
  option to source picker in calculator + notepad screens.
  Auto-switches to layout provider for full-page analysis.

- [x] **11. Qwen2.5-VL catalog + dep update.** Added vision-language
  model (3B params, Q4_K=2.6 GB, Q8_0=3.9 GB) to catalog and
  settings dialog. Desktop-only. Updated CrispEmbed dep to 9811275
  (Qwen2.5-VL engine + WASM pthread fix + perf). Rebuilt WASM.
  8 new tests for VL catalog integrity.

- [x] **12. Qwen3-VL-2B + DeepSeek-OCR2 + CrispEmbed perf update.**
  Bumped CrispEmbed dep to d020054 (latest). New models:
  - **Qwen3-VL-2B** (Q4_K=1.5 GB, Q8_0=2.2 GB): smaller and faster
    than Qwen2.5-VL with DeepStack vision fusion, fused flash
    attention, backend KV cache. Registered as preferred VLM.
  - **DeepSeek-OCR2** (F16=6.4 GB): SAM-ViT + Qwen2 + DeepSeek-V2
    MoE decoder. Apache-2.0. Quantized variants pending.
  Automatic perf gains from dep bump: madvise prefetch on model load,
  fused `flash_attn_ext` in all VLM paths, per-row embedding dequant
  (saves ~655 MB in DeepSeek-OCR2), backend KV cache (no CPU-GPU
  transfer per token). Settings dialog updated with 3 new sections.
  14 new tests for Qwen3-VL + DeepSeek-OCR2 catalog integrity.
  All GGUF files uploaded to HuggingFace: `cstr/qwen3-vl-2b-crispembed-GGUF`
  (Q4_K, Q8_0) and `cstr/deepseek-ocr2-crispembed-GGUF` (Q4_K, Q8_0, F16).
  DeepSeek-OCR2 quantized via Kaggle P100 (VPS OOM at 7.6 GB RAM).

### Performance — June 2026 batch

- [x] **P1. OCR pipeline optimization.** VLM providers now receive
  color images via `recognizeRaw` (was losing info from grayscale).
  WASM bulk copy via `setRange` (was per-pixel loop, 36K–590K
  iterations). Parallel `Future.wait` for model path resolution.
  Adaptive thread count from `Platform.numberOfProcessors`. Download
  resume via `Range` header. Temp dir reuse per provider instance.
  12 RegExp patterns hoisted to top-level. Dead WASM init code removed.
  Canvas `toRgbaBytes` for VLM-ready input.

- [x] **P2. Notepad keystroke path.** Deferred JSON persistence to
  debounce timer (was serializing entire doc map + `notifyListeners`
  on every character typed). Cached `_docScopeNames`. Passed line
  index from `itemBuilder` (eliminated two O(N) `indexOf` scans).
  Cached RegExp patterns for scope substitution. Cached syntax
  highlighting TextStyle objects. Scope keys cache invalidation.

- [x] **P3. Startup + web loading.** `registerNativeLicenses` and
  `initOcrProviders` fired as `unawaited` background tasks (no longer
  block first frame). WASM preloaded with `<link rel="preload">`.
  JS loaders deferred. Fixed WASM init race condition.

- [x] **P4. Calculator + graphing + app-wide.** Calculator: single
  `setState` per keystroke (was double). Graphing: hoisted hot-loop
  RegExp (20K→1 compilations per frame), moved implicit-mul outside
  sample loop, `shouldRepaint` uses `listEquals`/`mapEquals` (was
  `.toString()`). 3D scene: debounced `_persistScene3D` (was 60 Hz
  disk writes). History: microtask-deferred serialization. OCR image
  decode: header-only `ImageDescriptor` (was full JPEG decode for
  width/height).

- [x] **P5. CrispEmbed Flutter bindings.** Fixed truncated
  `CrispembedTbsrnSrProcessDart` typedef, duplicate TBSRN/Punct
  typedefs, mangled SwinIR/SCUNet interleaved classes, SCUNet
  process signature, duplicate `TbsrnSrResult` class. Resolved
  all 4 pre-existing test failures (3621 → 3621+0).

### Test coverage — June 2026 batch

- [x] **T1. OCR utils tests.** 81 tests for `postProcessOcrText`
  and `latexToEngineSyntax` (Unicode superscripts, operators, Greek,
  sqrt, BPE markers, LaTeX commands, fractions, binomial, arrows,
  set notation, environments, real-world OCR outputs).

- [x] **T2. Analysis engine tests.** 27 new tests: input validation,
  result structure, error propagation, edge cases, polynomial
  analysis via pure-Dart fallback, AnalysisResult data class.

- [x] **T3. Numerical limits tests.** 9 new tests: `oneSidedLimit`
  for infinite/oscillatory/regular points, `limitAtInfinity` for
  oscillatory/decay/divergent/exponential functions.

- [x] **T4. Step engine tests.** 20 new tests: `partialFractions`
  steps, quadratic solve structural tests, linear solve edge cases
  (degenerate coefficient=0, no-variable, identity).

- [x] **T5. AppState persistence tests.** 51 tests (new file):
  `setTextScale` (7), `setHighContrast` (5), `exportToJson`/
  `importFromJson` round-trips (4), `persistNotepadNow` safety (2),
  plus onboarding flag tests. Fixed bug: `_textScale`/`_highContrast`
  not reset on `force: true` reload.

- [x] **T6. OCR model catalog completeness.** 14 new tests: pix2tex
  (3 variants, MIT), Texo (2, AGPL), PP-FormulaNet-L (3, Apache),
  handwritten math (7+, NC gates), sizeLabel GB boundary.

### Tier 4 — Future / speculative

- [x] **Pen / handwriting input.** DrawingCanvas (CustomPainter) +
  HandwritingInputDialog. Works on all platforms (mouse/touch/stylus).
  Exports grayscale bitmap → OCR pipeline. Wired into Calculator +
  Notepad toolbars.
- [x] **Shareable state links.** URL-encode expressions as shareable
  links (`?expr=...&tab=N`). Auto-load from URL on web. Share button
  in calculator history menu.
- [ ] **Collaborative editing.** Server infra (Firebase). V3+ scope.

### OCR — Math equation recognition

**Architecture**: DeiT encoder (12L ViT) + TrOCR decoder (6L,
post-LayerNorm). Runs on-device via CrispEmbed C++/ggml FFI.

**Status (June 2026)**: end-to-end working (printed math). All
quantizations verified. CI builds all 5 platforms.

| Tier | Status | Description |
|---|---|---|
| 1. Scaffolding | ✅ | OcrProvider abstraction, postProcessOcrText, latexToEngineSyntax |
| 2. ML Kit | planned | google_mlkit_text_recognition (Android/iOS), Apache 2.0 |
| 3. Cloud LLM | ✅ | CloudLlmOcrProvider, user-supplied API key, shares CrispAssist infra |
| 3b. General OCR | ✅ | DBNet/Surya text det + TrOCR recognition (7–63 MB) |
| 4a. Printed math | ✅ | PP-FormulaNet-L (181M), Texo-Distill, pix2tex, MixTex (CJK) |
| 4b. Handwritten math | ✅ | PosFormer (57%), BTTR (49%), HMER (36%), auto-detected from GGUF |
| 5a. Vision-language | ✅ | Qwen3-VL-2B (preferred), Qwen2.5-VL-3B (fallback), desktop-only |
| 5b. MoE document OCR | ✅ | DeepSeek-OCR2 (3B MoE, Apache-2.0), desktop-only, Q4K/Q8/F16 |

**Models on HuggingFace**: `cstr/pix2tex-mfr-gguf` (F32/F16/Q8_0/Q4_K)

**Remaining**:
- [x] ggml graph decoder — merged, 27x speedup, 0.99+ cosine parity.
- [x] Bundle CrispEmbed native lib per platform — PR merged, CI fixed.
- [x] Register CrispEmbed OCR provider at startup.
- [~] Handwritten math: Cloud LLM provider done. On-device CROHME
  fine-tune pending (needs GPU for training).

### Code quality — June 2026

- [x] **Q1. Zero `flutter analyze` issues.** Migrated deprecated
  `onReorder` → `onReorderItem` in notepad_screen.dart and
  scene_3d_screen.dart. Removed old-style newIndex adjustment in
  `withReorderedObjects`. Replaced `print` with `stdout.writeln`
  in tool/parse_latex.dart. Result: 0 errors, 0 warnings, 0 infos.

### Code quality — July 2026

- [x] **Ans full-precision chaining.** `8/3` → `Ans*3` returned
  `8.00000000001` because `Ans` substituted the rounded display
  string. Now: `CalculationEntry.rawResult` keeps the unrounded
  engine string (Ans + memory-store use it), fallback emits 15
  significant digits (parity with native SymEngine), Auto display
  rounds to 12. Details in HISTORY.md 2026-07-03.
- [x] **DST-safe date arithmetic.** DateTimeEvaluator dates are UTC
  midnights; `days between` across spring-forward no longer loses a
  day.
- [x] **Local Flutter 3.38.5 → 3.44.4.** Required by the
  `onReorderItem` migration (Q1 above). Post-upgrade: `flutter clean`
  before `flutter test` (stale shader artifacts fail widget tests).

### Completed (moved to HISTORY.md)

- CBJ-aware "explain failure" (Round E.2)
- Notepad V1 (8 phases) + V2 (14 features)
- Math OCR end-to-end (4 quantizations, 3.3-5.5s)
- Step engine V5 (repeated roots + trig sub)
- P6/P7 help system + logic function reference
- CrispAssist AI service + settings + UI integration
- Function Reference i18n (DE/FR/ES, 11 logic entries)
- PDF export + crash reporting + perf instrumentation
- Web build fix (conditional imports for dart:ffi/dart:io)
- App icon (∫Σ on indigo)
- CSV history export + statistics clipboard paste
- High-contrast theme + configurable text scale
- Matrix eigenvalues/eigenvectors (pure-Dart QR)
- Unit catalog + derived unit tests (20 tests)
- Eigenvalues/eigenvectors in function reference (4 locales)
- polydiv(p, q) polynomial long division + step-by-step trace
- Partial fractions standalone step-by-step
- Statistics presets tests (11) + step diagnostics tests (12)
- Intersection edge case tests (14) + notepad cycle tests (14)
- iOS deployment target 13→15 (CrispEmbed requires 15.0+)
- CI Flutter 3.38→3.44 (formatter parity with local dev)
- CI green: all 7 workflows pass (3513+ tests, format + analyze)

---

## Architecture notes (for future agents)

### Three-repo chain
```
math-stack-ios-builder → symbolic_math_bridge → CrispCalc
```
- **math-stack**: builds SymEngine + GMP/MPFR/FLINT into
  xcframeworks (iOS/macOS) or shared libs (Android/Windows/Linux/WASM)
- **symbolic_math_bridge**: Flutter FFI plugin wrapping the C API
- **CrispCalc**: the app, pins bridge via git ref in pubspec

### CrispEmbed integration (OCR)
```
CrispEmbed (C++/ggml) → Flutter plugin (flutter/crispembed/) → CrispCalc
```
- `math_ocr.h/cpp`: DeiT encoder (ggml graph) + TrOCR decoder (scalar)
- `qwen2vl_ocr.h/cpp`: Qwen2.5-VL + Qwen3-VL (auto-detected from GGUF arch)
- `deepseek_ocr2.h/cpp`: DeepSeek-OCR2 (SAM-ViT + Qwen2 + MoE decoder)
- `convert-pix2tex-to-gguf.py`: ONNX → GGUF with weight transpose
- Platform dirs: linux/ windows/ macos/ ios/ android/ with CI bundling

### Notepad evaluator pipeline
```
User input → classifyNotepadLine → preprocessNotepadLine →
  [DateTimeEvaluator | CurrencyEvaluator | UnitEvaluator |
   PrecisionCall | CAS dispatch | EngineService.evaluateAsync] →
  cachedResult → formatLineResult (per-line format override) → UI
```

### Key conventions
- SymEngine bridge: `DynamicLibrary.process()` on iOS/macOS (static
  link), `.open()` on Android/Linux/Windows
- WASM web bridge: `dart:js_interop` impl behind conditional import
- `preprocessNativeExpression()` runs before every engine call
  (percentage → implicit mul → factorial → mod → special functions)
- Decoder post-LN (TrOCR/BART), encoder pre-LN (DeiT/ViT)
- GGUF weight convention: transpose 2D matrices in converter so
  ggml_mul_mat produces correct results
- Feature branches for CrispEmbed/CrispASR, never commit to main
- Build on /mnt/volume1 (not CIFS), use ninja + ccache
- Large files on /mnt/storage or /mnt/volume1, never /tmp
