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

**The bet**: notepad mode + CrispAssist reposition CrispCalc from
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
  Platform dirs + CMakeLists/podspec/build.gradle done
  (PR CrispStrobe/CrispEmbed#1). Linux build verified — .so bundled.
  Remaining: merge PR, test macOS/iOS/Windows/Android builds.
- [ ] **iOS smoke test.** Not run since recent changes.

### Tier 2 — High-value features

- [~] **CrispAssist (verifier-frontend, never solver).** LLM translates
  input → engine syntax, narrates step traces, explains results.
  Hard guardrail: LLM never asked "what's the answer." Pluggable
  provider (Claude/OpenAI/on-device); user supplies API key.
  Service layer done: CrispAssistService with OpenAI + Anthropic API
  support (streaming SSE), CrispAssistConfig, settings in AppState,
  settings UI card in SettingsScreen. "Explain" on history help modal
  + notepad result menu. "Narrate" on steps dialog. "AI Translate"
  toolbar button on notepad (natural language → engine syntax).
  Remaining: testing with live API key.
- [~] **Inline LaTeX input.** Toggle wired in notepad overflow menu.
  Flag persisted per-doc. Live LaTeX preview now renders below input
  lines when flag is on and input contains LaTeX syntax. Needs
  interactive testing on device (verify preview with ReorderableListView
  drag-reorder, line height changes).
- [ ] **Handwritten math OCR.** Apple VisionKit (iOS), or pix2tex
  fine-tune on CROHME dataset. Printed math OCR already working.

### Tier 3 — Polish + completeness

- [x] **Function Reference i18n.** DE/FR/ES complete — 11 logic-category
  entries (eq/ne/lt/le/gt/ge/and/or/not/xor/if_cond) added to all 3
  locales. 562 localization tests pass.
- [~] **Accessibility V2.** Ctrl/Cmd+1-6 tab navigation added. Calculator
  keypad already has full keyboard input + semantics labels. Notepad has
  Ctrl+Z/Y undo/redo + Ctrl+F search. Remaining: more icon semanticLabels.
- [x] **PDF export.** `exportToPdf()` renders notepad as multi-page A4
  PDF via `package:pdf` + `printing`. Menu item wired in notepad.
- [x] **Crash reporting (opt-in).** CrashReporter ring buffer (20 max),
  email + GitHub issue actions, Settings card shows only when errors
  exist. No data leaves device without explicit user action.
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
| 3. Cloud LLM | planned | User-supplied API key, shares CrispAssist infra |
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
- [~] Bundle CrispEmbed native lib per platform — platform dirs
  created (PR CrispStrobe/CrispEmbed#1). Linux verified. Remaining:
  merge PR, test macOS/iOS/Windows/Android builds.
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
