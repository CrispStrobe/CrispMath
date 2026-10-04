# CrispMath App Review preparation packet

Updated 4 October 2026. This is a draft for a future App Review submission;
this packet has not been sent to Apple and no new App Review submission has
been made during this work. The September 14 rejection
of 1.0.3 (7) under guideline 4.3(a) remains unresolved. External TestFlight
approval does not resolve that rejection.

## Current build and evidence

Version **1.2.0 (23)** is available through the
[public TestFlight beta](https://testflight.apple.com/join/E6HdVhTx).
[Signed upload CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37230996262)
checks the signed photo-library/camera purpose strings, version/build and
production-source parity before upload. This replaces the build 12 delivery
that was rejected for ITMS-90683.
[External beta verification](https://github.com/CrispStrobe/CrispMath/actions/runs/37231506974)
records Apple processing **VALID**, beta review **APPROVED**, both audiences
**IN_BETA_TESTING**, and assignment to **Public Beta**. The build ID is
`60f7c784-0eea-42e0-b20a-03bd0befe135`; Apple's `submittedDate` is null.
No App Review submission occurred.

The release and public deployment source is
`637b07ec0e13c428385dc670cdc91f64919777b6` (merged PR #2).
The signed-release gate verifies 372 production files against the completed
feature-validation source `e8920a3dbaf669032901b44d4a00a25fee0c8d8e`, with
production-tree SHA256
`e320ae453970fea84b86c094acc86fe9df0c275e74a92aca90ded84f07800859`.
Subsequent documentation edits preserve these production inputs.

| Evidence | Verified result |
| --- | --- |
| [Final main feature validation](https://github.com/CrispStrobe/CrispMath/actions/runs/37230602280) | Unit, focused, native OCR, release/debug browser and web-gallery jobs pass; all required main builds, format and database checks pass |
| [Linux/WASM math audit](https://github.com/CrispStrobe/CrispMath/actions/runs/37228244814) / [packaged macOS](https://github.com/CrispStrobe/CrispMath/actions/runs/37228248552) | 789 accumulated cases pass on each platform at the identical production source e8920a3; actual macOS version 1.2.0+23 is checked |
| [Pages](https://github.com/CrispStrobe/CrispMath/actions/runs/37230602299) / [Vercel](https://github.com/CrispStrobe/CrispMath/actions/runs/37230684265) | Both actual public deployments report source637b07e and pass 789 runtime cases, all 52 new UI questions, guided workflows and default-off cloud checks |
| [Configured-cloud contract](https://github.com/CrispStrobe/CrispMath/actions/runs/37230602216) | Disposable CI Auth/PostgREST/PostgreSQL checks pass; no production Supabase project is provisioned |
| Full hosted main tests | 5,774 unit/widget tests pass with eight skips; 511 focused feature, 19 guided/audit, 11 cloud-widget and 169 tooling tests pass; three numeric-reference controls run separately; analysis has no issues. Invocations overlap and cannot be summed as unique tests |

See [the eleventh audit](round11-math-audit-52.md) for frozen references,
initial failures and measured repairs. Earlier release history remains in
[HISTORY.md](../HISTORY.md) and the individual audit documents.

There is no Supabase project for this release. Cloud sync stays off by default;
local worksheets, checkpoints and portable backups require no account. This
behavior is explicit in Settings and the cloud dialog in build 23. Real public
checks on desktop, phone and tablet preserve local work through reload and
emit zero backend requests or uncaught errors. They do not verify a production
Supabase service or a physical device.

The published runtime hotfix is CrispEmbed 0.17.12. Native libraries and browser
JS/WASM are pinned to verified checksums, with the staged browser compatibility
repair recorded separately. Recognition remains 7/50 on the unchanged original
handwriting benchmark; the 0/50 candidate model is unshipped. This release makes
no handwriting accuracy claim.

## What to demonstrate to review

Present the connected, persistent worksheet workflow as the concrete product
experience. A public repository, test count, new screenshots or a list of CAS
operations does not by itself establish distinctiveness. The suggestion that
Apple's finding was an automated similarity check is unverified and should not
appear in the response.

These steps use existing, tested actions; the combined sequence is a proposed
review demonstration, not a claim that a physical-device walkthrough has run:

1. Open **Notepad → Document menu → Explore a linked worksheet**. A fresh
   document contains `a=3`, `f(x)=x^2+a`, `f(4)` and result **19**. Existing
   documents remain intact; return to them through the document selector.
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

[Final native gallery CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37230024733)
passes at source `18092e4a75d1de62601793358c6687e2b9a48eea`. The only changes
from validated production source e8920a3 are two native capture helper/test files.
It retains **33 populated captures**:

| Profile | Captures | Dimensions |
| --- | ---: | --- |
| iPhone 15 Pro Max simulator | 11 | 1290 × 2796 |
| iPad Pro 13-inch (M4) simulator | 11 | 2048 × 2732 |
| Native macOS application render tree, at 2× | 11 | 2560 × 1800 |

All 33 captures pass hosted content/image verification. Twelve selected views
are visually reviewed: connected worksheet, traced graph, checkpoint history
and graph export preview for each profile. The latest iOS originals are from
18092e4; the selected macOS images are reused from e8920a3 with exact production
parity and the refreshed macOS manifest independently verified. See
[the selection and provenance](native-apple-gallery.md).
Both fresh owned iOS simulators connect and pass on their first attempt; no
recovery retry is used. This is simulator evidence, not physical-device proof.

The guided worksheet shows a=3, f(x)=x²+a and f(4)=19. Graphs contain cos(x),
x²−2 and the worksheet-linked x²+3. Export previews retain the evaluated
worksheet, linked parabola and sampled values. The optional tank scene still
contains evaluated area and volume. The phone graph toolbar scrolls horizontally;
hosted tests reveal and use trace/table commands.

Use the evaluated worksheet, multiple-function graph, worksheet graph export
preview, and checkpoint-history scenes to show actual use. Keep originals and
source manifests. The macOS captures contain application content without OS
window chrome. Simulator images and native macOS captures do not establish
physical iPhone/iPad behavior.

Apple's [accurate-metadata guidance, including 2.3.3](https://developer.apple.com/app-store/review/guidelines/#accurate-metadata)
requires screenshots to represent the app in use. The captured iPhone/iPad
sizes are listed in [Apple's screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/).
The current 2560×1800 macOS internal images do not match the listed Mac sizes.
A fresh debug-only native recapture now passes all eleven Mac renders at
2560×1600; four selected views are visually reviewed without new clipping.
[Capture CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37239843806)
also passes all22 iPhone/iPad captures and16 capture-tool controls; both fresh
simulators pass first attempt with no recovery. See the gallery selection for
exact original sources; the new Mac images are not resized older captures.
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
| 1 | Guided connected worksheet | Calculate with editable worksheets | Parameter/function rows, result 19 and contextual graph/history/export actions |
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
> functions drive later calculations and linked graphs. Open Notepad, then
> Document menu → Explore a linked worksheet. It creates a=3, f(x)=x^2+a and
> f(4), with result 19. Save a checkpoint, change a to 5 to obtain 21, then
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
  parity and suitable trained weights remain open. Production weights are
  unchanged; the verified normalization/ceil-pooling runtime hotfix is published
  and pinned as 0.17.12, without an accuracy gain. See [handwriting findings](handwriting-quality-findings.md).
  Dataset/weight licenses remain separate from application code, and benchmark
  weights are not shipped as app assets.
- The original guideline 4.3(a) App Review finding remains open. No new App
  Review submission or correspondence is authorized by this preparation file.

## Later physical-device session

Status: **not run**. Use the approved build 23 on both available device types.
Record model, iOS/iPadOS version, install/update path and TestFlight build before
starting; attach the first failing screen and steps rather than marking it passed.

| Check | iPhone | iPad | Expected result |
| --- | --- | --- | --- |
| Launch with cloud unconfigured, then use airplane mode | Pending | Pending | Local calculator/worksheet opens without account or cloud requests |
| Guided worksheet and checkpoints | Pending | Pending | Fresh document; 19 → 21 → 19; existing work retained |
| Link graph, trace and generate table | Pending | Pending | Linked parabola, coordinate and populated table; toolbar commands reachable |
| Background/relaunch and rotate | Pending | Pending | Sources/checkpoints preserved; calculation and graph usable |
| Files worksheet/export/backup round trips | Pending | Pending | Real Files provider saves/imports; source recalculates; backup preserves documents |
| Photo/camera access, allow/deny where requested | Pending | Pending | Clear purpose text when access is requested; picker cancellation/denial preserves work and app remains usable |
| Large text and VoiceOver | Pending | Pending | Full result announced; long result/action sheet can scroll; Copy copies full value |
| Native worksheet shortcut/URL | Pending | Pending | Actual handler opens evaluated worksheet; record Siri separately if configured |
| Pencil and supported multitasking | Not applicable unless supported | Pending | Ink remains editable; split view/stage changes preserve work |

Photo/ink checks establish import and editable input, not successful recognition.
After recording both device results, review the selected display slots and actual
upload files against Apple's screenshot specifications, then review the draft
metadata and notes before a future App Review submission.
