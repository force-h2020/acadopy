# (C) Copyright 2019 Enthought, Inc., Austin, TX
# All rights reserved.
# cython: language_level=3

from libcpp cimport bool


from . cimport acado

cdef class DMatrix:
    cdef acado.DMatrix* _thisptr
    cdef bool _owner

cdef class DVector:
    cdef acado.DVector* _thisptr
    cdef bool _owner