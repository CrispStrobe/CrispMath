"""Fill the generated fact blocks in readme.md from canonical sources.

The README must not restate numbers that live elsewhere: the version already
exists in pubspec.yaml, the dependency pins in tool/dependency_lock.json, the
test and function counts in the tree. This script rewrites the marked blocks so
those lines cannot drift, and --check lets CI refuse a stale README.

Markers are HTML comments so they disappear when the file is rendered:

    <!-- AUTO:app_version -->1.2.0<!-- /AUTO:app_version -->

Only the text between a pair is replaced; everything else is left alone.
"""
import argparse
import json
import re
from pathlib import Path
import subprocess
import sys

README = Path('readme.md')
MARKER = re.compile(r'(<!-- AUTO:(?P<name>[a-z0-9_]+) -->)(?P<value>.*?)'
                    r'(<!-- /AUTO:(?P=name) -->)', re.S)
VERSION = re.compile(r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$', re.M)


def read_pubspec(root):
    match = VERSION.search((root / 'pubspec.yaml').read_text())
    if match is None:
        raise ValueError('pubspec.yaml has no numeric version+build')
    return match.group(1), match.group(2)


def read_lock(root):
    lock = json.loads((root / 'tool/dependency_lock.json').read_text())
    return {
        'flutter_version': lock['flutter'],
        'crispembed_revision': lock['crispembed']['revision'],
        'bridge_revision': lock['symbolic_math_bridge']['revision'],
        'dart_csp_version': f"{lock['dart_csp']['version']} "
                            f"({lock['dart_csp']['revision'][:7]})",
    }


def latest_tag(root):
    """Newest v* tag, or None when git or the tags are unavailable."""
    try:
        return subprocess.check_output(
            ['git', 'describe', '--tags', '--abbrev=0', '--match', 'v*'],
            cwd=root, text=True, stderr=subprocess.DEVNULL).strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def counts(root):
    tests = sum(len(list((root / folder).rglob('*_test.dart')))
                for folder in ('test', 'integration_test', 'native_test')
                if (root / folder).is_dir())
    reference = (root / 'lib/engine/function_reference.dart').read_text()
    entries = len(re.findall(r"^\s+id: '", reference, re.M))
    return {'test_file_count': str(tests), 'function_entry_count': str(entries)}


def facts(root, tag=None):
    version, build = read_pubspec(root)
    values = {'app_version': version, 'build_number': build,
              'app_version_build': f'{version}+{build}'}
    values.update(read_lock(root))
    values.update(counts(root))
    if tag or (tag := latest_tag(root)):
        values['latest_tag'] = tag
    return values


def render(text, values, strict=True):
    seen = set()

    def replace(match):
        name = match.group('name')
        if name not in values:
            if strict:
                raise KeyError(f'no source for AUTO:{name}')
            return match.group(0)
        seen.add(name)
        return f'{match.group(1)}{values[name]}{match.group(4)}'

    updated = MARKER.sub(replace, text)
    unused = sorted(set(values) - seen)
    if strict and unused:
        raise KeyError('marker missing for: ' + ', '.join(unused))
    return updated


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path.cwd())
    parser.add_argument('--readme', type=Path, default=README)
    parser.add_argument('--check', action='store_true',
                        help='Exit 1 when the README is stale instead of writing')
    args = parser.parse_args()
    path = args.root / args.readme
    current = path.read_text()
    updated = render(current, facts(args.root))
    if args.check:
        if current != updated:
            print('readme.md is stale; run python tool/update_readme_facts.py')
            return 1
        print('readme.md facts are current')
        return 0
    if current == updated:
        print('readme.md facts are current')
        return 0
    path.write_text(updated)
    print('updated readme.md')
    return 0


if __name__ == '__main__':
    sys.exit(main())
