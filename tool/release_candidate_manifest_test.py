from pathlib import Path
import json
import subprocess
import tempfile
import unittest
from release_candidate_manifest import manifest


class ReleaseCandidateManifestTest(unittest.TestCase):
    def setUp(self):
        declaration = next(line for line in Path('pubspec.yaml').read_text().splitlines()
                           if line.startswith('version:'))
        self.version, build = declaration.split(':', 1)[1].strip().split('+')
        self.build = int(build)
        self.dependency_lock = json.loads(Path('tool/dependency_lock.json').read_text())

    def test_candidate_tracks_the_exact_source_and_dependencies(self):
        candidate = manifest(Path.cwd(), f'v{self.version}-rc.3')
        self.assertEqual(candidate['app_version'], self.version)
        self.assertEqual(candidate['build_number'], self.build)
        self.assertEqual(candidate['source_revision'], subprocess.check_output(
            ['git', 'rev-parse', 'HEAD'], text=True).strip())
        self.assertEqual(candidate['dependencies'], self.dependency_lock)
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
                manifest(root, f'v{self.version}-rc.3')

    def test_mismatched_or_unsafe_labels_are_rejected(self):
        mismatched = '999.999.999' if self.version != '999.999.999' else '998.999.999'
        for label in [f'v{mismatched}-rc.1', f'v{self.version}-rc.0',
                      f'v{self.version};echo leaked', f'../v{self.version}']:
            with self.subTest(label=label), self.assertRaises(ValueError):
                manifest(Path.cwd(), label)

    def test_release_label_uses_the_same_app_version(self):
        self.assertEqual(manifest(Path.cwd(), f'v{self.version}')['distribution'], 'release artifact')


if __name__ == '__main__':
    unittest.main()
