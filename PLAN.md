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

## Open work items (priority order)

### Tier 1 — Ship blockers

- [ ] **Distribution pipeline.** Apple Developer enrollment +
  notarization + TestFlight/App Store. Android via Play. **Load-bearing
  prerequisite** for everything below to reach users.
- [~] **Bundle CrispEmbed native lib per platform.** PR merged to
  main. CI bundle-flutter job fixed (artifact v7 + Windows Release/
  path). Remaining: verify CI goes green, then cross-platform test.
- [ ] **iOS smoke test.** Not run since recent changes.

### Tier 2 — High-value features

- [~] **CrispAssist (verifier-frontend, never solver).** Service layer
  complete with streaming SSE, Anthropic + OpenAI support. Settings UI,
  Explain/Narrate buttons, AI Translate in notepad menu. 29 unit tests
  + 8 integration tests with mock HTTP server.
  Remaining: obtain API key and test live end-to-end.
- [~] **Inline LaTeX input.** Live preview wired. Needs device testing.
- [~] **Handwritten math OCR (cross-platform).** Printed OCR working
  via CrispEmbed (DeiT+TrOCR GGUF). Handwritten needs a cross-platform
  solution. Options evaluated:
  1. **Tesseract/MLKit** — printed only, no math layout understanding
  2. **pix2tex fine-tune on CROHME** — train on handwritten dataset,
     run via CrispEmbed GGUF (same pipeline). Best cross-platform path.
  3. **Apple VisionKit** — iOS/macOS only, not cross-platform
  4. **Cloud LLM** — send image to Claude/GPT-4V via CrispAssist
     infra. Cross-platform, requires API key + network.
  **Decision: pix2tex CROHME fine-tune (option 2) for on-device,
  Cloud LLM (option 4) as fallback.**
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
- [x] **PDF export.** Multi-page A4 via `package:pdf` + `printing`.
- [x] **Crash reporting (opt-in).** Ring buffer + email/GitHub issue.
- [x] **Perf instrumentation.** PerfOverlay (Ctrl+Shift+P toggle).
- [~] **Symbolic limit.** Tiers 1+2 done. Gruntz (tier 4) deferred.

### Tier 4 — Future / speculative

- [ ] **Pen / handwriting input.** Cross-platform drawing canvas via
  Flutter CustomPainter (all platforms) + Apple Pencil PKCanvasView
  (iPad). Captured strokes → bitmap → OCR pipeline.
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
| 3. Cloud LLM | planned | User-supplied API key, shares CrispAssist infra |
| 4. CrispEmbed | ✅ | DeiT+TrOCR GGUF, F16=3.3s, Q4_K=17MB, all correct |

**Models on HuggingFace**: `cstr/pix2tex-mfr-gguf` (F32/F16/Q8_0/Q4_K)

**Remaining**:
- [x] ggml graph decoder — merged, 27x speedup, 0.99+ cosine parity.
- [x] Bundle CrispEmbed native lib per platform — PR merged, CI fixed.
- [x] Register CrispEmbed OCR provider at startup.
- [ ] Handwritten math: pix2tex CROHME fine-tune (on-device) +
  Cloud LLM fallback (cross-platform via CrispAssist).

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
- CI green (3358 tests, format + analyze + test)

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
