"""Bounded independent checks for the frozen tenth mathematical audit.

Standard library only. References are hand-derived in the frozen round10 docs;
these checks compare complete coefficients, dimensions and finite optima.
"""
import ast
from fractions import Fraction
import math
import re

from round7_reference_checks import (bounded_add, bounded_multiply, bounded_divide,
                                     polynomial_coefficients)
from round8_reference_checks import (scalar, complex_components, matrix_values,
                                     root_values, imaginary_pi_value)
from round9_reference_checks import constraint_assignment_field, validate_statistics

CASES = [
    ('imaginary-quotient-log','ln((1+I)/(1-I))',('pi-imaginary',Fraction(1,2))),
    ('principal-nonreal-square','sqrt((3-4*I)^2)',('complex',3,-4)),
    ('opposed-euler-phases','exp(I*pi/3)+exp(-I*pi/3)','1'),
    ('conjugate-quotient','conjugate((2+I)/(1-3*I))',('complex',Fraction(-1,10),Fraction(-7,10))),
    ('nonreal-repeated-root','solve((I-1)*x^2+(2-2*I)*x+(I-1),x)',('roots',((1,0),))),
    ('quotient-surviving-root','solve((x^2+x-6)/(x^2-4),x)',('roots',((-3,0),))),
    ('complex-source-holes','solve((x^2+1)^2/(x^2+1),x)',('roots',())),
    ('irreducible-square-factor','factor(x^4+2*x^2+1)',('multivariate','x^4+2*x^2+1')),
    ('trivariate-expand','expand((x+y+z)^2-(x+y-z)^2)',('multivariate','4*x*z+4*y*z')),
    ('multivariate-domain-cancellation','simplify((a^2+2*a*b+b^2)/(a+b))',('multivariate','a+b')),
    ('cyclic-permutation-determinant','det(Matrix([[0,1,0],[0,0,1],[1,0,0]]))','1'),
    ('jordan-rational-inverse','inv(Matrix([[2,1,0],[0,2,1],[0,0,2]]))',('matrix',((Fraction(1,2),Fraction(-1,4),Fraction(1,8)),(0,Fraction(1,2),Fraction(-1,4)),(0,0,Fraction(1,2))))),
    ('leading-zero-rref','rref(Matrix([[0,1,2],[0,2,4],[0,1,3]]))',('matrix',((0,1,0),(0,0,1),(0,0,0)))),
    ('regular-log-primitive','integrate(x/(x^2+4),x,0,2)',('real-constant',math.log(2)/2)),
    ('upper-log-endpoint','integrate(ln(3-2*x),x,0,3/2)',('real-constant',3*(math.log(3)-1)/2)),
    ('log-reciprocal-divergence','integrate(ln(x)^2/x,x,0,1)',('error','divergent')),
    ('outside-irrational-poles','integrate(1/(x^2-7),x,-1,1)',('real-constant',math.log((math.sqrt(7)-1)/(math.sqrt(7)+1))/math.sqrt(7))),
    ('rational-center-absolute-series','series(abs(x^2-x),x,1/2,3)',('polynomial',(0,1,-1))),
    ('fifth-order-absolute-zero','series(abs((x-2)^5),x,2,5)','0'),
    ('scaled-radical-limit','limit(sqrt(4*x^2+x)-2*x,x,oo)','1/4'),
    ('triple-angle-limit','limit((sin(3*x)-3*sin(x))/x^3,x,0)','-4'),
    ('opposed-root-square-limits','limit(x/sqrt(x^2),x,0)',('error','left and right limits differ')),
    ('choose-twelve-five','factorial(12)/(factorial(5)*factorial(7))','792'),
    ('reciprocal-exact-decimals','1/(0.125+0.2)','40/13'),
    ('mixed-pivot-determinant','det(Matrix([[1,2,3],[0,-2,4],[5,0,1]]))','68'),
    ('determinant-two-inverse','inv(Matrix([[3,2],[5,4]]))',('matrix',((2,-1),(Fraction(-5,2),Fraction(3,2))))),
    ('rectangular-contraction','Matrix([[1,-1,2],[0,3,1]])*Matrix([[2,0],[-1,4],[3,-2]])',('matrix',((9,-8),(0,10)))),
    ('dependent-scaled-pivot','rref(Matrix([[1,3,4],[2,6,8],[0,2,2]]))',('matrix',((1,0,1),(0,1,1),(0,0,0)))),
    ('prefixed-ohm-voltage','6 kΩ * 2 mA in V',('unit','12','V')),
    ('kiloohm-current','12 V / 3 kΩ in mA',('unit','4','mA')),
    ('pressure-volume-work','2 kPa * 3 L in J',('unit','6','J')),
    ('noncoherent-travel-speed','36 km / 2 h in m/s',('unit','5','m/s')),
    ('cubic-density','5 g / 2 cm³ in kg/m³',('unit','2500','kg/m³')),
    ('force-distance-cgs','3 N * 4 cm in erg',('unit','1200000','erg')),
    ('specific-energy','9 m² / 4 s² in J/kg',('unit','2.25','J/kg')),
]
EXACT_CASES = {'choose-twelve-five','reciprocal-exact-decimals','mixed-pivot-determinant'}
VARIABLES=('x','y','z','a','b')
ZERO=(0,)*len(VARIABLES)


def multivariate_coefficients(expression):
    """Exact bounded rational polynomial, retaining every variable/monomial."""
    text=re.sub(r'\s+','',expression).replace('−','-')
    text=re.sub(r'[⁰¹²³⁴⁵⁶⁷⁸⁹]+',lambda m:'^'+m[0].translate(str.maketrans('⁰¹²³⁴⁵⁶⁷⁸⁹','0123456789')),text)
    text=text.replace('^','**')
    text=re.sub(r'(?<=[0-9)])(?=[xyzab])','*',text)
    # Existing multivariate display writes monomials such as 4xz and 2xy².
    text=re.sub(r'(?<=[xyzab])(?=[xyzab])','*',text)
    assert len(text)<=1024,expression
    tree=ast.parse(text,mode='eval')
    assert sum(1 for _ in ast.walk(tree))<=180,expression
    def trim(p):
        result={k:v for k,v in p.items() if v}
        assert len(result)<=64 and all(sum(k)<=8 for k in result),expression
        return result
    def multiply(p,q):
        assert len(p)*len(q)<=256,expression
        result={}
        for k,v in p.items():
            for l,w in q.items():
                key=tuple(a+b for a,b in zip(k,l))
                assert sum(key)<=8,expression
                result[key]=bounded_add(result.get(key,Fraction(0)),bounded_multiply(v,w))
        return trim(result)
    def parse(node):
        if isinstance(node,ast.Constant) and type(node.value) in {int,float}:
            return trim({ZERO:scalar(ast.get_source_segment(text,node))})
        if isinstance(node,ast.Name):
            assert node.id in VARIABLES,expression
            return {tuple(int(name==node.id)for name in VARIABLES):Fraction(1)}
        if isinstance(node,ast.UnaryOp) and isinstance(node.op,(ast.USub,ast.UAdd)):
            p=parse(node.operand)
            return p if isinstance(node.op,ast.UAdd) else {k:-v for k,v in p.items()}
        assert isinstance(node,ast.BinOp),expression
        p,q=parse(node.left),parse(node.right)
        if isinstance(node.op,(ast.Add,ast.Sub)):
            result=dict(p);sign=1 if isinstance(node.op,ast.Add) else -1
            for k,v in q.items():result[k]=bounded_add(result.get(k,Fraction(0)),sign*v)
            return trim(result)
        if isinstance(node.op,ast.Mult):return multiply(p,q)
        if isinstance(node.op,ast.Div):
            assert set(q)=={ZERO} and q[ZERO],expression
            return trim({k:bounded_divide(v,q[ZERO])for k,v in p.items()})
        assert isinstance(node.op,ast.Pow) and set(q)<={ZERO},expression
        exponent=q.get(ZERO,Fraction(0));assert exponent.denominator==1 and 0<=exponent<=8,expression
        result={ZERO:Fraction(1)}
        for _ in range(int(exponent)):result=multiply(result,p)
        return result
    return trim(parse(tree.body))


def validate_factorization(expression):
    """Require genuine degree-two factors, beyond equality of the expansion."""
    assert multivariate_coefficients(expression)==multivariate_coefficients('x^4+2*x^2+1'),expression
    text=re.sub(r'\s+','',expression).replace('−','-')
    text=re.sub(r'[⁰¹²³⁴⁵⁶⁷⁸⁹]+',lambda m:'^'+m[0].translate(str.maketrans('⁰¹²³⁴⁵⁶⁷⁸⁹','0123456789')),text)
    text=text.replace('^','**')
    text=re.sub(r'(?<=[0-9)])(?=[xyzab])','*',text)
    text=re.sub(r'(?<=[xyzab])(?=[xyzab])','*',text)
    node=ast.parse(text,mode='eval').body
    while isinstance(node,ast.UnaryOp) and isinstance(node.op,ast.UAdd):node=node.operand
    def quadratic(part):
        coefficients=multivariate_coefficients(ast.get_source_segment(text,part))
        assert coefficients and max(sum(key)for key in coefficients)==2,expression
        assert all(not any(key[1:])for key in coefficients),expression
    assert isinstance(node,ast.BinOp),expression
    if isinstance(node.op,ast.Pow):
        assert scalar(ast.get_source_segment(text,node.right))==2,expression
        quadratic(node.left)
    else:
        assert isinstance(node.op,ast.Mult),expression
        quadratic(node.left);quadratic(node.right)


def real_constant(expression):
    """Evaluate only bounded real constants and unary natural log/square root."""
    text=re.sub(r'\s+','',expression).replace('−','-').replace('^','**')
    assert len(text)<=512,expression
    tree=ast.parse(text,mode='eval');assert sum(1 for _ in ast.walk(tree))<=100,expression
    def parse(node):
        if isinstance(node,ast.Constant) and type(node.value) in {int,float}:
            value=float(scalar(ast.get_source_segment(text,node)));assert math.isfinite(value),expression
            return value
        if isinstance(node,ast.UnaryOp) and isinstance(node.op,(ast.USub,ast.UAdd)):
            value=parse(node.operand);return -value if isinstance(node.op,ast.USub) else value
        if isinstance(node,ast.Call):
            assert isinstance(node.func,ast.Name) and node.func.id in {'ln','log','sqrt'},expression
            assert len(node.args)==1 and not node.keywords,expression
            value=parse(node.args[0]);return math.sqrt(value) if node.func.id=='sqrt' else math.log(value)
        assert isinstance(node,ast.BinOp),expression
        left,right=parse(node.left),parse(node.right)
        if isinstance(node.op,ast.Add):value=left+right
        elif isinstance(node.op,ast.Sub):value=left-right
        elif isinstance(node.op,ast.Mult):value=left*right
        elif isinstance(node.op,ast.Div):value=left/right
        else:
            assert isinstance(node.op,ast.Pow) and right.is_integer() and abs(right)<=8,expression
            value=left**int(right)
        assert math.isfinite(value),expression
        return value
    return parse(tree.body)


def validate_domain(domain):
    match=re.fullmatch(r'\s*(.*?)\s*(?:≠|!=)\s*0\s*',domain)
    assert match,domain
    assert not re.search(r'[≠!;=]',match[1]),domain
    try:
        coefficients=multivariate_coefficients(match[1])
    except (SyntaxError,ValueError) as error:
        raise AssertionError(domain) from error
    assert coefficients==multivariate_coefficients('a+b'),domain


def validate_result(case,line):
    name,source,expected=case
    assert line.get('s')==source,(case,line)
    if isinstance(expected,tuple) and expected[0]=='error':
        value=line.get('e') or line.get('r') or ''
        assert expected[1] in value and (line.get('e') or value.startswith('Error')),(case,line)
        return
    assert not line.get('e'),(case,line)
    result=line.get('r');assert isinstance(result,str) and result and not result.startswith('Error'),(case,line)
    evidence=line.get('evidence') or {};free=set()
    if isinstance(expected,tuple):
        kind=expected[0]
        if kind=='complex':assert complex_components(result)==tuple(Fraction(v)for v in expected[1:]),(case,line)
        elif kind=='pi-imaginary':
            imaginary_pi_value(result,expected[1])
            if not re.search(r'pi|π',result):assert evidence.get('accuracy')!='exact',(case,line)
        elif kind=='roots':assert root_values(result)=={tuple(Fraction(v)for v in root)for root in expected[1]},(case,line)
        elif kind=='matrix':assert matrix_values(result)==tuple(tuple(Fraction(v)for v in row)for row in expected[1]),(case,line)
        elif kind=='polynomial':
            assert polynomial_coefficients(result)==[Fraction(v)for v in expected[1]],(case,line)
            free={'x'}
        elif kind=='multivariate':
            ref='x^4+2*x^2+1' if name=='irreducible-square-factor' else expected[1]
            assert multivariate_coefficients(result)==multivariate_coefficients(ref),(case,line)
            free={'x'} if name=='irreducible-square-factor' else {'x','y','z'} if name=='trivariate-expand' else {'a','b'}
            if name=='irreducible-square-factor':validate_factorization(result)
            if name=='trivariate-expand':assert not re.search(r'[()]|expand|Error',result),(case,line)
            if name=='multivariate-domain-cancellation':
                assert not re.search(r'[/^]|simplify|Error',result),(case,line)
                validate_domain(evidence.get('sourceDomain') or '')
        elif kind=='real-constant':
            actual=real_constant(result)
            assert abs(actual-expected[1])<=1e-11*abs(expected[1]),(case,line)
        elif kind=='unit':
            suffix=' '+expected[2]
            assert result.endswith(suffix) and scalar(result[:-len(suffix)].strip())==Fraction(expected[1]),(case,line)
            assert evidence.get('method')=='unitConversion',(case,line)
        else:raise AssertionError(('Unknown independent reference',case))
    else:assert scalar(result)==Fraction(expected),(case,line)
    assert set(line.get('f') or [])==free,(case,line)
    if name in EXACT_CASES:assert evidence.get('accuracy')=='exact',(case,line)
    if source.startswith('limit('):
        assert (evidence.get('method'),evidence.get('accuracy')) in {('symbolicEvaluation','symbolic'),('numericFallback','approximate')},(case,line)


STATISTICS_CASES=[
    ('unequal-repeated-observations','1, 1, 4, 4, 5',{'Count':'5','Mean':'3','Median':'4','Std. deviation (n−1)':'1.870829'}),
    ('tiny-symmetric-dispersion','1e-100, -1e-100, 0, 0, 0',{'Count':'5','Mean':'0','Median':'0','Std. deviation (n−1)':'7.0711e-101'}),
]
CONSTRAINT_CASES=[
    ('odd-sum-balanced-minimum','vars: x, y in 0..5\nx+y == 5\nminimize (x-1)*(x-1)+(y-1)*(y-1)'),
    ('opposed-shifted-product-maximum','vars: x, y in -2..2\nx+y == 0\nmaximize (x+1)*(y+1)'),
]
LINSOLVE_SOURCE='linsolve(x+y+z=6;x-y=0;2*x+z=6;x+2*y+3*z=12,x,y,z)'


def validate_linsolve(result):
    assert isinstance(result,str) and len(result)<=512,result
    pairs=result.split(',');assert len(pairs)==3,result
    values={}
    for pair in pairs:
        match=re.fullmatch(r'\s*([xyz])\s*=\s*(.*?)\s*',pair)
        assert match and match[1]not in values,result
        values[match[1]]=scalar(match[2])
    assert values=={'x':Fraction(2),'y':Fraction(2),'z':Fraction(2)},result
    return values


def validate_optimum(name,header,assignment):
    match=re.fullmatch(r'Optimal: objective =\s*([+-]?\d+(?:\.\d+)?)',header.strip())
    expected=5 if name=='odd-sum-balanced-minimum' else 1
    assert name in {c[0]for c in CONSTRAINT_CASES} and match and Fraction(match[1])==expected,(name,header)
    parts=assignment.split(',');assert len(parts)==2,assignment
    values={}
    for part in parts:
        match=re.fullmatch(r'\s*([xy])\s*=\s*(-?\d+)\s*',part)
        assert match and match[1]not in values,assignment
        values[match[1]]=int(match[2])
    assert set(values)=={'x','y'},assignment
    x,y=values['x'],values['y']
    if name=='odd-sum-balanced-minimum':assert (x,y)in {(2,3),(3,2)} and x+y==5 and (x-1)**2+(y-1)**2==5,assignment
    else:assert (x,y)==(0,0) and x+y==0 and (x+1)*(y+1)==1,assignment
    return {'objective':expected,**values}
