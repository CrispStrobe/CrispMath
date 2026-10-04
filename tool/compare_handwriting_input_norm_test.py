import unittest
from compare_handwriting_encoders_test import report
from compare_handwriting_input_norm import compare
from audit_handwriting_vocabulary import FROZEN_MANIFEST_SHA256


def pair():
    before, after = report('default'), report('default')
    for item in (before, after):
        item['corpus_manifest_sha256'] = FROZEN_MANIFEST_SHA256
    before.update(library_sha256='a' * 64, bridge_patch_sha256=None)
    after.update(library_sha256='b' * 64, bridge_patch_sha256='d' * 64)
    controls = {'library_sha256': 'b' * 64, 'cases': [
        {'dimension': d, 'status': 'passed', 'max_absolute_error': 1e-6,
         'negative_control_distances': {'missing_norm': 1, 'wrong_order': 2,
                                        'missing_learned_affine': 3}} for d in (256, 384)]}
    return before, after, controls


class InputNormEvidenceTest(unittest.TestCase):
    def test_paired_no_change_is_diagnostic_not_a_quality_claim(self):
        result = compare(*pair(), 'd' * 64, 'crohme-q8')
        self.assertEqual(result['token_output_differences'], 0)
        self.assertEqual(result['samples'], 50)

    def test_wrong_patch_baseline_patch_and_unchanged_library_fail(self):
        for key, value in [('bridge_patch_sha256', 'e' * 64),
                           ('library_sha256', 'a' * 64), ('library_sha256', None)]:
            before, after, controls = pair()
            after[key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                compare(before, after, controls, 'd' * 64, 'crohme-q8')
        before, after, controls = pair()
        before['bridge_patch_sha256'] = 'd' * 64
        with self.assertRaises(ValueError):
            compare(before, after, controls, 'd' * 64, 'crohme-q8')

    def test_control_wrong_library_missing_dimension_or_math_failure_fail(self):
        for mutation in ('library', 'dimension', 'error', 'order', 'nan'):
            before, after, controls = pair()
            if mutation == 'library': controls['library_sha256'] = 'e' * 64
            elif mutation == 'dimension': controls['cases'].pop()
            elif mutation == 'error': controls['cases'][0]['max_absolute_error'] = .1
            elif mutation == 'nan': controls['cases'][0]['max_absolute_error'] = float('nan')
            else: controls['cases'][0]['negative_control_distances']['wrong_order'] = 0
            with self.subTest(mutation=mutation), self.assertRaises(ValueError):
                compare(before, after, controls, 'd' * 64, 'crohme-q8')

    def test_frozen_manifest_labels_images_source_and_incomplete_cases_fail(self):
        for mutation in ('manifest', 'label', 'image', 'source', 'partial'):
            before, after, controls = pair()
            if mutation == 'manifest': after['corpus_manifest_sha256'] = 'e' * 64
            elif mutation == 'label': after['cases'][0]['reference_latex'] = 'z'
            elif mutation == 'image': after['cases'][0]['image_sha256'] = 'e' * 64
            elif mutation == 'source': after['source'] = 'e' * 40
            else: after['cases'].pop()
            with self.subTest(mutation=mutation), self.assertRaises(ValueError):
                compare(before, after, controls, 'd' * 64, 'crohme-q8')


if __name__ == '__main__':
    unittest.main()
