"""Independent negative controls for frozen round-eight worksheet answers."""
from fractions import Fraction
import unittest

from round8_reference_checks import CASES, validate_result, matrix_values, normal_cdf_display


class RoundEightReferenceControls(unittest.TestCase):
    def case(self, name):
        return next(case for case in CASES if case[0] == name)

    def check_value(self, name, result, **metadata):
        case = self.case(name)
        validate_result(case, {'s': case[1], 'r': result, **metadata})

    def reject_values(self, name, values, **metadata):
        for result in values:
            with self.subTest(name=name, result=result), self.assertRaises((AssertionError, SyntaxError)):
                self.check_value(name, result, **metadata)

    def test_principal_complex_branches_and_conjugation(self):
        self.check_value('principal-root-product', '-12')
        self.check_value('negative-complex-power', '-0.25-0.25i')
        self.check_value('cubic-conjugate', '2I-2')
        self.reject_values('principal-root-product', ['12', '-12.0001'])
        self.reject_values('negative-complex-power', ['-1/4+I/4', '-1/4', '-I/4-1/4+I^2'])
        self.reject_values('cubic-conjugate', ['-2-2i', '2+2i'])

    def test_principal_log_keeps_pi_and_sign(self):
        for result in ['-pi*I/2', '-πi/2', '-1/2πi', '-1.5707963267948966i']:
            self.check_value('principal-imaginary-log', result)
        self.reject_values('principal-imaginary-log', ['pi*I/2', '-3*pi*I/2', '1-pi*I/2', '-1.5707i'])

    def test_source_holes_remain_excluded(self):
        self.check_value('source-hole-surviving-root', 'x = {2}')
        self.check_value('source-hole-only-root', 'x = (no solutions)')
        self.reject_values('source-hole-surviving-root', ['x = {-2,2}', 'x = {2,2}', 'x = -2'])
        self.reject_values('source-hole-only-root', ['x = {3}', 'x = {-3}', 'x = {}'])

    def test_complex_root_set_is_order_independent_and_complete(self):
        for result in ['x = {-1+I,1+I}', 'x = {1+1.0i,-1+1.0i}']:
            self.check_value('complex-quadratic-roots', result)
        self.reject_values('complex-quadratic-roots', ['x = {-1-I,1+I}', 'x = {1+I}', 'x = {1+I,1+I}', 'x = {-1+I,1+I,0}'])

    def test_shifted_taylor_checks_every_exact_coefficient_and_badge(self):
        for result in ['(x-1)^2', 'x²-2x+1', '(2*x-2)^2/4']:
            self.check_value('absolute-square-taylor', result, f=['x'])
        self.check_value('negative-branch-taylor', '1-(x-2)^2', f=['x'])
        self.reject_values('absolute-square-taylor', ['x²+2*x+1', '(x-1)^2+x^3/1000000000', '(y-1)^2', 'abs((x-1)^2)', 'series(abs(x),x,1,5)'], f=['x'])
        self.reject_values('absolute-square-taylor', ['(x-1)^2'], f=[])

    def test_matrix_shape_order_and_rational_cells_are_preserved(self):
        self.check_value('permutation-scaled-inverse', 'Matrix([[0,1/3],[0.5,0]])')
        self.reject_values('permutation-scaled-inverse', ['Matrix([[0,1/2],[1/3,0]])', 'Matrix([[0,0.333333],[0.5,0]])', 'Matrix([[0,1/3,0],[1/2,0,0]])', 'Matrix([[0,1/3],[1/2,x]])'])
        self.check_value('four-dimensional-jordan-inverse', 'Matrix([[1,-1,1,-1],[0,1,-1,1],[0,0,1,-1],[0,0,0,1]])')
        self.reject_values('four-dimensional-jordan-inverse', ['Matrix([[1,-1,1,0],[0,1,-1,1],[0,0,1,-1],[0,0,0,1]])'])
        with self.assertRaises(AssertionError):
            matrix_values('Matrix([[1,0],[1]])')

    def test_unit_value_dimension_and_method_all_matter(self):
        self.check_value('force-impulse', '1 kg*m/s', evidence={'method':'unitConversion'})
        self.check_value('specific-cgs-energy', '5000 erg/g', evidence={'method':'unitConversion'})
        self.reject_values('force-impulse', ['1 kg*m/s²', '1000 kg*m/s', '1 N*s'], evidence={'method':'unitConversion'})
        self.reject_values('force-impulse', ['1 kg*m/s'], evidence={'method':'symbolicEvaluation'})
        self.reject_values('force-impulse', ['1 kg*m/s'], evidence={'method':'unitConversion'}, f=['kg'])

    def test_explicit_errors_cannot_be_replaced_by_plausible_values(self):
        for name, message in [('irrational-cubic-pole','divergent pole'), ('opposed-one-sided-limits','left and right limits differ')]:
            self.check_value(name, '', e='Error: '+message)
            self.reject_values(name, ['0', '1', message])

    def test_exact_evidence_and_no_opaque_factorial(self):
        self.check_value('factorial-quotient', '30.0', evidence={'accuracy':'exact'})
        self.check_value('nested-rational-powers', '2.25', evidence={'accuracy':'exact'})
        self.reject_values('factorial-quotient', ['factorial(30)/factorial(29)', '29', '30.000001'], evidence={'accuracy':'exact'})
        self.reject_values('factorial-quotient', ['30'], evidence={'accuracy':'unknown'})

    def test_limit_evidence_remains_honest_and_source_is_read_back(self):
        self.check_value('rationalized-large-limit', '1', evidence={'method':'numericFallback','accuracy':'approximate'})
        self.check_value('bounded-oscillation-limit', '0', evidence={'method':'symbolicEvaluation','accuracy':'symbolic'})
        self.reject_values('rationalized-large-limit', ['1'], evidence={'method':'numericFallback','accuracy':'exact'})
        case = self.case('rationalized-large-limit')
        with self.assertRaises(AssertionError):
            validate_result(case, {'s':'1', 'r':'1', 'evidence':{'method':'symbolicEvaluation','accuracy':'symbolic'}})
        self.reject_values('bounded-oscillation-limit', ['0'], evidence={'method':'symbolicEvaluation','accuracy':'symbolic'}, f=['x'])

    def test_normal_cdf_display_requires_real_row_geometry(self):
        def node(text,x,y,width=100):
            return {'text':text,'box':{'x':x,'y':y,'width':width,'height':20}}
        label = node('CDF(x) = P(X ≤ x)',20,300,200)
        good = node('0.252493',230,300,70)
        self.assertEqual(normal_cdf_display([label,good],390,844)['value'],'0.252493')
        for candidate in [node('0.5',230,300,70), node('0.252494',230,300,70),
                          node('0.252493',230,350,70), node('0.252493',10,300,70)]:
            with self.subTest(candidate=candidate),self.assertRaises(AssertionError):
                normal_cdf_display([label,candidate],390,844)
        with self.assertRaises(AssertionError):
            normal_cdf_display([label,good,node('0.252493',310,300,70)],390,844)

    def test_normal_cdf_merged_group_preserves_label_value_order(self):
        def group(text):
            return {'text':text,'box':{'x':20,'y':300,'width':350,'height':100}}
        good = 'PDF(x) 0.106483 CDF(x) = P(X ≤ x) 0.252493 quantile(p) 7.879892'
        self.assertEqual(normal_cdf_display([group(good)],390,844)['value'],'0.252493')
        for wrong in [good.replace('0.252493','0.252494'),
                      'PDF(x) 0.252493 CDF(x) = P(X ≤ x) 0.106483 quantile(p) 7.879892']:
            with self.subTest(wrong=wrong),self.assertRaises(AssertionError):
                normal_cdf_display([group(wrong)],390,844)

    def test_reactive_trace_keeps_parameter_value_and_no_builtin_badge(self):
        self.check_value('reactive-trace-parameter','2')
        self.check_value('reactive-trace','5')
        case = self.case('reactive-trace')
        validate_result((case[0],case[1],'8'),{'s':case[1],'r':'8'})
        self.reject_values('reactive-trace',['8'])
        self.reject_values('reactive-trace',['5'],f=['trace'])
        self.reject_values('reactive-trace',['5'],f=['a'])


if __name__ == '__main__':
    unittest.main()
