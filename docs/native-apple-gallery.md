# Native Apple screenshot evidence

The [latest GitHub CI gallery](https://github.com/CrispStrobe/CrispMath/actions/runs/37104046317)
captures the real CrispMath application at source
`29273367886684638798575dec2050746752aacc`.
Both jobs pass on 3 October 2026: all 33 images and native calculation/content
assertions are verified. Three selected macOS graph, engineering worksheet and
value-table images are visually reviewed. The subsequent `1afa020` changes only
the live test helper; production code is unchanged. iPhone/iPad manifests and
calculation reports are inspected without downloading their images or app bundles.

| Profile | Capture | Images | Pixel dimensions |
| --- | --- | ---: | --- |
| iPhone 15 Pro Max | Native iOS simulator | 11 | 1290 × 2796 |
| iPad Pro 13-inch (M4) | Native iOS simulator | 11 | 2048 × 2732 |
| macOS | Actual native Flutter application render tree, at 2× | 11 | 2560 × 1800 |

The macOS images contain the application content without operating-system
window chrome. They are not browser screenshots. The iPhone and iPad checks
use simulators; physical-device testing remains for another session.

Both CI artifacts include a source-tagged `manifest.json`, RGB PNG images,
and calculator evidence: `native-apple-screenshot-gallery` and
`native-macos-screenshot-gallery`. Selected macOS images and platform manifests are in
`.dart_tool/stage12-ci/final-incremental-gallery/`; all 33 images remain in the
remote artifacts. The [earlier gallery](https://github.com/CrispStrobe/CrispMath/actions/runs/37056297272),
source `c5955f2`, retains the prior visual review across all three profiles in
`.dart_tool/stage9-ci/apple-native-final/`.

| Scene filename, without `.png` | Visible content |
| --- | --- |
| `calculator-exact-integral` | Actual history result: integral of x² from 0 to 1 equals 1/3 |
| `connected-worksheet` | Evaluated assignments, linked sine function, and exact integral |
| `linked-function-graph` | Sampled curves, including the worksheet-linked 3 sin(x) |
| `multiple-function-graph` | cos(x), x² − 2, and the linked 3 sin(x) |
| `graph-curve-trace` | A live sampled coordinate and visible trace marker |
| `generated-graph-value-table` | Eleven generated function values, from −5 to 5 |
| `shortcuts-created-worksheet` | Evaluated f(t) = t² + 3 and f(4) = 19 |
| `evaluated-engineering-worksheet` | Tank radius, height, area, and volume with computed-result evidence |
| `worksheet-graph-export-preview` | The real worksheet export preview and retained graph link |
| `worksheet-checkpoint-history` | A saved checkpoint and comparison action |
| `handwriting-editable-input` | Six actual pen strokes spelling x² + 1 |

Assertions exercise the linked native CAS (`differentiate(sin(x)) = cos(x)`),
the exact integral, populated curve geometry, tracing, generated table rows,
and evaluated worksheets. The definite integral must have no free x; its
linked sine-function control must still retain x. The π-dependent tank volume
must remain readable numeric data near 45π, with computed evidence rather than
an exact label. Literal radius and height retain exact evidence.

The worksheet URL is launched through the real native iOS handler and must
produce f(4) = 19. macOS exercises the native evaluator and worksheet screen;
its worksheet URL handler is not supported. Handwriting input is rendered and
checked, but recognition is not exercised: the capture has no configured model.

The [workflow](../.github/workflows/apple-screenshot-gallery.yml),
[native integration test](../integration_test/product_gallery_test.dart), and
[artifact verifier](../tool/verify_native_gallery.py) run on GitHub-hosted macOS
runners. No local VPS build or screenshot batch is required.
