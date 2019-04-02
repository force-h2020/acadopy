# (C) Copyright 2019 Enthought, Inc., Austin, TX
# All rights reserved.

import os
import sys

CUR_DIR = os.path.abspath(os.path.dirname(__file__))
sys.path.append(os.path.join(CUR_DIR, os.pardir))

from acadopy import *

########################################
# Variables
########################################

# the differential states
s = DifferentialState()
v = DifferentialState()
m = DifferentialState() 

# The control input u
u = Control()

# The differential equation
f = DifferentialEquation()

t_start = 0.0
t_end = 10.0

########################################
# Define a differential equation
########################################

# An implementation of the model equations for the rocket
# !! The following should be evaluated a <<, giving a DifferentialEquation, then == which is still a DifferentialEquation
f << dot(s) == v
f << dot(v) == ((u - 0.2 * v * v) / m)
f << dot(m) == (-0.01 * u * u) 

########################################
# Define an optimal control problem
#######################################

ocp = OCP(t_start, t_end, 20 )
ocp.minimizeLagrangeTerm( u*u )

# Minimize T s.t. the model
ocp.subjectTo(f)
# The initial values for s, v and m
ocp.subjectTo(AT_START, s ==  0.0 )
ocp.subjectTo(AT_START, v ==  0.0 )
ocp.subjectTo(AT_START, m ==  1.0 )

# The terminal constratins for s and v
ocp.subjectTo(AT_END, s == 10.0 )
ocp.subjectTo(AT_END, v ==  0.0 )

# as well as the bounds on v, the control input u and the time horizon T
ocp.subjectTo(-0.01 <= v <=  1.3)
ocp.subjectTo( u*u  >= 1.0)

########################################
# Define an optimization problem and solve the OCP
######################################

algorithm = OptimizationAlgorithm(ocp)
algorithm.set(HESSIAN_APPROXIMATION, EXACT_HESSIAN )
algorithm.set(MAX_NUM_ITERATIONS, 20 )
algorithm.set(KKT_TOLERANCE, 1e-10 )

algorithm.solve()

