import unittest

from acadopy import (
    Expression, DifferentialState, IntermediateState, TIME, Function,
    exp, DMatrix, DVector
)


class AcadoTestCase(unittest.TestCase):

    def test_instantiate_expression(self):

        for cls in [DifferentialState, IntermediateState, TIME]:
            instance = cls()
            self.assertIsInstance(instance, Expression)


    def test_expression_init(self):

        e = Expression()
        self.assertIsInstance(e, Expression)

        e = Expression("name", 3, 1)
        self.assertIsInstance(e, Expression)

    def test_instantiate_function(self):

        f = Function()

    def test_expression_add(self):

        x = DifferentialState()

        y = x + 0.5

        self.assertIsInstance(y, Expression)

        y = 0.5 + x 

        self.assertIsInstance(y, Expression)

    def test_expression_mult(self):

        x = DifferentialState()

        y = x * 0.5

        self.assertIsInstance(y, Expression)

        y = 0.5 * x 

        self.assertIsInstance(y, Expression)

    def test_expression_function(self):

        x = DifferentialState()
        z = exp(x)

        self.assertIsInstance(z, Expression)

    def test_function_loading_expression(self):

        f = Function()
        x = DifferentialState()

        expression = exp(x + 1)

        self.assertEqual(f.dim, 0)
        self.assertEqual(f.nx, 0)

        f << expression
        self.assertEqual(f.dim, 1)
        self.assertEqual(f.nx, 1)




    def test_simple_function(self):
        x = DifferentialState()
        z = IntermediateState()
        t =TIME() 
        f= Function()

        z = 0.5 * x + 1.0

    def test_dmatrix(self):
        
        matrix = DMatrix(3,3)
        self.assertIsInstance(matrix, DMatrix)

    def test_dmatrix_setzero(self):

        matrix = DMatrix(3,3)
        matrix.set_zero()
        self.assertIsInstance(matrix, DMatrix)

    def test_dmatrix_assign(self):

        matrix = DMatrix(3,3)
        matrix[0,0] = 1.5
        self.assertIsInstance(matrix, DMatrix)

    def test_dvector(self):
        
        vector = DVector(3)
        self.assertIsInstance(vector, DVector)

    def test_dvector_assign(self):

        vector = DVector(3)
        vector[0] = 1.2
        self.assertIsInstance(vector, DVector)

       
