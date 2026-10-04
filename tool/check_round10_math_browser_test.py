"""Independent bounded parser and value negative controls, stdlib only."""
import unittest
from fractions import Fraction
from round10_reference_checks import (CASES, STATISTICS_CASES, multivariate_coefficients,
                                      real_constant, validate_result, validate_statistics,
                                      validate_optimum, validate_linsolve, validate_domain, validate_factorization)


class RoundTenReferencesTest(unittest.TestCase):
    def line(self,name,result,**patch):
        case=next(c for c in CASES if c[0]==name)
        line={'s':case[1],'r':result,'f':[],
              'evidence':{'method':'symbolicEvaluation','accuracy':'unknown'}}
        line.update(patch)
        return case,line

    def test_all_multivariate_coefficients_and_variables(self):
        self.assertEqual(multivariate_coefficients('(x+y+z)^2-(x+y-z)^2'),
                         multivariate_coefficients('4xz+4yz'))
        self.assertEqual(multivariate_coefficients('(1+x²)^2'),multivariate_coefficients('x^4+2x²+1'))
        self.assertEqual(multivariate_coefficients('b+a'),multivariate_coefficients('a+b'))
        self.assertNotEqual(multivariate_coefficients('4*x*z-4*y*z'),multivariate_coefficients('4*x*z+4*y*z'))
        self.assertNotEqual(multivariate_coefficients('a-b'),multivariate_coefficients('a+b'))
        for expression in ['w+a','sin(x)','1/(a+b)','x¹²','1e100000000','(((999999999^8)^8)^8)^8']:
            with self.subTest(expression=expression),self.assertRaises((AssertionError,SyntaxError)):
                multivariate_coefficients(expression)

    def test_factorization_requires_genuine_quadratic_square_or_product(self):
        for result in ['(1+x²)^2','(-x^2-1)^2','(x^2+1)*(1+x^2)',
                       '(2*x^2+2)*(x^2/2+1/2)']:
            validate_factorization(result)
        for result in ['x^4+2*x^2+(1)','(x^4+2*x^2+1)',
                       '1*(x^4+2*x^2+1)','(x^2+1)^1*(x^2+1)^0',
                       '(x^2-1)^2','(x^2+1)*(x^2+2)']:
            with self.subTest(result=result),self.assertRaises(AssertionError):
                validate_factorization(result)

    def test_domain_condition_is_the_entire_original_denominator(self):
        for text in ['a+b ≠ 0','(b+a) != 0','a + b ≠ 0']:validate_domain(text)
        for text in ['','a != 0','a-b ≠ 0','a+b = 0','a+b ≠ 1','a+b ≠ 0; a ≠ 0']:
            with self.assertRaises(AssertionError):validate_domain(text)
        case,line=self.line('multivariate-domain-cancellation','b+a',f=['a','b'],evidence={'sourceDomain':'(a+b) ≠ 0'})
        validate_result(case,line)
        for patch in [{'f':['a']},{'r':'a-b'},{'evidence':{}},{'evidence':{'sourceDomain':'a-b ≠ 0'}}]:
            with self.assertRaises(AssertionError):validate_result(case,{**line,**patch})

    def test_principal_complex_branch_and_every_root(self):
        case,line=self.line('principal-nonreal-square','3.0-4.0I')
        validate_result(case,line)
        with self.assertRaises(AssertionError):validate_result(case,{**line,'r':'-3+4I'})
        case,line=self.line('quotient-surviving-root','x = {-3}')
        validate_result(case,line)
        for result in ['x = {-3,2}','x = 2','x = {-3,-3}']:
            with self.assertRaises(AssertionError):validate_result(case,{**line,'r':result})
        case,line=self.line('complex-source-holes','x = (no solutions)')
        validate_result(case,line)
        with self.assertRaises(AssertionError):validate_result(case,{**line,'r':'x = {I,-I}'})

    def test_matrix_shape_order_and_rational_values(self):
        case,line=self.line('rectangular-contraction','Matrix([[9,-8],[0,10]])')
        validate_result(case,line)
        for result in ['Matrix([[9,0],[-8,10]])','Matrix([[9,-8,0],[0,10,0]])','Matrix([[9,-8],[0,9]])']:
            with self.assertRaises(AssertionError):validate_result(case,{**line,'r':result})
        case,line=self.line('determinant-two-inverse','Matrix([[2,-1],[-2.5,1.5]])')
        validate_result(case,line)

    def test_real_integral_constants_and_domain_errors(self):
        case,line=self.line('regular-log-primitive','ln(2)/2')
        validate_result(case,line)
        with self.assertRaises(AssertionError):validate_result(case,{**line,'r':'ln(2)'})
        case,line=self.line('log-reciprocal-divergence','Error: divergent endpoint')
        validate_result(case,line)
        for patch in [{'r':'0'},{'r':'Error: numeric sampling failed'}]:
            with self.assertRaises(AssertionError):validate_result(case,{**line,**patch})
        for expression in ['x','ln(-2)','sqrt(-1)','exp(1)','1e100000000','2**100000000']:
            with self.subTest(expression=expression),self.assertRaises((AssertionError,ValueError)):
                real_constant(expression)

    def test_integral_display_rounding_preserves_value_and_approximate_evidence(self):
        displays={'regular-log-primitive':'0.3465735903',
                  'upper-log-endpoint':'0.147918433',
                  'outside-irrational-poles':'-0.3006198874'}
        for name,result in displays.items():
            case,line=self.line(name,result,evidence={'accuracy':'approximate'})
            validate_result(case,line)
            for accuracy in ['exact','unknown']:
                with self.subTest(name=name,accuracy=accuracy),self.assertRaises(AssertionError):
                    validate_result(case,{**line,'evidence':{'accuracy':accuracy}})
        case,line=self.line('regular-log-primitive',displays['regular-log-primitive'],
                            evidence={'accuracy':'approximate'})
        for result in ['0.3465735902','0.3465735904','0.3466','0.34657359027997264','0','1']:
            with self.subTest(result=result),self.assertRaises(AssertionError):
                validate_result(case,{**line,'r':result})

    def test_exact_values_evidence_dimensions_and_free_variables(self):
        case,line=self.line('reciprocal-exact-decimals','40/13',evidence={'accuracy':'exact'})
        validate_result(case,line)
        for patch in [{'r':'3'},{'evidence':{'accuracy':'approximate'}},{'f':['e']}]:
            with self.assertRaises(AssertionError):validate_result(case,{**line,**patch})
        case,line=self.line('kiloohm-current','4 mA',evidence={'method':'unitConversion'})
        validate_result(case,line)
        for patch in [{'r':'4 A'},{'r':'0 mA'},{'f':['kΩ']},{'evidence':{'method':'numericFallback'}}]:
            with self.assertRaises(AssertionError):validate_result(case,{**line,**patch})

    def test_taylor_constant_has_no_formal_free_variable(self):
        case,line=self.line('rational-center-absolute-series','-(x-1/2)^2+1/4',f=['x'])
        validate_result(case,line)
        with self.assertRaises(AssertionError):validate_result(case,{**line,'r':'x+x^2'})
        case,line=self.line('fifth-order-absolute-zero','0')
        validate_result(case,line)
        with self.assertRaises(AssertionError):validate_result(case,{**line,'f':['x']})

    def test_sample_rows_count_and_nonzero_dispersion(self):
        text='Count 5 Sum 15 Mean 3 Median 4 Mode 1, 4 Std. deviation (n−1) 1.870829 Variance (n) 2.8'
        validate_statistics(text,STATISTICS_CASES[0][2])
        tiny='Count 5 Sum 0 Mean 0 Median 0 Mode 0 Std. deviation (n−1) 7.0711e-101 Variance (n) 4.0000e-201'
        validate_statistics(tiny,STATISTICS_CASES[1][2])
        for wrong in [tiny.replace('7.0711e-101','0'),tiny.replace('Count 5','Count 4'),tiny.replace('Median 0','Median 1')]:
            with self.assertRaises(AssertionError):validate_statistics(wrong,STATISTICS_CASES[1][2])

    def test_both_global_integer_optima_and_feasibility(self):
        for assignment in ['x=2, y=3','y=2, x=3']:
            self.assertEqual(validate_optimum('odd-sum-balanced-minimum','Optimal: objective = 5',assignment)['objective'],5)
        validate_optimum('opposed-shifted-product-maximum','Optimal: objective = 1','x=0, y=0')
        for name,header,value in [('odd-sum-balanced-minimum','Optimal: objective = 4','x=2, y=3'),
                                   ('odd-sum-balanced-minimum','Optimal: objective = 5','x=1, y=4'),
                                   ('odd-sum-balanced-minimum','Optimal: objective = 5','x=2, y=2'),
                                   ('opposed-shifted-product-maximum','Optimal: objective = 1','x=1, y=-1'),
                                   ('opposed-shifted-product-maximum','Optimal: objective = 1','x=0, x=0')]:
            with self.assertRaises(AssertionError):validate_optimum(name,header,value)

    def test_all_linear_unknowns_are_required(self):
        for result in ['x = 2, y = 2, z = 2','z=2, x=4/2, y=2.0']:validate_linsolve(result)
        for result in ['x=2,y=2','x=2,y=2,z=3','x=2,x=2,z=2','x=2,y=2,z=2,w=0','x=2,y=2,z=2+u']:
            with self.assertRaises(AssertionError):validate_linsolve(result)


if __name__=='__main__':unittest.main()
