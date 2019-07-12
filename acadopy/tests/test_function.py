
from .utils import BaseAcadoTestCase

from acadopy.bindings import (
    Expression, TIME, IntermediateState, DifferentialState
)

from acadopy.c_function import PyFunction

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