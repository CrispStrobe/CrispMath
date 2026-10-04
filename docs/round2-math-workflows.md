# Round two: 20 worksheet, graph and export problems

Drafted independently on 2 October 2026 before checking prior corpora. Expectations follow substitution, exact arithmetic, and original-expression real domains. These are desired mathematical behaviors; unsupported features must remain explicitly recorded.

1. **Diamond dependency recomputes both branches** — `a=2; b=a+3; c=a^2; b+c`. Expected: `['4', '7', '16', '23']`.
2. **Forward reference resolves before its definition** — `a=b+1; b=8; a*b`. Expected: `['9', '8', '72']`.
3. **Function argument shadows document variable** — `t=100; f(t)=t^2+1; f(3)+t`. Expected: `['100', 't^2+1', '110']`.
4. **Nested user function composition** — `f(u)=u^2+u; g(v)=f(v-1); g(-2)`. Expected: `['u^2+u', '(v-1)^2+v-1', '6']`.
5. **Two argument function** — `f(x,y)=x^2+2*x*y+y^2; f(3,-5)`. Expected: `['x^2+2*x*y+y^2', '4']`.
6. **Function coefficient edit cascades** — `a=3/5; f(z)=a*z+1; g(w)=f(f(w)); g(10)`. Expected: `['2/5', '2*z/5+1', '2*(2*w/5+1)/5+1', '3']`.
7. **Zero coefficient remains valid definition** — `a=0; f(u)=a*u+7; f(1000)`. Expected: `['0', '7', '7']`.
8. **Exact decimal coefficient through dependent division** — `p=0.2; q=p/3; q*15`. Expected: `['1/5', '1/15', '1']`.
9. **Cancelled denominator after parameter substitution** — `a=2; f(t)=(t^2-a^2)/(t-a); f(3)`. Expected: `['2', '(t^2-4)/(t-2)', '5']`.
10. **Two independent names survive parameter edit** — `a=2; b=3; f(t)=a*t+b; f(-4)`. Expected: `['2', '-7', '2*t-7', '-15']`.
11. **Shifted square-root domain** — `sqrt(x+1)`. Expected: `[{'x': -2, 'y': None}, {'x': -1, 'y': 0}, {'x': 0, 'y': 1}, {'x': 1, 'y': 1.4142135623730951}, {'x': 2, 'y': 1.7320508075688772}]`.
12. **Reciprocal square positive except pole** — `1/x^2`. Expected: `[{'x': -2, 'y': 0.25}, {'x': -1, 'y': 1}, {'x': 0, 'y': None}, {'x': 1, 'y': 1}, {'x': 2, 'y': 0.25}]`.
13. **Original cancelled even poles** — `(x^2-1)/(x^2-1)`. Expected: `[{'x': -2, 'y': 1}, {'x': -1, 'y': None}, {'x': 0, 'y': 1}, {'x': 1, 'y': None}, {'x': 2, 'y': 1}]`.
14. **Absolute-value shifted corner** — `abs(x+1)-2`. Expected: `[{'x': -2, 'y': -1}, {'x': -1, 'y': -2}, {'x': 0, 'y': -1}, {'x': 1, 'y': 0}, {'x': 2, 'y': 1}]`.
15. **Trigonometric fundamental identity** — `sin(x)^2+cos(x)^2`. Expected: `[{'x': -2, 'y': 1}, {'x': -1, 'y': 1}, {'x': 0, 'y': 1}, {'x': 1, 'y': 1}, {'x': 2, 'y': 1}]`.
16. **Nested denominator has removable hole** — `(1/x)/(1/x)`. Expected: `[{'x': -2, 'y': 1}, {'x': -1, 'y': 1}, {'x': 0, 'y': None}, {'x': 1, 'y': 1}, {'x': 2, 'y': 1}]`.
17. **Edited rational values survive JSON** — `a=5/12; b=1-a; 12*b`. Expected: `['5/12', '7/12', '7']`.
18. **Negative rational result retained in Markdown** — `a=-7/3; a^2; a^3`. Expected: `['-7/3', '49/9', '-343/27']`.
19. **Multiple variables remain in LaTeX** — `a=3; f(t)=a*t^2-2; f(-3)`. Expected: `['3', '3*t^2-2', '25']`.
20. **Function results included in PDF** — `f(t)=t^3+t; f(2); f(-2)`. Expected: `['t^3+t', '10', '-10']`.
