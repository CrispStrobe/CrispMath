# Round 11: independent algebra and calculus references

These 25 questions and exact references were derived before running the app,
CLI, tests, or inspecting previous result reports. Operation names and fixture
grammar were read solely to register the independently selected questions.
They form the algebra half of the fresh 50-question audit.

Real variables are used unless the question explicitly involves `I`, the
imaginary unit. `log` means natural logarithm. Complex square roots and logarithms
use principal branches; Arg lies in (-pi, pi]. Definite integrals use ordinary
improper-integral semantics at singular endpoints and infinity. The series
request with order 5 retains powers below 5; its reference stores the polynomial,
with remainder O(x^5) stated here. No reference is chosen from app output.

| ID suffix | Independent question | Exact reference and derivation |
| --- | --- | --- |
| 01 | Expand (2x-3y)^3. | 8x^3-36x^2y+54xy^2-27y^3, from the four binomial coefficients 1,3,3,1. |
| 02 | Factor x^4+4y^4 over the rationals. | (x^2-2xy+2y^2)(x^2+2xy+2y^2). This is (x^2+2y^2)^2-(2xy)^2, whose expansion is x^4+4y^4. |
| 03 | Simplify (x^2-9)/(x^2+6x+9), preserving its source domain. | (x-3)/(x+3), x != -3. Numerator is (x-3)(x+3), denominator is (x+3)^2; both source and result exclude -3. |
| 04 | Solve (x-4)^2=25 for real x. | {-1,9}. x-4 is either -5 or 5; both substituted values give 25. |
| 05 | Solve 2^(x+1)=32 for real x. | {4}. 32=2^5 and base-2 exponentiation is injective on the reals. |
| 06 | Solve log(x-2)=log(7-x) for real x. | {9/2}. The common domain is 2<x<7. Injectivity gives x-2=7-x; 9/2 is in that interval and both log arguments equal 5/2. |
| 07 | Solve 2x-y+z=7; x+3y-2z=-3; 3x+y+z=11. | x=2,y=1,z=4. Substitution gives 7,-3,11; the coefficient determinant is 9, proving uniqueness. |
| 08 | Differentiate atan(3x). | 3/(1+9x^2), by the chain rule, valid for every real x. |
| 09 | Differentiate x^x on x>0. | x^x(log(x)+1). Write x^x=exp(x log(x)); the inner derivative is log(x)+1. |
| 10 | Differentiate log(sqrt(x^2+4)). | x/(x^2+4), for every real x. Since x^2+4>0, the input equals (1/2)log(x^2+4). |
| 11 | Integrate x/(x^2+7) from 0 to 3. | (1/2)log(16/7). The primitive is (1/2)log(x^2+7), so the endpoint difference is (log(16)-log(7))/2. |
| 12 | Integrate x exp(-2x) from 0 to positive infinity. | 1/4. Primitive -(x/2+1/4)exp(-2x) tends to zero at infinity and equals -1/4 at zero. |
| 13 | Integrate 1/sqrt(1-x^2) from -1 to 1. | pi. The primitive asin(x) tends to -pi/2 and pi/2 at the two endpoints. Each endpoint singularity is of inverse-square-root type and integrable separately. |
| 14 | Integrate x sin(x) from 0 to pi. | pi. Integration by parts gives primitive -x cos(x)+sin(x), whose endpoint values are pi and zero. |
| 15 | Integrate x^2/sqrt(1+x^3) from 0 to 2. | 4/3. Set u=1+x^3, du=3x^2 dx; (1/3) integral from 1 to 9 of u^(-1/2) is (2/3)(3-1). |
| 16 | Take the two-sided limit (tan(x)-sin(x))/x^3 at zero. | 1/2. Expand tan(x)=x+x^3/3+O(x^5) and sin(x)=x-x^3/6+O(x^5); the linear terms cancel and the cubic coefficient is 1/3+1/6. |
| 17 | Take sqrt(x^2+5)-x as x tends to positive infinity. | 0. Rationalization gives 5/(sqrt(x^2+5)+x), whose positive denominator tends to infinity. |
| 18 | Take the two-sided limit (1-cos(4x))/x^2 at zero. | 8. The cosine expansion gives 1-cos(4x)=8x^2+O(x^4). |
| 19 | Expand exp(x) cos(x) around zero through degree 4. | 1+x-x^3/3-x^4/6+O(x^5). Multiply (1+x+x^2/2+x^3/6+x^4/24) by (1-x^2/2+x^4/24); coefficients of x^2,x^3,x^4 are 0,-1/3,-1/6. |
| 20 | Evaluate sqrt(-16) sqrt(-9), using principal roots. | -12. The two roots are 4I and 3I, so their product is 12I^2=-12. |
| 21 | Evaluate the principal log(-I). | -I*pi/2. Modulus is 1 and principal argument is -pi/2, so log modulus contributes zero. |
| 22 | Evaluate (1+I)^6. | -8I. Its square is 2I, and cubing that square gives (2I)^3=-8I. |
| 23 | Find det([[x,1,0],[0,x,1],[1,0,x]]). | x^3+1. Expansion along the first row gives x*x^2-1*(0*x-1*1). |
| 24 | Cube A=[[1,2,0],[0,1,3],[0,0,1]]. | [[1,6,18],[0,1,9],[0,0,1]]. Write A=Id+N, where N^3=0 and N^2 has only entry (1,3)=6; A^3=Id+3N+3N^2. |
| 25 | Invert A=[[1,2,0],[0,1,3],[0,0,1]]. | [[1,-2,6],[0,1,-3],[0,0,1]]. Since N^3=0, (Id+N)^(-1)=Id-N+N^2. Multiplication cancels both N and N^2 terms, yielding Id. |

## Reference verification and freeze

Each reference has an explicit identity, substitution, derivative, endpoint
evaluation, or convergence argument above. Nonlinear real equations include
domain and completeness arguments; the linear system has a nonzero determinant.
The three complex questions specify branches and use the full complex value.
No uncertain mathematical reference remains in this draft.

The draft receives a static stimulus-only duplicate check against prior fixture
inputs before freezing. App evaluation and result-led implementation changes
begin only after the combined 50-question reference set is committed.
