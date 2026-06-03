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

## Open work items

### P1 — Native limit (in progress)

- [~] Pure-Dart symbolic limit engine (`symbolic_limit.dart`) ships
  tiers 1+2 (direct substitution + L'Hôpital for 0/0). Numerical
  fallback remains as tier 3. Gruntz algorithm (tier 4) deferred.

### P4 — Production-readiness

- [ ] **Distribution pipeline.** Apple Developer enrollment +
  notarization + TestFlight/App Store. Android via Play. Load-bearing
  prerequisite for reach.
- [ ] **Crash reporting (opt-in).** Sentry self-hosted or email-based.
- [ ] **iOS smoke test.** Not run since recent changes.
- [ ] **Perf instrumentation.** Frame-timing overlay, jank detection.

### P5 — Notepad V2/V3

Notepad V1 (8 phases) is complete. V2 features shipped in June 2026:
percentages, subtotals, headings, syntax highlighting, per-line
format, autocomplete, date/time, inline plots, collapsible sections,
undo/redo, search, left-rail, templates, currency, cross-doc refs,
drag-drop, Markdown/LaTeX export, line pinning.

**Still open:**

- [~] **Inline LaTeX input.** `useLatexInput` flag on NotepadDocument
  persisted. Actual LatexController integration needs interactive
  testing with ReorderableListView.
- [ ] **PDF export.** Needs `package:pdf`. Structured export model
  (`notepad_export.dart`) is done.
- [ ] **Collaborative editing.** Server infrastructure (Firebase/
  Supabase). V3+ scope.

### P5 — AI copilot

- [ ] **Verifier-frontend, never solver.** LLM translates input and
  narrates output; SymEngine + step engine remain the only sources of
  arithmetic. Three jobs:
  - Job 1 — Translate: natural language → engine syntax
  - Job 2 — Narrate: step trace → prose explanation
  - Job 3 — Explain: "what does this result mean?"
  - Hard guardrail: LLM never asked "what's the answer"
  - Pluggable provider (Claude/OpenAI/on-device); user supplies key

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
- [ ] Bundle CrispEmbed native lib per platform (macOS/Linux/
  Windows/Android/iOS) — needed for the FFI provider to load
- [ ] Register CrispEmbed OCR provider at app startup once native
  lib is bundled
- [ ] Handwritten math: Apple VisionKit (iOS), pix2tex fine-tune
  on CROHME dataset

### Other open items

- [ ] **Pen / handwriting input.** Apple Pencil via PKCanvasView +
  MLHandwritingRecognizer. iPad/Mac-only.
- [ ] **CBJ-aware "explain failure" mode.** Surface MUS from
  dart_csp's conflict-directed backjumping on unsat CSP results.
- [ ] **Round E.5 — Bundle dart_csp_fzn as MiniZinc solver.**
  Needs distribution pipeline (notarization) first.
- [ ] **Shareable state links.** URL-encode calculator state for
  the web build.
- [ ] **Accessibility V2.** Keyboard navigation audit, contrast
  verification, VoiceOver/TalkBack pass.
- [ ] **Function Reference i18n.** FR+ES translations (DE done).

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
