# Fresh 50-problem audit

Drafted independently of the existing test corpus on 2 October 2026.
These are user problems, not a list selected to match current engine operations.
Expected answers must be verified independently before scoring. A missing CLI
adapter must be distinguished from a missing application capability.

1. Apply 19% tax and then a 10% discount to 37.50.
2. Add 7/12 and 5/18 exactly.
3. Find the remainder of 123456789 divided by 97.
4. Factor 360360 into primes.
5. Find the greatest common divisor and least common multiple of 84 and 126.
6. Evaluate 2^100 exactly.
7. Compute the number of ways to choose 6 objects from 20.
8. Evaluate sin(pi/6) + cos(pi/3) exactly.
9. Evaluate log base 2 of 1024.
10. Compute the magnitude of 3+4i.
11. Expand (2x-3)^4.
12. Factor x^4-5x^2+4.
13. Cancel (x^2-9)/(x^2+x-6), retaining the excluded input values.
14. Solve x^2-5x+6=0.
15. Solve 2x+3y=7 and 4x-y=5.
16. Solve x^2+1=0 over the complex numbers.
17. Find the derivative of x^3*exp(x).
18. Find the second derivative of sin(2x).
19. Integrate 3x^2-4x+2 indefinitely.
20. Integrate x^3 from -2 to 3 exactly.
21. Integrate sin(x) from 0 to pi.
22. Compute the limit sin(3x)/x as x approaches zero.
23. Compute the limit (sqrt(1+x)-1)/x as x approaches zero.
24. Find the Maclaurin polynomial of exp(x) through degree 5.
25. Find the Taylor polynomial of log(x) about x=1 through degree 4.
26. Find the real roots and minimum of x^2-4x+3, and inspect its graph.
27. Tabulate 1/(x-1) at x=-1,0,1,2,3, explicitly marking the pole.
28. Plot sin(x) and cos(x) together and inspect their intersection near pi/4.
29. Define a=2 and f(t)=t^2+a, evaluate f(3), then change a to 5.
30. Define f(t)=t^2, g(t)=f(t)+f(t+1), and evaluate g(3).
31. Compute the determinant of [[2,1,3],[0,-1,4],[5,2,0]].
32. Invert [[4,7],[2,6]] and multiply by the original matrix.
33. Reduce [[1,2,3],[2,4,6],[1,1,1]] to reduced row echelon form.
34. Find the eigenvalues of [[2,1],[1,2]].
35. Compute the mean, median and sample standard deviation of [2,4,4,4,5,5,7,9].
36. Fit a straight line to points (1,3),(2,5),(3,7),(4,9).
37. Run a one-sample two-sided t-test on [9,10,11,10,10] against mean 10.
38. Run a paired two-sided t-test on before [10,12,9,11,13] and after [12,13,12,12,16].
39. Compute chi-square goodness-of-fit for observed [10,20,30] and expected [20,20,20].
40. Find the probability of exactly 3 successes in 10 trials with success probability 0.2.
41. Convert 72 km/h to m/s.
42. Convert 32 degrees Fahrenheit to Celsius.
43. Add 2 m and 35 cm, returning metres.
44. Compute the kinetic energy of 3 kg moving at 4 m/s in joules.
45. Convert 2 litres to cubic centimetres.
46. Find the date 2028-02-28 plus 2 days.
47. Find the number of days between 2027-12-31 and 2028-03-01.
48. Solve a four-queens constraint problem and verify every pair of queens.
49. Solve the Boolean constraints (a or b), (not a or c), and (not b or not c); verify every clause.
50. Solve a 4x4 Sudoku with rows [1,0,0,4], [0,4,1,0], [0,1,4,0], [4,0,0,1], checking rows, columns and 2x2 boxes.

Status: drafted; not scored yet. Unit, CLI/runtime and live UI coverage will be
recorded separately, with source SHA and CI run links. No pass count is claimed
from this draft.
