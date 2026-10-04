import copy
import unittest

from check_posformer_pooling import CASE_IDS, SHAPES
from compare_handwriting_forward_repair import ORIGINAL_SOURCE_SHA256, compare
from compare_handwriting_encoders import BRIDGE_SOURCE
from compare_handwriting_input_norm_test import pair


def pooling():
    return {'library_sha256': 'b' * 64, 'invalid_arguments_rejected': True, 'cases': [
        {'id': identifier, 'input_shape': [c, h, w],
         'output_shape': [c, (h + 1) // 2, (w + 1) // 2], 'status': 'passed',
         'max_absolute_error': 1e-7, 'floor_rejected': True, 'zero_padding_rejected': True}
        for identifier, (c, h, w) in zip(CASE_IDS, SHAPES * 2)]}


class ForwardRepairEvidenceTest(unittest.TestCase):
    def provenance(self):
        return {'source': pair()[0]['source'], 'bridge_source': BRIDGE_SOURCE,
                'original_source_sha256': ORIGINAL_SOURCE_SHA256, 'patched_source_sha256': 'c' * 64,
                'patch_sha256': 'd' * 64, 'library_sha256': 'b' * 64}

    def test_complete_paired_evidence_is_diagnostic(self):
        result = compare(*pair(), pooling(), 'd' * 64, 'crohme-q8', self.provenance())
        self.assertEqual(result['samples'], 50)
        self.assertEqual(result['pooling_control_cases'], 16)

    def test_changed_pool_library_shapes_and_negative_controls_fail(self):
        for change in ('library', 'partial', 'abi', 'shape', 'error', 'nan', 'floor', 'zero'):
            p = copy.deepcopy(pooling())
            if change == 'library': p['library_sha256'] = 'e' * 64
            elif change == 'partial': p['cases'].pop()
            elif change == 'abi': p['invalid_arguments_rejected'] = False
            elif change == 'shape': p['cases'][1]['output_shape'] = [1, 1, 3]
            elif change == 'error': p['cases'][0]['max_absolute_error'] = 0.1
            elif change == 'nan': p['cases'][0]['max_absolute_error'] = float('nan')
            elif change == 'floor': p['cases'][1]['floor_rejected'] = False
            else: p['cases'][1]['zero_padding_rejected'] = False
            with self.subTest(change=change), self.assertRaises(ValueError):
                compare(*pair(), p, 'd' * 64, 'crohme-q8', self.provenance())

    def test_changed_native_source_patch_library_rejected(self):
        for key, wrong in [('source', 'e' * 40), ('bridge_source', 'e' * 40),
                           ('original_source_sha256', 'e' * 64), ('patch_sha256', 'e' * 64),
                           ('library_sha256', 'e' * 64), ('patched_source_sha256', ORIGINAL_SOURCE_SHA256)]:
            p = self.provenance()
            p[key] = wrong
            with self.subTest(key=key), self.assertRaises(ValueError):
                compare(*pair(), pooling(), 'd' * 64, 'crohme-q8', p)


if __name__ == '__main__':
    unittest.main()
