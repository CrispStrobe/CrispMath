"""Hosted PyTorch comparison of the actual native ceil-pool helper."""
import argparse
import ctypes
import json
from pathlib import Path

from audit_handwriting_vocabulary import file_hash
from compare_handwriting_encoders import require

SHAPES = [(1, 4, 6), (1, 3, 6), (1, 4, 5), (1, 3, 5),
          (3, 5, 7), (2, 1, 5), (2, 5, 1), (3, 1, 1)]
CASE_IDS = [f'{operation}-{c}x{h}x{w}' for operation in ('max', 'avg') for c, h, w in SHAPES]


def run(library_path):
    import numpy as np
    import torch
    import torch.nn.functional as F
    torch.set_num_threads(2)
    library = ctypes.CDLL(str(Path(library_path).resolve()))
    probe = library.crispembed_posformer_pool_ceil_probe
    pointer = ctypes.POINTER(ctypes.c_float)
    probe.argtypes = [pointer, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int,
                     ctypes.c_int, pointer, ctypes.c_int]
    probe.restype = ctypes.c_int
    def ptr(a):
        return a.ctypes.data_as(pointer)
    cases = []
    for operation in ('max', 'avg'):
        for c, h, w in SHAPES:
            # Negative, positive and nonuniform edges; each channel is distinct.
            values = np.arange(c * h * w, dtype=np.float32).reshape(c, h, w)
            values = (values % 11 - 8) / np.float32(3) - np.arange(c, dtype=np.float32)[:, None, None]
            if w % 2:
                values[:, :, -1] = -4 - np.arange(c, dtype=np.float32)[:, None]
            if h % 2:
                values[:, -1, :] = -6 - np.arange(c, dtype=np.float32)[:, None]
            values = np.ascontiguousarray(values)
            pooled = np.empty((c, (h + 1) // 2, (w + 1) // 2), dtype=np.float32)
            require(probe(ptr(values), c, h, w, int(operation == 'avg'), values.size,
                          ptr(pooled), pooled.size) == 1, 'Native pool control failed')
            pooling = F.max_pool2d if operation == 'max' else F.avg_pool2d
            reference = pooling(torch.from_numpy(values)[None], 2, ceil_mode=True)[0].numpy()
            error = float(np.abs(pooled - reference).max())
            require(np.allclose(pooled, reference, atol=1e-6, rtol=0), 'Native pool disagrees with PyTorch')
            floor_rejected = None
            if h >= 2 and w >= 2 and (h % 2 or w % 2):
                floor = pooling(torch.from_numpy(values)[None], 2)[0].numpy()
                floor_rejected = floor.shape != pooled.shape
                require(floor_rejected, 'Floor-pool negative control failed')
            zero_padding_rejected = None
            if h % 2 or w % 2:
                padded = F.pad(torch.from_numpy(values)[None], (0, w % 2, 0, h % 2))
                wrong = pooling(padded, 2)[0].numpy()
                zero_padding_rejected = not np.allclose(wrong, reference, atol=1e-6, rtol=0)
                require(zero_padding_rejected, 'Zero-padding negative control failed')
            cases.append({'id': f'{operation}-{c}x{h}x{w}', 'operation': operation,
                          'input_shape': [c, h, w], 'output_shape': list(pooled.shape),
                          'max_absolute_error': error, 'status': 'passed',
                          'floor_rejected': floor_rejected, 'zero_padding_rejected': zero_padding_rejected})
    # ABI guards reject missing buffers, wrong size and an invalid operation.
    small = np.zeros(4, dtype=np.float32)
    output = np.zeros(1, dtype=np.float32)
    invalid = [probe(None, 1, 2, 2, 0, 4, ptr(output), 1),
               probe(ptr(small), 1, 2, 2, 0, 3, ptr(output), 1),
               probe(ptr(small), 1, 2, 2, 0, 4, ptr(output), 0),
               probe(ptr(small), 1, 2, 2, 2, 4, ptr(output), 1),
               probe(ptr(small), 0, 2, 2, 0, 4, ptr(output), 1)]
    require(invalid == [0] * len(invalid), 'Native probe accepted invalid dimensions/buffers')
    return {'format': 'crispmath.native-pool-ceil-controls', 'library_sha256': file_hash(library_path),
            'reference': 'PyTorch functional max_pool2d/avg_pool2d, ceil_mode=True',
            'torch_version': torch.__version__, 'atol': 1e-6, 'rtol': 0,
            'invalid_arguments_rejected': True, 'cases': cases}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--library', required=True)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    result = run(args.library)
    Path(args.output).write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: v for k, v in result.items() if k != 'cases'}))
