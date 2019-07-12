from .utils import BaseAcadoTestCase

from acadopy.bindings import (
    IntermediateState, DifferentialState, Parameter , dot,
    TIME, Expression, DVector
)

from acadopy.function import DifferentialEquation, Function, EvaluationPoint

class VariableTypesTestCase(BaseAcadoTestCase):

    def test_intermediatestate_init(self):

        x = IntermediateState()
        x = IntermediateState(2)


    def test_differentialstate_init(self):

        x = DifferentialState('x')
        x = DifferentialState('y', 0, 1)

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

    def test_differentialequation_init(self):
        start = Parameter()
        end = Parameter()
        f = DifferentialEquation()
        f = DifferentialEquation(0, 10)
        f = DifferentialEquation(0.0, 10.0)
        f = DifferentialEquation(start, end)
        f = DifferentialEquation(start, 10.0)
        f = DifferentialEquation(0.0, end)

    def test_instantiate_types(self):

        for cls in [DifferentialState, IntermediateState, TIME]:
            instance = cls()
            self.assertIsInstance(instance, Expression)


    def test_intermediatestate_init(self):


        i = IntermediateState()
        i = IntermediateState(2)
        i = IntermediateState("namne")
        i = IntermediateState("namne", 2)
        i = IntermediateState("namne", 3, 4)




    def test_real_example(self):

        t = TIME()
        y = DifferentialState()

        x = IntermediateState(2)

        self.assertEqual(2, x.dim)
        self.assertEqual(2, x.num_rows)
        self.assertEqual(1, x.num_cols)


        x[0] = t
        x[1] = (2*y+1)

        f = Function()
    
        z = IntermediateState()

        f << z + z

        print('Evaluation point')
        zz  = EvaluationPoint(f)

        xx = DVector(1) 

        xx[0] = 2.0
        tt    = 1.0

        zz.set_t( tt )
        zz.set_x( xx )


        # EVALUATE f AT THE POINT  (tt,xx):
        # ---------------------------------
        result = f.evaluate( zz )


        # PRINT THE RESULT:
        # -----------------
        print(result)
