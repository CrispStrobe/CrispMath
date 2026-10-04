# Tenth independent mathematical audit

Fifty new questions were drafted independently of application output: 25 algebra,
calculus, complex and matrix questions, plus 25 numeric, statistics, units and
constraint questions. Record independent derivations, review any uncertainties
and exact prior-source duplicates before freezing the four reference files in
Git. No application observation occurs before that freeze. Existing CLI paths
exercise the questions; the accumulated corpus grows from 687 to 737.

All builds, application execution, unit/runtime batches, Playwright and Apple
captures run on GitHub-hosted runners. Small local edits and selected evidence
review respect the shared VPS policy. The initial check finds load 1.47,
3.3 GiB available RAM, 285 MiB free root disk and 74 MiB free fast disk.
Downloaded JSON and selected PNG evidence goes directly to stage17 CIFS cold
storage; app binaries and full galleries stay remote.

The previous audit's production source is `cd1991d`; approved external beta
1.2.0 (20) packages `7c0f244` with identical production. Physical iPhone/iPad,
real Siri/Files-provider, two-device cloud checks, handwriting accuracy and
Apple's 4.3(a) finding remain open. This audit does not establish those checks
or submit an App Review version.

## Frozen references and initial evidence

The four reference files are frozen at
`dfc778bf1998c3cfcf69062702a01686de2aabc9`, before app observation; SHA256 hashes
are retained on stage17 cold storage. Registration source `88a267a` retains
the approved build-20 production unchanged and enables normal current-head CI.
No skip-CI marker hides the new checks.

The initial WebAssembly corpus passes 735/737: all previous 687 and all 25 new
numeric questions pass, while two algebra questions fail. A uniquely solvable
overdetermined rational linear system is rejected; the divergent integral
`integrate(ln(x)^2/x,x,0,1)` reports only a sample evaluation failure. The
packaged Mac corpus passes 736/737: its linear-system call succeeds, but the
divergence diagnosis fails identically. Tiny original reports are preserved.

Ubuntu's native corpus crashes at the new overdetermined linear-system question
14, in `SymEngine::StrPrinter::apply` with a NULL reference. Its 33 completed
reports prove 712/712 (all prior 687 plus numeric 25); the entire 25-question
algebra report is absent. This is incomplete native evidence, not 735/737 or
737/737. A focused crash log is retained. Ordinary exception handling cannot
recover this native fault.

The exact bounded Gaussian solver was used only when the bridge lacked the
linear-system capability; a capable bridge failure bypassed it. The repair uses
the certified rational proof first and blocks unsupported rectangular inputs
from the unsafe native route after exact decline. Gaussian row arithmetic also
receives preallocation bounds. A shared affine logarithmic quotient proof now
classifies endpoint divergence before quadrature, preserving positive-domain,
regular-interval and nonproportional-denominator controls.

All platform compilation checks and legacy CI succeed except packaged Mac's
new mathematical audit step. The active red checks therefore include real new
math defects, alongside historical failed runs; neither tests nor gates are
removed or weakened. Final verification is recorded below.

## Shared fixes and regression controls

Corrected source `da75490` packages version 1.2.0 (21). Rational linear systems
are proved before selecting the backend, with exact result evidence and bounded
Gaussian arithmetic. Inconsistent and nonunique systems retain explicit errors;
unproved rectangular symbolic inputs are declined before the unsafe native call.
Square symbolic capability remains available.

The affine logarithmic quotient proof classifies a zero log argument endpoint as
divergent, rejects negative real domains and requires exact denominator
proportionality. Regular intervals use exact rational offsets near one, stable
logarithmic differences and normalized primitive powers. Exact reciprocal odd
moments can certify zero; unresolved underflow or overflow declines the proof.
Nineteen regressions include representable near-one moments around 7/3e-300,
scaled small primitives, nonproportional denominators and exact versus nearby
reciprocal endpoints.

Supplemental live controls retain independent references and require real
factorization structure, all matrix cells, principal complex branches, exact
source-domain metadata and complete globally optimal constraint assignments.
They add 70 worksheet entries, four descriptive checks, four objective checks
and two actual calculator linear-system checks. Twelve tooling test groups
reject altered values, missing metadata and unsafe comparison inputs. Runtime, unit, live, deployment and release outcomes are verified below.

## Hosted verification so far

The corrected native Linux and actual browser WebAssembly corpus each pass
737/737, from 34 complete reports with no unsupported cases or failures. Their
canonical audit is [37178530940](https://github.com/CrispStrobe/CrispMath/actions/runs/37178530940),
source `da75490`; the later helper-only source `4f4944b` has identical 368-file
production, SHA256 `ab85cee47aeb75df7fd041e6316ad32660dba610e5077f057c8b7518527dacfe`.

At `4f4944b`, full-feature unit/widget checks pass 5,735 with eight skipped;
focused regressions pass 491 and Python tooling passes 103. Analysis has zero
issues. Browser, debug/framework assertions and gallery gates in that whole-feature
run also succeed; the final canonical whole-feature run below supersedes it. The first corrected run caught an
exception-shape bug in a negative domain-comparison control; malformed inputs
now consistently reject without accepting extra conditions. That initial
failure is preserved; strict controls remain intact.

## Live-driver corrections

The first complete new live checks stopped at a correct displayed logarithmic
integral: `0.3465735903`. The comparison demanded more precision than numerical
integration's ten-decimal display retains. A helper-only correction compares the
exact displayed decimal against the independent mathematical reference rounded
to that grid, requires approximate evidence and rejects an adjacent final digit,
coarser rounding and false exact badges. Symbolic constants retain their strict
mathematical comparison. No frozen mathematical answer changes.

The next targeted probe passes all 70 new worksheet entries and eight module
checks. Calculator input and persisted history contain the exact expected
`x = 2, y = 2, z = 2`; the screenshot also shows it. A standalone-text locator
misses Flutter's merged expression/result history semantics. The driver now
selects the complete actual history label, checks uniqueness and visible
geometry, reads back all three values and repeats verification after reload.
Again this correction changes the test interaction, not the app or reference.

All six platform builds and legacy CI pass at `4f4944b`. Native Apple gallery
37178578571 passes 33 populated views, eleven per iPhone/iPad/macOS. Four selected
graph and evaluated-notepad captures are reviewed as readable, with correct
engineering values. These are simulator/native desktop checks; physical devices
remain deferred. All final helper corrections retain identical production. Canonical source
`ca7b6c7` passes every platform build, full math audit and whole-feature gate.


## Final canonical hosted verification

A shared click helper previously performed a trial hover followed by a second
locator click. Flutter tooltips could change semantics between those two
operations. The repair measures the unique visible control, verifies its
viewport bounds and actual hit target, then clicks those measured coordinates
once. Complete input, result, clipboard and reload assertions remain in place.
This systematic correction fixes both objective-copy and expression-edit races.

Canonical `ca7b6c7` passes [whole feature validation](https://github.com/CrispStrobe/CrispMath/actions/runs/37184040045),
including clean analysis, 5,735 unit/widget passes (eight skips), 491 focused
regressions, 104 tooling controls, release/debug browser assertions, performance
and gallery gates. [Full math audit](https://github.com/CrispStrobe/CrispMath/actions/runs/37184040061)
passes 737/737 native and browser runtime problems plus 420 actual worksheet
entries, 26 incremental edit states, 18 statistics, six constraint checks and
two calculator checks. Packaged macOS also passes 737/737. The
[targeted production-parity probe](https://github.com/CrispStrobe/CrispMath/actions/runs/37184237505)
independently passes all 70 new worksheet entries, four statistics, four
constraint objectives and two calculator linear-system checks including reload.
All six platform builds and legacy CI are green.

The production identity remains 368 files with SHA256
`ab85cee47aeb75df7fd041e6316ad32660dba610e5077f057c8b7518527dacfe`.
The immutable app bundle used by the targeted probe comes from `4f4944b`;
required full production parity with the corrected helper source is verified.
Frozen answers and all historical failures are preserved.

Task-only cold cleanup relocates 873 completed evidence files (about 18.3 MB)
and two cold directories (6,531,698 bytes), with verified hashes and readable
symlinks. Active source, other projects and toolchains remain untouched.
Unrelated disk growth still fills the fast disk; all computation remains hosted
and selected evidence is stored directly on CIFS.


## Published-site verification

[Pages run 37184585963](https://github.com/CrispStrobe/CrispMath/actions/runs/37184585963)
and [production Vercel run 37184586065](https://github.com/CrispStrobe/CrispMath/actions/runs/37184586065)
each pass 737/737 runtime problems, 420 worksheet entries, 26 edits, 18 statistics,
six constraint and two calculator checks. All sixteen math UI reports pass
with source `ca7b6c7` on both app and driver. These tests run against the actual
published [Pages](https://crispstrobe.github.io/CrispMath/) and
[Vercel](https://crisp-math.vercel.app) apps. Selected JSON evidence totals
247,728 transferred bytes; app bundles and galleries remain remote.


## Signed release and external beta

Signed [upload 37185726215](https://github.com/CrispStrobe/CrispMath/actions/runs/37185726215)
validates signature, bundled privacy strings and production parity before
delivering 1.2.0 (21). Apple processing is VALID and Internal Testers is assigned.
[External verification/submission 37186277329](https://github.com/CrispStrobe/CrispMath/actions/runs/37186277329)
confirms APPROVED beta review and Public Beta IN_BETA_TESTING, build UUID
971c1bb2-df76-4993-b841-03c6dce32a6e. The public
[TestFlight link](https://testflight.apple.com/join/E6HdVhTx) remains active.
Apple's submittedDate is null; no App Review submission occurs.

The final documentation revision retains the same production fingerprint and
uses normal push-triggered CI. Its exact Git revision and completed checks are
recorded in the stage17 final summary after verification. No checks are skipped
to hide failures. Physical-device checks and the other outstanding items listed
at the start remain open.
