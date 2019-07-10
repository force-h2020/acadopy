# (C) Copyright 2019 Enthought, Inc., Austin, TX
# All rights reserved.

from .utils import BaseAcadoTestCase

from acadopy.bindings import *

class AcadoTestCase(BaseAcadoTestCase):


    def test_instantiate_function(self):

        f = Function()
        self.assertIsInstance(f, Function)


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
        t = TIME()
        f = Function()

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

    def test_constraint_component_le(self):

        v = DifferentialState()

        result = -0.01 <= v

        self.assertIsInstance(result, ConstraintComponent)

        constraint = result <= 3.0

        self.assertIsInstance(constraint, ConstraintComponent)

    def test_three_item_constraint(self):

        t1 = Parameter()

        constraint = 0.1 <= t1 <= 50.0

        self.assertIsInstance(constraint, ConstraintComponent)


    def test_multiobjective_optimisation(self):
        """ Use the catalyst_mixing_nbi example as a test case. """

        x1 = DifferentialState()
        x2 = DifferentialState()
        x3 = DifferentialState()

        u = Control()

        f = DifferentialEquation(0.0, 1.0)

        f << dot(x1) == u * (10.0 * x2 - x1)
        f << dot(x2) == u * (x1 - 10.0 * x2) - (1.0 - u)*x2
        f << dot(x3) == u/10.0

        ocp = OCP(0.0, 1.0, 25)

        ocp.minimizeMayerTerm(0, (x1+x2-1))
        self.assertEqual(ocp.get_number_of_mayer_terms(), 1)
        ocp.minimizeMayerTerm(1, x3)
        self.assertEqual(ocp.get_number_of_mayer_terms(), 2)
        ocp.subjectTo(f)

        ocp.subjectTo(AT_START, x1 == 1.0)
        ocp.subjectTo(AT_START, x2 == 0.0)
        ocp.subjectTo(AT_START, x3 == 0.0)

        res = 0.0 <= x1 <= 1.0
        ocp.subjectTo(res)
        ocp.subjectTo(0.0 <= x2 <= 1.0)
        ocp.subjectTo(0.0 <= x3 <= 1.0)
        ocp.subjectTo(0.0 <= u <= 1.0)

        algorithm = MultiObjectiveAlgorithm(ocp)

        algorithm.set(PARETO_FRONT_GENERATION, PFG_NORMAL_BOUNDARY_INTERSECTION)
        algorithm.set(PARETO_FRONT_DISCRETIZATION, 11)
        algorithm.set(HESSIAN_APPROXIMATION, EXACT_HESSIAN)

        # FIXME: this should be added to the test
        # algorithm.solve();

    def test_multiobjective_optimisation_2(self):
        """ Run the start of the car_ws example and test that the OCP
        is set up correctly.
        """

        t1 = Parameter()
        x1 = DifferentialState()
        x2 = DifferentialState()
        u = Control()

        f = DifferentialEquation(0.0, t1)
        f << dot(x1) == x2
        f << dot(x2) == u

        ocp = OCP(0.0, t1, 50)
        ocp.minimizeMayerTerm(0, x2)
        self.assertEqual(ocp.get_number_of_mayer_terms(), 1)
        ocp.minimizeMayerTerm(1, 2.0 * t1 / 20.0)
        self.assertEqual(ocp.get_number_of_mayer_terms(), 2)
        ocp.subjectTo(f)

        ocp.subjectTo(AT_START, x1 == 0.0)
        ocp.subjectTo(AT_START, x2 == 0.0)
        ocp.subjectTo(AT_END, x1 == 200.0)

        ocp.subjectTo(0.0 <= x1 <= 200.001)
        ocp.subjectTo(0.0 <= x2 <= 40.0)
        ocp.subjectTo(0.0 <= u <= 5.0)
        ocp.subjectTo(0.0 <= t1 <= 50.0)

        algorithm = MultiObjectiveAlgorithm(ocp)
        algorithm.set(PARETO_FRONT_GENERATION, PFG_WEIGHTED_SUM)
        algorithm.set(PARETO_FRONT_GENERATION, PFG_NORMAL_BOUNDARY_INTERSECTION)
        algorithm.set(PARETO_FRONT_DISCRETIZATION, 11)
        algorithm.set(KKT_TOLERANCE, 1e-8)

        # FIXME: this should be added to the test
        # algorithm.solve();

    def test_rocket_flight(self):
        """ Test simple OCP rocket flight example. """
        import os
        import sys

        f = DifferentialEquation()

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
        ocp.subjectTo(u * u >= -1.0)

        ########################################
        # Define an optimization problem and solve the OCP
        ######################################

        algorithm = OptimizationAlgorithm(ocp)
        algorithm.set(HESSIAN_APPROXIMATION, EXACT_HESSIAN)
        algorithm.set(MAX_NUM_ITERATIONS, 20)
        algorithm.set(KKT_TOLERANCE, 1e-10)

        algorithm.solve()
