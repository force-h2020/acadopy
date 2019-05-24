# (C) Copyright 2019 Enthought, Inc., Austin, TX
# All rights reserved.

""" Python implementation of the ACADO example
`examples/multi_objective/car_ws.cpp`.

From https://www.sciencedirect.com/science/article/pii/S1474667016402028:

Problem of transferring a car from an initial position to a
specified target in minimum time, and with a minimum
control effort is considered.

The aim is to drive 200 meters while minimizing the control effort
for accelerating and the traveling time. These are obviously
conflicting objectives since a small travelling time requires a
high speed, and, hence, also a large consumption of fuel for reaching
this velocity. Since infinitely fast accelerating and decelerating
is impossible, the control is bounded between -5 m/s2 and 5 m/s2.

We also constraint the time to 50s and a maximum speed of 40 m/s

"""

import os
import sys

from acadopy.api import *

x1 = DifferentialState() # x1 is the position of the car [m]
x2 = DifferentialState() # x2 is the velocity [m/s]
t1 = Parameter() # t is it the independant variable in the ODE
u = Control() # u is the acceleration [m/s2]

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

ocp.subjectTo(0.0 <= x1 <= 200.0001)
ocp.subjectTo(0.0 <= x2 <= 40.0)
ocp.subjectTo(0.0 <= u <= 5.0)
ocp.subjectTo(0.1 <= t1 <= 50.0)

algorithm = MultiObjectiveAlgorithm(ocp)
algorithm.set(PARETO_FRONT_GENERATION, PFG_WEIGHTED_SUM)
algorithm.set(PARETO_FRONT_DISCRETIZATION, 11)
algorithm.set(KKT_TOLERANCE, 1.0e-8 )

algorithm.solve()

algorithm.get_all_differential_states('car_ws_stats.txt')
