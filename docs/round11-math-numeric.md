# Round 11: 25 independent numeric, statistics, unit and constraint references

Drafted from mathematical questions before running CrispMath or observing any
round-eleven answer. Existing fixture schema and operation names were read only
to select CLI entry routes. References use arithmetic, matrix definitions,
distribution identities, SI dimensions and complete finite-domain proofs. The
machine-readable references are in `test/fixtures/round11_numeric_tasks.json`.

## Independent derivations

| ID suffix | Problem | Independent answer and derivation |
| --- | --- | --- |
| 01 | `factorial(17)/(factorial(8)*factorial(9))` | `24310`. This is the eight-element subset count, `17*16*15*14*13*12*11*10/40320`. Exact integer evidence is required. |
| 02 | `0.00625/0.0005` | `25/2`. The exact decimal fractions are `1/160` and `1/2000`, so the ratio is `2000/160`. Exact rational evidence is required. |
| 03 | `factorial(9)/(factorial(3)*factorial(3)*factorial(3))` | `1680`. Nine labelled items split into three labelled groups of three give `362880/216`. Exact integer evidence is required. |
| 04 | `det(Matrix([[2,1,0,0],[3,4,0,0],[0,0,5,2],[0,0,1,3]]))` | `65`. The two diagonal blocks have determinants `8-3=5` and `15-2=13`; their product is the full determinant. Exact integer evidence is required. |
| 05 | `inv(Matrix([[2,1,0],[0,3,4],[0,0,5]]))` | `Matrix([[1/2,-1/6,2/15],[0,1/3,-4/15],[0,0,1/5]])`. Back substitution fixes the diagonal reciprocals, off-diagonal entries `-1/6,-4/15`, and corner `4/(2*3*5)=2/15`. Both multiplication orders give identity. |
| 06 | `Matrix([[2,-1],[0,3],[-2,4]])*Matrix([[1,0,2,-1],[3,5,-2,4]])` | `Matrix([[-1,-5,6,-6],[9,15,-6,12],[10,20,-12,18]])`. Each row is respectively two first rows minus one second row, three second rows, and minus two first rows plus four second rows of the right operand. All twelve cells are required. |
| 07 | `rref(Matrix([[1,2,-1,3],[2,4,-2,6],[0,1,1,2]]))` | `Matrix([[1,0,-3,-1],[0,1,1,2],[0,0,0,0]])`. Row two is twice row one; move the third row to the second pivot and subtract twice it from row one. |
| 08 | Describe `[0.125,0.25,0.375]` | Mean and median `0.25`, sample SD `0.125`. Deviations are `-1/8,0,1/8`; squared sum `1/32`, divided by two gives sample variance `1/64`. |
| 09 | Describe `[1000000000000,1000000000001,1000000000002]` | Mean and median `1000000000001`, sample SD `1`. Centered deviations `-1,0,1` have squared sum two. The large offset must not destroy unit dispersion. |
| 10 | Regress `x=[-2,-1,0,1,2]`, `y=[9,6,3,0,-3]` | Slope `-3`, intercept `3`, R² `1`. The exact line is `y=3-3*x`; centered `Sxx=10`, `Sxy=-30`, `Syy=90`. |
| 11 | Binomial `n=12,p=0.2,k=0` | `0.068719476736`. Zero successes has probability `(4/5)^12=16777216/244140625`. |
| 12 | Normal CDF `mean=10,sd=3,x=-14` | Approximately `6.220960574271784e-16`. Standard coordinate is `(-14-10)/3=-8`; lower-tail reference is `erfc(8/sqrt(2))/2`. A zero result must fail relative comparison. |
| 13 | Student t interval `df=1,lower=0,upper=sqrt(3)` | `1/3`, stored as `0.3333333333333333`. A one-degree t is standard Cauchy with CDF `1/2+atan(t)/pi`; `atan(sqrt(3))=pi/3`. The upper bound is the nearest double `1.7320508075688772`. |
| 14 | Chi-square observed `[4,8,12]`, fixed expected counts `[8,8,8]` | Statistic `4`, df `2`, p-value `exp(-2)=0.1353352832366127`. The outer cells each contribute `16/8=2`; df-two survival is `exp(-statistic/2)`. |
| 15 | `3 µF * 12 V in µC` | `36 µC`. Capacitance times voltage is charge: `3e-6 F*12 V=36e-6 C`. `F` denotes farad and `C` coulomb in this electrical expression. |
| 16 | `2 mH * 3 A / 4 ms in V` | `1.5 V`. Inductive voltage is `L*dI/dt`: `0.002 H*3 A/0.004 s`. Henry is `V*s/A`. |
| 17 | `6 mWb / 3 cm² in T` | `20 T`. Flux density is `0.006 Wb/0.0003 m²`; tesla is weber per square metre. The square applies to the centimetre scale. |
| 18 | `2 A * 3 s in C` | `6 C`. Charge is time-integrated current; coulomb is ampere-second. |
| 19 | `4 eV in J` | `6.408706536e-19 J`. One electronvolt is exactly `1.602176634e-19 J` using the SI elementary charge. Magnitude must stay positive and preserve the energy dimension; zero is not equivalent. |
| 20 | `250 mL / 2 s in L/min` | `7.5 L/min`. `0.25 L/2 s=0.125 L/s`; multiply by sixty seconds per minute. |
| 21 | Integer `x,y in -4..4`, `x*x+y*y=10`, `x<0` | Complete unordered set `(-3,-1),(-3,1),(-1,-3),(-1,3)`. The only squares summing to ten in the domain are nine and one; the x sign is negative and either y sign remains. |
| 22 | Integer `x,y,z in 0..6`, sum six, `x<y<z` | Complete set `(0,1,5),(0,2,4),(1,2,3)`. If x is at least two the minimum sum is nine. At x zero, y is one or two; at x one, y must be two. |
| 23 | Integer `x,y in 0..6`, sum six; minimize `(x-1)^2+(y-2)^2` | Optimum `5`, at `(2,4)` and `(3,3)`. Substitution gives `2*x²-10*x+17=2*(x-2.5)²+4.5`; nearest integer x values are two and three. |
| 24 | Integer `x,y in -3..3`, sum zero; maximize `(x+2)*(y+2)` | Optimum `4`, uniquely at `(0,0)`. Substitute `y=-x` to get `4-x²`, globally bounded above by four. |
| 25 | Integer `x in -5..5`, `x*x=9`, `x!=3` | Complete set `{x:-3}`. Squaring leaves `-3,3`; the explicit exclusion removes three. |

## Reference discipline

Engine/matrix/unit expectations remain exact source expressions, with principal
units stated independently. Nonzero probability and electronvolt references
require relative agreement; a small absolute tolerance must not accept zero.
Rounded screen evidence supplements the full-precision CLI comparisons.
Constraint sets are complete, and objective references have global proofs rather
than selected feasible examples. References will be frozen together with the
25 algebra questions before any application observations. Any correction needed
during pre-observation review is documented here; later failures retain the
frozen answers and initial evidence.

Static stimulus-only review found that the initial zero-success binomial
`n=10,p=0.1,k=0` and central Cauchy interval `[-1,1]` exactly duplicated prior
questions. Before any application execution they were replaced with the twelve
trials/fifth-probability and `[0,sqrt(3)]` questions above, with new independent
derivations. No reference was fitted to an application answer.
