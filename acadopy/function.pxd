# (C) Copyright 2019 Enthought, Inc., Austin, TX
# All rights reserved.
# cython: language_level=3

from . cimport acado
from libcpp cimport bool


cdef class Function:
    cdef acado.Function* _thisptr
    cdef bool _owner

cdef class DifferentialEquation(Function):
    pass

cdef void callback(double* x_, double* f_, void* userData) with gil

cdef class PyFunction:
    cdef acado.CFunction* _thisptr
    cdef object func
    cdef int _dim

cdef class EvaluationPoint:
    cdef acado.EvaluationPoint* _thisptr