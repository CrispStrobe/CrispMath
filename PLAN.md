# CrispCalc — Plan

Living worklist. `[ ]` pending · `[~]` in-progress · `[x]` done.
Completed items with details are in `HISTORY.md`.

---

## Strategic context (May 2026)

**Five paradigms** in the 2026 calculator category: (1) OS-bundled
calculator+notes, (2) notepad/natural-language, (3) AI math
solvers, (4) graphing, (5) scientific/power-user.

**CrispCalc's position**: competitive-to-ahead on scientific/power-user
with unique CAS+CSP+stats+units+cross-platform breadth. Behind on
input paradigm (notepad shipped June 2026) and AI (planned).

**The bet**: notepad mode + AI copilot reposition CrispCalc from
"strongest engine nobody knows about" to "only CAS-grade calculator
with a 2026 input surface."

---

## Open work items (priority order)

### Tier 1 — Ship blockers

- [ ] **Distribution pipeline.** Apple Developer enrollment +
  notarization + TestFlight/App Store. Android via Play. **Load-bearing
  prerequisite** for everything below to reach users.
- [~] **Bundle CrispEmbed native lib per platform.** Plugin pubspec
  declares ffiPlugin for 5 platforms. CI builds the artifacts.
  Remaining: place them in platform directories + test on each OS.
- [ ] **iOS smoke test.** Not run since recent changes.

### Tier 2 — High-value features

- [ ] **AI copilot (verifier-frontend, never solver).** LLM translates
  input → engine syntax, narrates step traces, explains results.
  Hard guardrail: LLM never asked "what's the answer." Pluggable
  provider (Claude/OpenAI/on-device); user supplies API key.
- [~] **Inline LaTeX input.** Toggle wired in notepad overflow menu.
  Flag persisted per-doc. Needs interactive testing with
  ReorderableListView (LatexController changes line heights).
- [ ] **Handwritten math OCR.** Apple VisionKit (iOS), or pix2tex
  fine-tune on CROHME dataset. Printed math OCR already working.

### Tier 3 — Polish + completeness

- [ ] **Function Reference i18n.** FR+ES translations (DE done).
- [ ] **Accessibility V2.** Keyboard navigation, contrast, VoiceOver.
- [ ] **PDF export.** Needs `package:pdf`. Export model done.
- [ ] **Crash reporting (opt-in).** Sentry or email-based.
- [ ] **Perf instrumentation.** Frame-timing overlay, jank detection.
- [~] **Symbolic limit.** Tiers 1+2 done. Gruntz (tier 4) deferred.

### Tier 4 — Future / speculative

- [ ] **Pen / handwriting input.** Apple Pencil (PKCanvasView). iPad-only.
- [ ] **Shareable state links.** URL-encode calculator state for web.
- [ ] **Collaborative editing.** Server infra (Firebase). V3+ scope.
- [ ] **ggml graph decoder.** Replace scalar decoder loops (~5× for long outputs).
- [ ] **Round E.5 — dart_csp_fzn MiniZinc solver.** Needs distribution pipeline.

### OCR — Math equation recognition

**Architecture**: DeiT encoder (12L ViT) + TrOCR decoder (6L,
post-LayerNorm). Runs on-device via CrispEmbed C++/ggml FFI.

**Status (June 2026)**: end-to-end working. All quantizations verified.

| Tier | Status | Description |
|---|---|---|
| 1. Scaffolding | ✅ | OcrProvider abstraction, postProcessOcrText, latexToEngineSyntax |
| 2. ML Kit | planned | google_mlkit_text_recognition (Android/iOS), Apache 2.0 |
| 3. Cloud LLM | planned | User-supplied API key, shares AI copilot infra |
| 4. CrispEmbed | ✅ | DeiT+TrOCR GGUF, F16=3.3s, Q4_K=17MB, all correct |

**Models on HuggingFace**: `cstr/pix2tex-mfr-gguf` (F32/F16/Q8_0/Q4_K)

**CrispCalc integration**: camera button on Calculator+Notepad,
image_picker, OcrCaptureDialog, OcrSettingsDialog with model
download/delete, OcrModelManager with HF catalog.

**Key design decisions**:
- Encoder uses ggml graph (SIMD, multi-thread) for speed
- Decoder uses scalar C with cached cross-attention K/V
  (autoregressive KV-cache too complex for V1, fast enough for
  short expressions)
- Weight transpose in GGUF converter (ONNX MatMul convention →
  ggml mul_mat convention)
- TrOCR uses post-LayerNorm (BART convention), not pre-LN (ViT)
- FP16/quantized models: `to_f32()` dequant for CPU-side access,
  `ensure_f32()` ggml cast for graph binary ops, `cached_f32()`
  for decoder weight cache

**Remaining**:
- [ ] ggml graph decoder (replaces scalar loops, ~5× speedup for
  long outputs)
- [~] Bundle CrispEmbed native lib per platform — plugin pubspec
  declares ffiPlugin for all 5 platforms. CI builds the .so/.dylib/
  .dll. Remaining: place CI artifacts into the plugin's platform
  directories (linux/Libraries, macos/Frameworks, etc.)
- [x] ~~Register CrispEmbed OCR provider at startup~~ — done.
  `initOcrProviders()` auto-registers when a GGUF model is found.
  Uses `package:crispembed`'s `CrispEmbedOcr` class via FFI.
- [ ] Handwritten math: Apple VisionKit (iOS), pix2tex fine-tune
  on CROHME dataset

### Completed (moved to HISTORY.md)

- CBJ-aware "explain failure" (Round E.2)
- Notepad V1 (8 phases) + V2 (14 features)
- Math OCR end-to-end (4 quantizations, 3.3-5.5s)
- Step engine V5 (repeated roots + trig sub)
- P6/P7 help system + logic function reference

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
- `convert-pix2tex-to-gguf.py`: ONNX → GGUF with weight transpose
- Feature branch: `feature/math-ocr-inference` (merged to main)

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
