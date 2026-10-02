import copy
import unittest
from check_workflow_performance import compare


def report(samples=None):
    return {'source': 'test', 'status': 'passed', 'trials': 3,
            'profiles': [{'profile': 'desktop', 'cpu': 1, 'status': 'passed',
                          'notepad': [{'rows': 500,
                                       'edit_to_saved_result_ms': samples or [600, 650, 900]}]}]}


class PerformanceCheckTest(unittest.TestCase):
    def test_runner_noise_and_single_outlier_are_tolerated(self):
        self.assertTrue(compare(report([800, 850, 10000]), report())['passed'])

    def test_sustained_slowdown_fails(self):
        result = compare(report([4000, 4400, 5000]), report())
        self.assertFalse(result['passed'])
        self.assertEqual(result['checks'][0]['medianMs'], 4400)

    def test_missing_coverage_and_failed_or_short_runs_are_rejected(self):
        for mutation in [lambda r: r.update(status='failed'),
                         lambda r: r.update(trials=1),
                         lambda r: r['profiles'][0].update(cpu=4),
                         lambda r: r['profiles'][0]['notepad'][0].update(edit_to_saved_result_ms=[5])]:
            changed = copy.deepcopy(report())
            mutation(changed)
            with self.assertRaises(ValueError):
                compare(changed, report())
