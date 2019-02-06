from libcpp cimport bool
from libcpp.string cimport string

cdef extern from 'acado/utils/acado_types.hpp' namespace 'ACADO':
    ctypedef bool BooleanType


cdef extern from 'Eigen/Dense' namespace 'Eigen':

    cdef cppclass PlainObjectBase[T]:
        pass

cdef extern from 'Eigen/Dense' namespace 'Eigen':

    cdef cppclass Matrix[Scalar, Rows, Cols, Options, MaxRows, MaxCols]:
        pass

cdef extern from 'acado/matrix_vector/matrix.hpp' namespace 'ACADO':

    cdef cppclass GenericMatrix[T](Matrix):
        GenericMatrix()
        GenericMatrix(size_t _nRows, size_t _nCols)

        T& operator()(T)
        #GenericMatrix coeff()(T)

        GenericMatrix[T]& setZero()

    ctypedef GenericMatrix[double] DMatrix

cdef extern from 'acado/matrix_vector/vector.hpp' namespace 'ACADO':

    cdef cppclass GenericVector[T]:
        GenericVector()
        GenericVector(size_t _dim)
        void setAll( const T& _value)
        GenericVector[T]& setZero()

    ctypedef GenericVector[double] DVector


cdef extern from "support.h":
    void matrix_assign(DMatrix&, unsigned int, unsigned int, double)
    void vector_assign(DVector&, unsigned int, double)

cdef extern from 'acado/symbolic_expression/constraint_component.hpp' namespace 'ACADO':

    cdef cppclass ConstraintComponent:
        ConstraintComponent()
        ConstraintComponent(const ConstraintComponent)

cdef extern from 'acado/symbolic_expression/expression.hpp' namespace 'ACADO':

    cdef cppclass Expression:
        Expression()
        Expression(const double&) 
        Expression(const DMatrix&)
        Expression(const DVector&)
        Expression(const Expression&)
        Expression(string&, unsigned int , unsigned int)


        Expression operator+ (Expression&)
        Expression operator- (Expression&)
        Expression operator/ (Expression&)
        Expression operator* (Expression&)

        ConstraintComponent operator<= (const double&)
        ConstraintComponent operator>= (const double&)
        ConstraintComponent operator== (const double&)

        Expression getExp()
        Expression getDot()

    cdef cppclass ExpressionType[Derived,Type, AllowCounter](Expression):
        ExpressionType()
        ExpressionType(const double&) 

cdef extern from 'acado/symbolic_expression/variable_types.hpp' namespace 'ACADO':
    cdef cppclass Control(ExpressionType):
        Control()

    cdef cppclass DifferentialState(ExpressionType):
        DifferentialState()
        DifferentialState(string& , unsigned int, unsigned int)
    
    cdef cppclass IntermediateState(ExpressionType):
        IntermediateState()

    cdef cppclass TIME(ExpressionType):
        TIME()

    cdef cppclass Parameter(ExpressionType):
        Parameter()


cdef extern from 'acado/function/function_.hpp' namespace 'ACADO':
    cdef cppclass Function:
        Function()

        Function& operator<< (const Expression&)


        int getDim()
        int getN()
        int getNX()
        int getNU()


        BooleanType isConvex()

cdef extern from 'acado/function/differential_equation.hpp' namespace 'ACADO':

    cdef cppclass DifferentialEquation(Function):
        DifferentialEquation()
        DifferentialEquation(const double &tStart, const double &tEnd )
        DifferentialEquation(const double &tStart, const Parameter &tEnd )

        DifferentialEquation& operator<<( const Expression&)
        DifferentialEquation& operator==( const Expression&)

cdef extern from 'acado/utils/acado_types.hpp' namespace 'ACADO':

    cdef cppclass returnValue:
        pass

    cdef enum TimeHorizonElement:
        AT_TRANSITION
        AT_START
        AT_END

    cdef enum OptionsName:
        HESSIAN_APPROXIMATION
        MAX_NUM_ITERATIONS
        KKT_TOLERANCE

    cdef enum HessianApproximationMode:
        CONSTANT_HESSIAN
        GAUSS_NEWTON
        FULL_BFGS_UPDATE
        BLOCK_BFGS_UPDATE
        GAUSS_NEWTON_WITH_BLOCK_BFGS
        EXACT_HESSIAN
        DEFAULT_HESSIAN_APPROXIMATION

cdef extern from 'acado/ocp/ocp.hpp' namespace 'ACADO':

    cdef cppclass OCP:
        OCP() # fake OCP to allow Cython to allocate the object on the stack
        OCP(const double&, const double&)
        OCP(const double&, const double&, const int&)
        OCP(const double&, const Parameter&)
        OCP(const double&, const Parameter&, const int&)

        returnValue minimizeMayerTerm(const Expression&)
        returnValue minimizeLagrangeTerm(const Expression&)

        returnValue subjectTo( const DifferentialEquation&)
        returnValue subjectTo( int, const ConstraintComponent&)

cdef extern from 'acado/optimization_algorithm/optimization_algorithm.hpp' namespace 'ACADO':

    cdef cppclass OptimizationAlgorithm:
        OptimizationAlgorithm()
        OptimizationAlgorithm(const OCP&)

        returnValue solve() except+

        returnValue set(OptionsName, int) except+ # from options.hpp