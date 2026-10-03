"""Independent negative controls for rendered hypothesis-test row assertions."""
import unittest
from statistics_ui_reference_checks import hypothesis_rows


class HypothesisRowsControls(unittest.TestCase):
    def test_chi_square_rows_retain_nonzero_probability(self):
        successors = {'χ² statistic': 'Degrees of freedom', 'Degrees of freedom': 'p-value (upper tail)', 'p-value (upper tail)': 'Reject H₀'}
        rows = hypothesis_rows('χ² statistic 10 Degrees of freedom 1 p-value (upper tail) 0.001565 Reject H₀ at α', successors)
        self.assertEqual({label: row['value'] for label,row in rows.items()},
                         {'χ² statistic': '10', 'Degrees of freedom': '1', 'p-value (upper tail)': '0.001565'})
        wrong = hypothesis_rows('χ² statistic 10 Degrees of freedom 1 p-value (upper tail) 0 Reject H₀ at α', successors)
        self.assertNotEqual(wrong['p-value (upper tail)']['value'], rows['p-value (upper tail)']['value'])

    def test_upper_tail_cannot_be_swapped_with_two_sided(self):
        successors = {'p-value (two-sided)': 'p-value (upper tail)', 'p-value (upper tail)': 'p-value (lower tail)'}
        text = 'p-value (two-sided) 3.3333e-21 p-value (upper tail) 1.6667e-21 p-value (lower tail) 1'
        rows = hypothesis_rows(text, successors)
        self.assertEqual(rows['p-value (upper tail)']['value'], '1.6667e-21')
        self.assertEqual(rows['p-value (two-sided)']['value'], '3.3333e-21')
        self.assertNotEqual(rows['p-value (upper tail)']['value'], '0')

    def test_missing_duplicate_or_wrong_row_boundary_is_rejected(self):
        successors = {'Degrees of freedom': 'p-value (upper tail)'}
        for text in ['Degrees of freedom 1 p-value (two-sided) 0.1',
                     'Degrees of freedom 1 p-value (upper tail) 0.1 Degrees of freedom 2 p-value (upper tail) 0.2',
                     'Degrees of freedom Undefined Error']:
            with self.subTest(text=text), self.assertRaises(AssertionError):
                hypothesis_rows(text, successors)


if __name__ == '__main__':
    unittest.main()
