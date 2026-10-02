# Second independent 100-case audit

Drafted on 2 October 2026 after the preceding audit completed. Two agents fixed
40 algebra and 40 numeric references independently before comparing old corpora;
the parent drafted 20 worksheet/graph/export problems. Some questions may overlap
previous coverage. This is another audit, not a claim of 100 new features.

- [Algebra and calculus references](round2-math-algebra.md)
- [Numeric, statistics, units and constraints](round2-math-numeric.md)
- [Worksheets, graphs and exports](round2-math-workflows.md)

Fixtures are `test/fixtures/round2_{algebra,numeric,workflow}_tasks.json`.
Run using `tool/crispmath_cli.sh --tasks FILE --require-native --report FILE`.
GitHub CI runs these through the actual native CLI and browser WASM worker;
deployment workflows also run them against Pages and Vercel. Eight additional
independently derived arithmetic controls are typed through the real desktop and
phone UI, with source provenance, reload checks and screenshots.

## Initial results and fixes

[Initial CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37049929017),
source `c581c56`, passed 93/100 new WASM checks: 40/40 algebra, 33/40 numeric
and 20/20 workflow. Native passed 33/40 numeric and 20/20 workflow; the algebra
batch crashed in native antiderivative substitution and did not produce a report.
The preceding additional 100-case corpus still passed on both runtimes.

The seven numeric failures were a rounded large-integer remainder, loss of exact
power/reciprocal forms, zero singleton sample deviation, and three unavailable
unit conversions (watt-hours, squared prefixes and compound speed). The first
new actual-UI control also exposed a decimal result instead of the requested
exact negative-base reciprocal.

Fixes add bounded exact constant arithmetic, safely replace scalar symbols
without the crashing FFI substitution, retain undefined singleton sample values,
and support properly scaled derived and compound conversion targets. Rational
integration checks cancel exact common factors before rejecting actual poles;
this avoids principal-value answers for ordinary improper integrals while
preserving removable holes. Independent expected mathematical values remain
unchanged. Verification of these fixes is pending.

All compilation, suites and browser execution run on hosted CI. VPS load, memory
and disk were checked first; local work is limited to small edits and report
review. Physical iPhone/iPad checks remain deferred by the user. Previous math
fixes are verified, while imperative reassignment remains an explicit reactive
worksheet feature boundary. Later math changes are not in TestFlight build 13.
