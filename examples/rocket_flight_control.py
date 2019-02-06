import os
import sys

CUR_DIR = os.path.abspath(os.path.dirname(__file__))
sys.path.append(os.path.join(CUR_DIR, os.pardir))

from acadopy import *

# the differential states
s = DifferentialState()
v = DifferentialState()
m = DifferentialState() 

# The control input u
u = Control()

# The time horizon T
T = Parameter()

# The differential equation
f = DifferentialEquation( 0.0, T )

########################################
# Time horizon of the OCP:[0,T]
ocp = OCP( 0.0, T )
# The time T should be optimized
ocp.minimizeMayerTerm(T)

# An implementation of the model equations for the rocket
# !! The following should be evaluated a <<, giving a DifferentialEquation, then == which is still a DifferentialEquation
f << dot(s) == v
f << dot(v) == (u-0.2*v*v)/m
f << dot(m) == -0.01*u*u 

# Minimize T s.t. the model
ocp.subjectTo(f)
# The initial values for s, v and m
res = s == 0.0
ocp.subjectTo(AT_START, s ==  0.0 )
ocp.subjectTo(AT_START, v ==  0.0 )
ocp.subjectTo(AT_START, m ==  1.0 )

# The terminal constratins for s and v
ocp.subjectTo(AT_END, s == 10.0 )
ocp.subjectTo(AT_END, v ==  0.0 )

# as well as the bounds on v, the control input u and the time horizon T
ocp.subjectTo(-0.1 <= v <=  1.7)
ocp.subjectTo(-1.1 <= u <=  1.1)
ocp.subjectTo( 5.0 <= T <= 15.0)

# Construct optimization algorithm, and solve the problem
algorithm = OptimizationAlgorithm(ocp)
print("before solve")
algorithm.solve()

