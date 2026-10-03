# Round eight: independent algebra and calculus references

These 25 questions were drafted from mathematical identities before consulting
prior task fixtures or any application result. Expected values are fixed below.
Execution belongs on hosted CI. Branches of complex powers and logarithms are
principal branches. Integrals and derivatives are real unless stated otherwise.

| ID | Independent question | Reference and derivation |
| --- | --- | --- |
| 01 | Evaluate `sqrt(-9)*sqrt(-16)` | `-12`: principal roots are `3I` and `4I`; their product is `12I^2`. |
| 02 | Evaluate `ln(-I)` | `-pi*I/2`: modulus one and principal argument `-pi/2`. |
| 03 | Evaluate `(1+I)^(-3)` | `-1/4-I/4`: the cube is `-2+2I`; reciprocation multiplies its conjugate by `1/8`. |
| 04 | Evaluate `conjugate((1-I)^3)` | `-2+2I`: the cube is `-2-2I`, then conjugate changes the imaginary sign. |
| 05 | Evaluate `(2+I)/(2-I)+(2-I)/(2+I)` | `6/5`: terms are `(3+4I)/5` and `(3-4I)/5`. |
| 06 | Solve `(x^2-4)^2/(x+2)=0` | `{2}`: the numerator has roots `±2`, while the original denominator excludes `-2`. |
| 07 | Solve `(x-3)^3/(x^2-9)=0` | No solutions: only numerator root `3` is excluded by the denominator. |
| 08 | Solve `x^2-2*I*x-2=0` | `{-1+I,1+I}`: completing the square gives `(x-I)^2=1`. |
| 09 | Integrate `ln(x)^3` from zero to one | `-6`: substitute `x=e^-t`, yielding minus the third gamma moment `-3!`. |
| 10 | Integrate `1/(x^3-x-1)` from one to two | Divergent pole: the denominator is `-1` at one and `5` at two, with derivative `3x^2-1>0` throughout. Its unique interior zero is simple, so the ordinary integral diverges. |
| 11 | Integrate `(x^2-3)/(x^2-3)` from one to two | `1`: its removable interior hole has bounded continuous extension identically one. |
| 12 | Integrate `1/sqrt(3*x)` from zero to three | `2`: primitive `2*sqrt(x)/sqrt(3)`, evaluated by the convergent right endpoint limit. |
| 13 | Integrate `ln(1+2*x)` from `-1/2` to zero | `-1/2`: set `u=1+2x`, so half the known integral of `ln(u)` from zero to one. |
| 14 | Differentiate `abs(x^2+2*x+2)` at `-1` | `0`: the inner polynomial `(x+1)^2+1` is positive everywhere, derivative `2x+2`. |
| 15 | Differentiate `abs((x-2)^4)` at two | `0`: absolute value equals the globally nonnegative fourth power. |
| 16 | Differentiate `(x-1)*abs(x-1)` at one | `0`: the difference quotient is `abs(h)`, tending to zero from both sides. |
| 17 | Taylor-expand `abs((x-1)^2)` around one through order four (five terms) | `(x-1)^2`: the inner square is nonnegative, so expansion is the same degree-two polynomial. |
| 18 | Taylor-expand `abs(x^2-4*x+3)` around two with four terms | `-x^2+4*x-3`: the inner polynomial is negative near two. |
| 19 | Limit `sqrt(9*x^2+6*x+7)-3*x` at positive infinity | `1`: rationalization divides `6x+7` by a denominator asymptotic to `6x`. |
| 20 | Limit `x^2*cos(1/x)` at zero | `0`: bounded cosine and amplitude `x^2` squeeze the expression between `±x^2`. |
| 21 | Limit `(abs(x-2))/(x-2)` at two, two-sided | Does not exist: left limit `-1`, right limit `1`. |
| 22 | Limit `(exp(2*x)-1-2*x)/x^2` at zero | `2`: Taylor numerator starts with `(2x)^2/2`. |
| 23 | Compute inverse of `[[0,2],[3,0]]` | `[[0,1/3],[1/2,0]]`: direct multiplication yields identity. |
| 24 | Compute determinant of `[[1,2,0],[0,1,2],[2,0,1]]` | `9`: identity permutation contributes one, cyclic permutation contributes eight. |
| 25 | Compute square of `[[1,1],[0,1]]` | `[[1,2],[0,1]]`: write `I+N` with `N^2=0`, then square as `I+2N`. |

## Freshness review

The initial references above were drafted before reading earlier fixtures. A
read-only comparison found three exact reused inputs; they were replaced before
any execution:

- 03: `(1+I)^8` previously existed; replaced by the independently derived negative
  Gaussian power `(1+I)^(-3)`.
- 08: the real-coefficient quadratic `x^2+2*x+5` previously existed; replaced by
  a complex-coefficient quadratic, derived by completing its complex square.
- 10: the quadratic-pole integral `1/(x^2-3)` on `[1,2]` previously existed;
  replaced by a cubic-pole integral with a sign-change and monotonicity proof.

The resulting 25 operation/argument tuples contain no exact prior-fixture
duplicates. Expected values were never obtained from app output. Cases 17/18
also require an actual polynomial result: repeating the original absolute-value
expression cannot pass merely by numerical equivalence. No mathematical
reference may be changed after execution.
