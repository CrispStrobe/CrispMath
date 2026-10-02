# Second independent numeric audit

This draft was fixed before inspecting earlier corpus files. References use
exact arithmetic, elementary distribution identities, sample-statistic
definitions, dimensional conversion and complete finite solution sets.
Execution belongs on GitHub-hosted CI; no local batches are authorized.

1. Compute `(-2)^11 + 2^11` exactly.
2. Compute `(3/8 - 5/12) / (7/24)` exactly.
3. Compute `(10^40-1) % 9` exactly.
4. Compute `0^0`, explicitly testing the calculator's mathematical convention.
5. Compute `sqrt(81/16)`.
6. Compute `abs(-5/6) + abs(7/9)` exactly.
7. Compute `7!/(3!*4!)`.
8. Compute `2^(3^2)`.
9. Compute `(2^3)^2`.
10. Compute `(-3)^(-2)` exactly.
11. Describe the single observation `[7]`, especially its undefined sample SD.
12. Describe `[-5,-1,3,7]`.
13. Describe `[1000001,1000002,1000003]` without cancellation in variance.
14. Regress `y=-3*x+2` at `x=[-2,-1,0,1,2]`.
15. Compute the binomial mass with `n=5,p=0,k=0`.
16. Compute the binomial mass with `n=5,p=1,k=4`.
17. Compute binomial mass with `n=3,p=1/4,k=1`.
18. Compute binomial mass outside its support, `n=3,p=1/2,k=4`.
19. Compute normal CDF at `x=-6`, with mean -6 and SD 0.125.
20. Compute Student-t probability between -1 and 1 with two degrees of freedom.
21. Convert 1 megajoule to watt-hours.
22. Convert 500 micrometres to metres.
23. Convert 2.5 kilopascals to pascals.
24. Convert 5 square centimetres to square millimetres.
25. Convert 125 cubic centimetres to litres.
26. Convert 3.6 kilometres per second to metres per second.
27. Convert -22 Fahrenheit to Celsius.
28. Convert 310.15 kelvin to Fahrenheit.
29. Divide 12 metres by 3 seconds and express the result in kilometres per hour.
30. Compute work from 15 newtons times 2 metres, in joules.
31. Enumerate integers `x,y` in `[-3,3]` satisfying `x+y=-2` and `x<y`.
32. Enumerate integers `x,y` in `[-3,3]` satisfying `x*y=0`.
33. Enumerate integers `x` in `[-4,4]` satisfying `x*x>=9`.
34. Enumerate integers `x` in `[-3,3]` satisfying `x*x*x=8`.
35. Enumerate distinct `a,b,c` in `[0,3]` satisfying `a+b+c=3`.
36. Prove infeasibility of `x+y=1` with both variables in `[2,4]`.
37. Enumerate binary `a,b,c,d` satisfying `a+b+c+d=1`.
38. Minimize `x+y` in `[0,5]`, subject to `2*x+y>=7`.
39. Enumerate integers `x,y` in `[-2,2]` satisfying `x*x*y=0` and `x!=0`.
40. Enumerate integers `x,y` in `[0,5]` satisfying `3*x-2*y=1`.

Questions 4 and 11 deliberately probe definitions and error handling rather
than assuming every boundary input has a finite numeric answer. Their actual
app behavior must be reported explicitly.

## Independent answers

The runnable fixture is `test/fixtures/round2_numeric_tasks.json` and contains
exactly 40 tasks. Thirty module tasks also have separate unit cases in
`test/round2_numeric_modules_test.dart`. No results have been generated locally.

| Problems | Reference derivation |
| --- | --- |
| 1–3 | Opposite odd powers cancel to 0. The rational difference is `-1/24`, then division gives `-1/7`. Every `10^k-1` is divisible by 9, giving remainder 0 even for k=40. |
| 4 | Expected 1 uses the empty-product convention of polynomial and combinatorial arithmetic. This is a stated convention test, not a claim that every analytic context defines `0^0`. |
| 5–7 | Positive square root is `9/4`; magnitudes sum to `(15+14)/18=29/18`; `7 choose 3=35`. |
| 8–10 | `2^(3^2)=2^9=512`; `(2^3)^2=2^6=64`; reciprocal of `(-3)^2` gives `1/9`. |
| 11 | Mean and median are 7. Sample variance divides the sum of squared deviations by `n-1=0` and is undefined, represented by null in the reference. Reporting zero would confuse sample SD with population SD. |
| 12 | Mean and median are 1; squared deviations total 80, giving sample SD `sqrt(80/3)=5.163977794943222`. |
| 13 | Mean and median are 1000002; squared deviations total 2 and sample SD is `sqrt(2/2)=1`. |
| 14 | The exact line is `y=-3*x+2`; slope -3, intercept 2, and `r²=1`. |
| 15–18 | Degenerate binomial endpoint masses are respectively 1 and 0. For `n=3,p=1/4,k=1`, `3*(1/4)*(3/4)^2=27/64=0.421875`. An out-of-support mass is zero. |
| 19–20 | Normal symmetry gives 1/2. The Student-t(2) CDF is `1/2+x/(2*sqrt(x²+2))`; the central interval probability is `1/sqrt(3)=0.5773502691896257`. |
| 21 | A watt-hour is 3600 joules, so one megajoule is `1000000/3600=2500/9` Wh, rendered to ten decimal places as `277.7777777778 Wh`. |
| 22–26 | SI and dimensional factors give `0.0005 m`, `2500 Pa`, `500 mm²`, `0.125 L`, and `3600 m/s`. Area and volume factors must be squared/cubed. |
| 27–30 | Affine temperature conversion gives -30°C and 98.6°F. Speed is `12/3=4 m/s=14.4 km/h`. Work is `15*2=30 J`. |
| 31 | Substitute `y=-2-x`; bounds and ordering permit exactly `(-3,1),(-2,0)`. |
| 32 | Product zero describes both coordinate axes: 7 possibilities for x=0 plus 7 for y=0, minus their common origin, gives 13 complete solutions. |
| 33–34 | Square at least 9 yields exactly -4,-3,3,4; cube equal to 8 yields exactly 2. |
| 35 | Distinct nonnegative values summing to 3 must be 0,1,2; all six permutations are solutions. |
| 36–37 | Domain minima force a sum at least 4, so sum 1 is impossible. Exactly one of four binary variables gives four complete unit-vector assignments. |
| 38 | If `x+y<=3`, then `2*x+y<=2*(x+y)<=6`, contradicting the lower bound 7. Cost 4 is feasible at `(3,1)` and `(4,0)`, proving the minimum is 4. |
| 39–40 | Nonzero x forces y=0 in the repeated product, yielding four signed x values. `3*x-2*y=1` forces x odd, and bounds retain exactly `(1,1),(3,4)`. |

## CLI integration and findings to verify

The `constraintObjective` adapter invokes the actual app solver and reports
its objective, rather than asserting one arbitrarily chosen minimizer when
multiple optima exist. The reference remains 4 independently of selection.

Initial source inspection identifies two likely findings that are retained
with their original mathematical answers: the statistics implementation
returns zero for singleton sample SD, and the unit catalog lacks watt-hours.
These have not been converted into expected rejections or skipped tasks.
Other inputs (including composite prefixed speed and squared millimetres)
still require actual runtime verification. There are no claimed passes before
GitHub CI executes the real paths.
