# FIXME: consider using smartpointers in place of managing the ownership of pointers!
from cython.operator cimport dereference as deref

cimport acado

AT_START = acado.TimeHorizonElement.AT_START
AT_END = acado.TimeHorizonElement.AT_END

HESSIAN_APPROXIMATION = acado.OptionsName.HESSIAN_APPROXIMATION
MAX_NUM_ITERATIONS = acado.OptionsName.MAX_NUM_ITERATIONS
KKT_TOLERANCE = acado.OptionsName.KKT_TOLERANCE

EXACT_HESSIAN = acado.HessianApproximationMode.EXACT_HESSIAN

cdef class DMatrix:

    def __cinit__(self, nrows=0, ncols=0):
        self._thisptr = new acado.DMatrix(nrows, ncols)

    def __dealloc__(self):
        del self._thisptr

    def set_zero(self):
        (self._thisptr).setZero()

    def set_value(self, int i, int j, double value):
        acado.matrix_assign(deref(self._thisptr), i, j, value)

    def __setitem__(self, index, double value):
        cdef unsigned int i, j 
        i, j = index
        self.set_value(i, j, value)

cdef class DVector:

    def __cinit__(self, dim=0):
        self._thisptr = new acado.DVector(dim)

    def __dealloc(self):
        del self._thisptr

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

def as_expression(value):
    if not isinstance(value, Expression):
        try:
            expression = Expression.factory(value)
        except ValueError:
            return NotImplemented
    else:
        expression = value
    return expression


cdef expression_from_ref(acado.Expression* expression, owner=False):
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
        del self._thisptr


cdef class Expression:

    def __cinit__(self, str name=None, int nrows=0, int ncols=0, initialize=True):
        if initialize:
            if name is not None:
                self._thisptr = new acado.Expression(
                    name, <unsigned int>nrows, <unsigned int>ncols)
            else:
                self._thisptr = new acado.Expression()
        else:
            self._owner = False

    def __dealloc__(self):
        if self._owner:
            del self._thisptr
        self._thisptr = NULL

    @classmethod
    def factory(cls, value):
        cdef acado.Expression* _expression
        cdef DMatrix _matrix
        cdef DVector _vector
        if isinstance(value, float):
            _expression = new acado.Expression(<double>value)
        elif isinstance(value, int):
            _expression = new acado.Expression(<double>float(value))
        elif isinstance(value, DMatrix):
            _matrix = value
            _expression = new acado.Expression(deref(_matrix._thisptr))
        elif isinstance(value, DVector):
            _vector = value
            _expression = new acado.Expression(deref(_vector._thisptr))
        else:
            raise ValueError(
                'Creating expression from {} is not supported'.format(
                    type(value)
                )
            )
        cdef Expression expression = cls()
        return expression_from_ref(_expression, owner=True)

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
        lhs = as_expression(other)

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

        lhs = as_expression(other)
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
        cdef Expression lhs

        cdef double rhs = other
        lhs = as_expression(other)

        _result = new acado.ConstraintComponent(
            deref(lhs._thisptr) >= rhs
        )

        cdef ConstraintComponent component = ConstraintComponent(initialize=False)
        component._thisptr = _result
        component._owner = True

        return component 

cdef class ExpressionType(Expression):
    pass
        
def exp(Expression expression):
    cdef acado.Expression* _expression
    _expression =  new acado.Expression(expression._thisptr.getExp())
    return expression_from_ref(_expression, owner=True)

def dot(Expression expression):
    cdef acado.Expression* _expression
    _expression =  new acado.Expression(expression._thisptr.getDot())
    return expression_from_ref(_expression, owner=True)

cdef class DifferentialState(ExpressionType):
    """ Python wrapper of the DifferentialState class 
    """

    def __cinit__(self, str name=None, int nrows=0, int ncols=0, initialize=True):
        if initialize:
            if name is None:
                self._thisptr = new acado.DifferentialState()
            else:
                self._thisptr = new acado.DifferentialState(
                    name, <unsigned int>nrows, <unsigned int>ncols
                )

cdef class IntermediateState(ExpressionType):
    """ Python wrapper of the IntermediateState class 
    """

    def __cinit__(self, initialize=True):
        if initialize:
            self._thisptr = new acado.IntermediateState()


cdef class TIME(ExpressionType):
    """ Python wrapper of the TIME class 
    """

    def __cinit__(self, initialize=True):
        if initialize:
            self._thisptr = new acado.TIME()

cdef class Control(ExpressionType):
    def __cinit__(self, initialize=True):
        if initialize:
            self._thisptr = new acado.Control()

cdef class Parameter(ExpressionType):
    def __cinit__(self, initialize=True):
        if initialize:
            self._thisptr = new acado.Parameter()

cdef class Function:
    """ Python wrapper of the Function class 
    """

    def __cinit__(self):
        self._thisptr = new acado.Function()


    def __lshift__(self, other):
        cdef Expression rhs
        cdef Function lhs
        cdef acado.Function _function

        if isinstance(self, Function) and isinstance(other, Expression):
            lhs = self
            rhs = other
            _function = deref(lhs._thisptr)

            _function << deref(rhs._thisptr)

            return self
        else:
            return NotImplemented

    property dim:
        def __get__(self):
            return self._thisptr.getDim()

    property n:
        def __get__(self):
            return self._thisptr.getN()

    property nx:
        def __get__(self):
            return self._thisptr.getNX()

    property nu:
        def __get__(self):
            return self._thisptr.getNU()

    def isConvex(self):
        return self._thisptr.isConvex()

cdef class DifferentialEquation(Function):

    def __cinit__(self, start=None, end=None):
        cdef float dstart
        cdef Parameter pend 
        cdef acado.Parameter _parameter
        if start == end == None:
            self._thisptr = new acado.DifferentialEquation()
        else:
            # FIXME: support other constructors
            dstart = start
            pend = end
            _parameter = deref(<acado.Parameter*>pend._thisptr)
            self._thisptr = new acado.DifferentialEquation(<double>start, _parameter)

    
    def __eq__(self, other):
        if not isinstance(other, Expression):
            return NotImplemented
        
        cdef acado.DifferentialEquation _result
        cdef Expression rhs
        cdef DifferentialEquation lhs

        lhs = self
        rhs = other

        _result = deref(<acado.DifferentialEquation*>lhs._thisptr)

        _result == deref(rhs._thisptr)

        return self    

cdef class OCP:

    def __cinit__(self, start, end, intervals=None):

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
        if self._owner:
            del self._thisptr
        self._thisptr = NULL

    def minimizeMayerTerm(self, arg):
        cdef Expression expression = arg
        self._thisptr.minimizeMayerTerm(deref(expression._thisptr))

    def minimizeLagrangeTerm(self, arg):
        cdef Expression expression = arg
        self._thisptr.minimizeLagrangeTerm(deref(expression._thisptr))

    def subjectTo(self, *args):
        cdef DifferentialEquation diffeq
        cdef int index
        cdef ConstraintComponent constraint
        if len(args) == 1:
            if isinstance(args[0], DifferentialEquation):
                diffeq = args[0]
                self._thisptr.subjectTo(
                    deref(<acado.DifferentialEquation*>diffeq._thisptr)
                )
        elif len(args) == 2:
            index, constraint = args
            self._thisptr.subjectTo(index, deref(constraint._thisptr))


cdef class OptimizationAlgorithm:

    def __cinit__(self, ocp=None):
        cdef OCP _ocp
        if ocp:
            _ocp = ocp
            self._thisptr = new acado.OptimizationAlgorithm(
                deref(_ocp._thisptr)
            )
        else:
            self._thisptr = new acado.OptimizationAlgorithm()

        self._owner = True

    def __dealloc__(self):
        if self._owner:
            del self._thisptr

    def set(self, int option_id, value):
        values = {
            HESSIAN_APPROXIMATION:acado.OptionsName.HESSIAN_APPROXIMATION,
            MAX_NUM_ITERATIONS:acado.OptionsName.MAX_NUM_ITERATIONS,
            KKT_TOLERANCE:acado.OptionsName.KKT_TOLERANCE,
        }

        if isinstance(value, int):
            self._thisptr.set(<acado.OptionsName> values[option_id], <int>value)
        elif isinstance(value, float):
            self._thisptr.set(<acado.OptionsName> values[option_id], <double>value)
        #elif isinstance(value, str):
        #    # FIXME: sort out the unicode/bytes string questions
        #    self._thisptr.set(<acado.OptionsName> values[option_id], <str>value)


    
    def solve(self):
        self._thisptr.solve()