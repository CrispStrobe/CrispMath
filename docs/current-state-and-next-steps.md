# CrispMath and CrispEmbed: current state and executable lanes

<!-- BEGIN CURRENT VENDOR EXECUTION -->
## Vendor execution —29 October2026,11:48 UTC

Read the [current portfolio execution handoff](https://github.com/CrispStrobe/CrispEmbed/blob/main/docs/handoff-2026-10-29.md)
and [precision/task matrix](https://github.com/CrispStrobe/CrispEmbed/blob/main/PLAN.md).
The app remains immutable0.17.12. No new runtime release or quantized qualification.

- **Josev:** [actual final-projection ablations](https://github.com/CrispStrobe/CrispEmbed/blob/main/docs/josev2b-last-projection-v1-result.md)
  complete at3cc96dbab. Q8 final gate/up pair passes the limited discrete/
  probability/ordinal screen (worst probability0.0000433922), but75 strict
  stages and complete serialization remain negative. Single Q4 gate/up recipes
  fail106/105 strict stages and probability gates. All292 critical tensors stay
  F32; other projections F16. No recipe selected; NEW20 remains closed. Calibration source208fbefe is
  ready for review/registration, not yet executed (40 native prefills maximum).
- **MoEdern:** [exact CPUv4/f336 actual capture](https://github.com/CrispStrobe/CrispEmbed/blob/main/docs/moedern-first-row-actual-v4-result.md)
  completes after both ordinary barriers/93 native anchors. All real operator/
  observer/repeat/public-slice controls pass;44 floating Ref stages give39 pass,
  five fail. First strict difference is layer1 row58 top-k: original[2,4],
  native[2,6] after roughly1e-7 unequal probability reordering; final normalized
  max0.02282943/cosine0.99574771 remains negative. Router weights already F32.
  Replay source81fa4e26 is pushed but needs independent review/execution with exact retained inputs,
  no new original/full-model forward. Aggregate original calls8 stay frozen.
- **UltraBERT:** [first Q4 shard40855927708](https://github.com/CrispStrobe/CrispEmbed/blob/main/docs/ultrabert-first-q4-shard0-result.md)
  completes686 rows/1372 public raw-normalized calls. Minimum cosine0.98075227;
  raw max2.76205, normalized max0.0258125; strict vector checks negative.
  Same576,997,440-byte/12-Q4/206-F32 candidate remains unqualified. Remaining
  seven shards/full300-query ranking40871150002 is queued atef7153156; no new
  quantizer/original/F32 forwards. Q8 remains open.
- **Unlimited:** [retained structural proof](https://github.com/CrispStrobe/CrispEmbed/blob/main/docs/unlimited-retained-v3-structural-result.md)
  passes all540 files; actual40859258832 authenticates544 including PNGs,
  builds/profiles pass, then isolated Ref-helper import fails before any model
  forward. Source388c510a0 adds only the exact frozen-helper wrapper;18 bounded
  controls pass. Corrected F16-before-Q4 panel40868634374 is queued at388c510a0. Reuse first
  candidate; last4/all11 and Q8 remain later declared work.
- **MiniCPM:** [seven missing arms40855153707](https://github.com/CrispStrobe/CrispEmbed/blob/main/docs/minicpm-seven-arm-v3-result.md)
  complete: all30 decoded cases exact/zero CER/WER. Combined vision130/180 pass,
  50 fail; F32/F16 each50/60, Q4_K25/30, Q8_0 5/30.96 later crop parts lack
  original tensors. Same-input F32 attribution precedes further precision
  recipes; no original recapture or qualification from high cosine/exact text.
- **WASM:** full norm64 remains rejected16/20 final and6/16 stage checks.
  One-sentence40867038915/ff3 now fails its component compile-profile guard
  before model acquisition or forwards; [initial evidence](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/packaging/wasm-live-norm-initial-build-review.json)
  preserves39 small members. Repair exact target inventory/flags before any
  model capture. All rounding/norm defaults remain unchanged.
- **LFM/typed Gemma:** [source/evidence audit](https://github.com/CrispStrobe/CrispEmbed/blob/main/docs/encoder-precision-evidence-20261029.md)
  distinguishes existing masked230M LFM Q8/Q4 failures from other models;
  mixed330 precision improves but one masked prediction remains wrong.
  Typed Gemma has published Q8 approximation evidence; current-source Q4
  [genuine CPUv1/92ee](https://github.com/CrispStrobe/CrispEmbed/blob/main/docs/gemma-first-q4-cpu-v1-initial-result.md)
  rejects before Q4: all five pooled embeddings pass, but125 saved-stage
  failures and a768-wide bank-adapter error block the F32 barrier. Only the
  design0ee3fb674 is frozen: implement/review it before a three-call first probe.
  Rust/Dart Q8 and broader current-source consumer gaps remain explicit.

Both Q8/Q4_K require actual original intermediates, errors/magnitudes and final
outputs/rankings. Critical-tensor protection follows measured ablations.
Final integrated-source Ovis14/11 on both gates, assets, all public consumers,
platform checks and immutable HF readback remain required. Keep heavy work
hosted, large artifacts remote and machine/access details outside Git.
<!-- END CURRENT VENDOR EXECUTION -->

Consumer snapshot verified5 October2026; vendor roadmap updated25 October2026.
This handoff scopes follow-up work; it does not say the
lanes below have been implemented. Read the status, choose one lane, and record
its exact source, evidence and remaining dependencies before handing it on.
All references are public repository paths, workflow runs or published services.

## What is done

| Surface | Current verified state | Public evidence |
| --- | --- | --- |
| CrispMath main | PRs 1–6 merged; application revision 219eca3c9595284eeda7937848939b47f4ee8574 has successful post-merge platform, CI/CD and iOS runs | [PR 6](https://github.com/CrispStrobe/CrispMath/pull/6), [Feature validation](https://github.com/CrispStrobe/CrispMath/actions/runs/41036815731), [iOS Release](https://github.com/CrispStrobe/CrispMath/actions/runs/41040892621) |
| Apple binary | 1.2.0 (24), source 219eca3c9595284eeda7937848939b47f4ee8574, VALID, assigned to the internal TestFlight group; no external beta review submitted for this build | [Signed upload](https://github.com/CrispStrobe/CrispMath/actions/runs/41040892621), [TestFlight](https://testflight.apple.com/join/E6HdVhTx) |
| Public web | Pages reports 4f45017; Vercel reports 637b07e. The subsequent application change is a DEBUG-only Mac capture-window size, with release behavior unchanged | [Pages](https://crispstrobe.github.io/CrispMath/), [Pages verification](https://github.com/CrispStrobe/CrispMath/actions/runs/37240927177), [Vercel](https://crisp-math.vercel.app/), [Vercel verification](https://github.com/CrispStrobe/CrispMath/actions/runs/37230684265) |
| Mathematical audit | All 789 accumulated cases pass independently on Linux/native, WASM and packaged macOS. All 52 round-eleven references also pass actual desktop/phone UI checks | [Native/WASM audit](https://github.com/CrispStrobe/CrispMath/actions/runs/37228244814), [Mac audit](https://github.com/CrispStrobe/CrispMath/actions/runs/37228248552), [frozen references and initial failures](https://github.com/CrispStrobe/CrispMath/blob/main/docs/round11-math-audit-52.md) |
| Guided workflow and UX | Real menu creates a fresh a=3, f(x)=x²+a, f(4)=19 worksheet; 19→21→19, linked graph, checkpoints, downloads, reload and existing-document preservation pass release/debug on desktop, phone and tablet. Long math and enlarged-text result actions scroll. Chrome is compacted to one row per screen: one search menu (commands, history, clear) instead of a header row, worksheet actions as app-bar glyphs plus menu entries, no per-result accuracy or digit-count lines (result details live in the result's context menu and the optional history help view), and transient undo bars expire | [Guided checks](https://github.com/CrispStrobe/CrispMath/blob/main/tool/check_guided_worksheet_browser.py), [main browser evidence](https://github.com/CrispStrobe/CrispMath/actions/runs/41036815731) |
| Cloud | Off without configuration; local work needs no account. Real browser profiles emit zero backend requests. Configured-cloud tests use a disposable backend, not a production project | [Cloud behavior](https://github.com/CrispStrobe/CrispMath/blob/main/docs/workspace-backups.md), [contract CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37230602216) |
| Native screenshots | 33 populated captures pass: eleven each for iPhone, iPad and Mac. New Mac renders are 2560×1600; four selected Mac scenes are visually reviewed. Both iOS simulators pass first attempt, no recovery; sixteen tool controls pass | [Native run](https://github.com/CrispStrobe/CrispMath/actions/runs/37239843806), [selection/provenance](https://github.com/CrispStrobe/CrispMath/blob/main/docs/native-apple-gallery.md) |
| CrispEmbed app runtime | Published 0.17.12 at 78493a31fc3043f3af4ab6fd2f197a32da6f07f0 contains decoder input normalization and ceil-pooling fixes. Fourteen CPU/Apple/Android/WASM assets have verified release hashes; the app pins the release | [Release](https://github.com/CrispStrobe/CrispEmbed/releases/tag/v0.17.12), [native assets](https://github.com/CrispStrobe/CrispEmbed/actions/runs/37222310628), [WASM assets](https://github.com/CrispStrobe/CrispEmbed/actions/runs/37222310650) |
| Browser OCR packaging | Hosted builds stage the checksummed published JS/WASM. A bounded upstream UTF-8 compatibility patch handles resizable buffers; downloaded/staged JS hashes are separate and WASM unchanged. Actual module/Unicode/heap checks pass | [Staging helper](https://github.com/CrispStrobe/CrispMath/blob/main/tool/stage_ocr_wasm_runtime.py), [model-free browser gate](https://github.com/CrispStrobe/CrispMath/blob/main/tool/check_ocr_wasm_runtime_browser.py) |

Earlier full app validation recorded 5,774 Dart passes/eight skips, 511 focused
feature passes, 19 guided/math passes, eleven cloud-widget passes and clean
analysis. These invocations overlap: do not sum them as unique tests. Prefer
the exact latest workflow reports when recording new totals.

Completed vendor packaging: all four wheel legs,23 installed native-load/C-ABI
checks and aggregation pass [39003273845](https://github.com/CrispStrobe/CrispEmbed/actions/runs/39003273845)
at e75a32f1. No runtime/PyPI release or app pin change.

## What remains open

- Physical-device testing and Apple's September 4.3(a) App Review rejection.
  External TestFlight approval does not settle that rejection. No new App
  Review submission or store-image upload has occurred.
- Handwriting quality: unchanged original benchmark 7/50; expanded-vocabulary
  candidate 0/50, despite 49/50 references being lexically representable.
  Corrections establish bounded forward correctness, not improved recognition.
  Original training-checkpoint/full-sequence parity remains unproved.
- The selective PosFormer source/default restoration is merged via PR72/PR73;
  historical PR60 is closed. Linux published0.17.12 and the current default match
  all50 frozen IDs/text/EOS. A successor release still needs actual portable
  artifacts/hashes and consumer qualification; the app remains pinned0.17.12.
- No production cloud backend is selected. Provisioning one is optional future
  work, not a blocker for offline use or App Review demonstration.

## Execution and evidence rules for every lane

Keep each lane in an isolated change with one owner; coordinate edits to shared
fixtures, workflows, package pins and release metadata. Consult each repository's
PLAN and contributing instructions before changing code. Run builds, full suites,
corpus batches, browser batches, native captures and model benchmarks on hosted
CI. Use authorized GPU infrastructure for training. Keep large models/bundles
remote; fetch only the reports/images needed for review.

Freeze independent references before app outputs. Preserve initial failures and
unchanged historical fixtures. Exercise actual CLI/native/browser paths; do not
inject correct results or weaken comparisons to make a gate pass. Check full
workflow conclusions and explicit assertion reports, not merely step progression.
Distinguish numerical approximations from exact answers, component parity from
decoded quality, simulator checks from device checks, and beta from App Review.

Runtime work must follow the real inference blueprint and compare intermediate
values, magnitudes and final decoded outputs. Keep experimental/performance
paths gated; a speed improvement without equal output is not promotion evidence.
Read [CrispEmbed contribution requirements](https://github.com/CrispStrobe/CrispEmbed/blob/main/docs/contributing.md)
and [model policy](https://github.com/CrispStrobe/CrispEmbed/blob/main/POLICY.md).

Every finished lane delivers a bounded patch, meaningful positive/negative
regressions, exact source/workflow links, retained initial/final evidence and
updated status here and in both affected PLAN files. Never publish host paths,
credentials, private service references or operator contact details.

## Vendor status — updated 25 October 2026

[Executable next-agent tasks](https://github.com/CrispStrobe/CrispEmbed/blob/main/docs/next-agent-handoff.md) give exact sources, tool paths,
corrected audit, artifact expiry and acceptance checks. [PLAN](https://github.com/CrispStrobe/CrispEmbed/blob/main/PLAN.md) contains
pending work, [HISTORY](https://github.com/CrispStrobe/CrispEmbed/blob/main/HISTORY.md) completed milestones and every initial
failure, [PERFORMANCE](https://github.com/CrispStrobe/CrispEmbed/blob/main/PERFORMANCE.md) numerical/quality/storage limits.
Completed wheel/source changes and test-only UltraBERT tools are integrated;
merged-source platform CI and Pages/live metadata verification pass (HISTORY23 October).
The app remains pinned to immutable0.17.12, not vendor main.

| Front | Verified result | Remaining work |
| --- | --- | --- |
| Wheels | All4 platform legs/23 installed native-load/C-ABI checks/aggregation pass at e75a32f1 | Version/release reconciliation and any future PyPI publication are separate |
| Social preview | PR68 merged after native/Flutter/WASM/secret success | Completed deployment39009694992 at f6f84aba; live HTML/PNG verified23 October |
| UltraBERT source/conversion | All218 tensors in both F32/F16 exports and original7-case/2,730-stage capture pass | Gated CPU/F32 text dispatch mergedPR74; PR75 Rust/Dart wrapper integration merged2f078406 after actual39979622930; pairs, numerical attribution and release gates remain |
| UltraBERT tokenizer | All8 native BPE/test-template rows match original IDs/masks; both wrong alternatives fail8/8 | Scoped public F32 IDs/masks pass; pair/reserved-token profiles remain separate |
| UltraBERT numerical | Initial14-arm panel/700 exact controls complete,183 F32/1,294 F16 numerical failures retained | [Corrected local audit39009703362](https://github.com/CrispStrobe/CrispEmbed/actions/runs/39009703362) complete: all21 F32 local probes pass; six F16 down failures; reference/projection attribution and both strict replay failures remain |
| OCR quantization | Original/F16 plus all9 independent Q8/mixed/Q4 audits and auditor controls complete | No tested recipe qualifies; retained numerical/recognition/format/cap debt blocks promotion |
| LFM2.5 Encoder | Official F16 CPU/CUDA T4 audit passes594 direct checks and both15-case ordinary API panels; [full report](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/lfm2-encoder/cuda-f16.json). Paired v2 performance passes independent recipe/placement/hash/420-sample review; all15 cases faster on CUDA in one T4 session | Pooled9/20/649-token medians27.93x/27.64x/120.11x are session-scoped; other GPU/precision/MMQ, throughput, long-context and task quality remain open; GPU default unchanged |
| Typed Gemma | Integration/publication completed in its model document | Independent task quality, GPU and performance remain open |
| Permissive OCR queue | OvisOCR2 export/frontend/original GPU pass; reviewed [native40049244654](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/qwen35-ocr/ovisocr2-model-audit.json) passes14/14 F32/F16 arms on943 frozen fields, [public40053283383](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/qwen35-ocr/ovisocr2-public-surfaces.json) passes27 C/Python/CLI/HTTP/Rust/Dart arms, [original HF eleven-case quality40054043629](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/qwen35-ocr/ovisocr2-original-quality.json) is frozen, and [first native F16 quality40056641800](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/qwen35-ocr/ovisocr2-f16-quality.json) has a positive independent eleven-case review | [Protected Q8 40061433357](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/qwen35-ocr/ovisocr2-q8-quality.json) is complete and rejected for numerical and two-column text regression. All four quantization attempts are rejected; qualified F16 is selected. F16 publication40074370335 and immutable readback pass; real precision alias is wired. Published CLI/HTTP/offline consumer40080458492 passes; PR79 and final platform/Flutter/WASM/style/security checks are integrated. The bounded latency/RSS attribution is complete; next performance work is a separately gated, byte-budgeted converted-weight reuse experiment. Initial12/14 vision failures and four strict0.002 exceedances remain recorded; F16 publication and actual source alias consumer are verified. Indra public-code-only |
| PosFormer/app | PR73 merged75e87ea6 after all source790f9a6b checks; unset/1 trained,0 legacy. Actual Linux released/default50-case outputs and bounded references pass | Successor native/WASM artifacts/hashes and consumer qualification remain separate; app stays0.17.12 |
| Development desktop bundles | [PR76](https://github.com/CrispStrobe/CrispEmbed/pull/76) merged1f8ff4d5; [39979940916](https://github.com/CrispStrobe/CrispEmbed/actions/runs/39979940916) passes Linux/macOS/Windows CPU-baseline configure/build/smoke/install | [Flag/log review](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/packaging/development-cpu-baseline.json) is scoped to development bundles; successor release assets and cross-host consumer checks remain |

UltraBERT original arrays were verified and copied by preservation39913800444;
the remote copy expires21 January2027. Original producer/manifest/payload
identities remain unchanged. [Preservation provenance](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/ultrabert/reference-preservation.json).
Numerical replay drift and cause remain unresolved. Component cosine, exact
tokenizer IDs or local operator agreement do not establish full model/task quality.
Default-off CPU/F32 public text support merged viaPR74 at3f3d023a after complete
source4be9f864 platform/Flutter/WASM/style/security checks. Hosted39943940607
passes actual C API/Python/CLI/HTTP and all twelve pooled/seven text-row checks.
[API evidence](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/ultrabert/public-f32-api.json). Original-first
retrieval39950831201 at812e56e5/native4be9f864 passes all32 IDs/64 vectors and
8/8 exact top1; original/native Recall@1/MRR@10/NDCG@10 all1.0. Raw max7.34e-5,
normalized5.51e-7, minimum cosine0.999999999999019. [Full smoke evidence](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/ultrabert/retrieval-smoke.json).
This authored panel does not establish representative MTEB/BEIR quality.
Actual Rust/Dart39979622930 passes all seven rows/42 pooled checks; PR75 merged
at2f078406. [Reviewed binding evidence](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/ultrabert/public-bindings.json)
retains raw maxima6.723403930664062e-5/5.941838026046753e-7/6.07222318649292e-7
for raw/dense/normalized-token CLS, both languages, and all14 binding ID rows.
Public pairs, long-context/GPU/performance and validated
quantization/publication remain U3/U4. Initial harness failures and183/1294
intermediate failures are retained. No new runtime tag/model alias/app pin.
The [M1 native handover](https://github.com/CrispStrobe/CrispEmbed/blob/main/docs/handover-m1-ultrabert-f32-api.md) supplies
complementary Apple coverage, with no repeated Python audit. Original-backend reproducibility39915714794 completes all four controls without
recovering frozen anchors. The [M1 follow-up](https://github.com/CrispStrobe/CrispEmbed/blob/main/docs/handover-m1-validation.md) is complete:
raw/normalized CLS max6.52e-5/6.41e-7, long hidden0.00579. Independent review
checks all returned stage identities and same-input hashes. Preserve the full audit
and scope F32 pooled-output/API/retrieval qualification separately; no repeated arms.
Selective PosFormer [PR72](https://github.com/CrispStrobe/CrispEmbed/pull/72) is
merged at7f1ecd33 after full sourcef7c53803 platform/Flutter/style/security and
bounded original/exported-weight reference success. PR60 is closed. Development
manifests0.17.13 are not a release or app upgrade. The new main integration runs
are separate checks. Released-binary compatibility is measured; PR73 default restoration merged75e87ea6 after full exact-source CI. Atomic
release/consumer qualification remains open.
Other portfolio/app owners remain separate.

## Recommended order and dependencies

W1 packaging is complete and archived in [HISTORY](https://github.com/CrispStrobe/CrispEmbed/blob/main/HISTORY.md).
Continue vendor UltraBERT tasks from [the executable handoff](https://github.com/CrispStrobe/CrispEmbed/blob/main/docs/next-agent-handoff.md);
V1 (selective PosFormer reconciliation) remains a separate bounded change.
M1 (fresh mathematics) and U1 (UX coverage) can proceed independently on hosted
runners. O1 can extend diagnostics now; O2 waits for checkpoint/license/access
requirements. P1 waits for a device session; A1 follows P1 and final metadata
review. R1 is used only when a production app change is ready to ship. C1 and
F1 require an explicit backend/product decision. B1 is an optional bounded
math-engine investigation, not a reason to rebuild everything immediately.

### V1 — Qualify actual successor assets and consumer behavior

**Repository:** CrispEmbed. **Source/default restoration complete; release gate open.**

Selective source PR72 merged7f1ecd33; historical PR60 closed without merging its
old release branch or moving the0.17.12 tag. [PR73](https://github.com/CrispStrobe/CrispEmbed/pull/73)
merged at `75e87ea6d0a5bbb1b3fb06362e05135b0a77b47d` after all exact-source790f9a6b
platform/style/security/WASM and ten [Build/Flutter jobs39933251542](https://github.com/CrispStrobe/CrispEmbed/actions/runs/39933251542)
pass. `CRISPEMBED_POSFORMER_TRAINED_FORWARD` is captured at model init: unset/1
select the trained correction, matching published0.17.12; literal0 retains legacy.

[Hosted39933245147](https://github.com/CrispStrobe/CrispEmbed/actions/runs/39933245147)
and independent raw-report review pass actual unset/released Linux0.17.12
IDs/text/EOS/confidence for all50 cases, unset/1 and zero/legacy agreement,
public API/printed regressions, primitive controls and both five-case/five-step
exported-F32/original-code reference paths. Recognition remains7/50; original
training-checkpoint/BN and unrestricted full-sequence parity are unproved.
[All raw reports/limits](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/posformer/released-default-validation.json).
Earlier actual-binary comparison retains up to2.0265579223632812e-6 confidence
drift, without fitting a tolerance or claiming general bitwise parity.

Before a successor tag, build portable native/WASM release assets using the
release workflow's CPU-baseline gate; verify archive/library hashes and normal
consumer behavior on each affected platform. Include an actual Apple released/
new-default binary comparison; Linux evidence does not certify an Apple asset.
Preserve native per-case logs in future producer artifacts; this run retains
hashes but did not upload those logs. Exact source checks do not replace actual
artifact qualification. Development0.17.13 creates no tag, publication or app pin
change; the app remains on immutable0.17.12.

### M1 — Fifty new independent mathematical problems and systemic repairs

**Repository:** CrispMath. **Ready now.**

First read the [round-eleven reference/failure record](https://github.com/CrispStrobe/CrispMath/blob/main/docs/round11-math-audit-52.md)
and prior corpus only to avoid semantic duplicates. Draft fifty fresh problems
with independently derived full answers, domains, multiplicities, dimensions
and rounding tolerances before running the app. Cover symbolic branches/domain
holes, calculus endpoints, matrices/systems, statistics tails, composite units
and complete constraint solutions. Include failures and unsupported boundaries.

Freeze a round-twelve reference document and fixtures in Git. Extend the actual
[CLI audit](https://github.com/CrispStrobe/CrispMath/blob/main/tool/crispmath_cli.dart),
[runtime workflow](https://github.com/CrispStrobe/CrispMath/blob/main/.github/workflows/workflow-task-audit.yml),
[packaged Mac audit](https://github.com/CrispStrobe/CrispMath/blob/main/.github/workflows/build-macos.yml)
and [strict UI checker](https://github.com/CrispStrobe/CrispMath/blob/main/tool/check_round11_math_browser.py)
for the new fixtures. Register them in deployment checks as well; a fixture
unreferenced by a workflow is not coverage. Keep all 789 old cases unchanged.

Preserve the first outputs; trace each discrepancy through parser, dispatcher,
engine, numerical method and presentation before patching the responsible layer.
Add a negative control for every checker change and a real UI regression for
each entry-point/presentation gap. Require complete sets/matrix cells, genuine
factor structure and visible precision rather than text fragments.

**Done when:** all 839 accumulated cases have explicit native/WASM/Mac outcomes,
every new question has an actual UI check or a documented limitation, required
units/analysis pass, and Pages/Vercel Playwright checks prove deployed behavior.
Report genuine unsupported tasks as open; do not silently drop or redefine them.

### U1 — Accessibility, localization and narrow-layout coverage

**Repository:** CrispMath. **Ready now; coordinate shared UI edits with M1.**

Begin from the [guided checks](https://github.com/CrispStrobe/CrispMath/blob/main/tool/check_guided_worksheet_browser.py),
[native gallery test](https://github.com/CrispStrobe/CrispMath/blob/main/integration_test/product_gallery_test.dart)
and result presentation regressions. Audit real graph controls, photo/ink import
dialogs, variable/function editing and export dialogs on phone/tablet/desktop
at normal and enlarged text, and in English/German/French/Spanish. An off-screen
item in an intentional scroll region is not by itself an overflow defect.

Record failures before editing. Fix shared layout/action helpers where several
flows share a cause. Preserve complete accessible values and actual clipboard
payloads. If adding a graph scroll affordance, prove it exposes real trace/table
commands without covering the plot. Use stable real clicks and rendered geometry,
not forced clicks, retries masking errors or injected state.

**Done when:** observed defects have targeted widget controls and real release/
debug browser checks, no framework/page errors, readable populated screenshots
and reachable final actions. Physical VoiceOver verification belongs to P1.

### O1 — Complete the handwriting diagnosis before choosing new weights

**Repositories:** CrispEmbed runtime; CrispMath benchmark/consumer. **Partly ready now.**

Read the [measured findings](https://github.com/CrispStrobe/CrispMath/blob/main/docs/handwriting-quality-findings.md)
and [independent reference run](https://github.com/CrispStrobe/CrispEmbed/actions/runs/37221078035).
Preserve the frozen fifty references, rasterization, image/model hashes and
token scoring. Bounded exported-FP32 comparisons account for 270 tensors,
45 encoder and 275 decoder stage comparisons per arm. They do not prove the
original training checkpoint or unrestricted autoregressive decode.

Inspect [conversion](https://github.com/CrispStrobe/CrispEmbed/blob/main/models/convert-posformer-to-gguf.py),
[runtime](https://github.com/CrispStrobe/CrispEmbed/blob/main/src/posformer_ocr.cpp)
and [app reference harness](https://github.com/CrispStrobe/CrispMath/blob/main/tool/handwriting_reference_parity.py).
Extend bounded coverage through preprocessing, positional conventions, masks,
token IDs, EOS/length handling and complete decoded outputs. Compare magnitudes
as well as cosine; localize the first actual divergence. Keep probe code out
of production artifacts. Separate FP32 structural parity from Q8 drift.

**Done when:** a pinned full-sequence reference and runtime agree on the same
inputs or the first remaining divergence is reproduced with a regression.
Original-checkpoint checks require legitimately accessible weights. If unavailable,
finish available exported-weight diagnostics and record that dependency instead
of repeating blind encoder changes or claiming recognition is fixed.

### O2 — Obtain and evaluate suitable licensed recognition weights

**Repositories:** CrispEmbed conversion/training; CrispMath consumer. **Conditional.**

Depends on O1's inference contract and legitimate checkpoint/dataset access.
Start by verifying the real checkpoint architecture, vocabulary and license
chain; a public GGUF or wider token dictionary alone is not proof of provenance
or quality. Use the existing [training tools](https://github.com/CrispStrobe/CrispEmbed/tree/main/tools/kaggle/posformer-train)
only after confirming they match the verified inference path and authorized
remote resources. Split training/evaluation data without reusing the frozen
fifty examples for training or parameter selection.

Produce pinned conversion/reference artifacts and compare decoded results with
the unchanged baseline plus a separate held-out corpus. Record exact matches,
error categories, invalid/empty output, latency/memory and numeric handoff.
Require a predeclared quality threshold; never substitute benchmark success
for user review. Do not add the current 0/50 candidate to the default catalog.

**Done when:** provenance/licensing, reference parity and held-out quality justify
a separately reviewed model promotion, with opt-in/rollback controls and no
unverified reliable-recognition claim. No training has been authorized by this
handoff document itself.

### P1 — Physical Apple device session

**Repository:** CrispMath. **Waiting for the deferred device session.**

Use approved build 23 from [TestFlight](https://testflight.apple.com/join/E6HdVhTx)
and follow the [device matrix](https://github.com/CrispStrobe/CrispMath/blob/main/docs/apple-review-evidence.md#later-physical-device-session).
Record device model, OS, install/update route and actual build; exercise offline
guided 19→21→19, graph trace/table, background/relaunch/rotation, Files round trips,
photo/camera cancellation and permission behavior, enlarged text/VoiceOver,
native URL/shortcut behavior, and supported Pencil/multitasking.

**Done when:** both device categories have recorded results and first-failure
reproductions, with fixes re-tested on the affected device. Simulator/Python CI
must not be entered as a physical pass. Ink/import tests do not prove recognition.

### A1 — Finish store presentation and resolve App Review 4.3(a)

**Repository:** CrispMath. **Drafting is ready; submission is deferred.**

Start with the [review packet](https://github.com/CrispStrobe/CrispMath/blob/main/docs/apple-review-evidence.md)
and [native selection](https://github.com/CrispStrobe/CrispMath/blob/main/docs/native-apple-gallery.md).
Keep the connected parameter→function→graph→checkpoint→export narrative. Select
actual populated images with original source manifests and supported slots;
Mac files must use listed 16:10 dimensions. Check every description against the
current binary, default-off cloud behavior and experimental handwriting limits.
Remove unsupported feature/reliability claims from any proposed store text.

After P1, assemble the exact screenshots, description and review response for
review. Explain concrete distinct workflow/content; do not allege an automated
similarity check or use source-line/test counts as proof of distinctiveness.
The next agent may prepare drafts; sending correspondence, uploading store
metadata/images and a new App Review submission need the user's explicit scope.

**Done when:** the packet matches a tested binary and verified device/screenshots;
after an authorized submission, record Apple's actual response. Do not mark the
4.3(a) rejection resolved merely because the beta is approved.

### R1 — Promote the next production app change through all release gates

**Repository:** CrispMath; coordinate a dependency change with CrispEmbed. **Conditional.**

Use only after a production change from another lane is ready. Inspect the
[release workflow](https://github.com/CrispStrobe/CrispMath/blob/main/.github/workflows/ios-release.yml)
and [validation/source guard](https://github.com/CrispStrobe/CrispMath/blob/main/tool/wait_release_validation.py).
Bump the build number for a new Apple binary; never reuse23 after its upload.
Pin a vendor successor's source/version and published native/WASM hashes
atomically, preserving the UTF-8 staging provenance and model-free module gate.

Require appropriate units/analysis, accumulated CLI and actual UI audits,
release/debug browser checks, supported native screenshots, packaged metadata
and deployed Pages/Vercel evidence on the real candidate. Validate privacy
purpose strings inside the signed app. Upload once, wait for actual Apple VALID
processing, then perform metadata-only internal/external assignment checks.

**Done when:** exact-source gates pass, deployed fingerprints are recorded and
the authorized new beta has read-back evidence. Do not rebuild/reupload for a
retry of metadata assignment, for documentation, or the DEBUG-only capture fix.
App Review remains a separate action in A1.

### C1 — Optional configured-cloud deployment

**Repository:** CrispMath. **Waiting for an explicit backend choice.**

Keep cloud off by default. Do not create a project just to make an optional
checklist green. If cloud is selected, use the [workspace contract](https://github.com/CrispStrobe/CrispMath/blob/main/docs/workspace-backups.md)
and [disposable CI contract](https://github.com/CrispStrobe/CrispMath/blob/main/.github/workflows/sync-backend-contract.yml)
as the starting point. Receive configuration through a secure mechanism;
publish no service-role keys, credentials, sessions or operator identities.

Verify migration/RLS with two independent users, then real authenticated
devices/browsers with a local worksheet evaluating to 21 and a separately
imported/cloud worksheet evaluating to 23, preserving both conflicting versions,
reload/offline recovery, safe sign-out, cancellation, cleanup and backup round
trips. Re-run fresh unconfigured profiles to ensure zero backend requests.

**Done when:** real chosen-backend/two-device evidence exists without losing
local work; otherwise record this lane as intentionally unconfigured, not broken.

### B1 — Optional math-stack capabilities and plotting performance

**Repositories:** CrispMath and its publicly declared math-stack dependency.
**Investigation ready; implementation needs a bounded demonstrated use case.**

Start with [CrispMath PLAN](https://github.com/CrispStrobe/CrispMath/blob/main/PLAN.md)
and [dependency declarations](https://github.com/CrispStrobe/CrispMath/blob/main/pubspec.yaml).
Measure a real repeated graph-evaluation or rigorous-numerics workload before
proposing LLVM/ARB changes. ECM/PRIMESIEVE are conditional on an observed large
factorization limitation. Follow the dependency's own public build instructions;
do not guess its repository or enable all optional libraries together.

Change one capability at a time, preserve fallback behavior and compare the
same results/domains, latency, memory, startup and binary size across native
and WASM. Run hosted build/package/CLI/UI controls and document unsupported
platforms. A faster benchmark with changed output is not a successful default.

**Done when:** a bounded use case has a measured improvement and passing parity,
or a reproducible finding explains why the capability remains disabled.

### F1 — Future collaboration/product expansion

**Repository:** CrispMath. **Needs a separate product/backend decision.**

The older plan's multi-user editing proposal is not part of the shipped app.
First define the collaboration unit, offline ownership, conflict policy and
account/privacy model. Preserve portable local worksheets and source-only
imports; do not turn the default-off backup service into mandatory login.
Build a small disposable-backend two-editor prototype before proposing a
production service, with deterministic concurrent-edit and recovery tests.

**Done when:** the prototype has reviewed semantics and real two-client tests;
a production rollout has its own authorized scope, migration and device gates.
Do not treat this longer-term idea as an unfinished build 23 feature.

## Ovis follow-up outcomes — 25 October 2026

Profiling, source feasibility, selective quantization and larger-input audits
have reviewed outcomes, including the OvisOCR3 paired/interface diagnostics.
The remaining work is source-quality/numerical attribution and the separately
scoped implementation, benchmark, preservation and immutable-release lanes. Use the [executable vendor handoff](https://github.com/CrispStrobe/CrispEmbed/blob/main/docs/next-agent-handoff.md) and
[PLAN](https://github.com/CrispStrobe/CrispEmbed/blob/main/PLAN.md) for current dependencies. The application remains pinned to
published0.17.12; development0.17.13 and model experiments do not upgrade it.

- [Profile40171223309](https://github.com/CrispStrobe/CrispEmbed/actions/runs/40171223309)
  is independently reviewed: three alternating off/on pairs preserve all nine
  IDs, raw text, EOS and probabilities. Median wall time is38.108/38.058 seconds,
  with about3.32 GiB process RSS including load. Eight decode steps materialize
  24.06 GB of F32 data, spending11.16 seconds materializing versus0.57 computing
  projections. Nested counters are not additive and this is no broad speed claim.
  [Full evidence](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/qwen35-ocr/ovisocr2-profiling.json).
- [Issue71 feasibility](https://github.com/CrispStrobe/CrispEmbed/blob/main/docs/inpainting-feasibility.md) is complete at source level.
  MI-GAN has explicit MIT code/weight terms; one independently implemented fixed-
  resolution graph with original RGB/mask/block/output references is the first
  bounded prototype. Payload identity and any copied helper notices remain gates.
  LaMa checkpoint terms and FFT/complex implementation remain unresolved.
  No inpainting execution, video-quality claim or issue closure follows.
- [Attention-F16/FFN-Q4 attempt40172527229](https://github.com/CrispStrobe/CrispEmbed/actions/runs/40172527229)
  is complete and rejected. Its72 FFN matrices use Q4_K;401 tensors, including78
  attention matrices, remain byte exact. The first full layer has max error
  0.0328895 despite global cosine0.999563; receipt and two-column CER/WER regress.
  [Four-attempt selection](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/qwen35-ocr/ovisocr2-quant-attempts-v2.json)
  keeps the published F16 candidate. Independent same-quantized-weight operator
  attribution precedes any newly declared precision-selection protocol.
- [Larger-input audit40177774574](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/qwen35-ocr/ovisocr2-larger-inputs.json)
  is complete: frozen/1024-square/1200-landscape pass14/14;2048 boundary passes8/14.
  Six composed decoder arms fail prefill/full-prefix norm, F32/F16 max
  0.003945589/0.004386902, despite exact nine IDs/text/EOS. Original-embedding
  replay passes; root cause remains open. The2048 experiment stays unqualified,
  default1024 unchanged. All four full producer reports are retained in Git.
  [Final-source frozen14](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/qwen35-ocr/ovisocr2-final-runtime-frozen-replay.json)
  and [eleven-case F16 replay](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/qwen35-ocr/ovisocr2-final-runtime-f16-quality.json)
  pass with exact1,841 first-F16 outputs, stops and confidences.
- OvisOCR3 actual controlled T4 execution, processor anchors and original943-stage
  CPU/F32 capture are reviewed. [Final-source native14](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/qwen35-ocr/ovisocr3-native-model.json)
  passes14/14 with exact nine-ID smoke output and profile-bound isolation.
  Its original plain OCR11 capture is complete, but two-column output caps1024
  without EOS (CER0.52365/WER0.83993). [Paired F16 run40187405735](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/qwen35-ocr/ovisocr3-f16-quality.json)
  faithfully matches all11 cases/1,679 IDs/raw text/stops/caps. [Public-interface
  diagnostic40196755934](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/qwen35-ocr/ovisocr3-public-diagnostic.json)
  passes all29 recorded checks across six clients, ABI/cache and negative guards.
  It retains model-qualified=false/publication-eligible=false. The initial
  missing-artifact-name dispatch failed safe before dependencies/model transfer/build.
  A faithful diagnostic cannot override source-quality failure: no qualification,
  model alias or publication. Preserve unchanged prompts/gold/caps/scorers.
  [Original quality evidence](https://github.com/CrispStrobe/CrispEmbed/blob/main/tests/results/qwen35-ocr/ovisocr3-original-quality.json).
