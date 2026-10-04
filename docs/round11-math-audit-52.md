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
Final source and deployed live validation remain pending.

Small initial and repaired JSON reports are retained under
`/mnt/storage/CrispMath-stage21-ci/`; application bundles and large runtime/model
artifacts remain on GitHub. No local full suite, build or browser batch was run.
