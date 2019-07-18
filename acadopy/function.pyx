# (C) Copyright 2019 Enthought, Inc., Austin, TX
# All rights reserved.

# distutils: language=c++
# cython: language_level=3


from cython.operator cimport dereference as deref

from . cimport acado
from .bindings cimport (
    Expression, expression_from_ref, Parameter, DVector
)

cimport numpy as cnp
import numpy as np

import inspect

cdef class Function:
    """ Python wrapper of the Function class
    """

    def __cinit__(self, initialize=True, *args, **kwargs):
        if type(self) is Function:
            if initialize:
                self._thisptr = new acado.Function()
                self._owner = True
            else:
                self._owner = False

    def __dealloc__(self):
        if self._owner and self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def __repr__(self):
        # Fake print statement
        acado.cout << deref(self._thisptr)
        return ""

    def __lshift__(self, other):
        cdef Expression rhs
        cdef Function lhs
        cdef acado.Function _function

        if isinstance(self, Function) and isinstance(other, Expression):
            lhs = self
            rhs = other
            _function = deref(lhs._thisptr)

            _function << deref(rhs._thisptr)

            lhs._thisptr = new acado.Function(_function)

            return self
        else:
            return NotImplemented

    @property
    def dim(self):
        return self._thisptr.getDim()

    @property
    def n(self):
        return self._thisptr.getN()

    @property
    def nx(self):
        return self._thisptr.getNX()

    @property
    def nu(self):
        return self._thisptr.getNU()

    def isConvex(self):
        return self._thisptr.isConvex()

    def evaluate(self, EvaluationPoint pt):

        cdef acado.DVector* result = new acado.DVector(
            self._thisptr.evaluate(deref(pt._thisptr))
        )
        cdef DVector v = DVector()
        del v._thisptr
        v._thisptr = result

        return v

cdef class DifferentialEquation(Function):

    def __cinit__(self, start=None, end=None, initialize=True):
        cdef Parameter pstart
        cdef Parameter pend
        cdef acado.Parameter start_parameter
        cdef acado.Parameter end_parameter

        if type(self) is DifferentialEquation:
            if not initialize:
                self._owner = False
                return

            if start is None and end is None:
                self._thisptr = new acado.DifferentialEquation()
            elif isinstance(start, Parameter) and isinstance(end, Parameter):
                pstart = start
                pend = end
                start_parameter = deref(<acado.Parameter*>pstart._thisptr)
                end_parameter = deref(<acado.Parameter*>pend._thisptr)
                self._thisptr = new acado.DifferentialEquation(start_parameter, end_parameter)
            elif not isinstance(start, Parameter) and isinstance(end, Parameter):
                pend = end
                end_parameter = deref(<acado.Parameter*>pend._thisptr)
                self._thisptr = new acado.DifferentialEquation(<double>start, end_parameter)
            elif isinstance(start, Parameter) and not isinstance(end, Parameter):
                pstart = start
                _parameter = deref(<acado.Parameter*>pstart._thisptr)
                self._thisptr = new acado.DifferentialEquation(end_parameter, <double>end)
            else:
                self._thisptr = new acado.DifferentialEquation(<double>start, <double>end)

            self._owner = True

    def __eq__(self, other):
        if not isinstance(other, Expression):
            return NotImplemented

        cdef acado.DifferentialEquation _result
        cdef Expression rhs
        cdef DifferentialEquation lhs
        cdef DifferentialEquation result
        cdef acado.DifferentialEquation _diffeq

        lhs = self
        rhs = other

        _diffeq = deref(<acado.DifferentialEquation*>lhs._thisptr)
        _result = _diffeq == deref(rhs._thisptr)

        lhs._thisptr = new acado.DifferentialEquation(_result)

        return self

    def __lshift__(self, other):
        cdef Expression rhs
        cdef DifferentialEquation lhs
        cdef acado.DifferentialEquation _diffeq

        if isinstance(self, Function) and isinstance(other, Expression):
            lhs = self
            rhs = other
            _diffeq = deref(<acado.DifferentialEquation*>lhs._thisptr)

            _diffeq << deref(rhs._thisptr)

            lhs._thisptr = new acado.DifferentialEquation(_diffeq)

            return self
        else:
            return NotImplemented

cdef class EvaluationPoint:

    def __cinit__(self, Function f):
        self._thisptr = new acado.EvaluationPoint(deref(f._thisptr))

    def set_x(self, DVector v):
        self._thisptr.setX(deref(v._thisptr))

    def set_t(self, float t):
        self._thisptr.setT(<double> t)

cdef void callback(double* x_, double* f_, void* userData) with gil:
    """ Retrieves a Python function from userData """
        
    cdef PyFunction obj = <object> userData
    cdef int dimension = obj._dim

    try:
        x_ary = np.asarray(<cnp.float64_t[:dimension]> x_)
        f_ary = np.asarray(<cnp.float64_t[:dimension]> f_)
    except Exception as exc:
        print('Error while converting inputs to numpy arrays')
        import traceback
        traceback.print_exc()

    try:
        f_ary[:] = obj.func(x_ary)
    except Exception as exc:
        print('Error while evaluating the function')
        traceback.print_exc()

cdef class PyFunction:
    """ Cython wrapper around an acado CFunction and its
     Python implementation.
     
    """

    def __cinit__(self, int dim, object func):

        if not inspect.isfunction(func):
            raise ValueError('Only functions are supported')

        self.func = func
        self._dim = dim

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

    property dim:
        def __get__(self):
            return self._thisptr.getDim()

    def __call__(self, Expression exp):
        """ Call `CFunction.operator(const Expression args)` which returns an Expression. 
        
        """
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

