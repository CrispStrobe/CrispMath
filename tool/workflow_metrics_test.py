import unittest
from workflow_metrics import large_document, summarize


class WorkflowMetricsTest(unittest.TestCase):
    def test_percentiles_use_all_samples_and_are_order_independent(self):
        summary = summarize([5, 1, 4, 2, 3])
        self.assertEqual(summary, {'samples': 5, 'median_ms': 3, 'p95_ms': 5, 'max_ms': 5})
        self.assertEqual(summarize(list(range(1, 101)))['p95_ms'], 95)

    def test_invalid_measurements_are_rejected(self):
        for samples in [[], [-1], [float('nan')], [float('inf')]]:
            with self.subTest(samples=samples), self.assertRaises(ValueError):
                summarize(samples)

    def test_large_documents_have_unique_ids_and_a_complete_dependency_chain(self):
        document = large_document(2000)
        self.assertEqual(len(document['l']), 2000)
        self.assertEqual(len({line['i'] for line in document['l']}), 2000)
        self.assertEqual(document['l'][0]['s'], 'v0 = 1')
        self.assertEqual(document['l'][-1]['s'], 'v1999 = v1998 + 1')
        self.assertEqual(document['l'][-1]['r'], '2000')

    def test_empty_document_is_rejected(self):
        with self.assertRaises(ValueError):
            large_document(0)


if __name__ == '__main__':
    unittest.main()
