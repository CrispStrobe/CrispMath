"""Independent fifth-audit problems entered through desktop/phone worksheets."""
import argparse
import asyncio
from fractions import Fraction
import math
import os
import re

import check_new_math_browser as controls

# Independently frozen round-five references: rational principal root 12/13;
# polynomial primitive x³+x²+x; ln(1+3x)'s first coefficient 3;
# function power integral [(x+1)³/3] gives 7/3 despite global x=6;
# cosine quadratic coefficient 9/2; substitution in squared denominator
# gives 1/4; conjugate multiplication gives 13.
controls.CASES = [
    ('exact-rational-root', 'sqrt(144/169)', '12/13'),
    ('mixed-polynomial-integral', 'integrate(3*x^2+2*x+1,x,-2,1)', '9'),
    ('scaled-logarithm-limit', 'limit(ln(1+3*x)/x,x,0)', '3'),
    ('global-function-x', 'x=6', '6'),
    ('function-template', 'g(t)=t+1', None),
    ('function-power-integral', 'integrate(g(x)^2,x,0,1)', '7/3'),
    ('triple-cosine-limit', 'limit((1-cos(3*x))/x^2,x,0)', '9/2'),
    ('squared-denominator-integral', 'integrate(x/(1+x^2)^2,x,0,1)', '1/4'),
    ('conjugate-product', '(3+2*I)*(3-2*I)', '13'),
    ('unit-name-bar', 'bar=7', '7'),
    ('unit-name-m', 'm=2', '2'),
    ('compound-pressure-bar', '1 kN/m^2 in bar', '0.01 bar'),
]

NUMERIC = re.compile(r'[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?(?:/\d+)?')


def validate_result(case, line):
    case_id, source, expected = case
    assert line.get('s') == source and not line.get('e'), (case, line)
    result = line.get('r')
    assert isinstance(result, str) and result, (case, line)
    if case_id == 'compound-pressure-bar':
        match = re.fullmatch(r'([+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)\s+bar', result)
        assert match and abs(float(match[1]) - 0.01) < 1e-10, (case, line)
        assert not line.get('f'), (case, line)
        assert (line.get('evidence') or {}).get('method') == 'unitConversion', (case, line)
        return
    if case_id == 'function-template':
        assert re.sub(r'\s+', '', result) in {'t+1', '1+t'}, (case, line)
        assert not line.get('f'), (case, line)
        return
    assert NUMERIC.fullmatch(result), (case, line)
    value, reference = float(Fraction(result)), float(Fraction(expected))
    assert math.isfinite(value) and abs(value - reference) < 1e-8, (case, line)
    if case_id == 'exact-rational-root':
        assert result == '12/13', (case, line)
    if 'integral' in case_id or 'limit' in case_id:
        assert not line.get('f'), (case, line)


controls.validate_result = validate_result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--output', default='browser-results/round5-math-ui')
    parser.add_argument('--expected-source', default=os.environ.get('EXPECTED_SOURCE'))
    asyncio.run(controls.check(parser.parse_args()))
