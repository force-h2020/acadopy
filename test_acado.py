import unittest

from acadopy import (
    Expression, DifferentialState, IntermediateState, TIME, Function,
    exp, DMatrix, DVector, clear_static_counters, dot, DifferentialEquation,
    ConstraintComponent
)


class AcadoTestCase(unittest.TestCase):

    def setUp(self):
        clear_static_counters()

    def test_instantiate_expression(self):

        for cls in [DifferentialState, IntermediateState, TIME]:
            instance = cls()
            self.assertIsInstance(instance, Expression)


    def test_expression_init(self):

        e = Expression()
        self.assertIsInstance(e, Expression)

        e = Expression("name", 3, 1)
        self.assertIsInstance(e, Expression)

    def test_expression_print(self):

        e = Expression("name", 3, 1)
        print(e)

    def test_instantiate_function(self):

        f = Function()


    def test_expression_add(self):

        x = DifferentialState()

        y = x + 0.5

        self.assertIsInstance(y, Expression)
        self.assertEqual(y.dim, 1)
        self.assertEqual(y.num_rows, 1)
        self.assertEqual(y.num_cols, 1)
        self.assertFalse(y.is_variable)

        y = 0.5 + x 

        self.assertIsInstance(y, Expression)

        z = DifferentialState()

        y = x + z + 1.0
        print(y)
        self.assertIsInstance(y, Expression)
        self.assertEqual(y.dim, 1)
        self.assertEqual(y.num_rows, 1)
        self.assertEqual(y.num_cols, 1)
        self.assertFalse(y.is_variable)

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
        self.assertEqual(z.dim, 1)
        self.assertEqual(z.num_rows, 1)
        self.assertEqual(z.num_cols, 1)
        self.assertFalse(z.is_variable)

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

    def test_differentialstate_equal(self):

        f = DifferentialEquation()
        s = DifferentialState()
        v = DifferentialState()

        intermediate = f << dot(s)

        self.assertIsInstance(intermediate, DifferentialEquation)
        self.assertEqual(intermediate.dim, 0)
        self.assertEqual(intermediate.n, 0)
        self.assertEqual(intermediate.nx, 0)
        self.assertEqual(intermediate.nu, 0)

        self.assertIsInstance(f, DifferentialEquation)
        self.assertEqual(f.dim, 0)
        self.assertEqual(f.n, 0)
        self.assertEqual(f.nx, 0)
        self.assertEqual(f.nu, 0)

        result = f == v

        self.assertIsInstance(result, DifferentialEquation)
        self.assertEqual(result.dim, 1)
        self.assertEqual(result.n, 0)
        self.assertEqual(result.nx, 2)
        self.assertEqual(result.nu, 0)

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

       
    def test_constraint_component_le(self):

        v = DifferentialState()

        result = -0.01 <= v

        self.assertIsInstance(result, ConstraintComponent)

        result = result <= 3.0

        self.assertIsInstance(result, ConstraintComponent)