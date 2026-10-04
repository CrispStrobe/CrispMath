# Twenty new worksheet and graph problems

Drafted as user calculations on 2 October 2026. Expected values use direct
substitution and arithmetic, independently of app output.

1. Dependent affine worksheet: ['a=7', 'b=a-2', 'f(t)=b*t+a', 'f(4)']; expected ['7', '5', '5*t+7', '27']
2. Negative parameter edit: ['a=7', 'b=a-2', 'f(t)=b*t+a', 'f(4)']; expected ['-3', '-5', '-5*t-3', '-23']
3. Rational coefficient: ['r=3/7', 'f(t)=r*t^2', 'f(14)']; expected ['3/7', '3*t^2/7', '84']
4. Nested affine argument: ['f(t)=t^2-1', 'g(u)=f(2*u+1)', 'g(3)']; expected ['t^2-1', '(2*u+1)^2-1', '48']
5. Sequential reassignment: ['n=5', 'n=n+1', 'n^2']; expected ['5', '6', '36']
6. Decimal and rational addition: ['d=0.125', 'd+1/8']; expected ['1/8', '1/4']
7. Rational function substitution: ['f(t)=t/(t+1)', 'f(3)']; expected ['t/(t+1)', '3/4']
8. Exponential at zero: ['f(t)=exp(t)', 'f(0)']; expected ['exp(t)', '1']
9. Negative argument cube: ['f(t)=t^3', 'f(-2)']; expected ['t^3', '-8']
10. Function value becomes variable: ['f(t)=t^2', 'a=f(4)', 'a+f(3)']; expected ['t^2', '16', '25']
11. Decimal parameter recalculation: ['r=0.5', 'area(t)=r*t^2', 'area(4)']; expected ['1/4', 't^2/4', '4']
12. Function replacement invalidates dependents: ['f(t)=t^2', 'b=f(3)', 'b+f(2)']; expected ['t^3', '27', '35']
13. Circle upper semicircle: sqrt(1-x^2); expected [{'x': -2, 'y': None}, {'x': -1, 'y': 0}, {'x': 0, 'y': 1}, {'x': 1, 'y': 0}, {'x': 2, 'y': None}]
14. Logarithm domain: log(x); expected [{'x': -1, 'y': None}, {'x': 0, 'y': None}, {'x': 1, 'y': 0}]
15. Absolute value cusp: abs(x); expected [{'x': -2, 'y': 2}, {'x': -1, 'y': 1}, {'x': 0, 'y': 0}, {'x': 1, 'y': 1}, {'x': 2, 'y': 2}]
16. Rational two poles: 1/(x^2-1); expected [{'x': -2, 'y': 0.3333333333333333}, {'x': -1, 'y': None}, {'x': 0, 'y': -1}, {'x': 1, 'y': None}, {'x': 2, 'y': 0.3333333333333333}]
17. Cancellation still has original hole: (x^2-1)/(x-1); expected [{'x': -2, 'y': -1}, {'x': 0, 'y': 1}, {'x': 1, 'y': None}, {'x': 2, 'y': 3}]
18. Fourth power even curve: x^4-2*x^2; expected [{'x': -2, 'y': 8}, {'x': -1, 'y': -1}, {'x': 0, 'y': 0}, {'x': 1, 'y': -1}, {'x': 2, 'y': 8}]
19. Exact rational document JSON round trip: ['p=2/9', 'f(t)=p*t', 'f(27)']; expected ['2/9', '2*t/9', '6']
20. Markdown retains computed function value: ['f(t)=t^3-2*t', 'f(5)']; expected ['t^3-2*t', '115']

## Explicit feature boundary

Problem 5 originally requests imperative reassignment `n=5; n=n+1; n^2`,
whose expected sequential values are 5, 6, 36. The worksheet is reactive and
uses the last definition of each name throughout the document; self-reference
is deliberately a circular-reference error. The fixture retains the original
requested answers and records this as an unsupported feature, testing explicit
rejection rather than claiming the requested calculation succeeded. The focused
document tests verify `n=5; next=n+1; next^2` computes 5, 6, 36, including after
an edit, without changing the established worksheet semantics. Thus the corpus
contains 99 positive math/workflow cases and one expected feature rejection.
