"""Negative controls for the independent eleventh-audit comparator."""
import unittest

from round11_algebra_reference_checks import CASES, validate_result, validate_linsolve


class AlgebraReferenceControls(unittest.TestCase):
    def line(self,name,result,**changes):
        case=next(case for case in CASES if case[0]==name)
        kind=case[2][0]
        free=['x','y'] if kind in {'multi','factor'} else ['x'] if kind in {'rational','self-power','poly'} else []
        line={'s':case[1],'r':result,'e':None,'f':free,'evidence':{'accuracy':'symbolic'}}
        line.update(changes)
        return case,line

    def accepts(self,name,result,**changes):
        validate_result(*self.line(name,result,**changes))

    def rejects(self,name,result,**changes):
        with self.assertRaises((AssertionError,SyntaxError,ValueError,ZeroDivisionError)):
            self.accepts(name,result,**changes)

    def test_full_coefficients_and_real_factorization(self):
        self.accepts('signed-cubic','8*x^3-36*x^2*y+54*x*y^2-27*y^3')
        self.rejects('signed-cubic','8*x^3-36*x^2*y+54*x*y^2+27*y^3')
        self.accepts('sophie-germain','(x^2-2*x*y+2*y^2)*(x^2+2*x*y+2*y^2)')
        self.rejects('sophie-germain','x^4+4*y^4')
        self.rejects('sophie-germain','(x^2-2*x*y+y^2)*(x^2+2*x*y+y^2)')

    def test_complete_rational_identity_and_source_domain(self):
        evidence={'sourceDomain':'x ≠ -3','accuracy':'symbolic'}
        self.accepts('surviving-exclusion','(x-3)/(x+3)',evidence=evidence)
        self.rejects('surviving-exclusion','(x-3)/(x+3)')
        self.rejects('surviving-exclusion','(x+3)/(x-3)',evidence=evidence)
        self.accepts('scaled-arctangent','3/(9*x^2+1)')
        self.rejects('scaled-arctangent','1/(9*x^2+1)')
        self.accepts('nested-log-radical','x/(4+x*x)')
        self.rejects('nested-log-radical','2*x/(4+x*x)')

    def test_self_power_symbolic_identity_and_all_series_coefficients(self):
        self.accepts('self-power','x^x*(1+log(x))')
        self.rejects('self-power','x^x*log(x)')
        self.accepts('exponential-cosine-series','1+x-x^3/3-x^4/6')
        self.rejects('exponential-cosine-series','1+x+x^2/2-x^3/3-x^4/6')
        self.rejects('exponential-cosine-series','1+x-x^3/3')

    def test_complete_root_sets_and_complex_components(self):
        self.accepts('shifted-square','x = {9,-1}')
        self.rejects('shifted-square','x = 9')
        self.rejects('shifted-square','x = {9,-1,-1}')
        self.accepts('principal-negative-imaginary-log','-I*pi/2')
        self.rejects('principal-negative-imaginary-log','I*pi/2')
        self.accepts('gaussian-sixth-power','0.0-8.0*I')
        self.rejects('gaussian-sixth-power','1-8*I')
        self.accepts('principal-root-product','-12+0*I')
        self.rejects('principal-root-product','12')

    def test_matrix_shape_every_entry_and_exact_system(self):
        self.accepts('nonuniform-shear-cube','Matrix([[1,6,18],[0,1,9],[0,0,1]])')
        self.rejects('nonuniform-shear-cube','Matrix([[1,6,0],[0,1,9],[0,0,1]])')
        self.rejects('nonuniform-shear-cube','Matrix([[1,6],[0,1]])')
        validate_linsolve('x = 2, y = 1, z = 4')
        for source in ['x=2,y=1','x=2,y=1,z=5','x=2,y=1,z=4,z=4','Error: x=2,y=1,z=4']:
            with self.assertRaises(AssertionError):validate_linsolve(source)

    def test_closed_integrals_and_documented_display_rounding(self):
        self.accepts('rational-log-integral','log(16/7)/2')
        self.accepts('two-endpoint-singularities','pi')
        approximate={'accuracy':'approximate','method':'fundamentalTheorem'}
        self.accepts('two-endpoint-singularities','3.141592654',evidence=approximate)
        self.rejects('two-endpoint-singularities','3.141592653',evidence=approximate)
        self.rejects('two-endpoint-singularities','3.141592654',evidence={'accuracy':'exact'})
        self.accepts('exponential-moment','1/4')
        self.rejects('exponential-moment','0')
        self.rejects('radical-at-infinity','Error: 0')


if __name__=='__main__':unittest.main()
