# CrispCalc — handover for the next session

Pickup note from the **2026-05-26 (late) session** that
finished P7 and started P6. Today's rounds:

- **110, 111, 111b, 112, 113** — P7 booleans (relational +
  logical operators, `if(...)` fold, Adv-keypad keys, worked
  examples, notepad chip rendering).
- **93, 94** — P6 worked-examples discoverability (icon on
  Calculator + Notepad, surface-scoped filtering).

`HANDOFF.md` remains the load-bearing pattern reference.

---

## ⚠ Working-mode change

**Parallel-arc work is paused.** All edits now go **directly on
`main`** in `/Volumes/backups/code/CrispCalc`. The old "create a
feature branch / worktree for every round" rule (HANDOFF §0a) is
suspended until the user reactivates the parallel worker.

If you accidentally start editing in a feature-branch worktree,
either move the edits to `/Volumes/backups/code/CrispCalc` or
remind yourself the user wants main.

---

## State

| | |
|---|---|
| **Main worktree** | `/Volumes/backups/code/CrispCalc` (branch `main`) |
| **main HEAD** | (this session — Rounds 93 + 94 + docs) |
| **Tests** | **1911 pass** (1810 → 1832 → 1856 → 1880 → 1898 → 1905 → 1911 across rounds 110/111/112/111b/113/93+94) — `flutter analyze` clean |
| **dart_csp pin** | `69a9cfb` (FlatZinc frontend + QuickXplain MUS) |
| **CI** | Rounds 113 + 93 + 94 pushes not yet observed; previous pushes were green |

Only dirty file is `.claude/scheduled_tasks.lock` (harness state — leave alone).

## What this session shipped

| Round | What |
|---|---|
| **Round 110** | Relational-operator preprocessor (P7 kickoff). `preprocessRelationalOperators` does a paren-depth-0 scan + longest-match rewrite of `==` `!=` `<=` `>=` `<` `>` into SymEngine's `Eq` `Ne` `Le` `Ge` `Lt` `Gt`. Calculator + notepad assignment regexes tightened with `=(?!=)`. New `normalizeBooleanResult` lowercases `True`/`False` for display. Calculator history renders bool results as a colored chip via `_buildBooleanChip`. 22 tests. |
| **Round 111** | Logical-operator preprocessor. `preprocessLogicalOperators` does a two-phase walk: phase A recurses into parens, phase B splits at depth 0 in precedence order (`or` < `xor` < `and`) and checks for leading `not`, then falls through to the relational rewrite at the leaf. Python-style precedence. Chained collapse to n-ary `And`/`Or`/`Xor`. Calculator + notepad swapped from the relational call to the combined entry point. 24 tests. |
| **Round 112** | Adv-keypad keys + worked examples for P7. Ten new Adv keys (`==`, `≠`, `<`, `≤`, `>`, `≥`, `and`, `or`, `not`, `xor`) with glyph labels + ASCII insertion. Four worked-examples entries (boolean predicates) in the `numberTheory` category, localized en/de/fr/es. |
| **Round 111b** | `if(cond, t, e)` Dart-side fold + paren-descent comma-split fix. `tryFoldIfConditional(input, evaluator)` detects an `if(...)` call spanning the whole input, runs the condition through the engine, and returns the chosen branch trimmed (or null for symbolic / non-if). Calculator + notepad both call it after the boolean rewrite. The descent into paren-groups now splits the inner content by top-level commas before recursing — fixes the latent `Min(2 == 2, x + 1)` mangling and makes `if(...)` args lower correctly. New `if` Adv key + `booleanIfFold` worked example. Cap test bumped 40→50. 18 tests. |
| **Round 113** | Notepad boolean integration. Lifted calculator's `_buildBooleanChip` to a shared `lib/widgets/boolean_chip.dart` (`BooleanChip`). `notepad_screen.dart::_buildResult` now branches on `trimmedRes == 'true' \|\| trimmedRes == 'false'` and renders the chip (font 16 to match notepad's surrounding text; calc still defaults to 18). Calculator's `_buildBooleanChip` collapses to a single `Align(BooleanChip(...))`. **Arithmetic-with-boolean coercion**: V1 decision is **no coercion** — pass through whatever SymEngine returns (symbolic form or error). 7 tests (+4 chip widget, +3 notepad render). |
| **Round 93 (P6 kickoff)** | Worked Examples library out of Settings. Open-book `(menu_book_outlined)` IconButton on Calculator top toolbar + Notepad AppBar `actions:` row. Settings card stays but its subtitle now points at the icon (all 4 locales). The Calculator's existing top toolbar (LaTeX/Plain toggle + search + clear) used to hide when history was empty; now it renders unconditionally so the icon stays reachable from cold start. Open-book glyph instead of `help_outline` because that one is reserved for Round 101's future help-mode toggle. |
| **Round 94** | Surface-scoped filtering. `WorkedExamplesDialog` gained a `surface: WorkedExamplesSurface` parameter (default `calculator`). Notepad passes `notepad`, restricting the chip row + example list to `{calculus, algebra, linearAlgebra, numberTheory}` — hiding three module-bound categories (statistics / units / constraints). PLAN's spec said the first three only; numberTheory included because P7 + the precision arc both ship entries that work fine inline in a notepad line. 6 tests (+4 dialog filter, +2 ui_flows icon discovery). |

## Pickup points — next strategic slot

P7's engine + UI is complete; P6 rounds 93+94 shipped today.
Order below is roughly by follow-on value.

1. **Round 95 — Examples open the right module (deferred from
   today).** Per-module pre-loading via parameterised
   `open:<module>?key=value` sentinels. Needs:
   - New AppState pending slots:
     `_pendingSudokuPreset` + `_pendingStatisticsDemo`
     (mirrors `_pendingDslProgramId` from round 73).
   - Receiver-side drain on `SudokuScreen` + `StatisticsScreen`
     init (route through the existing `AppState.addListener`
     pattern that `_maybeRouteToCalculator` uses).
   - Sentinel parser extension in
     `WorkedExamplesDialog._insert` for the `?` separator.
   - At least one new worked-examples entry per module that
     uses the new sentinel.

2. **Round 114 — Function Reference + help-mode wiring**
   (depends on P6 round 97 landing first).

3. **Rounds 96-100 — Function Reference data model + entries**.
   This is the meaty P6 arc: `FunctionRef` model, ~50 entries
   × 4 locales. Each round is one-session-shaped; round 96
   (the scaffolding) is the right place to start.

4. **CSP Round E.5** (deferred) — bundle `dart_csp_fzn` CLI as a
   MiniZinc solver. Blocked on P4 distribution pipeline.

5. **P9 follow-ups** (A5d / A7 / A8) — 3D Scene polish.

6. **Precision arc round 4** (`modpow` / `modinv` / `totient` /
   `jacobi`) — multi-repo. See `HANDOFF_PRECISION.md`. Cross-repo
   arc; ask before starting.

## Known issues / context

### P7 (rounds 110-113)

- **Symbolic `if(...)` doesn't render usefully.** When the
  condition stays symbolic (`if(x == 5, ...)` with `x` free),
  `tryFoldIfConditional` returns null and the original
  `if(...)` form flows to SymEngine, which doesn't understand
  it and surfaces an error. Acceptable V1.
- **Bool-chip detection is a string match.** Both calculator
  and notepad key on `entry.result.trim()` / `res.trim() ==
  'true'`/`'false'`. `normalizeBooleanResult` runs *before*
  the cache write so the lowercase form is what reaches the
  chip path.
- **Arithmetic-with-boolean is uncoerced.** `1 + (2 == 2)` is
  whatever SymEngine returns — usually symbolic. The V1
  decision is documented in PLAN P7 Round 113.
- **`if(cond, t, e)` requires the engine** to be loaded.
  Headless `flutter test` runs without SymEngine, so the unit
  tests use a stub evaluator and verify the dispatch shape.

### P6 (rounds 93-94)

- **Calculator top toolbar now always renders.** Pre-round-93
  it was guarded by `_appState.history.isNotEmpty`. The icon
  needs to be reachable from a cold start, so the container
  renders unconditionally now and the history-specific
  controls (LaTeX/Plain toggle, search, clear) are gated on
  the history check inside the row.
- **`menu_book_outlined`, not `help_outline`.** Round 101 (P6
  later in the arc) will add a help-mode toggle that uses
  `help_outline`. Keeping the two icons distinct now avoids
  confusion when both exist.
- **`numberTheory` was added to the notepad allowlist beyond
  what the PLAN specified.** Reason: P7 + precision arc both
  ship `numberTheory` entries (`isprime(2027)`, `2 == 2`,
  `pi(100)`) that work fine inline in a notepad line. Hiding
  them would be a regression.

## Hygiene reminders

- **`dart format`** before push. Format only files you touched,
  not `lib/` wholesale (HANDOFF §4.17).
- **Don't run multiple `flutter test` in parallel** — they race
  on `.dart_tool/test/incremental_kernel_*` and all fail. Run
  sync or one at a time.
- **Don't touch `.claude/`** — harness state.
- **Working on main now.** If you start a feature branch out of
  habit, ask first.

## Quick-reference paths

- Boolean preprocessor: `lib/utils/expression_preprocessing_utils.dart`
- Shared boolean chip widget: `lib/widgets/boolean_chip.dart`
- **Worked Examples dialog**: `lib/widgets/worked_examples_dialog.dart`
  (Round 94: `WorkedExamplesSurface` enum + `surface:` ctor
   parameter + `_allowedCategories()`)
- Calculator dispatch + AppBar-less toolbar:
  `lib/screens/calculator_screen.dart`
  (Round 93: top toolbar always renders + open-book icon)
- Notepad dispatch + AppBar:
  `lib/screens/notepad_screen.dart`
  (Round 93: open-book icon at start of `_buildActions`)
- Calculator keypad: `lib/widgets/calculator_keypad.dart`
- Notepad classifier: `lib/engine/notepad_evaluator.dart`
- Worked-examples catalog: `lib/engine/worked_examples.dart`
- Localization: `lib/localization/app_localizations.dart`
  (Round 93: 4-locale subtitle update on `settingsWorkedExamplesSubtitle`)
- Tests this session: `test/relational_preprocessor_test.dart`,
  `test/logical_preprocessor_test.dart`,
  `test/worked_examples_test.dart` (cap bump),
  `test/boolean_chip_test.dart`,
  `test/notepad_screen_test.dart` (Round 113 chip render),
  `test/worked_examples_dialog_test.dart`,
  `test/ui_flows_test.dart` (Round 93 icon discovery)

Good luck.
