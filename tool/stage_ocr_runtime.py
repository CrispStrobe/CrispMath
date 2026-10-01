"""Stage matching CPU OCR runtime libraries for Flutter desktop packaging."""
import argparse
from pathlib import Path
import re
import shutil
import tarfile
import tempfile
import urllib.request
import zipfile


def stage(plugin_root, platform, archive=None):
    version_match = re.search(r'^version:\s*([^\s+]+)',
                              (plugin_root / 'pubspec.yaml').read_text(), re.M)
    if version_match is None:
        raise ValueError('CrispEmbed plugin version is missing')
    version = version_match[1]
    asset = ('crispembed-linux-x86_64.tar.gz' if platform == 'linux'
             else 'crispembed-windows-x86_64.zip')
    destination = plugin_root / platform / 'lib'
    with tempfile.TemporaryDirectory(prefix='crispmath-ocr-') as directory:
        temporary = Path(directory)
        if archive is None:
            archive = temporary / asset
            url = f'https://github.com/CrispStrobe/CrispEmbed/releases/download/v{version}/{asset}'
            urllib.request.urlretrieve(url, archive)
        extracted = temporary / 'extracted'
        extracted.mkdir()
        if platform == 'linux':
            with tarfile.open(archive) as bundle:
                bundle.extractall(extracted, filter='data')
            libraries = sorted(extracted.rglob('*.so*'))
            primary = 'libcrispembed.so'
        else:
            with zipfile.ZipFile(archive) as bundle:
                # Only flatten native library files; no executable paths are extracted.
                for member in bundle.infolist():
                    if not member.is_dir() and member.filename.lower().endswith('.dll'):
                        (extracted / Path(member.filename).name).write_bytes(bundle.read(member))
            libraries = sorted(extracted.glob('*.dll'))
            primary = 'crispembed.dll'
        if not any(library.name == primary for library in libraries):
            raise ValueError(f'{asset} does not contain {primary}')
        destination.mkdir(parents=True, exist_ok=True)
        for library in libraries:
            if library.is_file():
                shutil.copy2(library, destination / library.name)
        print(f'Staged CrispEmbed {version}: {len(libraries)} libraries in {destination}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--plugin-root', type=Path,
                        default=Path('.ci/CrispEmbed/flutter/crispembed'))
    parser.add_argument('--platform', choices=['linux', 'windows'], required=True)
    parser.add_argument('--archive', type=Path)
    args = parser.parse_args()
    stage(args.plugin_root, args.platform, args.archive)
