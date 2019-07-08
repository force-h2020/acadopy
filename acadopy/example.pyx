# (C) Copyright 2019 Enthought, Inc., Austin, TX
# All rights reserved.

# distutils: language=c++
# cython: language_level=3
# cython: c_string_type=unicode, c_string_encoding=utf8
"""

Implementing the linking_c_functions2.cpp

Some useful references:
- http://blog.yclin.me/gsoc/2016/07/17/Function-Pointer/


"""

from .api import *
from . cimport acado

import faulthandler

faulthandler.enable()

cdef void my_function(double* x_, double* f_, void* userData) nogil:

    cdef double t =  x_[ 0];    # the time
    cdef double x =  x_[ 1];    # the differential state

    f_[0] = x*x + t
    f_[1] = t


def test():

    cdef acado.cFcnPtr f_ptr = &my_function
    cdef acado.CFunction map = acado.CFunction(2,  f_ptr)

    t = TIME()
    y = DifferentialState()

    x = IntermediateState(2)

    x[0] = t
    x[1] = 2*y+1

    f = Function()

    #f << map(2*x)*t
    #f << t
    #f << map(x)

    z = IntermediateState()

    #z = euclidean_norm( map(x) )

    f << z + z

    print('Evaluation point')
    zz  = EvaluationPoint(f)

    xx = DVector(1) 

    xx[0] = 2.0
    tt    = 1.0

    zz.setT( tt )
    zz.setX( xx )


    # EVALUATE f AT THE POINT  (tt,xx):
    # ---------------------------------
    result = f.evaluate( zz )


    # PRINT THE RESULT:
    # -----------------
    result.print()

    return 0

if __name__ == '__main__':
    test()