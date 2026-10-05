# Eleventh independent mathematical audit

The initial 50 references were frozen at `7a758f5` before running the app.
Static review subsequently identified two semantic overlaps with earlier rounds:
the commuted product of principal square roots and `log` versus `ln` for `-I`.
Those original questions and measurements remain unchanged. Two independently
referenced supplements were frozen at `5d67aec` before observing their answers.
The audit therefore has 52 questions and the accumulated runtime corpus has 789.

## Initial evidence

Linux/WASM run [37218527620](https://github.com/CrispStrobe/CrispMath/actions/runs/37218527620)
and packaged macOS [37218527485](https://github.com/CrispStrobe/CrispMath/actions/runs/37218527485)
retained all 737 previous passing answers. The new raw reports had algebra 21/25
and numeric 20/25 on each platform. Four algebra failures concerned shifted
polynomial/exponential/logarithmic equations and an exponential moment over an
infinite interval. Five numeric failures concerned absent capacitance, charge,
inductance, magnetic flux/density and electronvolt definitions.

An independent structural check found an additional gap masked by a raw pass:
`factor(x^4+4*y^4)` returned the expanded input unchanged. Genuine factoring
requires the two nonconstant quadratic factors, as well as exact equality of
all multivariate coefficients.

## Repairs and controls

- Certified elementary equation routing retains domain guards and compares
  complete root sets. It does not accept a subset or repeated root as a pass.
- Polynomial/exponential half-line integration checks convergence and orientation.
- Sophie Germain factorization emits explicit multiplication between variables,
  preserving the expression when reparsed. The generic diagnostic comparator
  rejects an unchanged polynomial when a factored answer is required.
- A shared coherent SI registry supplies electrical/magnetic dimensions and the
  exact electronvolt scale. Both explicit and implicit unit output use the same
  formatter so tiny nonzero magnitudes survive presentation.
- Independent Python controls compare every matrix entry and shape, exact
  fractions, unit magnitude and symbol, and feasible globally optimal assignments.
  Tiny energy comparisons use relative error and reject zero and truncated output.

Repair run [37219838087](https://github.com/CrispStrobe/CrispMath/actions/runs/37219838087)
and packaged macOS [37219838220](https://github.com/CrispStrobe/CrispMath/actions/runs/37219838220)
proved algebra 25/25 and supplements 2/2 on Linux, WASM and macOS; all previous
737 cases passed. Numeric remained 20/25 there, before the SI repair `628a1bc`.
The SI repair then passed all 789 cases in packaged macOS run
[37220497867](https://github.com/CrispStrobe/CrispMath/actions/runs/37220497867),
with zero failed or unsupported cases across 37 JSON reports. The native unit
gate exposed three unchanged historical scientific-format expectations; the
formatter now preserves their compact zeros while retaining meaningful extra
digits. At `f668074`, Linux/WASM run
[37221131045](https://github.com/CrispStrobe/CrispMath/actions/runs/37221131045)
and packaged macOS [37221131123](https://github.com/CrispStrobe/CrispMath/actions/runs/37221131123)
confirmed all 789 runtime answers. The full feature suite at that revision passed
5,769 Dart unit/widget tests with eight skips, 508 focused regressions, 17 new
regressions, 11 cloud-dialog tests, and 140 of 143 Python controls (three numeric
reference controls intentionally run separately with their CPU dependencies).
Analysis reported no issues.

Real UI checks then found a separate solver routing gap: the shared worksheet
binder converts equality to a zero-form expression, while the new elementary
solver initially required an equals sign. `ed0f754` supports bounded exact
two-term zero forms and adds a regression through the actual dispatcher, keeping
the binder contract unchanged. Correct richer source-domain annotations and
complete-value accessibility nodes also required stricter semantic checker
adaptation. The calculator then exposed a second entry-point gap: only semicolon equations
were accepted by its linear-system argument reader. `7c5dc72` accepts bounded
list-of-equations/list-of-symbols inputs as well, retaining the old form and
rejecting malformed or duplicate symbols. Complete complex-number comparison
supports numerical lowercase `i` without treating its result as exact.
Final production source `e8920a3dbaf669032901b44d4a00a25fee0c8d8e` passed
[37228244814](https://github.com/CrispStrobe/CrispMath/actions/runs/37228244814):
all 789 Linux and all 789 WASM answers, with zero failed or unsupported cases.
All 52 independently referenced questions also passed through the actual
desktop and phone interfaces, including complete matrix/constraint output,
source-domain annotations, tiny nonzero magnitudes and full-precision statistics.
The guided worksheet passed desktop, phone and tablet creation, editing,
graph linking, checkpoint recovery, Markdown download and reload while preserving
existing documents. No stored answers or result injection were used.

Packaged macOS run
[37228248552](https://github.com/CrispStrobe/CrispMath/actions/runs/37228248552)
passed all 789 cases at the same final `e8920a3` source, and checked the actual
package version `1.2.0+23` and pinned dependency source.

The hosted feature unit jobs at `e8920a3` passed 5,774 Dart tests with eight skips,
511 focused feature regressions, 19 guided/audit regressions, 11 cloud-widget
tests and 166 of 169 Python controls. Three numeric reference controls run
separately with their CPU dependencies. These invocations overlap and their
counts must not be summed as unique tests. Merged-main unit/feature jobs confirm
the same Dart counts and 169 of 172 Python controls after three native-startup
controls were added; the three numeric-reference skips remain separate. Static
analysis found no issues.

The new browser packaging gate exposed another underlying defect: production
web builds retained old OCR assets despite the new native dependency pin.
Shared hosted builds now download the exact checksummed `0.17.12` JS/WASM pair
and record its provenance. Executing that pair revealed Emscripten 6.0.2's
resizable-buffer UTF-8 decoder bug. A source-bound, single-call compatibility
repair follows the official
[Emscripten fix](https://github.com/emscripten-core/emscripten/pull/27242),
preserving the published WASM binary and native libraries. Provenance records
both the downloaded and staged JS hashes. Actual module initialization, heap
round-trip, long Unicode decoding on fixed/resizable buffers and rejection of
the unpatched decoder pass; no model is downloaded by this gate. This establishes
runtime compatibility, not improved handwriting recognition accuracy.

Broader release/debug coverage exposed two presentation defects beyond the
runtime answers: a long typeset phone result overflowed by 26 pixels, and the
shared result-action sheet overflowed by 22 pixels at doubled text scale.
Typeset results now scroll horizontally; the shared action list scrolls
vertically. Three hosted widget regressions cover phone at both text scales and
desktop, including reaching the final term, the complete accessible label,
the final action's viewport bounds and the actual clipboard payload. A platform
clipboard fixture follows Flutter's own test boundary and each case has a
30-second timeout.

The combined release UI step also recorded a missed guide-menu action before
the synchronous create handler ran. The driver now observes the actual completed
sentinel value, then requires a unique, unobscured, fully visible target whose
bounds remain stable for at least 250 ms before one physical click. Moving,
clipped, duplicate and obscured controls reject readiness. It does not retry
creation or inject data. The `0813ace` audit passes all 789 native/WASM cases,
all 52 actual GUI questions and all three guided profiles, including the
recorded stable phone targets. The final shared-action-sheet revision `e8920a3` also passes the complete
release/debug feature workflow
[37227986057](https://github.com/CrispStrobe/CrispMath/actions/runs/37227986057),
including all three cloud-off and guided profiles without backend requests or
uncaught errors. PR #2 is merged as `637b07e`; its production inputs match this
source. The intervening `18092e4` changes only the native capture helper and its
tests. Final gallery
[37230024733](https://github.com/CrispStrobe/CrispMath/actions/runs/37230024733)
passes all 33 populated captures; both fresh iOS simulators pass on their first
attempt, with no recovery retry.
[Signed upload 37230996262](https://github.com/CrispStrobe/CrispMath/actions/runs/37230996262)
verifies purpose strings and processing VALID for build 23;
[external verification 37231506974](https://github.com/CrispStrobe/CrispMath/actions/runs/37231506974)
confirms APPROVED and Public Beta IN_BETA_TESTING at merge source `637b07e`.
Physical checks and App Review remain deferred.

[Pages 37230602299](https://github.com/CrispStrobe/CrispMath/actions/runs/37230602299)
and [Vercel 37230684265](https://github.com/CrispStrobe/CrispMath/actions/runs/37230684265)
both finish successfully at `637b07e`, including all 789 runtime questions,
all 52 actual UI questions, three guided profiles, default-off cloud and the
actual published OCR module gates. Final main
[Feature run 37230602280](https://github.com/CrispStrobe/CrispMath/actions/runs/37230602280)
finishes successfully, including release/debug browser assertions and the web
gallery. All main platform, CI/CD, format and database checks also pass. The
automatic web build is superseded by the successful explicit production deploy.

Initial and repaired JSON reports are retained in the linked GitHub workflow
artifacts; private archive locations are documented outside the repository.
Application bundles and large runtime/model artifacts remain on GitHub. No local full suite, build or browser batch was run.
