import unittest
from round11_numeric_reference_checks import CASES, validate_result, quantity, validate_optimum

class IndependentNumericControls(unittest.TestCase):
    def test_exact_fraction_and_complete_matrix(self):
        validate_result(CASES[1],{'r':'25/2'})
        validate_result(CASES[5],{'r':'Matrix([[-1,-5,6,-6],[9,15,-6,12],[10,20,-12,18]])'})
        for result in ['Matrix([[-1,-5,6],[9,15,-6],[10,20,-12]])','Matrix([[-1,-5,6,-6],[9,15,-6,12],[10,20,-12,19]])']:
            with self.assertRaises(AssertionError):validate_result(CASES[5],{'r':result})
        with self.assertRaises(AssertionError):validate_result(CASES[1],{'r':'12.50001'})

    def test_tiny_energy_is_relative_nonzero_and_dimension_checked(self):
        quantity('6.408706536e-19 J',6.408706536e-19,'J')
        for value in ['0 J','6.408707e-19 J','6.408706536e-19 C','NaN J','Infinity J','6.408706536e-19 J extra']:
            with self.assertRaises(AssertionError):quantity(value,6.408706536e-19,'J')
        quantity('36 μC',36,'µC')

    def test_optimum_rejects_feasible_nonoptimal_and_duplicate_assignments(self):
        validate_optimum('offset-least-squares','Optimal: objective = 5','x=2,y=4')
        validate_optimum('offset-least-squares','Optimal: objective = 5','x=3,y=3')
        validate_optimum('zero-sum-shifted-product','Optimal: objective = 4','x=0,y=0')
        for header,assignment in [('Optimal: objective = 5','x=1,y=5'),('Optimal: objective = 6','x=2,y=4'),('Optimal: objective = 5','x=2,x=4'),('Optimal: objective = 5','x=2,y=4,z=0')]:
            with self.assertRaises(AssertionError):validate_optimum('offset-least-squares',header,assignment)

if __name__=='__main__':unittest.main()
