# (C) Copyright 2019 Enthought, Inc., Austin, TX
# All rights reserved.

""" Example of NLP optimising python function"""

from acadopy.api import (
    expression_from_method, Parameter, OCP, OptimizationAlgorithm,
    AT_START, MAX_NUM_ITERATIONS, KKT_TOLERANCE)


def opt_acadopy(python_func, initial_values, constraints):
    """Partial func. Performs a acadopy optimise given the
    scoring function, the initial point, and a set of constraints.

    Parameters
    ----------
    puthon_func: method
        Function to optimise (in this case minimise) written in pure
        python that takes in n variables
    initial_values: array-like (float)
        Array of initial values for n variables
    constaints: list of tuple (float, float)
        List of n constaints of variables as (min, max) values

    Returns
    -------

    parameters: array-like
        Array of optimised values for n variables
    """

    """Initialising Non-Linear Problem solver as an Optimal-Control
    Probelm (OCP) with no dynamic range"""
    nlp = OCP(0.0, 0.0, 0)

    "Initialising Parameters
    variables = tuple([Parameter() for var in variables])

    wrapped_function = expression_from_method(python_func)

    #: Stating Mayer Term
    nlp.minimizeMayerTerm(wrapped_function)

    #: Stating Constraints
    for var, constraint in zip(variables, constraints):
        nlp.subjectTo(constraint[0] <= var <= constraint[1])

    #: Stating Initial Values
    for var, value in enumerate(variables, initial_values):
        nlp.subjectTo(AT_START, var == value)

    #: Inititalising Optimsiation algorithm
    algorithm = OptimizationAlgorithm(nlp)
    algorithm.set(MAX_NUM_ITERATIONS, 20)
    algorithm.set(KKT_TOLERANCE, 1e-10)

    algorithm.solve()

    parameters = algorithm.get_parameters()

    return parameters

if __name__ == '__main__':
    """Example needs to pass in a function in pure python that 
    takes in a set of n variables and n constraints"""
