"""Strict evidence pairing for the diagnostic-only native input-normalization patch."""
import argparse
import hashlib
import json
import math
import re
from pathlib import Path

from audit_handwriting_vocabulary import MODELS, FROZEN_MANIFEST_SHA256
from compare_handwriting_encoders import require, tokens, validate

FILENAMES = {'crohme-q8': 'posformer-q8.gguf',
             'mathwriting-v2': 'posformer-mathwriting-v2-f32.gguf'}


def compare(before, after, controls, patch_hash, model_id):
    require(model_id in MODELS, 'Unknown pinned model identity')
    require(re.fullmatch(r'[0-9a-f]{64}', patch_hash), 'Missing patch identity')
    left, left_matches = validate(before, 'default', MODELS[model_id], FILENAMES[model_id])
    right, right_matches = validate(after, 'default', MODELS[model_id], FILENAMES[model_id])
    require(before.get('bridge_patch_sha256') is None, 'Baseline was patched')
    require(after.get('bridge_patch_sha256') == patch_hash, 'Wrong diagnostic patch')
    for report in (before, after):
        require(isinstance(report.get('library_sha256'), str) and
                re.fullmatch(r'[0-9a-f]{64}', report['library_sha256']), 'Missing library identity')
        require(report['corpus_manifest_sha256'] == FROZEN_MANIFEST_SHA256,
                'Frozen manifest changed')
    require(before['library_sha256'] != after['library_sha256'], 'Diagnostic library unchanged')
    require(controls.get('library_sha256') == after['library_sha256'],
            'Independent controls exercised a different library')
    rows = controls.get('cases', [])
    require([row.get('dimension') for row in rows] == [256, 384], 'Missing dimension controls')
    require(all(row.get('status') == 'passed' and
                type(row.get('max_absolute_error')) in (int, float) and
                0 <= row['max_absolute_error'] <= 2e-5 and
                set(row.get('negative_control_distances', {})) ==
                {'missing_norm', 'wrong_order', 'missing_learned_affine'} and
                all(type(distance) in (int, float) and math.isfinite(distance) and distance > .1
                    for distance in row['negative_control_distances'].values())
                for row in rows), 'Native normalization controls failed')
    for key in ('source', 'bridge_source', 'model_sha256', 'model',
                'corpus_manifest_sha256', 'corpus', 'threads', 'scoring'):
        require(before[key] == after[key], f'Paired {key} changed')
    cases = []
    for a, b in zip(left, right):
        for key in ('id', 'reference_latex', 'image_sha256', 'image_width', 'image_height'):
            require(a[key] == b[key], f'Paired {key} changed')
        cases.append({'id': a['id'], 'reference_latex': a['reference_latex'],
                      'baseline_latex': a['latex'], 'patched_latex': b['latex'],
                      'baseline_status': a['status'], 'patched_status': b['status'],
                      'token_output_equal': tokens(a['latex']) == tokens(b['latex'])})
    return {'format': 'crispmath.handwriting-input-normalization-comparison',
            'source': before['source'], 'bridge_source': before['bridge_source'],
            'model_id': model_id, 'model_sha256': MODELS[model_id],
            'patch_sha256': patch_hash, 'baseline_library_sha256': before['library_sha256'],
            'patched_library_sha256': after['library_sha256'],
            'corpus_manifest_sha256': FROZEN_MANIFEST_SHA256, 'samples': 50,
            'baseline_exact_matches': left_matches, 'patched_exact_matches': right_matches,
            'token_output_differences': sum(not row['token_output_equal'] for row in cases),
            'interpretation': 'Controlled diagnostic only; no production bridge pin or model change. Native input path matches independent LayerNorm math; full model/reference parity remains unresolved.',
            'cases': cases}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('baseline', 'patched', 'controls', 'patch-file', 'output'):
        parser.add_argument('--' + name, required=True)
    parser.add_argument('--model-id', choices=sorted(MODELS), required=True)
    args = parser.parse_args()
    result = compare(json.loads(Path(args.baseline).read_text()),
                     json.loads(Path(args.patched).read_text()),
                     json.loads(Path(args.controls).read_text()),
                     hashlib.sha256(Path(args.patch_file).read_bytes()).hexdigest(), args.model_id)
    Path(args.output).write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({key: value for key, value in result.items() if key != 'cases'}))
