# Seventh independent mathematical audit

Fifty questions and hand-derived references were committed before observing app
outputs in `ffa36677f42b8e71644e89d7c5596675c87eeb26`:
[algebra/calculus references](round7-math-algebra.md) and
[numeric references](round7-math-numeric.md). Pre-output freshness replacements
are documented in those drafts; none used app answers. Both fixtures contain
25 questions and remain frozen throughout diagnosis.

The first hosted [native/WASM audit](https://github.com/CrispStrobe/CrispMath/actions/runs/37116981054)
and [packaged macOS run](https://github.com/CrispStrobe/CrispMath/actions/runs/37116922166)
found 34/50 passing on Linux native, 33/50 on packaged macOS, and 31/50
on WASM. All previous 537 runtime cases passed on each platform. Initial
reports are retained in stage14 CI evidence; the browser reports are on cold
storage to protect the shared disk. The accumulated runtime corpus has 587 cases before any
additional related negative or live controls. Initial failures will be preserved
and traced to shared causes; expected answers will not be replaced with app
outputs.

Confirmed failures cover complex conjugation/principal powers, roots excluded
by original denominators, endpoint logarithmic integrals, unsampled irrational
poles, polynomial absolute-value calculus, a rationalized infinity limit,
scientific literals and near-singular decimal matrices, singular-inverse
diagnostics, Student t tail intervals, chi-square significance, and erg/atm
conversion. Shared bounded proofs and stable tail routines are being validated;
this report will record final hosted results before claiming closure.

All builds, app execution, analysis, unit suites and Playwright batches run on
GitHub-hosted machines. The shared VPS only handles edits, status queries and
small report downloads. Physical-device testing remains deferred; handwriting
accuracy and Apple's 4.3(a) App Review rejection remain separate open issues.
