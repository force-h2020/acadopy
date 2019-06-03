# (C) Copyright 2019 Enthought, Inc., Austin, TX
# All rights reserved.

""" Port of files in examples/nlp to Python. """

from acadopy.api import *

def nlp_simple_solver():

    print("Initialising NLP")
    nlp = OCP(0.0, 0.0, 0)

    print("Initialising Parameters")
    a = Parameter()
    b = Parameter()

    print("Stating Mayer Term")


    nlp.minimizeMayerTerm(a * a + b * b)

    print("Stating Constraints")
    nlp.subjectTo(0.08 <= a )
    nlp.subjectTo(0.1 <= a + b + 0.3*a*a )

    print("Inititalising Optimsiation algorithm")
    algorithm = OptimizationAlgorithm(nlp)
    algorithm.solve()

    results = algorithm.get_parameters()
    print("optimal solution:")
    print(results)

def rosenbrock_function():

    print("Initialising NLP")
    nlp = OCP(0.0, 0.0, 0)

    print("Initialising Parameters")
    x = Parameter()
    y = Parameter()

    print("Stating Mayer Term")
    nlp.minimizeMayerTerm(
        100.0 * ( y - x * x ) * ( y - x * x ) + (1.0 - x) * (1.0 - x))

    algorithm = OptimizationAlgorithm(nlp)
    algorithm.set(KKT_TOLERANCE, 1e-12 )
    algorithm.solve()

    results = algorithm.get_parameters()
    print("optimal solution:")
    print(results)

def three_dimensional_function():

    print("Initialising NLP")
    nlp = OCP(0.0, 0.0, 0)

    print("Initialising Parameters")
    x = Parameter()
    y = Parameter()
    z = Parameter()

    print("Stating Mayer Term")
    nlp.minimizeMayerTerm(x * y + y * z)

    print("Stating Constraints")
    nlp.subjectTo(x*x - y*y + z*z >= 2.0  )
    nlp.subjectTo(x * x + y * y + z * z <= 10.0)
    nlp.subjectTo(x >= 0.01)
    nlp.subjectTo(y >= 0.01)
    nlp.subjectTo(z >= 0.01)

    algorithm = OptimizationAlgorithm(nlp)
    algorithm.solve()

    results = algorithm.get_parameters()
    print("optimal solution:")
    print(results)

if __name__ == '__main__':
    nlp_simple_solver()
    rosenbrock_function()
    three_dimensional_function()