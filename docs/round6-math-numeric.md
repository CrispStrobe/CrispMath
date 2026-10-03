# Sixth independent numeric audit

These 25 questions and mathematical references are drafted before consulting
older fixtures, current app routing or backend output. Hosted CI will execute
the app; the shared VPS is used only for small source edits and reads.

1. `(1+10^(-20))-1` = 1/100000000000000000000, exactly. This checks
   cancellation below double precision without rounding the input to 1.
2. `sqrt((3/7)^2)` = 3/7, the nonnegative exact root.
3. `(1/3)^(-2)/9` = 1, exactly, since the reciprocal square is 9.
4. `floor(-7/3)` = -3, since -3 ≤ -7/3 < -2.
5. `ceiling(-7/3)` = -2, the least integer at least -7/3.
6. `abs(-2+sqrt(4))` = 0, exactly.
7. Describe `[1e308,1e308]`: mean 1e308, median 1e308, sample SD 0.
   Constant finite observations must not acquire infinity through summation.
8. Describe `[-1e308,1e308]`: mean 0, median 0,
   sample SD √2×1e308, a finite value despite overflowing squared deviations.
9. Describe `[-1e150,0,1e150]`: mean 0, median 0, sample SD 1e150.
10. Binomial n=1000,p=1/2,k=500: C(1000,500)/2^1000,
    approximately 0.0252250181783608. The answer is finite even though the
    separate combination is very large.
11. Normal CDF mean=1e9, SD=1, x=1e9+1:
    (1+erf(1/√2))/2 ≈ 0.8413447460685429.
12. Student-t(1) interval lower=2, upper=2: probability 0.
13. `1 acre in m²` = 4046.8564224 m². An international acre is
    43560 square feet; one foot is exactly 0.3048 m.
14. `180 deg in rad` = π rad, displayed 3.1415926536 rad.
15. `1 ha in m²` = 10000 m² by the hectare definition.
16. `1e-3 bar in Pa` = 100 Pa because 1 bar = 100000 Pa.
17. `1 Wh/kg in J/kg` = 3600 J/kg; dividing by the same mass unit
    must preserve the noncoherent energy scale.
18. `10 cm / 2 mm` = 50, dimensionless: 0.1/0.002 = 50.
19. Enumerate x,y in 0..2 with x+y=5: no solutions, since the largest
    possible sum is 4.
20. Three binary variables constrained allDifferent: no solutions by the
    pigeonhole principle, not an evaluation error.
21. Enumerate x,y in -2..2 with x*y≥2: exactly (-2,-2),(-2,-1),
    (-1,-2),(1,2),(2,1),(2,2). Zero and opposite signs cannot qualify.
22. Enumerate x in -4..4 with x*x*x=-8: exactly x=-2, since the cube
    is strictly increasing on integers.
23. Minimize x*x for x in -3..3: objective 0 at x=0; the objective
    has an interior optimum rather than an extreme-domain optimum.
24. Transpose [[1,2,3],[4,5,6]]: [[1,4],[2,5],[3,6]].
25. Determinant of [[1,2,1],[3,4,3],[5,6,5]]: 0 because the first
    and third columns coincide.

Unsupported functions, units or optimization expressions remain explicit
findings; references are never changed to accommodate app behavior.

## Routing and freshness review after freezing references

The fixture contains eight actual engine evaluations (including the two
matrix operations) and seventeen real module calls. A source-only comparison
against existing task fixtures found no duplicate inputs; no question needed
replacement. Matrix transpose is routed through the existing matrix evaluator.
All six scalar engine cases require exact output. The extreme descriptive
samples require finite mean, median and sample deviation wherever the
independent references are finite; an overflowing intermediate is a defect,
not permission to change the answer to infinity or null.

The large binomial reference is the integer coefficient
`1000!/(500!×500!)` divided by `2^1000`, not a product obtained from the app.
The normal probability standardizes `(1000000001-1000000000)/1` to 1;
translation must preserve the probability. The acre, hectare and matrix
functions already have source routes. Degree aliases currently include
`degree` and `degrees`, but not `deg`: case 14 preserves a common mathematical
unit spelling as an explicit possible input feature gap.

Source inspection documents that optimization objectives currently support
only linear expressions and reject nonlinear objectives. Case 23 is therefore
an explicit feature-scope challenge, rather than a claim that nonlinear
optimization already works. Its mathematical optimum remains 0. Distinguish
that limitation from incorrect answers in supported constraint paths. No
backend output was read and no local app tests, CLI runs or builds were used.
