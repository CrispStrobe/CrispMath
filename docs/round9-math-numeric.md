# Round nine: independent numerical references

Drafted before inspecting prior fixtures, current CLI routes, or app results. These references are mathematical oracles, not observations of the implementation. No local app execution is authorized; execution belongs on hosted CI.

1. Reciprocal of a sum of reciprocals: `1/(1/7+1/11)` = **77/18**, exactly.
2. Cancellation of odd signed powers: `(-2)^15+2^15` = **0**, exactly.
3. Determinant of `[[2,3,1],[4,1,-3],[-2,5,2]]` = **50**. First-row expansion is 34−6+22.
4. Inverse of `[[2,1],[1,1]]` = **[[1,-1],[-1,2]]**. Its determinant is one.
5. Ordered product `[[1,2],[0,1]] * [[1,0],[3,1]]` = **[[7,2],[3,1]]**; reversing factors changes the answer.
6. Exact rational square root: `sqrt(81/121)` = **9/11**.
7. Descriptive statistics of `[1e-200,2e-200,3e-200]`: mean and median **2e-200**, sample SD **1e-200**. A finite SD must survive underflow of the squared deviations.
8. Descriptive statistics of `[1e200,2e200,3e200]`: mean and median **2e200**, sample SD **1e200**. A representable SD must survive overflow of variance.
9. Regression x=`[-2,-1,0,1,2]`, y=`[4,1,0,1,4]`: slope **0**, intercept **2**, R² **0** by symmetry and positive response variance.
10. Regression x=`[0,1,2]`, y=`[2,2,5]`: slope **1.5**, intercept **1.5**, R² **0.75**. Centered cross-product=3, predictor SS=2, response SS=6.
11. Binomial probability n=1,000,000, p=1/1,000,000, k=2: **C(1,000,000,2)·10^-12·(1−10^-6)^999998**, approximately **0.1839398125556351**. Direct 60-digit Decimal integer-power arithmetic supplies the independent decimal; the logarithmic formula must retain accuracy despite a large trial count and tiny success rate.
12. Binomial probability n=10, p=1/10, k=0: **(9/10)^10 = 0.3486784401**.
13. Normal mean=0, SD=2, x=2: **Φ(1)=0.8413447460685429**.
14. Student t, df=1, interval `[1,sqrt(3)]`: **1/12**. The Cauchy primitive is atan(x)/π.
15. Student t, df=2, interval `[-sqrt(2/3),sqrt(2/3)]`: **1/2**, since central probability is x/sqrt(x²+2).
16. Chi-square goodness of fit observed `[0,20]`, expected `[10,10]`: statistic **20**, df **1**, upper p **erfc(sqrt(10)) ≈ 7.744216431044084e-6**.
17. `1 atm * 1 L in J`: **101.325 J**, pressure-volume work (101325 Pa times 0.001 m³).
18. `1 erg / 1 cm in N`: **0.00001 N**, energy divided by distance.
19. `1 mA * 1 kΩ in V`: **1 V**, SI-prefix cancellation in Ohm's law.
20. `1 kg / 1 L in g/cm³`: **1 g/cm³**, equivalent mass density.
21. `1 m² / 1 s² in J/kg`: **1 J/kg**, dimensional equivalence of specific energy.
22. Constraint x,y in `0..4`, `x+y==4`, `x*y==3`: exactly **(1,3),(3,1)**.
23. Constraint x in `-4..4`, `x*x==9`, `x<0`: exactly **x=-3**.
24. Minimize `(x-2)*(x-2)+(y+1)*(y+1)` over integer x,y in `-3..3`, with `x+y==0`: objective **1**; minimizers (1,-1) and (2,-2). Substitution gives 2x²−6x+5.
25. Maximize `x*y` over integer x,y in `-3..3`, with `x+y==1`: objective **0**, attained at (0,1),(1,0); parabola x(1−x) has continuous optimum 1/4 between integers.

## Reference precision

Exact engine results require exact evidence. Statistical values use independent mathematical references with relative tolerance suitable for floating arithmetic; tiny positive quantities must not be accepted as zero by an absolute floor. Converted quantities must include their correct dimensions. Constraint sets are unordered complete sets, and optimization compares the objective rather than enumeration order.

## Routing and freshness review

The CLI uses six engine evaluations and nineteen module cases through existing routes: describe, regression, binomial, normalCdf, tInterval, chiSquare, unit, constraint, and constraintObjective. No new adapter is required. Unicode ohm support is a product capability under test, not grounds for an expected rejection.

A post-draft comparison of routed inputs found the original central binomial n=1000, p=1/2, k=500 duplicated round6-numeric-10. It was replaced before any app observation with the rare-event million-trial case above, derived independently. All other routed inputs are distinct from previous `*tasks.json` fixtures. References remain mathematical requirements even if a current implementation lacks a path. Case 11 requires a relative probability accuracy sufficient to detect cancellation from subtracting large log-factorials; the comparator's existing relative tolerance applies.
