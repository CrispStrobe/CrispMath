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

Initial execution and findings are pending. Desired behavior for an integral
across a pole is rejection, never its principal value unless explicitly requested.
Singleton sample standard deviation is undefined rather than zero. These
references will not be changed merely to accept an incorrect app result.

All compilation, suites and browser execution run on hosted CI. VPS load, memory
and disk were checked first; local work is limited to small edits and report
review. Physical iPhone/iPad checks remain deferred by the user. Previous math
fixes are verified, while imperative reassignment remains an explicit reactive
worksheet feature boundary. Later math changes are not in TestFlight build 13.
