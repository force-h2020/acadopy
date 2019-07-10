# (C) Copyright 2019 Enthought, Inc., Austin, TX
# All rights reserved.
# cython: language_level=3

from . cimport acado


cdef void callback(double* x_, double* f_, void* userData)

cdef class PyFunction:
    cdef acado.CFunction* _thisptr
    cdef object func
    cdef int dim