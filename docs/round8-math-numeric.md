# Eighth independent numeric audit

These 25 mathematical questions and references are drafted before reviewing
prior fixtures, app routing or execution output. All actual app tests and
builds run on hosted CI; the shared VPS is limited to tiny source edits.

1. `(((-3)/2)^(-2))^(-1)` = 9/4, exactly. The inner reciprocal square
   is 4/9, and its reciprocal is 9/4.
2. `factorial(30)/factorial(29)` = 30, exactly, by cancelling the first
   29 factorial factors.
3. `gcd(-84,30)` = 6. GCD uses nonnegative magnitude; Euclid gives
   84 mod 30=24, 30 mod 24=6, 24 mod 6=0.
4. `lcm(12,18,30)` = 180: the union of prime factors is 2²×3²×5.
5. `sqrt(4/9+5/9)` = 1 exactly, the nonnegative square root of 1.
6. Trace of [[-2,1],[0,3]] = 1, the sum of its diagonal entries.
7. Inverse of [[1,1,0,0],[0,1,1,0],[0,0,1,1],[0,0,0,1]] is
   [[1,-1,1,-1],[0,1,-1,1],[0,0,1,-1],[0,0,0,1]]. Write the input
   as I+N; N⁴=0, so its inverse is I-N+N²-N³.
8. [[0,1],[0,0]] to the third power is the 2×2 zero matrix, since
   this matrix already squares to zero.
9. RREF of [[0,1,0],[0,0,1],[1,0,0]] is the 3×3 identity. Cycle the
   three rows into leading-pivot order; each pivot is already 1.
10. Describe [-3,-1,1,1,2]: mean 0, median 1, sample SD 2. The sum
    is 0, and squared-deviation sum 9+1+1+1+4=16 divided by 4 is 4.
11. Describe [0,0,0,0,0,0,1]: mean 1/7, median 0, sample SD 1/√7.
    Squared deviations sum to 6/7, and Bessel division by 6 yields 1/7.
12. Regression x=[-2,-1,1,2], y=[4,1,1,4]: slope 0, intercept 2.5,
    r²=0. Odd covariance cancels while both axes have nonzero variance.
13. Regression x=[1,2], y=[10,-10]: slope -20, intercept 30, r²=1.
    Two distinct predictor values define the line exactly.
14. Binomial n=52,p=1/52,k=1: C(52,1)(1/52)(51/52)^51,
    simplifying to (51/52)^51 ≈ 0.3714569219134604.
15. Normal CDF mean=2, SD=3, x=0: Φ(-2/3)=(1-erf(√2/3))/2.
    This gives approximately 0.2524925375469229.
16. Student-t(4) interval [0,2]: 5/(8√2). With
    z=x/√(x²+4), the antiderivative from zero is 3z/4-z³/4;
    at x=2 this gives 3/(4√2)-1/(8√2).
17. Chi-square GOF observed=[10,10,10], expected=[10,10,10]:
    statistic 0, df 2, upper-tail probability 1.
18. `1 kWh / 1 h in kW` = 1 kW, since 3.6e6 J/3600 s=1000 W.
19. `1 N * 1 s in kg*m/s` = 1 kg*m/s. A newton is kg*m/s²;
    multiplication by time leaves impulse dimensions kg*m/s.
20. `1 m² * 1 m in L` = 1000 L because 1 m³=1000 L.
21. `1 J / 2 kg in erg/g` = 5000 erg/g. One erg per gram is
    1e-7 J/0.001 kg=1e-4 J/kg, while the source is 0.5 J/kg.
22. Enumerate x,y in 0..3 with x+y=3 and x*y=0:
    exactly (0,3),(3,0), the two assignments containing a zero factor.
23. Minimize x*x+y*y, x,y in -2..2, x≥1 and y≤-1:
    objective 2, attained at (1,-1); each square is at least 1.
24. Maximize x*y-z*z, x,y,z in 0..2, allDifferent:
    objective 2 at (1,2,0) and (2,1,0). For z=1 the remaining
    product is 0 and objective -1; for z=2 it is -4.
25. Enumerate x in -2..2, x*x≤1 and x!=0: exactly -1 and 1.

Absent functions or target syntax are feature findings, not mathematical
rejections. Every reference stays fixed after actual app output is observed.

## Routing, independent decimals and freshness

The final fixture contains eight engine tasks and seventeen actual module
calls. GCD calls the app's real binary GCD operation; the three-number LCM
uses the existing chain adapter with actual LCM(12,18)=36 followed by
LCM(36,30)=180. This composes already exposed operations rather than assuming
a three-argument calculator function. Statistics, distributions, GOF, units
and constraints use existing production modules.

The probability formulas were derived above before routing review. A tiny
independent reference-only arithmetic check evaluated (51/52)^51 using
60-digit Python Decimal, obtaining
0.371456921913460393746460455084707398042429914368238806672787.
The normal decimal uses the independently derived erf expression and Python
math.erf, not an app result. The t4 probability is 5/(8√2) ≈
0.4419417382415922. Sample deviation case 11 is 1/√7 ≈
0.3779644730092272. Expected matrices require exact cell values while allowing
the router's existing whitespace normalization.

Freshness review found the originally proposed 3×3 unit upper-triangular
inverse already in round-seven algebra. Replace it before observing outputs
with the 4×4 nilpotent-series inverse above, deriving its extra -N³ term.
The final source-only comparison against all prior/current task fixtures
found no duplicate inputs. No other reference was replaced.

The product target `kg*m/s` is mathematically valid impulse syntax; the unit
parser's supported target grammar may expose a genuine feature gap. Retain
the reference rather than changing it to an expected error. Target units
retain their declared spellings: kW, kg*m/s, L and erg/g. There are no new
CLI adapters required and no mathematical rejection cases in this corpus.
No app outputs were inspected and no local app tests, CLI corpus execution,
browser runs or builds were performed.
