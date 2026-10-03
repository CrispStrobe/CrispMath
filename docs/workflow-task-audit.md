# Repeatable workflow task audit

The corpus contains 50 scenarios: 30 calculator/CAS tasks, 10 document dependency and editing tasks, 5 graph sampling/domain tasks and 5 real export/persistence tasks. Expectations are explicit in `test/fixtures/workflow_tasks.json`. It uses CrispMath's own `CalculatorEngine`, engine dispatcher, `NotepadEvaluator`, graph sampler and export code. Documents are isolated from saved user data. Document evaluation currently uses the engine callback directly; screen-specific preprocessing, units and calendar routing are tested separately by the existing UI/dispatcher tests.

After `flutter pub get`, with Flutter's Dart on PATH, run from the repository root:

```sh
tool/crispmath_cli.sh --list
tool/crispmath_cli.sh --require-native --report task-results/native.json
tool/crispmath_cli.sh --task task-39 --report task-results/function-definition.json
tool/crispmath_cli.sh --check-series-compatibility
```

The Linux launcher resolves the pinned symbolic bridge from Dart's package configuration. `dart run tool/crispmath_cli.dart` is also available directly; its library search path must contain `libsymbolic_math_bridge.so` for native CAS. The report records native availability. A fallback run is never represented as a native pass.

The packaged macOS app also provides a strict native diagnostic path. Keep its
sandbox enabled and supply input/output through pipes:

```sh
mkdir -p task-results
cat test/fixtures/workflow_tasks.json | \
  CRISPMATH_DIAGNOSTIC=workflows CRISPMATH_TASKS_FILE=- \
  CRISPMATH_TASK_REPORT=- \
  build/macos/Build/Products/Release/crisp_math.app/Contents/MacOS/crisp_math \
  2>&1 | tee task-results/macos.log
python tool/extract_workflow_report.py --log task-results/macos.log --output task-results/macos.json
```

Use `set -o pipefail` in automation to retain the app's exit status. The extractor
also enforces native availability, exactly 50 distinct passing results and zero
failed/unsupported cases. It saves failed reports before rejecting them. A
release macOS app can change its working directory and cannot directly read the
runner workspace under its sandbox; CI retains these protections.

Exit codes: 0 means every task passed; 1 means wrong results, unsupported capabilities or a required native bridge missing; 2 means invalid CLI/corpus input. No known failure is silently skipped or reclassified as success. All task outcomes are retained, even when a task throws. Select a single scenario with `--task` or pass another JSON corpus with `--tasks`.

`50-task gap audit` runs on relevant changes and can also be dispatched manually. Both native and browser jobs upload reports even on failure. The web build includes a separate diagnostic worker using the same app engine/WASM assets, so PDF and diagnostic code do not enlarge the normal UI math worker. Playwright runs the same JSON corpus:

```sh
python tool/check_workflow_tasks_browser.py --url http://localhost:8766/ --output task-results/browser.json
```

Comparisons accept equivalent arithmetic and polynomial notation, using the independent numeric parser at six nontrivial sample points. This is a regression comparison, not a mathematical proof of general symbolic equivalence. Negligible imaginary floating-point noise is accepted, but genuinely complex and wrong values are rejected by unit tests. An antiderivative's integration constant is included in the sample bindings. Factoring and cancellation also require the requested result form; unchanged equivalent expressions fail those tasks.

Initial browser audit: 49 passed and 1 failed (task 39); WASM CAS was available.

Initial native audit with result-form checks: 46 passed, 3 failed, 1 unsupported. Tasks 14 and 15 exposed the older Linux binary returning unfactored or uncancelled forms; task 25 exposed its missing series entry point, and task 39 exposed unsupported inline worksheet functions.

All four gaps are now fixed. [CI run 36995303162](https://github.com/CrispStrobe/CrispMath/actions/runs/36995303162) passes 50/50 on both native Linux and browser WASM, with zero failed or unsupported scenarios. The packaged macOS release app also passes 50/50 in [run 36995309372](https://github.com/CrispStrobe/CrispMath/actions/runs/36995309372), with the sandbox enabled. Factoring and cancellation retain their result-form checks. Task 39 now expects the definition's symbolic template `x^2+1` and a computed call result of `10`, reflecting the new definition result rather than an empty unsupported row.

The app pins symbolic_math_bridge `e75dbbe916c238e6a109ba85aac227fe9bbe34b7`. Its Linux library compiles the full C++ CAS wrapper from math-stack-ios-builder `167ecfe01d87f84dc1874575ed06c5b511d0efa1`, including real FLINT factoring, rational cancellation and series. The macOS podspec also retains vendored frameworks inside its source root, so CocoaPods propagates their link paths. Direct runtime contract tests verify products, rational cancellation, Taylor coefficients, shifted series and invalid orders in the stripped library. Sources and the shipped binary are reviewable in the [bridge draft PR](https://github.com/CrispStrobe/symbolic_math_bridge/pull/1).

Apple native libraries without the `series()` entry point compute exact Taylor coefficients using their existing symbolic differentiation, substitution and simplification. The direct native series implementation remains preferred when present. Orders are bounded to 1–64; CAS errors and non-finite coefficients fail explicitly. Ten forced compatibility checks cover geometric, exponential and sine expansions, shifted polynomials and rational functions, constants, truncation and poles. These checks run against Linux CAS and the packaged macOS release binary. Five unit regressions cover shifted coefficients, truncation, early termination, bounds and error propagation.

Worksheet functions support lexical parameters, multiple arguments, nested and forward calls, captured document bindings, incremental edits, redefinition, persistence, argument-count errors and cycle reporting. Invalid bodies and excessive expansion cannot retain old results. Single-parameter definitions can be linked directly to graphs, including parameters named `t`; multi-parameter calls can fix an argument, such as `g(x,2)`. Ordinary numeric worksheets keep their existing fast path.

Release and debug UI tests exercise edits, captured variables, transcendental calls, reload, argument-error recovery and linked graphs on desktop and phone layouts. Both Pages and Vercel now run the same strict 50-task audit alongside those Playwright UI checks after deployment.

Unit regressions cover corpus identity, comparator false positives, malformed task isolation, and graph domain holes. Existing Playwright coverage checks calculator, document edits, linked graphs, calendar routing and result provenance through the UI. Physical iPhone/iPad TestFlight checks remain deferred to a later session.

The audit also exposed an integration-call inconsistency between UI surfaces. The calculator and worksheet now share `parseIntegralArguments`, accepting both flat and tuple bounds and rejecting partial/malformed argument lists. Unit and Playwright regressions cover both forms; two CLI scenarios use the same parser.

Screenshot CI provides a web gallery and a separate `Native Apple screenshot gallery` workflow. The latter builds simulator OCR archives from the pinned source, verifies native CAS results, captures iPhone/iPad app screens and records actual PNG dimensions. Simulator captures do not claim physical-device validation.

[Native gallery CI](https://github.com/CrispStrobe/CrispMath/actions/runs/36995410403) passed for iPhone 15 Pro Max and iPad Pro 13-inch (M4), producing six captures at 1290×2796 and 2048×2732. The RGB encoder rejects transparent pixels and preserves dimensions and RGB values while removing the redundant alpha channel. Original captures remain in `raw/`. These dimensions and the no-alpha requirement match [Apple's screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/).

Final validation for `2daed84`: [feature CI](https://github.com/CrispStrobe/CrispMath/actions/runs/36995303257) passes analysis, 5,250 unit/widget tests (seven opt-in skips), 22 Python tooling tests, 194 focused checks, native OCR, release/debug Playwright and the 12-scene browser gallery. All platform builds pass. [Pages](https://github.com/CrispStrobe/CrispMath/actions/runs/36995320209) and [Vercel](https://github.com/CrispStrobe/CrispMath/actions/runs/36995323446) pass their post-deployment UI checks and strict 50-task audits.

Large-document performance is also checked against the recorded 48f0190 release
CI baseline in `tool/notepad_performance_baseline.json`. The gate requires
three valid trials for each matching desktop/phone CPU profile and 500/2,000-row
case, and recomputes medians from raw samples. It rejects medians above twice
the baseline plus 300 ms; this allows runner noise while catching sustained
regressions. This is a broad regression threshold, not an improvement target
or a physical-device performance claim. A negative control using the slower
6718c6c build fails all four cases. Debug cancellation correctness uses 200 rows with a real CAS operation on every
row, keeping the batch active long enough to click Cancel;
release and deployed cancellation checks retain 2,000 rows.
