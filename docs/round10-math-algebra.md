# Round ten: independently derived algebra and calculus references

These 25 questions were drafted from mathematical identities, without running
the app or reading app outputs. A schema read of older fixtures preceded this
draft; their titles were visible during that read. None of the answers below
comes from those fixtures. References use principal complex square roots and
logarithms, and ordinary real improper integrals, never Cauchy principal values.
The list is frozen before adapting it to the portable task schema.

1. Evaluate `ln((1+I)/(1-I))`. The quotient is I; principal Arg(I)=π/2,
   modulus one, hence **πI/2**.
2. Evaluate `sqrt((3-4*I)^2)`. The radicand is −7−24I. Its principal
   square root has positive real part; (3−4I)² is that radicand, hence **3−4I**.
3. Evaluate `exp(I*pi/3)+exp(-I*pi/3)`. Euler's formula gives twice
   cos(π/3), hence **1**.
4. Evaluate `conjugate((2+I)/(1-3*I))`. Multiplying by 1+3I yields
   (−1+7I)/10 before conjugation, so the answer is **−1/10−7I/10**.
5. Solve `(I-1)*x^2+(2-2*I)*x+(I-1)=0`. Factor the nonzero constant
   I−1 to obtain (x−1)², so the distinct solution set is **{1}**.
6. Solve `(x^2+x-6)/(x^2-4)=0` on its original domain. Numerator roots
   are 2 and −3; denominator forbids ±2. Thus **{−3}**, excluding 2.
7. Solve `(x^2+1)^2/(x^2+1)=0` over complex numbers. Candidate roots ±I
   both make the original denominator zero. Thus **no solutions**.
8. Factor `x^4+2*x^2+1`. The perfect square is **(x²+1)²**. An unchanged
   expanded polynomial is not a successful factorization.
9. Expand `(x+y+z)^2-(x+y-z)^2`. With u=x+y, (u+z)²−(u−z)²=4uz,
   giving **4xz+4yz**. The output must no longer contain the input squares.
10. Simplify `(a^2+2*a*b+b^2)/(a+b)`. The numerator is (a+b)²;
    the simplified expression is **a+b**, on **a+b≠0**. The denominator
    restriction belongs to source-domain metadata, not the simplified formula.
11. Compute det([[0,1,0],[0,0,1],[1,0,0]]). The permutation is a
    three-cycle with positive sign, so the determinant is **1**.
12. Invert [[2,1,0],[0,2,1],[0,0,2]]. Write it as 2Id+N, N³=0.
    Its inverse is Id/2−N/4+N²/8, namely
    **[[1/2,−1/4,1/8],[0,1/2,−1/4],[0,0,1/2]]**.
13. RREF [[0,1,2],[0,2,4],[0,1,3]]. The first column is zero.
    Subtract twice row one from row two, and row one from row three;
    swap the resulting zero row to the end, then subtract twice the second
    pivot row from row one. The result is
    **[[0,1,0],[0,0,1],[0,0,0]]**, with rank two.
14. Solve x+y+z=6, x−y=0, 2x+z=6, x+2y+3z=12. Since y=x,
    the first and third equations agree. The fourth becomes x+z=4;
    combining it with 2x+z=6 gives **x=y=z=2**. All four original
    equations hold, so this is a consistent overdetermined system.
15. Integrate `x/(x^2+4)` from 0 to 2. Set u=x²+4, du=2x dx;
    the result is (ln8−ln4)/2=**ln2/2**.
16. Integrate `ln(3-2*x)` from 0 to 3/2. Set t=3−2x. The result
    is (1/2)∫₀³ ln t dt = (1/2)[t ln t−t]₀³
    = **3(ln3−1)/2**, since t ln t tends to zero at zero.
17. Integrate `ln(x)^2/x` from 0 to 1. The primitive is (ln x)³/3,
    which tends to −∞ at zero. The ordinary integral **diverges to +∞**;
    a finite result must be rejected.
18. Integrate `1/(x^2-7)` from −1 to 1. The poles ±√7 lie outside
    the interval. The primitive (1/(2√7)) ln|(x−√7)/(x+√7)|
    gives **ln((√7−1)/(√7+1))/√7**. Its log argument is positive
    and less than one, consistent with the integrand being negative.
19. Differentiate `abs((x^2-1)^2)` at x=1. The square is nonnegative,
    so this is (x²−1)² globally; derivative 4x(x²−1) gives **0**.
20. Differentiate `x*abs(x^2-4)` at x=0. Near zero the expression is
    x(4−x²), whose derivative is 4−3x². The answer is **4**.
21. Taylor-expand `abs(x^2-x)` in x around 1/2 with order 3 (degrees
    less than 3). In a neighborhood of 1/2 the inner quadratic is negative,
    so the complete local polynomial is **x−x²**.
22. Taylor-expand `abs((x-2)^5)` around 2 with order 5. Its first four
    derivatives at the center exist and vanish; the order-five Taylor
    polynomial is **0**. This does not assert the fifth derivative exists.
23. Take the limit `sqrt(4*x^2+x)-2*x` as x→+∞. Rationalize to
    x/(√(4x²+x)+2x)=1/(√(4+1/x)+2), hence **1/4**.
24. Take `(sin(3*x)-3*sin(x))/x^3` as x→0. Cubic Taylor terms leave
    (−27+3)x³/6, hence **−4**. Alternatively sin(3x)−3sin x=−4sin³x.
25. Take the two-sided real limit `x/sqrt(x^2)` as x→0. Since
    √(x²)=|x|, its right limit is 1 and its left limit is −1. The
    **two-sided limit does not exist**; both directions must be considered.

Exact rational, polynomial and complex references use the existing comparator's
strict symbolic/numeric semantics. Transcendental numeric comparisons use its
standard tolerance; transformation tasks additionally require transformed
output notation. Domain errors require a meaningful error, with no change to
the underlying mathematical question if an adapter cannot express it.

Freshness review before app observation:

- The initial rank-one RREF question was replaced with a zero-first-column,
  rank-two matrix, because prior rounds already exercised rank-one square RREF.
- The initial inconsistent two-equation system was replaced with a consistent,
  overdetermined three-variable system to distinguish it from an earlier
  augmented inconsistent RREF question.
- Exact source scans found prior `ln(1-x)` and `1/(x^2-2)` questions. Even though
  the old intervals tested different domain behavior, these were replaced with
  the newly derived questions 16 and 18 above before any app output was seen. A second scan
  also found `1/(x^2-3)` in round five; its replacement uses 7 and the
  corresponding independently derived √7 primitive.
- After these replacements, no whitespace-normalized first source or module
  expression equals an earlier fixture source. Repeated mathematical families
  (absolute calculus, complex branches) intentionally test different structures.

Adapter notes: all 25 use existing engine or differentiateAt module paths.
Matrix operations use Matrix constructors; linsolve uses semicolon-separated
original equations. Cases 17 and 25 require meaningful divergence/directional
errors. Cases 8–10 and 21–22 require transformed output notation, so equivalence
of an unchanged input cannot count as completing the requested operation.
The simplification source condition a+b≠0 is independently documented; the
current engine-task schema records source-domain evidence but has no assertion
field for its content. Root should review that metadata in actual hosted/UI
checks rather than treating the expression comparison as a domain assertion.
