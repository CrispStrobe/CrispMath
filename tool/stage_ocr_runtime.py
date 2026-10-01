"""Stage checksummed native OCR libraries matching the pinned plugin release."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import tarfile
import tempfile
import urllib.request
import zipfile

ASSETS = {
    'linux': [('crispembed-linux-x86_64.tar.gz', 'linux/lib', '*.so*', 'libcrispembed.so')],
    'windows': [('crispembed-windows-x86_64.zip', 'windows/lib', '*.dll', 'crispembed.dll')],
    'macos': [('crispembed-macos-arm64.tar.gz', 'macos/Libs', '*.dylib', 'libcrispembed.dylib')],
    'ios': [('crispembed-ios-arm64.tar.gz', 'ios/Libs', '*.a', 'libcrispembed-static.a')],
    'android': [(f'crispembed-android-{abi}.tar.gz', f'android/src/main/jniLibs/{abi}', '*.so*',
                 'libcrispembed.so') for abi in ['arm64-v8a', 'armeabi-v7a']],
}


def verify_archive(archive, expected):
    with archive.open('rb') as source:
        digest = hashlib.file_digest(source, 'sha256').hexdigest()
    if digest != expected:
        raise ValueError(f'Checksum mismatch for {archive.name}: {digest}')


def stage(plugin_root, platform, archive=None, expected_sha256=None):
    version_match = re.search(r'^version:\s*([^\s+]+)',
                              (plugin_root / 'pubspec.yaml').read_text(), re.M)
    if version_match is None:
        raise ValueError('CrispEmbed plugin version is missing')
    version = version_match[1]
    checksums = json.loads(Path(__file__).with_name('ocr_runtime_checksums.json').read_text())
    if archive is not None and len(ASSETS[platform]) != 1:
        raise ValueError('Archive overrides require a single-archive platform')
    for asset, folder, pattern, primary in ASSETS[platform]:
        expected = expected_sha256 or checksums[version][asset]
        destination = plugin_root / folder
        with tempfile.TemporaryDirectory(prefix='crispmath-ocr-') as directory:
            temporary = Path(directory)
            source = archive or temporary / asset
            if archive is None:
                url = f'https://github.com/CrispStrobe/CrispEmbed/releases/download/v{version}/{asset}'
                with urllib.request.urlopen(url, timeout=60) as response, source.open('wb') as output:
                    shutil.copyfileobj(response, output)
            verify_archive(source, expected)
            extracted = temporary / 'extracted'
            extracted.mkdir()
            if asset.endswith('.zip'):
                with zipfile.ZipFile(source) as bundle:
                    for member in bundle.infolist():
                        if not member.is_dir() and member.filename.lower().endswith('.dll'):
                            (extracted / Path(member.filename).name).write_bytes(bundle.read(member))
            else:
                with tarfile.open(source) as bundle:
                    bundle.extractall(extracted, filter='data')
            libraries = sorted(extracted.rglob(pattern))
            if not any(library.name == primary for library in libraries):
                raise ValueError(f'{asset} does not contain {primary}')
            destination.mkdir(parents=True, exist_ok=True)
            for library in libraries:
                if library.is_file():
                    shutil.copy2(library, destination / library.name)
            print(f'Staged verified CrispEmbed {version}: {len(libraries)} libraries in {destination}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--plugin-root', type=Path,
                        default=Path('.ci/CrispEmbed/flutter/crispembed'))
    parser.add_argument('--platform', choices=ASSETS, required=True)
    parser.add_argument('--archive', type=Path)
    args = parser.parse_args()
    stage(args.plugin_root, args.platform, args.archive)
