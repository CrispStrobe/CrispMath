# Third independent numeric audit

This draft was fixed before reading earlier fixtures. Expected values follow
independent arithmetic, probability definitions, dimensional conversion and
complete finite enumeration. All app execution belongs on GitHub-hosted CI;
the shared VPS is used only for these small source edits.

1. Compute `(-2)^(-3)` exactly: -1/8.
2. Compute `(-8)^(1/3)`: test the real cube-root convention, expected -2.
3. Compute `0.000125 * 8000` exactly: 1.
4. Compute `1/(1/2 + 1/3 + 1/6)` exactly: 1.
5. Compute `abs(-17)%5`: 2.
6. Compute `sqrt(2)^2`: 2.
7. Compute `3^(-4) / 3^(-2)` exactly: 1/9.
8. Compute `(-11)%4`, under nonnegative Euclidean remainder: 1.
9. Describe `[0.1,0.2,0.3]`: mean/median 0.2, sample SD 0.1.
10. Describe `[6,2,6,2]`: mean/median 4, sample SD sqrt(16/3).
11. Regress x=[0,2,4], y=[5,5,5]: slope0, intercept5; coefficient
    of determination is undefined because the response variance is zero.
12. Binomial mass n=2, p=0.75, k=2: 9/16.
13. Student-t(1) probability on [0,1]: 1/4.
14. Normal CDF at its mean1000000 with SD0.01: 1/2.
15. Convert 2 kWh to kJ: 7200 kJ.
16. Convert 1 mm³ to microlitres: 1 μL.
17. Convert 0.5 hectares to square metres: 5000 m².
18. Convert 1 km/ms to m/s: 1000000 m/s.
19. Compute pressure `100 N / 0.5 m²` in kPa: 0.2 kPa.
20. Convert -0.5 m/s to km/h: -1.8 km/h.
21. Enumerate x,y in[-2,2] with x*x+y*y=2: four pairs (±1,±1).
22. Enumerate x in[-3,3] with x*x<=1: -1,0,1.
23. Enumerate distinct a,b,c in[1,4] with a+b+c=9: six permutations of2,3,4.
24. Enumerate x,y in[-3,3] with x*x*y*y=4: eight ordered pairs with
    magnitudes1and2, independently signed.
25. Maximize `2*x+y` for x,y in[0,4] subject to x+y<=4: optimum8.

Boundary expectations remain explicit. Problem2 requests the real cube root,
whereas generic principal complex exponentiation may legitimately differ;
that difference must be recorded rather than changing this reference. Problem8
states its Euclidean remainder convention. Problem11 keeps undefined r² as
null in the portable reference, rather than claiming perfect explanatory power
for a constant response.

## Fixture routing and independent checks

`test/fixtures/round3_numeric_tasks.json` contains exactly 25 new tasks:
eight engine calculations and seventeen real module operations. The second
question uses explicit `cbrt(-8)` in the fixture to request the drafted real
cube root unambiguously, rather than imposing real-root behavior on generic
complex principal exponentiation. Its independently fixed answer remains -2.
This is a domain clarification, not a change based on observed app output.

Arithmetic references are -1/8, -2, 1, 1, 2, 2, 1/9 and 1. In particular,
Euclidean division is `-11=(-3)*4+1`; the remainder is in `[0,4)`.
The descriptive samples have centered squared deviations 0.02 and16,
respectively: divide by `n-1` to obtain SD0.1 and `sqrt(16/3)`.
For a constant response the total sum of squares is zero, so the customary
`1-SSE/SST` definition does not define r². The slope and intercept are still
well-defined, 0 and5, and the fixture preserves null for the undefined statistic.
The probability references are `(3/4)^2=9/16`,
`atan(1)/pi-atan(0)/pi=1/4`, and normal symmetry1/2.

Dimensional references use `1kWh=3600kJ`, `1mm³=10^-9m³=1μL`,
`1ha=10000m²`, prefix factors `1000m/0.001s=1000000m/s`,
`100N/0.5m²=200Pa=0.2kPa`, and a road-speed conversion factor3.6.
The signed speed therefore remains -1.8km/h.

Constraint references are complete sets. A sum of squares2 requires both
magnitudes1, giving four independent sign choices. Square<=1 gives -1,0,1.
A distinct bounded triple summing to9 must consist of2,3,4, with six
permutations. `x²*y²=4` requires magnitudes1and2 in either order, with four
sign choices in each order, giving eight solutions. Finally,
`2*x+y=(x+y)+x<=4+4=8`, attained at x4,y0, proves the maximum8.

Small source inspection after drafting shows two likely gaps: regression
currently reports r²1 for a constant response, and microlitre prefixes are
absent from the catalog. These expectations remain unchanged. All tasks use
the current engine/module routes and should run on native and web paths;
unsupported real cube-root support, if observed, is a reported feature gap,
not a fabricated pass. No execution or artifact download took place locally.
