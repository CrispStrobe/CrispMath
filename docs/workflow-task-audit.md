# Repeatable workflow task audit

The corpus contains 50 scenarios: 30 calculator/CAS tasks, 10 document dependency and editing tasks, 5 graph sampling/domain tasks and 5 real export/persistence tasks. Expectations are explicit in `test/fixtures/workflow_tasks.json`. It uses CrispMath's own `CalculatorEngine`, engine dispatcher, `NotepadEvaluator`, graph sampler and export code. Documents are isolated from saved user data. Document evaluation currently uses the engine callback directly; screen-specific preprocessing, units and calendar routing are tested separately by the existing UI/dispatcher tests.

After `flutter pub get`, with Flutter's Dart on PATH, run from the repository root:

```sh
tool/crispmath_cli.sh --list
tool/crispmath_cli.sh --require-native --report task-results/native.json
tool/crispmath_cli.sh --task task-39 --report task-results/function-definition.json
```

The Linux launcher resolves the pinned symbolic bridge from Dart's package configuration. `dart run tool/crispmath_cli.dart` is also available directly; its library search path must contain `libsymbolic_math_bridge.so` for native CAS. The report records native availability. A fallback run is never represented as a native pass.

Exit codes: 0 means every task passed; 1 means wrong results, unsupported capabilities or a required native bridge missing; 2 means invalid CLI/corpus input. No known failure is silently skipped or reclassified as success. All task outcomes are retained, even when a task throws. Select a single scenario with `--task` or pass another JSON corpus with `--tasks`.

`50-task gap audit` is a manual GitHub Actions workflow. Both native and browser jobs upload reports even on failure. The web build includes a separate diagnostic worker using the same app engine/WASM assets, so PDF and diagnostic code do not enlarge the normal UI math worker. Playwright runs the same JSON corpus:

```sh
python tool/check_workflow_tasks_browser.py --url http://localhost:8766/ --output task-results/browser.json
```

Comparisons accept equivalent arithmetic and polynomial notation, using the independent numeric parser at six nontrivial sample points. This is a regression comparison, not a mathematical proof of general symbolic equivalence. Negligible imaginary floating-point noise is accepted, but genuinely complex and wrong values are rejected by unit tests. An antiderivative's integration constant is included in the sample bindings. Factoring and cancellation also require the requested result form; unchanged equivalent expressions fail those tasks.

Initial browser audit: 49 passed and 1 failed (task 39); WASM CAS was available.

Initial native audit with result-form checks: 46 passed, 3 failed, 1 unsupported. Tasks 14 and 15 expose the older Linux binary returning unfactored or uncancelled forms. Task 25 requires a newer series-capable Linux bridge. Task 39 asks for an inline worksheet function definition; the current document evaluator does not support it and the subsequent call may remain symbolic rather than computing 10. These scenarios stay in the corpus with the desired expectations, so the strict audit remains red until the gaps are resolved. They do not change the existing calculator's global named-function support.

Unit regressions cover corpus identity, comparator false positives, malformed task isolation, and graph domain holes. Existing Playwright coverage checks calculator, document edits, linked graphs, calendar routing and result provenance through the UI. Physical iPhone/iPad TestFlight checks remain deferred to a later session.
