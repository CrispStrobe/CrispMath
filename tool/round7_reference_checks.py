"""Standard-library-only assertions for independently frozen round-seven math."""
import ast
from fractions import Fraction
import math
import re

TINY_ROOT = Fraction(1, 10**160)
CASES = [
    ('reciprocal-decimals', '1e308*1e-308', '1'),
    ('negative-divisor-remainder', '(-11)%(-4)', '1'),
    ('subnormal-exact-root', 'sqrt(1e-320)', TINY_ROOT),
    ('large-integer-determinant', 'det(Matrix([[9007199254740993,9007199254740994],[9007199254740994,9007199254740995]]))', '-1'),
    ('perturbed-decimal-determinant', 'det(Matrix([[1,1],[1,1.0000000000000001]]))', Fraction(1, 10**16)),
    ('singular-inverse', 'inv(Matrix([[1,2],[2,4]]))', 'Matrix inversion failed'),
    ('squared-log-endpoint', 'integrate(ln(x)^2,x,0,1)', '2'),
    ('real-log-domain', 'integrate(ln(1-x),x,0,2)', 'real integrand domain'),
    ('irrational-interior-poles', 'integrate(1/(x^4-2),x,-2,2)', 'divergent pole'),
    ('smooth-absolute-limit', 'limit((abs(x+1)-1)/x,x,0)', '1'),
    ('quadratic-root-limit', 'limit((sqrt(1+x)-1-x/2)/x^2,x,0)', '-1/8'),
    ('rationalized-infinite-limit', 'limit(sqrt(x^2+3*x)-x,x,oo)', '3/2'),
    ('cgs-energy', '10000000 erg in J', '1 J'),
    ('standard-atmosphere', '1 atm in bar', '1.01325 bar'),
    ('signed-force-distance', '-3 N * -2 m in J', '6 J'),
    ('frequency-cancellation', '2 Hz * 3 s', '6'),
    ('fahrenheit-fixed-point', '32 °F in K', '273.15 K'),
    ('mass-concentration', '1 g/L in kg/m³', '1 kg/m³'),
    ('nonlinear-local-taylor', 'series(abs(x^2-1),x,0,5)', [1, 0, -1]),
    ('shifted-rational-taylor', 'series(1/(1+x),x,1,4)', [Fraction(15,16), Fraction(-11,16), Fraction(5,16), Fraction(-1,16)]),
    ('complex-conjugate', 'conjugate((2+3*I)/(1-2*I))', [Fraction(-4,5), Fraction(-7,5)]),
    ('source-hole-root', 'solve((x-1)^2*(x+2)/(x-1),x)', '-2'),
    ('near-singular-inverse', 'inv(Matrix([[1,1],[1,1.0000000000000001]]))', [[10000000000000001, -10000000000000000], [-10000000000000000, 10000000000000000]]),
    ('principal-squared-root', 'sqrt((-3+4*I)^2)', '3-4*I'),
    ('reactive-parameter', 'p=1', '1'),
    ('formal-global-binding', 'x=9', '9'),
    ('reactive-nonlinear-taylor', 'taylor(abs(x^2-p),x,0,5)', [1, 0, -1]),
]

ERROR_CASES = {'singular-inverse', 'real-log-domain', 'irrational-interior-poles'}
EXACT_CASES = {'reciprocal-decimals', 'negative-divisor-remainder',
               'subnormal-exact-root', 'large-integer-determinant',
               'perturbed-decimal-determinant'}
UNIT_CASES = {'cgs-energy', 'standard-atmosphere', 'signed-force-distance',
              'frequency-cancellation', 'fahrenheit-fixed-point', 'mass-concentration'}


MAX_COEFFICIENT_BITS = 4096
MAX_LITERAL_EXPONENT = 1024


def bounded_fraction(literal):
    """Reject oversized scientific literals before Fraction allocates powers."""
    assert len(literal) <= 1024, 'Reference numeric literal exceeds length budget'
    assert re.fullmatch(r'[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?(?:/\d+)?',literal),literal
    exponent = re.search(r'[eE]([+-]?\d+)',literal)
    if exponent:
        digits=exponent[1].lstrip('+-').lstrip('0') or '0'
        assert len(digits)<=4 and abs(int(exponent[1]))<=MAX_LITERAL_EXPONENT, 'Reference scientific exponent exceeds budget'
    value=Fraction(literal)
    return bounded_coefficient(value)


def bounded_coefficient(value):
    assert value.numerator.bit_length()<=MAX_COEFFICIENT_BITS and value.denominator.bit_length()<=MAX_COEFFICIENT_BITS, 'Reference rational coefficient exceeds bit budget'
    return value


def bounded_add(left,right):
    """Preflight cross-products before constructing an exact rational sum."""
    common=math.gcd(left.denominator,right.denominator)
    left_scale=right.denominator//common
    right_scale=left.denominator//common
    assert max(left.numerator.bit_length()+left_scale.bit_length(),right.numerator.bit_length()+right_scale.bit_length())+1<=MAX_COEFFICIENT_BITS, 'Reference addition exceeds numerator budget'
    assert left.denominator.bit_length()+left_scale.bit_length()<=MAX_COEFFICIENT_BITS, 'Reference addition exceeds denominator budget'
    return bounded_coefficient(Fraction(left.numerator*left_scale+right.numerator*right_scale,left.denominator*left_scale))


def bounded_multiply(left,right):
    """Cancel first, then bound integer products before multiplication."""
    first=math.gcd(left.numerator,right.denominator)
    second=math.gcd(right.numerator,left.denominator)
    numerator_left,numerator_right=left.numerator//first,right.numerator//second
    denominator_left,denominator_right=left.denominator//second,right.denominator//first
    assert numerator_left.bit_length()+numerator_right.bit_length()<=MAX_COEFFICIENT_BITS, 'Reference multiplication exceeds numerator budget'
    assert denominator_left.bit_length()+denominator_right.bit_length()<=MAX_COEFFICIENT_BITS, 'Reference multiplication exceeds denominator budget'
    return bounded_coefficient(Fraction(numerator_left*numerator_right,denominator_left*denominator_right))


def bounded_divide(left,right):
    assert right, 'Reference division by zero'
    return bounded_multiply(left,Fraction(right.denominator,right.numerator))


def polynomial_coefficients(expression):
    """Parse only bounded rational polynomials, comparing every coefficient.

    No eval, numerical samples or discarded unknown terms can accept a false
    Taylor answer. Arithmetic on source literals uses exact Fractions.
    """
    text = re.sub(r'\s+', '', expression)
    text = re.sub(r'[⁰¹²³⁴⁵⁶⁷⁸⁹]+', lambda match: '^' + match[0].translate(
        str.maketrans('⁰¹²³⁴⁵⁶⁷⁸⁹', '0123456789')), text)
    text = text.replace('−', '-').replace('^', '**')
    # Insert only coefficient-to-variable multiplication; unknown names remain
    # invalid. Thus 1/16x³ means (1/16)*x³ without changing any denominator.
    text = re.sub(r'(?<=[0-9)])(?=x)', '*', text)
    assert len(text) <= 512, expression
    tree = ast.parse(text, mode='eval')
    assert sum(1 for _ in ast.walk(tree)) <= 100, expression

    def trim(coefficients):
        while len(coefficients) > 1 and coefficients[-1] == 0:
            coefficients.pop()
        assert len(coefficients) <= 9, expression
        return coefficients

    def multiply(left, right):
        assert len(left) + len(right) - 1 <= 9, expression
        result = [Fraction(0)] * (len(left) + len(right) - 1)
        for i, a in enumerate(left):
            for j, b in enumerate(right):
                result[i+j] = bounded_add(result[i+j],bounded_multiply(a,b))
        return trim(result)

    def parse(node):
        if isinstance(node, ast.Constant) and type(node.value) in {int, float}:
            literal = ast.get_source_segment(text, node)
            assert re.fullmatch(r'\d+(?:\.\d+)?(?:[eE][+-]?\d+)?', literal), expression
            return [bounded_fraction(literal)]
        if isinstance(node, ast.Name) and node.id == 'x':
            return [Fraction(0), Fraction(1)]
        if isinstance(node, ast.UnaryOp) and isinstance(node.op, (ast.UAdd, ast.USub)):
            values = parse(node.operand)
            return values if isinstance(node.op, ast.UAdd) else [-value for value in values]
        assert isinstance(node, ast.BinOp), expression
        left, right = parse(node.left), parse(node.right)
        if isinstance(node.op, (ast.Add, ast.Sub)):
            sign = 1 if isinstance(node.op, ast.Add) else -1
            return trim([bounded_add(left[i] if i < len(left) else Fraction(0), sign*(right[i] if i < len(right) else Fraction(0)))
                         for i in range(max(len(left), len(right)))])
        if isinstance(node.op, ast.Mult):
            return multiply(left, right)
        if isinstance(node.op, ast.Div):
            assert len(right) == 1 and right[0] != 0, expression
            return trim([bounded_divide(value,right[0]) for value in left])
        assert isinstance(node.op, ast.Pow) and len(right) == 1, expression
        exponent = right[0]
        assert exponent.denominator == 1 and 0 <= exponent <= 8, expression
        result = [Fraction(1)]
        for _ in range(int(exponent)):
            result = multiply(result, left)
        return result

    return trim(parse(tree.body))


def validate_result(case, line):
    case_id, source, expected = case
    assert line.get('s') == source, (case, line)
    if case_id in ERROR_CASES:
        actual_error = line.get('e') or line.get('r') or ''
        assert expected in actual_error and (line.get('e') or actual_error.startswith('Error')), (case, line)
        return
    assert not line.get('e'), (case, line)
    result = line.get('r')
    assert isinstance(result, str) and result and not result.startswith('Error'), (case, line)
    evidence = line.get('evidence') or {}
    if case_id == 'near-singular-inverse':
        tree = ast.parse(result, mode='eval').body
        assert isinstance(tree, ast.Call) and isinstance(tree.func, ast.Name) and tree.func.id == 'Matrix', (case, line)
        assert len(tree.args) == 1 and not tree.keywords and isinstance(tree.args[0], ast.List), (case, line)
        rows = tree.args[0].elts
        assert len(rows) == 2 and all(isinstance(row, ast.List) and len(row.elts) == 2 for row in rows), (case, line)
        actual = [[polynomial_coefficients(ast.get_source_segment(result, cell)) for cell in row.elts] for row in rows]
        assert actual == [[[Fraction(value)] for value in row] for row in expected], (case, line)
        assert evidence.get('accuracy') == 'exact', (case, line)
        assert not line.get('f'), (case, line)
        return
    if case_id == 'complex-conjugate':
        assert polynomial_coefficients(result.translate(str.maketrans({'I': 'x', 'i': 'x'}))) == expected, (case, line)
        assert not line.get('f'), (case, line)
        return
    if case_id == 'source-hole-root':
        root = re.fullmatch(r'x\s*=\s*\{?\s*(-?\d+(?:/\d+)?)\s*\}?', result)
        assert root and Fraction(root[1]) == -2, (case, line)
        assert not line.get('f'), (case, line)
        return
    if isinstance(expected, list):
        assert polynomial_coefficients(result) == [Fraction(value) for value in expected], (case, line)
        free = set() if case_id == 'reactive-nonlinear-taylor' else {'x'}
        assert set(line.get('f') or []) == free, (case, line)
        return
    if case_id == 'principal-squared-root':
        assert polynomial_coefficients(result.translate(str.maketrans({'I': 'x', 'i': 'x'}))) == [Fraction(3), Fraction(-4)], (case, line)
    else:
        expected_value = expected
        actual_value = result
        if case_id in UNIT_CASES:
            assert evidence.get('method') == 'unitConversion', (case, line)
            parts = str(expected).split(' ', 1)
            expected_value = parts[0]
            if len(parts) == 2:
                suffix = ' ' + parts[1]
                assert result.endswith(suffix), (case, line)
                actual_value = result[:-len(suffix)]
        actual_value = actual_value.strip()
        assert re.fullmatch(r'[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?(?:/\d+)?', actual_value), (case, line)
        assert bounded_fraction(actual_value) == Fraction(expected_value), (case, line)
    if case_id in EXACT_CASES:
        assert evidence.get('accuracy') == 'exact', (case, line)
    if case_id == 'squared-log-endpoint':
        assert evidence.get('method') == 'fundamentalTheorem', (case, line)
    if case_id.endswith('limit'):
        assert (evidence.get('method'), evidence.get('accuracy')) in {
            ('symbolicEvaluation', 'symbolic'), ('numericFallback', 'approximate')}, (case, line)
    assert not line.get('f'), (case, line)

