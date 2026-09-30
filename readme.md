# CrispMath — CAS Calculator

A cross-platform scientific and graphing calculator built with Flutter. It
features an adaptive UI (mobile bottom-nav / desktop side-rail / wide-screen
split-view) and is powered by the SymEngine Computer Algebra System for
symbolic math.

Free and open source (AGPL-3.0 with App Store exception). Available on
[iOS](https://apps.apple.com/app/crispmath/), web
([crisp-math.vercel.app](https://crisp-math.vercel.app)), macOS, Android,
Linux, and Windows.

## Core Features

- **LaTeX display:** Textbook-style rendering of expressions and history via
  `flutter_math_fork`. Inline LaTeX input with live preview, 12-stage
  LaTeX→engine converter.
- **Symbolic CAS engine:** Algebra and calculus operations, not just numerical
  calculations.
  - Solver: `solve(x^2 - 4, x)` returns `x = {-2, 2}`.
  - Calculus: symbolic differentiation (`d/dx`), symbolic limits (Gruntz-style
    growth-rate analysis at infinity), Taylor/Maclaurin series
    (`taylor(f, x, x0, n)` / `series(f, x, n)`).
  - Algebraic: `factor` (univariate + multivariate via FLINT), `expand`,
    `simplify` (rational cancellation + trig identities), `gcd`, `lcm`,
    linear-system solve (`linsolve(eq1; eq2, x, y)`).
  - Numerics: `factorial`, `fibonacci`, constants `π`, `e`, `γ`.
  - Matrix: `det`, `inv`, `transpose`, `rref`, `eigenvalues`, `eigenvectors`
    (pure-Dart QR algorithm with Hessenberg reduction).
- **Interactive graphing:** Y1..Y10 function slots, pan + pinch-to-zoom, axis
  labelling, curve sketching (Kurvendiskussion), root & extrema annotations,
  parameter sliders, curve tracing (tap/drag or arrow keys), value tables with
  TSV/CSV clipboard export, editable independent axis bounds, finite-value fit
  and a 20-change undo history. Fit uses the current x interval and trims the
  outer 2% of samples to avoid isolated poles dominating the y range.
- **Notepad:** Multi-line evaluator with variables, cross-references,
  subtotals, date/time arithmetic, currency conversion (44 currencies),
  inline mini-plots, collapsible sections, templates, Markdown/LaTeX export.
  Link an expression line to a graph slot; document scope updates the graph,
  and its source dialog opens the document or detaches the expression.
- **Statistics:** Descriptive stats, linear/polynomial/exponential regression,
  normal/binomial distributions, 9 hypothesis tests (t-test, ANOVA,
  chi-square, Fisher's exact, sign test, Wilcoxon). Clipboard paste for data.
- **Unit conversion:** 6 base dimensions + 5 derived SI units (N, J, W, Pa, Hz),
  composite-dimension arithmetic (`100 m / 10 s → 10 m/s`), SI prefix system.
- **Constraint solver:** FlatZinc parser + solver (Sudoku, N-queens, boolean
  SAT). Notepad `fzn:` prefix for inline constraint problems.
- **CrispAssist:** AI verifier (never solver) via streaming SSE. Anthropic +
  OpenAI compatible. Explain/Narrate/Translate actions.
- **Math OCR:** On-device DeiT+TrOCR (printed) + HMER/BTTR (handwritten) via
  CrispEmbed ggml FFI. Cloud LLM fallback (Claude/GPT-4V). Camera + pen input.
- **Adaptive layout:**
  - `< 720 px` — bottom navigation bar (mobile).
  - `720–1199 px` — side rail (tablets / narrow desktop windows).
  - `≥ 1200 px` — side rail plus a secondary pane so calculator + graph (or
    calculator + analysis) can be shown at the same time.
- **Command search:** The global Search commands button and Ctrl/Cmd+K find
  screens, tools and function examples. Arrow keys select; Enter opens a result.
- **Accessibility:** High-contrast theme, configurable text scale (80%–150%),
  keyboard navigation (Ctrl+1-6), ~225 semantic labels, full keyboard input.
- **Localization:** English, German, French, Spanish (EN/DE/FR/ES) with
  complete function reference translations.
- **Export/Import:** PDF, Markdown, LaTeX, JSON (full state), CSV (history).
  Shareable URL links (`?expr=...&tab=N`).

## Cloud Sync & Optional Math Assistance
- **Supabase Cloud Sync:** Sync AppState (variables, history, notepad, graphs) seamlessly across devices. Features robust merging to prevent data loss.
- **Math assistance:** Deferred provider-backed natural-language translation on native and web. Configure a full chat-completions or messages endpoint, model and API key in CrispAssist settings. The assistant supports cancellation, timeout and retry, and lets you edit the expression before sending it to the calculator. Keyless local endpoints are supported; browser endpoints must allow CORS. Configuration is not a claim that a model connection has been verified.
- **Advanced Graphing:** Vector Fields and plotting enhancements.
- **Notepad PDF Export:** Print or save complete interactive math sessions to PDF.

## Architecture

Three layers:

1. **Flutter UI** (`lib/screens`, `lib/widgets`) — renders the keypad,
   captures input, displays results. No knowledge of FFI.
2. **`CalculatorEngine`** (`lib/engine/calculator_engine.dart`) — Dart facade
   over the `symbolic_math_bridge` plugin. Every method returns a `String` so
   the UI can treat errors and successes the same way. When the native bridge
   isn't loaded (e.g. under `flutter test` on the host), every method returns
   `'Error: <op> requires native library'` instead of crashing.
3. **`symbolic_math_bridge`** (separate package) — Flutter FFI plugin that
   wraps the SymEngine C API.

```mermaid
graph LR
    A[Flutter UI] --> B[CalculatorEngine]
    B --> C[symbolic_math_bridge / FFI]
    C --> D[SymEngine C++ library]
```

## Project layout

```
CrispMath/
├── lib/
│   ├── main.dart                       # App entry, adaptive shell, settings
│   ├── controllers/
│   │   └── latex_controller.dart       # Cursor-aware LaTeX text controller
│   ├── engine/
│   │   ├── app_state.dart              # Singleton: history, variables, fns
│   │   ├── calculator_engine.dart      # Bridge facade
│   │   ├── analysis_engine.dart        # Curve sketching pipeline
│   │   ├── eigen.dart                  # Eigenvalue/eigenvector (QR algorithm)
│   │   ├── matrix_evaluator.dart       # Matrix ops (det/inv/rref/eigen)
│   │   ├── statistics.dart             # Descriptive stats + regression
│   │   ├── unit_expression.dart        # Unit arithmetic + SI derived
│   │   ├── notepad_evaluator.dart      # Multi-line notepad pipeline
│   │   └── symbolic_limit.dart         # Gruntz-style limit engine
│   ├── localization/
│   │   └── app_localizations.dart      # i18n strings (en/de/fr/es)
│   ├── screens/
│   │   ├── calculator_screen.dart      # Calc keypad + display
│   │   ├── graphing_screen.dart        # Plotter
│   │   ├── function_editor_screen.dart # Y= editor
│   │   ├── analysis_hub_screen.dart    # Module picker
│   │   ├── curve_analysis_input_screen.dart
│   │   ├── curve_analysis_results_screen.dart
│   │   └── matrix_editor_screen.dart
│   ├── utils/
│   │   ├── expression_preprocessing_utils.dart  # Implicit-* / mod / Y(x) inlining
│   │   ├── latex_conversion_utils.dart          # LaTeX <-> engine syntax
│   │   ├── math_display_utils.dart              # Result formatting
│   │   └── keyboard_input_handler.dart          # Hardware-keyboard mapping
│   └── widgets/
│       ├── calculator_keypad.dart      # Tabbed keypad
│       ├── calculator_button.dart      # Single key
│       ├── keypad_grid.dart            # Layout grid
│       ├── latex_input_field.dart      # Live LaTeX-rendered input
│       ├── function_picker_dialogs.dart
│       ├── memory_dialogs.dart
│       ├── progress_overlay.dart
│       ├── variable_viewer.dart
│       └── calculator_display.dart
├── test/                               # Unit tests (no native bridge needed)
├── PLAN.md                             # Open work items
├── HISTORY.md                          # Completed work log
└── pubspec.yaml
```

## Building and running

```bash
flutter pub get
flutter test            # ~4018 unit tests run without the native bridge
flutter run             # Runs the app; SymEngine bridge required for math
tool/build_web.sh --release  # Also compiles the browser math worker

# CAS regression corpus (SymPy-certified expected values):
python3 tool/cas_corpus_verify.py                        # certify + regenerate
flutter test test/cas_corpus_test.dart                   # pure-Dart fallbacks
flutter test integration_test/cas_corpus_native_test.dart -d macos  # native
```

The native side lives in the `symbolic_math_bridge` plugin (separate
repository, git-pinned in `pubspec.yaml`). See its README for the SymEngine
build.

## Platform support (v1.1.1)

| Platform | SymEngine bridge | Notes |
|---|---|---|
| **iOS** | ✓ full | `.xcframework` from `math-stack-ios-builder` |
| **macOS** | ✓ full | `.xcframework` from `math-stack-ios-builder` |
| **Android arm64-v8a** | ✓ full | `libsymbolic_math_bridge.so`, vcpkg+NDK build (PLAN P11 R132) |
| **Windows x86_64** | ✓ full | `symbolic_math_bridge_plugin.dll`, MSYS2/MinGW64 build (PLAN P11 R131) |
| **Linux x86_64** | ✓ full | `libsymbolic_math_bridge.so`, vcpkg `x64-linux` static build on ubuntu-22.04 / GLIBC 2.35 (PLAN P11 R130) |
| Android x86_64 / armeabi-v7a | ✗ not built | extend the bridge's build matrix when needed |
| **Web** (Vercel) | ✓ CAS via WASM | **Live: https://crisp-math.vercel.app** (PLAN P10 Path B). Full CAS core (evaluate, expand, diff, solve, substitute, trig, gcd/lcm/factorial/fibonacci, matrices) runs via SymEngine WASM (1.1 MB, `INTEGER_CLASS=boostmp`). Pure-Dart CAS interim (expand/diff/solve for single-variable polynomials) serves as synchronous pre-load fallback. MPFR precision / FLINT number-theory / Bessel not available in web build. |

Releases ship platform binaries via GitHub Actions; see GH Releases
for `crisp_math-vX.Y.Z-{macos.zip,ios-unsigned.zip,linux-x64.tar.gz,
windows-x64.zip,android.apk}`.

## Math OCR (June 2026)

On-device math equation recognition via CrispEmbed's ggml inference:
- **Printed math:** DeiT encoder + TrOCR decoder — image → LaTeX in 3.3s (FP16)
  - 4 quantization levels: F32 (112MB), F16 (56MB), Q8_0 (31MB), Q4_K (17MB)
  - Models on HuggingFace: [`cstr/pix2tex-mfr-gguf`](https://huggingface.co/cstr/pix2tex-mfr-gguf)
- **Handwritten math:** HMER (DenseNet+GRU, 13MB) and BTTR (DenseNet+Transformer, 4–25MB)
  - Model type auto-detected from GGUF by unified `CrispEmbedOcr` FFI
- **Cloud fallback:** CloudLlmOcrProvider (Claude/GPT-4V) for cross-platform coverage
- **Pen input:** DrawingCanvas on all platforms (mouse/touch/stylus) → OCR pipeline
- Camera or pen tap on Calculator/Notepad → photo/drawing → LaTeX → engine syntax
- No cloud required, no Python, no ONNX at runtime — pure C++ via FFI

## Known limitations

- `limit()` uses a pure-Dart symbolic engine (L'Hôpital + Gruntz growth-rate
  analysis) — no native SymEngine binding yet.
- Matrix eigenvalues/eigenvectors use a pure-Dart QR algorithm — works well
  for small matrices (tested up to 4x4), but not optimized for large ones.
- `simplify()` handles the core trig identities natively since bridge
  1.4.1 (Pythagorean, double angle, power reduction, secant form); broader
  identity rewriting (angle sums, half angles, radicals) is still open.
- OCR requires the CrispEmbed native library bundled per platform.
- Multivariate `factor()` uses FLINT and is not available in the web build
  (WASM `fmpz_mpoly_factor` traps).

Since 2026-07-04 the browser build runs the full CAS — including
high-precision (`evalf`), number theory (isprime/factorint/…), Bessel,
Taylor series, `linsolve`, and trig-identity simplify — via the
full-capability SymEngine WASM (GMP/MPFR/MPC/FLINT). The remaining
web-only gap is multivariate factoring (falls back to `expand`).

See `PLAN.md` for the current punch list and `HISTORY.md` for what landed
recently.

## Performance validation

Modules mount on their first visit and retain their state afterward; hidden
graphs stop scheduling samples. Graph geometry is sampled outside painting: native builds use an isolate;
web builds use a persistent browser worker with its own SymEngine WASM
instance. Gesture updates use coarse samples, then refine at rest. An
8-entry viewport cache and a 128-entry numeric expression cache are bounded.
Calculator CAS and graph sampling use separate browser workers, so cancelling
an evaluation does not interrupt the plot. Build web through
`tool/build_web.sh` so the compiled worker is included. For `flutter run -d
chrome`, first run `dart compile js -O2 -Ddart.vm.product=true
lib/services/math_worker_entry.dart -o web/math_worker.dart.js`.

Use the settings performance overlay in a profile build. It reports UI and
raster p95 work times against the display's refresh-rate budget; it does not
claim presentation FPS. Exercise graph pan/zoom with multiple functions,
implicit contours and parameter sliders; edit a large notepad; then compare
cold startup with OCR unopened. Record the device and build mode with results.
`dart run tool/benchmark_graph_sampling.dart` measures sampling CPU time only.

For browser worker transport/cancellation checks, compile
`tool/math_worker_browser_probe.dart` to `web/math_worker_probe.dart.js`, serve
`web/` over HTTP, and run `python tool/check_math_worker.py --url
http://localhost:8765/`. This optional check uses Python Playwright and accepts
`--chromium` for an existing Chromium executable. The probe is a development
artifact and is excluded from production bundles by `tool/build_web.sh`.

Notepad records are stored per document. Existing `crisp.notepadDocs` blobs
migrate automatically, retaining the old blob until migration succeeds.
Writes are ordered, edits are batched, and lifecycle pauses flush pending
changes. JSON import/export remains compatible; linked graph source IDs are included
in the optional `graphLinks` field.


## Feature validation

Build with `tool/build_web.sh --debug --no-wasm-dry-run` and serve `build/web`
over HTTP. With Python Playwright installed, start
`python tool/ai_contract_fixture.py`, then run
`python tool/check_feature_browser.py --stage 5 --url http://localhost:8766/`.
The ordered workflow checks tracing/table CSV against numeric values, linked
source edits, command navigation, bounds/fit/undo, and provider error,
cancellation, retry and calculator handoff. It saves screenshots and failure
labels. The HTTP fixture tests the provider contract, not actual model quality.
A real provider and an evaluation corpus are still needed to assess translation
quality. The Feature validation workflow runs focused regressions, the entire
unit/widget suite, and live release/debug browser checks as separate jobs.
