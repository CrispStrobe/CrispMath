# Fourth independent numeric audit

These 25 questions and reference answers were drafted before inspecting
earlier fixtures or runtime output. All execution belongs on GitHub CI.

1. Evaluate `(0.25)^(-2)` exactly:16.
2. Evaluate `(-0.5)^3` exactly:-1/8.
3. Evaluate `((10^20)+3)%7` exactly:5.
4. Evaluate `(5/7)^0` exactly:1.
5. Evaluate `sqrt(49)/sqrt(121)` exactly:7/11.
6. Evaluate `(-20)%6` using nonnegative Euclidean remainder:4.
7. Describe `[1,1,1,9]`: mean3, median1, sample SD4.
8. Describe `[-0.5,0,0.5]`: mean0, median0, sample SD0.5.
9. Fit x=[1000000000,1000000001,1000000002],
   y=[1,3,5]: slope2, intercept-1999999999, r²1.
10. Fit x=[0,1,2], y=[1000000000,1000000002,1000000004]:
    slope2, intercept1000000000, r²1.
11. Compute binomial mass n=0,p=0.3,k=0:1.
12. Compute binomial mass n=4,p=0.3,k=-1:0.
13. Compute Student-t(1) probability on[-sqrt(3),sqrt(3)]:2/3.
14. Compute Student-t(2) probability on[0,sqrt(2)]:1/(2*sqrt(2)).
15. Convert250mW toW:0.25W.
16. Convert1kPa toN/cm²:0.1N/cm².
17. Convert1mL tomm³:1000mm³.
18. Compute3Wh/2h inW:1.5W.
19. Convert2µm/ms tom/s:0.002m/s.
20. Find determinant of[[-1,2],[3,-4]]:-2.
21. Find inverse of[[0,1],[1,0]]:the same matrix.
22. Enumerate x,y in[-2,2] satisfying x*y=-4:
    exactly(-2,2),(2,-2).
23. Enumerate x,y in[0,3] satisfying x*x+y*y=5:
    exactly(1,2),(2,1).
24. Enumerate x in[-4,4] satisfying x*x*x*x=16:
    exactly-2and2.
25. Minimize x-y for x,y in[-2,2] subject to x+y=1:
    optimum-3 at x=-1,y=2.

Problem5 requests exact rational evaluation of perfect-square roots, rather
than merely a rounded decimal. Problems9and10 deliberately use large offsets
with small centered variation to test stable regression formulas. Problem16
uses a compound target dimension, not a different mathematical pressure unit.

## Independent derivations and routing

The fixture contains 25 tasks: eight engine calculations and seventeen real
module operations. No app output was consulted to form these answers.

The exact arithmetic references follow `1/(1/4)^2=16`,
`(-1/2)^3=-1/8`, and `10^20 mod7=2` because the powers of10 have
period6 modulo7 and20 has remainder2. Adding3 gives remainder5.
The nonzero rational's zeroth power is1; perfect-square roots are7and11;
Euclidean division is `-20=(-4)*6+4`.

For the outlier sample, deviations from3 are -2,-2,-2,6, with squared sum48;
sample variance16 gives SD4. For the centered decimal sample, the squared
sum0.5 divided by2 gives variance0.25 and SD0.5. The large-offset regression
samples lie on exact lines `y=2*x-1999999999` and `y=2*x+1000000000`.
Their centered variation remains finite and nonzero even though subtracting
large raw sums of squares can lose it in floating-point arithmetic.

With zero binomial trials the only result is zero successes, probability1;
negative success counts have probability0. Cauchy CDF differences give
`2*atan(sqrt(3))/pi=2/3`. Student-t(2) CDF gives
`sqrt(2)/(2*sqrt(2+2))=1/(2*sqrt(2))` above its median. Fixture endpoints
use independently rounded double representations of sqrt2andsqrt3.

Conversion uses `1mW=0.001W`; `1N/cm²=10000Pa`; `1mL=10^-6m³` and
`1mm³=10^-9m³`; division of3600J by3600s gives1W; and
`2µm/ms=2*10^-6m/(10^-3s)=0.002m/s`.
The determinant is `(-1)*(-4)-2*3=-2`. The swap matrix squares toidentity,
so it is its own inverse. The remaining references list complete solution
sets: negative product4 requires opposite signed2s; sum of squares5 requires
1and2 in either order; fourth power16 requires -2or2. Finally,
`x-y=1-2*y` under x+y1, with maximal feasible y2, proves minimum-3.

After freezing the draft, a small source/schema inspection identifies likely
stability gaps for the large-offset regressions and unsupported compound
pressure targets. The exact radical quotient may also expose precision-path
coverage. These remain original expectations for native and web verification;
no rejections, skips or adapted oracle values have been introduced. A small
search of preceding numeric fixtures found no matching cases. All runtime
checks and any resulting fixes will follow the remote initial audit.
