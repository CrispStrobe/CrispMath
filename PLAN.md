# CrispCalc — Repair & Completion Plan

Living document. Each task: `[ ]` pending · `[~]` in-progress · `[x]` done.
Completed items are moved (with date) to `HISTORY.md`.

See `HISTORY.md` for the most recent work: 60 new unit tests covering plane,
conic, numerical helpers and full AppState persistence; the calculator
history clear button; persistent history / variables / graph functions;
and the light/dark/system theme picker.

---

## P1 — Open follow-ups

- [x] ~~Make `CrispCalc` repo public.~~ Done 2026-05-17 — see HISTORY.
- [ ] **Native `limit`.** The native bridge doesn't expose a `limit`
  entry point and the underlying SymEngine C API is missing one. Numerical
  one-sided / infinity limits stay as the current best effort. (Native
  `integrate` is now bound — see HISTORY.)
- [ ] **`flutter build macos --release`: SymEngine wrapper symbols dropped.**
  Investigated 2026-05-17. The static archive `libsymengine_flutter_wrapper.a`
  contains two distinct things: ~3000 C++ SymEngine symbols and 45 C
  wrapper `flutter_symengine_*` symbols, in different `.o` files. The
  C++ side links fine in release (~3000 `__ZN9SymEngine…` symbols land
  in the binary). The C wrapper `flutter_symengine_wrapper.o` is silently
  dropped, even with `-all_load`, even with `STRIP_INSTALLED_PRODUCT=NO`
  + `DEAD_CODE_STRIPPING=NO`, even with `-Wl,-force_load,<path>` on the
  on-disk xcframework slice. Adding both `-all_load` and `-force_load`
  trips duplicate-symbol errors. Patching `LIBRARY_SEARCH_PATHS` on the
  bridge POD target so the framework pre-links the wrapper also dupes
  in release. The real fix is upstream: split the wrapper into its own
  static lib in the bridge plugin's xcframework, or pre-link the
  framework binary properly so its symbols are unambiguously the
  authoritative ones.
- [ ] **iOS smoke test.** Not run since the recent changes.

## P2 — Engine + native bridge

- [ ] **High-precision evaluation.** `SymbolicMathBridge.evaluateWithPrecision`
  / `gmpPower` / `mpfrHighPrecisionPi` still throw — wire them when the
  C++ wrapper exposes the corresponding symbols.
- [ ] **Matrix arithmetic end-to-end.** Confirm `det(Matrix([[…]]))`,
  `inv(...)`, `transpose(...)` round-trip cleanly through the engine
  with a release SymEngine build.

## P2 — UX polish

- [ ] **More translations.** German is up to date; Spanish / French
  would be cheap follow-ups.
- [ ] **Variable substitution dialog** — no more typing `subst(...)`.
- [ ] **Plot annotations** — mark extrema and roots on the graph when
  an analysis is open.

## P3 — Long tail

- [ ] Symbolic Gauss / RREF on matrices.
- [ ] CI: GitHub Actions to run `flutter analyze` + `flutter test` on PR.
- [ ] History view filtering / search.

---

## Out of scope this round

- C++ implementation of symbolic `limit` and `integrate`.
- Rewriting the LaTeX↔engine parsing as a real grammar.
- Full accessibility audit.
