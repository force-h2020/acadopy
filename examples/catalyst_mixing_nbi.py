# (C) Copyright 2019 Enthought, Inc., Austin, TX
# All rights reserved.
""" Python version of the ACADO example
`examples/multi_objective/catalyst_mixing_nbi.cpp`.

"""
from acadopy.api import *
import faulthandler

faulthandler.enable()


x1 = DifferentialState()
x2 = DifferentialState()
x3 = DifferentialState()

u = Control()

f = DifferentialEquation(0.0, 1.0)

f << dot(x1) == (-u * (x1 - 10.0 * x2))
f << dot(x2) == ( u * (x1 - 10.0 * x2) - (1.0 - u) * x2)
f << dot(x3) == ( u / 10.0)

print(f)

ocp = OCP(0.0, 1.0, 25)

ocp.minimizeMayerTerm(0, -(1.0-x1-x2))
ocp.minimizeMayerTerm(1, x3)
ocp.subjectTo(f)

ocp.subjectTo(AT_START, x1 == 1.0)
ocp.subjectTo(AT_START, x2 == 0.0)
ocp.subjectTo(AT_START, x3 == 0.0)

ocp.subjectTo(0.0 <= x1 <= 1.0)
ocp.subjectTo(0.0 <= x2 <= 1.0)
ocp.subjectTo(0.0 <= x3 <= 1.0)
ocp.subjectTo(0.0 <= u <= 1.0)

algorithm = MultiObjectiveAlgorithm(ocp)

algorithm.set(PARETO_FRONT_GENERATION, PFG_NORMAL_BOUNDARY_INTERSECTION)
algorithm.set(PARETO_FRONT_DISCRETIZATION, 11)
algorithm.set(HESSIAN_APPROXIMATION, EXACT_HESSIAN)

# Minimize individual objective function
algorithm.solve_single_objective(0)

# Minimize individual objective function
algorithm.solve_single_objective(1)

# Generate Pareto set
algorithm.solve()

pareto_front = algorithm.get_pareto_front()
print('Pareto front')
print(pareto_front)