# Stable result references in Notepad

## Scope and status — 10 November 2026

Application checkpoint
[`63fbffa`](https://github.com/CrispStrobe/CrispMath/commit/63fbffad6e9e292da0c1fa17e5fe2b78c9e92b22),
tree `bcba66e3408e0830a19da5e782f3101774ef2613`, passes the complete
[release and debug browser workflows](https://github.com/CrispStrobe/CrispMath/actions/runs/42829214370)
on desktop and phone. References can be inserted, extended by typing, followed
back to their source, recalculated, deleted/undone, duplicated and reloaded
through actual controls, with zero page errors. Strict analysis and all 63
tests in the two affected widget files pass. All six platform builds, Docs
freshness and format preview pass for the unchanged application source.
**Functional acceptance is complete; PR22 remains a draft.** The row-scoped
tooltip workaround resolves the previously reproduced phone Undo failure in
the complete debug workflow.

The test-only follow-up
[`da8c6e9`](https://github.com/CrispStrobe/CrispMath/commit/da8c6e92a459a5267e2baf1ca1d3fa4884f76ed6),
tree `d6fab0fde51ee60f465b57ad9c81abbf5829e28a`, corrects obsolete tooltip-based selectors in
`test/notepad_screen_test.dart`. It changes no application source; the browser
results remain applicable. Its strict analysis and focused retry pass. The
original full-suite 6,045 passes/eight failures/eight skips and focused
55 passes/eight failures are retained below. These separate runs do not
establish a combined full-suite pass.

This is the second connected-worksheet increment on
[PR 22](https://github.com/CrispStrobe/CrispMath/pull/22), following the merged
[Notepad and graph work](connected-notepad.md). Dependency pins, release
metadata and existing `lineN` semantics are unchanged. The
[permanent evidence receipt](evidence/notepad-stable-references-20261110.json)
records exact sources, results and retained failures. This is feature-branch
validation, not a release, deployment or physical-device claim.

## User workflow

Calculate a value, open its result menu, and choose **Use result**. A new row
starts with a live reference to that result. Complete the expression, for
example by multiplying it by two. Editing the original calculation updates the
dependent row; inserting or moving other rows does not change its target.

**Copy result** still copies a value. The document menu's **References…** action
offers usable results by their current line number, source, and value. It
replaces the remembered editor selection, or appends a new row if there is no
valid destination. References displayed under a row provide navigation back to
their source, including a source in a
collapsed section or outside the current viewport.

The initial stable-reference feature supports results of ordinary expressions,
scalar assignments, and aggregates. Function definitions remain callable by name.
Plots, document structure, and FlatZinc's multi-output display are not scalar
reference targets. References belong to one document.

Worksheet-row icons currently have no floating hover captions. A row-scoped
tooltip workaround avoids an SDK overlay reactivation failure during structural
edits. Delete retains its localized accessible label, both graph-action layouts
retain their explicit label, and section controls retain their labels. Source
chips keep readable labels and an accessible hint. Tooltips outside worksheet
rows are unaffected.

## Identity and mathematical meaning

Editable source stores `@{row-id}`, using URI encoding for the persistent row
ID. The picker and source links show readable labels. Plain source editing
still exposes the explicit token; the text controller does not disguise it
with a shorter label that would change selection or input-method offsets.

The reference means the source row's current unformatted mathematical result.
It participates in dependency ordering, incremental invalidation, cycle
detection, and result-accuracy propagation. It is not a copy of the source
expression and must not be rebound by unrelated scalar assignments in its
consumer. Calculus and plotting may operate on the referenced symbolic result.

Legacy `lineN` aliases remain positional. No existing saved expression is
silently migrated. New stable references use explicit syntax and existing row
identities, so no document-schema version change is required.

| Event | Required behavior |
| --- | --- |
| Insert or reorder rows | The target remains the same row; its displayed line number changes. |
| Edit source | Recalculate dependent results and plots. |
| Delete source | Clear the dependent output and identify a missing source. |
| Undo deletion | Restore the original identity and allow the reference to recover. |
| Source failed or has no calculated output | Show an unavailable/blocked result; never reuse an old value. |
| Self-reference or cycle | Report the cycle using the existing dependency machinery. |
| Malformed token | Report invalid reference syntax during evaluation; tolerate incomplete input while displaying the editor. |
| Duplicate source IDs | Reject ambiguous resolution instead of choosing one row. |
| Comment or quoted text | Keep token-like text literal. |
| Paste a token into another document | Resolve only if that document has its target; never search unrelated documents. |

## Copy, import, undo, and sharing

Every independent document copy allocates all destination row IDs first, then
rewrites internal references with the complete mapping. This includes forward
references. The shared copy helper preserves input mode, pinned state, and
result formatting, while discarding calculated caches for local recalculation.

The document menu, Notepad manager, worksheet-file import, JSON import, and
workspace conflict-copy path use that helper. Missing references remain
missing. Ambiguous imported identities are rejected. Repeated backup imports
compare reference targets by their local row positions, so newly generated IDs
do not create another identical conflict copy.

Ordinary persistence, checkpoints, and full workspace restore retain existing
identities. Undo/redo retains the initial source of inserted reference rows and
the before/after text of reference edits.

Editable `.crispmath` files retain stable tokens. Static Markdown, HTML, LaTeX,
and PDF content gives referenced outputs labels such as `result[3]`, with the
same label attached to the source calculation and its consumers. These labels
belong to that snapshot; they are not a new executable positional syntax.
Missing and unavailable sources are described explicitly.

## Acceptance evidence

Focused engine regressions cover identity through reorder, forward references,
source edits, missing/invalid targets, cycles, lexical binding, plot bounds,
linked graphs, and result provenance. Model/file/backup regressions cover copy,
import, checkpoint restore, and repeated conflict import. Widget regressions
exercise the real result menu, reference picker, undo/redo, and source reveal.

`tool/check_notepad_references_browser.py` enters data through actual controls
on desktop and phone layouts. Storage reads are evidence only; source documents
and calculated results are not injected.

### Current application checkpoint: `63fbffa`

| Scope | Observed result | Evidence |
| --- | --- | --- |
| Analysis and full suite | Clean analysis (43.9 seconds); 6,045 passed, eight failed, eight skipped. All eight failures occur at obsolete tooltip-based action selectors. | [Source-matched CI](https://github.com/CrispStrobe/CrispMath/actions/runs/42829156775/job/129874390477) |
| Platform builds | Web, macOS, Windows, Linux, Android and iOS pass. Docs freshness and format preview also pass. | [Candidate checks](https://github.com/CrispStrobe/CrispMath/commit/63fbffad6e9e292da0c1fa17e5fe2b78c9e92b22) |
| Original focused widgets | 55 passed/eight failed at the same obsolete selectors; these overlap the full suite. The job correctly fails its widget gate. | [Release job](https://github.com/CrispStrobe/CrispMath/actions/runs/42829214370/job/129874506764) |
| Test-only corrected retry | `da8c6e9` changes only the affected test file. Full analysis passes in 43.5 seconds; all 63 tests in both affected widget files pass in 45 seconds, including phone hover/Delete/Undo. | [Strict retry](https://github.com/CrispStrobe/CrispMath/actions/runs/42832203169/job/129884887253) |
| Release graphs and references | Both complete workflows pass on desktop 1280×900 and phone 390×844, with zero page errors, despite the independent widget-gate failure. | [Release job](https://github.com/CrispStrobe/CrispMath/actions/runs/42829214370/job/129874506764) |
| Debug graphs and references | Both complete workflows pass on desktop 1280×900 and phone 390×844, with zero page errors. Phone Undo restores original IDs and the visible result; independent duplicate/edit and reload pass. | [Debug job](https://github.com/CrispStrobe/CrispMath/actions/runs/42829214370/job/129874506249) |

Isolated acceptance uses workflow commit `0c7a5e5` and verifies that its only
change from application `63fbffa` is the acceptance workflow. The PR test-merge
commit `7923636ce1c9c97356452220a5a70b7da267e9bb` has the same entire Git tree as
the application checkpoint. These source checks bind results to the app; they
do not mean the draft PR has merged. The broader Linux Feature validation jobs
are not counted as passed while queued.

The eight native/focused failures concern phone Undo after hovering Delete,
collapsed-source navigation, deletion feedback/Undo/redo and visible search
counts. They cannot locate controls through the suppressed tooltip nodes, so
they fail before performing their intended action. The test-only correction
uses the existing accessible Delete and section labels; all 63 tests in the two
complete affected files now pass. The strict workflow `af739f7` verifies both
the workflow-only difference from `da8c6e9` and the test-file-only difference
between `da8c6e9` and application `63fbffa`. Its evidence artifact is
`13771808421`. The automatic full-suite rerun
[42832019698](https://github.com/CrispStrobe/CrispMath/actions/runs/42832019698)
was in progress at 14:21 UTC and is not included as a passing result. The
focused count is kept separate from the earlier full-suite count.

### Retained failures and bounded corrections

Earlier runs found a picker destination lost across menu blur, then native
keyboard focus lost after **Use result**. A read-only same-bundle trace at
`90d80b6` recorded the surviving textarea's semantic ancestor changing before
the original keys reached BODY. Semantic containment and FocusNode lifecycle
corrections at `ca24eb3` restored typing, but debug source deletion then exposed
a shown-tooltip reactivation assertion. The same application passed a native
control without a shown tooltip and failed when the tooltip was explicitly
shown; the full stack identifies `OverlayPortal` reactivation.

Removing the source-chip Tooltip at `43d0030` retained its semantic hint and
the picker's source description. That checkpoint passed 6,052 native tests
with eight skips, all six builds, 62 focused widgets and complete release
acceptance. Its debug retry passed the complete desktop lifecycle, but phone
Undo restored original IDs and results 9/19 in storage before the visible list
threw `_RenderLayoutBuilder0 was mutated in RenderSliverList.performLayout`.
The later phone copy/reload stages were not reached at that source.

The unchanged-source phone regression
[42828479928](https://github.com/CrispStrobe/CrispMath/actions/runs/42828479928/job/129871933282)
reproduced that failure after verifying the original pointer lay over the
surviving Delete control and its **Delete line** tooltip was visible. Its
captured exception supplies the test expectation stack, not a new OverlayPortal
stack; the earlier source-tooltip experiment supplies the full portal stack.
The corrected candidate `63fbffa` disables tooltip overlays only within
worksheet rows and supplies explicit accessible action labels. It preserves
row/editor keys, controllers and dependency pins. Actual debug phone Undo,
independent duplication and reload now pass with the original assertions.

Full sources, trees, runs, control/failure logs and the original assertions remain in the
[receipt](evidence/notepad-stable-references-20261110.json) and
[dated history](../HISTORY.md). The earlier debug setup timeout is recorded
separately as infrastructure failure, not an application result.

This increment supplies the identity foundation for future source-linked
differentiate/integrate/solve/plot/table actions and worksheet sliders. Those
additional interactions remain separate work.
