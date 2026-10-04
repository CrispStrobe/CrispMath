# Native Apple screenshot evidence

The [latest native GitHub CI gallery](https://github.com/CrispStrobe/CrispMath/actions/runs/37202560511)
captures CrispMath at source `6eff9fb6fa609144fad2844e8e245d430978d3f9`.
Both jobs pass on 4 October 2026: all **33 images** and native calculation/content
assertions are verified. All **33 captures have now been individually visually
reviewed**, including evaluated worksheets, populated graphs, tracing, generated
tables, saved checkpoints, export previews and actual handwriting strokes.

The capture source and validated documentation revision
`d4739be9eb26f8bbb8963ca9547df35e6e1480dd` have identical 368-file production
trees, SHA256
`98edb1c4f9ca1064ca37e299b203425398db54622ad9e5d159159933b584d79c`.
This also matches uploaded 1.2.0 (22), source `d4739be`. The intervening changes
affect CI helpers and documentation. See [the current review packet](apple-review-evidence.md)
for signed-binary and external TestFlight evidence; beta approval does not
resolve the earlier App Review 4.3(a) finding.

| Profile | Capture | Images | Pixel dimensions |
| --- | --- | ---: | --- |
| iPhone 15 Pro Max | Native iOS simulator | 11 | 1290 × 2796 |
| iPad Pro 13-inch (M4) | Native iOS simulator | 11 | 2048 × 2732 |
| macOS | Actual native Flutter application render tree, at 2× | 11 | 2560 × 1800 |

The macOS images contain the application content without operating-system
window chrome. They are not browser screenshots. The iPhone and iPad checks
use simulators; physical-device testing remains for another session.

Both CI artifacts retain source-tagged manifests, RGB PNG images and
calculation evidence: `native-apple-screenshot-gallery` and
`native-macos-screenshot-gallery`. All 33 images remain in remote artifacts.
The first review downloaded the manifests and four selected PNGs:

- `/mnt/storage/CrispMath-stage19-ci/native-gallery/ios/manifest.json`
- `/mnt/storage/CrispMath-stage19-ci/native-gallery/ios/iphone/multiple-function-graph.png`
- `/mnt/storage/CrispMath-stage19-ci/native-gallery/ios/ipad/evaluated-engineering-worksheet.png`
- `/mnt/storage/CrispMath-stage19-ci/native-gallery/macos/manifest.json`
- `/mnt/storage/CrispMath-stage19-ci/native-gallery/macos/macos/multiple-function-graph.png`
- `/mnt/storage/CrispMath-stage19-ci/native-gallery/macos/macos/evaluated-engineering-worksheet.png`

The first selected-image review and production parity are recorded in
`/mnt/storage/CrispMath-stage19-ci/native-gallery/verified-native-gallery-math.json`.
The subsequent review downloaded the remaining 29 PNGs by exact manifest path,
excluding duplicate raw simulator images, through partial artifact requests.
These files are under `native-gallery/remaining-ios` and
`native-gallery/remaining-macos` on the same CIFS storage. The complete review,
image hashes, dimensions and proposed sequence are recorded in
`native-gallery/store-selection-review.json`. App bundles and models were not
downloaded, and no local app build or screenshot batch was run.

Reviewed graphs contain `cos(x)`, `x^2-2` and linked `3*sin(x)`. The tank
worksheets show `r=3`, `h=5`, area `28.2743338823`, volume `141.3716694115` and
volume/1000 `0.1413716694115`, with computed-result labels. No blank capture,
framework error or unexpected blocking overlay was seen. The expected table,
history, export and handwriting dialogs contain real content.

## Proposed screenshot sequence

Use the following four unmodified captures for each device profile. They follow
one document from calculation through inspection, recovery and export. This is
a reviewed selection; the images have not been uploaded to App Store Connect.

| Order | Filename | What the image establishes |
| --- | --- | --- |
| 1 | `connected-worksheet.png` | Evaluated `a=3`, the linked `3 sin(x)` expression, its free x, and the exact integral 1/3 |
| 2 | `graph-curve-trace.png` | Three populated curves, their worksheet link, a visible sampled coordinate and trace marker |
| 3 | `worksheet-checkpoint-history.png` | The same document with a saved checkpoint and visible Compare action |
| 4 | `worksheet-graph-export-preview.png` | Evaluated worksheet content, retained sine graph, numeric samples and HTML/MD/TEX/PDF actions |

The first, third and fourth scenes refer to **Explore a function**. The graph
adds `cos(x)` and `x²−2` alongside its linked `3 sin(x)`. The trace coordinates
differ slightly across platforms because sampling uses the real plot geometry.
The phone readout is `(0, 1)`; tablet and desktop captures show approximately
`(0.02, 0.9998)`, all consistent with the traced cosine.

The longer `evaluated-engineering-worksheet.png` is a useful optional fifth image
on iPad and macOS. On iPhone its last result label sits near the lower edge,
so the shorter connected worksheet is the clearer opening image. The exact
calculator and generated value table are useful supplementary views.
`handwriting-editable-input.png` is excluded from the proposed store sequence:
it visibly says no model is configured and demonstrates pen input, not successful
recognition. Export previews contain a scrollable sample list; do not imply the
screen shows every exported row or verifies a physical Files provider.

## Phone graph controls

The phone toolbar is intentionally a bounded horizontal
[`SingleChildScrollView`](../lib/screens/graphing_screen.dart), and the function
chips use a horizontal `ListView`. Their partial edge items indicate additional
content reached by horizontal scrolling; they are not unconstrained layout
overflow. The trace screenshot shows the toolbar after it has scrolled from
Bounds/Fit to Trace/Table/Zoom, while the graph itself remains fully within its
viewport.

The successful native gallery test reveals and taps **Trace curve** and
**Value table**, then asserts a real trace readout and at least ten generated
table rows on iPhone, iPad and macOS. That evidence supports reachability of
those tested commands. It does not independently test every toolbar command
or dragging the function strip on a physical phone. No inaccessible-control
defect was established by this review, so no application layout change or new
release is attributed to the screenshot selection. A visible overflow menu or
scroll affordance remains a possible later UX improvement, with its own tests.

For historical captures, see [the previous gallery](https://github.com/CrispStrobe/CrispMath/actions/runs/37104046317)
at `2927336`, [the earlier gallery](https://github.com/CrispStrobe/CrispMath/actions/runs/37056297272)
at `c5955f2`, and [release history](../HISTORY.md). Those runs are archived
evidence, not the current production source.

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

Apple's [screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)
list the captured iPhone and iPad dimensions. Confirm the selected display
slots and actual upload files before submission. These new captures have not
been uploaded to App Store Connect. Simulator evidence does not verify physical
Siri invocation, Files providers, Apple Pencil or device multitasking.
