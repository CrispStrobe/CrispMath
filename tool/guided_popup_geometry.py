"""Require a unique, unobscured popup item to stop moving before a real click."""
import math


def stable_popup_window(samples, minimum_ms=250):
    if not samples:
        return False
    latest = samples[-1]
    def valid(sample):
        return (sample.get('count') == 1 and sample.get('ready') is True
                and all(math.isfinite(sample.get(key, float('nan')))
                        for key in ['x', 'y', 'width', 'height', 'timeMs']))
    if not valid(latest):
        return False
    earliest = latest
    for sample in reversed(samples[:-1]):
        if not valid(sample) or any(abs(sample[key] - latest[key]) > .25
                                   for key in ['x', 'y', 'width', 'height']):
            break
        earliest = sample
    return latest['timeMs'] - earliest['timeMs'] >= minimum_ms
