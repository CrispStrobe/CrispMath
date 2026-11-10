# Connected Notepad: audit and worksheet direction

## Scope and status — 10 November 2026

Application checkpoint
[`63fbffa`](https://github.com/CrispStrobe/CrispMath/commit/63fbffad6e9e292da0c1fa17e5fe2b78c9e92b22),
tree `bcba66e3408e0830a19da5e782f3101774ef2613`, connects worksheet calculations,
inline plots, Graph and [stable result references](stable-result-references.md).
[Browser acceptance](https://github.com/CrispStrobe/CrispMath/actions/runs/42829214370)
passes both complete workflows in release and debug on desktop and phone with zero page errors,
including visible Undo recovery, independent duplication and reload. Strict
analysis, all 63 tests in the two affected widget files, all six platform builds,
Docs freshness and format preview pass. Functional acceptance is complete on
the draft feature branch. Test-only follow-up
[`da8c6e9`](https://github.com/CrispStrobe/CrispMath/commit/da8c6e92a459a5267e2baf1ca1d3fa4884f76ed6)
corrects obsolete tooltip-based test selectors without changing application
code. Its [strict retry](https://github.com/CrispStrobe/CrispMath/actions/runs/42832203169/job/129884887253)
passes analysis and all 63 widget tests, including phone hover/Delete/Undo.
The original full run's 6,045 passes/eight failures/eight skips and original
focused 55 passes/eight failures remain recorded separately. All eight failures
were the corrected selector lookups. Automatic full-suite reruns are separate
and are not included as a passing result or combined with the focused count.

The candidate suppresses tooltip overlays inside worksheet rows to prevent the
reproduced deletion/Undo layout failure. Floating hover captions are removed
only from worksheet-row controls; explicit accessible labels remain. Other
tooltips, row/editor keys, controllers and dependency pins are unchanged.
The prior `43d0030` checkpoint passed 6,052 tests/eight skips, all six builds and
release acceptance, but its debug phone Undo flow failed. Those historical
results, controlled reproductions and the earlier SDK setup timeout remain in the
[evidence receipt](evidence/notepad-stable-references-20261110.json).

This audit began at
[834bcc0](https://github.com/CrispStrobe/CrispMath/commit/834bcc0152bb703a187e7a838dfb6f70d3e11013).
The first increment merged through
[PR 21](https://github.com/CrispStrobe/CrispMath/pull/21) as `c7f84eb`; follow-up
[PR 22](https://github.com/CrispStrobe/CrispMath/pull/22) adds accessible plots
and stable references. Historical graph-observation, editor-focus and shown-
tooltip failures remain recorded in [HISTORY](../HISTORY.md) and the receipt.
This feature-branch evidence does not establish a release, deployment,
physical-device result, or additional engine capability.

Follow the [current state and executable lanes](https://github.com/CrispStrobe/CrispMath/blob/main/docs/current-state-and-next-steps.md)
and [PLAN](https://github.com/CrispStrobe/CrispMath/blob/main/PLAN.md). Keep the
existing dependency pin and release metadata. Builds, complete suites and
browser batches belong on hosted CI.

## Product goal

The Notepad should be where a mathematical investigation lives: explain the
question, define values and functions, calculate, graph, inspect, revise and
share the result. A graph should retain its source and parameters, and work
started in Graph should be able to become a worksheet without retyping.

The useful Maple precedent is the execution group: mathematical input and its
corresponding output stay together, and a group can also contain commentary
and a plot. Maple's embedded components demonstrate a second useful pattern:
one worksheet variable can drive both an interactive control and displayed
results. Its equation labels provide references that remain associated with
outputs when display numbering changes.

Primary references:

- [Maple execution groups](https://www.maplesoft.com/support/help/maple/view.aspx?L=E&path=worksheet%2Fdocumenting%2Fexecutiongroups).
- [Maple embedded components](https://maplesoft.com/support/help/view.aspx?path=EmbeddedComponents).
- [Maple equation labels](https://www.maplesoft.com/support/help/Maple/view.aspx?path=worksheet%2Fexpressions%2Fequationlabels).

These are interaction references. CrispMath already uses dependency-driven
document recalculation; adopting worksheet interactions does not require
changing it to Maple's execution-order model.

## Existing foundation

The application already has document-local variables and functions, dependency
tracking, error propagation, persistent documents, headings, undo, graph links,
source navigation, graph tracing, value tables and several exports. Graph links
use document and line IDs, so they can follow the same source through a row
move. The first increment reuses those facilities.

| Existing part | Public source |
| --- | --- |
| Documents, persistent row IDs and cached outputs | [Notepad model](https://github.com/CrispStrobe/CrispMath/blob/834bcc0152bb703a187e7a838dfb6f70d3e11013/lib/engine/notepad.dart) |
| Dependency evaluation and scope handling | [Evaluator](https://github.com/CrispStrobe/CrispMath/blob/834bcc0152bb703a187e7a838dfb6f70d3e11013/lib/engine/notepad_evaluator.dart) |
| Document-to-graph scope resolution | [Linked graph](https://github.com/CrispStrobe/CrispMath/blob/834bcc0152bb703a187e7a838dfb6f70d3e11013/lib/engine/linked_graph.dart) |
| Compiled/background graph sampling | [Sampling service](https://github.com/CrispStrobe/CrispMath/blob/834bcc0152bb703a187e7a838dfb6f70d3e11013/lib/services/graph_sampling_service.dart) |
| Source and variable navigation | [Source dialog](https://github.com/CrispStrobe/CrispMath/blob/834bcc0152bb703a187e7a838dfb6f70d3e11013/lib/widgets/linked_source_dialog.dart) |

## Gaps found at the baseline

| Gap | Observed implementation | Consequence |
| --- | --- | --- |
| Inline plots bypass document evaluation | The plot branch stores raw expression, variable and bounds in a cache sentinel before normal scope/error handling. | An inline plot can disagree with the already more capable linked graph. |
| Bounds accept only literal doubles in the preview | `PlotSpec.tryParse` calls `double.tryParse` on each range endpoint. | `plot(sin(t),t,-pi,pi)` and variable-driven intervals cannot work through that preview path. |
| Inline sampling runs during widget build | The preview performs 101 synchronous substitutions/evaluations whenever it builds. | Rebuilding a worksheet repeats sampling on the UI path. |
| Undefined samples disappear | Only valid points enter one continuous painted path. | A line can cross a gap where the function has no value. |
| Preview has no direct open action | The widget comment describes a tap action, but the widget has no callback. | The user must discover a separate row action. |
| Linked graph drops the declared interval | The resolution holds source, expression, scope and error, with no range. | Opening a plot can retain an unrelated previous viewport. |
| Graph cannot become a worksheet | The graph function menu contains Edit and Remove only. | The source and slider exploration stay outside the document. |
| Plot exports expose cache syntax | Plot rows take the ordinary result-text path. | Exported documents can contain `__plot__:` and pipe-separated fields. |
| Result aliases are positional | `lineN` changes meaning when rows are moved. | Narrative reordering can change a mathematical reference; this needs a separate compatibility design. |

The inline rendering observations come from the baseline
[preview widget](https://github.com/CrispStrobe/CrispMath/blob/834bcc0152bb703a187e7a838dfb6f70d3e11013/lib/widgets/mini_plot_widget.dart)
and [result column](https://github.com/CrispStrobe/CrispMath/blob/834bcc0152bb703a187e7a838dfb6f70d3e11013/lib/screens/notepad/result_column.dart).
The reverse-workflow and export observations come from the
[graph screen](https://github.com/CrispStrobe/CrispMath/blob/834bcc0152bb703a187e7a838dfb6f70d3e11013/lib/screens/graphing_screen.dart)
and [exporter](https://github.com/CrispStrobe/CrispMath/blob/834bcc0152bb703a187e7a838dfb6f70d3e11013/lib/engine/notepad_export.dart).

## Implemented first increment

### Try the connected worksheet

Enter these rows in Notepad:

```text
a = 2
radius = 3
f(t) = a*t^2
f(2)
plot(f(x), x, -radius, radius)
```

The last row shows a compact plot. Change `a` to update the function result and
plot, or change `radius` to update its interval. The plot's **View linked graph**
action opens Graph at that interval. The graph function menu's **Open worksheet
source** returns to the same row; the linked-source dialog can navigate to its
parameter assignments.

For a calculation started in Graph, choose **Create worksheet** from a function's
menu. Current parameter values and the visible x interval become editable rows
in a fresh document, and the original graph slot follows them. Existing linked
functions offer **Open worksheet source** instead of creating another copy.

### Shared plot meaning

The plain plot specification now lives in the engine layer. Document
functions, parameters, imports and interval bounds resolve before either view samples.
The independent variable is lexically bound: a document assignment `t=100`
does not replace the `t` in `plot(t^2,t,-2,2)`. Bounds remain ordinary document
expressions. A missing or invalid dependency produces an explicit error and
clears the old output.

The existing document IDs, row IDs and graph slots remain the source of
identity; both views use the worksheet's mathematical definitions.

### Inline graph and full graph

The inline output shows the graph, its interval, loading/empty/error states and
a **View linked graph** action. Sampling is asynchronous and reusable, with
late results from previous expressions discarded. Invalid samples remain
breaks in the curve. Opening a plot preserves its source link and carries its
declared x interval to the graph view.

### Graph back to Notepad

For a graph that already has a document source, the action opens that source.
For an independent graph, **Create worksheet** creates parameter assignments
and a plot over the current interval, then links the original graph slot to the
new plot row. This makes the document the owner of subsequent
changes while preserving the original graph slot and leaving the user's
current worksheet intact. The new worksheet provides a separate scope for
parameter names that may already exist in another document.

### Export

Cached plot metadata is decoded for text exporters and the shared
worksheet-bundle/PDF content path. The export includes the mathematical
expression, independent variable and evaluated interval. If no usable
evaluation exists, it retains the requested expression/range and identifies
the plot as not calculated. An error is not described as a valid plot.

This bounded change exports readable plot metadata. It does not claim to embed
an inline chart image in every format. A later graph-export lane should preserve
the actual interval and discontinuities in SVG/PDF output; the existing bundle's
separate graph collection and fixed preview interval need their own review.

## Acceptance examples and controls

| Scenario | Required result |
| --- | --- |
| `a=2`, `f(t)=a*t^2`, `plot(f(x),x,-2,2)` | Inline/full graph use the same function; editing `a` updates both. |
| `r=pi`, `plot(sin(t),t,-r,r)` | Symbolic and variable bounds resolve, and the plot range updates when `r` changes. |
| `t=100`, `plot(t^2,t,-2,2)` | Plot variable remains free over its range. |
| Nested user functions and fixed arguments | Expansion matches worksheet function semantics. |
| Invalid upstream assignment | Old geometry disappears, a useful error appears, and fixing the source recovers it. |
| `1/x`, `tan(x)`, `sqrt(x)` | Undefined regions and discontinuities do not become connecting lines. |
| No real values in the requested interval | Display an explicit empty result with the requested interval retained. |
| Equal, reversed or nonfinite bounds | Reject the range rather than silently substituting defaults. |
| Edit during sampling | A late old sample cannot replace the new result. |
| Open, return, move row, reload | Link identity and source navigation survive. |
| Graph with sliders to new worksheet | Parameters and interval survive; unrelated worksheet contents are preserved. |
| Markdown export, Copy as Markdown menu, LaTeX, shared PDF content | Human-readable plot metadata; no internal cache sentinel. |

Use focused unit/widget regressions plus actual hosted browser controls on wide
and narrow layouts. Record exact commits and workflow conclusions. Do not
replace historical mathematical fixtures or infer application behavior from a
model-only test. The `63fbffa` browser results and native selector failures, together with
earlier failures and controlled tooltip reproductions, are recorded in the
[evidence receipt](evidence/notepad-stable-references-20261110.json). The checks live in `notepad_plot_test.dart`,
`mini_plot_widget_test.dart`, `graph_worksheet_test.dart`, the existing graph
navigation/action, Notepad screen and export suites, and
`tool/check_connected_notepad_browser.py`.
The latter enters data through actual controls, observes successful sampled
plot semantics, checks both navigation directions, and reloads saved work.

### Current limits

This increment covers Cartesian expressions with one independent variable.
Plot limits use ordinary numeric arithmetic, functions and constants; a bound
requiring a CAS operation should first be calculated into a named numeric
value. Both intervals and preview geometry respect the existing graph display
limits. Finite samples outside that display range are reported as a display
limitation, separately from a range with no finite real samples. Sampling is
bounded and discontinuity handling is heuristic, as in the full graph view.

Exports contain readable expression and interval metadata; they do not yet
embed the inline plot as a chart image. The merged first increment retains the
positional `lineN` convention; PR22 adds explicit stable references alongside
it. Worksheet-row icons retain explicit accessible labels but currently have
no floating hover captions because the row-scoped workaround disables tooltip
overlays. Tooltips elsewhere in the app are unaffected. The remaining next
steps below are proposed work.

## Subsequent worksheet roadmap

1. **Stable result references — verified foundation.**
   [PR22's contract](stable-result-references.md) uses persistent row IDs and
   adds **Use result**, a **References…** picker and readable source links.
   Editable source still shows `@{row-id}` tokens, scoped to the same document;
   existing `lineN` stays positional without migration. Copy/import remaps
   internal identities, undo preserves them, and static exports use snapshot
   labels. Current-source release and debug controls pass the entire desktop and phone
   lifecycle, including visible Undo recovery and independent copy/reload.
   The test-only selector correction at `da8c6e9` passes strict analysis and all
   63 affected widget tests. The original full-suite result and corrected
   focused count remain separate. PR22 remains a draft awaiting review.
2. **Dependent calculation groups.** Differentiate, integrate, solve, plot and
   table actions should insert a new source-linked calculation beside the
   original. Show inputs, output and any assumptions together. Reuse the
   current dependency evaluator and mathematical capability/error evidence.
3. **Worksheet parameter controls.** A slider edits its assignment row rather
   than introducing a parallel parameter value. Step, bounds, units, undo and
   precision belong to that control's model.
4. **Tables and richer plots.** Value tables, multiple curves, annotations,
   parametric/polar/implicit plots and supported 3D views should become document
   outputs with their own inspectable specifications and dependencies.
5. **Dependency navigation.** Offer Uses and Used by links to defining rows,
   with clear pending, stale, missing and failed states. This is particularly
   useful for imported values and repeated assignment names.
6. **Portable mathematical documents.** Preserve source, references, plot
   specifications, assumptions and result evidence across save, share and
   restore. Separate an editable document from a static snapshot in the UI.

Progress should be judged through the complete task: enter a model, calculate,
inspect/plot it, change a parameter and save or share the explanation. Further
modules are useful when they participate in that same workflow.
