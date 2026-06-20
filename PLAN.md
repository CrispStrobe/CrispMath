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
  TODO: upload GGUF files to HuggingFace `cstr/` repos, quantize
  DeepSeek-OCR2 (Q4_K, Q8_0).

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
| 5b. MoE document OCR | ✅ | DeepSeek-OCR2 (3B MoE, Apache-2.0), desktop-only, F16 only |

**Models on HuggingFace**: `cstr/pix2tex-mfr-gguf` (F32/F16/Q8_0/Q4_K)

**Remaining**:
- [x] ggml graph decoder — merged, 27x speedup, 0.99+ cosine parity.
- [x] Bundle CrispEmbed native lib per platform — PR merged, CI fixed.
- [x] Register CrispEmbed OCR provider at startup.
- [~] Handwritten math: Cloud LLM provider done. On-device CROHME
  fine-tune pending (needs GPU for training).

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
