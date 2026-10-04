"""Independent positive/negative controls; no browser or app dependencies."""
from fractions import Fraction
from round7_reference_checks import polynomial_coefficients
import unittest
from round9_reference_checks import (CASES, TAYLOR_EXPECTED, log_polynomial,
                                     validate_result, validate_optimum, validate_statistics, STATISTICS_CASES, constraint_assignment_field)


class RoundNineReferencesTest(unittest.TestCase):
    def line(self,name,result,**extra):
        case=next(case for case in CASES if case[0]==name)
        line={'s':case[1],'r':result,'f':[],'evidence':{'method':'symbolicEvaluation','accuracy':'unknown'}}
        line.update(extra)
        return case,line

    def test_transcendental_center_equivalent_exact_polynomials(self):
        for expression in ['2+2*(x-ln(2))+(x-ln(2))^2',
                           '(x-log(2))*exp(log(2))+(1/2)*(x-log(2))**2*exp(log(2))+exp(log(2))',
                           'x²+2x-2x*ln(2)+ln(2)^2-2*ln(2)+2']:
            self.assertEqual(log_polynomial(expression),TAYLOR_EXPECTED)
        self.assertEqual(log_polynomial('x^0'),{(0,0):Fraction(1)})

    def test_exact_literal_and_coefficient_resource_bounds(self):
        self.assertEqual(polynomial_coefficients('1e308*1e-308'),[Fraction(1)])
        self.assertEqual(polynomial_coefficients('1e-320'),[Fraction(1,10**320)])
        for expression in ['1e100000000','1e-100000000','(((999999999^8)^8)^8)^8',
                           '1/(((999999999^8)^8)^8)^8']:
            with self.subTest(expression=expression), self.assertRaises(AssertionError):
                polynomial_coefficients(expression)
        with self.assertRaises(AssertionError):log_polynomial('ln(2)+1e100000000')
        with self.assertRaises(AssertionError):log_polynomial('ln(2)+(((999999999^8)^8)^8)^8')

    def test_transcendental_wrong_coefficients_and_foreign_functions_fail(self):
        self.assertNotEqual(log_polynomial('2+(x-ln(2))+(x-ln(2))^2'),TAYLOR_EXPECTED)
        for expression in ['exp(x)','ln(3)+x','y+2','x^99','x¹²','1/(x-ln(2))','x**ln(2)']:
            with self.subTest(expression=expression), self.assertRaises((AssertionError,SyntaxError)):
                log_polynomial(expression)

    def test_principal_branches_and_false_exactness(self):
        case,line=self.line('log-winding','2.22044604925031e-16+6.28318530717959*I')
        validate_result(case,line)
        for wrong in ['0','-6.28318530717959*I','1e-6+6.28318530717959*I']:
            with self.assertRaises(AssertionError):validate_result(case,{**line,'r':wrong})
        with self.assertRaises(AssertionError):
            validate_result(case,{**line,'evidence':{'accuracy':'exact'}})
        case,line=self.line('principal-rational-power','-0.5+0.866025403784439*I')
        validate_result(case,line)
        with self.assertRaises(AssertionError):validate_result(case,{**line,'r':'-0.5-0.866025403784439*I'})

    def test_units_require_true_dimensions_and_no_unknown_badges(self):
        case,line=self.line('ohm-prefix-cancellation','1 V',evidence={'method':'unitConversion'})
        validate_result(case,line)
        for patch in [{'r':'0 V'},{'r':'1 A'},{'f':['kΩ']},{'evidence':{'method':'numericFallback'}}]:
            with self.assertRaises(AssertionError):validate_result(case,{**line,**patch})

    def test_matrix_positions_and_root_exclusions(self):
        case,line=self.line('rectangular-leading-zero-rref','Matrix([[1,0,1,2],[0,1,2,3],[0,0,0,0]])')
        validate_result(case,line)
        with self.assertRaises(AssertionError):validate_result(case,{**line,'r':'Matrix([[1,0,2,1],[0,1,2,3],[0,0,0,0]])'})
        case,line=self.line('multiplicity-source-hole','x = {1}')
        validate_result(case,line)
        with self.assertRaises(AssertionError):validate_result(case,{**line,'r':'x = {-1,1}'})

    def test_extreme_sample_sd_and_row_pairing_are_strict(self):
        expected=STATISTICS_CASES[0][2]
        text='Count 3 Sum 6e-200 Mean 2.0000e-200 Median 2.0000e-200 Mode Undefined Std. deviation (n−1) 1.0000e-200 Variance (n) 0'
        validate_statistics(text,expected)
        for wrong in [text.replace('1.0000e-200','0'),
                      text.replace('Mean 2.0000e-200 Median','Mean 2.0000e-200 WRONG'),
                      text+' Mean 2.0000e-200 Median']:
            with self.assertRaises(AssertionError):validate_statistics(wrong,expected)

    def test_actual_constraint_output_field_excludes_editable_or_ambiguous_values(self):
        field={'index':1,'tag':'input','readOnly':True,'value':'x=1, y=-1',
               'box':{'x':16,'y':400,'width':1248,'height':40}}
        self.assertEqual(constraint_assignment_field([field])['value'],'x=1, y=-1')
        for fields in [[{**field,'readOnly':False}],
                       [{**field,'tag':'div'}],
                       [{**field,'box':{'width':0,'height':40}}],
                       [field,{**field,'index':2}],
                       [{**field,'value':'vars: x, y in -3..3'}]]:
            with self.assertRaises(AssertionError):constraint_assignment_field(fields)

    def test_both_independent_integer_optima_and_order(self):
        self.assertEqual(validate_optimum('Optimal: objective = 1','x = 1, y = -1')['objective'],1)
        self.assertEqual(validate_optimum('Optimal: objective = 1.0','y = -2, x = 2')['x'],2)
        for header,assignment in [('Optimal: objective = 2','x = 1, y = -1'),
                                  ('Optimal: objective = 1','x = 0, y = 0'),
                                  ('Optimal: objective = 1','x = 2, y = -1'),
                                  ('Optimal: objective = 1','x = 1, x = -1'),
                                  ('2 solutions','x = 1, y = -1')]:
            with self.assertRaises(AssertionError):validate_optimum(header,assignment)


if __name__=='__main__':unittest.main()
