# Native Apple screenshot evidence

The [latest native GitHub CI gallery](https://github.com/CrispStrobe/CrispMath/actions/runs/37178578571)
captures CrispMath at source `da75490b48bf1a9548e68fafce45e8c5769e749c`.
Both jobs pass on 4 October 2026: all **33 images** and native calculation/content
assertions are verified. Four selected images were visually reviewed: iPhone
multiple-function graph, iPad evaluated engineering worksheet, and native macOS
graph and worksheet. The other 29 captures passed hosted tooling assertions;
they were not individually visually reviewed.

The capture source and final documented source
`438c3e516b0ddc32c589b8d12ae2a62d2e9216da` have identical 368-file production
trees, SHA256
`ab85cee47aeb75df7fd041e6316ad32660dba610e5077f057c8b7518527dacfe`.
This also matches uploaded 1.2.0 (21), source `ca7b6c7`. The intervening changes
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
Only the needed manifests and four selected PNGs were downloaded for review:

- `/mnt/storage/CrispMath-stage17-ci/final-da75490-gallery-ios/manifest.json`
- `/mnt/storage/CrispMath-stage17-ci/final-da75490-gallery-ios/iphone/multiple-function-graph.png`
- `/mnt/storage/CrispMath-stage17-ci/final-da75490-gallery-ios/ipad/evaluated-engineering-worksheet.png`
- `/mnt/storage/CrispMath-stage17-ci/final-da75490-gallery-macos/manifest.json`
- `/mnt/storage/CrispMath-stage17-ci/final-da75490-gallery-macos/macos/multiple-function-graph.png`
- `/mnt/storage/CrispMath-stage17-ci/final-da75490-gallery-macos/macos/evaluated-engineering-worksheet.png`

The selected-image review and production parity are recorded in
`/mnt/storage/CrispMath-stage17-ci/final-da75490-gallery-review.json`.
Reviewed graphs contain `cos(x)`, `x^2-2` and linked `3*sin(x)`. The tank
worksheets show `r=3`, `h=5`, area `28.2743338823`, volume `141.3716694115` and
volume/1000 `0.1413716694115`, with readable computed-result labels. No blank
capture or blocking overlay was seen in these four images. The iPhone graph
toolbar and function chips extend horizontally beyond its viewport; inspect the
intended store selection/crop before upload.

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
