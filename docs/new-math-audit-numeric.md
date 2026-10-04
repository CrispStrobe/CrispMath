# Fresh numeric, statistics, units and discrete audit

These 40 challenges were drafted before inspecting the existing corpus or
adapters. Expected answers will come from arithmetic, definitions, finite
enumeration or distribution identities, never from CrispMath output.

1. Calculate `(2^80 + 1) - 2^80` exactly.
2. Calculate `1/6 + 1/10 + 1/15` exactly.
3. Evaluate `sqrt(144) + abs(-17) - 5!`.
4. Evaluate `sin(pi/6)^2 + cos(pi/6)^2`.
5. Evaluate `ln(exp(3/2))`.
6. Evaluate `2^(-3) + 4^(-2)`.
7. Evaluate `abs(-3/7) / (9/14)` exactly.
8. Evaluate the geometric sum `1 + 1/3 + 1/9 + 1/27`.
9. Evaluate `cos(pi) + sin(pi/2)`.
10. Evaluate the cancellation `10^30 + 7 - 10^30` exactly.
11. Find the arithmetic mean of `[2, 4, 8, 10]`.
12. Find the sample standard deviation of `[3, 3, 3, 3]`.
13. Find the sample variance of `[1, 3, 5]`.
14. Find the median of `[9, 1, 7, 3]`.
15. Compute the normal CDF at its own mean for mean 12 and SD 4.
16. Compute the exponential survival probability at one mean lifetime.
17. Compute `P(X=2)` for binomial `n=4`, `p=1/2`.
18. Compute the standard Cauchy probability between -1 and 1.
19. Convert 2500 millimetres to metres.
20. Convert 3 hours to seconds.
21. Convert 72 kilometres per hour to metres per second.
22. Convert one square kilometre to square metres.
23. Convert 1 litre to cubic metres.
24. Convert -40 degrees Celsius to Fahrenheit.
25. Convert 273.15 kelvin to Celsius.
26. Convert 2500 milligrams to grams.
27. Find the determinant of `[[2,1,0],[0,3,1],[0,0,4]]`.
28. Invert `[[1,2],[3,5]]`.
29. Find the determinant of `[[1,2],[2,4]]`.
30. Find eigenvalues of `[[0,-1],[1,0]]`.
31. Find the RREF of `[[1,2,3],[2,4,6]]`.
32. Multiply `[[1,2],[3,4]]` by `[[0,1],[1,0]]`.
33. Count permutations of three distinct items using finite constraints.
34. Find all integers `x,y` in `[0,4]` satisfying `x+y=4` and `x<y`.
35. Count 4-queens solutions.
36. Find binary `a,b,c` with `a+b+c=2` and `a!=b`.
37. Find integers `x,y` in `[1,4]` with `x*y=6`.
38. Find all integers `x` in `[-3,3]` satisfying `x*x=4`.
39. Demonstrate infeasibility of three pairwise distinct binary variables.
40. Find integers `x,y` in `[0,3]` satisfying `x+2*y=5`.

No execution is performed on the shared VPS. The fixture and actual app-path
results are to be run on GitHub-hosted CI.

## Independent answers and integration

The runnable fixture is `test/fixtures/new_math_numeric_tasks.json`. Each
number below refers to the original draft above. All constraint expectations
list complete solution sets, rather than accepting the first solution.

| Problems | Independent derivation / answers |
| --- | --- |
| 1–2 | Integer cancellation gives 1; common denominator 30 gives `(5+3+2)/30 = 1/3`. |
| 3–5 | `12+17-120=-91`; the trigonometric norm is 1; logarithm/exponential inversion gives `3/2`. |
| 6–8 | `1/8+1/16=3/16`; `(3/7)/(9/14)=2/3`; geometric sum is `(27+9+3+1)/27=40/27`. |
| 9–10 | `-1+1=0`; integer cancellation gives 7, including when intermediates exceed IEEE-754 exact integers. |
| 11 | Mean and median are 6; squared deviations total 40, so sample SD is `sqrt(40/3) = 3.6514837167011076`. |
| 12 | Mean and median are 3; every deviation is zero, so sample SD is zero. |
| 13 | Mean/median 3; squared deviations total 8, sample variance `8/(3-1)=4`, so sample SD is 2. |
| 14 | Sorted data are `[1,3,7,9]`, median 5, mean 5; squared deviations total 40 and sample SD is `sqrt(40/3)`. |
| 15 | Symmetry places exactly half a normal distribution's probability below its mean. |
| 16 | Exponential survival is `exp(-rate*t)`; at one mean lifetime `rate*t=1`, giving `exp(-1) = 0.36787944117144233`. |
| 17 | `choose(4,2)*(1/2)^4=6/16=0.375`. |
| 18 | Standard Cauchy CDF is `1/2+atan(x)/pi`; difference at ±1 is `2*(pi/4)/pi=1/2`. Student t with one degree of freedom is the same distribution. |
| 19–23 | Prefix/time/dimensional factors give `2.5 m`, `10800 s`, `20 m/s`, `1000000 m²`, `0.001 m³`. The kilometre area factor is squared. |
| 24–26 | `F=9*C/5+32` gives -40; `C=K-273.15` gives 0; milligrams to grams gives 2.5. |
| 27 | An upper triangular determinant is the diagonal product `2*3*4=24`. |
| 28 | Determinant is -1; adjugate division gives `[[-5,2],[3,-1]]`. Multiplying by the original matrix gives identity. |
| 29–31 | Proportional rows give determinant zero; rotation characteristic polynomial is `lambda²+1`, roots ±i; subtract twice row one to obtain RREF `[[1,2,3],[0,0,0]]`. |
| 32 | Multiplication by the swap matrix exchanges columns, giving `[[2,1],[4,3]]`. |
| 33 | Three distinct values in a three-value domain give all `3!=6` permutations. |
| 34 | Substituting `y=4-x` and requiring `x<y` gives exactly `(0,4),(1,3)`. |
| 35 | The two nonattacking four-queen row permutations are `(2,4,1,3)` and `(3,1,4,2)`. Each row, column and diagonal can be checked directly. |
| 36 | Inequality requires `(a,b)=(0,1)` or `(1,0)`; the sum then forces `c=1`. |
| 37–38 | Factors of 6 in `[1,4]` give `(2,3),(3,2)`; signed integer square roots of 4 are exactly -2 and 2. |
| 39 | Three distinct values cannot fit in a two-value domain: the solution set is empty. |
| 40 | `x=5-2*y` within `[0,3]` gives exactly `(1,2),(3,1)`. |

The existing descriptive adapter exposes mean, median and sample SD. Problem
13 therefore checks SD 2, which is equivalent to sample variance 4; it does
not claim direct coverage of a sample-variance CLI field. Problems 15 and 18
need thin `normalCdf` and `tInterval` adapters over the existing distribution
classes, added by the parent task. Problem 16 uses the actual calculator's
`exp(-1)` evaluation: the app currently has no dedicated exponential
distribution class or screen, so this is formula calculation coverage only.

Some freshly drafted questions coincidentally overlap older corpus questions
(road-speed conversion and four queens). They remain here because the draft
was fixed before inspecting the older corpus; the other cases probe different
inputs and boundaries.
