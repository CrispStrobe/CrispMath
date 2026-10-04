# Round 10: 25 independent numeric, statistics, unit and constraint references

Drafted before running CrispMath or observing any round-10 result. Only existing fixture schemas and operation names were read to select supported CLI entry routes. The answers below come from arithmetic, matrix definitions, distribution identities, dimensional analysis and complete finite-domain proofs. The machine-readable references are in `test/fixtures/round10_numeric_tasks.json`. None depends on an app output.

## Independent derivations

| ID suffix | Frozen input or problem | Independent answer and derivation |
| --- | --- | --- |
| 01 | `factorial(12)/(factorial(5)*factorial(7))` | `792`. Cancel `7!`, then `12*11*10*9*8/120 = 792`, the number of five-element subsets. Exact integer evidence is required. |
| 02 | `1/(0.125+0.2)` | `40/13`. The decimal operands are exact `1/8` and `1/5`, so their sum is `13/40`. Exact rational evidence is required. |
| 03 | `det(Matrix([[1,2,3],[0,-2,4],[5,0,1]]))` | `68`. First-row expansion is `1*(-2)-2*(-20)+3*(10) = 68`. Exact integer evidence is required. |
| 04 | `inv(Matrix([[3,2],[5,4]]))` | `Matrix([[2,-1],[-5/2,3/2]])`. Determinant `12-10=2`; divide the adjugate `[[4,-2],[-5,3]]` by two. Multiplying either way gives identity. |
| 05 | `Matrix([[1,-1,2],[0,3,1]])*Matrix([[2,0],[-1,4],[3,-2]])` | `Matrix([[9,-8],[0,10]])`. Four row-column dot products are `2+1+6`, `-4-4`, `-3+3`, and `12-2`. |
| 06 | `rref(Matrix([[1,3,4],[2,6,8],[0,2,2]]))` | `Matrix([[1,0,1],[0,1,1],[0,0,0]])`. Subtract twice row one from row two, scale the remaining pivot row `[0,2,2]` by one half, and subtract three times it from row one. |
| 07 | Describe `[1,1,4,4,5]` | Mean `3`, median `4`, sample SD `sqrt(7/2) = 1.8708286933869707`. Sum `15`; squared deviations `4+4+1+1+4=14`; divide by `n-1=4`. |
| 08 | Describe `[1e-100,-1e-100,0,0,0]` | Mean and median `0`; sample SD `1e-100/sqrt(2) = 7.071067811865476e-101`. Squared-deviation sum is `2e-200` and sample variance is `5e-201`. The nonzero SD must not be accepted as zero. |
| 09 | Regress `x=[0,1,2,3]`, `y=[1,3,2,4]` | Slope `0.8`, intercept `1.3`, R² `0.64`. Means are `1.5,2.5`; centered `Sxx=5`, `Syy=5`, `Sxy=4`. Thus `b=4/5`, `a=5/2-(4/5)(3/2)`, and `R²=16/25`. |
| 10 | Binomial `n=8,p=1/4,k=3` | `0.2076416015625`. `C(8,3)*(1/4)^3*(3/4)^5 = 56*243/65536 = 1701/8192`. |
| 11 | Normal CDF `mean=-3,sd=2,x=-7` | `0.02275013194817921`. Standardized coordinate is `(-7+3)/2=-2`; reference is `erfc(sqrt(2))/2`. The stored double is the independently known two-sigma Gaussian lower-tail probability. |
| 12 | Student t interval `df=2,lower=0,upper=sqrt(6)` | `sqrt(3)/4 = 0.4330127018922193`. For two degrees of freedom, `F(t)=1/2+t/(2*sqrt(t²+2))`; subtract `F(0)` and substitute `t=sqrt(6)`. The supplied upper bound is the nearest double `2.449489742783178`. |
| 13 | Chi-square observed `[12,8,10]`, expected counts `[10,10,10]` | Statistic `0.8`, df `2`, p-value `exp(-0.4)=0.6703200460356393`. Two cells contribute `4/10` each. Three fixed-probability cells give df `3-1`; chi-square df-two survival is `exp(-statistic/2)`. |
| 14 | `6 kΩ * 2 mA in V` | `12 V`. Ohm's law and SI scales give `6000 Ω * 0.002 A = 12 V`. |
| 15 | `12 V / 3 kΩ in mA` | `4 mA`. `12/3000 A = 0.004 A`; conversion to milliampere multiplies by 1000. |
| 16 | `2 kPa * 3 L in J` | `6 J`. `2000 Pa * 0.003 m³`; pressure times volume has the energy dimension. |
| 17 | `36 km / 2 h in m/s` | `5 m/s`. `36000 m / 7200 s`. |
| 18 | `5 g / 2 cm³ in kg/m³` | `2500 kg/m³`. `0.005 kg / 0.000002 m³`. |
| 19 | `3 N * 4 cm in erg` | `1200000 erg`. `3*0.04 J = 0.12 J`, and `1 erg = 1e-7 J`. |
| 20 | `9 m² / 4 s² in J/kg` | `2.25 J/kg`. `J/kg` reduces to `m²/s²` with coherent scale one. |
| 21 | Integers `x,y in -3..3`, `x*x+y*y=5`, `x>0` | Complete unordered solutions `(1,-2),(1,2),(2,-1),(2,1)`. Squares must be `1` and `4`; positivity selects `x=1` or `2`, and both signs of y remain. |
| 22 | Integers `x,y,z in 0..4`, sum `4`, `x<y<z` | Only `(0,1,3)`. If `x>=1`, the least sum is `1+2+3=6`; hence `x=0`. Then `y+z=4` and strict positive order forces `y=1,z=3`. |
| 23 | Integers `x,y in 0..5`, sum `5`; minimize `(x-1)^2+(y-1)^2` | Optimum `5`, achieved at `(2,3)` and `(3,2)`. Substitute `y=5-x`: objective `2*(x-2.5)^2+4.5`. Nearest integers are 2 and 3. The CLI objective route requires the optimum value, independently of tie ordering. |
| 24 | Integers `x,y in -2..2`, sum `0`; maximize `(x+1)*(y+1)` | Optimum `1`, uniquely at `(0,0)`. Substituting `y=-x` gives `1-x²`, bounded above by one. |
| 25 | Integer `x in -4..4`, `x*x=4`, `x!=-2` | Complete solution `{x:2}`. The only roots are `-2,2`; the explicit inequality excludes the negative root. |

## Pre-observation checks and draft corrections

The initial hand-drafted row-reduction stimulus for case 06 was `[[1,2,3],[2,4,6],[0,1,1]]`. A static stimulus-only comparison found that exact matrix already in `round7-numeric-06`. Before any app execution or results, it was replaced with `[[1,3,4],[2,6,8],[0,2,2]]`; the new independent pivot derivation is recorded above. No expected answer was fitted to an app response.

A subsequent static comparison of the complete route plus stimulus against every existing `test/fixtures/*tasks*.json` found no exact duplicates for the final 25, and all 25 stimuli are distinct within this draft. IDs, titles, references, expectations and comparison annotations were excluded from stimulus signatures. No app, CLI corpus or local test suite was executed.

The normal and t references use the full worker precision. A future actual statistics-screen check may show fewer digits; a rounded visible result is supplementary UI evidence and does not replace the strict probability comparison in this corpus. Unit outputs retain both independently derived magnitude and dimension. Constraint solution sets are complete, not sampled, and objective values have global finite-domain proofs.
