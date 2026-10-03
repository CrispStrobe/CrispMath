"""Independent frozen round-eight worksheet references; standard library only.

Values were chosen from 26c751eb before inspecting any app outputs. Polynomial,
complex and matrix comparisons retain every coefficient, shape and branch.
"""
import ast
from fractions import Fraction
import math
import re

from round7_reference_checks import polynomial_coefficients

CASES = [
    ('principal-root-product', 'sqrt(-9)*sqrt(-16)', '-12'),
    ('principal-imaginary-log', 'ln(-I)', ('pi-imaginary', Fraction(-1, 2))),
    ('negative-complex-power', '(1+I)^(-3)', ('complex', Fraction(-1,4), Fraction(-1,4))),
    ('cubic-conjugate', 'conjugate((1-I)^3)', ('complex', -2, 2)),
    ('conjugate-quotient-sum', '(2+I)/(2-I)+(2-I)/(2+I)', '6/5'),
    ('source-hole-surviving-root', 'solve((x^2-4)^2/(x+2),x)', ('roots', ((2, 0),))),
    ('source-hole-only-root', 'solve((x-3)^3/(x^2-9),x)', ('roots', ())),
    ('complex-quadratic-roots', 'solve(x^2-2*I*x-2,x)', ('roots', ((-1,1), (1,1)))),
    ('cubic-log-endpoint', 'integrate(ln(x)^3,x,0,1)', '-6'),
    ('irrational-cubic-pole', 'integrate(1/(x^3-x-1),x,1,2)', ('error', 'divergent pole')),
    ('removable-irrational-hole', 'integrate((x^2-3)/(x^2-3),x,1,2)', '1'),
    ('scaled-root-endpoint', 'integrate(1/sqrt(3*x),x,0,3)', '2'),
    ('shifted-log-endpoint', 'integrate(ln(1+2*x),x,-1/2,0)', '-1/2'),
    ('absolute-square-taylor', 'series(abs((x-1)^2),x,1,5)', ('polynomial', (1,-2,1))),
    ('negative-branch-taylor', 'series(abs(x^2-4*x+3),x,2,4)', ('polynomial', (-3,4,-1))),
    ('rationalized-large-limit', 'limit(sqrt(9*x^2+6*x+7)-3*x,x,oo)', '1'),
    ('bounded-oscillation-limit', 'limit(x^2*cos(1/x),x,0)', '0'),
    ('opposed-one-sided-limits', 'limit(abs(x-2)/(x-2),x,2)', ('error', 'left and right limits differ')),
    ('exponential-second-order-limit', 'limit((exp(2*x)-1-2*x)/x^2,x,0)', '2'),
    ('permutation-scaled-inverse', 'inv(Matrix([[0,2],[3,0]]))', ('matrix', ((0,Fraction(1,3)), (Fraction(1,2),0)))),
    ('cyclic-determinant', 'det(Matrix([[1,2,0],[0,1,2],[2,0,1]]))', '9'),
    ('jordan-square', 'Matrix([[1,1],[0,1]])^2', ('matrix', ((1,2), (0,1)))),
    ('nested-rational-powers', '(((-3)/2)^(-2))^(-1)', '9/4'),
    ('factorial-quotient', 'factorial(30)/factorial(29)', '30'),
    ('rational-radicand', 'sqrt(4/9+5/9)', '1'),
    ('signed-trace', 'trace(Matrix([[-2,1],[0,3]]))', '1'),
    ('four-dimensional-jordan-inverse', 'inv(Matrix([[1,1,0,0],[0,1,1,0],[0,0,1,1],[0,0,0,1]]))', ('matrix', ((1,-1,1,-1),(0,1,-1,1),(0,0,1,-1),(0,0,0,1)))),
    ('nilpotent-cube', 'Matrix([[0,1],[0,0]])^3', ('matrix', ((0,0),(0,0)))),
    ('permuted-rref', 'rref(Matrix([[0,1,0],[0,0,1],[1,0,0]]))', ('matrix', ((1,0,0),(0,1,0),(0,0,1)))),
    ('energy-time-power', '1 kWh / 1 h in kW', ('unit', '1', 'kW')),
    ('force-impulse', '1 N * 1 s in kg*m/s', ('unit', '1', 'kg*m/s')),
    ('area-volume', '1 m² * 1 m in L', ('unit', '1000', 'L')),
    ('specific-cgs-energy', '1 J / 2 kg in erg/g', ('unit', '5000', 'erg/g')),
    ('reactive-trace-parameter', 'a=2', '2'),
    ('reactive-trace', 'trace(Matrix([[a,1],[0,3]]))', '5'),
]
EXACT_CASES = {'nested-rational-powers', 'factorial-quotient', 'rational-radicand'}


def scalar(expression):
    values = polynomial_coefficients(expression)
    assert len(values) == 1, expression
    return values[0]


def complex_components(expression):
    assert not re.search(r'[xX]', expression), expression
    values = polynomial_coefficients(expression.translate(str.maketrans({'I':'x', 'i':'x'})))
    assert len(values) <= 2, expression
    return tuple(values + [Fraction(0)] * (2-len(values)))


def matrix_values(expression):
    assert len(expression) <= 4096, expression
    tree = ast.parse(expression, mode='eval')
    assert sum(1 for _ in ast.walk(tree)) <= 256, expression
    call = tree.body
    assert isinstance(call, ast.Call) and isinstance(call.func, ast.Name) and call.func.id == 'Matrix', expression
    assert len(call.args) == 1 and not call.keywords and isinstance(call.args[0], ast.List), expression
    rows = call.args[0].elts
    assert 1 <= len(rows) <= 4, expression
    assert all(isinstance(row, ast.List) and 1 <= len(row.elts) <= 4 for row in rows), expression
    assert len({len(row.elts) for row in rows}) == 1, expression
    return tuple(tuple(scalar(ast.get_source_segment(expression, cell)) for cell in row.elts) for row in rows)


def root_values(expression):
    match = re.fullmatch(r'x\s*=\s*(.+)', expression.strip())
    assert match, expression
    text = match[1].strip()
    if text == '(no solutions)':
        return set()
    if text.startswith('{'):
        assert text.endswith('}'), expression
        text = text[1:-1]
    else:
        assert '{' not in text and '}' not in text, expression
    parts = text.split(',')
    assert 1 <= len(parts) <= 4 and all(part.strip() for part in parts), expression
    values = [complex_components(part.strip()) for part in parts]
    assert len(set(values)) == len(values), expression
    return set(values)


def imaginary_pi_value(expression, coefficient):
    text = expression.replace('π', 'pi').replace('−', '-')
    if 'pi' in text:
        assert text.count('pi') == 1, expression
        text = re.sub(r'(?<=[0-9)])(?=pi)', '*', text)
        text = text.replace('piI', 'pi*I').replace('pii', 'pi*i')
        text = text.replace('pi', '(1)')
        assert complex_components(text) == (0, coefficient), expression
    else:
        real, imaginary = complex_components(text)
        assert real == 0 and abs(float(imaginary)-float(coefficient)*math.pi) <= 1e-12, expression


def validate_result(case, line):
    case_id, source, expected = case
    assert line.get('s') == source, (case, line)
    if isinstance(expected, tuple) and expected[0] == 'error':
        error = line.get('e') or line.get('r') or ''
        assert expected[1] in error and (line.get('e') or error.startswith('Error')), (case, line)
        return
    assert not line.get('e'), (case, line)
    result = line.get('r')
    assert isinstance(result, str) and result and not result.startswith('Error'), (case, line)
    evidence = line.get('evidence') or {}
    free = set()
    if isinstance(expected, tuple):
        kind = expected[0]
        if kind == 'complex':
            assert complex_components(result) == tuple(Fraction(v) for v in expected[1:]), (case, line)
        elif kind == 'pi-imaginary':
            imaginary_pi_value(result, expected[1])
        elif kind == 'polynomial':
            assert polynomial_coefficients(result) == [Fraction(v) for v in expected[1]], (case, line)
            free = {'x'}
        elif kind == 'matrix':
            assert matrix_values(result) == tuple(tuple(Fraction(v) for v in row) for row in expected[1]), (case, line)
        elif kind == 'roots':
            assert root_values(result) == {tuple(Fraction(v) for v in root) for root in expected[1]}, (case, line)
        elif kind == 'unit':
            suffix = ' ' + expected[2]
            assert result.endswith(suffix), (case, line)
            assert scalar(result[:-len(suffix)].strip()) == Fraction(expected[1]), (case, line)
            assert evidence.get('method') == 'unitConversion', (case, line)
        else:
            raise AssertionError(('Unknown independent reference', case))
    else:
        assert scalar(result) == Fraction(expected), (case, line)
    assert set(line.get('f') or []) == free, (case, line)
    if case_id in EXACT_CASES:
        assert evidence.get('accuracy') == 'exact', (case, line)
    if source.startswith('limit('):
        assert (evidence.get('method'), evidence.get('accuracy')) in {
            ('symbolicEvaluation', 'symbolic'), ('numericFallback', 'approximate')}, (case, line)
    if evidence.get('method') == 'numericFallback':
        assert evidence.get('accuracy') == 'approximate', (case, line)

NORMAL_CDF_INPUTS = {'mean μ':'2', 'stddev σ':'3', 'x for CDF':'0'}
NORMAL_CDF_DISPLAY = '0.252493'


def normal_cdf_display(nodes, width, height):
    """Read one actual merged result group or geometrically paired row.

    The screen rounds to six decimal places, so this checks display/routing;
    frozen worker references and module tests check the finer CDF accuracy.
    """
    label = 'CDF(x) = P(X ≤ x)'
    def visible(node):
        box = node['box']
        return (box['width'] > 0 and box['height'] > 0 and box['x'] >= 0 and
                box['y'] >= 140 and box['x']+box['width'] <= width+1 and
                box['y']+box['height'] <= height+1)
    groups = []
    for node in nodes:
        match = re.fullmatch(r'PDF\(x\)\s+[0-9.eE+-]+\s+'+re.escape(label)+
                             r'\s+([0-9.eE+-]+)\s+quantile\(p\)\s+[0-9.eE+-]+', node['text'])
        if match and visible(node):
            groups.append((match[1], node))
    if groups:
        assert len(groups) == 1, groups
        value, node = groups[0]
        assert value == NORMAL_CDF_DISPLAY, (value, node)
        return {'value':value, 'source':'single-rendered-result-group', 'group':node}
    labels = [node for node in nodes if node['text'] == label and visible(node)]
    assert len(labels) == 1, labels
    row = labels[0]['box']
    values = [node for node in nodes if re.fullmatch(r'[+-]?\d+(?:\.\d+)?', node['text']) and visible(node)
              and node['box']['x'] >= row['x']+row['width']-2
              and abs((node['box']['y']+node['box']['height']/2)-(row['y']+row['height']/2)) <= 2]
    assert len(values) == 1 and values[0]['text'] == NORMAL_CDF_DISPLAY, (labels, values)
    return {'value':values[0]['text'], 'source':'actual-ordered-row-geometry', 'label':labels[0], 'result':values[0]}
