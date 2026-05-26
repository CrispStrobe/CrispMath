# CrispCalc — handover for the next session

Single-shot briefing from the **2026-05-26 session** that left the
repo at commit `f4ee630`. The longer-lived `HANDOFF.md` is still
the load-bearing reference for repo conventions; this file is a
focused pickup note for what to do *next*.

---

## State

| | |
|---|---|
| **Main worktree** | `/Volumes/backups/code/CrispCalc` (branch `main`) |
| **Feature worktree** | `/Volumes/backups/code/CrispCalc-notepad-phase-1` (branch `feature/notepad-phase-1`) |
| **Both branches HEAD** | `2bc60aa` docs: HANDOFF_NEXT (after the parallel P9 arc rounds 92–100 below merged) |
| **Tests** | 1708 pass (1465 carried + 19 scene-engine + 24 intersections + 5 quadric presets + ~3 conic-degenerate + parallel-arc additions), `flutter analyze` clean |
| **CI** | green on the last main push |
| **App** | builds + runs on macOS (CocoaPods is fixed on this machine) |

Only dirty file is `.claude/scheduled_tasks.lock` (harness state — leave alone).

## What this session shipped

| Area | Commits |
|---|---|
| **Phase 4** Notepad UI skeleton | `b04caf1` (on feature/notepad-phase-1, then merged) |
| **Phase 5** live recalc + serialization fix + `_PersistentWorker` race fix | `72ed15d` |
| **Phase 6** units inline + `use` directive + format toggle | `63d6441` `604226c` |
| **Phase 7** Markdown export + Notepad-manager dialog + DE label "Rechenblock" | `d34b3d7` |
| **Phase 8** partial localization (en/de/fr/es chrome + error chips) | `75e627a` `95adf89` |
| **Bug round 1** — 100! exact integer, negative `-5.0`, decimal-places slider, auto-bind-solve toggle, focus-on-start belt | `27336ae` `755870d` `4fa911c` `4fd26b6` `1c00dc1` `99252af` |
| **Bug round 2** — d/dx LaTeX alignment (`\bigg(`), inline derivative `2 + d/dx(3*x)` expansion, history-cache `GlobalKey` crash | `d82b285` `bb35c95` `e7c1d14` `ab24c43` `8cc6ea3` `cecc37c` `642b913` |
| **Test build-out** — 91 parsing pipeline + 48 expression-deep + 38 edge + 5 Gantt = **182 new pure-Dart tests** (caught 4 real preprocessor bugs along the way) | `ff09b20` `1152ad5` `fd2c017` `68550e2` |
| **CSP Gantt** — `noOverlap` / `cumulative` results render as a horizontal Gantt chart instead of text | `d664303` |
| **PLAN** Round D (7 CSP opportunities) + Round E (FlatZinc + MUS + Notepad integration) | `aa0a390` `f4ee630` |

The 4 real bugs the new tests caught + fixed:

1. Chained binary minus `a-b-c` only spaced the first `-` (regex non-overlapping match issue).
2. `3*I` rendered as literal `\1i` (Dart's `replaceAll(RegExp, String)` doesn't do back-refs).
3. `2*sin` mangled to `2sin` (multi-letter ident shouldn't lose its `*`).
4. `extractNumericFromSolveResult("x = 1, x = 2")` returned `"2"` (silently picking one solution from a multi-solution result).

All fixed in `lib/utils/expression_preprocessing_utils.dart`.

## Pickup points — Round E (FlatZinc + MUS)

PLAN.md → search for `CSP Round E`. The full writeup is there.
Recommended order:

1. **Prereq — bump `dart_csp` pin** from `e3cce21` to a HEAD SHA that includes both the FlatZinc frontend (`8520461`) and QuickXplain MUS (`66b1a31` + `47beb59` + `a483980`). The features are additive but verify the `Problem` API surface didn't shift by running `flutter test test/csp_solver_test.dart` + `test/sudoku_test.dart`.
2. **E.1 — Paste-FlatZinc tab** (~½ day). 4th tab on `ConstraintsScreen`, textarea → `FlatZinc.solve(source)` → render output in `_ResultBlock` style. Two gallery entries (NQueens-4, bin-packing). The CLI binary `dart_csp_fzn` already works.
3. **E.4 — Notepad ↔ FlatZinc** *(novel)* (~1 day for inline `fzn:` directive variant; ~2–3 days for multi-line cell variant). PLAN E.4 has both options written up. The inline variant fits the existing `NotepadEvaluator` (Phase 3) cleanly; the cell variant needs Phase-1 doc-model changes.
4. **E.2** Why-no-solution QuickXplain panel + **E.3** DSL → FlatZinc export are polish, can wait.

## Known issues / context

- **Focus on cold launch** — added belt-and-suspenders re-`requestFocus` in `_MainScreenState.initState` (`1c00dc1`). User confirmed it works now but flag if it regresses.
- **2 + d/dx(3 * x)** — inline-derivative expansion fixed for derivatives only; `2 + integrate(x^2, x)` etc. would need the same treatment but isn't shipped yet.
- **GlobalKey crash on duplicate history expressions** — fixed (`642b913`) by caching the LaTeX *string* instead of the `Math.tex` widget. If you add other widget caches downstream, remember this pattern.
- **CocoaPods on this machine** was repaired earlier in the session (user fix); `flutter build macos --debug` works.

## Parallel arc — P9 3D Scene module (AI assistant, rounds 92–100)

In parallel with the Notepad/CSP work above, an 11-round arc
landed the **3D Scene** module described in PLAN P9. End-to-end
visible feature, replaces the text-only Plane Analyzer + Conic
Section modules with a real renderable 3D scene that computes
and highlights intersections.

| Round | Commit | What |
|---|---|---|
| 120 | `a755ae3` | Calculator history LaTeX render cache (per-expression LRU). Later patched in `642b913` to cache the *string* not the widget — Math.tex's internal GlobalKeys can't be reused across mount points. |
| 91 | `6276bbd` | Right-click "Store result as variable / function" on Calculator history + Notepad result cells. Shared `StoreResultDialogs`. |
| 92 (P9-A1) | `cae22d9` | Scene engine scaffolding — sealed `SceneObject` + 6 concrete kinds + `Scene3D` container. Pure-Dart. 19 tests. |
| 93 (P9-A2) | `459e064` | `Scene3DScreen` + viewport + plane rendering. Added as Analysis-hub module card (appended at end so existing ui_flows scrolls keep working). |
| 94 (P9-A3) | `75a8e13` | Lines + spheres in the viewport. FAB chooser sheet, drag-handle reorder. |
| 95 (P9-A4) | `45ac048` | Pairwise intersections (plane×plane, plane×line, plane×sphere, line×line, line×sphere, sphere×sphere) + cyan-highlighted geometry overlay + results panel. 24 new tests. |
| 96 (P9-A5) | `bbc6511` | Quadrics (preset-based): ellipsoid / cone / cylinder / paraboloid / hyperboloid 1- & 2-sheet. `QuadricPreset` derives 10 canonical coefficients. |
| 97 (P9-A5b) | `a6d42ee` | Plane × quadric → `ConicSectionIntersection`. Painter renders the conic via marching-squares on a 64×64 plane-local grid. Routes through existing `analyzeConic` for classification. |
| 98 (P9-A5c) | `27b4dca` | Two cleanups: (a) **3×3 determinant degenerate-conic detection** on `analyzeConic` — catches pair-of-parallel-lines that the 2-variable discriminant misclassifies as parabola; (b) **"Open in 3D Scene"** button on ConicSectionScreen that lifts the user's 2D conic into a matching quadric preset + adds a z=0 plane + navigates. |
| 99 (P9-A6) | `70efd9a` | Parametric surfaces + curves. Per-process `_ParametricSampleCache` keyed by full geometry hash so rotation doesn't re-eval SymEngine. |
| 100 (R91b) | `dfe5eb1` | Naming-dialog polish — pre-fill next unused single-letter + overwrite-confirm AlertDialog. |

### Files added / heavily touched in the parallel arc

- `lib/engine/scene_3d/scene_object.dart` — sealed `SceneObject` + 6 subclasses (`PlaneObject`, `LineObject`, `SphereObject`, `QuadricObject`, `ParametricSurfaceObject`, `ParametricCurveObject`) + `QuadricKind` enum + `QuadricPreset`.
- `lib/engine/scene_3d/scene_state.dart` — `Scene3D` container (objects + viewport).
- `lib/engine/scene_3d/intersections.dart` — sealed `Intersection` + `intersect(a, b)` dispatcher over 7 pair kinds.
- `lib/widgets/scene_3d_painter.dart` — CustomPainter dispatching on kind; intersection-overlay; parametric sample cache.
- `lib/widgets/scene_3d_object_dialogs.dart` — 6 `show...EditorDialog` functions (one per object kind).
- `lib/widgets/scene_3d_intersections_panel.dart` — results panel.
- `lib/screens/scene_3d_screen.dart` — the screen.
- `lib/widgets/store_result_dialogs.dart` — R91 + R91b dialogs.
- `lib/engine/conic_math.dart` — extended classifier with 3×3 determinant.
- `lib/screens/conic_section_screen.dart` — gained the "Open in 3D Scene" button.
- `lib/engine/app_state.dart` — added `scene3D` field + 4 setters + load + export/import.
- `lib/screens/analysis_hub_screen.dart` — new "3D Scene" module card (last in list).

### Land mines for the next session

- **Dart-format reflow vs user WIP**: running `dart format lib/` on a feature branch picks up the user's pending edits to other files (calculator_screen.dart, etc.) as format diffs that conflict with active parallel work. Workaround: format only files you actually edit, or check out `origin/main` versions of files you accidentally reformatted before committing. Hit this 3 times this session.
- **Math.tex GlobalKey caching trap**: caching the `Math.tex` widget directly causes a "Duplicate GlobalKey" exception when the same expression appears multiple times in the history list. Cache the LaTeX *string* or rebuild the widget per use. The user already shipped the fix (`642b913`); be aware if you add similar widget caches.
- **`analyzeConic` discriminant alone misclassifies pair-of-parallel-lines as parabola** — fixed in A5c by adding 3×3 determinant check first. If you change `analyzeConic`, preserve this.
- **Parametric scene rendering cost**: each frame ~324 SymEngine calls for a 18×18 surface grid. The `_ParametricSampleCache` (key = full geometry hash, FIFO 32 entries) is load-bearing; without it, rotation gestures lag visibly.
- **Module-card list order in `analysis_hub_screen.dart`**: existing ui_flows_test relies on `scrollUntilVisible` reaching Sudoku at its current position. Inserting cards *above* Sudoku breaks the tap-hit-test at the 1280×800 test viewport. Append new module cards at the end.

### Pickup points for the P9 arc (if you continue it)

- **A5d** — Raw-coefficient quadric input mode (a/b/c semi-axis dialog only takes presets today). Painter needs isosurface extraction (marching cubes) for non-preset quadrics to render.
- **A7** — Numerical intersection involving parametric objects. Newton on a fine grid; document as approximate. Closed-form algorithms in A4/A5b stay authoritative for non-parametric pairs.
- **A8** — Back-to-front sorting in `Scene3DPainter` so sphere/quadric back hemispheres don't draw over the front. Per-primitive depth + painter's algorithm.

## Hygiene reminders

- **`dart format`** before push — CI's "Verify formatting" step rejects unformatted files (`66ee3b0` was the catch-up commit for last failure).
- **Both branches in sync** — when you commit to `main`, fast-forward `feature/notepad-phase-1` in `/Volumes/backups/code/CrispCalc-notepad-phase-1` and push too.
- **Don't touch `.claude/`** — harness state.
- **Don't touch `lib/engine/calculator_engine.dart`** unless the precision-arc work is explicitly part of the task (the original handover said this; the precision-arc commits have since landed so this is less critical, but still).

## Quick-reference paths

- Notepad UI: `lib/screens/notepad_screen.dart`
- Calculator dispatch: `lib/screens/calculator_screen.dart` (search for `_calculate`)
- Preprocessing: `lib/utils/expression_preprocessing_utils.dart`
- LaTeX conversion: `lib/utils/latex_conversion_utils.dart`
- CSP wrapper: `lib/engine/csp_solver.dart` (Gantt threading lives here)
- CSP UI: `lib/screens/constraints_screen.dart` (4th tab for E.1 lands here)
- AppState: `lib/engine/app_state.dart`
- Localization: `lib/localization/app_localizations.dart` (en/de/fr/es)

## Test files added this session

- `test/parsing_pipeline_test.dart` — 91 cases for LaTeX + preprocessing
- `test/expression_pipeline_deep_test.dart` — 48 cases for normalize/substitute/UDF/formatNumber
- `test/edge_cases_test.dart` — 38 cases for degenerate inputs
- `test/csp_solver_test.dart` — extended to 52 cases (Gantt-metadata threading)

Good luck.
