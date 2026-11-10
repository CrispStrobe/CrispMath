# Stable result references in Notepad

## Scope and status — 10 November 2026

Application checkpoint
[`43d0030`](https://github.com/CrispStrobe/CrispMath/commit/43d00309345b369860c8453bcec0f4fea1e3717d),
tree `736640b9263ab9ac31e471b2ee5095d2dace65fb`, passes the complete
[release browser workflow](https://github.com/CrispStrobe/CrispMath/actions/runs/42823031454/job/129853091015)
on desktop and phone. References can be inserted, extended by typing, followed
back to their source, recalculated, deleted/undone, duplicated and reloaded
through actual controls. There are zero page errors, and 62 focused widget
tests pass. The full native suite passes 6,052 tests/eight skips and all six
platform builds pass. **Feature closure remains open for a debug phone Undo
layout failure**, described below; the complete debug desktop lifecycle passes.

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

### Current application checkpoint: `43d0030`

| Scope | Observed result | Evidence |
| --- | --- | --- |
| Analysis and full suite | Clean analysis; 6,052 passed, eight skipped, zero failed. The hovered source-deletion/Undo regression passes. | [Source-matched CI](https://github.com/CrispStrobe/CrispMath/actions/runs/42822982607/job/129852918258) |
| Platform builds | Web, macOS, Windows, Linux, Android and iOS pass. | [Candidate checks](https://github.com/CrispStrobe/CrispMath/commit/43d00309345b369860c8453bcec0f4fea1e3717d) |
| Focused widgets | 62 pass in the isolated release job; these overlap the full suite. | [Release job](https://github.com/CrispStrobe/CrispMath/actions/runs/42823031454/job/129853091015) |
| Release graphs and references | Complete actual workflows pass on desktop 1280×900 and phone 390×844, with zero page errors. | [Release job](https://github.com/CrispStrobe/CrispMath/actions/runs/42823031454/job/129853091015) |
| Debug graphs and references | Both graph layouts and the complete desktop reference lifecycle pass. Phone Undo restores saved state, then throws a visible list-layout assertion; later phone stages are not reached. | [Retry](https://github.com/CrispStrobe/CrispMath/actions/runs/42824865537/job/129859438590) |

Release acceptance uses workflow commit `5d36e11`; the debug-only retry uses
`95b6923`. Both bind their application source to `43d0030`; the workflow-only
changes do not alter the app. The original
[debug attempt](https://github.com/CrispStrobe/CrispMath/actions/runs/42823031454/job/129853091339)
timed out during Flutter SDK setup before application execution.

### Remaining debug phone failure

Source deletion correctly shows **Missing result**. Undo restores the two
original row IDs, source expressions and results 9/19 in storage. The visible
list then throws `_RenderLayoutBuilder0 was mutated in RenderSliverList.performLayout`
while rebuilding `_ReorderableItem`, and the strict visible-result check times
out. Undo's mathematical and identity restoration does not make that UI flow
successful. The next bounded correction must remove the layout failure and
complete the remaining phone lifecycle while retaining the existing assertions.

### Retained failures and bounded corrections

Earlier runs found a picker destination lost across menu blur, then native
keyboard focus lost after **Use result**. A read-only same-bundle trace at
`90d80b6` recorded the surviving textarea's semantic ancestor changing before
the original keys reached BODY. Semantic containment and FocusNode lifecycle
corrections at `ca24eb3` restored typing, but debug source deletion then exposed
a shown-tooltip reactivation assertion. The same application passed a native
control without a shown tooltip and failed when the tooltip was explicitly
shown; the full stack identifies `OverlayPortal` reactivation.

The final correction removes only the new source-chip Tooltip, retaining its
semantic hint and the picker's source description. Full sources, trees, runs,
control/failure logs and the original assertions remain in the
[receipt](evidence/notepad-stable-references-20261110.json) and
[dated history](../HISTORY.md). The final debug setup timeout is recorded
separately as infrastructure failure, not an application result.

This increment supplies the identity foundation for future source-linked
differentiate/integrate/solve/plot/table actions and worksheet sliders. Those
additional interactions remain separate work.
