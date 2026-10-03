"""Independent solve-scope controls entered through desktop/phone worksheets."""
import argparse
import asyncio
from fractions import Fraction
import math
import os
import re

import check_new_math_browser as controls

# Freeze scope references before execution: x²-1 has roots±1; the rational
# equation x-1=2(x+2) has root-5 (source excludes-2); 2x-6=0 has root3.
# Explicit solve variables are local even when a worksheet defines x=9.
controls.CASES = [
    ('quadratic-global-x', 'x=9', '9'),
    ('quadratic-local-solve', 'solve(x^2-1,x)', {-1, 1}),
    ('rational-local-solve', 'solve((x-1)/(x+2)-2,x)', {-5}),
    ('reactive-coefficient', 'a=2', '2'),
    ('linear-global-x', 'x=9', '9'),
    ('linear-local-solve', 'solve(a*x-6,x)', {3}),
    ('calculus-global-x', 'x=9', '9'),
    ('formal-derivative', 'diff(x^3,x)', '3*x^2'),
    ('formal-antiderivative', 'integrate(x^2,x)', 'x^3/3+C'),
]
NUMERIC = re.compile(r'[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?(?:/\d+)?')


def validate_result(case, line):
    case_id, source, expected = case
    assert line.get('s') == source and not line.get('e'), (case, line)
    result = line.get('r')
    assert isinstance(result, str) and result, (case, line)
    if case_id in {'formal-derivative', 'formal-antiderivative'}:
        expression = re.sub(r'\s+', '', result).replace('**', '^').replace('²', '^2').replace('³', '^3')
        if case_id == 'formal-derivative':
            assert re.fullmatch(r'3\*?x\^2', expression), (case, line)
        else:
            term = r'(?:(?:x\^3|\(x\^3\))/3|(?:1/3|\(1/3\))\*x\^3)'
            assert re.fullmatch(rf'(?:{term}\+C|C\+{term})', expression), (case, line)
        assert not line.get('f'), (case, line)
        return
    if isinstance(expected, set):
        match = re.fullmatch(r'x\s*=\s*(\{[^{}]+\}|[^{}]+)', result.strip())
        assert match, (case, line)
        text = match[1].strip()
        if text.startswith('{'):
            text = text[1:-1]
        parts = [part.strip() for part in text.split(',')]
        assert all(NUMERIC.fullmatch(part) for part in parts), (case, line)
        values = {float(Fraction(part)) for part in parts}
        assert len(parts) == len(expected) == len(values), (case, line)
        assert all(any(abs(actual-ref) < 1e-10 for actual in values)
                   for ref in expected), (case, line)
        assert not line.get('f'), (case, line)
    else:
        assert result == expected, (case, line)


controls.validate_result = validate_result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--output', default='browser-results/round5-solve-ui')
    parser.add_argument('--expected-source', default=os.environ.get('EXPECTED_SOURCE'))
    asyncio.run(controls.check(parser.parse_args()))
