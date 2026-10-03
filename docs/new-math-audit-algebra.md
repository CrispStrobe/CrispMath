# Fresh algebra and calculus challenge draft

These 40 problems were drafted before inspecting either existing task corpus.
Expected values come from the mathematical identities and derivations below,
not from CrispMath output. Execution belongs on GitHub-hosted CI.

1. Compute `(2^127-1)-(2^127-2)`: 1 (adjacent large integers).
2. Compute `100!/(98!*99*100)`: 1 (factorial cancellation).
3. Compute `(1/3+1/7)/(1/3-1/7)`: 5/2.
4. Evaluate `sqrt(50)-5*sqrt(2)`: 0.
5. Evaluate `sqrt(81/16)`: 9/4 (principal root).
6. Evaluate `ln(exp(-7/3))`: -7/3.
7. Evaluate `log(64,2)`: 6 (base-two logarithm).
8. Evaluate `sin(pi/12)^2+cos(pi/12)^2`: 1.
9. Evaluate `tan(pi/8)`: sqrt(2)-1.
10. Evaluate `asin(1/2)`: pi/6 (principal branch).
11. Evaluate `cosh(ln(3))`: 5/3.
12. Evaluate `sinh(ln(3))`: 4/3.
13. Evaluate `atan(1)+atan(2)+atan(3)`: pi (tangent addition and branches).
14. Evaluate `(1+i)^8`: 16.
15. Evaluate `(3+4*i)/(3-4*i)`: -7/25+24*i/25.
16. Evaluate `i^2027`: -i (power periodicity).
17. Evaluate `sqrt(-16)`: 4*i (principal square root).
18. Evaluate `exp(i*pi)+1`: 0 (Euler identity).
19. Evaluate `abs(5-12*i)`: 13.
20. Evaluate `ln(-1)`: pi*i (principal complex logarithm).
21. Differentiate `x^x`, evaluate at x=1: 1.
22. Differentiate `ln(1+x^2)`, evaluate at x=2: 4/5.
23. Differentiate `sin(x^2)`, evaluate at x=1: 2*cos(1).
24. Differentiate `exp(-x^2)`, evaluate at x=2: -4*exp(-4).
25. Differentiate `atan(x)`, evaluate at x=3: 1/10.
26. Differentiate `x/(1+x^2)`, evaluate at x=2: -3/25.
27. Differentiate `sqrt(1+x^2)`, evaluate at x=3: 3/sqrt(10).
28. Integrate `x^3-2*x+1` from -2 to 3: 65/4.
29. Integrate `1/(1+x^2)` from 0 to 1: pi/4.
30. Integrate `sin(x)^2` from 0 to pi: pi/2.
31. Integrate `x*exp(x)` from 0 to 1: 1.
32. Integrate `ln(x)` from 1 to e: 1.
33. Compute limit `sin(3*x)/x` as x approaches 0: 3.
34. Compute limit `(1-cos(x))/x^2` as x approaches 0: 1/2.
35. Compute limit `(sqrt(1+x)-1)/x` as x approaches 0: 1/2.
36. Solve `x^2-5*x+6=0`: x=2 or 3.
37. Solve `(x-1)/(x+2)=2`: x=-5, with x=-2 excluded.
38. Compute determinant of [[1,2,3],[0,4,5],[1,0,6]]: 22.
39. Compute eigenvalues of [[2,1],[1,2]]: 1 and 3.
40. Solve system `2*x+y=5`, `x-y=1`: x=2, y=1.

## Independent derivations and integration notes

Problems 1–20 use exact arithmetic, elementary identities and principal complex
branches. Problems 21–27 follow the product/chain/quotient rules. For 28 the
antiderivative is x^4/4-x^2+x; F(3)-F(-2)=65/4. For 29 use atan(x), for 30
use (1-cos(2*x))/2, for 31 use (x-1)*exp(x), and for 32 use x*ln(x)-x.
Limits 33–35 follow the first two nonzero Taylor coefficients. The quadratic in
36 factors as (x-2)*(x-3). Multiplying 37 by x+2 gives x-1=2*x+4. In 38,
cofactor expansion gives 24-2*(-5)+3*(-4)=22. The characteristic polynomial
in 39 is (2-lambda)^2-1; adding the equations in 40 gives 3*x=6.

The draft is intentionally preserved even if an app syntax/path does not exist.
Any unsupported operation must be recorded as a coverage gap rather than
silently replaced with a different mathematical task.

## Fixture integration

`test/fixtures/new_math_algebra_tasks.json` contains all 40 tasks with unique
`new-algebra-` IDs. Only conventional CAS spellings are translated (`i` to `I`,
the integration bound `e` to `E`). No question or expected answer was changed
after inspecting the adapters.

Seven derivative-at-point questions need a diagnostic `differentiateAt` module
adapter that invokes the existing engine differentiation, substitution and
evaluation methods. Existing generic engine dispatch has no substitution
operation, so that missing adapter is a coverage issue rather than an app
claim. Its task fields are `expression`, `variable`, and string `point`.

Complex-valued expectations deserve an independent complex-aware comparator:
the current task comparator evaluates only real scalar expressions. Equivalent
forms such as `24/25*I - 7/25` and `-7/25+24*I/25` may otherwise produce an
audit failure even when the app answer is correct. Preserve signed/principal
branch checks rather than discarding the imaginary component.

The two-argument logarithm, variable-power derivative, logarithmic/exponential
integration and inverse-tangent branch sum intentionally probe parser and CAS
coverage. They remain real findings if the engine cannot handle them.
