from pathlib import Path
import json
import tempfile
import unittest
from release_candidate_manifest import manifest


class ReleaseCandidateManifestTest(unittest.TestCase):
    def test_candidate_tracks_the_exact_source_and_dependencies(self):
        candidate = manifest(Path.cwd(), 'v1.2.0-rc.3')
        self.assertEqual(candidate['app_version'], '1.2.0')
        self.assertEqual(candidate['build_number'], 13)
        self.assertEqual(len(candidate['source_revision']), 40)
        self.assertEqual(candidate['dependencies']['crispembed']['version'], '0.17.11')
        self.assertIn('crispembed-linux-x86_64.tar.gz', candidate['ocr_runtime_sha256'])

    def test_constraint_solver_pin_must_match_the_dependency_lock(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'tool').mkdir()
            lock = json.loads(Path('tool/dependency_lock.json').read_text())
            (root / 'tool/dependency_lock.json').write_text(json.dumps(lock))
            pubspec = Path('pubspec.yaml').read_text()
            (root / 'pubspec.yaml').write_text(pubspec.replace(lock['dart_csp']['revision'], 'main'))
            with self.assertRaisesRegex(ValueError, 'dart_csp revision differs'):
                manifest(root, 'v1.2.0-rc.3')

    def test_mismatched_or_unsafe_labels_are_rejected(self):
        for label in ['v1.1.1-rc.1', 'v1.2.0-rc.0', 'v1.2.0;echo leaked', '../v1.2.0']:
            with self.subTest(label=label), self.assertRaises(ValueError):
                manifest(Path.cwd(), label)

    def test_release_label_uses_the_same_app_version(self):
        self.assertEqual(manifest(Path.cwd(), 'v1.2.0')['distribution'], 'release artifact')


if __name__ == '__main__':
    unittest.main()
