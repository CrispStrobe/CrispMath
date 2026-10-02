# Additional 100-case mathematical audit

Drafted on 2 October 2026 using two agents and a parent worksheet/graph review.
The algebra and numeric drafts were fixed before inspecting previous corpora.
References use explicit elementary algebra, exact arithmetic, distribution
identities and independently enumerated small constraint solution sets, without
consulting app output. Some independently drafted questions overlap earlier
coverage; these are 100 additional audit cases, not a claim of 100 new features.

- [40 algebra/calculus/complex cases](new-math-audit-algebra.md)
- [40 arithmetic/statistics/units/constraint cases](new-math-audit-numeric.md)
- [20 worksheet/graph/export cases](new-math-audit-workflows.md)

The fixtures are `test/fixtures/new_math_{algebra,numeric,workflow}_tasks.json`.
Run each through `tool/crispmath_cli.sh --tasks FILE --require-native --report FILE`.
Playwright sends the same fixtures to the actual app WASM diagnostic worker.
The packaged macOS release app receives each corpus through inherited pipes,
keeping its sandbox enabled. The usual two 50-case corpora remain regression gates.

## Initial findings and fixes

Packaged macOS source `252145f` passed 87/100 new cases. Several failures were
precision-contract or comparison failures, rather than wrong numeric values.
Production fixes now preserve bounded exact integer/rational results even when
large intermediate values cancel to small answers; parse signed temperature and
quantity literals; preserve repeated CSP factors such as `x*x`; solve bounded
rational equations while excluding original denominator zeros; and strip only
zero imaginary formatting so symbolic L'Hopital steps can identify 0/0 correctly.
The cosine limit previously fell back to the unstable numeric value 0.4996003611.

The comparison oracle now handles arbitrary variables independently, retains
integration constants, rejects undefined/error results, measures full complex
residuals (never only the real part), respects root multiplicity, and normalizes
pretty rational coefficients and numeric `i` suffixes. The old antiderivative
regression exposed domain evidence falsely treating an additive +C as part of a
denominator; the whole-quotient inspector now declines top-level sums.

## Explicit unsupported request

`n=5; n=n+1; n^2` asks for imperative reassignment, whereas the worksheet uses
reactive last-definition semantics. This remains a deliberate feature boundary.
The fixture preserves the original requested results 5, 6, 36 and records the
unsupported reason, then checks that the app rejects the circular definition.
A separate regression verifies `n=5; next=n+1; next^2` computes 5, 6, 36 and
recalculates after an edit. The revised corpus therefore contains **99 positive
calculation/workflow cases and one explicit expected feature rejection**.
Reports record expected rejections and feature gaps separately from pass counts.

## Verification

Application changes are complete at `aa71c7f`; `c7df009` adds CI preview-server
readiness checks and `9090082` changes only browser capture tooling/workflows.

- [Linux CLI and browser WASM](https://github.com/CrispStrobe/CrispMath/actions/runs/37042076931)
  both pass 50/50 original, 50/50 fresh, 40/40 algebra, 40/40 numeric and 20/20
  workflow checks. Native corpus/comparison/engine/document/evidence unit gates
  and the ten forced native Taylor compatibility cases pass. WASM also passes
  all 11 actual worksheet problems on desktop and phone (22 entries), correct
  limit/solve evidence, reload persistence and no page errors. Eight screenshots
  retain the real results, with source provenance in `report.json`.
- [Packaged sandboxed macOS](https://github.com/CrispStrobe/CrispMath/actions/runs/37041845547)
  passes the same 200 runtime checks, linked native CAS/series assertions and OCR.
- [Full analysis and unit validation](https://github.com/CrispStrobe/CrispMath/actions/runs/37042080538):
  analysis, focused feature/tooling checks and **5,367 unit/widget tests** pass
  with eight skips (existing disabled/opt-in checks and unavailable native
  bridge in the macOS unit process). The broader browser job exposed an existing host-
  dependent Alert-label selector; the actual HTTP 503 error was visibly correct.
  The selector now asserts the visible message on all platforms.
- [Pages](https://github.com/CrispStrobe/CrispMath/actions/runs/37045709723) and
  [Vercel](https://github.com/CrispStrobe/CrispMath/actions/runs/37043229968)
  pass all 200 runtime checks, all 11 desktop/phone worksheet controls,
  ink/undo/clear, worksheet import/export, recovery/history and the gallery.
- [Broader release/debug browser checks](https://github.com/CrispStrobe/CrispMath/actions/runs/37047382645)
  pass release and debug UI checks, performance gates and the 12-scene gallery
  on hosted Linux. The earlier macOS checks exposed a host-
  dependent Alert label, duplicate accessibility-announcement text and delayed
  local fixture-port readiness; these test/infrastructure issues were corrected
  while preserving the actual HTTP 503/retry/cancellation assertions. Handwriting
  crops now require stable geometry and retain coordinates and crop PNGs. Phone
  entry waits for its compact toolbar menu instead of selecting a transient
  desktop semantics node. All strict ink assertions remain unchanged.

Initial packaged output passed 87/100; follow-up native/WASM execution confirms
these fixes against the real engine rather than only mocked operations. The
original imperative reassignment request remains recorded as a feature gap.
All compilation, large suites and browser execution use hosted CI. Local work
is limited to small edits and evidence review. The idle task-owned temporary
Flutter SDK was removed to recover 1.1 GiB; no other project's files/processes
were touched. Physical iPhone/iPad checks remain deferred. The new math changes
are later than the previously submitted TestFlight build 13.

## Follow-up edge review

Two power-chain controls were independently derived: `2^(-3)^2 = 512`
(right-associative exponentiation) and `(2^(-3))^2 = 1/64`. The negative-power
preprocessor now preserves that distinction. Both are added to live worksheet
entry checks, bringing the UI batch to 11 problems on desktop and phone.
Exact polynomial and rational-equation arithmetic also bounds coefficient cost
before multiplication or powers; degree-zero constants alone do not bound
BigInt growth. A 16,384-bit budget retains the ordinary large-integer corpus.
Completed symbolic limits and checked rational roots now replace intermediate
operation metadata with their actual provenance. Unit and live checks assert
these labels; all 11 live worksheet controls pass on both screen sizes.
