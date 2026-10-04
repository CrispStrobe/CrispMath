"""Strict paired 50-case evidence for normalization plus ceil-pooling repair."""
import argparse
import json
import math
import re
from pathlib import Path

from audit_handwriting_vocabulary import file_hash
from check_posformer_pooling import CASE_IDS, SHAPES
from compare_handwriting_encoders import BRIDGE_SOURCE, require
from compare_handwriting_input_norm import compare as compare_normalization


ORIGINAL_SOURCE_SHA256 = 'bc88ab2f68cfe992d3cc78df47d488771a237ae3ae3eb7af4d927383fa8e7f2c'


def compare(before, after, normalization_controls, pooling_controls, patch_hash, model_id, provenance):
    result = compare_normalization(before, after, normalization_controls, patch_hash, model_id)
    require(provenance.get('source') == before['source'] and
            provenance.get('bridge_source') == BRIDGE_SOURCE and
            provenance.get('original_source_sha256') == ORIGINAL_SOURCE_SHA256,
            'Wrong native source provenance')
    require(provenance.get('patch_sha256') == patch_hash and
            provenance.get('library_sha256') == after['library_sha256'], 'Wrong patch/library provenance')
    patched_source = provenance.get('patched_source_sha256', '')
    require(re.fullmatch(r'[0-9a-f]{64}', patched_source) and patched_source != ORIGINAL_SOURCE_SHA256,
            'Missing actual repaired source identity')
    require(pooling_controls.get('library_sha256') == after['library_sha256'],
            'Pool controls exercised a different library')
    require(pooling_controls.get('invalid_arguments_rejected') is True, 'Missing ABI negative controls')
    rows = pooling_controls.get('cases', [])
    require([row.get('id') for row in rows] == CASE_IDS, 'Incomplete/changed pool controls')
    for row, (c, h, w) in zip(rows, SHAPES * 2):
        require(row.get('input_shape') == [c, h, w] and
                row.get('output_shape') == [c, (h + 1) // 2, (w + 1) // 2], 'Wrong pooling dimensions')
        error = row.get('max_absolute_error')
        require(row.get('status') == 'passed' and type(error) in (float, int) and
                math.isfinite(error) and 0 <= error <= 1e-6, 'Native pool arithmetic failed')
        if h >= 2 and w >= 2 and (h % 2 or w % 2):
            require(row.get('floor_rejected') is True, 'Missing floor-pool negative control')
        if h % 2 or w % 2:
            require(row.get('zero_padding_rejected') is True, 'Missing zero-padding negative control')
    result['format'] = 'crispmath.handwriting-forward-repair-comparison'
    result['interpretation'] = ('Controlled unchanged-50 diagnostic of post-position normalization and '
        'ceil pooling. Actual patched library passed independent LayerNorm and PyTorch pooling controls. '
        'Bounded exported-FP32 model reference parity is reported separately; no production promotion.')
    result['pooling_control_cases'] = len(rows)
    result['native_provenance'] = provenance
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('baseline', 'patched', 'normalization-controls', 'pooling-controls', 'patch-file',
                 'provenance', 'output'):
        parser.add_argument('--' + name, required=True)
    parser.add_argument('--model-id', choices=['crohme-q8', 'mathwriting-v2'], required=True)
    args = parser.parse_args()
    result = compare(json.loads(Path(args.baseline).read_text()), json.loads(Path(args.patched).read_text()),
                     json.loads(Path(args.normalization_controls).read_text()),
                     json.loads(Path(args.pooling_controls).read_text()), file_hash(args.patch_file), args.model_id,
                     json.loads(Path(args.provenance).read_text()))
    Path(args.output).write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: v for k, v in result.items() if k != 'cases'}))
