"""Second independent audit controls entered through actual desktop/phone UI."""
import argparse
import asyncio
import os

import check_new_math_browser as controls

# Independently derived exact values. Reuse typing, persistence, reload, source
# verification and screenshot capture; no script writes calculated results.
controls.CASES = [
    ('odd-negative-reciprocal', '(-2)^(-5)', '-1/32'),
    ('rational-sum-divided', '(1/3+1/7)/(2/21)', '5'),
    ('large-identical-quotient', '(10^24+3)/(10^24+3)', '1'),
    ('absolute-fraction-partition', 'abs(-5/12)+abs(-7/12)', '1'),
    ('decimal-negative-power', '(0.125+0.375)^(-2)', '4'),
    ('negative-base-power-chain', '(-3)^2^3', '6561'),
    ('fraction-cube', '(1-1/3)^3', '8/27'),
    ('reciprocal-power-chain', '3^(-2)^2', '81'),
]

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--output', default='browser-results/round2-math-ui')
    parser.add_argument('--expected-source', default=os.environ.get('EXPECTED_SOURCE'))
    asyncio.run(controls.check(parser.parse_args()))
