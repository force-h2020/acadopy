# (C) Copyright 2019 Enthought, Inc., Austin, TX
# All rights reserved.

import unittest

from acadopy.api import (
    Expression, DifferentialState, IntermediateState, TIME, Function,
    exp, DMatrix, DVector, DifferentialEquation, dot, Control, OCP,
    AT_START, AT_END, OptimizationAlgorithm, HESSIAN_APPROXIMATION,
    EXACT_HESSIAN, MAX_NUM_ITERATIONS, KKT_TOLERANCE, SUCCESSFUL_RETURN,
    clear_static_counters, ConstraintComponent
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
        self.assertIsInstance(f, Function)


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

    def test_expression_division(self):

        x = DifferentialState()
        z = DifferentialState()

        y = (0.5 + x) / 2.0
        self.assertIsInstance(y, Expression)

        y = (0.5 + x) / (z - 0.2)
        self.assertIsInstance(y, Expression)

        y = x / z
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

    def test_rocket_flight(self):
        """ Test rocket flight example. """
        import os
        import sys

        f = DifferentialEquation()
        CUR_DIR = os.path.abspath(os.path.dirname(__file__))
        sys.path.append(os.path.join(CUR_DIR, os.pardir))

        start = 0.0
        end = 10.0

        s = DifferentialState()
        v = DifferentialState()
        m = DifferentialState()

        u = Control()
        f << dot(s) == v
        f << dot(v) == ((u - 0.2 * v * v) / m)
        f << dot(m) == (-0.01 * u * u)

        self.assertIsInstance(f, DifferentialEquation)

        ocp = OCP(start, end, 20)
        ocp.minimizeLagrangeTerm(u * u)
        ocp.subjectTo(f)

        ocp.subjectTo(AT_START, s == 0.0)
        ocp.subjectTo(AT_START, v == 0.0)
        ocp.subjectTo(AT_START, m == 1.0)

        ocp.subjectTo(AT_END, s == 10.0)
        ocp.subjectTo(AT_END, v == 0.0)

        ocp.subjectTo(-0.01 <= v <= 1.3)
        ocp.subjectTo(u * u >= 1.0)

        ########################################
        # Define an optimization problem and solve the OCP
        ######################################

        algorithm = OptimizationAlgorithm(ocp)
        algorithm.set(HESSIAN_APPROXIMATION, EXACT_HESSIAN)
        algorithm.set(MAX_NUM_ITERATIONS, 20)
        algorithm.set(KKT_TOLERANCE, 1e-10)

        algorithm.solve()
