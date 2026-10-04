"""Compare the patched real decoder input path against independent LayerNorm math.

Reference: https://docs.pytorch.org/docs/stable/generated/torch.nn.LayerNorm.html
LayerNorm uses biased variance and epsilon 1e-5, with learned affine parameters.
This is a hosted diagnostic, not an application library or model replacement.
"""
import argparse
import ctypes
import hashlib
import json
from pathlib import Path


def check(library):
    import numpy as np
    native = ctypes.CDLL(str(Path(library).resolve()))
    probe = native.crispembed_posformer_input_norm_probe
    pointer = ctypes.POINTER(ctypes.c_float)
    probe.argtypes = [pointer] * 7 + [ctypes.c_int]
    probe.restype = ctypes.c_int
    rows = []
    for dimension in (256, 384):
        arrays = [np.asarray(value, dtype=np.float32) for value in (
            np.linspace(-3, 3, dimension), np.sin(np.arange(dimension) * .37) * 2,
            np.linspace(.5, 1.5, dimension), np.linspace(-.7, .4, dimension),
            np.linspace(1.7, .3, dimension), np.cos(np.arange(dimension) * .23) * .2)]
        output = np.zeros(dimension, dtype=np.float32)
        assert probe(*[a.ctypes.data_as(pointer) for a in arrays + [output]], dimension) == 1
        embedding, position, word_w, word_b, input_w, input_b = [a.astype(np.float64) for a in arrays]
        def normalize(value, weight, bias):
            return (value - value.mean()) / np.sqrt(value.var(ddof=0) + 1e-5) * weight + bias
        word = normalize(embedding, word_w, word_b)
        expected = normalize(word + position, input_w, input_b)
        np.testing.assert_allclose(output, expected, rtol=0, atol=2e-5)
        missing = word + position
        wrong_order = normalize(word, input_w, input_b) + position
        wrong_affine = normalize(word + position, np.ones(dimension), np.zeros(dimension))
        distances = {name: float(np.max(np.abs(expected - alternative)))
                     for name, alternative in [('missing_norm', missing),
                        ('wrong_order', wrong_order), ('missing_learned_affine', wrong_affine)]}
        assert all(distance > .1 for distance in distances.values()), distances
        assert probe(*[a.ctypes.data_as(pointer) for a in arrays + [output]], 0) == 0
        assert probe(None, *[a.ctypes.data_as(pointer) for a in arrays[1:] + [output]], dimension) == 0
        rows.append({'dimension': dimension, 'status': 'passed',
                     'max_absolute_error': float(np.max(np.abs(output - expected))),
                     'negative_control_distances': distances})
    return {'format': 'crispmath.posformer-input-normalization-controls',
            'library_sha256': hashlib.sha256(Path(library).read_bytes()).hexdigest(),
            'reference': 'Independent biased-variance LayerNorm equation, epsilon1e-5, learned affine, after positional addition.',
            'cases': rows}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--library', required=True)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    result = check(args.library)
    Path(args.output).write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))
