import copy
import unittest

from compare_handwriting_encoders import (BRIDGE_SOURCE, POSFORMER_SHA256,
                                         compare, tokens)
from provision_ocr_quality import DATA_SHA256, DATA_SOURCE, DATA_URL


def report(arm):
    cases = [{'id': f'case-{i}', 'image': f'{i}.png', 'reference_latex': 'x+1'}
             for i in range(50)]
    return {'encoder_arm': arm, 'encoder_environment': {
        'POSFORMER_SCALAR_ENCODER': '1' if arm == 'scalar' else None},
        'bridge_source': BRIDGE_SOURCE, 'source': 'a' * 40,
        'model': 'posformer-q8.gguf', 'model_sha256': POSFORMER_SHA256,
        'threads': 2, 'corpus_manifest_sha256': 'b' * 64,
        'corpus': {'split': 'test', 'archive_sha256': DATA_SHA256,
                   'archive_url': DATA_URL, 'dataset': DATA_SOURCE,
                   'selection': 'first 50 SHA-256 ranked IDs with fixed CrispMath-2026-10-02 seed',
                   'cases': cases},
        'scoring': 'Exact LaTeX tokens after whitespace/BPE separator removal; equivalent alternate transcriptions are not exact matches.',
        'exact_matches': 50, 'runtime_failures': 0,
        'cases': [{'id': item['id'], 'reference_latex': item['reference_latex'],
                   'latex': 'x+1', 'status': 'exact_match', 'image_sha256': 'c' * 64,
                   'image_width': 128, 'image_height': 120, 'elapsed_ms': 1}
                  for item in cases]}


class PairedEncoderReportsTest(unittest.TestCase):
    def test_identical_outputs_and_low_accuracy_remain_diagnostic(self):
        first, second = report('default'), report('scalar')
        result = compare(first, second)
        self.assertEqual(result['samples'], 50)
        self.assertEqual(result['token_output_differences'], 0)
        for value in (first, second):
            value['exact_matches'] = 0
            for item in value['cases']:
                item.update(latex='z', status='different_transcription')
        self.assertEqual(compare(first, second)['scalar_exact_matches'], 0)

    def test_raw_spacing_and_actual_token_differences_are_distinguished(self):
        first, second = report('default'), report('scalar')
        second['cases'][0]['latex'] = 'x \u0120+ 1'
        second['cases'][1].update(latex='x+2', status='different_transcription')
        second['exact_matches'] = 49
        result = compare(first, second)
        self.assertEqual(result['raw_output_differences'], 2)
        self.assertEqual(result['token_output_differences'], 1)
        self.assertNotEqual(tokens('x+1'), tokens('x+01'))

    def test_partial_duplicate_reordered_and_failed_cases_are_rejected(self):
        for mutation in ('partial', 'duplicate', 'reordered', 'failure'):
            second = report('scalar')
            if mutation == 'partial':
                second['cases'].pop()
            elif mutation == 'duplicate':
                second['cases'][1] = copy.deepcopy(second['cases'][0])
            elif mutation == 'reordered':
                second['cases'].reverse()
            else:
                second['cases'][0]['status'] = 'runtime_failure'
            with self.subTest(mutation=mutation), self.assertRaises(ValueError):
                compare(report('default'), second)

    def test_changed_weights_bridge_source_manifest_threads_or_scoring_fail(self):
        for key, value in [('model_sha256', 'd' * 64), ('bridge_source', 'd' * 40),
                           ('source', 'd' * 40), ('corpus_manifest_sha256', 'd' * 64),
                           ('threads', 4), ('scoring', 'equivalent is enough')]:
            second = report('scalar')
            second[key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                compare(report('default'), second)

    def test_labels_images_dimensions_and_frozen_selection_cannot_change(self):
        for key, value in [('reference_latex', 'x+2'), ('image_sha256', 'd' * 64),
                           ('image_width', 127), ('image_height', 119)]:
            second = report('scalar')
            second['cases'][0][key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                compare(report('default'), second)
        for key in ('selection', 'archive_sha256', 'dataset', 'split'):
            first, second = report('default'), report('scalar')
            first['corpus'][key] = second['corpus'][key] = 'changed'
            with self.subTest(key=key), self.assertRaises(ValueError):
                compare(first, second)

    def test_score_corruption_missing_hash_and_nonfinite_time_fail(self):
        for key, value in [('exact_matches', 49), ('runtime_failures', 1),
                           ('corpus_manifest_sha256', None)]:
            second = report('scalar')
            second[key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                compare(report('default'), second)
        for key, value in [('elapsed_ms', float('nan')), ('elapsed_ms', -1),
                           ('image_sha256', None), ('image_width', 0)]:
            second = report('scalar')
            second['cases'][0][key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                compare(report('default'), second)

    def test_scalar_presence_must_be_explicit_and_default_must_unset_it(self):
        for arm, value in [('default', '0'), ('scalar', None), ('scalar', '0')]:
            first, second = report('default'), report('scalar')
            target = first if arm == 'default' else second
            target['encoder_environment']['POSFORMER_SCALAR_ENCODER'] = value
            with self.subTest(arm=arm, value=value), self.assertRaises(ValueError):
                compare(first, second)


if __name__ == '__main__':
    unittest.main()
