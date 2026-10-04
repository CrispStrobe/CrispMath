"""Check frozen round-eleven math through actual desktop and phone input."""
import argparse
import asyncio
import os
import json
from pathlib import Path

import check_new_math_browser as controls
import check_round10_math_browser as calculator_controls
from round11_algebra_reference_checks import (CASES as ALGEBRA_CASES,
                                              validate_result as validate_algebra,
                                              LINSOLVE_SOURCE, validate_linsolve)


async def check(args):
    failures=[]
    async def stage(name, operation):
        try:
            await operation()
        except Exception as error:
            failures.append({'stage':name,'error':repr(error)})
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
    assert len({case[0]for case in cases})==len(cases),'Independent case IDs must be distinct'
    def validate(case,line):
        if case[0] in algebra_names:validate_algebra(case,line)
        else:numeric_validator(case,line)
    controls.CASES=cases
    controls.validate_result=validate
    controls.AFTER_ENTRY=None
    await stage('worksheet',lambda:controls.check(args))
    calculator_controls.LINSOLVE_SOURCE=LINSOLVE_SOURCE
    calculator_controls.validate_linsolve=validate_linsolve
    await stage('linear-system-calculator',lambda:calculator_controls.check_calculator(args))
    if numeric_modules is not None:
        await stage('compact-descriptive-and-optima',lambda:numeric_modules(args))
        report_path=Path(args.output)/'modules'/'report.json'
        report=json.loads(report_path.read_text())
        report['coverage']='round11: two compact descriptive samples and two integer optima'
        report['precisionNote']='Complete descriptive values are checked separately in additional-modules; these compact rows follow the display contract.'
        report_path.write_text(json.dumps(report,indent=2)+'\n')
    if numeric_modules is not None:
        from check_round11_modules_browser import check_modules
        await stage('complete-additional-modules',lambda:check_modules(args))
    summary={'passed':not failures,'toolSource':os.environ.get('GITHUB_SHA'),
             'failures':failures,'coverage':'Separate actual worksheet, linear system, descriptive/optima, and remaining module reports provide measured coverage.'}
    (Path(args.output)/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
    assert not failures,failures


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--algebra-only',action='store_true',help='Diagnostic subset; full audit also runs numeric modules')
    parser.add_argument('--url',default='http://127.0.0.1:8766/')
    parser.add_argument('--output',default='browser-results/round11-math-ui')
    parser.add_argument('--expected-source',default=os.environ.get('EXPECTED_SOURCE'))
    asyncio.run(check(parser.parse_args()))
