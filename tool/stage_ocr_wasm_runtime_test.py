"""Fail-closed WASM staging controls; no models, binaries or network downloads."""
import hashlib
import json
from pathlib import Path
import tempfile
import unittest

from stage_ocr_wasm_runtime import REQUIRED_EXPORTS, UTF8_BEFORE, UTF8_AFTER, patch_loader, stage

REVISION = 'a' * 40


class StageOcrWasmRuntimeTest(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        (self.root / 'tool').mkdir()
        self.plugin = self.root / '.ci/CrispEmbed/flutter/crispembed'
        self.plugin.mkdir(parents=True)
        (self.plugin / 'pubspec.yaml').write_text('version: 0.17.12\n')
        (self.root / 'tool/dependency_lock.json').write_text(json.dumps(
            {'crispembed': {'revision': REVISION, 'version': '0.17.12'}}))
        self.files = {'crispembed_ocr.js': ('CrispEmbedOCR ' + ' '.join(REQUIRED_EXPORTS)
                      + ' ccall UTF8ToString FS HEAPF32 HEAPU8 ').encode() + UTF8_BEFORE,
                      'crispembed_ocr.wasm': b'\x00asm\x01\x00\x00\x00fixture'}
        self.write_checksums()
        self.calls = []
        (self.root / 'web').mkdir()
        for name in self.files:
            (self.root / 'web' / name).write_bytes(b'old unverified runtime')

    def write_checksums(self):
        (self.root / 'tool/ocr_runtime_checksums.json').write_text(json.dumps(
            {'0.17.12': {name: hashlib.sha256(data).hexdigest()
                         for name, data in self.files.items()}}))

    def fetch(self, url):
        self.calls.append(url)
        return self.files[url.rsplit('/', 1)[1]]

    def check(self, **kwargs):
        return stage(self.root, fetch=self.fetch, source_revision=REVISION,
                     environment={'RUNNER_ENVIRONMENT': 'github-hosted', 'GITHUB_ACTIONS': 'true', 'GITHUB_SHA': 'b' * 40}, **kwargs)

    def assert_old_pair_untouched(self):
        for name in self.files:
            self.assertEqual((self.root / 'web' / name).read_bytes(), b'old unverified runtime')
        self.assertFalse((self.root / 'web/crispembed-ocr-runtime.json').exists())

    def test_complete_verified_pair_and_actual_hash_report(self):
        report = self.check()
        self.assertEqual(report['version'], '0.17.12')
        self.assertEqual(report['crispembedSource'], REVISION)
        self.assertEqual(len(self.calls), 2)
        for name, data in self.files.items():
            actual = patch_loader(data) if name.endswith('.js') else data
            self.assertEqual((self.root / 'web' / name).read_bytes(), actual)
            self.assertEqual(report['assets'][name]['sha256'], hashlib.sha256(actual).hexdigest())
            self.assertEqual(report['downloadedAssets'][name], hashlib.sha256(data).hexdigest())
            self.assertIn('/v0.17.12/', next(url for url in self.calls if url.endswith(name)))

    def test_unknown_duplicate_and_already_patched_calls_reject(self):
        for script in (b'unknown', UTF8_BEFORE + UTF8_BEFORE, UTF8_AFTER):
            with self.subTest(script=script), self.assertRaises(ValueError):
                patch_loader(script)

    def test_local_execution_cannot_download_or_fall_back(self):
        with self.assertRaisesRegex(ValueError, 'GitHub-hosted'):
            stage(self.root, fetch=self.fetch, environment={})
        self.assertEqual(self.calls, [])
        self.assert_old_pair_untouched()

    def test_self_hosted_runner_cannot_download(self):
        with self.assertRaisesRegex(ValueError, 'GitHub-hosted'):
            stage(self.root, fetch=self.fetch,
                  environment={'GITHUB_ACTIONS': 'true', 'RUNNER_ENVIRONMENT': 'self-hosted'})
        self.assertEqual(self.calls, [])
        self.assert_old_pair_untouched()

    def test_wrong_source_cannot_download(self):
        with self.assertRaisesRegex(ValueError, 'source checkout'):
            stage(self.root, fetch=self.fetch, source_revision='c' * 40,
                  environment={'RUNNER_ENVIRONMENT': 'github-hosted', 'GITHUB_ACTIONS': 'true'})
        self.assertEqual(self.calls, [])
        self.assert_old_pair_untouched()

    def test_wrong_plugin_version_cannot_download(self):
        (self.plugin / 'pubspec.yaml').write_text('version: 0.17.11\n')
        with self.assertRaisesRegex(ValueError, 'plugin version'):
            self.check()
        self.assertEqual(self.calls, [])
        self.assert_old_pair_untouched()

    def test_corrupt_second_asset_prevents_replacing_first(self):
        self.files['crispembed_ocr.wasm'] += b'corruption'
        with self.assertRaisesRegex(ValueError, 'Checksum mismatch'):
            self.check()
        self.assert_old_pair_untouched()

    def test_network_failure_never_keeps_old_runtime_as_success(self):
        def failure(url):
            raise OSError('download unavailable')
        with self.assertRaises(OSError):
            stage(self.root, fetch=failure, source_revision=REVISION,
                  environment={'RUNNER_ENVIRONMENT': 'github-hosted', 'GITHUB_ACTIONS': 'true'})
        self.assert_old_pair_untouched()

    def test_checked_but_incompatible_wrapper_is_rejected(self):
        for missing in ('CrispEmbedOCR', '_wasm_ocr_recognize_gray', 'HEAPF32'):
            original = self.files['crispembed_ocr.js']
            self.files['crispembed_ocr.js'] = original.replace(missing.encode(), b'')
            self.write_checksums()
            with self.subTest(missing=missing), self.assertRaisesRegex(ValueError, 'loader'):
                self.check()
            self.assert_old_pair_untouched()
            self.files['crispembed_ocr.js'] = original

    def test_checked_non_wasm_payload_is_rejected(self):
        self.files['crispembed_ocr.wasm'] = b'not wasm'
        self.write_checksums()
        with self.assertRaisesRegex(ValueError, 'WebAssembly'):
            self.check()
        self.assert_old_pair_untouched()


if __name__ == '__main__':
    unittest.main()
