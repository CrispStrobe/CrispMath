# Third independent algebra and calculus draft

These 25 references were written from first principles before consulting old
fixtures or current routes. GitHub CI must execute them; this VPS has almost
no free volume space.

1. Determinant [[1,1,1],[1,2,3],[1,3,6]] = 1.
2. Its inverse = [[3,-3,1],[-3,5,-2],[1,-2,1]].
3. RREF [[0,1,2],[0,2,4],[1,0,3]] = [[1,0,3],[0,1,2],[0,0,0]].
4. Eigenvalues [[4,1,0],[0,4,2],[0,0,-1]] = 4, 4, -1; the repeated
   eigenvalue has algebraic multiplicity two.
5. Solve x+y+z=6, 2*x-y+z=3, x+2*y-z=2: x=1, y=2, z=3.
6. Solve x/(x^2-4)=0: x=0.
7. Solve (x^2-4)/(x^2-x-2)=0: x=-2; x=2 and x=-1 are excluded.
8. Integrate 1/(x^2-2) from 0 to 2: reject a divergent interior pole
   at sqrt(2), even though the pole is not on a rational sampling grid.
9. Integrate (x^2-4)/(x-2) from 1 to 3: 8, as a convergent improper
   integral across a removable hole.
10. Integrate 1/(x+2)^2 from -1 to 1: 2/3.
11. Integrate x*ln(x) from 1 to 2: 2*ln(2)-3/4.
12. Integrate sin(2*x) from pi/4 to 3*pi/4: 0.
13. Integrate 1/sqrt(1-x^2) from 0 to 1/2: pi/6.
14. Limit (sqrt(4+x)-2)/x at 0: 1/4.
15. Limit (sin(x)-x)/x^3 at 0: -1/6.
16. Limit (exp(x)-1-x)/x^2 at 0: 1/2.
17. Differentiate x^2*ln(x) at x=1: 1.
18. Differentiate asin(x) at x=1/2: 2/sqrt(3).
19. Differentiate ln(cosh(x)) at x=0: 0.
20. Differentiate exp(sin(x)) at x=pi: -1.
21. Evaluate (sqrt(2)+i*sqrt(2))^4: -16.
22. Evaluate (1+2*i)/(2-i): i.
23. Worksheet: x=7; a=3; integrate(a*x^2,x,0,2) gives 8, with no
   free-variable tag. The document's x must not replace the dummy variable.
24. Worksheet: x=4; a=2; integrate(a*x,x,0,x) gives 16. Editing x to
   3 must recalculate the integral to 9, with no free-variable tag.
25. Worksheet: f(t)=t^2; x=9; integrate(f(x),x,0,2) gives 8/3,
   with no free-variable tag. Function expansion must preserve dummy scope.

## Independent derivations

1 follows by subtracting the first row from the other rows, leaving a 2x2
determinant 5-4. The inverse in 2 is the cofactor transpose divided by 1.
For 3, swap the third row into the first position and subtract twice the
second row from the original middle row. The triangular diagonal gives 4's
eigenvalues and multiplicities. Substitution directly verifies (1,2,3) in 5.

6's numerator vanishes only at zero, where its denominator is -4. In 7,
cancel x-2 while retaining exclusions; the remaining numerator x+2 vanishes
at -2. In 8 the denominator has simple roots +/-sqrt(2), with the positive
root inside the interval. In 9 cancellation gives x+2 except at the hole;
its integral is [x^2/2+2*x]_1^3=8. Item 10 uses -1/(x+2).

11 uses x^2*ln(x)/2-x^2/4; endpoint subtraction gives 2*ln(2)-3/4.
12 uses -cos(2*x)/2, with both endpoint cosines zero. For 13 use asin(x).
14 rationalizes to 1/(sqrt(4+x)+2). Taylor expansions give the coefficients
-1/6 and 1/2 in 15 and 16. Derivatives in 17–20 are respectively
2*x*ln(x)+x, 1/sqrt(1-x^2), tanh(x), and exp(sin(x))*cos(x).

For 21, squaring gives 4*i and squaring again gives -16. For 22, multiplying
by 2+i gives 5*i/5. The remaining references are exact polynomial integrals:
23 is 3*(2^3)/3=8; 24 is 2*x^2/2=x^2 at the document-valued upper bound;
25 is [x^3/3]_0^2=8/3 after expanding f's local argument.

Neither a principal value nor a numerical coincidence may replace the
improper-integral definitions in 8 and 9. Repeated eigenvalues must not be
silently deduplicated in item 4.

## CLI integration

The fixture contains exactly 25 unique `round3-algebra-` IDs. Existing engine
routes cover matrices, equations, definite integrals and limits; four derivative
tasks use `differentiateAt`; three use real worksheet documents with free-variable
assertions. Item 24 uses the existing edit hook and asserts the final value 9;
the initial value 16 remains independently documented but the generic edit
runner does not separately assert its pre-edit value.

Item 8 specifically requires the divergent-pole explanation. Item 9 expects
the convergent value across a removable hole. The multiplicity in item 4 is
preserved as three entries in the expected eigenvalue multiset. Unsupported
behavior remains a finding; no case has been rewritten to match app output.
