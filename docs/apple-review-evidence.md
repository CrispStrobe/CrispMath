# CrispMath App Review preparation packet

Updated 4 October 2026. This is a draft for a future App Review submission;
this packet has not been sent to Apple and no new App Review submission has
been made during this work. The September 14 rejection
of 1.0.3 (7) under guideline 4.3(a) remains unresolved. External TestFlight
approval does not resolve that rejection.

## Current build and evidence

Version **1.2.0 (22)** is available through the
[public TestFlight beta](https://testflight.apple.com/join/E6HdVhTx).
[Signed upload CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37206068397)
checks the signed photo-library/camera purpose strings, version/build and
production-source parity before upload. This replaces the build 12 delivery
that was rejected for ITMS-90683.
[External beta verification](https://github.com/CrispStrobe/CrispMath/actions/runs/37206599650)
records Apple processing **VALID**, beta review **APPROVED**, both audiences
**IN_BETA_TESTING**, and assignment to **Public Beta**. The build ID is
`6ece5e52-41bd-4601-bbe2-c3b9736efbe2`; Apple's `submittedDate` is null.
No App Review submission occurred.

The release source is `d4739be9eb26f8bbb8963ca9547df35e6e1480dd`.
Its 368 production files are identical to gallery/math source
`6eff9fb6fa609144fad2844e8e245d430978d3f9` and deployed Pages/Vercel source
`b84af1f36310622ebdb813e11e07068665ba8502`, with production-tree SHA256
`98edb1c4f9ca1064ca37e299b203425398db54622ad9e5d159159933b584d79c`.
Subsequent documentation edits do not change this production tree.

| Evidence | Verified result |
| --- | --- |
| [Release-source feature validation](https://github.com/CrispStrobe/CrispMath/actions/runs/37205254896) | Full feature, release/debug browser, native OCR and gallery jobs pass; all nine required workflow gates are green on `d4739be` |
| [Linux/WASM math audit](https://github.com/CrispStrobe/CrispMath/actions/runs/37202543185) / [packaged macOS](https://github.com/CrispStrobe/CrispMath/actions/runs/37202546133) | 737 accumulated cases pass on each platform |
| [Pages](https://github.com/CrispStrobe/CrispMath/actions/runs/37204455016) / [Vercel](https://github.com/CrispStrobe/CrispMath/actions/runs/37204456455) | Each published site passes 737 runtime cases and actual Playwright checks: 420 worksheet entries, 26 edits, 18 statistics, six constraint solves and two calculator linear-system/reload checks |
| [Cloud contract and GUI](https://github.com/CrispStrobe/CrispMath/actions/runs/37205254939) | Five real SDK scenarios and desktop/phone GUI pass with wrong-password recovery, inline feedback, conflict preservation, both Close actions and verified cleanup; no application state injection |
| Full hosted test suite | 5,744 unit/widget tests pass, eight documented skips; 500 focused and 125 tooling tests pass; analysis reports zero issues; nine new real-SDK widget groups cover cloud-dialog behavior |

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

[Native gallery CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37202560511)
passes at source `6eff9fb6fa609144fad2844e8e245d430978d3f9`, with the identical
production fingerprint above. It retains **33 populated captures**:

| Profile | Captures | Dimensions |
| --- | ---: | --- |
| iPhone 15 Pro Max simulator | 11 | 1290 × 2796 |
| iPad Pro 13-inch (M4) simulator | 11 | 2048 × 2732 |
| Native macOS application render tree, at 2× | 11 | 2560 × 1800 |

All 33 captures have now been individually visually reviewed. The selected
sequence for each profile is connected worksheet, graph with tracing, checkpoint
history and worksheet graph export preview; see [the complete selection](native-apple-gallery.md).
Graphs contain `cos(x)`, `x^2-2` and worksheet-linked `3*sin(x)`. The optional tank
worksheet shows `r=3`, `h=5`, area **28.2743338823**, volume **141.3716694115**, and
volume/1000 **0.1413716694115**, with computed-result evidence. The phone graph
controls use bounded horizontal scrolling; hosted checks reveal and activate
trace/table controls. No inaccessible-control defect was established.

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

## Presentation draft

Lead with **editable mathematical worksheets with linked graphs and recoverable
history**. This describes the connected experience demonstrated above; the
calculator, CAS and statistics are supporting tools within that workflow.

Proposed store description, pending final screenshot and device verification:

> Build a worksheet from variables, functions and calculations. Change an input
> and recalculate its dependent results. Link a function to a graph, inspect a
> coordinate or generate a value table, then export your calculations and plots
> together. Save checkpoints, compare changes and restore an earlier worksheet.
> Portable worksheet files preserve editable calculations and are recalculated
> when imported. Core calculations run on your device. Optional AI assistance
> and cloud backup use services you configure. Handwriting transcription is
> experimental and requires review and correction.

Use this screenshot narrative, with the corresponding actual captures selected
in [the native gallery evidence](native-apple-gallery.md):

| Order | Scene | Suggested caption | What the capture must show |
| --- | --- | --- | --- |
| 1 | Evaluated engineering worksheet | Calculate with editable worksheets | Source assignments, dependent results and readable computation evidence |
| 2 | Multiple-function or traced graph | Turn worksheet functions into graphs | Actual populated curves and a retained worksheet link; a coordinate if using the trace view |
| 3 | Checkpoint history | Compare changes and recover your work | A real saved checkpoint and available comparison/restore actions |
| 4 | Worksheet graph export preview | Share calculations and graphs together | An actual export preview containing worksheet content and a graph |
| 5, optional | Generated value table | Inspect values along a curve | Real generated rows and function labels |

Keep the original native images and their source manifests. Captions are draft
metadata, not text inserted into the captured application. Do not use the ink
input scene to imply successful handwriting recognition. On phone, graph
controls and function chips use horizontal scrolling; select a view whose
visible controls fit the intended story and verify access rather than interpreting
an off-screen scroll item as layout overflow. The scene is still subject to
physical-device verification before App Review.

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
- No Supabase project exists for this release; Cloud Sync stays off by default.
  Local worksheets, checkpoints and portable backups need no account. A real
  project/two-device check is optional future work if cloud setup is chosen;
  do not claim verified deployed cloud sync or invent review credentials.
- Handwriting is an editable transcription aid. The 50-human-sample benchmark
  achieved only **7/50** exact transcriptions for PosFormer and **0/50** for
  BTTR/HMER. Do not advertise reliable recognition or show an unverified
  recognition success. Local model weights are optional downloads; cloud
  recognition requires explicit confirmation and a configured provider.
  An expanded-vocabulary candidate scores 0/50 despite 49/50 representable
  references. A controlled decoder normalization repair passes numerical controls
  but leaves the original/candidate exact scores unchanged. Full model/reference
  parity and suitable trained weights remain open; production weights and the
  bridge pin are unchanged. See [handwriting findings](handwriting-quality-findings.md).
  Dataset/weight licenses remain separate from application code, and benchmark
  weights are not shipped as app assets.
- The original guideline 4.3(a) App Review finding remains open. No new App
  Review submission or correspondence is authorized by this preparation file.
