"""Diagnose paired encoder outputs without changing recognition quality gates."""
import argparse
import json
import math
import re
from pathlib import Path
from provision_ocr_quality import DATA_SHA256, DATA_SOURCE, DATA_URL

BRIDGE_SOURCE = '11e6d598521976f38081934106b55095b46b40e3'
POSFORMER_SHA256 = '450211ad27ce19e2f30651e69fdc77ea76a13b66e29e045858286024864bf4a4'


def tokens(value):
    if not isinstance(value, str):
        raise ValueError('Transcriptions and references must be strings')
    return re.sub(r'\s+', '', value.replace('\u0120', ' '))


def require(condition, message):
    if not condition:
        raise ValueError(message)


def validate(report, arm):
    require(report.get('encoder_arm') == arm, 'Wrong encoder arm')
    require(report.get('encoder_environment') == {
        'POSFORMER_SCALAR_ENCODER': '1' if arm == 'scalar' else None},
        'Wrong encoder environment')
    require(report.get('bridge_source') == BRIDGE_SOURCE, 'Unpinned native bridge')
    require(report.get('model_sha256') == POSFORMER_SHA256, 'Unpinned weights')
    require(report.get('model') == 'posformer-q8.gguf', 'Wrong model')
    require(report.get('threads') == 2, 'Thread count changed')
    require(isinstance(report.get('source'), str) and
            re.fullmatch(r'[0-9a-f]{40}', report['source']), 'Missing source identity')
    require(isinstance(report.get('corpus_manifest_sha256'), str) and
            re.fullmatch(r'[0-9a-f]{64}', report['corpus_manifest_sha256']),
            'Missing corpus hash')
    corpus = report.get('corpus', {})
    require(corpus.get('split') == 'test', 'Not the frozen test split')
    require(corpus.get('archive_sha256') == DATA_SHA256 and
            corpus.get('archive_url') == DATA_URL and corpus.get('dataset') == DATA_SOURCE,
            'Unpinned dataset')
    require(corpus.get('selection') ==
            'first 50 SHA-256 ranked IDs with fixed CrispMath-2026-10-02 seed',
            'Frozen selection changed')
    require(report.get('scoring') ==
            'Exact LaTeX tokens after whitespace/BPE separator removal; equivalent alternate transcriptions are not exact matches.',
            'Scoring changed')
    manifest_cases = corpus.get('cases', [])
    cases = report.get('cases', [])
    require(isinstance(cases, list) and isinstance(manifest_cases, list) and
            len(cases) == len(manifest_cases) == 50, 'Incomplete paired corpus')
    ids = [item.get('id') for item in cases]
    require(all(isinstance(identifier, str) and identifier for identifier in ids)
            and len(set(ids)) == 50, 'Duplicate or missing case IDs')
    require(ids == [item.get('id') for item in manifest_cases], 'Case order changed')
    matches = 0
    for item, frozen in zip(cases, manifest_cases):
        require(item.get('reference_latex') == frozen.get('reference_latex'),
                'Independent reference changed')
        require(isinstance(item.get('image_sha256'), str) and
                re.fullmatch(r'[0-9a-f]{64}', item['image_sha256']), 'Missing image hash')
        require(all(type(item.get(key)) is int and item[key] > 0
                    for key in ('image_width', 'image_height')), 'Missing image dimensions')
        elapsed = item.get('elapsed_ms')
        require(type(elapsed) in (int, float) and math.isfinite(elapsed) and elapsed >= 0,
                'Invalid elapsed time')
        status = 'exact_match' if tokens(item.get('latex')) == tokens(
            frozen.get('reference_latex')) else 'different_transcription'
        require(item.get('status') == status, 'Runtime failure or inconsistent scoring')
        matches += status == 'exact_match'
    require(type(report.get('runtime_failures')) is int and
            report['runtime_failures'] == 0, 'Runtime failure')
    require(type(report.get('exact_matches')) is int and
            report['exact_matches'] == matches, 'Incorrect aggregate score')
    return cases, matches


def compare(default, scalar):
    left, left_matches = validate(default, 'default')
    right, right_matches = validate(scalar, 'scalar')
    for key in ('source', 'bridge_source', 'model_sha256', 'corpus_manifest_sha256',
                'corpus', 'threads', 'scoring'):
        require(default.get(key) == scalar.get(key), f'Paired {key} changed')
    rows = []
    for before, after in zip(left, right):
        for key in ('id', 'reference_latex', 'image_sha256', 'image_width', 'image_height'):
            require(before.get(key) == after.get(key), f'Paired {key} changed')
        rows.append({'id': before['id'], 'raw_output_equal': before['latex'] == after['latex'],
                     'token_output_equal': tokens(before['latex']) == tokens(after['latex']),
                     'default_status': before['status'], 'scalar_status': after['status'],
                     'default_latex': before['latex'], 'scalar_latex': after['latex'],
                     'reference_latex': before['reference_latex']})
    return {'format': 'crispmath.handwriting-encoder-comparison', 'source': default['source'],
            'bridge_source': BRIDGE_SOURCE, 'model_sha256': POSFORMER_SHA256,
            'corpus_manifest_sha256': default['corpus_manifest_sha256'], 'samples': 50,
            'default_exact_matches': left_matches, 'scalar_exact_matches': right_matches,
            'raw_output_differences': sum(not row['raw_output_equal'] for row in rows),
            'token_output_differences': sum(not row['token_output_equal'] for row in rows),
            'interpretation': 'Diagnostic only. Arms specify requested encoder selection; default may fall back to scalar if scheduler initialization fails. Equal outputs do not establish handwriting reliability.',
            'cases': rows}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--default', required=True)
    parser.add_argument('--scalar', required=True)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    result = compare(json.loads(Path(args.default).read_text()),
                     json.loads(Path(args.scalar).read_text()))
    Path(args.output).write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({key: value for key, value in result.items() if key != 'cases'}))
