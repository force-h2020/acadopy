from .utils import BaseAcadoTestCase

from acadopy.api import (
    IntermediateState, DifferentialState, Parameter, DifferentialEquation, dot,
    TIME, Expression
)

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