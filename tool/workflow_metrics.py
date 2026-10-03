"""Pure helpers shared by workflow profiling and its unit tests."""
import math
import statistics


def summarize(samples):
    if not samples or any(not math.isfinite(value) or value < 0 for value in samples):
        raise ValueError('Expected finite, nonnegative measurements')
    ordered = sorted(samples)
    return {'samples': len(ordered), 'median_ms': statistics.median(ordered),
            'p95_ms': ordered[math.ceil(len(ordered) * .95) - 1], 'max_ms': ordered[-1]}


def large_document(rows):
    if rows < 1:
        raise ValueError('Document needs at least one row')
    return {'i': 'performance-doc', 'n': f'Performance {rows} rows',
            'c': '2026-10-01T00:00:00Z', 'u': '2026-10-01T00:00:00Z',
            'l': [{'i': f'line-{i}', 's': 'v0 = 1' if i == 0 else f'v{i} = v{i-1} + 1',
                   'r': str(i + 1)} for i in range(rows)]}
