# CrispCalc — handover for the next session

Pickup note from the **2026-05-26 (Round 97) session**. Closed
the P6 §97 CAS slate (modulo two deferrals) and grew the
precision arc + number theory entries. Next slot is Round 98
(matrix + linear algebra entries) — already lined up in PLAN.

- **97** — P6 CAS + precision Function Reference content. 3 →
  20 entries. Tests 1949 → 1952.

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
| **main HEAD** | `9ee38f0` (Round 97) — docs commit to follow |
| **Tests** | **1952 pass** (1949 → 1952) — `flutter analyze` clean |
| **dart_csp pin** | `69a9cfb` (FlatZinc frontend + QuickXplain MUS) |
| **CI** | Round 97 push not yet observed; previous pushes were green |

Only dirty file is `.claude/scheduled_tasks.lock` (harness state — leave alone).

## What this session shipped

| Round | What |
|---|---|
| **Round 97** | Function Reference CAS + precision entries. `FunctionReferences.all` grows 3 → 20 entries. CAS: `solve` upgraded + new `expand`, `simplify`, `factor`, `diff`, `integrate`, `subst`, `limit`, `gcd`, `lcm`, `factorial`, `fibonacci`. Precision arc: `pi_precision` upgraded + new `e_precision`, `sqrt_precision`, `eulergamma_precision`. Number theory: `isprime` upgraded + new `nextprime`, `prevprime`, `factorint`. Each entry carries an "in CrispCalc, X returns Y; the underlying call is SymEngine's / MPFR's / FLINT's Z" prose paragraph in the first example's hint. `series` and `taylor` deferred — no SymEngine `series_expansion` binding in the bridge yet. Tests: +2 slate-coverage invariants (CAS + precision), tightened seeAlso resolver (every target now resolves), +1 dialog spot-check. Two existing dialog tests patched to filter via search before tapping `isprime(n)` / `pi(N)` — the rows now sit below the viewport. |

## Pickup points — next strategic slot

P6 rounds 93-97 done; Round 98 is the natural next slot.

1. **Round 98 — Matrix + linear algebra entries**.
   `det`, `inv`, `transpose`, `rref`, `Matrix([[…]])`
   syntax, eigenvalues (if shipped). ~8 entries. Mirror the
   Round-97 shape: 2-3 examples each, "underlying call is
   SymEngine's `det_bareiss` / `inverse_GE` / ..." prose in
   the first hint, seeAlso wiring across matrix entries.
   Worked-example cross-links: `matrixDet` → `det`,
   `matrixInverse` → `inv`, `rref` → `rref`.

2. **Round 99 — Statistics + Constraints + Sudoku entries**.
   ~15 more entries covering the module functions. PLAN
   names `mean`, `welchT`, `pairedT`, `anova1`,
   `chi2Goodness`, `chi2Independence`, `fisherExact`,
   `wilcoxon`, `signTest` for stats; `vars`, `allDifferent`,
   `noOverlap`, `cumulative`, `minimize`, `maximize` for
   constraints DSL; plus Sudoku variant rules.

3. **Round 100 — i18n pass (~30k words)**. Triage:
   100a EN-only refinements, 100b DE, 100c FR+ES.

4. **Round 101 — Help-mode design + state**.
   `_helpMode` toggle on Calculator + Notepad AppBars
   (using `Icons.help_outline` — reserved for this).
   `HelpModeNotifier` in AppState.

5. **Rounds 102-104** — Help popovers on the keypad,
   history rows, and notepad lines. Round-97 catalogue is
   the content source for these popovers, so no duplication.

6. **Round 95 follow-up** — Statistics input pre-fill.
   `pendingStatisticsTab` slot could grow to a richer
   payload. Defer until demand surfaces.

7. **Series / taylor entries (P6 §97 carry-over)** —
   blocked on a bridge addition (`SymEngine::series_expansion`
   or equivalent). When the binding lands, drop the deferral
   comment in `function_reference.dart` and add the two
   entries (probably alongside `limit`).

8. **CSP Round E.5** (deferred) — `dart_csp_fzn` CLI as a
   MiniZinc solver. Blocked on P4 distribution pipeline.

9. **P9 follow-ups** (A5d / A7 / A8) — 3D Scene polish.

10. **Precision arc round 4** (`modpow` / `modinv` /
    `totient` / `jacobi`) — multi-repo. Cross-repo arc; ask
    before starting.

## Known issues / context

### P7 (rounds 110-113)

- **Symbolic `if(...)` doesn't render usefully.** When the
  condition stays symbolic, `tryFoldIfConditional` returns
  null. Acceptable V1.
- **Bool-chip detection is a string match** on `'true'` /
  `'false'`. `normalizeBooleanResult` runs before the cache
  write.
- **Arithmetic-with-boolean is uncoerced.** PLAN P7 R113.

### P6 (rounds 93-97)

- **Calculator top toolbar always renders** (was guarded by
  `history.isNotEmpty`).
- **`menu_book_outlined`, not `help_outline`** — the latter
  is reserved for Round 101.
- **Round 95 sentinel parser is lenient**: unknown keys
  silently ignored.
- **Statistics pre-load is tab-pick only.** Input fields use
  built-in defaults.
- **`FunctionRef.workedExampleId` is an id pointer**, not a
  structured cross-link. Acceptable shape — Round 97 didn't
  upgrade this.
- **Function Reference rows use ExpansionTile** (inline
  detail) instead of a side-by-side master/detail layout.
  Reasoning: at 560×480 the dialog isn't wide enough to
  split.
- **Action buttons use `Wrap` (not `Row`)** in the row's
  detail area. Reflows onto a second line at narrow widths.
- **`_openWorkedExample` is deep-linked** via the
  `initialSearch` ctor param on `WorkedExamplesDialog`.
- **Round-97 catalogue pushes rows below the 480px viewport.**
  Tests that find `isprime(n)` or `pi(N)` directly now filter
  via the search field first. The pattern for Round 98+
  dialog tests: if the entry isn't in the top ~8 rows of its
  category, enter the id into the search field first.
- **`series` and `taylor` deferred.** No SymEngine binding
  yet — see Round 97 in HISTORY for the carve-out.

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
- Worked Examples dialog: `lib/widgets/worked_examples_dialog.dart`
- **Function Reference model**: `lib/engine/function_reference.dart`
  (Round 97: 20 entries across CAS / number theory / precision)
- **Function Reference dialog**: `lib/widgets/function_reference_dialog.dart`
  (Round 96 layout; unchanged in Round 97)
- AppState pending slots: `lib/engine/app_state.dart`
- Calculator: `lib/screens/calculator_screen.dart`
- Notepad: `lib/screens/notepad_screen.dart`
- Sudoku receiver: `lib/screens/sudoku_screen.dart`
- Statistics receiver: `lib/screens/statistics_screen.dart`
- Calculator keypad: `lib/widgets/calculator_keypad.dart`
- Notepad classifier: `lib/engine/notepad_evaluator.dart`
- Worked-examples catalog: `lib/engine/worked_examples.dart`
- Localization: `lib/localization/app_localizations.dart`
  (Round 96 strings still cover the Function Reference UI;
  Round 100 will i18n the entry bodies)
- Tests this session: `function_reference_test.dart`
  (catalogue invariants, +2 slate tests) and
  `function_reference_dialog_test.dart` (+1 CAS-filter spot
  check; 2 existing tests patched for the grown catalogue).

Good luck.
