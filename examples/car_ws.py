# (C) Copyright 2019 Enthought, Inc., Austin, TX
# All rights reserved.

import os
import sys

from acadopy.api import (
    DifferentialState, Control, Parameter, DifferentialEquation, dot, OCP,
    AT_START, AT_END, MultiObjectiveAlgorithm, PFG_WEIGHTED_SUM,
    PARETO_FRONT_GENERATION, PARETO_FRONT_DISCRETIZATION, KKT_TOLERANCE
)


x1 = DifferentialState()
x2 = DifferentialState()
t1 = Parameter()
u = Control()

f = DifferentialEquation(0, t1)

f << dot(x1) == x2
f << dot(x2) == u

ocp = OCP(0.0, t1, 25)

ocp.minimizeMayerTerm(x2)
print('mayer num', ocp.get_number_of_mayer_terms())
ocp.minimizeMayerTerm(2.0 * t1 / 20.0)
print('mayer num', ocp.get_number_of_mayer_terms())

ocp.subjectTo(f)
print('mayer num', ocp.get_number_of_mayer_terms())

ocp.subjectTo(AT_START, x1 == 0.0)
ocp.subjectTo(AT_START, x2 == 0.0)
ocp.subjectTo(AT_END, x1 == 200.0)

ocp.subjectTo(0.0 <= x1 <= 200.001)
ocp.subjectTo(0.0 <= x2 <= 40.0)
ocp.subjectTo(0.0 <= u <= 5.0)
ocp.subjectTo(0.0 <= t1 <= 50.0)

algorithm = MultiObjectiveAlgorithm(ocp)
# algorithm.set(PARETO_FRONT_GENERATION, PFG_WEIGHTED_SUM)
# algorithm.set(PARETO_FRONT_DISCRETIZATION, 11)
# algorithm.set(KKT_TOLERANCE, 1e-8 )

print('solving')

algorithm.solve()

print('solved')
# algorithm.get_all_differential_states('car_ws_stats.txt')
