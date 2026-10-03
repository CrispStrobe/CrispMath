import copy
import json
import unittest
from extract_workflow_report import BEGIN, END, extract, verify

class PackagedReportTest(unittest.TestCase):
    def report(self):
        return {'schemaVersion': 2, 'nativeBridge': True, 'total': 2, 'passed': 2,
                'failed': 0, 'unsupported': 0,
                'results': [{'id': 'one', 'status': 'passed'}, {'id': 'two', 'status': 'passed'}]}
    def framed(self, report):
        return 'Native startup diagnostic\n'+BEGIN+'\n'+json.dumps(report)+'\n'+END+'\n2 passed\n'
    def test_native_log_noise_is_ignored_and_all_results_preserved(self):
        report = extract(self.framed(self.report()))
        self.assertEqual(report, self.report())
        verify(report, 2)
    def test_partial_and_repeated_reports_are_rejected(self):
        for text in [BEGIN+'\n{}', self.framed(self.report())*2, BEGIN+'\n{}\n'+END]:
            with self.subTest(text=text), self.assertRaises(ValueError):
                extract(text)
    def test_no_fallback_failures_missing_results_or_duplicate_ids_can_pass(self):
        for update in [{'nativeBridge': False}, {'failed': 1}, {'unsupported': 1},
                       {'passed': 1}, {'total': 3}, {'results': []},
                       {'results': [{'id': 'one', 'status': 'passed'}]*2},
                       {'results': [{'id': 'one', 'status': 'failed'}, {'id': 'two', 'status': 'passed'}]}]:
            report = copy.deepcopy(self.report())
            report.update(update)
            with self.subTest(update=update), self.assertRaises(ValueError):
                verify(report, 2)

if __name__ == '__main__':
    unittest.main()
