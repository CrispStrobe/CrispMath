"""Stage the pinned, checksummed OCR WASM runtime on GitHub-hosted builds only."""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import urllib.request

ASSETS = ('crispembed_ocr.js', 'crispembed_ocr.wasm')
UTF8_BEFORE = b'UTF8Decoder.decode(heapOrArray.subarray(idx,endPtr))'
UTF8_AFTER = b'UTF8Decoder.decode(heapOrArray.buffer.resizable?heapOrArray.slice(idx,endPtr):heapOrArray.subarray(idx,endPtr))'
PATCH_RULE_SHA256 = hashlib.sha256(UTF8_BEFORE + b'\n' + UTF8_AFTER).hexdigest()
PATCHED_17_12_JS_SHA256 = 'b5116b0625c30bc5be2f0ebcd9aae096936de7cb7fc4cf04cb9a096cd5e46407'
PATCH_SOURCE = 'https://github.com/emscripten-core/emscripten/pull/27242'
PATCH_SOURCE_COMMIT = 'a41c221fbe7b99bf2f0d7e84990f90b5bf2fd9f3'


def patch_loader(script):
    if script.count(UTF8_BEFORE) != 1 or UTF8_AFTER in script:
        raise ValueError('Expected exactly one known Emscripten UTF8 decoder call')
    return script.replace(UTF8_BEFORE, UTF8_AFTER)


def staged_checksums(version, published):
    result = published.copy()
    if version == '0.17.12':
        result['crispembed_ocr.js'] = PATCHED_17_12_JS_SHA256
    return result

REQUIRED_EXPORTS = ('_wasm_ocr_version', '_wasm_ocr_init',
                    '_wasm_ocr_recognize_gray', '_wasm_ocr_recognize',
                    '_wasm_ocr_free', '_malloc', '_free')


def validate_runtime(files):
    script = files['crispembed_ocr.js'].decode('utf-8')
    if 'CrispEmbedOCR' not in script or any(name not in script for name in REQUIRED_EXPORTS):
        raise ValueError('OCR loader does not expose the app factory/native exports')
    if any(name not in script for name in ('ccall', 'UTF8ToString', 'FS', 'HEAPF32', 'HEAPU8')):
        raise ValueError('OCR loader lacks required Emscripten runtime methods')
    if not files['crispembed_ocr.wasm'].startswith(b'\x00asm\x01\x00\x00\x00'):
        raise ValueError('OCR runtime is not a WebAssembly v1 module')


def download(url):
    with urllib.request.urlopen(url, timeout=120) as response:
        return response.read()


def stage(root=Path('.'), *, fetch=download, source_revision=None, environment=None):
    environment = os.environ if environment is None else environment
    if (environment.get('GITHUB_ACTIONS') != 'true'
            or environment.get('RUNNER_ENVIRONMENT') != 'github-hosted'):
        raise ValueError('OCR WASM downloads are restricted to GitHub-hosted builds')
    lock = json.loads((root / 'tool/dependency_lock.json').read_text())['crispembed']
    plugin = root / '.ci/CrispEmbed'
    revision = source_revision or subprocess.check_output(
        ['git', '-C', str(plugin), 'rev-parse', 'HEAD'], text=True).strip()
    if revision != lock['revision'] or not re.fullmatch(r'[a-f0-9]{40}', revision):
        raise ValueError('OCR source checkout differs from the dependency lock')
    version_match = re.search(r'^version:\s*([^\s+]+)',
                             (plugin / 'flutter/crispembed/pubspec.yaml').read_text(), re.M)
    if version_match is None or version_match[1] != lock['version']:
        raise ValueError('OCR plugin version differs from the dependency lock')
    version = lock['version']
    checksums = json.loads((root / 'tool/ocr_runtime_checksums.json').read_text())[version]
    files = {}
    for asset in ASSETS:
        expected = checksums[asset]
        if not re.fullmatch(r'[a-f0-9]{64}', expected):
            raise ValueError('Invalid pinned OCR asset checksum')
        url = f'https://github.com/CrispStrobe/CrispEmbed/releases/download/v{version}/{asset}'
        data = fetch(url)
        if hashlib.sha256(data).hexdigest() != expected:
            raise ValueError(f'Checksum mismatch for {asset}')
        files[asset] = data
    downloaded = {name: hashlib.sha256(data).hexdigest() for name, data in files.items()}
    patch = None
    if version == '0.17.12':
        files['crispembed_ocr.js'] = patch_loader(files['crispembed_ocr.js'])
        patch = {'upstream': PATCH_SOURCE, 'sourceCommit': PATCH_SOURCE_COMMIT,
                 'ruleSha256': PATCH_RULE_SHA256, 'replacements': 1}
    validate_runtime(files)
    web = root / 'web'
    web.mkdir(exist_ok=True)
    # Verify the complete pair before replacing either tracked runtime file.
    with tempfile.TemporaryDirectory(prefix='.verified-ocr-', dir=web) as temporary:
        for name, data in files.items():
            (Path(temporary) / name).write_bytes(data)
        for name in ASSETS:
            (Path(temporary) / name).replace(web / name)
    report = {'source': environment.get('GITHUB_SHA'), 'crispembedSource': revision,
              'version': version, 'release': f'https://github.com/CrispStrobe/CrispEmbed/releases/tag/v{version}',
              'assets': {name: {'sha256': hashlib.sha256((web / name).read_bytes()).hexdigest(),
                                'bytes': (web / name).stat().st_size} for name in ASSETS},
              'checksumsVerified': True, 'downloadedAssets': downloaded,
              'compatibilityPatch': patch,
              'runtimeCompatibility': 'Factory/export presence verified; live module initialization is a separate browser check.'}
    (web / 'crispembed-ocr-runtime.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report))
    return report


if __name__ == '__main__':
    stage()
