# Round 4 independently derived algebra audit

The mathematical questions and references below are frozen before examining
earlier mathematical answers or running the app. Only the known fixture envelope
was inspected first; these references are hand derived, not app outputs.
Execution belongs on GitHub-hosted runners, never this shared VPS.

1. The determinant of [[0,2,-3],[-2,0,5],[3,-5,0]] is 0: an odd-dimensional
   skew-symmetric matrix has det(A)=det(-A)=-det(A).
2. Inverse of [[2,1],[1,3]] is [[3/5,-1/5],[-1/5,2/5]], since determinant is 5.
3. RREF of [[1,2,5],[2,5,12]] is [[1,0,1],[0,1,2]]: subtract twice row 1,
   then subtract twice the resulting row 2 from row 1.
4. Eigenvalues of [[0,-2],[2,0]] are {-2I,2I}, from lambda^2+4=0.
5. Solve 2x+3y=1, 5x-y=4: x=13/17, y=-3/17.
6. Solve (x^2-9)/(x-3)=0: x=-3 only; x=3 is excluded by the source denominator.
7. Integral x^3 from -1/2 to 3/2 is 5/4, using x^4/4.
8. Integral (x^2-x)/(x-1) from 0 to 2 is 2: the continuous extension is x.
9. Integral (x+1)/(x^2-1) from -2 to 2 diverges at x=1 despite cancelling x=-1.
10. Integral 2x/(x^2+4) from 0 to 2 is ln(2), by u=x^2+4.
11. Integral cos(3x) from 0 to pi/6 is 1/3, using sin(3x)/3.
12. Integral exp(-2x) from 0 to ln(2) is 3/8.
13. Limit (tan(x)-x)/x^3 as x approaches 0 is 1/3, from tan's cubic coefficient.
14. Limit (ln(1+x)-x)/x^2 at 0 is -1/2, from ln's quadratic coefficient.
15. Limit x/(sqrt(1+x)-1) at 0 is 2, by rationalizing the denominator.
16. Derivative of exp(2x) at 0 is 2.
17. Derivative of atan(x) at sqrt(3) is 1/4.
18. Derivative of x^x at 1 is 1, using x^x(ln(x)+1) on x>0.
19. Derivative of x*sin(x) at pi is -pi.
20. Partial derivative of x*y^2+y with respect to x is y^2; y remains symbolic.
21. (2+I)^3 = 2+11I, by multiplying (3+4I)(2+I).
22. (1-I)^8 = 16, since (1-I)^2=-2I and its fourth power is -4.
23. (3+I)/(1-2I) = (1+7I)/5, multiplying numerator and denominator by 1+2I.
24. Worksheet f(t)=t^3-t, x=8, integrate(f(x),x,-1,1) gives 0 because the
    integrand is odd; the dummy x must shadow global x=8.
25. Worksheet a=4, x=9, integrate(a*x,x,1,a) gives 30: 4*(4^2-1)/2.
    Both a occurrences are global; x is bound only in the integrand/declaration.

After freezing references, the supported CLI schema is used without changing
the questions. Unavailable operations must remain reported findings. Precision,
domain and free-variable assertions are included where independently justified.

Freshness review after freezing found that questions 13, 14 and 18 were exact
duplicates of earlier audits. Replace them, with new independent references:
13. Limit (tan(2x)-2x)/x^3 at 0 is 8/3: substitute 2x in the cubic coefficient.
14. Limit (ln(1+2x)-2x)/x^2 at 0 is -2: substitute 2x in the quadratic term.
18. Derivative of x^x at e is 2*exp(e), since ln(e)+1=2 and e^e=exp(e).
The fixture uses these replacement questions. No reference is based on execution.
