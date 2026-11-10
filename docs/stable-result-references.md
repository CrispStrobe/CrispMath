# Stable result references in Notepad

## Scope and status — 10 November 2026

This is the second connected-worksheet increment on
[PR 22](https://github.com/CrispStrobe/CrispMath/pull/22). It builds on the merged
[Notepad and graph audit](connected-notepad.md) without changing dependency
pins, release metadata, or the meaning of existing `lineN` expressions.
Implementation and hosted acceptance evidence are tracked in the PR. This
document describes the new contract; it is not a release or deployment claim.

## User workflow

Calculate a value, open its result menu, and choose **Use result**. A new row
starts with a live reference to that result. Complete the expression, for
example by multiplying it by two. Editing the original calculation updates the
dependent row; inserting or moving other rows does not change its target.

**Copy result** still copies a value. The document menu's **References…** action
offers usable results by their current line number, source, and value. It can
insert a reference at the remembered editor selection. References displayed
under a row provide navigation back to their source, including a source in a
collapsed section or outside the current viewport.

The first increment supports results of ordinary expressions, scalar
assignments, and aggregates. Function definitions remain callable by name.
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
and calculated results are not injected. Exact hosted results and retained
initial failures belong in the PR before readiness is asserted.

This increment supplies the identity foundation for future source-linked
differentiate/integrate/solve/plot/table actions and worksheet sliders. Those
additional interactions remain separate work.
