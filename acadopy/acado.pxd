# (C) Copyright 2019 Enthought, Inc., Austin, TX
# All rights reserved.
# cython: language_level=3

from libcpp cimport bool
from libcpp.string cimport string


cdef extern from 'acado/utils/acado_types.hpp' namespace 'ACADO':
    ctypedef bool BooleanType
    ctypedef void (*cFcnPtr)( double* x, double* f, void *userData )
    ctypedef void (*cFcnDPtr)(int number, double* x, double* seed, double* f, double* df, void *userData)


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

    cdef cppclass GenericVector[T](Matrix):
        GenericVector()
        GenericVector(size_t _dim)
        GenericVector(GenericVector[T] v) # fake copy constructor

        void setAll( const T& _value)
        GenericVector[T]& setZero()

    ctypedef GenericVector[double] DVector
    ctypedef GenericVector[int] IVector
    ctypedef GenericVector[bool] BVector

cdef extern from "support.h":
    void matrix_assign(DMatrix&, unsigned int, unsigned int, double)
    void vector_assign(DVector&, unsigned int, double)

cdef extern from 'acado/symbolic_expression/constraint_component.hpp' namespace 'ACADO':

    cdef cppclass ConstraintComponent:
        ConstraintComponent()
        ConstraintComponent(const ConstraintComponent)

        Expression getExpression()

        ConstraintComponent operator<= (const double&)
        ConstraintComponent operator>= (const double&)
        ConstraintComponent operator== (const double&)

cdef extern from 'acado/symbolic_expression/expression.hpp' namespace 'ACADO':

    cdef cppclass Expression:
        Expression()
        Expression(const double&)
        Expression(const DMatrix&)
        Expression(const DVector&)
        Expression(const Expression&)
        Expression(string&, unsigned int , unsigned int)

        unsigned int getDim()
        unsigned int getNumRows()
        unsigned int getNumCols()
        bool isVariable()

        Expression operator+ (Expression&)
        Expression operator- ()
        Expression operator- (Expression&)
        Expression operator/ (Expression&)
        Expression operator* (Expression&)
        Expression operator= (Expression&)
        Expression operator() (unsigned int)

        ConstraintComponent operator<= (const double&)
        ConstraintComponent operator>= (const double&)
        ConstraintComponent operator== (const double&)

        Expression getExp()
        Expression getDot()

    cdef cppclass ExpressionType[Derived,Type, AllowCounter](Expression):
        ExpressionType() 
        ExpressionType(string&, unsigned int , unsigned int)
        ExpressionType(const double&)
        ExpressionType(const DMatrix&)
        ExpressionType(const DVector&)
        ExpressionType(const Expression&)

cdef extern from 'acado/symbolic_expression/variable_types.hpp' namespace 'ACADO':
    cdef cppclass Control(ExpressionType):
        Control()

    cdef cppclass DifferentialState(ExpressionType):
        DifferentialState() 
        DifferentialState(string&, unsigned int , unsigned int)

    cdef cppclass IntermediateState(ExpressionType):
        IntermediateState()
        IntermediateState(string&, unsigned int , unsigned int)
        IntermediateState(const double&)
        IntermediateState(const DMatrix&)
        IntermediateState(const DVector&)

    cdef cppclass TIME(ExpressionType):
        TIME()

    cdef cppclass Parameter(ExpressionType):
        Parameter()

cdef extern from 'acado/symbolic_expression/acado_syntax.hpp':
    returnValue clearAllStaticCounters()
    IntermediateState exp(const Expression&)
    Expression dot(const Expression& )

cdef extern from 'acado/function/function_.hpp' namespace 'ACADO':
    cdef cppclass Function:
        Function()
        Function(const Function&)

        Function& operator<< (const Expression&)

        int getDim()
        int getN()
        int getNX()
        int getNU()

        BooleanType isConvex()

        DVector evaluate( const EvaluationPoint &x)

cdef extern from 'acado/function/differential_equation.hpp' namespace 'ACADO':

    cdef cppclass DifferentialEquation(Function):
        DifferentialEquation()
        DifferentialEquation(const DifferentialEquation&)
        DifferentialEquation(const double &tStart, const double &tEnd )
        DifferentialEquation(const double &tStart, const Parameter &tEnd )
        DifferentialEquation(const Parameter &tStart, const double &tEnd )
        DifferentialEquation(const Parameter &tStart, const Parameter &tEnd )

        DifferentialEquation& operator==(const Expression&)

cdef extern from 'acado/utils/acado_types.hpp' namespace 'ACADO':

    cdef enum returnValueType:
        SUCCESSFUL_RETURN
        RET_DIV_BY_ZERO
        RET_INDEX_OUT_OF_BOUNDS
        RET_INVALID_ARGUMENTS

        RET_OPTION_ALREADY_EXISTS
        RET_OPTION_DOESNT_EXIST
        RET_OPTIONS_LIST_CORRUPTED
        RET_INVALID_OPTION

        RET_OPTALG_INIT_FAILED

    cdef cppclass returnValue:

        bool operator== (const returnValueType&)
        bool operator!= (const returnValueType&)

    cdef enum TimeHorizonElement:
        AT_TRANSITION
        AT_START
        AT_END

    cdef enum OptionsName:
        HESSIAN_APPROXIMATION
        MAX_NUM_ITERATIONS
        KKT_TOLERANCE
        PARETO_FRONT_GENERATION
        PARETO_FRONT_DISCRETIZATION

    cdef enum HessianApproximationMode:
        CONSTANT_HESSIAN
        GAUSS_NEWTON
        FULL_BFGS_UPDATE
        BLOCK_BFGS_UPDATE
        GAUSS_NEWTON_WITH_BLOCK_BFGS
        EXACT_HESSIAN
        DEFAULT_HESSIAN_APPROXIMATION

    cdef enum ParetoFrontGeneration:
        PFG_FIRST_OBJECTIVE
        PFG_SECOND_OBJECTIVE
        PFG_WEIGHTED_SUM
        PFG_NORMALIZED_NORMAL_CONSTRAINT
        PFG_NORMAL_BOUNDARY_INTERSECTION
        PFG_ENHANCED_NORMALIZED_NORMAL_CONSTRAINT
        PFG_EPSILON_CONSTRAINT
        PFG_UNKNOWN

    cdef enum PrintScheme:
        PS_DEFAULT
        PS_PLAIN
        PS_MATLAB
        PS_MATLAB_BINARY

cdef extern from 'acado/ocp/ocp.hpp' namespace 'ACADO':

    cdef cppclass OCP:
        OCP() # fake OCP to allow Cython to allocate the object on the stack
        OCP(const double&, const double&)
        OCP(const double&, const double&, const int&)
        OCP(const double&, const Parameter&)
        OCP(const double&, const Parameter&, const int&)

        returnValue minimizeMayerTerm(const Expression&)
        returnValue minimizeMayerTerm(const int &multiObjectiveIdx,  const Expression& arg )
        returnValue minimizeLagrangeTerm(const Expression&)

        returnValue subjectTo(const DifferentialEquation&)
        returnValue subjectTo(const ConstraintComponent&)
        returnValue subjectTo(int, const ConstraintComponent&)

        int getNumberOfMayerTerms()

cdef extern from "<iostream>" namespace "std":
    cdef cppclass ostream:
        ostream& operator<< (Expression&)
        ostream& operator<< (Function&)
        ostream& operator<< (VariablesGrid&)
        ostream& operator<< (DVector&)
    ostream cout

cdef extern from 'acado/variables_grid/variables_grid.hpp' namespace 'ACADO':
    cdef cppclass VariablesGrid:
        VariablesGrid()
        VariablesGrid(const VariablesGrid&)
        returnValue pprint "print"(ostream&, const char*, PrintScheme)

cdef extern from 'acado/optimization_algorithm/optimization_algorithm.hpp' namespace 'ACADO':

    cdef cppclass OptimizationAlgorithm:
        OptimizationAlgorithm()
        OptimizationAlgorithm(const OCP&)

        returnValue solve() except+

        returnValue set(OptionsName, int) except+ # from options.hpp
        returnValue set(OptionsName, double) except+ # from options.hpp
        returnValue set(OptionsName, string) except+ # from options.hpp

        returnValue getDifferentialStates(VariablesGrid&)
        returnValue getParameters(VariablesGrid&)
        returnValue getControls(VariablesGrid&)

cdef extern from 'acado/optimization_algorithm/multi_objective_algorithm.hpp' namespace 'ACADO':
    cdef cppclass MultiObjectiveAlgorithm(OptimizationAlgorithm):
        MultiObjectiveAlgorithm()
        MultiObjectiveAlgorithm(const OCP&)

        returnValue solveSingleObjective(const int)

        returnValue getParetoFront(VariablesGrid&)
        returnValue getWeights(const char*)
        returnValue getAllDifferentialStates(const char*)
        returnValue getAllControls(const char*)
        returnValue getAllParameters(const char*)


cdef extern from 'acado/function/evaluation_point.hpp' namespace 'ACADO':

    cdef cppclass EvaluationPoint:
        EvaluationPoint()
        EvaluationPoint(const Function &f)
        returnValue setT (const double &t)
        returnValue setX (const DVector &x)

cdef extern from 'acado/function/c_function.hpp' namespace 'ACADO':

    cdef cppclass CFunction:
        CFunction()
        CFunction(unsigned int dim, cFcnPtr cFcn_)
        CFunction(unsigned int dim, cFcnPtr  cFcn_, cFcnDPtr cFcnDForward_,
                  cFcnDPtr cFcnDBackward_)
        Expression operator()( const Expression &arg )
        returnValue setUserData(void* user_data_)

