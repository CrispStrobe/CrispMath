"""The generated README facts must track their canonical sources."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

MODULE = Path(__file__).resolve().parent / 'update_readme_facts.py'
spec = importlib.util.spec_from_file_location('update_readme_facts', MODULE)
facts_module = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(facts_module)

README = """\
Version <!-- AUTO:app_version -->0.0.0<!-- /AUTO:app_version -->
build <!-- AUTO:build_number -->0<!-- /AUTO:build_number -->
full <!-- AUTO:app_version_build -->0+0<!-- /AUTO:app_version_build -->
tag <!-- AUTO:latest_tag -->v0<!-- /AUTO:latest_tag -->
flutter <!-- AUTO:flutter_version -->0<!-- /AUTO:flutter_version -->
embed <!-- AUTO:crispembed_revision -->0<!-- /AUTO:crispembed_revision -->
bridge <!-- AUTO:bridge_revision -->0<!-- /AUTO:bridge_revision -->
csp <!-- AUTO:dart_csp_version -->0<!-- /AUTO:dart_csp_version -->
tests <!-- AUTO:test_file_count -->0<!-- /AUTO:test_file_count -->
functions <!-- AUTO:function_entry_count -->0<!-- /AUTO:function_entry_count -->
"""


def tree(root):
    (root / 'tool').mkdir(parents=True)
    (root / 'lib/engine').mkdir(parents=True)
    (root / 'test').mkdir()
    (root / 'pubspec.yaml').write_text('name: x\nversion: 1.2.0+27\n')
    (root / 'tool/dependency_lock.json').write_text(json.dumps({
        'flutter': '3.44.0',
        'crispembed': {'revision': 'a' * 40, 'version': '0.17.12'},
        'symbolic_math_bridge': {'revision': 'b' * 40},
        'dart_csp': {'revision': 'c' * 40, 'version': '2.3.0'},
    }))
    (root / 'lib/engine/function_reference.dart').write_text(
        "      id: 'diff',\n      id: 'integrate',\n")
    for name in ('a_test.dart', 'b_test.dart'):
        (root / 'test' / name).write_text('')


class FactsTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        tree(self.root)
        self.values = facts_module.facts(self.root, tag='v1.2.0')

    def tearDown(self):
        self.tmp.cleanup()

    def test_reads_the_canonical_sources(self):
        self.assertEqual(self.values['app_version'], '1.2.0')
        self.assertEqual(self.values['build_number'], '27')
        self.assertEqual(self.values['app_version_build'], '1.2.0+27')
        self.assertEqual(self.values['flutter_version'], '3.44.0')
        self.assertEqual(self.values['bridge_revision'], 'b' * 40)
        self.assertEqual(self.values['dart_csp_version'], '2.3.0 (ccccccc)')
        self.assertEqual(self.values['test_file_count'], '2')
        self.assertEqual(self.values['function_entry_count'], '2')
        self.assertEqual(self.values['latest_tag'], 'v1.2.0')

    def test_render_replaces_only_the_marked_spans(self):
        out = facts_module.render(README, self.values)
        self.assertIn('Version <!-- AUTO:app_version -->1.2.0<!-- /AUTO:app_version -->', out)
        self.assertIn('build <!-- AUTO:build_number -->27<!-- /AUTO:build_number -->', out)
        self.assertIn('tag <!-- AUTO:latest_tag -->v1.2.0<!-- /AUTO:latest_tag -->', out)
        self.assertIn('tests <!-- AUTO:test_file_count -->2<!-- /AUTO:test_file_count -->', out)
        self.assertIn('functions <!-- AUTO:function_entry_count -->2<!-- /AUTO:function_entry_count -->', out)

    def test_render_is_idempotent(self):
        once = facts_module.render(README, self.values)
        self.assertEqual(facts_module.render(once, self.values), once)

    def test_missing_marker_is_reported(self):
        with self.assertRaisesRegex(KeyError, 'marker missing for: unused_fact'):
            facts_module.render(README, dict(self.values, unused_fact='x'))

    def test_unknown_marker_is_reported(self):
        with self.assertRaisesRegex(KeyError, 'no source for AUTO:flavour'):
            facts_module.render(
                '<!-- AUTO:flavour -->x<!-- /AUTO:flavour -->', self.values)


if __name__ == '__main__':
    unittest.main()
