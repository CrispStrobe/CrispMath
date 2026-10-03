#!/usr/bin/env python3
"""Wait for real browser/gallery CI and prove the signed source matches it."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import time
import urllib.error
import urllib.request

REPOSITORY = 'CrispStrobe/CrispMath'
WORKFLOW = '.github/workflows/feature-validation.yml'
REQUIRED_JOBS = ('browser', 'gallery')


class ValidationError(ValueError):
    pass


def validate_sha(value):
    if not isinstance(value, str) or not re.fullmatch(r'[0-9a-f]{40}', value):
        raise ValidationError('Expected a full lowercase 40-character source SHA')
    return value


def production_path(path):
    # Fail closed for new runtime directories/files. Only established non-runtime
    # paths are excluded; packaging tools that affect bundled bytes stay covered.
    root = path.split('/', 1)[0]
    if root in {'.github', 'docs', 'test', 'native_test', 'integration_test',
                'test_driver'}:
        return False
    if root == 'tool':
        return path in {'tool/stage_ocr_runtime.py',
                        'tool/ocr_runtime_checksums.json', 'tool/dependency_lock.json',
                        'tool/build_web.sh'}
    if '/' not in path and (path.lower().endswith('.md') or path in {
            '.gitignore', 'analysis_options.yaml'}):
        return False
    return True


def production_tree(tree):
    if tree.get('truncated') is not False or not isinstance(tree.get('tree'), list):
        raise ValidationError('Incomplete Git tree; cannot prove application parity')
    result = {}
    for entry in tree['tree']:
        if entry.get('type') == 'tree':
            continue
        path = entry.get('path')
        if not isinstance(path, str) or not path or path.startswith('/') or '..' in path.split('/'):
            raise ValidationError('Invalid Git tree path')
        if production_path(path):
            validate_sha(entry.get('sha'))
            if entry.get('type') not in {'blob', 'commit'} or not entry.get('mode'):
                raise ValidationError('Invalid production Git tree entry')
            result[path] = (entry['type'], entry['mode'], entry['sha'])
    if 'pubspec.yaml' not in result or 'pubspec.lock' not in result or not any(p.startswith('lib/') for p in result):
        raise ValidationError('Production tree is missing essential app source')
    return result


def checked_run(run, run_id):
    if run.get('id') != int(run_id):
        raise ValidationError('Validation run ID mismatch')
    for field in ('repository', 'head_repository'):
        if run.get(field, {}).get('full_name') != REPOSITORY:
            raise ValidationError('Validation repository mismatch')
    if run.get('path') != WORKFLOW or run.get('name') != 'Feature validation':
        raise ValidationError('Validation workflow mismatch')
    validate_sha(run.get('head_sha'))
    if run.get('status') not in {'queued', 'in_progress', 'waiting', 'pending', 'requested', 'completed'}:
        raise ValidationError('Unexpected validation run status')
    if run['status'] == 'completed' and run.get('conclusion') != 'success':
        raise ValidationError('Validation run did not succeed')
    return run['status'] == 'completed'


def wait_for_validation(api, run_id, package_sha, *, timeout=1800, interval=30,
                        clock=time.monotonic, sleep=time.sleep):
    if not isinstance(run_id, str) or not re.fullmatch(r'[1-9][0-9]*', run_id):
        raise ValidationError('Expected a positive numeric validation run ID')
    validate_sha(package_sha)
    if not 0 < timeout <= 1800 or not 0 < interval <= 60:
        raise ValidationError('Polling must be bounded to at most 30 minutes')
    prefix = f'/repos/{REPOSITORY}'
    deadline = clock() + timeout
    while True:
        run = api(f'{prefix}/actions/runs/{run_id}')
        if checked_run(run, run_id):
            break
        remaining = deadline - clock()
        if remaining <= 0:
            raise ValidationError('Timed out waiting for release validation')
        sleep(min(interval, remaining))
    jobs = []
    page = 1
    while True:
        batch = api(f'{prefix}/actions/runs/{run_id}/jobs?filter=latest&per_page=100&page={page}')
        entries = batch.get('jobs')
        total = batch.get('total_count')
        if not isinstance(entries, list) or not isinstance(total, int):
            raise ValidationError('Invalid validation jobs response')
        jobs.extend(entries)
        if len(jobs) >= total:
            break
        if not entries or page >= 100:
            raise ValidationError('Incomplete validation job listing')
        page += 1
    required = {}
    for name in REQUIRED_JOBS:
        matches = [job for job in jobs if job.get('name') == name]
        if len(matches) != 1 or matches[0].get('status') != 'completed' or matches[0].get('conclusion') != 'success':
            raise ValidationError(f'Required live validation job {name} did not succeed')
        required[name] = {'id': matches[0].get('id'), 'conclusion': 'success'}
    validated = production_tree(api(f"{prefix}/git/trees/{run['head_sha']}?recursive=1"))
    packaged = production_tree(api(f'{prefix}/git/trees/{package_sha}?recursive=1'))
    differences = sorted(p for p in validated.keys() | packaged.keys() if validated.get(p) != packaged.get(p))
    if differences:
        raise ValidationError('Application source differs from live validation: ' + ', '.join(differences[:20]))
    fingerprint = hashlib.sha256(json.dumps(packaged, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
    return {'passed': True, 'repository': REPOSITORY, 'workflow': WORKFLOW,
            'validationRunId': int(run_id),
            'validationRunUrl': f'https://github.com/{REPOSITORY}/actions/runs/{run_id}',
            'validationSource': run['head_sha'], 'packageSource': package_sha,
            'requiredJobs': required, 'productionFileCount': len(packaged),
            'productionTreeSha256': fingerprint}


class GitHubAPI:
    def __init__(self, token):
        self.token = token

    def __call__(self, path):
        request = urllib.request.Request('https://api.github.com' + path, headers={
            'Authorization': 'Bearer ' + self.token,
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28'})
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                return json.load(response)
        except (urllib.error.URLError, json.JSONDecodeError) as error:
            # Never include request headers, tokens or response bodies in logs.
            raise ValidationError('GitHub validation API request failed') from error


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run-id', required=True)
    parser.add_argument('--package-sha', required=True)
    parser.add_argument('--repository', default=os.environ.get('GITHUB_REPOSITORY', REPOSITORY))
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    report = {'passed': False, 'validationRunId': args.run_id, 'packageSource': args.package_sha}
    try:
        if args.repository != REPOSITORY:
            raise ValidationError('Package repository mismatch')
        token = os.environ.get('GH_TOKEN', '')
        if not token:
            raise ValidationError('GH_TOKEN is required')
        report = wait_for_validation(GitHubAPI(token), args.run_id, args.package_sha)
    except ValidationError as error:
        report['error'] = str(error)
        print('Release validation blocked: ' + str(error))
    finally:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + '\n')
    if not report['passed']:
        return 1
    print('Release validation passed: browser and gallery succeeded; production source matches')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
