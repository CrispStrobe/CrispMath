"""Fresh real worksheet controls for the third independent math audit."""
import argparse
import asyncio
from fractions import Fraction
import os
import re

import check_new_math_browser as controls

# Independently derived references; use actual typing, persistence and reload.
controls.CASES = [
    ('rational-difference-ratio', '(7/12-5/18)/(11/36)', '1'),
    ('translated-polynomial-integral', 'integrate((x-2)^2,x,1,3)', '2/3'),
    ('reversed-linear-integral', 'integrate(x,x,3,-1)', '-4'),
    ('negative-real-cube-root', 'cbrt(-8)', '-2'),
    ('microlitre-prefix', '50 μL in mL', '0.05 mL'),
    ('rationalized-square-root-limit', 'limit((sqrt(4+x)-2)/x,x,0)', '1/4'),
]


def validate_result(case, line):
    assert line.get('s') == case[1] and not line.get('e'), (case, line)
    result = line.get('r', '')
    if case[0] == 'microlitre-prefix':
        match = re.fullmatch(r'([+-]?\d+(?:\.\d+)?)\s+mL', result)
        assert match and abs(float(match[1]) - 0.05) < 1e-10, (case, line)
    else:
        assert re.fullmatch(r'[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?(?:/\d+)?', result), (case, line)
        assert abs(float(Fraction(result)) - float(Fraction(case[2]))) < 1e-8, (case, line)
    if case[0] in {'rational-difference-ratio', 'translated-polynomial-integral',
                   'reversed-linear-integral'}:
        assert (line.get('evidence') or {}).get('accuracy') == 'exact', (case, line)
    if 'integral' in case[0]:
        assert not line.get('f'), (case, line)


controls.validate_result = validate_result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--output', default='browser-results/round3-math-ui')
    parser.add_argument('--expected-source', default=os.environ.get('EXPECTED_SOURCE'))
    asyncio.run(controls.check(parser.parse_args()))
