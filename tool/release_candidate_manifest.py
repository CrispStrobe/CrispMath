"""Validate release metadata and record the source and dependency revisions."""
import argparse
import json
from pathlib import Path
import re
import subprocess


def manifest(root, label):
    version_match = re.search(r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$',
                              (root / 'pubspec.yaml').read_text(), re.M)
    if version_match is None:
        raise ValueError('Expected a numeric release version and build number')
    version, build = version_match.groups()
    if not re.fullmatch(r'v' + re.escape(version) + r'(?:-rc\.[1-9]\d*)?', label):
        raise ValueError('Release label must match pubspec version, optionally with -rc.N')
    lock = json.loads((root / 'tool/dependency_lock.json').read_text())
    for name in ['crispembed', 'symbolic_math_bridge', 'dart_csp']:
        if not re.fullmatch(r'[0-9a-f]{40}', lock[name]['revision']):
            raise ValueError(f'{name} requires a full commit revision')
    for name in ['symbolic_math_bridge', 'dart_csp']:
        if lock[name]['revision'] not in (root / 'pubspec.yaml').read_text():
            raise ValueError(f'{name} revision differs from the dependency lock')
    checksums = json.loads((root / 'tool/ocr_runtime_checksums.json').read_text())
    if lock['crispembed']['version'] not in checksums:
        raise ValueError('Native OCR release checksums are missing')
    revision = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip()
    return {'label': label, 'app_version': version, 'build_number': int(build),
            'source_revision': revision, 'dependencies': lock,
            'ocr_runtime_sha256': checksums[lock['crispembed']['version']],
            'distribution': 'candidate artifact' if '-rc.' in label else 'release artifact'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--label', required=True)
    parser.add_argument('--output', type=Path, default=Path('candidate-manifest.json'))
    args = parser.parse_args()
    result = manifest(Path.cwd(), args.label)
    args.output.write_text(json.dumps(result, indent=2) + '\n')
    print(f"Validated {result['label']} build {result['build_number']} at {result['source_revision']}")
