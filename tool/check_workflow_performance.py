"""Reject material worksheet latency regressions against recorded release CI."""
import argparse
import json
import math
from pathlib import Path
from workflow_metrics import summarize


def measurements(report):
    if report.get('status') != 'passed' or report.get('trials', 0) < 3:
        raise ValueError('A successful report with at least three trials is required')
    values = {}
    for profile in report['profiles']:
        if profile['status'] != 'passed':
            raise ValueError('Every profile must pass')
        for document in profile['notepad']:
            samples = document['edit_to_saved_result_ms']
            if len(samples) < 3:
                raise ValueError('Each document needs at least three samples')
            key = (profile['profile'], profile['cpu'], document['rows'])
            if key in values:
                raise ValueError('Duplicate profile/document measurement')
            values[key] = summarize(samples)['median_ms']
    return values


def compare(report, baseline, factor=2.0, slack_ms=300.0):
    if not math.isfinite(factor) or factor < 1 or not math.isfinite(slack_ms) or slack_ms < 0:
        raise ValueError('Expected finite factor >= 1 and nonnegative slack')
    actual, previous = measurements(report), measurements(baseline)
    if actual.keys() != previous.keys():
        raise ValueError('Reports must cover the same profiles, CPU rates and row counts')
    checks = []
    for key, before in previous.items():
        limit = before * factor + slack_ms
        checks.append({'profile': key[0], 'cpu': key[1], 'rows': key[2],
                       'baselineMedianMs': before, 'medianMs': actual[key],
                       'limitMs': limit, 'passed': actual[key] <= limit})
    return {'source': report['source'], 'baselineSource': baseline['source'],
            'factor': factor, 'slackMs': slack_ms,
            'passed': all(check['passed'] for check in checks), 'checks': checks}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', required=True)
    parser.add_argument('--baseline', default=str(Path(__file__).with_name('notepad_performance_baseline.json')))
    parser.add_argument('--output', default='browser-results/notepad-performance-check.json')
    args = parser.parse_args()
    try:
        result = compare(json.loads(Path(args.report).read_text()),
                         json.loads(Path(args.baseline).read_text()))
    except (ValueError, KeyError, TypeError) as error:
        result = {'passed': False, 'error': str(error)}
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result))
    raise SystemExit(0 if result['passed'] else 1)
