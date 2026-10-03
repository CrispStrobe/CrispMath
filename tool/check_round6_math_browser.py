"""Sixth audit regressions entered through actual desktop and phone worksheets."""
import argparse
import asyncio
from fractions import Fraction
import math
import os
import re

import check_new_math_browser as controls

controls.CASES = [
    ('floor-negative', 'floor(-7/3)', '-3'),
    ('ceiling-negative', 'ceiling(-7/3)', '-2'),
    ('floor-large', 'floor(9007199254740993.9)', '9007199254740993'),
    ('unit-name-deg', 'deg=7', '7'),
    ('degree-conversion', '180 deg in rad', str(math.pi)),
    ('specific-energy', '1 Wh/kg in J/kg', '3600'),
    ('multivariate-cancellation', 'simplify((x^2-y^2)/(x-y))', None),
    ('inverse-root-endpoint', 'integrate(1/sqrt(x),x,0,1)', '2'),
    ('log-endpoint', 'integrate(ln(x),x,0,1)', '-1'),
    ('squeezed-limit', 'limit(x*sin(1/x),x,0)', '0'),
    ('unequal-limits', 'limit(abs(x)/x,x,0)', 'left and right limits differ'),
    ('divergent-endpoint', 'integrate(1/x,x,-1,0)', 'divergent pole'),
    ('taylor-positive', 'series(abs(x),x,2,3)', 'x'),
    ('taylor-negative', 'series(abs(x),x,-2,3)', '-x'),
    ('taylor-product', 'series(x*abs(x),x,-2,3)', '-x^2'),
]


def validate_result(case, line):
    case_id, source, expected = case
    assert line.get('s') == source, (case, line)
    if case_id in {'unequal-limits', 'divergent-endpoint'}:
        error = line.get('e') or line.get('r') or ''
        assert expected in error and ('Error' in error or line.get('e')), (case, line)
        return
    assert not line.get('e'), (case, line)
    result = line.get('r')
    assert isinstance(result, str) and result and not result.startswith('Error'), (case, line)
    evidence = line.get('evidence') or {}
    if case_id.startswith('taylor-'):
        polynomial = re.sub(r'\s+', '', result).replace('**', '^').replace('²', '^2')
        assert polynomial == expected, (case, line)
        assert set(line.get('f') or []) == {'x'}, (case, line)
        return
    if case_id == 'multivariate-cancellation':
        assert re.sub(r'\s+', '', result) in {'x+y', 'y+x'}, (case, line)
        domain = evidence.get('sourceDomain') or ''
        assert 'x' in domain and 'y' in domain and ('≠' in domain or '!=' in domain), (case, line)
        assert set(line.get('f') or []) == {'x', 'y'}, (case, line)
        return
    if case_id in {'degree-conversion', 'specific-energy'}:
        unit = 'rad' if case_id == 'degree-conversion' else 'J/kg'
        assert result.endswith(' ' + unit), (case, line)
        value = float(result[:-len(unit)].strip())
        assert abs(value - float(expected)) < 1e-9, (case, line)
        assert evidence.get('method') == 'unitConversion', (case, line)
    else:
        assert re.fullmatch(r'[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?(?:/\d+)?', result), (case, line)
        assert Fraction(result) == Fraction(expected), (case, line)
    if case_id.startswith(('floor', 'ceiling')):
        assert result == expected and evidence.get('accuracy') == 'exact', (case, line)
    if case_id.endswith('endpoint'):
        assert evidence.get('method') == 'fundamentalTheorem', (case, line)
    if case_id == 'squeezed-limit':
        assert evidence.get('accuracy') == 'symbolic', (case, line)
    assert not line.get('f'), (case, line)


controls.validate_result = validate_result

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--output', default='browser-results/round6-math-ui')
    parser.add_argument('--expected-source', default=os.environ.get('EXPECTED_SOURCE'))
    asyncio.run(controls.check(parser.parse_args()))
