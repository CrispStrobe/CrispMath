# Native Apple screenshot evidence

The [final native GitHub CI gallery](https://github.com/CrispStrobe/CrispMath/actions/runs/37230024733)
captures CrispMath at source `18092e4a75d1de62601793358c6687e2b9a48eea`.
All **33 captures** pass hosted image and native calculation/content verification.
Twelve selected views are visually reviewed: worksheet, traced graph, checkpoint
history and graph export preview on each platform.

The capture helper and its tests are the only two changes from production source
`e8920a3dbaf669032901b44d4a00a25fee0c8d8e`. Uploaded build **1.2.0 (23)** and
public deployment source `637b07e` preserve those application production inputs.
The signed release gate checks 372 production files, fingerprint
`e320ae453970fea84b86c094acc86fe9df0c275e74a92aca90ded84f07800859`.
See [the review preparation packet](apple-review-evidence.md) for signed-binary
and external TestFlight evidence. Beta approval does not resolve the earlier
App Review 4.3(a) finding.

| Profile | Capture | Images | Pixel dimensions |
| --- | --- | ---: | --- |
| iPhone 15 Pro Max | Native iOS simulator | 11 | 1290 × 2796 |
| iPad Pro 13-inch (M4) | Native iOS simulator | 11 | 2048 × 2732 |
| macOS | Actual native Flutter application render tree, at 2× | 11 | 2560 × 1800 |

The macOS images contain application content without operating-system window
chrome. They are internal native captures, not verified App Store upload files.
iPhone/iPad use fresh owned simulators. Both connect and pass on their first
attempt, with no recovery retry; physical testing remains for another session.

Source-tagged manifests and the complete 33-image sets remain in the remote
`native-apple-screenshot-gallery` and `native-macos-screenshot-gallery` artifacts.
Selected images and bounded JSON reports are retained on CIFS:

- `/mnt/storage/CrispMath-round11-guided/native-18092e4/verified-gallery-selection.json`
- `/mnt/storage/CrispMath-round11-guided/native-18092e4/ios/iphone/`
- `/mnt/storage/CrispMath-round11-guided/native-18092e4/ios/ipad/`
- `/mnt/storage/CrispMath-round11-guided/native-e8920a3/macos/macos/`

The selected iOS originals are from 18092e4. Four macOS originals are reused from
e8920a3 under the two-file CI-helper parity proof, with the latest macOS manifest
independently checking eleven captures. The selection record includes exact
paths, source, dimensions and SHA-256 hashes for all twelve reviewed images.
Only needed JSON/selected PNG members were fetched using bounded artifact
requests; no bundle/model download or local build/capture batch was used.

## Selected sequence for each profile

| Order | Filename | Actual visible content |
| --- | --- | --- |
| 1 | `connected-worksheet.png` | Three real guided rows a=3, f(x)=x²+a and f(4), result 19, and contextual worksheet actions |
| 2 | `graph-curve-trace.png` | cos(x), x²−2 and worksheet-linked x²+3, with trace marker and coordinate |
| 3 | `worksheet-checkpoint-history.png` | Populated saved checkpoint with Compare, Close and Save checkpoint actions |
| 4 | `worksheet-graph-export-preview.png` | Evaluated worksheet/result19, retained parabola, sampled values and HTML/MD/TEX/PDF save actions |

The same guided document connects these four scenes. Phone actions wrap and
export values scroll; each screenshot shows its actual viewport, not every
export row. The ink scene is excluded from the proposed store sequence: it
shows editable strokes and no configured recognition model. These captures have
not been uploaded as App Store screenshots.

Earlier fully reviewed build-22 captures and selection records remain at
`/mnt/storage/CrispMath-stage19-ci/native-gallery/`. Their linked sine worksheet
and sources are historical evidence, not the current guided workflow.

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
| `connected-worksheet` | Guided parameter/function rows, linked parabola, and result 19 |
| `linked-function-graph` | Sampled curves, including the worksheet-linked x²+3 |
| `multiple-function-graph` | cos(x), x² − 2, and the linked x²+3 |
| `graph-curve-trace` | A live sampled coordinate and visible trace marker |
| `generated-graph-value-table` | Eleven generated function values, from −5 to 5 |
| `shortcuts-created-worksheet` | Evaluated f(t) = t² + 3 and f(4) = 19 |
| `evaluated-engineering-worksheet` | Tank radius, height, area, and volume with computed-result evidence |
| `worksheet-graph-export-preview` | The real worksheet export preview and retained graph link |
| `worksheet-checkpoint-history` | A saved checkpoint and comparison action |
| `handwriting-editable-input` | Six actual pen strokes spelling x² + 1 |

Assertions exercise the linked native CAS (`differentiate(sin(x)) = cos(x)`),
the exact integral, populated curve geometry, tracing, generated table rows,
and evaluated worksheets. The definite integral must have no free x; the
linked function control must still retain x. The π-dependent tank volume
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
