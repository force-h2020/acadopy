# (C) Copyright 2019 Enthought, Inc., Austin, TX
# All rights reserved.

# distutils: language=c++
# cython: language_level=3
# cython: c_string_type=unicode, c_string_encoding=utf8

from libcpp cimport bool

import logging

# FIXME: consider using smartpointers in place of managing the ownership of pointers!
from cython.operator cimport dereference as deref

from . cimport acado

from .function cimport DifferentialEquation

# FIXME: consider moving these global definitions to their own submodule
# Return codes
SUCCESSFUL_RETURN = acado.returnValueType.SUCCESSFUL_RETURN
RET_OPTALG_INIT_FAILED = acado.returnValueType.RET_OPTALG_INIT_FAILED
RET_INVALID_ARGUMENTS = acado.returnValueType.RET_INVALID_ARGUMENTS

# General solver options
HESSIAN_APPROXIMATION = acado.OptionsName.HESSIAN_APPROXIMATION
MAX_NUM_ITERATIONS = acado.OptionsName.MAX_NUM_ITERATIONS
KKT_TOLERANCE = acado.OptionsName.KKT_TOLERANCE

# Pareto options
PARETO_FRONT_GENERATION = acado.OptionsName.PARETO_FRONT_GENERATION
PARETO_FRONT_DISCRETIZATION = acado.OptionsName.PARETO_FRONT_DISCRETIZATION

# Pareto front generation possible values
PFG_WEIGHTED_SUM = acado.ParetoFrontGeneration.PFG_WEIGHTED_SUM
PFG_FIRST_OBJECTIVE = acado.ParetoFrontGeneration.PFG_FIRST_OBJECTIVE
PFG_SECOND_OBJECTIVE = acado.ParetoFrontGeneration.PFG_SECOND_OBJECTIVE
PFG_NORMALIZED_NORMAL_CONSTRAINT = acado.ParetoFrontGeneration.PFG_NORMALIZED_NORMAL_CONSTRAINT
PFG_NORMAL_BOUNDARY_INTERSECTION = acado.ParetoFrontGeneration.PFG_NORMAL_BOUNDARY_INTERSECTION
PFG_ENHANCED_NORMALIZED_NORMAL_CONSTRAINT = acado.ParetoFrontGeneration.PFG_ENHANCED_NORMALIZED_NORMAL_CONSTRAINT
PFG_EPSILON_CONSTRAINT = acado.ParetoFrontGeneration.PFG_EPSILON_CONSTRAINT
PFG_UNKNOWN = acado.ParetoFrontGeneration.PFG_UNKNOWN

# Hessian Approximation possible values
EXACT_HESSIAN = acado.HessianApproximationMode.EXACT_HESSIAN

# Time Horizon macros
AT_START = acado.TimeHorizonElement.AT_START
AT_END = acado.TimeHorizonElement.AT_END

logger = logging.getLogger(__name__)

def clear_static_counters():
    logger.debug('Clearing up all the static counters')
    return_value = acado.clearAllStaticCounters()
    if return_value != SUCCESSFUL_RETURN:
        raise RuntimeError('Error while clearing up static counters')

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

cdef class DVector:

    def __cinit__(self, int dim=0):
        self._thisptr = new acado.DVector(<size_t>dim)

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

    def __repr__(self):
        # Fake print statement
        acado.cout << deref(self._thisptr)
        return ""

def as_expression(value):
    if not isinstance(value, Expression):
        try:
            expression = Expression(value)
        except ValueError:
            return NotImplemented
    else:
        expression = value
    return expression

cdef expression_from_ref(acado.Expression* expression, owner):
    """ Return a Cython Expression from an ACADO Expression reference.

    """
    cdef Expression result = Expression(initialize=False)
    result._thisptr = expression
    # considering we're not the owner of the reference
    result._owner = owner
    return result

cdef class ConstraintComponent:

    def __cinit__(self, initialize=True):
        if initialize:
            self._thisptr = new acado.ConstraintComponent()

    def __dealloc__(self):
        if self._owner and self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def __repr__(self):
        # Fake print statement
        acado.cout << deref(self._thisptr).getExpression()
        return ""

    def __le__(self, other):
        cdef acado.ConstraintComponent* _result
        cdef ConstraintComponent lhs

        cdef double rhs = other
        lhs = self

        _result =  new acado.ConstraintComponent(
            deref(lhs._thisptr) <= rhs
        )

        cdef ConstraintComponent component = ConstraintComponent(initialize=False)
        component._thisptr = _result
        component._owner = True

        return component

    def __eq__(self, other):
        if not isinstance(self, ConstraintComponent) and not isinstance(other, float):
            return NotImplemented

        cdef acado.ConstraintComponent* _result
        cdef ConstraintComponent lhs
        cdef double rhs
        cdef ConstraintComponent component

        lhs = self
        rhs = other

        _result = new acado.ConstraintComponent(
            deref(lhs._thisptr) == rhs
        )

        component = ConstraintComponent(initialize=False)
        component._thisptr = _result
        component._owner = True
        result = component

        return result

    def __ge__(self, other):

        cdef acado.ConstraintComponent* _result
        cdef ConstraintComponent lhs

        cdef double rhs = other
        lhs = self

        _result = new acado.ConstraintComponent(
            deref(lhs._thisptr) >= rhs
        )

        cdef ConstraintComponent component = ConstraintComponent(initialize=False)
        component._thisptr = _result
        component._owner = True

        return component


cdef class Expression: 

    def __cinit__(self, _arg=None, int nrows=0, int ncols=0, initialize=True):
        """ Support a combination of constructors 
        
        - (name, nrows, ncols) 
        - ctx from double, int, DVector, DMatrix
        
        """
        cdef str name = ""
        cdef DMatrix _matrix
        cdef DVector _vector

        if type(self) is Expression:
            
            is_default_ctx = (_arg is None) or isinstance(_arg, str)
            if isinstance(_arg, str):
                name = _arg

            if initialize:
                if is_default_ctx:
                    self._thisptr = new acado.Expression(
                        <str>name, <unsigned int>nrows, <unsigned int>ncols
                    )
                else:
                    if isinstance(_arg, float):
                        self._thisptr = new acado.Expression(<double>_arg)
                    elif isinstance(_arg, int):
                        self._thisptr = new acado.Expression(<double>float(_arg))
                    elif isinstance(_arg, DMatrix):
                        _matrix = _arg
                        self._thisptr = new acado.Expression(deref(_matrix._thisptr))
                    elif isinstance(_arg, DVector):
                        _vector = _arg
                        self._thisptr = new acado.Expression(deref(_vector._thisptr))
                    else:
                        raise RuntimeError('Unsupported constructor')
                self._owner = True
            else:
                self._owner = False
            
    def __dealloc__(self):
        if self._owner and self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def __repr__(self):
        # Fake print statement
        if self._thisptr is NULL:
            # Should not be the case if the bindings are implemented properly
            return "<Null pointer> / {}".format(self._owner)
        else:
            acado.cout << deref(self._thisptr)
            return ""

    @property
    def dim(self):
        return self._thisptr.getDim()

    @property
    def num_rows(self):
        return self._thisptr.getNumRows()

    @property
    def num_cols(self):
        return self._thisptr.getNumCols()

    @property
    def is_variable(self):
        return self._thisptr.isVariable()

    def __add__(self, other):
        cdef acado.Expression*  _result
        cdef Expression lhs, rhs

        rhs = as_expression(self)
        lhs = as_expression(other)

        _result = new acado.Expression(
            deref(rhs._thisptr) + deref(lhs._thisptr)
        )
        return expression_from_ref(_result, owner=True)

    def __div__(self, other):
        return self.__truediv__(other)

    def __truediv__(self, other):
        cdef acado.Expression* _result
        cdef Expression lhs, rhs

        rhs = as_expression(self)
        lhs = as_expression(other)

        _result = new acado.Expression(
            deref(rhs._thisptr) / deref(lhs._thisptr)
        )
        return expression_from_ref(_result, owner=True)

    def __sub__(self, other):
        cdef acado.Expression* _result
        cdef Expression lhs, rhs

        rhs = as_expression(self)
        lhs = as_expression(other)

        _result = new acado.Expression(
            deref(rhs._thisptr) - deref(lhs._thisptr)
        )
        return expression_from_ref(_result, owner=True)

    def __mul__(self, other):
        cdef acado.Expression* _result
        cdef Expression rhs, lhs

        rhs = as_expression(self)
        lhs = as_expression(other)

        _result = new acado.Expression(
            deref(rhs._thisptr) * deref(lhs._thisptr)
        )

        return expression_from_ref(_result, owner=True)

    def __le__(self, other):
        cdef acado.ConstraintComponent* _result
        cdef Expression lhs

        cdef double rhs = other
        lhs = self

        _result =  new acado.ConstraintComponent(
            deref(lhs._thisptr) <= rhs
        )

        cdef ConstraintComponent component = ConstraintComponent(initialize=False)
        component._thisptr = _result
        component._owner = True

        return component

    def __eq__(self, other):
        if not isinstance(self, Expression) and not isinstance(other, float):
            return NotImplemented

        cdef acado.ConstraintComponent* _result
        cdef Expression lhs
        cdef double rhs
        cdef ConstraintComponent component

        lhs = self
        rhs = other

        _result = new acado.ConstraintComponent(
            deref(lhs._thisptr) == rhs
        )

        component = ConstraintComponent(initialize=False)
        component._thisptr = _result
        component._owner = True
        result = component

        return result

    def __neg__(self):

        cdef acado.Expression* _result
        cdef Expression lhs
        cdef Expression component

        lhs = self

        _result = new acado.Expression(
            - deref(lhs._thisptr)
        )

        component = Expression(initialize=False)
        component._thisptr = _result
        component._owner = True
        result = component

        return result

    def __ge__(self, other):

        cdef acado.ConstraintComponent* _result
        cdef Expression lhs

        cdef double rhs = other
        lhs = self

        _result = new acado.ConstraintComponent(
            deref(lhs._thisptr) >= rhs
        )

        cdef ConstraintComponent component = ConstraintComponent(initialize=False)
        component._thisptr = _result
        component._owner = True

        return component

    def __setitem__(self, int idx, value):

        cdef Expression rhs, lhs
        cdef acado.Expression* _rhs
        cdef acado.Expression* _lhs
        cdef unsigned int _idx = idx

        rhs = as_expression(value)

        cdef acado.Expression exp = deref(self._thisptr)(_idx)
        
        # FIXME: get the assignment operator= to work with
        exp = deref(rhs._thisptr) # assignment


cdef class ExpressionType(Expression):
    # Is it ok to let users rely on the Expression.__cinit__.
    # Instantiating an ExpressionType directly does not make sense
    # as it misses the template info...
    pass

def exp(Expression expression):
    cdef acado.Expression* _expression
    _expression =  new acado.Expression(acado.exp(deref(expression._thisptr)))
    return expression_from_ref(_expression, owner=True)

def dot(Expression expression):
    cdef acado.Expression* _expression
    _expression =  new acado.Expression(acado.dot(deref(expression._thisptr)))
    return expression_from_ref(_expression, owner=True)

cdef class DifferentialState(ExpressionType):
    """ Python wrapper of the DifferentialState class
    """

    def __cinit__(self, _arg=None, int nrows=1, int ncols=1, initialize=True):
        """ Support a combination of constructors 
        
        - ()
        - (name, nrows, ncols) 
        
        """
    
        if type(self) is DifferentialState:
            if initialize:
                if _arg is not None:
                    self._thisptr = new acado.DifferentialState(
                        <str>_arg, <unsigned int>nrows, <unsigned int>ncols
                    )
                else:
                    self._thisptr = new acado.DifferentialState()       
                self._owner = True
            else:
                self._owner = False

cdef class IntermediateState(ExpressionType):
    """ Python wrapper of the IntermediateState class
    """

    def __cinit__(self, _arg=None, int nrows=1, int ncols=1, initialize=True):
        """ Support a combination of constructors 
        
        - (name, nrows, ncols) 
        - ctx from double, DVector, DMatrix
        
        """
        cdef str name = ""
        cdef DMatrix _matrix
        cdef DVector _vector

        if type(self) is IntermediateState:
            
            is_default_ctx = (_arg is None) or isinstance(_arg, (str, int))
            if isinstance(_arg, str):
                name = _arg
            if isinstance(_arg, int):
                nrows = _arg

            if initialize:
                if is_default_ctx:
                    self._thisptr = new acado.IntermediateState(
                        <str>name, <unsigned int>nrows, <unsigned int>ncols
                    )
                else:
                    if isinstance(_arg, float):
                        self._thisptr = new acado.IntermediateState(<double>_arg)
                    elif isinstance(_arg, DMatrix):
                        _matrix = _arg
                        self._thisptr = new acado.IntermediateState(deref(_matrix._thisptr))
                    elif isinstance(_arg, DVector):
                        _vector = _arg
                        self._thisptr = new acado.IntermediateState(deref(_vector._thisptr))
                    else:
                        raise RuntimeError('Unsupported constructor')
                self._owner = True
            else:
                self._owner = False


cdef class TIME(ExpressionType):
    """ Python wrapper of the TIME class
    """

    def __cinit__(self, initialize=True):
        if type(self) == TIME:
            if initialize:
                self._thisptr = new acado.TIME()

cdef class Control(ExpressionType):
    def __cinit__(self, initialize=True):
        if type(self) == Control:
            if initialize:
                self._thisptr = new acado.Control()

cdef class Parameter(ExpressionType):
    def __cinit__(self, initialize=True):
        if type(self) == Parameter:
            if initialize:
                self._thisptr = new acado.Parameter()


cdef class OCP:

    def __cinit__(self, start, end, intervals=None):
        """ Initialise OCP.

        Parameters
        ----------
        start: float
            time at start.
        end: float
            time at end.

        Keyword arguments
        -----------------
        intervals: int
            number of sampling points in time range.

        """
        cdef acado.Parameter ps, pe
        cdef double ds, de
        if start is not None and end is not None:
            if isinstance(start, float):
                ds = <double> start
                if isinstance(end, Parameter):
                    pe = deref(
                        <acado.Parameter*>((<Parameter>end)._thisptr)
                    )
                    if intervals is not None:
                        self._thisptr = new acado.OCP(ds, pe, <int>intervals)
                    else:
                        self._thisptr = new acado.OCP(ds, pe)
                else:
                    de = <double>end
                    if intervals is not None:
                        self._thisptr = new acado.OCP(ds, de, <int>intervals)
                    else:
                        self._thisptr = new acado.OCP(ds, de)

    def __dealloc__(self):
        if self._owner and self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def minimizeMayerTerm(self, *args):
        cdef Expression expression
        cdef int multi_objective_index
        if len(args) == 2:
            multi_objective_index = args[0]
            expression = args[1]
            self._thisptr.minimizeMayerTerm(multi_objective_index, deref(expression._thisptr))
        elif len(args) == 1:
            logger.warning('This call signature is experimental and made lead to segfaults.')
            expression = args[0]
            self._thisptr.minimizeMayerTerm(deref(expression._thisptr))
        else:
            raise ValueError('Invalid function parameters')

    def minimizeLagrangeTerm(self, arg):
        cdef Expression expression = arg
        self._thisptr.minimizeLagrangeTerm(deref(expression._thisptr))

    def subjectTo(self, *args):

        cdef DifferentialEquation diffeq
        cdef int index
        cdef ConstraintComponent constraint
        cdef acado.returnValue return_value

        if len(args) == 1:
            if isinstance(args[0], DifferentialEquation):
                diffeq = args[0]
                return_value = self._thisptr.subjectTo(
                    deref(<acado.DifferentialEquation*>diffeq._thisptr)
                )
            elif isinstance(args[0], ConstraintComponent):
                constraint = args[0]
                return_value = self._thisptr.subjectTo(
                    deref(constraint._thisptr)
                )
            else:
                raise ValueError('Unsupported input type for OCP.subjectTo()')
        elif len(args) == 2:
            index, constraint = args
            return_value = self._thisptr.subjectTo(index, deref(constraint._thisptr))

        if return_value != SUCCESSFUL_RETURN:
            raise ValueError('Error while calling subjectTo {}'.format(args))

    def get_number_of_mayer_terms(self):
        return self._thisptr.getNumberOfMayerTerms()

cdef class VariablesGrid:

    def __cinit__(self):
        self._thisptr = new acado.VariablesGrid()
        self._owner=True

    def __dealloc__(self):
        if self._owner and self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def __repr__(self):
        # Fake print statement
        acado.cout << deref(self._thisptr)
        return ""
    

    def pprint(self, str name=""):
        self._thisptr.pprint(acado.cout, name, acado.PrintScheme.PS_DEFAULT)

cdef class OptimizationAlgorithm:

    def __cinit__(self, ocp=None):
        cdef OCP _ocp

        if type(self) is OptimizationAlgorithm: 
            if ocp:
                _ocp = ocp
                self._thisptr = new acado.OptimizationAlgorithm(
                    deref(_ocp._thisptr)
                )
            else:
                self._thisptr = new acado.OptimizationAlgorithm()

            self._owner = True

    def __dealloc__(self):
        if type(self) is OptimizationAlgorithm:
            if self._owner and self._thisptr is not NULL:
                del self._thisptr
                self._thisptr = NULL

    def set(self, int option_id, value):

        cdef acado.returnValue return_value
        values = {
            HESSIAN_APPROXIMATION: acado.OptionsName.HESSIAN_APPROXIMATION,
            MAX_NUM_ITERATIONS: acado.OptionsName.MAX_NUM_ITERATIONS,
            KKT_TOLERANCE: acado.OptionsName.KKT_TOLERANCE,
            PARETO_FRONT_GENERATION: acado.OptionsName.PARETO_FRONT_GENERATION,
            PARETO_FRONT_DISCRETIZATION: acado.OptionsName.PARETO_FRONT_DISCRETIZATION
        }

        if option_id not in values:
            raise KeyError('{} not defined'.format(option_id))

        if isinstance(value, int):
            return_value = self._thisptr.set(<acado.OptionsName> values[option_id], <int>value)
        elif isinstance(value, float):
            self._thisptr.set(<acado.OptionsName> values[option_id], <double>value)
        # elif isinstance(value, str):
           # FIXME: sort out the unicode/bytes string questions
           # self._thisptr.set(<acado.OptionsName> values[option_id], <char*>value)

        # TODO: consolidate error management. The C++ object does not allow us to access
        # the integer value of the returnValue object, which makes the code below ugly.
        if return_value == RET_INVALID_ARGUMENTS:
            raise ValueError('Invalid argument {}'.format(option_id))
        if return_value != SUCCESSFUL_RETURN:
            if return_value == acado.returnValueType.RET_OPTION_ALREADY_EXISTS:
                raise ValueError('Option already exists')
            elif  return_value == acado.returnValueType.RET_OPTION_DOESNT_EXIST:
                raise ValueError('Option does not exist')
            elif  return_value == acado.returnValueType.RET_INVALID_OPTION:
                raise ValueError('Invalid option')
            
    def solve(self):
        _return_value = self._thisptr.solve()
        if _return_value == RET_OPTALG_INIT_FAILED:
            raise RuntimeError('ACADO optimizer failed to initialize.')
        elif _return_value != SUCCESSFUL_RETURN:
            raise RuntimeError('ACADO optimizer failed.')

    def get_differential_states(self):
        cdef acado.VariablesGrid _grid = acado.VariablesGrid()
        self._thisptr.getDifferentialStates(_grid)

        cdef VariablesGrid grid = VariablesGrid()
        grid._thisptr = new acado.VariablesGrid(_grid)

        return grid

    def get_parameters(self):
        cdef acado.VariablesGrid _grid = acado.VariablesGrid()
        self._thisptr.getParameters(_grid)

        cdef VariablesGrid grid = VariablesGrid()
        grid._thisptr = new acado.VariablesGrid(_grid)

        return grid

    def get_controls(self):
        cdef acado.VariablesGrid _grid = acado.VariablesGrid()
        self._thisptr.getControls(_grid)

        cdef VariablesGrid grid = VariablesGrid()
        grid._thisptr = new acado.VariablesGrid(_grid)

        return grid

cdef class MultiObjectiveAlgorithm(OptimizationAlgorithm):

    def __cinit__(self, ocp=None):
        cdef OCP _ocp

        if type(self) is MultiObjectiveAlgorithm:
            if ocp:
                _ocp = ocp
                self._mcoptr = new acado.MultiObjectiveAlgorithm(
                    deref(_ocp._thisptr)
                )
            else:
                self._mcoptr = new acado.MultiObjectiveAlgorithm()

            self._thisptr = <acado.OptimizationAlgorithm*>self._mcoptr

            self._owner = True

    def __dealloc__(self):
        if type(self) is MultiObjectiveAlgorithm:
            if self._owner and self._mcoptr is not NULL:
                del self._mcoptr
                self._mcoptr = NULL
                self._thisptr = NULL

    def get_all_differential_states(self, filename):
       self._mcoptr.getAllDifferentialStates(filename)

    def get_pareto_front(self):
        cdef acado.VariablesGrid _grid = acado.VariablesGrid()
        self._mcoptr.getParetoFront(_grid)

        cdef VariablesGrid grid = VariablesGrid()
        grid._thisptr = new acado.VariablesGrid(_grid)

        return grid        

    def solve_single_objective(self, int number):
        cdef acado.returnValue _return_value
        _return_value = self._mcoptr.solveSingleObjective(number)

        if _return_value != SUCCESSFUL_RETURN:
            raise RuntimeError('Solve single objective failed.')
