# Round 6 independent algebra references

Questions and references are frozen before consulting earlier fixtures, runtime
outputs or operation routing. All app execution belongs on hosted CI.

1. det([[a,1],[1,a]])=a^2-1, by the two-by-two determinant formula.
2. inv([[1,t],[0,1]])=[[1,-t],[0,1]], verified by multiplication for every t.
3. rref([[1,0],[0,1],[1,1]])=[[1,0],[0,1],[0,0]]: subtract the first two rows from the third.
4. eigenvalues([[2,1],[0,2]])={2,2}: defective Jordan block with algebraic multiplicity two.
5. Roots of x^2+2x+5 are {-1-2I,-1+2I}, by completing (x+1)^2=-4.
6. Factor x^4+4 as (x^2-2x+2)*(x^2+2x+2), the difference (x^2+2)^2-(2x)^2.
7. Expand (x+y)^3 to x^3+3*x^2*y+3*x*y^2+y^3 by the binomial theorem.
8. Simplify (x^2-y^2)/(x-y) to x+y on the original domain x!=y, by difference of squares.
9. Solve (x-2)^2/(x-2)=0: no solutions, because its sole candidate x=2 is excluded.
10. Integral abs(x) from -1 to 2 is 5/2, splitting the cusp at 0: 1/2+2.
11. Improper integral 1/sqrt(x) from 0 to 1 is 2, by the right endpoint limit of 2*sqrt(x).
12. Improper integral ln(x) from 0 to 1 is -1, since x*ln(x)-x tends to 0 at the left endpoint.
13. Integral 1/x from -1 to 0 diverges at the endpoint; a finite principal value is inapplicable.
14. Two-sided limit exp(-1/x^2) at 0 is 0: both sides have exponent tending to negative infinity.
15. Two-sided limit x*sin(1/x) at 0 is 0 by squeezing its magnitude below abs(x).
16. Two-sided limit abs(x)/x at 0 does not exist: left -1 and right 1.
17. Real derivative of abs(x) at 0 does not exist: difference quotients are -1 and 1.
18. Derivative x^3/(x^2+1) at 1 is 1, since (3*x^2+x^4)/(x^2+1)^2 gives 4/4.
19. Partial derivative x^2+sin(y) with respect to x is 2*x, retaining independent y as a constant.
20. Integral x/(x^2+1) from -1 to 1 is 0 by oddness and a nonsingular denominator.
21. abs(3+4I)=5 by the modulus sqrt(3^2+4^2).
22. Principal sqrt(-9)*sqrt(-4)=-6, since (3I)*(2I)=-6; combining radicands would be wrong.
23. sqrt(1/16)^(-3)=64 exactly: principal root 1/4, then inverse cube.
24. Worksheet a=2,f(a)=a+1,integrate(f(a),a,0,1) gives 3/2. Function and integral
    declarations both shadow the same global name; the function template remains a+1.
25. Worksheet integrate(a*x,x,0,1),a=4,x=9 gives [2,4,9]: the coefficient is a
    forward dependency, while global x must neither replace the dummy nor create an edge.

Freshness review and CLI adaptation follow this frozen draft. Undefined limits
and derivatives are mathematical rejections, not permission to weaken references.

After freezing, no exact duplicates were found in earlier algebra fixtures.
Adapter review found that `differentiateAt` supports numerical/symbolic expected
values but has no portable error assertion. Question 17 is therefore recorded as
an unexecuted derivative-domain follow-up, and replaced by a distinct supported
problem: derivative of x*abs(x) at 0 is 0, because its difference quotient is
abs(h), tending to 0 from either side. This checks differentiability of the product
despite its absolute-value factor's cusp; it does not claim abs(x) differentiable.
