"""Independent controls for strict actual-worksheet Taylor comparisons."""
from fractions import Fraction
import unittest

from round7_reference_checks import polynomial_coefficients, validate_result


class TaylorReferenceControls(unittest.TestCase):
    def test_shifted_forms_match_independent_coefficients(self):
        expected = [Fraction(15,16), Fraction(-11,16), Fraction(5,16), Fraction(-1,16)]
        for source in ['(-x^3+5*x^2-11*x+15)/16',
                       '1/2-(x-1)/4+(x-1)^2/8-(x-1)^3/16',
                       '15/16-11*x/16+5*x²/16-x³/16',
                       '-1/16x³+5/16x²-11/16x+15/16',
                       '15/16-(11/16)x+(5/16)x²-(1/16)x³']:
            with self.subTest(source=source):
                self.assertEqual(polynomial_coefficients(source), expected)

    def test_wrong_coefficients_fail_actual_reference(self):
        case = ('shifted-rational-taylor', 'series(1/(1+x),x,1,4)',
                [Fraction(15,16), Fraction(-11,16), Fraction(5,16), Fraction(-1,16)])
        for wrong in ['(-x^3+5*x^2-10*x+15)/16',
                      '(-x^3+5*x^2-11*x+15)/16+x^4/1000000']:
            with self.subTest(wrong=wrong), self.assertRaises(AssertionError):
                validate_result(case, {'s': case[1], 'r': wrong, 'f': ['x']})

    def test_unsupported_inputs_are_rejected(self):
        for source in ['1-y^2', '1-x^2+y-y', 'sin(x)', '1/(1+x)',
                       'x^-1', 'x^1000000', 'x¹⁰', 'x²⁰', '__import__("os")']:
            with self.subTest(source=source), self.assertRaises((AssertionError, SyntaxError)):
                polynomial_coefficients(source)

    def test_principal_root_exact_components(self):
        case = ('principal-squared-root', 'sqrt((-3+4*I)^2)', '3-4*I')
        for result in ['3.0-4.0I', '-4I+3', '(3-4*I)', '3-8/2I', '3.0-4.0i']:
            validate_result(case, {'s': case[1], 'r': result})
        for result in ['-3+4I', '3-4.0001I', '3', '3-4I+I^2', 'Error']:
            with self.subTest(result=result), self.assertRaises(AssertionError):
                validate_result(case, {'s': case[1], 'r': result})

    def test_conjugate_accepts_only_correct_imaginary_components(self):
        case = ('complex-conjugate', 'conjugate((2+3*I)/(1-2*I))', [Fraction(-4,5), Fraction(-7,5)])
        for result in ['-4/5 - 7/5i', '-4/5-7/5*I', '-0.8-1.4i']:
            validate_result(case, {'s': case[1], 'r': result})
        for result in ['-4/5+7/5i', '-4/5', '-4/5-7/5i+i^2']:
            with self.subTest(result=result), self.assertRaises(AssertionError):
                validate_result(case, {'s': case[1], 'r': result})

    def test_source_hole_root_is_excluded(self):
        case = ('source-hole-root', 'solve((x-1)^2*(x+2)/(x-1),x)', '-2')
        validate_result(case, {'s': case[1], 'r': 'x = {-2}'})
        for result in ['x = {1,-2}', 'x = 1', 'x = {-2,-2}']:
            with self.subTest(result=result), self.assertRaises(AssertionError):
                validate_result(case, {'s': case[1], 'r': result})

    def test_inverse_retains_each_exact_coefficient(self):
        expected = [[10000000000000001, -10000000000000000],
                    [-10000000000000000, 10000000000000000]]
        case = ('near-singular-inverse', 'inv(Matrix([[1,1],[1,1.0000000000000001]]))', expected)
        good = 'Matrix([[10000000000000001,-10000000000000000],[-10000000000000000,10000000000000000]])'
        validate_result(case, {'s': case[1], 'r': good, 'evidence': {'accuracy': 'exact'}})
        for wrong in [good.replace('10000000000000001', '10000000000000000'),
                      'Matrix([[9.938978e15,-9.938978e15],[-9.938978e15,9.938978e15]])']:
            with self.subTest(result=wrong), self.assertRaises(AssertionError):
                validate_result(case, {'s': case[1], 'r': wrong, 'evidence': {'accuracy': 'exact'}})

    def test_formal_badges_follow_defined_global_only(self):
        case = ('reactive-nonlinear-taylor', 'taylor(abs(x^2-p),x,0,5)', [4, 0, -1])
        validate_result(case, {'s': case[1], 'r': '4-x²', 'f': []})
        with self.assertRaises(AssertionError):
            validate_result(case, {'s': case[1], 'r': '4-x²', 'f': ['x']})
        unbound = ('nonlinear-local-taylor', 'series(abs(x^2-1),x,0,5)', [1, 0, -1])
        validate_result(unbound, {'s': unbound[1], 'r': '1-x²', 'f': ['x']})
        with self.assertRaises(AssertionError):
            validate_result(unbound, {'s': unbound[1], 'r': '1-x²', 'f': []})

    def test_lost_tiny_result_and_false_exactness_fail(self):
        case = ('subnormal-exact-root', 'sqrt(1e-320)', Fraction(1, 10**160))
        validate_result(case, {'s': case[1], 'r': '1e-160', 'evidence': {'accuracy': 'exact'}})
        for value, accuracy in [('0', 'exact'), ('1e-160', 'approximate')]:
            with self.subTest(value=value, accuracy=accuracy), self.assertRaises(AssertionError):
                validate_result(case, {'s': case[1], 'r': value, 'evidence': {'accuracy': accuracy}})


if __name__ == '__main__':
    unittest.main()
