"""Check frozen round-eleven math through actual desktop and phone input."""
import argparse
import asyncio
import os

import check_new_math_browser as controls
import check_round10_math_browser as calculator_controls
from round11_algebra_reference_checks import (CASES as ALGEBRA_CASES,
                                              validate_result as validate_algebra,
                                              LINSOLVE_SOURCE, validate_linsolve)


async def check(args):
    cases=list(ALGEBRA_CASES)
    numeric_validator=None
    numeric_modules=None
    if not args.algebra_only:
        from round11_numeric_reference_checks import (CASES as NUMERIC_CASES,
                                                     validate_result,
                                                     check_modules)
        cases.extend(NUMERIC_CASES)
        numeric_validator=validate_result
        numeric_modules=check_modules
    algebra_names={case[0]for case in ALGEBRA_CASES}
    def validate(case,line):
        if case[0] in algebra_names:validate_algebra(case,line)
        else:numeric_validator(case,line)
    controls.CASES=cases
    controls.validate_result=validate
    controls.AFTER_ENTRY=None
    await controls.check(args)
    calculator_controls.LINSOLVE_SOURCE=LINSOLVE_SOURCE
    calculator_controls.validate_linsolve=validate_linsolve
    await calculator_controls.check_calculator(args)
    if numeric_modules is not None:await numeric_modules(args)


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--algebra-only',action='store_true',help='Diagnostic subset; full audit also runs numeric modules')
    parser.add_argument('--url',default='http://127.0.0.1:8766/')
    parser.add_argument('--output',default='browser-results/round11-math-ui')
    parser.add_argument('--expected-source',default=os.environ.get('EXPECTED_SOURCE'))
    asyncio.run(check(parser.parse_args()))
