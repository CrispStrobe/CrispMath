"""Independent wrong-byte/provenance/API/pointer controls, without Playwright."""
import copy
import unittest
from check_ocr_wasm_runtime_browser import API_VERSION, verify_live, verify_report
from stage_ocr_wasm_runtime import PATCH_RULE_SHA256, PATCH_SOURCE, PATCH_SOURCE_COMMIT, staged_checksums


class OcrWasmBrowserTest(unittest.TestCase):
    def setUp(self):
        self.checksums = {'crispembed_ocr.js': 'a' * 64, 'crispembed_ocr.wasm': 'b' * 64}
        self.report = {'source': 'c' * 40, 'crispembedSource': 'd' * 40,
                       'version': '0.17.12', 'checksumsVerified': True,
                       'assets': {name: {'sha256': sha} for name, sha in staged_checksums('0.17.12', self.checksums).items()},
                       'downloadedAssets': self.checksums.copy(),
                       'compatibilityPatch': {'upstream': PATCH_SOURCE, 'sourceCommit': PATCH_SOURCE_COMMIT, 'ruleSha256': PATCH_RULE_SHA256, 'replacements': 1}}
        self.live = {'assets': staged_checksums('0.17.12', self.checksums), 'apiVersion': API_VERSION,
                     'unicodeControls': {'fixed': True, 'resizable': True, 'unpatchedRejected': True, 'actualPatchedUnicode': True, 'bytes': 48},
                     'allocatedPointer': 128, 'pointerRoundTrip': True, 'missingModelPointer': 0}

    def test_exact_report_and_live_module_accept(self):
        verify_report(self.report, 'c' * 40, 'd' * 40, '0.17.12', self.checksums)
        verify_live(self.live, staged_checksums('0.17.12', self.checksums))

    def test_wrong_app_source_vendor_source_release_or_verified_flag_reject(self):
        for key, value in [('source', 'e' * 40), ('crispembedSource', 'e' * 40),
                           ('version', '0.17.11'), ('checksumsVerified', False)]:
            report = copy.deepcopy(self.report)
            report[key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                verify_report(report, 'c' * 40, 'd' * 40, '0.17.12', self.checksums)

    def test_each_recorded_or_actual_asset_substitution_rejects(self):
        for name in self.checksums:
            report = copy.deepcopy(self.report)
            report['assets'][name]['sha256'] = 'f' * 64
            with self.assertRaises(ValueError):
                verify_report(report, 'c' * 40, 'd' * 40, '0.17.12', self.checksums)
            live = copy.deepcopy(self.live)
            live['assets'][name] = 'f' * 64
            with self.assertRaises(ValueError):
                verify_live(live, staged_checksums('0.17.12', self.checksums))

    def test_missing_or_wrong_actual_unicode_controls_rejects(self):
        for key in self.live['unicodeControls']:
            live = copy.deepcopy(self.live)
            live['unicodeControls'][key] = 16 if key == 'bytes' else False
            with self.subTest(key=key), self.assertRaises(ValueError):
                verify_live(live, staged_checksums('0.17.12', self.checksums))

    def test_unrecorded_or_substituted_patch_rejects(self):
        for patch in (None, {}, dict(self.report['compatibilityPatch'], ruleSha256='f' * 64)):
            report = copy.deepcopy(self.report)
            report['compatibilityPatch'] = patch
            with self.assertRaises(ValueError):
                verify_report(report, 'c' * 40, 'd' * 40, '0.17.12', self.checksums)

    def test_wrong_api_invalid_pointer_heap_and_model_guard_reject(self):
        for key, value in [('apiVersion', '0.17.12'), ('allocatedPointer', 0),
                           ('pointerRoundTrip', False), ('missingModelPointer', 123)]:
            live = copy.deepcopy(self.live)
            live[key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                verify_live(live, staged_checksums('0.17.12', self.checksums))


if __name__ == '__main__':
    unittest.main()
