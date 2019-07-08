from cython.operator cimport dereference as deref

from . cimport acado

import numpy as np

cdef class DMatrix:

    def __cinit__(self, nrows=0, ncols=0):
        self._thisptr = new acado.DMatrix(nrows, ncols)

    def __dealloc__(self):
        if self._owner and self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def set_zero(self):
        (self._thisptr).setZero()

    def set_value(self, int i, int j, double value):
        acado.matrix_assign(deref(self._thisptr), i, j, value)

    def __setitem__(self, index, double value):
        cdef unsigned int i, j
        i, j = index
        self.set_value(i, j, value)

    @classmethod
    def from_array(cls, np.ndarray[np.float64_t, ndim=2] array):
        cdef acado.DMatrix* _matrix = new acado.DMatrix(Map[Matrix2d](array))
        matrix = cls()
        del matrix._thisptr
        matrix._thisptr = _matrix

cdef class DVector:

    def __cinit__(self, dim=0):
        self._thisptr = new acado.DVector(dim)

    def __dealloc(self):
        if self._owner and self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def set_value(self, int i, double value):
        acado.vector_assign(deref(self._thisptr), i, value)

    def __setitem__(self, index, double value):
        cdef unsigned int i
        i = index
        self.set_value(i, value)

    def set_all(self, float value):
        self._thisptr.setAll(value)

    def set_zero(self):
        (self._thisptr).setZero()