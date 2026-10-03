"""Independent fourth-audit problems entered through desktop/phone worksheets."""
import argparse
import asyncio
from fractions import Fraction
import math
import os
import re

import check_new_math_browser as controls

# References are derived before execution: a quarter's reciprocal square is 16;
# the square-root ratio is 7/11; u=x²+4 gives ln8-ln4=ln2; integrating exp(-2x)
# gives (1-exp(-2ln2))/2=3/8; tan(2x)'s cubic term is8x³/3; and a square
# centimetre is 10^-4 square metres, so 1000 N/m² = 0.1 N/cm².
# The shared harness types each expression into the real app, checks saved
# source/results and build provenance, reloads, and captures both screen sizes.
controls.CASES = [
    ('quarter-negative-square', '(0.25)^(-2)', '16'),
    ('square-root-rational-ratio', 'sqrt(49)/sqrt(121)', '7/11'),
    ('quadratic-logarithm-integral', 'integrate(2*x/(x^2+4),x,0,2)', None),
    ('global-limit-x', 'x=9', '9'),
    ('scaled-tangent-cubic-limit', 'limit((tan(2*x)-2*x)/x^3,x,0)', '8/3'),
    ('exponential-logarithmic-bound', 'integrate(exp(-2*x),x,0,ln(2))', '3/8'),
    ('unit-name-N', 'N=99', '99'),
    ('unit-name-cm', 'cm=2', '2'),
    ('pressure-square-centimetres', '1 kPa in N/cm^2', '0.1 N/cm²'),
]

NUMERIC = re.compile(r'[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?(?:/\d+)?')


def validate_result(case, line):
    case_id, source, expected = case
    assert line.get('s') == source and not line.get('e'), (case, line)
    result = line.get('r')
    assert isinstance(result, str) and result, (case, line)
    if case_id == 'pressure-square-centimetres':
        # Validate the target dimensions as well as the magnitude: a result
        # in N/cm, kPa or an unlabelled scalar does not satisfy this conversion.
        match = re.fullmatch(r'([+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)\s+N/cm²', result)
        assert match and abs(float(match[1]) - 0.1) < 1e-10, (case, line)
        assert not line.get('f'), (case, line)
        return

    if case_id == 'quadratic-logarithm-integral':
        if re.fullmatch(r'(?:ln|log)\(2\)', result):
            value = math.log(2)
        else:
            assert NUMERIC.fullmatch(result), (case, line)
            value = float(Fraction(result))
        reference = math.log(2)
    else:
        assert NUMERIC.fullmatch(result), (case, line)
        value = float(Fraction(result))
        reference = float(Fraction(expected))
    assert math.isfinite(value) and abs(value - reference) < 1e-8, (case, line)

    if case_id == 'quarter-negative-square':
        # This rational parser path has exact integer arithmetic evidence.
        assert result == '16', (case, line)
        assert (line.get('evidence') or {}).get('accuracy') == 'exact', (case, line)
    elif case_id == 'square-root-rational-ratio':
        # Demand the exact rational result without requiring the CAS to use
        # the rational frontend's accuracy classification.
        assert result == '7/11', (case, line)
    if ('integral' in case_id or case_id in {
            'exponential-logarithmic-bound', 'scaled-tangent-cubic-limit'}):
        # Dummy x belongs to the definite integral, not to the worksheet's
        # free-variable controls. Do not label numerical quadrature exact.
        assert not line.get('f'), (case, line)


controls.validate_result = validate_result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--output', default='browser-results/round4-math-ui')
    parser.add_argument('--expected-source', default=os.environ.get('EXPECTED_SOURCE'))
    asyncio.run(controls.check(parser.parse_args()))
