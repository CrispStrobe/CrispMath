# Independent second-round algebra and calculus draft

These 40 problems were drafted before reading the task fixtures for this
round. Expectations follow the manual derivations below; no app output is a
reference. All actual execution belongs on GitHub CI because the shared VPS is
under load and has limited free disk.

1. `(2^200+3)-(2^200+1)` = 2.
2. `(7/15-2/9)/(11/45)` = 1.
3. `(-2)^(-5)` = -1/32.
4. `abs(-11/13)+abs(2/13)` = 1.
5. `sqrt(3+2*sqrt(2))` = 1+sqrt(2), principal root.
6. `sqrt(7-4*sqrt(3))` = 2-sqrt(3), principal root.
7. `ln(exp(ln(2)))` = ln(2).
8. `acos(-1/2)` = 2*pi/3.
9. `asin(sin(5*pi/6))` = pi/6, principal branch.
10. `atan(tan(3*pi/4))` = -pi/4, principal branch.
11. `(2+3*i)*(2-3*i)` = 13.
12. `(1-i)^6` = 8*i.
13. `(2-i)^(-1)` = 2/5+i/5.
14. `sqrt(-9/4)` = 3*i/2, principal root.
15. `abs(-8+15*i)` = 17.
16. `(1+i)/(1-i)` = i.
17. Solve `x^2+4*x+13=0`: -2-3*i and -2+3*i.
18. Differentiate `x*ln(x)` at x=e: 2.
19. Differentiate `sqrt(x)` at x=4: 1/4.
20. Differentiate `ln(sin(x))` at x=pi/4: 1.
21. Differentiate `x/sqrt(1+x^2)` at x=0: 1.
22. Differentiate `cos(x)^2` at x=pi/4: -1.
23. Differentiate `sinh(x)` at x=0: 1.
24. Integrate `cos(x)^2` from -pi/2 to pi/2: pi/2.
25. Integrate `x^2/(1+x^3)` from 0 to 1: ln(2)/3.
26. Integrate `x/sqrt(1+x^2)` from 0 to sqrt(3): 1.
27. Integrate `exp(2*x)` from 0 to ln(2): 3/2.
28. Integrate `ln(x)` from 1 to 2: 2*ln(2)-1.
29. Integrate `x^5` from -3 to 3: 0.
30. Integrate `1/(x-1)` from 0 to 2: undefined as an ordinary improper
    integral; a principal value of zero must not be reported as the integral.
31. Limit `(exp(2*x)-1)/x` at x=0: 2.
32. Limit `(ln(1+x)-x)/x^2` at x=0: -1/2.
33. Limit `(tan(x)-x)/x^3` at x=0: 1/3.
34. Limit `1/x` at x=0: no two-sided limit.
35. Solve `(x^2-1)/(x+1)=0`: x=1; x=-1 is excluded.
36. Solve `1/(x-2)=1/(x+2)`: no solutions.
37. Determinant [[0,2,1],[3,0,4],[5,6,0]]: 58.
38. Inverse [[1,2],[3,5]]: [[-5,2],[3,-1]].
39. RREF [[1,2,3],[2,4,6]]: [[1,2,3],[0,0,0]].
40. Eigenvalues [[0,-2],[2,0]]: -2*i and 2*i.

## Reference derivations

1 uses adjacent integer cancellation. For 2, the numerator is 11/45. For 3,
the reciprocal of (-2)^5 is -1/32. For 4, the magnitudes add to 13/13. The
radicands in 5 and 6 are respectively (1+sqrt(2))^2 and (2-sqrt(3))^2, with
both proposed principal roots positive. Item 7 composes inverse real exp/ln.
Items 8–10 explicitly use the standard principal intervals of inverse trig.

11 is the sum of squares 4+9. In 12, (1-i)^2=-2*i, so its cube is 8*i. In 13,
multiply numerator and denominator by 2+i. Item 14 takes the principal root,
15 is sqrt(64+225), and 16 rationalizes the denominator. Completing the square
in 17 gives (x+2)^2=-9.

Derivatives in 18–23 are respectively ln(x)+1, 1/(2*sqrt(x)), cot(x),
(1+x^2)^(-3/2), -sin(2*x), and cosh(x). The integration references are:
24: x/2+sin(2*x)/4; 25: ln(1+x^3)/3; 26: sqrt(1+x^2);
27: exp(2*x)/2; 28: x*ln(x)-x; 29: odd symmetry. In 30 the left and right
improper integrals diverge separately; subtracting endpoint antiderivatives
would conceal the interior pole.

Limits 31–33 follow the Taylor coefficients exp(2*x)=1+2*x+...,
ln(1+x)=x-x^2/2+..., and tan(x)=x+x^3/3+.... For 34 the one-sided values have
opposite infinite signs. Cancelling the numerator in 35 leaves x-1 but must
retain x!=-1. Cross multiplication in 36 gives x+2=x-2, a contradiction.

For 37, expansion gives -2*(0-20)+(18-0)=58. The determinant in 38 is -1, so
the adjugate divided by -1 gives the stated inverse. In 39 the second row is
twice the first. For 40 the characteristic polynomial is lambda^2+4.

The singular integral and two-sided pole are deliberate boundary tests.
Unsupported grammar or inadequate rejection must be recorded honestly; the
draft must not be replaced with a nonsingular problem after seeing results.

## CLI integration and boundaries

`test/fixtures/round2_algebra_tasks.json` contains exactly 40 uniquely numbered
`round2-algebra-` tasks. Existing engine routes cover evaluation, solving,
integration and limits; the existing `differentiateAt` module covers six
derivatives at explicit points. Conventional CAS spellings use `I` and `E`.
No new adapters are required.

Items 30 and 34 expect an explicit error rather than any finite number. Their
`errorContains` fields require respectively a divergent-pole explanation and
differing one-sided limits; incidental parse errors cannot pass these cases.
The runner still separately marks unavailable operations unsupported. Item 30
specifically concerns an ordinary definite integral, not a requested Cauchy
principal value.

These questions keep earlier intentional bounds honest: matrix operations
use small dimensions and rational equations use low degrees, while integrals
and third-order limits intentionally probe deeper than trivial polynomials.
There is no imperative worksheet reassignment in this algebra batch; reactive
same-name self-reference remains a separately documented product policy.
