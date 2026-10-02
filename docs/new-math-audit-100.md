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

## Verification in progress

[Packaged macOS source 2cda5e1](https://github.com/CrispStrobe/CrispMath/actions/runs/37037728989)
passed all 100 new checks (40/40 algebra, 40/40 numeric, 20/20 workflow), but the
older antiderivative comparison still failed. That domain-inspection issue is
fixed subsequently and remains subject to the final original/fresh corpus rerun.
Final source and native/WASM/deployed validation will be recorded after CI.
All compilation, large test suites and browser execution run on hosted CI;
local work is limited to small edits, formatting and report inspection.
