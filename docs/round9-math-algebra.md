# Round nine: independent algebra references

The first 25 questions below were drafted from mathematical identities before
reading prior corpora or app output. Complex logarithms and roots mean their
principal values; definite calculus uses real domains and ordinary improper
integrals, never Cauchy principal values. Exact answers are symbolic references;
CLI numeric comparisons use its existing strict relative tolerance.

| ID | Question | Independent reference and derivation |
| --- | --- | --- |
| 01 | Evaluate `ln(-2)+ln(-3)-ln(6)` | `2*pi*I`: each negative real principal log contributes `pi*I`, while the real logarithms cancel. |
| 02 | Evaluate `(3+4*I)^(-1)` | `3/25-4*I/25`: multiply the reciprocal by the conjugate, whose norm is 25. |
| 03 | Evaluate `conjugate(1/(1+2*I)^2)` | `-3/25+4*I/25`: square is `-3+4I`, reciprocal `(-3-4I)/25`, then conjugate. |
| 04 | Evaluate `sqrt(-I)*sqrt(I)` | `1`: principal arguments `-pi/4` and `pi/4` cancel, and both moduli are one. |
| 05 | Evaluate `(-1)^(2/3)` | `-1/2+sqrt(3)*I/2`: use principal `exp(2*pi*I/3)`, not a real cube-root convention. |
| 06 | Solve `(1+I)*x^2+(-2+I)*x+(1-2*I)=0` | `{1,-1/2-3*I/2}`: substitution proves root 1; the product `c/a=(-1-3I)/2` gives the other root. The sum `(1-3I)/2` agrees with `-b/a`. |
| 07 | Solve `(x^2-1)^3/(x^2+2*x+1)=0` | `{1}`: the original denominator excludes -1; all multiplicities of that root must disappear. |
| 08 | Solve `x^2/(x^2+1)=1/2` | `{-1,1}`: cross multiplication gives `x^2=1`, and neither source pole `±I` is a solution. |
| 09 | Solve `(x-1)/(x-1)=0` | No solutions: every allowed input makes the quotient one; x=1 is excluded. |
| 10 | Integrate `ln(2*x)^4` from zero to `1/2` | `12`: substitution u=2x gives half the fourth log moment `4!=24`. |
| 11 | Integrate `1/sqrt(1-x)` from zero to one | `2`: primitive `-2*sqrt(1-x)` and convergent left limit at one. |
| 12 | Integrate `(x^3-x)/(x^2-1)` from -2 to two | `0`: cancelling both removable holes gives x, an odd continuous extension. |
| 13 | Integrate `1/(x^2-2)^2` from zero to two | Divergent pole: sqrt(2) lies inside; near it the positive integrand scales as a nonzero constant times `1/(x-sqrt(2))^2`. |
| 14 | Differentiate `abs(x^2-4*x+4)` at two | `0`: the inner polynomial is `(x-2)^2`, so absolute value is unnecessary. |
| 15 | Differentiate `(x+1)^2*abs(x+1)` at -1 | `0`: the local function is `h^2*abs(h)`, with difference quotient `h*abs(h)` tending to zero. |
| 16 | Differentiate `abs(x^2-4)` at three | `6`: inner polynomial is positive near three, derivative 2x. |
| 17 | Taylor-expand `abs((x+1)^3)` at -1 with three terms | `0`: the first two derivatives exist and vanish; no third derivative is requested. |
| 18 | Taylor-expand `abs((x+1)^3)` at -1 with four terms | Error: the third derivative does not exist, since local branches are ±h^3. |
| 19 | Taylor-expand `exp(x)` at `ln(2)` with three terms | `2+2*(x-ln(2))+(x-ln(2))^2`: coefficients use exp(center)=2 and the quadratic coefficient 2/2. |
| 20 | Limit `sqrt(4*x^2-12*x+5)+2*x` at negative infinity | `3`: rationalize against -2x; coefficient `-12/(2*(-2))=3`. |
| 21 | Limit `(x-3)^2*sin(1/(x-3))` at three | `0`: bounded sine is squeezed by a vanishing quadratic amplitude. |
| 22 | Limit `ln(1+x^2)/x^2` at zero | `1`: with u=x^2, `ln(1+u)/u` tends to one along u≥0. |
| 23 | Compute `rref(Matrix([[0,1,2,3],[0,2,4,6],[1,0,1,2]]))` | `[[1,0,1,2],[0,1,2,3],[0,0,0,0]]`: the second row is twice the first; pivoting the third row introduces the leading-column pivot before the original first row. |
| 24 | Compute `det(Matrix([[0,2,-3],[-2,0,4],[3,-4,0]]))` | `0`: A is skew-symmetric of odd order, so `det(A)=det(A^T)=det(-A)=-det(A)` over the reals. |
| 25 | Compute `inv(Matrix([[1,2],[3,7]]))` | `[[7,-2],[-3,1]]`: determinant is one and the adjugate has those entries. |

## Pre-freeze derivation correction and freshness review

Before reading app outputs, Vieta independently corrected the sign of the real
part of question 06's second root: it is `-1/2`, not `1/2`. Both sum and product
now verify the reference. The initial question 24 was a three-cycle determinant
closely resembling round eight; it was replaced with an odd skew-symmetric
determinant and a different structural proof.

After drafting, a read-only prior-corpus comparison found exact duplicate
operation/argument tuples in 22 and 23. They were replaced before execution:

- 22: the second-order logarithm remainder became a logarithm of a quadratic
  argument, derived via the one-sided intermediate variable u=x².
- 23: the earlier square RREF became a rectangular rank-two reduction with
  a row interchange and an initially absent leading-column pivot.

The final 25 problems have no exact prior-corpus duplicates. Taylor cases17/19
require actual polynomial output rather than repeating their original abs/exp
input; formal Derivative/Subs/series calls are rejected. Mathematical references
are frozen before application execution and must not change afterward.
