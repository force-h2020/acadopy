# (C) Copyright 2019 Enthought, Inc., Austin, TX
# All rights reserved.

""" Python implementation of the ACADO example
`examples/multi_objective/car_ws.cpp`.

"""

import os
import sys

from acadopy.api import *

x1 = DifferentialState()
x2 = DifferentialState()
t1 = Parameter()
u = Control()

f = DifferentialEquation(0.0, t1)

f << dot(x1) == x2
f << dot(x2) == u

ocp = OCP(0.0, t1, 25)

ocp.minimizeMayerTerm(0, x2)
ocp.minimizeMayerTerm(1, 2.0 * t1 / 20.0)
ocp.subjectTo(f)

ocp.subjectTo(AT_START, x1 == 0.0)
ocp.subjectTo(AT_START, x2 == 0.0)
ocp.subjectTo(AT_END, x1 == 200.0)

ocp.subjectTo(0.0 <= x1 <= 200.001)
ocp.subjectTo(0.0 <= x2 <= 40.0)
ocp.subjectTo(0.0 <= u <= 5.0)
ocp.subjectTo(0.0 <= t1 <= 50.0)

algorithm = MultiObjectiveAlgorithm(ocp)
algorithm.set(PARETO_FRONT_GENERATION, PFG_WEIGHTED_SUM)
algorithm.set(PARETO_FRONT_DISCRETIZATION, 11)
algorithm.set(KKT_TOLERANCE, 1e-8 )

algorithm.solve()

algorithm.get_all_differential_states('car_ws_stats.txt')
