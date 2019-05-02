# (C) Copyright 2019 Enthought, Inc., Austin, TX
# All rights reserved.

from libcpp cimport bool
cimport acado 

cdef class DMatrix:
    cdef acado.DMatrix* _thisptr
    cdef bool _owner

cdef class DVector:
    cdef acado.DVector* _thisptr
    cdef bool _owner

cdef class ConstraintComponent:
    cdef acado.ConstraintComponent* _thisptr
    cdef bool _owner

cdef class Expression:
    cdef acado.Expression* _thisptr
    cdef bool _owner

cdef class ExpressionType(Expression):
    pass

cdef class DifferentialState(ExpressionType):
    pass

cdef class IntermediateState(ExpressionType):
    pass

cdef class TIME(ExpressionType):
    pass

cdef class Control(ExpressionType):
    pass

cdef class Parameter(ExpressionType):
    pass

cdef class Function:
    cdef acado.Function* _thisptr
    cdef bool _owner

cdef class DifferentialEquation(Function):
    pass

cdef class OCP:
    cdef acado.OCP* _thisptr
    cdef bool _owner

cdef class VariablesGrid:
    cdef acado.VariablesGrid* _thisptr

cdef class OptimizationAlgorithm:
    cdef acado.OptimizationAlgorithm* _thisptr
    cdef bool _owner
