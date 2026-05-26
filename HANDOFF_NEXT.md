# CrispCalc — handover for the next session

Pickup note from the **2026-05-26 (late) session** that shipped
Rounds 110 + 111 + 112 of P7 (booleans). The longer-lived
`HANDOFF.md` is still the load-bearing reference for repo
conventions; this file is a focused pickup note for what to do
*next*.

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
| **main HEAD** | (this session — Round 112 + docs) |
| **Tests** | **1880 pass** (1810 → 1832 → 1856 → 1880 across rounds 110/111/112 + locale-coverage growth) — `flutter analyze` clean |
| **dart_csp pin** | `69a9cfb` (FlatZinc frontend + QuickXplain MUS) |
| **CI** | Round-110/111/112 pushes not yet observed; previous push was green |

Only dirty file is `.claude/scheduled_tasks.lock` (harness state — leave alone).

## What this session shipped

| Round | What |
|---|---|
| **Round 110** | Relational-operator preprocessor (P7 kickoff). `preprocessRelationalOperators` does a paren-depth-0 scan + longest-match rewrite of `==` `!=` `<=` `>=` `<` `>` into SymEngine's `Eq` `Ne` `Le` `Ge` `Lt` `Gt`. Calculator + notepad assignment regexes tightened with `=(?!=)`. New `normalizeBooleanResult` lowercases `True`/`False` for display. Calculator history renders bool results as a colored chip (secondaryContainer / errorContainer) via `_buildBooleanChip`. 22 tests. |
| **Round 111** | Logical-operator preprocessor. `preprocessLogicalOperators` does a two-phase walk: phase A recurses into parens, phase B splits at depth 0 in precedence order (`or` < `xor` < `and`) and checks for leading `not`, then falls through to the relational rewrite at the leaf. Python-style precedence. Chained collapse to n-ary `And`/`Or`/`Xor`. Calculator + notepad swapped from the relational call to the combined entry point. 24 tests. |
| **Round 112** | Adv-keypad keys + worked examples for P7. Ten new Adv keys (`==`, `≠`, `<`, `≤`, `>`, `≥`, `and`, `or`, `not`, `xor`) with glyph labels + ASCII insertion. Four worked-examples entries (boolean predicates) in the `numberTheory` category, localized en/de/fr/es. `if` button omitted while round 111b is still deferred. |

## Pickup points — next strategic slot

P7 has two open items: round 111b (`if(...)` conditional) and
round 113 (notepad chip integration). Plus a latent edge case in
the round-111 paren descent to clean up. Tracks below in priority
order.

1. **Round 111b — `if(cond, then, else)` Dart-side fold.** Detect
   the call at the top of the dispatch, evaluate the condition
   via the engine (it'll already be in `Eq(...)` / `And(...)` form
   after the round-111 rewrite), pick the appropriate branch, and
   continue dispatch on that branch. Symbolic conditions leave
   the `if(...)` form unchanged and SymEngine surfaces the error.
   Once shipped, also add the `if` button to the Adv keypad +
   one worked-example entry showcasing it.

2. **Round 113 — Notepad boolean integration.** Notepad result
   cells render bool chips like the calculator does (the
   `_buildBooleanChip` helper can be lifted to a shared widget
   or duplicated). Plus the decision on what arithmetic-with-
   boolean coerces to (0/1 vs. error). Today notepad just
   renders `true` / `false` as plain text.

3. **Round 111c — Paren-descent comma split (bug fix).** When
   `preprocessLogicalOperators` recurses into a paren-group that
   contains commas (e.g. `Min(2 == 2, x + 1)` or, once 111b
   lands, `if(2 == 2, x^2, x + 1)`), the inner relational scan
   walks past the comma and produces `Min(Eq(2, 2, x + 1))`. Fix:
   in `_logicalDescendIntoParens`, split the inner content by
   top-level commas and recurse on each piece independently
   before rejoining with `, `. Triggers exotic-only today
   (multi-arg function calls with relationals inside an arg);
   becomes load-bearing for 111b.

4. **Round 114 — Help-mode + Function Reference wiring**. P6
   round 97's Function Reference catalog needs entries for every
   relational + logical operator. Help mode (round 102) on a
   logic button should show a truth-table popover. Both depend
   on the round-93-105 discoverability arc being further along.

5. **P6 rounds 93-95** — Move Worked Examples out of Settings.
   Three small rounds, independent of P7.

6. **CSP Round E.5** (deferred) — bundle `dart_csp_fzn` CLI as a
   MiniZinc solver. Blocked on P4 distribution pipeline.

7. **P9 follow-ups** (A5d / A7 / A8) — 3D Scene polish.

8. **Precision arc round 4** (`modpow` / `modinv` / `totient` /
   `jacobi`) — multi-repo. See `HANDOFF_PRECISION.md`. Cross-repo
   arc; ask before starting.

## Known issues / context

- **`if(cond, t, e)` not yet handled.** Round 111 stops at
  `not`/`and`/`or`/`xor`; the PLAN's `Piecewise` lowering target
  isn't in SymEngine's text-parser grammar. Round 111b will fold
  the condition Dart-side. The `if` button is intentionally
  missing from the Adv keypad until 111b lands.
- **Paren-descent comma latent bug.** `preprocessLogicalOperators`
  recurses into every paren-group and runs the relational scan
  on the inner content; the scan doesn't respect commas. So
  `Min(2 == 2, x + 1)` mangles into `Min(Eq(2, 2, x + 1))`. Not
  exercised today by any common input but blocks the round-111b
  `if(...)` shape. Fix in round 111c.
- **History chip rendering is calculator-only.** Notepad result
  cells still show `true` / `false` as plain text. Round 113
  brings the chip there.
- **Chip detection key is the lowercase string.** Bool-chip
  rendering keys on `entry.result.trim() == 'true'/'false'`.
  Anyone else stuffing a bare `true`/`false` literal into history
  (e.g. a future `isprime(...)` shortcut) will pick up the chip
  rendering for free.
- **Word-boundary safety.** `random` / `factor` / `notation` are
  safe from accidental rewrites. Variables literally named
  `and`/`or`/`xor`/`not` would collide; users would notice fast
  enough.

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
  (Round 110: `preprocessRelationalOperators`,
   `normalizeBooleanResult`; Round 111:
   `preprocessLogicalOperators`)
- Calculator dispatch: `lib/screens/calculator_screen.dart`
  (Round 110/111: `_calculate` hook + tightened assignment
   regex + `_buildBooleanChip`; Round 112: dispatch cases for
   `==`/`≠`/`<`/`≤`/`>`/`≥`/`and`/`or`/`not`/`xor`)
- Calculator keypad: `lib/widgets/calculator_keypad.dart`
  (Round 112: 10 new keys appended to `_advKeys`)
- Notepad dispatch: `lib/screens/notepad_screen.dart`
  (Round 110/111: combined rewrite in `_dispatcher`'s
   `preNative` + `normalizeBooleanResult` at evaluate tail)
- Notepad classifier: `lib/engine/notepad_evaluator.dart`
  (Round 110: `_assignmentRegex` tightened with `(?!=)`)
- Worked-examples catalog: `lib/engine/worked_examples.dart`
  (Round 112: 4 new booleanX entries in numberTheory category)
- Localization: `lib/localization/app_localizations.dart`
  (Round 112: titles + descriptions for 4 new ids × 4 locales)
- Tests this session: `test/relational_preprocessor_test.dart`,
  `test/logical_preprocessor_test.dart`

Good luck.
