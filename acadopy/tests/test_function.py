
from .utils import BaseAcadoTestCase

from acadopy.bindings import (
    Expression, TIME, IntermediateState, DifferentialState, exp,
    DVector
)

from acadopy.function import PyFunction, EvaluationPoint, Function

class FunctionTestCase(BaseAcadoTestCase):

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

def my_py_function(x_):
    """ here x is an 1-D array with shape (n,) and `args`
    is a tuple of the fixed parameters needed to completely
    specify the function. """
    
    t = x_[0]
    x = x_[1]

    f_ = np.empty_like(x_)
    f[0] = x*x + t
    f[1] = t

    return f

class CFunctionTestCase(BaseAcadoTestCase):

    def test_cfunction_creation(self):
        
        func = PyFunction(my_py_function, 2)

        self.assertIsInstance(func, PyFunction)

    
    def test_cfunction___call__(self):

        func = PyFunction(my_py_function, 2)

        t = TIME()
        y = DifferentialState()

        x = IntermediateState(2)

        x[0] = t
        x[1] = 2*y+1

        result = func(x)

        self.assertIsInstance(result, Expression)


    def test_full_example(self):
        
        map_ = PyFunction(my_py_function, 2)

        t = TIME()
        y = DifferentialState()

        x = IntermediateState(2)

        x[0] = t
        x[1] = 2*y+1

        f = Function()

        f << map_(2*x)*t
        f << t
        f << map_(x)

        z = IntermediateState()

        zz  = EvaluationPoint(f)

        xx = DVector(1) 

        xx[0] = 2.0
        tt    = 1.0

        zz.set_t( tt )
        zz.set_x( xx )

        result = f.evaluate( zz )

        print(result)
