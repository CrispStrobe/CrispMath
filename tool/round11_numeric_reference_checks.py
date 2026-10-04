"""Independent frozen numeric references; no app math/comparator imported."""
from fractions import Fraction as F
import math
import re
from round8_reference_checks import scalar, matrix_values
from round9_reference_checks import validate_statistics, constraint_assignment_field

CASES = [
 ('choose-seventeen-eight','factorial(17)/(factorial(8)*factorial(9))',('scalar',F(24310))),
 ('small-decimal-quotient','0.00625/0.0005',('scalar',F(25,2))),
 ('labelled-triples','factorial(9)/(factorial(3)*factorial(3)*factorial(3))',('scalar',F(1680))),
 ('block-determinant','det(Matrix([[2,1,0,0],[3,4,0,0],[0,0,5,2],[0,0,1,3]]))',('scalar',F(65))),
 ('triangular-inverse','inv(Matrix([[2,1,0],[0,3,4],[0,0,5]]))',('matrix',((F(1,2),F(-1,6),F(2,15)),(0,F(1,3),F(-4,15)),(0,0,F(1,5))))),
 ('rectangular-product','Matrix([[2,-1],[0,3],[-2,4]])*Matrix([[1,0,2,-1],[3,5,-2,4]])',('matrix',((-1,-5,6,-6),(9,15,-6,12),(10,20,-12,18)))),
 ('dependent-augmented-rref','rref(Matrix([[1,2,-1,3],[2,4,-2,6],[0,1,1,2]]))',('matrix',((1,0,-3,-1),(0,1,1,2),(0,0,0,0)))),
 ('capacitor-charge','3 µF * 12 V in µC',('unit',36,'µC')),
 ('inductive-voltage','2 mH * 3 A / 4 ms in V',('unit',1.5,'V')),
 ('flux-density','6 mWb / 3 cm² in T',('unit',20,'T')),
 ('integrated-charge','2 A * 3 s in C',('unit',6,'C')),
 ('electronvolt-energy','4 eV in J',('unit',6.408706536e-19,'J')),
 ('volume-flow','250 mL / 2 s in L/min',('unit',7.5,'L/min')),
]


def quantity(result, expected, symbol):
    assert isinstance(result,str) and len(result)<=256,result
    match=re.fullmatch(r'\s*([+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)\s+(.+?)\s*',result)
    assert match and match[2].replace('μ','µ')==symbol.replace('μ','µ'),result
    value=float(match[1]);assert math.isfinite(value),result
    assert value==0 if expected==0 else abs(value/expected-1)<=1e-10,(result,expected)


def validate_result(case,line):
    kind,*expected=case[2]
    result=line['r']
    assert isinstance(result,str) and not result.startswith('Error:'),line
    if kind=='scalar':assert scalar(result)==expected[0],line
    elif kind=='matrix':assert matrix_values(result)==expected[0],line
    else:quantity(result,*expected)


STATISTICS_CASES=[
 ('eighth-spaced-dispersion','0.125, 0.25, 0.375',{'Count':'3','Mean':'0.25','Median':'0.25','Std. deviation (n−1)':'0.125'}),
 ('trillion-centered-dispersion','1000000000000, 1000000000001, 1000000000002',{'Count':'3','Mean':'1.0000e+12','Median':'1.0000e+12','Std. deviation (n−1)':'1'}),
]
CONSTRAINT_CASES=[
 ('offset-least-squares','vars: x, y in 0..6\nx+y == 6\nminimize (x-1)*(x-1)+(y-2)*(y-2)'),
 ('zero-sum-shifted-product','vars: x, y in -3..3\nx+y == 0\nmaximize (x+2)*(y+2)'),
]


def validate_optimum(name,header,assignment):
    expected=5 if name=='offset-least-squares' else 4
    assert name in {c[0]for c in CONSTRAINT_CASES},name
    match=re.fullmatch(r'Optimal: objective =\s*([+-]?\d+(?:\.\d+)?)',header.strip())
    assert match and F(match[1])==expected,header
    pairs=assignment.split(',');assert len(pairs)==2,assignment
    values={}
    for pair in pairs:
        match=re.fullmatch(r'\s*([xy])\s*=\s*(-?\d+)\s*',pair)
        assert match and match[1] not in values,assignment
        values[match[1]]=int(match[2])
    assert set(values)=={'x','y'},assignment
    x,y=values['x'],values['y']
    if name=='offset-least-squares':assert (x,y)in {(2,4),(3,3)} and x+y==6 and (x-1)**2+(y-2)**2==5,assignment
    else:assert (x,y)==(0,0) and x+y==0 and (x+2)*(y+2)==4,assignment
    return {'objective':expected,**values}


async def check_modules(args):
    # Reuse physical clicks, source readback, unobscured actual result controls,
    # screenshots and build provenance, while swapping independent references.
    import check_round10_math_browser as driver
    originals=(driver.STATISTICS_CASES,driver.CONSTRAINT_CASES,driver.validate_statistics,driver.validate_optimum)
    old_flag=getattr(args,'constraint_only',None)
    try:
        driver.STATISTICS_CASES=STATISTICS_CASES
        driver.CONSTRAINT_CASES=CONSTRAINT_CASES
        driver.validate_statistics=validate_statistics
        driver.validate_optimum=validate_optimum
        args.constraint_only=False
        await driver.check_modules(args)
    finally:
        driver.STATISTICS_CASES,driver.CONSTRAINT_CASES,driver.validate_statistics,driver.validate_optimum=originals
        if old_flag is None:delattr(args,'constraint_only')
        else:args.constraint_only=old_flag
