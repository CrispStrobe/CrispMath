# Calculator typing latency

Measured 2026-11-28 with
[`tool/check_calculator_typing_latency_browser.py`](../tool/check_calculator_typing_latency_browser.py)
through the [Calculator typing latency workflow](../.github/workflows/typing-latency.yml),
run [46157983716](https://github.com/CrispStrobe/CrispMath/actions/runs/46157983716).

## Method

- Release web builds from Feature validation (`feature-web` artifact):
  - before: build 1.2.2+31, commit `57643d8`, run 46146610265
  - after: build 1.2.2+33, commit `90189d9`, run 46151148745. That
    validation run itself failed; only its web bundle is used here.
- Chromium in Playwright, 1280×900, CPU throttled 4× (roughly a phone).
- The real calculator text editor, one key at a time, with 250 ms pauses.
  Each pause is longer than the 150 ms live-preview debounce, so the
  preview runs between keystrokes.
- Per key: the time from the key press until the editor holds the new text
  and a frame is painted. This includes the Playwright round trips, so its
  floor is about 100 ms at 4× throttling and the metric moves little.
- Main-thread long tasks over 50 ms (`PerformanceObserver`) while typing
  each expression.
- A second job builds the web app in `--profile` mode and records a CDP CPU
  profile per expression.

## Results

| Expression | Build | Key median | Key p95 | Key max | Long tasks | Long-task total | Longest |
|---|---|---|---|---|---|---|---|
| `9.5-2+3*4` | 31 | 127.6 ms | 507.8 ms | 668.6 ms | 21 | 3756 ms | 323 ms |
| `9.5-2+3*4` | 33 | 113.4 ms | 151.9 ms | 441.2 ms | 19 | 1975 ms | 312 ms |
| `integrate(x^2*sin(x),x)` | 31 | 108.7 ms | 114.0 ms | 117.3 ms | 94 | 14212 ms | 242 ms |
| `integrate(x^2*sin(x),x)` | 33 | 106.7 ms | 112.6 ms | 113.7 ms | 68 | 5910 ms | 112 ms |
| `factor(x^12-1)` | 31 | 107.8 ms | 111.9 ms | 112.9 ms | 87 | 12867 ms | 235 ms |
| `factor(x^12-1)` | 33 | 102.2 ms | 106.1 ms | 106.3 ms | 66 | 5535 ms | 101 ms |

Between builds 31 and 33:

- Main-thread blocking while typing fell by 47–58%.
- The longest stall during the longer expressions roughly halved, from
  about 240 ms to about 105 ms.
- The arithmetic p95 fell from 508 ms to 152 ms.

The median per-key figure stays near the measurement floor in both builds.

## Cause

The build 31 profile, taken from a profile-mode web build:

- About half the frame time went into a `LayoutBuilder` rebuild
  (`_rebuildWithConstraints` → `buildScope` → `updateChild`) of a large
  subtree after every paused keystroke.
- Most of the rest was CanvasKit `createImageBitmap` rasterizing the result.

The live preview was calculator-screen state set through `setState`. Each
preview update therefore rebuilt the whole screen, including the history
list and the full keypad. Build 32 (`dfdfa46`) moved the preview into a
`ValueNotifier` that only the input bar listens to.

Build 33 also stops the math field from re-typesetting both halves on every
cursor blink, and from rebuilding twice per keystroke
(`lib/widgets/latex_input_field.dart`).

In the build 33 profile the main thread is mostly idle while typing. What
remains is mainly CanvasKit `createImageBitmap`, which is a web-renderer
cost.

Build 31's earlier preview change, which skips previews for slow expressions
and drops stale ones, had no measurable effect on its own. Comparing
`ff03478` with `57643d8` (run 46148895691) gave the same figures within
noise.

## Limits

- This is the web build. Native iOS and macOS share the widget code but use
  Impeller and native SymEngine, so absolute numbers there differ.
- The browser test cannot show native-only effects, such as the iOS text
  input channel.
