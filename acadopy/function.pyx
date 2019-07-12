# (C) Copyright 2019 Enthought, Inc., Austin, TX
# All rights reserved.

# distutils: language=c++
# cython: language_level=3
# cython: c_string_type=unicode, c_string_encoding=utf8

from cython.operator cimport dereference as deref

from . cimport acado
from .bindings cimport Expression, expression_from_ref

cimport numpy as np
import numpy as np

import inspect

cdef void callback(double* x_, double* f_, void* userData):
    """ Retrieves a Python function from userData """
        
    obj = <object> userData
    dimension = obj.dim

    x_ary = np.asarray(<np.float64_t[:dimension]> x_)
    f_ary = np.asarray(<np.float64_t[:dimension]> f_)

    f_ary[:] = obj.func(x_ary)


cdef class PyFunction:
    """ Cython wrapper around an acado CFunction and its
     Python implementation.
     
    """

    def __init__(self, object func, int dim):

        if not inspect.isfunction(func):
            raise ValueError('Only functions are supported')

        self.func = func
        self.dim = dim

        # FIXME: I need a function pointer with a valid signature for a cFcnPtr
        # If there is no obvious way to do it, we can use the userData pointer
        # and rely on a default implementation for the CFunction implementation 
        # which would retrieve the Python function pointer from the userData
        # pointer
        cdef acado.cFcnPtr f_ptr = &callback
        self._thisptr = new acado.CFunction(
            dim,  f_ptr
        )
        self._thisptr.setUserData(<void*>self)

    def __call__(self, Expression exp):
        """ Call CFunction operator(const Expression args) which returns an exprssion. """
        cdef acado.Expression _exp
        cdef acado.Expression* _result
        cdef acado.CFunction _func

        _func = deref(self._thisptr)
        _exp = deref(exp._thisptr)
        
        _result = new acado.Expression(_func(_exp))

        # NOTE: do we need to make sure result keeps a reference on the PyFunction object 
        # if not, the PyFunction object could be cleared and the CFunction deleted ...
        cdef Expression result = expression_from_ref(_result, owner=True)

        return result

