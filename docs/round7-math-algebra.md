# Seventh independent algebra/calculus audit

These questions and references were drafted from first principles before
consulting old fixtures or application output. Complex logarithms and fractional
powers below use the principal branch. Definite integrals are ordinary real
integrals, including improper limits, rather than Cauchy principal values.

1. **Principal logarithm subtraction across the cut:**
   `ln(-1-I)-ln(1+I) = -pi*I`. The moduli cancel; the principal arguments
   are-3π/4 andπ/4. This differs from the principal log of their quotient,
   ln(-1)=πi, exposing why a blanket log-quotient rewrite is invalid.
2. **Square-root branch after squaring:** `sqrt((-3+4*I)^2) = 3-4*I`.
   Squaring gives -7-24i; the principal square root has positive real part.
3. **Square root of a non-real number:** `sqrt(1+I) =
   sqrt((sqrt(2)+1)/2)+I*sqrt((sqrt(2)-1)/2)`. Squaring gives real part1,
   imaginary part1, with both root components positive.
4. **Conjugation of a quotient:** `conjugate((2+3*I)/(1-2*I)) =
   -4/5-7*I/5`. Multiplying numerator/denominator by1+2i gives(-4+7i)/5;
   conjugation reverses the imaginary sign.
5. **Logarithm is not a global inverse of exponentiation:**
   `ln(exp(4*pi*I)) = 0`, because the inner exponential is1.
6. **Principal cube root of a negative real:** `(-8)^(1/3) = 1+sqrt(3)*I`.
   Its modulus is2 and argumentπ/3; this differs from the real cube root -2.
7. **Repeated zero eigenvalues:** the rank-one matrix
   `[[1,2,3],[2,4,6],[3,6,9]]` has eigenvalue multiset`{14,0,0}`.
   It is vvᵀ with v=(1,2,3), so v is an eigenvector with vᵀv=14 and its
   two-dimensional orthogonal complement has eigenvalue0.
8. **Singular determinant without a zero row:**
   `det([[1,0,1],[0,1,1],[1,1,2]]) = 0`. Row3=row1+row2.
9. **Singular inverse:** `inv([[1,2],[2,4]])` must return an error.
   Its determinant is4-4=0; no inverse exists.
10. **Inconsistent augmented system in RREF:**
    `rref([[1,1,1],[2,2,3]]) = [[1,1,0],[0,0,1]]`.
    Subtract twice row1 from row2, then remove row1's last-column entry.
    The final row encodes0=1, an inconsistency rather than a valid solution.
11. **Excluded repeated root and a surviving root:**
    `solve((x-1)^2*(x+2)/(x-1),x)` has the sole root -2.
    The original expression excludes x1; cancellation leaves(x-1)(x+2),
    but the formal root1 remains excluded.
12. **Repeated complex roots:** `solve((x^2+1)^2,x)` has the distinct roots
    `{-I,I}`. Each has multiplicity2; equation solving returns a solution set.
13. **Nilpotent matrix cube:**
    `[[0,1,0],[0,0,1],[0,0,0]]^3 = [[0,0,0],[0,0,0],[0,0,0]]`.
    A nonzero second superdiagonal remains after squaring; a third shift
    has no surviving entry, so the cube is zero.
14. **Inverse with a second superdiagonal:**
    `inv([[1,1,0],[0,1,1],[0,0,1]]) = [[1,-1,1],[0,1,-1],[0,0,1]]`.
    Writing the matrix as I+N, N³=0, its inverse is I-N+N².
15. **Squared logarithm at a singular endpoint:**
    `integrate(ln(x)^2,x,0,1) = 2`. A primitive is
    x*((ln(x))²-2ln(x)+2), whose limit at0 from the right is0, and its
    value at1 is2. This is a convergent improper integral despite ln(x)²
    being unbounded near the endpoint.
16. **Real-domain crossing:** `integrate(ln(1-x),x,0,2)` is an error.
    For1<x≤2,1-x is negative and the real logarithm is undefined.
17. **Quartic improper poles:** `integrate(1/(x^4-2),x,-2,2)` diverges.
    The denominator has simple real zeros±2^(1/4) inside the interval; the
    derivative4x³ is nonzero at both, giving nonintegrable simple poles.
18. **Absolute value away from its cusp:**
    `limit((abs(x+1)-1)/x,x,0) = 1`. In a neighborhood of0,x+1>0 and the
    quotient equals1 for every nonzero x.
19. **Second-order square-root remainder:**
    `limit((sqrt(1+x)-1-x/2)/x^2,x,0) = -1/8`.
    The second derivative of sqrt(1+x) at0 is-1/4, and the Taylor coefficient
    is one-half of that derivative.
20. **Infinity and rationalization:**
    `limit(sqrt(x^2+3*x)-x,x,oo) = 3/2`.
    Rationalization gives3x/(sqrt(x²+3x)+x), whose denominator/x tends to2.
21. **Smooth nonlinear absolute value:**
    derivative of `abs(x^2-1)` at x0 is0. Locally the expression is1-x².
22. **Flattened nonlinear absolute cusp:** derivative of `abs(x^3)` at x0
    is0. The difference quotient is|h³|/h, whose magnitude is h².
23. **Exact local polynomial Taylor branch:**
    `series(abs(x^2-1),x,0,5) = 1-x^2`. This is the exact function locally
    for |x|<1, so all higher Taylor coefficients vanish.
24. **Shifted rational Taylor truncation:**
    `series(1/(1+x),x,1,4) = (-x^3+5*x^2-11*x+15)/16`.
    Let h=x-1:1/(2+h)=1/2-h/4+h²/8-h³/16+O(h⁴); expansion gives the
    displayed polynomial. The requested order retains degrees0 through3.
25. **Reactive nonlinear Taylor coefficient under shadowing:** document
    `p=1; x=9; taylor(abs(x^2-p),x,0,5)`, then edit p to4, yields
    `[4,9,4-x^2]`. The formal x stays symbolic despite global x9, while p
    remains reactive; the local branch around0 is p-x² for positive p.

## Freshness review and executable adaptation

After freezing the first draft, a read-only search across earlier fixtures
identified simple negative-real logarithms, ordinary row-swap RREF, triangular
repeated spectra, and the unshifted arctangent integral. To avoid merely changing
their constants, questions1,10,13,15 were independently replaced with the
cross-cut log subtraction, inconsistent augmented RREF, nilpotent cube and
squared-log improper integral derived above. None of these replacements was
informed by app output.

The remaining questions are distinct expressions and operations from prior
fixtures. The repeated-root source-hole question adds a repeated numerator
factor and a surviving root; the nonlinear abs derivative/Taylor/document trio
deliberately probes one domain issue through three real application routes.
The rank-one matrix previously appeared as an RREF question, but its repeated
eigenvalue spectrum here is a separate operation and independent reference.

All25 questions use existing engine operations, the shared differentiateAt
module, or the real document evaluator with shared Taylor routing. No new
adapter is required. Singular inversion expects the bridge's documented
`Matrix inversion failed` diagnostic rather than accepting any parse error.
Quartic poles and nonlinear absolute values are challenges to existing
integration/calculus paths; unsupported runtime results must be reported as
gaps, without replacing their mathematical references.
