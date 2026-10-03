"""Stdlib-only controls for independently frozen ninth-audit references."""
import ast
from fractions import Fraction
import math
import re

from round7_reference_checks import bounded_add, bounded_multiply, bounded_divide
from round8_reference_checks import complex_components, matrix_values, root_values, scalar
from statistics_ui_reference_checks import rendered_rows

CASES = [
    ('log-winding', 'ln(-2)+ln(-3)-ln(6)', ('pi-imaginary',2)),
    ('complex-reciprocal', '(3+4*I)^(-1)', ('complex',Fraction(3,25),Fraction(-4,25))),
    ('conjugate-reciprocal-square', 'conjugate(1/(1+2*I)^2)', ('complex',Fraction(-3,25),Fraction(4,25))),
    ('opposed-root-phases', 'sqrt(-I)*sqrt(I)', '1'),
    ('principal-rational-power', '(-1)^(2/3)', ('radical-imaginary',Fraction(-1,2),Fraction(1,2))),
    ('nonmonic-gaussian-roots', 'solve((1+I)*x^2+(-2+I)*x+(1-2*I),x)', ('roots',((1,0),(Fraction(-1,2),Fraction(-3,2))))),
    ('multiplicity-source-hole', 'solve((x^2-1)^3/(x^2+2*x+1),x)', ('roots',((1,0),))),
    ('nonzero-rational-equation', 'solve(x^2/(x^2+1)=1/2,x)', ('roots',((-1,0),(1,0)))),
    ('all-source-hole-roots', 'solve((x-1)/(x-1),x)', ('roots',())),
    ('fourth-log-moment', 'integrate(ln(2*x)^4,x,0,1/2)', '12'),
    ('upper-root-endpoint', 'integrate(1/sqrt(1-x),x,0,1)', '2'),
    ('cancelled-odd-integral', 'integrate((x^3-x)/(x^2-1),x,-2,2)', '0'),
    ('repeated-irrational-pole', 'integrate(1/(x^2-2)^2,x,0,2)', ('error','divergent pole')),
    ('cubic-absolute-two-derivatives', 'series(abs((x+1)^3),x,-1,3)', '0'),
    ('cubic-absolute-missing-third-derivative', 'series(abs((x+1)^3),x,-1,4)', ('error','does not exist')),
    ('transcendental-taylor-center', 'series(exp(x),x,ln(2),3)', ('log-polynomial',)),
    ('negative-infinity-addition', 'limit(sqrt(4*x^2-12*x+5)+2*x,x,-oo)', '3'),
    ('shifted-oscillation-envelope', 'limit((x-3)^2*sin(1/(x-3)),x,3)', '0'),
    ('logarithmic-composition-limit', 'limit(ln(1+x^2)/x^2,x,0)', '1'),
    ('rectangular-leading-zero-rref', 'rref(Matrix([[0,1,2,3],[0,2,4,6],[1,0,1,2]]))', ('matrix',((1,0,1,2),(0,1,2,3),(0,0,0,0)))),
    ('odd-skew-determinant', 'det(Matrix([[0,2,-3],[-2,0,4],[3,-4,0]]))', '0'),
    ('unimodular-integer-inverse', 'inv(Matrix([[1,2],[3,7]]))', ('matrix',((7,-2),(-3,1)))),
    ('harmonic-reciprocal', '1/(1/7+1/11)', '77/18'),
    ('signed-power-cancellation', '(-2)^15+2^15', '0'),
    ('mixed-determinant', 'det(Matrix([[2,3,1],[4,1,-3],[-2,5,2]]))', '50'),
    ('symmetric-unimodular-inverse', 'inv(Matrix([[2,1],[1,1]]))', ('matrix',((1,-1),(-1,2)))),
    ('noncommuting-shears', 'Matrix([[1,2],[0,1]])*Matrix([[1,0],[3,1]])', ('matrix',((7,2),(3,1)))),
    ('rational-square-root', 'sqrt(81/121)', '9/11'),
    ('atmosphere-pressure-work', '1 atm * 1 L in J', ('unit','101.325','J')),
    ('cgs-force', '1 erg / 1 cm in N', ('unit','0.00001','N')),
    ('ohm-prefix-cancellation', '1 mA * 1 kΩ in V', ('unit','1','V')),
    ('coherent-density', '1 kg / 1 L in g/cm³', ('unit','1','g/cm³')),
    ('specific-energy-identity', '1 m² / 1 s² in J/kg', ('unit','1','J/kg')),
]
EXACT_CASES = {'harmonic-reciprocal','signed-power-cancellation','mixed-determinant','rational-square-root'}
TAYLOR_EXPECTED = {(0,0):Fraction(2),(1,0):Fraction(2),(0,1):Fraction(-2),
                   (2,0):Fraction(1),(1,1):Fraction(-2),(0,2):Fraction(1)}


def log_polynomial(expression):
    """Bounded exact bivariate polynomial in x and the constant ln(2).

    Only exp(ln(2))=2 is reduced; arbitrary exp/functions stay rejected.
    Native CAS log(2) denotes the same natural logarithm in display strings.
    """
    text = re.sub(r'\s+','',expression).replace('−','-')
    text = re.sub(r'[⁰¹²³⁴⁵⁶⁷⁸⁹]+',lambda m:'^'+m[0].translate(str.maketrans('⁰¹²³⁴⁵⁶⁷⁸⁹','0123456789')),text)
    text = text.replace('^','**')
    text = re.sub(r'(?<=[0-9)])(?=x)','*',text)
    assert len(text)<=1024,expression
    tree=ast.parse(text,mode='eval')
    assert sum(1 for _ in ast.walk(tree))<=180,expression
    def trim(poly):
        result={key:value for key,value in poly.items() if value}
        assert len(result)<=45 and all(sum(key)<=8 for key in result),expression
        return result
    def mul(left,right):
        result={}
        for (a,b),v in left.items():
            for (c,d),w in right.items():
                key=(a+c,b+d)
                assert sum(key)<=8,expression
                result[key]=bounded_add(result.get(key,Fraction(0)),bounded_multiply(v,w))
        return trim(result)
    def is_log_two(node):
        return (isinstance(node,ast.Call) and isinstance(node.func,ast.Name) and node.func.id in {'ln','log'}
                and len(node.args)==1 and not node.keywords and
                isinstance(node.args[0],ast.Constant) and type(node.args[0].value) in {int,float}
                and scalar(ast.get_source_segment(text,node.args[0]))==2)
    def parse(node):
        if isinstance(node,ast.Constant) and type(node.value) in {int,float}:
            return trim({(0,0):scalar(ast.get_source_segment(text,node))})
        if isinstance(node,ast.Name) and node.id=='x':
            return {(1,0):Fraction(1)}
        if is_log_two(node):
            return {(0,1):Fraction(1)}
        if (isinstance(node,ast.Call) and isinstance(node.func,ast.Name) and node.func.id=='exp'
                and len(node.args)==1 and not node.keywords and is_log_two(node.args[0])):
            return {(0,0):Fraction(2)}
        if isinstance(node,ast.UnaryOp) and isinstance(node.op,(ast.UAdd,ast.USub)):
            value=parse(node.operand)
            return value if isinstance(node.op,ast.UAdd) else {k:-v for k,v in value.items()}
        assert isinstance(node,ast.BinOp),expression
        left,right=parse(node.left),parse(node.right)
        if isinstance(node.op,(ast.Add,ast.Sub)):
            result=dict(left)
            sign=1 if isinstance(node.op,ast.Add) else -1
            for key,value in right.items():result[key]=bounded_add(result.get(key,Fraction(0)),sign*value)
            return trim(result)
        if isinstance(node.op,ast.Mult):return mul(left,right)
        if isinstance(node.op,ast.Div):
            assert set(right)=={(0,0)} and right[(0,0)],expression
            return trim({key:bounded_divide(value,right[(0,0)]) for key,value in left.items()})
        assert isinstance(node.op,ast.Pow) and set(right)<={(0,0)},expression
        exponent=right.get((0,0),Fraction(0))
        assert exponent.denominator==1 and 0<=exponent<=8,expression
        result={(0,0):Fraction(1)}
        for _ in range(int(exponent)):result=mul(result,left)
        return result
    return trim(parse(tree.body))


def validate_result(case,line):
    name,source,expected=case
    assert line.get('s')==source,(case,line)
    if isinstance(expected,tuple) and expected[0]=='error':
        error=line.get('e') or line.get('r') or ''
        assert expected[1] in error and (line.get('e') or error.startswith('Error')),(case,line)
        return
    assert not line.get('e'),(case,line)
    result=line.get('r')
    assert isinstance(result,str) and result and not result.startswith('Error'),(case,line)
    evidence=line.get('evidence') or {}
    free=set()
    if isinstance(expected,tuple):
        kind=expected[0]
        if kind=='complex':
            assert complex_components(result)==tuple(Fraction(v) for v in expected[1:]),(case,line)
        elif kind=='pi-imaginary':
            if 'pi' in result or 'π' in result:
                from round8_reference_checks import imaginary_pi_value
                imaginary_pi_value(result,Fraction(expected[1]))
            else:
                real,imag=complex_components(result)
                assert abs(float(real))<=1e-12 and abs(float(imag)-expected[1]*math.pi)<=1e-12,(case,line)
                assert evidence.get('accuracy')!='exact',(case,line)
        elif kind=='radical-imaginary':
            normalized=re.sub(r'sqrt\(3\)|√3',str(math.sqrt(3)),result)
            real,imag=complex_components(normalized)
            assert real==expected[1] and abs(float(imag)-float(expected[2])*math.sqrt(3))<=1e-12,(case,line)
            if normalized==result:
                assert evidence.get('accuracy')!='exact',(case,line)
        elif kind=='roots':
            assert root_values(result)=={tuple(Fraction(v) for v in root) for root in expected[1]},(case,line)
        elif kind=='matrix':
            assert matrix_values(result)==tuple(tuple(Fraction(v) for v in row) for row in expected[1]),(case,line)
        elif kind=='log-polynomial':
            assert log_polynomial(result)==TAYLOR_EXPECTED,(case,line)
            free={'x'}
        elif kind=='unit':
            suffix=' '+expected[2]
            assert result.endswith(suffix) and scalar(result[:-len(suffix)].strip())==Fraction(expected[1]),(case,line)
            assert evidence.get('method')=='unitConversion',(case,line)
        else:raise AssertionError(('Unknown frozen reference',case))
    else:assert scalar(result)==Fraction(expected),(case,line)
    assert set(line.get('f') or [])==free,(case,line)
    if name in EXACT_CASES:assert evidence.get('accuracy')=='exact',(case,line)
    if source.startswith('limit('):
        assert (evidence.get('method'),evidence.get('accuracy')) in {
            ('symbolicEvaluation','symbolic'),('numericFallback','approximate')},(case,line)


STATISTICS_CASES = [
    ('subvariance-underflow','1e-200, 2e-200, 3e-200',
     {'Count':'3','Mean':'2.0000e-200','Median':'2.0000e-200','Std. deviation (n−1)':'1.0000e-200'}),
    ('variance-overflow','1e200, 2e200, 3e200',
     {'Count':'3','Mean':'2.0000e+200','Median':'2.0000e+200','Std. deviation (n−1)':'1.0000e+200'}),
]
CONSTRAINT_PROGRAM = 'vars: x, y in -3..3\nx+y == 0\nminimize (x-2)*(x-2)+(y+1)*(y+1)'


def validate_statistics(text,expected):
    rows=rendered_rows(text)
    for label,value in expected.items():assert rows[label]['value']==value,(label,rows,value)
    return rows


def validate_optimum(header,assignment):
    match=re.fullmatch(r'Optimal: objective =\s*([+-]?\d+(?:\.\d+)?)',header.strip())
    assert match and Fraction(match[1])==1,header
    parts=assignment.split(',')
    assert len(parts)==2,assignment
    values={}
    for part in parts:
        match=re.fullmatch(r'\s*([xy])\s*=\s*(-?\d+)\s*',part)
        assert match and match[1] not in values,assignment
        values[match[1]]=int(match[2])
    assert set(values)=={'x','y'},assignment
    x,y=values['x'],values['y']
    assert (x,y) in {(1,-1),(2,-2)} and x+y==0 and (x-2)**2+(y+1)**2==1,assignment
    return {'objective':1,'x':x,'y':y}
