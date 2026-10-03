"""Gate the actual signed iOS bundle before delivery to Apple."""
import argparse
import json
from pathlib import Path
import plistlib

PURPOSE_KEYS = ('NSPhotoLibraryUsageDescription', 'NSCameraUsageDescription')


def validate(info, version=None, build=None):
    for key in PURPOSE_KEYS:
        value = info.get(key)
        if not isinstance(value, str) or not value.strip() or '$(' in value:
            raise ValueError(f'Missing or unresolved iOS privacy purpose: {key}')
    for key, expected in [('CFBundleShortVersionString', version), ('CFBundleVersion', build)]:
        if expected is not None and info.get(key) != expected:
            raise ValueError(f'Packaged {key} differs from the intended delivery')
    return {key: info[key] for key in PURPOSE_KEYS}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('plist', type=Path)
    parser.add_argument('--version')
    parser.add_argument('--build')
    args = parser.parse_args()
    with args.plist.open('rb') as file:
        info = plistlib.load(file)
    purposes = validate(info, args.version, args.build)
    print(json.dumps({'bundleId': info.get('CFBundleIdentifier'),
                      'version': info.get('CFBundleShortVersionString'),
                      'build': info.get('CFBundleVersion'), 'purposes': purposes,
                      'passed': True}), flush=True)
