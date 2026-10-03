# Fifth independent numeric audit

This draft and its reference values were fixed before inspecting prior
fixtures or app output. Only GitHub CI will execute app tests.

1. Exact terminating decimal sum `0.001+0.009`:1/100.
2. Exact nested fraction `(2/3)/(4/9)`:3/2.
3. Exact signed rational power `(-2/5)^(-3)`:-125/8.
4. Exact integer remainder `(2^50+5)%13`:9.
5. Exact roots `sqrt(0.0004)`:1/50.
6. Exact quotient `sqrt(9/100)/sqrt(4/25)`:3/4.
7. Descriptive data `[0,0,0,0,10]`:mean2,median0,sample SDsqrt20.
8. Descriptive data `[2,5]`:mean3.5,median3.5,sample SD3/sqrt2.
9. Regression x=[-3,-1,1,3], y=[3,1,-1,-3]:slope-1,intercept0,r²1.
10. Regression x=[-1e-200,0,1e-200], y=[-2e-200,0,2e-200]:
    slope2,intercept0,r²1 despite underflow in unscaled products.
11. Binomial mass n=6,p=1/2,k=0:1/64.
12. Binomial mass n=6,p=1/2,k=6:1/64.
13. Student-t(1) probability between -1and0:1/4.
14. Student-t(2) probability between -2and2:2/sqrt6.
15. Convert3MJ tokWh:5/6kWh, displayed0.8333333333kWh.
16. Convert7.5mL toµL:7500µL.
17. Convert1g/cm³ tokg/L:1kg/L.
18. Convert1kN/m² tobar:0.01bar.
19. Convert2W/ms tokW/s:2kW/s.
20. Convert0.25N/mm² toN/cm²:25N/cm².
21. Enumerate x,y in[-2,2] with x*x-y*y=3:
    four assignments with x=±2and y=±1.
22. Enumerate x,y in[0,4] with x*y=4and x<=y:
    exactly(1,4),(2,2).
23. Enumerate x in[-3,3] with x*x*x !=0:
    exactly-3,-2,-1,1,2,3.
24. Enumerate binary a,b,c with a+b+c>=2and a=c:
    exactly(1,0,1),(1,1,1).
25. Maximize x-y for x,y in[-3,3], x+y=-1:
    optimum5 at x2,y-3.

References use exact arithmetic, sample-variance definitions, scaled line
coefficients, closed-form probabilities and complete finite solution sets.
Unsupported units or parser scope must be reported explicitly; expectations
will not be adapted to app behavior.

## Independent derivations

1. Sum the decimal numerators over 1000: 10/1000 = 1/100.
2. Multiply by the reciprocal: (2/3)(9/4) = 3/2.
3. Invert before cubing: (-5/2)^3 = -125/8.
4. Since 2^12 = 4096 = 1 modulo 13 and 50 = 4×12+2,
   2^50+5 has remainder 4+5 = 9.
5. (1/50)^2 = 1/2500 = 0.0004, with nonnegative root 1/50.
6. The positive roots are 3/10 and 2/5; their quotient is 3/4.
7. The deviations are -2,-2,-2,-2,8. Their squared sum is 80;
   the sample variance is 80/(5-1) = 20.
8. The mean is 7/2. Deviations ±3/2 give sample variance 9/2.
9. Every point obeys y = -x; both axes vary, so r² = 1.
10. Every point obeys y = 2x, with varying predictor and response.
    Scaling both axes by 1e200 gives [-1,0,1] and [-2,0,2], preserving
    slope 2, intercept 0 and r² 1 without squaring tiny floating values.
11–12. Each extreme outcome contains one sequence of six independent fair
    trials, with probability (1/2)^6 = 1/64.
13. Cauchy CDF is 1/2+atan(t)/π; the interval from -1 to 0 has mass 1/4.
14. Student-t with two degrees of freedom has CDF
    1/2+t/(2√(t²+2)); subtracting at ±2 gives 2/√6.
15. One kWh is 3.6 MJ, so 3 MJ is 5/6 kWh. The fixture records the
    existing ten-decimal display contract rather than an altered reference.
16. A millilitre is 1000 microlitres; 7.5×1000 = 7500.
17. 1 g/cm³ is 0.001 kg/0.000001 m³ = 1000 kg/m³.
    One litre is 0.001 m³, so this is 1 kg/L.
18. One bar is 100000 Pa. One kN/m² is 1000 Pa, hence 0.01 bar.
19. Division by a millisecond multiplies the per-second rate by 1000;
    expressing watts as kilowatts divides by 1000, leaving coefficient 2.
20. A square millimetre is 1/100 of a square centimetre, so pressure
    expressed per square centimetre has coefficient 0.25×100 = 25.
21. Available squares are 0,1,4. Their only difference of 3 is 4-1,
    giving the four independent sign choices x=±2 and y=±1.
22. Nonnegative ordered factor pairs of 4 in the domain are (1,4),(2,2).
23. An integer cube is zero exactly when its base is zero. Remove only 0
    from the seven-element domain.
24. If a=c=0 the sum cannot reach 2. If a=c=1, either b=0 or b=1 works.
25. Substitute y=-1-x: x-y=2x+1. The bounds on y require x≤2;
    x=2,y=-3 reaches the maximum 5.

## Routing and freshness review

The references above were frozen before reading old fixtures or current
module routing. All 25 cases now use the portable CLI fixture schema:
six engine evaluations and nineteen real module calls. Exact arithmetic
cases require exact output, not a decimal approximation. Constraint cases
require complete solution sets, with ordering ignored, and the optimization
case checks the actual objective returned by the solver.

A subsequent source-only freshness check found no identical engine
expressions, unit expressions, data pairs or constraint programs in the
previous numeric audits. Similar mathematical families intentionally use
different domains, signs, magnitudes and conversion dimensions.

Source inspection found no catalog entry for `bar`. Case 18 is therefore
an explicit possible feature gap: retain its independently derived answer
and report an unsupported conversion if CI confirms it. The other cases
route through existing operations. No backend output has been inspected
and no local test or calculation batch has been run.
