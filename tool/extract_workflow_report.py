"""Extract the packaged app's strict audit report from native startup logs."""
import argparse
import json
from pathlib import Path
import re

BEGIN = 'CRISPMATH_WORKFLOW_REPORT_BEGIN'
END = 'CRISPMATH_WORKFLOW_REPORT_END'

def extract(text):
    matches = re.findall(r'^'+BEGIN+r'\r?\n(.*?)^'+END+r'\r?$', text, re.M | re.S)
    if len(matches) != 1 or text.count(BEGIN) != 1 or text.count(END) != 1:
        raise ValueError('Expected one complete packaged workflow report')
    report = json.loads(matches[0])
    if not isinstance(report, dict) or report.get('schemaVersion') != 2:
        raise ValueError('Unexpected workflow report schema')
    return report

def verify(report, expected_count=50):
    results = report.get('results', [])
    if report.get('nativeBridge') is not True:
        raise ValueError('The packaged native bridge is unavailable')
    if (report.get('total') != expected_count or len(results) != expected_count
            or report.get('passed') != expected_count or report.get('failed') != 0
            or report.get('unsupported') != 0
            or any(row.get('status') != 'passed' for row in results)
            or len({row.get('id') for row in results}) != expected_count):
        raise ValueError('The packaged workflow audit did not pass every task')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--log', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--expected-count', type=int, default=50)
    args = parser.parse_args()
    report = extract(args.log.read_text())
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2)+'\n')
    verify(report, args.expected_count)
    print(f"Packaged native audit: {report['passed']}/{report['total']} passed")
