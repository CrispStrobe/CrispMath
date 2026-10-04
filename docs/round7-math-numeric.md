# Seventh independent numeric audit

These 25 questions and references are frozen before reviewing older fixtures,
current routing or app output. Source reads and edits stay on the shared VPS;
all app execution and browser tests belong on hosted CI.

1. `1e308*1e-308` = 1 exactly when decimal literals are interpreted exactly.
2. `(-11)%(-4)` = 1 under the calculator's Euclidean remainder convention:
   -11 = -3×4+1, with 0≤remainder<4.
3. `sqrt(1e-320)` = 1/10^160 exactly, the nonnegative root.
4. Determinant of [[9007199254740993,9007199254740994],
   [9007199254740994,9007199254740995]] = -1. With N=9007199254740993,
   N(N+2)-(N+1)^2 = -1; converting entries to doubles loses this identity.
5. Determinant of [[1,1],[1,1.0000000000000001]] = 1/10^16 exactly.
   Subtract the first product from the second; rounding the decimal cell to
   1 prematurely would turn an invertible matrix into a singular one.
6. RREF of [[1,2,3],[2,4,6],[0,1,1]] = [[1,0,1],[0,1,1],[0,0,0]].
   Row two is twice row one; subtracting twice the third row from the first
   leaves [1,0,1], and the two surviving leading pivots are in columns 1 and 2.
7. Inverse of [[1,1],[1,1.0000000000000001]] is
   [[10000000000000001,-10000000000000000],
   [-10000000000000000,10000000000000000]]. Its determinant is 1e-16;
   dividing the adjugate [[1.0000000000000001,-1],[-1,1]] by this
   exact determinant gives the stated integer entries.
8. Describe `[5e-324,5e-324]`: mean and median 5e-324, sample SD 0.
   This uses the smallest positive representable double in the data API;
   multiplying both midpoint terms by 1/2 first would erase the median.
9. Describe `[-5e-324,0,5e-324]`: mean and median 0, sample SD 5e-324.
   The sample squared-deviation sum is twice the squared scale, divided by 2.
10. Regression x=[-5e-324,0,5e-324], y=[-1e-323,0,1e-323]: slope 2,
    intercept 0, r²=1. Normalize both finite coordinate sets before products.
11. Describe `[1e308,1e308,-1e308,-1e308]`: mean and median 0,
    sample SD √(4/3)×1e308 ≈ 1.1547005383792515e308. The true mean is
    finite even when naive sorted summation overflows.
12. Binomial n=2,p=1e-200,k=1: 2p(1-p), represented as 2e-200.
    The correction 2e-400 is below double range; the nonzero mass is not.
13. Student-t(2) interval [1e10,2e10]: approximately 3.75e-21.
    Its survival function is (1-x/√(x²+2))/2 = 1/(2x²)+O(x^-4).
    Subtracting the tails gives 1/(2×1e20)-1/(8×1e20); the neglected
    term is below 1e-40. Subtracting two CDF values rounded to 1 loses it.
14. Chi-square goodness-of-fit observed=[0,10], expected=[5,5]: statistic
    10, df=1, p=erfc(√5) ≈ 0.0015654022580025497. Each bin contributes 5.
15. `10000000 erg in J` = 1 J by 1 erg = 1e-7 J.
16. `1 atm in bar` = 1.01325 bar: standard atmosphere is exactly 101325 Pa
    and a bar is 100000 Pa.
17. `-3 N * -2 m in J` = 6 J: both signs cancel and force×distance is energy.
18. `2 Hz * 3 s` = 6 dimensionless: inverse time cancels time.
19. `32 °F in K` = 273.15 K: 32 °F is 0 °C.
20. `1 g/L in kg/m³` = 1 kg/m³, since 0.001 kg/0.001 m³ = 1.
21. Minimize x*x-2*x*y+y*y, x,y in -2..2 and x+y=1: objective 1.
    This is (x-y)^2; x-y is odd, so its smallest magnitude is 1,
    attained at (0,1) and (1,0).
22. Minimize x*x-x*x+x for x in -3..3: objective -3. Repeated nonlinear
    terms cancel, leaving the original declared variable x.
23. Minimize x*y, x,y in -2..2 and x+y≥1: objective -2, attained at
    (-1,2) and (2,-1). The candidate -4 would require sum 0 and is excluded.
24. Maximize x*x+y*y, x,y in -1..1 and x+y=0: objective 2 at (±1,∓1).
25. Enumerate x,y in -2..2 and x*x+y*y≤1: exactly (0,0),(-1,0),(1,0),
    (0,-1),(0,1). Integer squared coordinates cannot take fractional values.

Unsupported functions or units remain explicit findings with unchanged
mathematical references. The tiny probability and subnormal statistics
require relative-value comparison so zero cannot masquerade as a valid answer.

## Routing and freshness review after freezing

The fixture contains seven engine evaluations and eighteen actual module
calls. There are no new adapters needed: describe, regression, binomial,
tInterval, chiSquare, unit and constrained objective routes already exist.
Exact decimal/matrix cases retain exact numeric values; matrix comparison
allows only whitespace differences already handled by the router.

A subsequent source-only input comparison found the original draft's 2×3
RREF case already present in two earlier corpora. Replace it with the 3×3
rank-two case above, retaining an independent row-operation derivation before
any backend execution. The replacement adds an independent pivot and a zero
dependent row. Parent review also finds the originally drafted singular
inverse in the simultaneously drafted algebra corpus. Replace it before
runtime output with the exact near-singular inverse in case 7, derived directly
from its adjugate and determinant above. No other draft input was duplicated.

Current catalog inspection finds no `erg` or `atm` entry. Cases 15 and 16
therefore distinguish common-unit feature gaps from incorrect supported
conversions. Their physical definitions remain unchanged. The far-tail
interval checks the actual existing tInterval route rather than importing an
external probability result into the app. Nonlinear objectives now have a
bounded polynomial route; all four references require the proven objective
from that real solver, not a truncated enumeration estimate.

No app results were inspected, and no local tests, calculations or builds
were run while preparing these references.
