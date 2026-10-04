"""Independent full-value checks of the frozen round-eleven algebra audit.

No app engine or app comparator is imported. Exact bounded coefficients prove
polynomial/rational identities; matrix entries, roots, and complex parts are
compared in full. Hand-derived references are frozen in round11-math-algebra.md.
"""
import ast
from fractions import Fraction as F
import math
import re

from round7_reference_checks import polynomial_coefficients
from round8_reference_checks import (scalar, complex_components, matrix_values,
                                     root_values, imaginary_pi_value)
from round10_reference_checks import multivariate_coefficients

CASES = [
    ('signed-cubic', 'expand((2*x-3*y)^3)', ('multi', '8*x^3-36*x^2*y+54*x*y^2-27*y^3')),
    ('sophie-germain', 'factor(x^4+4*y^4)', ('factor', 'x^4+4*y^4')),
    ('surviving-exclusion', 'simplify((x^2-9)/(x^2+6*x+9))', ('rational', '(x-3)/(x+3)')),
    ('shifted-square', 'solve((x-4)^2=25,x)', ('roots', (-1,9))),
    ('shifted-exponential', 'solve(2^(x+1)=32,x)', ('roots', (4,))),
    ('intersected-log-domain', 'solve(log(x-2)=log(7-x),x)', ('roots', (F(9,2),))),
    ('scaled-arctangent', 'diff(atan(3*x),x)', ('rational', '3/(1+9*x^2)')),
    ('self-power', 'diff(x^x,x)', ('self-power', None)),
    ('nested-log-radical', 'diff(log(sqrt(x^2+4)),x)', ('rational', 'x/(x^2+4)')),
    ('rational-log-integral', 'integrate(x/(x^2+7),x,0,3)', ('constant', math.log(16/7)/2)),
    ('exponential-moment', 'integrate(x*exp(-2*x),x,0,oo)', ('scalar', F(1,4))),
    ('two-endpoint-singularities', 'integrate(1/sqrt(1-x^2),x,-1,1)', ('pi', F(1))),
    ('sine-first-moment', 'integrate(x*sin(x),x,0,pi)', ('pi', F(1))),
    ('cubic-radical-substitution', 'integrate(x^2/sqrt(1+x^3),x,0,2)', ('scalar', F(4,3))),
    ('tangent-sine-cancellation', 'limit((tan(x)-sin(x))/x^3,x,0)', ('scalar', F(1,2))),
    ('radical-at-infinity', 'limit(sqrt(x^2+5)-x,x,oo)', ('scalar', F(0))),
    ('cosine-second-order', 'limit((1-cos(4*x))/x^2,x,0)', ('scalar', F(8))),
    ('exponential-cosine-series', 'series(exp(x)*cos(x),x,0,5)', ('poly', (1,1,0,F(-1,3),F(-1,6)))),
    ('principal-root-product', 'sqrt(-16)*sqrt(-9)', ('scalar', F(-12))),
    ('principal-negative-imaginary-log', 'log(-I)', ('imaginary-pi', F(-1,2))),
    ('gaussian-sixth-power', '(1+I)^6', ('complex', (0,-8))),
    ('cyclic-symbolic-determinant', 'det(Matrix([[x,1,0],[0,x,1],[1,0,x]]))', ('poly', (1,0,0,1))),
    ('nonuniform-shear-cube', 'Matrix([[1,2,0],[0,1,3],[0,0,1]])^3', ('matrix', ((1,6,18),(0,1,9),(0,0,1)))),
    ('nonuniform-shear-inverse', 'inv(Matrix([[1,2,0],[0,1,3],[0,0,1]]))', ('matrix', ((1,-2,6),(0,1,-3),(0,0,1)))),
    ('supplement-principal-root-product', 'sqrt(-25)*sqrt(-49)', ('scalar', F(-35))),
    ('supplement-nonunit-log-modulus', 'ln(-2*I)', ('complex-constant', (math.log(2),-math.pi/2))),
]
LINSOLVE_SOURCE='linsolve([2*x-y+z=7,x+3*y-2*z=-3,3*x+y+z=11],[x,y,z])'


def normalized(expression):
    text=re.sub(r'\s+','',expression).replace('−','-').replace('π','pi')
    text=re.sub(r'[⁰¹²³⁴⁵⁶⁷⁸⁹]+',lambda m:'^'+m[0].translate(str.maketrans('⁰¹²³⁴⁵⁶⁷⁸⁹','0123456789')),text)
    text=text.replace('^','**')
    text=re.sub(r'(?<=[0-9)])(?=[xyzab(])','*',text)
    return text


def rational_parts(expression):
    """Parse bounded univariate rational functions into exact polynomial pairs."""
    text=normalized(expression)
    assert len(text)<=1024,expression
    tree=ast.parse(text,mode='eval');assert sum(1 for _ in ast.walk(tree))<=150,expression
    def trim(p):
        while len(p)>1 and p[-1]==0:p.pop()
        assert len(p)<=25 and all(v.numerator.bit_length()<=512 and v.denominator.bit_length()<=512 for v in p),expression
        return p
    def mul(p,q):
        assert len(p)*len(q)<=256,expression
        r=[F(0)]*(len(p)+len(q)-1)
        for i,v in enumerate(p):
            for j,w in enumerate(q):r[i+j]+=v*w
        return trim(r)
    def add(p,q,sign=1):
        r=[F(0)]*max(len(p),len(q))
        for i,v in enumerate(p):r[i]+=v
        for i,v in enumerate(q):r[i]+=sign*v
        return trim(r)
    def parse(node):
        if isinstance(node,ast.Constant) and type(node.value) in {int,float}:return [scalar(ast.get_source_segment(text,node))],[F(1)]
        if isinstance(node,ast.Name):
            assert node.id=='x',expression
            return [F(0),F(1)],[F(1)]
        if isinstance(node,ast.UnaryOp) and isinstance(node.op,(ast.UAdd,ast.USub)):
            p,q=parse(node.operand);return ([-v for v in p] if isinstance(node.op,ast.USub) else p),q
        assert isinstance(node,ast.BinOp),expression
        p,q=parse(node.left)
        if isinstance(node.op,ast.Pow):
            n=scalar(ast.get_source_segment(text,node.right));assert n.denominator==1 and abs(n)<=8,expression
            if n<0:p,q=q,p
            a,b=[F(1)],[F(1)]
            for _ in range(abs(int(n))):a,b=mul(a,p),mul(b,q)
            assert any(b),expression
            return a,b
        a,b=parse(node.right)
        if isinstance(node.op,ast.Mult):return mul(p,a),mul(q,b)
        if isinstance(node.op,ast.Div):
            assert any(a),expression
            return mul(p,b),mul(q,a)
        assert isinstance(node.op,(ast.Add,ast.Sub)),expression
        return add(mul(p,b),mul(a,q),-1 if isinstance(node.op,ast.Sub) else 1),mul(q,b)
    p,q=parse(tree.body);assert any(q),expression
    return p,q,mul


def rational_equal(actual,expected):
    p,q,mul=rational_parts(actual);a,b,_=rational_parts(expected)
    assert mul(p,b)==mul(a,q),(actual,expected)


def real_constant(expression,complex_mode=False):
    text=normalized(expression);assert len(text)<=512,expression
    if complex_mode:
        text=re.sub(r'(?<=[0-9)])i\b','*I',text)
        text=re.sub(r'\bi\b','I',text)
    tree=ast.parse(text,mode='eval');assert sum(1 for _ in ast.walk(tree))<=100,expression
    def parse(node):
        if isinstance(node,ast.Constant) and type(node.value) in {int,float}:return float(scalar(ast.get_source_segment(text,node)))
        if isinstance(node,ast.Name):
            assert node.id=='pi' or (complex_mode and node.id=='I'),expression
            return 1j if node.id=='I' else math.pi
        if isinstance(node,ast.UnaryOp) and isinstance(node.op,(ast.UAdd,ast.USub)):
            a=parse(node.operand);return -a if isinstance(node.op,ast.USub) else a
        if isinstance(node,ast.Call):
            assert isinstance(node.func,ast.Name) and node.func.id in {'log','ln','sqrt'} and len(node.args)==1 and not node.keywords,expression
            a=parse(node.args[0]);return math.sqrt(a) if node.func.id=='sqrt' else math.log(a)
        assert isinstance(node,ast.BinOp),expression
        a,b=parse(node.left),parse(node.right)
        if isinstance(node.op,ast.Add):r=a+b
        elif isinstance(node.op,ast.Sub):r=a-b
        elif isinstance(node.op,ast.Mult):r=a*b
        elif isinstance(node.op,ast.Div):r=a/b
        else:
            assert isinstance(node.op,ast.Pow) and float(b).is_integer() and abs(b)<=8,expression
            r=a**int(b)
        assert math.isfinite(r.real) and math.isfinite(r.imag),expression
        return r
    value=parse(tree.body);assert math.isfinite(value.real) and math.isfinite(value.imag),expression
    return value


def validate_linsolve(expression):
    matches=list(re.finditer(r'([xyz])\s*=\s*([^,{}]+)',expression))
    assert len(matches)==3 and {m[1]for m in matches}=={'x','y','z'},expression
    assert not re.sub(r'[{},\s]','',re.sub(r'([xyz])\s*=\s*([^,{}]+)','',expression)),expression
    assert {m[1]:scalar(m[2])for m in matches}=={'x':F(2),'y':F(1),'z':F(4)},expression


def validate_source_domain(domain):
    """Prove the exclusion -3 from either a root or polynomial condition."""
    simple=re.fullmatch(r'\s*x\s*(?:≠|!=)\s*(.+?)\s*',domain)
    if simple:
        assert scalar(simple[1])==F(-3),domain
        return
    condition=re.fullmatch(r'\s*(.*?)\s*(?:≠|!=)\s*0(?:\s*\((x\s*(?:≠|!=)\s*[^()]+)\))?\s*',domain)
    assert condition,domain
    if condition[2]:validate_source_domain(condition[2])
    coefficients=polynomial_coefficients(condition[1])
    assert 2<=len(coefficients)<=9,domain
    # A nonzero scalar times (x+3)^m has exactly the required excluded root.
    while len(coefficients)>1:
        quotient=[F(0)]*(len(coefficients)-1)
        quotient[-1]=coefficients[-1]
        for i in range(len(coefficients)-2,0,-1):quotient[i-1]=coefficients[i]-3*quotient[i]
        assert coefficients[0]-3*quotient[0]==0,domain
        coefficients=quotient
    assert coefficients[0]!=0,domain


def validate_result(case,line):
    name,source,(kind,expected)=case
    assert line.get('s')==source and not line.get('e'),(case,line)
    result=line.get('r');assert isinstance(result,str) and result and not re.search(r'\b(?:Error|NaN|Infinity|zoo|undefined)\b',result),(case,line)
    evidence=line.get('evidence') or {};free=set()
    if kind in {'multi','factor'}:
        assert multivariate_coefficients(result)==multivariate_coefficients(expected),(case,line)
        free={'x','y'}
        if kind=='factor':
            text=normalized(result);node=ast.parse(text,mode='eval').body
            assert isinstance(node,ast.BinOp) and isinstance(node.op,ast.Mult),(case,line)
            for part in [node.left,node.right]:
                coeff=multivariate_coefficients(ast.get_source_segment(text,part))
                assert max(map(sum,coeff))==2,(case,line)
    elif kind=='rational':
        rational_equal(result,expected);free={'x'}
        if name=='surviving-exclusion':
            domain=evidence.get('sourceDomain') or ''
            validate_source_domain(domain)
    elif kind=='self-power':
        text=normalized(result)
        text=re.sub(r'\bx\*\*x\b','a',text)
        text=re.sub(r'\b(?:log|ln)\(x\)','b',text)
        assert multivariate_coefficients(text)==multivariate_coefficients('a*(b+1)'),(case,line)
        free={'x'}
    elif kind=='poly':
        assert polynomial_coefficients(result)==[F(v)for v in expected],(case,line)
        free={'x'}
    elif kind=='roots':assert root_values(result)=={(F(v),F(0))for v in expected},(case,line)
    elif kind=='matrix':assert matrix_values(result)==tuple(tuple(F(v)for v in row)for row in expected),(case,line)
    elif kind=='complex':assert complex_components(result)==tuple(F(v)for v in expected),(case,line)
    elif kind=='imaginary-pi':imaginary_pi_value(result,expected)
    elif kind=='complex-constant':
        value=complex(real_constant(result,complex_mode=True))
        assert abs(value.real-expected[0])<=1e-12 and abs(value.imag-expected[1])<=1e-12,(case,line)
        if not re.search(r'\b(?:log|ln|pi)\b|π',result):assert evidence.get('accuracy')!='exact',(case,line)
    elif kind in {'pi','constant'}:
        ref=float(expected)*math.pi if kind=='pi' else expected
        if re.fullmatch(r'[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?',result):
            assert scalar(result)==F(f'{ref:.10g}') and evidence.get('accuracy')=='approximate',(case,line)
        else:assert abs(real_constant(result)-ref)<=1e-12*abs(ref),(case,line)
    else:
        assert kind=='scalar',(case,line)
        if re.search(r'\bI\b',result):
            assert complex_components(result)==(expected,F(0)),(case,line)
        elif evidence.get('accuracy')=='approximate':
            assert scalar(result)==F(f'{float(expected):.10g}'),(case,line)
        else:assert scalar(result)==expected,(case,line)
    assert set(line.get('f') or [])==free,(case,line)
    if evidence.get('method')=='numericFallback':assert evidence.get('accuracy')=='approximate',(case,line)
