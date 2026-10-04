# CrispMath App Review preparation packet

Updated 4 October 2026. This is a draft for a future App Review submission;
this packet has not been sent to Apple and no new App Review submission has
been made during this work. The September 14 rejection
of 1.0.3 (7) under guideline 4.3(a) remains unresolved. External TestFlight
approval does not resolve that rejection.

## Current build and evidence

Version **1.2.0 (21)** is available through the
[public TestFlight beta](https://testflight.apple.com/join/E6HdVhTx).
[Signed upload CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37185726215)
checks the signed photo-library/camera purpose strings, version/build and
production-source parity before upload. This replaces the build 12 delivery
that was rejected for ITMS-90683.
[External beta verification](https://github.com/CrispStrobe/CrispMath/actions/runs/37186277329)
records Apple processing **VALID**, beta review **APPROVED**, both audiences
**IN_BETA_TESTING**, and assignment to **Public Beta**. The build ID is
`971c1bb2-df76-4993-b841-03c6dce32a6e`; Apple's `submittedDate` is null.
No App Review submission occurred.

The validated documentation revision is
`438c3e516b0ddc32c589b8d12ae2a62d2e9216da`; the uploaded source is
`ca7b6c7ee205c7c73da2a4a783cba1e9b2977c5e`. Their 368 production files are
identical, with production-tree SHA256
`ab85cee47aeb75df7fd041e6316ad32660dba610e5077f057c8b7518527dacfe`.
The native gallery source below has the same production fingerprint.

| Evidence | Verified result |
| --- | --- |
| [Final-source feature validation](https://github.com/CrispStrobe/CrispMath/actions/runs/37186428965) | Full feature, browser, native OCR and gallery jobs pass; all required platform checks are green on `438c3e5` |
| [Linux/WASM math audit](https://github.com/CrispStrobe/CrispMath/actions/runs/37184040061) / [packaged macOS](https://github.com/CrispStrobe/CrispMath/actions/runs/37184042305) | 737 accumulated cases pass on each platform |
| [Pages](https://github.com/CrispStrobe/CrispMath/actions/runs/37184585963) / [Vercel](https://github.com/CrispStrobe/CrispMath/actions/runs/37184586065) | Each published site passes 737 runtime cases and actual Playwright checks: 420 worksheet entries, 26 edits, 18 statistics, six constraint solves and two calculator linear-system/reload checks |
| Full hosted test suite | 5,735 unit/widget tests pass, eight documented skips; 491 focused and 104 tooling tests pass; analysis reports zero issues |

See [the tenth audit](round10-math-audit-50.md) for frozen independent references,
production fixes and evidence limits. Earlier release history remains in
[HISTORY.md](../HISTORY.md) and the individual audit documents.

## What to demonstrate to review

Present the connected, persistent worksheet workflow as the concrete product
experience. A public repository, test count, new screenshots or a list of CAS
operations does not by itself establish distinctiveness. The suggestion that
Apple's finding was an automated similarity check is unverified and should not
appear in the response.

These steps use existing, tested actions; the combined sequence is a proposed
review demonstration, not a claim that a physical-device walkthrough has run:

1. Open **Notepad** and enter three lines: `a=3`, `f(t)=t^2+a`, `f(4)`.
   In **Document menu**, choose **Recalculate all**. The last result is **19**.
2. Choose **Document history**, then **Save checkpoint**, and close the dialog.
   Change the first line to `a=5`; the dependent result becomes **21**.
3. Open **Document history**, select **Compare** on the saved checkpoint and
   choose **Restore checkpoint**. The worksheet returns to `a=3` and **19**;
   the pre-restore state is retained as another checkpoint.
4. Use **Link line to graph** on the function line. Inspect its sampled curve,
   trace a coordinate and generate a value table. Return to the worksheet;
   the graph is linked to that worksheet rather than a pasted picture.
5. From **Document menu**, open **Worksheet export preview**. Show the evaluated
   calculations and linked graph. Save HTML, Markdown, LaTeX or PDF. The
   downloaded export includes sampled values; undefined points remain marked.
6. Choose **Save worksheet file**, then **Open worksheet file** to import it.
   Imported source calculations are recalculated rather than trusting cached
   results. This browser file round trip is verified; exercising an actual
   iPhone/iPad Files provider remains deferred.
7. In **Settings → Workspace backups**, use **Save backup** and **Open backup**
   to demonstrate portable workspace recovery. Importing conflicting documents
   preserves both versions. This is separate from configured cloud sync.

The exact 19 → 21 → 19 history/restore behavior is checked by
[the history test](../tool/check_document_history_browser.py).
[Worksheet export](../tool/check_worksheet_export_browser.py) checks downloaded
formats, a linked graph and undefined values using `f(x)=3/x`.
[Workflow import](../tool/check_apple_workflows_browser.py) checks the 19-result
worksheet, real downloads/uploads and rejection of a forged cached result of
999. Native graph sampling, trace/table content and the iOS worksheet URL
handler are checked in [the native integration test](../integration_test/product_gallery_test.dart).
Siri invocation itself has not been physically tested.

## Screenshot selection

[Native gallery CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37178578571)
passes at source `da75490b48bf1a9548e68fafce45e8c5769e749c`, with the identical
production fingerprint above. It retains **33 populated captures**:

| Profile | Captures | Dimensions |
| --- | ---: | --- |
| iPhone 15 Pro Max simulator | 11 | 1290 × 2796 |
| iPad Pro 13-inch (M4) simulator | 11 | 2048 × 2732 |
| Native macOS application render tree, at 2× | 11 | 2560 × 1800 |

Four selected images were visually reviewed: iPhone multiple-function graph,
iPad evaluated engineering worksheet, and macOS graph/worksheet. The graphs
contain `cos(x)`, `x^2-2` and worksheet-linked `3*sin(x)`. The tank worksheet
shows `r=3`, `h=5`, area **28.2743338823**, volume **141.3716694115**, and
volume/1000 **0.1413716694115**, with computed-result evidence. Other views
passed hosted capture assertions but were not individually visually reviewed.
The iPhone graph's toolbar/function chips extend horizontally beyond the
viewport; review the intended crop before selecting that image for the store.

Use the evaluated worksheet, multiple-function graph, worksheet graph export
preview, and checkpoint-history scenes to show actual use. Keep originals and
source manifests. The macOS captures contain application content without OS
window chrome. Simulator images and native macOS captures do not establish
physical iPhone/iPad behavior.

Apple's [accurate-metadata guidance, including 2.3.3](https://developer.apple.com/app-store/review/guidelines/#accurate-metadata)
requires screenshots to represent the app in use. The captured iPhone/iPad
sizes are listed in [Apple's screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/).
Validate the chosen display slots and upload files before submission; these
captures have not been uploaded as new App Store screenshots.

## Review notes draft

> CrispMath provides persistent mathematical worksheets whose variables and
> functions drive later calculations and linked graphs. Try a=3, f(t)=t^2+a,
> f(4): the result is 19. Save a checkpoint, change a to 5 to obtain 21, then
> compare and restore the checkpoint to recover 19. Link the function to a
> sampled graph and use Worksheet export preview to export calculations,
> plots and values together. Worksheet files retain editable source and are
> recalculated on import. Core calculator, worksheet and graph calculations
> run on-device. Optional AI assistance and cloud sync use configured services.
> Handwriting transcription is experimental and must be reviewed before use.
> Public source and reproducible evidence:
> https://github.com/CrispStrobe/CrispMath.

Before sending a response, confirm that the selected screenshots and metadata
match this build and any enabled review services are accessible.
[Apple's 4.3 guidance](https://developer.apple.com/app-store/review/guidelines/#spam)
addresses duplicate app variants and experiences indistinguishable from
widely available apps. This packet supplies a concrete workflow for assessment;
it does not predict Apple's decision or establish that other submitted apps
are unrelated.

## Remaining verification

- Physical iPhone/iPad testing is deferred to another session, including Siri,
  Files-provider behavior, Apple Pencil and multitasking.
- A configured cloud project and real two-device account check remain pending.
  Local checkpoints and portable backups work independently of that service;
  do not claim verified deployed cloud sync or invent review credentials.
- Handwriting is an editable transcription aid. The 50-human-sample benchmark
  achieved only **7/50** exact transcriptions for PosFormer and **0/50** for
  BTTR/HMER. Do not advertise reliable recognition or show an unverified
  recognition success. Local model weights are optional downloads; cloud
  recognition requires explicit confirmation and a configured provider.
  Dataset/weight licenses remain separate from application code, and benchmark
  weights are not shipped as app assets.
- The original guideline 4.3(a) App Review finding remains open. No new App
  Review submission or correspondence is authorized by this preparation file.
