"""Negative controls for reference tensor accounting, provenance and comparisons."""
import copy
import json
import os
from pathlib import Path
import tempfile
import types
import unittest

from compare_handwriting_encoders import BRIDGE_SOURCE
from handwriting_reference_parity import (TensorStore, compare, read_trace,
                                          validate_manifest, validate_provenance)
from prepare_handwriting_reference_bridge import replace_once


@unittest.skipUnless(os.environ.get('CRISPMATH_REFERENCE_NUMERIC_CONTROLS') == '1',
                     'Numeric controls run only in the explicitly requested hosted reference job')
class NumericalReferenceControls(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        import numpy
        cls.np = numpy

    def test_tensor_names_shapes_types_and_complete_accounting(self):
        np = self.np
        tensor = types.SimpleNamespace(name='conv', shape=[6, 2], tensor_type=0,
                                       data=np.arange(12, dtype=np.float32))
        extra = types.SimpleNamespace(name='extra', shape=[1], tensor_type=0, data=np.zeros(1))
        store = TensorStore(types.SimpleNamespace(tensors=[tensor, extra]), np)
        with self.assertRaisesRegex(ValueError, 'Missing/duplicate'):
            store.get('missing', (2, 6))
        with self.assertRaisesRegex(ValueError, 'shape'):
            store.get('conv', (3, 4))
        tensor.tensor_type = 1
        with self.assertRaisesRegex(ValueError, 'F32'):
            store.get('conv', (2, 6))
        tensor.tensor_type = 0
        self.assertEqual(store.get('conv', (2, 1, 2, 3), flattened_conv=True).shape, (2, 1, 2, 3))
        with self.assertRaisesRegex(ValueError, 'Missing/duplicate'):
            store.get('conv', (2, 6))
        with self.assertRaisesRegex(ValueError, 'Unconsumed'):
            store.complete()
        store.get('extra', (1,))
        self.assertEqual(store.complete()['count'], 2)

    def test_trace_truncation_and_nonfinite_rejected(self):
        np = self.np
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp)
            (path / 'stage.shape.json').write_text('[1,2,2]')
            np.zeros(3, dtype='<f4').tofile(path / 'stage.f32')
            with self.assertRaisesRegex(ValueError, 'Truncated'):
                read_trace(path, 'stage', np)
            np.full(4, np.nan, dtype='<f4').tofile(path / 'stage.f32')
            with self.assertRaisesRegex(ValueError, 'Nonfinite'):
                read_trace(path, 'stage', np)

    def test_comparison_never_hides_missing_shape_or_large_errors(self):
        np = self.np
        a = np.arange(12, dtype=np.float32).reshape(3, 4)
        self.assertTrue(compare(a, a, (1e-5, 0), np)['matches'])
        self.assertFalse(compare(a, a[:, :-1], (1e-5, 0), np)['matches'])
        self.assertFalse(compare(a, a + 0.001, (1e-5, 0), np)['matches'])
        with self.assertRaisesRegex(ValueError, 'Nonfinite'):
            compare(a, np.full_like(a, np.inf), (1e-5, 0), np)


class ReferenceControls(unittest.TestCase):
    def test_native_source_library_patch_provenance_is_strict(self):
        p = {'bridge_source': BRIDGE_SOURCE, 'library_sha256': 'lib',
             'instrumentation_tool_sha256': 'tool', 'input_norm_patch_sha256': None,
             'mathematical_change': 'none', 'original_source_sha256': 'base',
             'instrumented_source_sha256': 'instrumented'}
        validate_provenance(p, 'lib', 'tool', 'patch')
        for key, wrong in [('bridge_source', 'wrong'), ('library_sha256', 'other'),
                           ('instrumentation_tool_sha256', 'other'), ('input_norm_patch_sha256', 'patch'),
                           ('instrumented_source_sha256', 'base')]:
            bad = copy.deepcopy(p)
            bad[key] = wrong
            with self.assertRaises(ValueError):
                validate_provenance(bad, 'lib', 'tool', 'patch')
        p.update(mathematical_change='post-position learned normalization', input_norm_patch_sha256='patch')
        validate_provenance(p, 'lib', 'tool', 'patch')
        with self.assertRaises(ValueError):
            validate_provenance(p, 'lib', 'tool', 'wrong-patch')

    def test_corpus_mutation_and_changed_native_anchors_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / 'manifest.json'
            path.write_text(json.dumps({'split': 'test', 'cases': []}))
            with self.assertRaisesRegex(ValueError, 'Changed frozen'):
                validate_manifest(path)
        for source in ('no anchor', 'marker marker'):
            with self.assertRaisesRegex(ValueError, 'anchor changed'):
                replace_once(source, 'marker', 'replacement')


if __name__ == '__main__':
    unittest.main()
