# CrispCalc — handover for the next session

Pickup note from the **2026-05-27 (v0.4.0 cut session)**. This
session was a multi-arc landing run — the P6 help-popover sweep
PLUS the P11 cross-platform SymEngine bridge work. v0.4.0 ships
full SymEngine on iOS / macOS / **Android arm64-v8a** / **Windows
x86_64**.

## ⚠ Working-mode change (unchanged)

**Parallel-arc work is paused.** All edits go **directly on `main`**
in `/Volumes/backups/code/CrispCalc`. The bridge plugin work
happens on its own feature branches in
`/Volumes/backups/code/symbolic_math_bridge` per the multi-repo
arc rule (see `memory/feedback_multi_repo_arc_worktree.md`).

## State

| | |
|---|---|
| **Main worktree** | `/Volumes/backups/code/CrispCalc` (branch `main`) |
| **main HEAD** | `605acb9` (v0.4.0 cut + GH Release published `2026-05-27T21:31:14Z`) |
| **Tests** | **1992 pass** (1965 → 1992 across the help-popover arc); bridge pin bump doesn't change test surface |
| **dart_csp pin** | `69a9cfb` (unchanged) |
| **bridge pin** | **`931adcf`** (bridge 1.1.1 — Android + Windows binaries + consumer-integration fixes) — was `505074d` pre-session |
| **release artifacts on GH** | macOS 32.8 MB · iOS 12.0 MB · Linux 13.2 MB · **Android 83.3 MB (+17.7 MB carries the new .so)** · **Windows 17.4 MB (+1.9 MB carries the new .dll)** |

## This session — major arcs landed

### Arc A: P6 help-popover sweep (rounds 103 + 102b + 104 + 104b + 105)

Calculator history rows (R103), CAS-tab keypad buttons (R102b —
Adv was already in R102), Notepad lines (R104 + R104b), and
per-module explainers on all 8 Analyze-hub screens (R105). All
shipped, all green, all in v0.3.0 (tagged earlier this session
at commit `c226d91`). Tests grew 1965 → 1992. See HISTORY entries
for detail.

### Arc B: P11 cross-platform SymEngine bridge (R131 + R132)

The bigger lift. Closes the platform-support gap the P6 help arc
made visible — "Computed via SymEngine.X" now actually computes
on Android and Windows.

- **R132 Android arm64-v8a**: 7 CI iterations. vcpkg + NDK
  cross-compile via `VCPKG_CHAINLOAD_TOOLCHAIN_FILE`. `.so`
  committed to bridge.
- **R131 Windows x86_64**: vcpkg+MSVC dead-ended at GHA's 6-hour
  Windows runner cap (6 attempts cancelled). Pivoted to
  MSYS2/MinGW64 — flint/mpfr/gmp/mpc/boost pre-built via pacman,
  only SymEngine compiled from source. 4 iterations to green;
  `.dll` committed to bridge.

Bridge initially merged as v1.1.0 (`85bfa7e`), then had to bump
to v1.1.1 (`931adcf`) after CrispCalc CI caught two consumer-side
breakages:
- Android: bridge's `android/build.gradle` had `externalNativeBuild`
  forcing consumer Gradle to compile the wrapper from source
  without SymEngine available. Fix: drop `externalNativeBuild` —
  `jniLibs` alone is sufficient for `ffiPlugin: true`.
- Windows: bridge's `windows/CMakeLists.txt` always compiled the
  wrapper source. Fix: three-mode CMake — full-from-source (CI
  only), consumer-prebuilt (bundle the pre-built DLL via
  `bundled_libraries`), registrar-stub (degraded fallback). Plus
  a rename: prebuilt DLL went from
  `symbolic_math_bridge_plugin.dll` to `libsymbolic_math_bridge.dll`
  to avoid a name collision with the registrar DLL Flutter's
  consumer-mode build also produces. Plus a follow-up bridge fix
  (force-link guard in `symbolic_math_bridge_plugin.cpp` since
  consumer mode doesn't compile `force_link.c`).
- Dart side: `DynamicLibrary.open` now picks per-platform binary
  names — `libsymbolic_math_bridge.so` on Android,
  `libsymbolic_math_bridge.dll` on Windows, `DynamicLibrary.process()`
  on iOS/macOS.

Three full CrispCalc CI iterations on the bridge consumer integration:
`24bbe61` (Android + Windows fail), `867230a` (Android green,
Windows still fails), `605acb9` (**all 6 green**) → v0.4.0 cut.

## Smoke-test status (what's verified, what isn't)

| | Verified via CI | Verified locally (macOS host) | Real-hardware verification |
|---|---|---|---|
| Compile + link + symbols in export table | ✓ | — | n/a |
| macOS app builds + binaries embed | ✓ | ✓ (`crisp_calc.app` 74.7 MB built locally) | host = macOS, runtime trivially OK |
| Android APK contains the bridge .so | ✓ (size delta +17.7 MB matches stripped .so size) | — | **⚠ needs arm64-v8a device or emulator** |
| Windows zip contains the bridge .dll | ✓ (size delta +1.9 MB matches stripped .dll compressed) | — | **⚠ needs Windows x86_64 desktop** |
| iOS / Linux unchanged | ✓ | — | — |

The structural pipeline is end-to-end green. What's NOT confirmed:
the runtime FFI call from a real Android device or Windows desktop.
The same SymEngine wrapper source that works on iOS/macOS is what
got compiled into both new binaries — if compile + link + symbol
visibility line up (verified), runtime should follow. But should
should be verified.

## What's open / next session pickup

### 1. **Runtime smoke-test on real hardware** (highest priority)

Download v0.4.0's artifacts and run them:

- **Android**: install `crisp_calc-v0.4.0-android.apk` on an arm64
  device or emulator. Open the calculator, type
  `solve(x^2 - 1, x)`. Expect `[-1, 1]`. If you get
  `Error: requires native library`, the DLL didn't load at runtime
  — most likely cause is a mismatch between the filename Dart
  passes to `DynamicLibrary.open` and the filename Flutter
  actually bundled. Bridge 1.1.2 fix would adjust either side.
- **Windows**: extract `crisp_calc-v0.4.0-windows-x64.zip`, run
  `crisp_calc.exe`, same calculator test. Two DLLs ship in the
  runner directory (`symbolic_math_bridge_plugin.dll` registrar
  stub + `libsymbolic_math_bridge.dll` real wrapper) — Dart loads
  the second by name.

If a runtime fail surfaces, the iteration is bridge 1.1.2 — add
diagnostic logging to `_openNativeLibrary()`, narrow the failure,
push fix, re-pin CrispCalc, cut v0.4.1.

### 2. **R130 — Linux SymEngine build**

The remaining tier-1 platform. Documented in `PLAN.md` P11. Should
mirror the Android pattern closely — same `ubuntu-latest` runner,
same vcpkg dance, but no NDK chainload needed (host IS Linux). 1
day of work; ~5-10 min cold-cache CI build expected.

### 3. **Android x86_64 (emulator) and armeabi-v7a (32-bit)**

Extend the `build-android.yml` matrix. Useful when somebody tests
in an x86 emulator or owns an older phone. Each ABI is its own
~15-min build slot.

### 4. **Strip ARB references from CrispCalc** (cleanup)

While dropping `arb` from the symengine vcpkg port was the right
move (it transitively re-pulled LLVM), CrispCalc has no calls
into ARB-only SymEngine APIs (verified). Nothing to remove
code-side; just verify HISTORY/PLAN entries don't claim we use ARB
anywhere.

### 5. **Carry-overs from prior sessions**

All from the v0.3.0 HANDOFF; none affected by this session:

- Round 100 — Function Reference i18n pass (~30k words). Still
  pending. Now the highest-leverage UI-side open item.
- Round 105b — Per-element popovers inside Statistics /
  Constraints DSL / Sudoku.
- Round 95 follow-up — Statistics input pre-fill.
- `open:` / `dsl:` dispatch in Try-in-Calculator (R99 followup).
- CSP Round E.5 — `dart_csp_fzn` CLI (blocked on P4).
- P9 follow-ups (A5d / A7 / A8) — 3D Scene polish.

## Hygiene reminders

- **`dart format`** before push. Format only files you touched.
- **Don't run multiple `flutter test` in parallel** — they race
  on `.dart_tool/test/incremental_kernel_*`.
- **Don't touch `.claude/`** — harness state.
- **Working on main now.** Ask before starting a feature branch
  inside CrispCalc proper. Bridge plugin still uses feature
  branches per the multi-repo rule.
- **`flutter_symengine_*` symbol-not-found lines** in
  `flutter test` stderr are expected — the test VM doesn't load
  the plugin's compiled binaries. Bridge catches the failure;
  pure-Dart tests don't depend on it.

## Quick-reference paths

### CrispCalc (`/Volumes/backups/code/CrispCalc`)

- Calculator: `lib/screens/calculator_screen.dart`
- Notepad: `lib/screens/notepad_screen.dart`
- Help-mode infrastructure: `lib/widgets/help_target.dart`,
  `history_help_modal.dart`, `module_help_dialog.dart`,
  `calculator_keypad.dart` (popover maps)
- Function Reference catalog: `lib/engine/function_reference.dart`
  (45 entries)
- Step engine: `lib/engine/step_engine.dart`
- Localization: `lib/localization/app_localizations.dart`

### symbolic_math_bridge (`/Volumes/backups/code/symbolic_math_bridge`)

- `main` HEAD: `85bfa7e` (v1.1.0)
- `src/flutter_symengine_wrapper.{c,h}` — the 749-line C wrapper
  vendored from math-stack-ios-builder (same source for Android +
  Windows; iOS/macOS use prebuilt `.xcframework` bundles)
- `android/` — Gradle module + CMakeLists + Kotlin glue
- `windows/` — Flutter Windows plugin + CMakeLists + glue
- `.github/workflows/build-android.yml` + `build-windows.yml`
- `ANDROID_STATUS.md` + `WINDOWS_STATUS.md` — per-platform
  iteration history (essential context if R130 picks up)

### math-stack-ios-builder (`/Users/christianstrobele/code/math-stack-ios-builder`)

- Canonical iOS/macOS xcframework builder. Master branch
  `34ec0fdf`. Source-of-truth for `src/flutter_symengine_wrapper.c`
  (vendored into the bridge by R131 + R132).

Good luck.
