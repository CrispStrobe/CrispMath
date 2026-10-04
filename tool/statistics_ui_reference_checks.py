"""Strict standard-library checks for actual rendered statistics rows."""
import re

def rendered_rows(text):
    """Parse the actual merged StatsTable semantics with explicit row bounds."""
    number = r'(?:[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?|Infinity|-Infinity|Undefined|NaN)'
    successors = {'Count': 'Sum', 'Mean': 'Median', 'Median': 'Mode',
                  'Std. deviation (n−1)': 'Variance (n)'}
    rows = {}
    for label, successor in successors.items():
        pattern = rf'(?:^|\s){re.escape(label)}\s+({number})\s+{re.escape(successor)}(?:\s|$)'
        matches = re.findall(pattern, text)
        assert len(matches) == 1, (label, text, matches)
        rows[label] = {'label': label, 'value': matches[0],
                       'nextRowLabel': successor}
    return rows


def hypothesis_rows(text, successors):
    number = r'(?:[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?|Infinity|-Infinity|Undefined|NaN)'
    rows = {}
    for label, successor in successors.items():
        matches = re.findall(rf'(?:^|\s){re.escape(label)}\s+({number})\s+{re.escape(successor)}(?:\s|$)', text)
        assert len(matches) == 1, (label, text, matches)
        rows[label] = {'label': label, 'value': matches[0], 'nextRowLabel': successor}
    return rows
