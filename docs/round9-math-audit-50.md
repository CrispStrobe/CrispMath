# Ninth independent mathematical audit

Fifty new mathematical questions and independent references are frozen at
`3bc82de` before any app output is observed: [algebra/calculus](round9-math-algebra.md)
and [numeric/statistics/units/constraints](round9-math-numeric.md). Each fixture
contains 25 questions. Exact duplicates and a hand-derivation sign correction
were resolved before observation and documented in the reference drafts.
SHA256 hashes of all four frozen reference files are saved on stage16 cold
storage. Existing CLI routes suffice; only hosted corpus registration and
reference tests are added before the initial audit. Previous rounds
supply 637 accumulated runtime questions; this round will bring the corpus to
687. Confirmed failures will retain their initial reports and unchanged expected
answers, with shared repairs and regression controls recorded here.

All builds, app execution, full analysis, test batches, Playwright and native
captures run on GitHub-hosted runners. Local work is limited to small edits,
status queries and selected report/image review; downloaded evidence goes to
cold storage. Physical iPhone/iPad checks remain deferred. Real Siri/Files,
two-device cloud, handwriting accuracy and Apple's 4.3(a) finding remain open.
Build 19 remains the verified approved public beta while this audit proceeds.

## Preserved initial evidence

At integration source `1ec3c2825c991d2a8e8be6cda72d660fbd2a93bd`, production
remains identical to the approved build 19. [Native Linux/WebAssembly audit](https://github.com/CrispStrobe/CrispMath/actions/runs/37144811266)
and [packaged Mac audit](https://github.com/CrispStrobe/CrispMath/actions/runs/37144813327)
run all 687 questions. Initial Linux and Mac each pass 684/687: all prior 637,
all 25 new algebra cases and 22/25 numeric cases. Their three failures are
Ohm-law prefix composition (`1 mA * 1 kΩ in V`), standalone squared-time units
(`1 m² / 1 s² in J/kg`) and a shifted-factor polynomial constraint objective.
Tiny original runtime JSONs and focused-reference failure evidence remain on
stage16 cold storage. The tiny/huge standard deviation, rare binomial, closed
t-distribution and zero-cell chi-square references pass. WASM also passes 684/687 with exactly the same three failures, all 25
new algebra cases and all previous 637; its historical actual UI checks pass.

Electrical current is absent from the dimension model/catalog; standalone
unit powers bypass the bounded atomic resolver; the shared integer-polynomial
parser splits on every sign/product and rejects grouped shifted factors.
Systematic bounded repairs and positive/negative controls are in progress.

## Shared repairs and controls

Electrical current is a separate dimension propagated through arithmetic,
equality/hash and coherent ampere/volt/ohm definitions and SI prefixes. Powered
standalone units use the same bounded atomic resolver as compound factors,
including squared/cubed forms, finite-scale checks and affine-unit rejection.
Multiple denominator factors are printed as repeated divisions, matching the
parser's left-associative semantics; default display conversion rejects overflow.

The shared integer-polynomial parser now handles grouped sum/product/unary
expressions with canonical exact BigInt coefficients. It bounds source length,
expanded terms (64), factors (128), nesting (32) and coefficient bits (4096)
before allocation while retaining objective-domain guards. Reduced linear or
constant expressions remain valid; constant true/false constraints retain safe
solver routing. Independent static review found these cancellation/zero-arity
and display-overflow cases, which now have controls. Twenty-nine new regression
tests and two reference tests are ready for hosted verification. Build 20 is
prepared; build 19 remains approved until all changed-production gates pass.

The first repaired candidate `0d8dd15` passes all 687 runtime questions on
native Linux and packaged Mac. Full units expose a real input-budget regression:
canonical term combination allowed 65 repeated summands to bypass the previous
64-source-term limit. Separate global source-term/atom counters now retain that
limit before simplification, with oversized repeated/zero controls. Two existing
unit assertions described grouped objectives and ampere as unsupported; they
now assert the newly supported behavior while retaining other invalid-input
checks. Initial failure logs are preserved. The analyzer's reported missing
braces are corrected. Final full/runtime/live verification follows.

The next candidate `76b4e41` also passes all 687 runtime questions on WASM
and packaged Mac. Its sole remaining full-unit/focused failure is 65 zero
linear terms bypassing polynomial limits through the older linear fast path.
The shared linear parser now checks 1024 source characters, 64 raw terms and
128 atoms before coefficient parsing; decimal linear grammar and propagation
remain intact. Positive 64-term controls and unchanged negative 65-term controls
cover both routes.

Actual browser coverage adds 66 worksheet entries, four real descriptive-statistics
checks and two real constraint optimizations. Independent tooling controls retain
exact principal signs, complete roots, every matrix/Taylor coefficient and
visible tiny-value labels. Shared exact comparator arithmetic now preflights
scientific exponents and rational coefficient growth before allocation.
Native gallery capture has separate iPhone/iPad steps with bounded boot/drive
phases, streamed logs, failure diagnostics and owned-descendant cleanup. These
helper changes retain the same production code and screenshot assertions.
