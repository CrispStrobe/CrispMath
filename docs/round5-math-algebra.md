# Round 5 independent algebra references

These 25 questions and manual references are frozen before inspecting earlier
fixtures or app outputs. Hosted CI performs execution; this shared VPS does not.

1. det([[2,1,0,0],[1,2,0,0],[0,0,3,1],[0,0,1,3]])=24: block determinants 3*8.
2. inv([[0,2],[-3,0]])=[[0,-1/3],[1/2,0]], verified by multiplication.
3. rref([[1,2,3],[2,4,6],[3,6,9]])=[[1,2,3],[0,0,0],[0,0,0]]: rows are proportional.
4. eigenvalues([[2,1],[1,2]])={1,3}, using eigenvectors (1,-1),(1,1).
5. x+y=1, x-y=1/3 gives x=2/3,y=1/3 by addition and subtraction.
6. (x^2-16)/(x^2+3x-4)=0 has only x=4: denominator excludes -4 and 1.
7. Integral 3x^2+2x+1 from -2 to 1 is 9, by [x^3+x^2+x]_-2^1.
8. Integral (x^2+2x+1)/(x+1) from -2 to 0 is 0; continuous extension x+1 is odd around -1.
9. Integral 1/(x^2-3) from 1 to 2 diverges at the interior simple pole sqrt(3).
10. Integral x/(1+x^2)^2 from 0 to 1 is 1/4, by [-1/(2(1+x^2))]_0^1.
11. Integral sin(x)*cos(x) from 0 to pi/2 is 1/2, by sin(x)^2/2.
12. Integral x*exp(x) from 0 to 1 is 1, by (x-1)*exp(x).
13. Limit ln(1+3x)/x at 0 is 3, from the linear logarithm coefficient.
14. Limit (1-cos(3x))/x^2 at 0 is 9/2, from the quadratic cosine coefficient.
15. Limit (sqrt(9+x)-3)/x at 0 is 1/6, by denominator rationalization.
16. Derivative cos(x^2) at sqrt(pi) is 0, since -2x*sin(x^2) vanishes there.
17. Derivative x/(x+1) at 2 is 1/9, by 1/(x+1)^2.
18. Derivative ln(x^2+1) at 3 is 3/5, by 2x/(x^2+1).
19. Derivative sqrt(4x+1) at 2 is 2/3, by 2/sqrt(4x+1).
20. Partial derivative x^2*y^3 with respect to y is 3*x^2*y^2; x remains independent.
21. (3+2I)*(3-2I)=13, by conjugate multiplication.
22. (2-I)^(-2)=(3+4I)/25: (2-I)^2=3-4I, reciprocal conjugation divides by 25.
23. sqrt(144/169)=12/13 exactly, using the nonnegative principal rational root.
24. Worksheet a=2,x=10,integrate(a*x^2,x,0,a) gives 16/3. Editing a to 3 gives 27;
    both coefficient and upper bound must react, while global x stays shadowed.
25. Worksheet g(t)=t+1,x=6,integrate(g(x)^2,x,0,1) gives 7/3, by [(x+1)^3/3]_0^1.
    Function expansion must preserve local dummy scope despite global x=6.

Portable operation adaptation and freshness review follow this frozen list.
Unsupported operations remain findings; answers are never inferred from app output.

Freshness review found earlier exact questions 4 and 12. Their replacements are:
4. eigenvalues([[5,2],[2,5]])={3,7}, using the same symmetric/antisymmetric eigenvectors.
12. Integral x*exp(x) from 0 to ln(3) is 3*ln(3)-2: the same independently
    derived antiderivative gives 3*(ln(3)-1)-(-1). The fixture uses these replacements.
