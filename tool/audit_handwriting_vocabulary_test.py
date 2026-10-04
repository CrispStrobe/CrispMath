import copy
from types import SimpleNamespace
import unittest
from unittest.mock import patch

from audit_handwriting_vocabulary import (MODELS, audit, coverage, metadata,
                                         representable)


def reader():
    fields = {'general.architecture': 'posformer',
              'tokenizer.tokens': ['<pad>', '<sos>', '<eos>', 'x', '+', '1'],
              'posformer.decoder.vocab_size': 6,
              'posformer.decoder.pad_token': 0,
              'posformer.decoder.sos_token': 1,
              'posformer.decoder.eos_token': 2}
    fields.update({'posformer.decoder.d_model': 256, 'posformer.decoder.nhead': 8,
                   'posformer.decoder.max_len': 200, 'posformer.encoder.input_channels': 1})
    return SimpleNamespace(fields={k: SimpleNamespace(contents=lambda v=v: v)
                                   for k, v in fields.items()},
                           tensors=[SimpleNamespace(name='dec.proj.bias', shape=[6]),
                                    SimpleNamespace(name='dec.proj.weight', shape=[256, 6])])


class VocabularyAuditTest(unittest.TestCase):
    def test_candidate_hash_cannot_be_replaced_by_baseline_or_changed_manifest(self):
        def forbid_reader(*args, **kwargs):
            self.fail('Weights must not be opened before identity checks pass')
        with patch.dict('sys.modules', {'gguf': SimpleNamespace(GGUFReader=forbid_reader)}):
            with patch('audit_handwriting_vocabulary.file_hash',
                       return_value=MODELS['crohme-q8']):
                with self.assertRaisesRegex(ValueError, 'Unpinned weights'):
                    audit('candidate.gguf', 'manifest.json', 'mathwriting-v2')
            with patch('audit_handwriting_vocabulary.file_hash',
                       side_effect=[MODELS['mathwriting-v2'], 'd' * 64]):
                with self.assertRaisesRegex(ValueError, 'Frozen manifest changed'):
                    audit('candidate.gguf', 'manifest.json', 'mathwriting-v2')
            with self.assertRaisesRegex(ValueError, 'Unknown pinned model identity'):
                audit('candidate.gguf', 'manifest.json', 'unknown-model')

    def test_actual_metadata_requires_consistent_tokenizer_and_tensor_dimensions(self):
        self.assertEqual(metadata(reader())['vocab_size'], 6)
        for mutation in ('field', 'vocab', 'projection', 'architecture', 'special'):
            value = reader()
            if mutation == 'field':
                del value.fields['tokenizer.tokens']
            elif mutation == 'vocab':
                value.fields['posformer.decoder.vocab_size'].contents = lambda: 7
            elif mutation == 'projection':
                value.tensors[1].shape = [256, 7]
            elif mutation == 'architecture':
                value.fields['general.architecture'].contents = lambda: 'bttr'
            else:
                value.fields['posformer.decoder.sos_token'].contents = lambda: 2
            with self.subTest(mutation=mutation), self.assertRaises(ValueError):
                metadata(value)

    def test_whitespace_normalization_preserves_frozen_exact_scoring(self):
        self.assertTrue(representable('x \u0120+ 1', ['x', '+', '1']))
        self.assertFalse(representable('x+2', ['x', '+', '1']))
        self.assertFalse(representable(r'\Omega', ['O', 'm', 'e', 'g', 'a']))

    def test_candidate_dimensions_are_read_from_metadata_and_unsupported_shapes_fail(self):
        candidate = reader()
        candidate.fields['posformer.decoder.d_model'].contents = lambda: 384
        candidate.tensors[1].shape = [384, 6]
        self.assertEqual(metadata(candidate)['decoder_dimensions']['d_model'], 384)
        for key, value in [('posformer.decoder.d_model', 0),
                           ('posformer.decoder.d_model', 257),
                           ('posformer.decoder.nhead', 0),
                           ('posformer.decoder.max_len', 513),
                           ('posformer.encoder.input_channels', 3)]:
            broken = reader()
            broken.fields[key].contents = lambda value=value: value
            with self.subTest(key=key, value=value), self.assertRaises(ValueError):
                metadata(broken)

    def test_missing_single_command_can_be_representable_by_multiple_tokens(self):
        self.assertTrue(representable(r'\sin', ['\\', 's', 'i', 'n']))
        self.assertTrue(representable('abcd', ['a', 'ab', 'bcd']))
        self.assertFalse(representable('abcd', ['ab', 'bc']))

    def test_full_corpus_coverage_reports_each_original_reference(self):
        corpus = {'split': 'test', 'cases': [
            {'id': str(i), 'reference_latex': r'\Omega' if i == 0 else 'x+1'}
            for i in range(50)]}
        frozen = copy.deepcopy(corpus)
        result = coverage(corpus, metadata(reader()))
        self.assertEqual(result['exact_strings_unrepresentable'], 1)
        self.assertEqual(result['lexically_representable_reference_count'], 49)
        self.assertEqual(result['cases'][0]['missing_canonical_tokens'], [r'\Omega'])
        self.assertEqual(corpus, frozen)
        corpus['cases'].pop()
        with self.assertRaises(ValueError):
            coverage(corpus, metadata(reader()))

    def test_coverage_does_not_confuse_lexical_command_gaps_with_impossibility(self):
        corpus = {'split': 'test', 'cases': [
            {'id': str(i), 'reference_latex': r'\sin'} for i in range(50)]}
        result = coverage(corpus, {'tokens': ['\\', 's', 'i', 'n']})
        self.assertEqual(result['cases_with_missing_canonical_tokens'], 50)
        self.assertEqual(result['exact_strings_unrepresentable'], 0)


if __name__ == '__main__':
    unittest.main()
