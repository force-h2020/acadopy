""" Port of examples/getting_started/simple_function.cpp to Python. """

from acadopy import *

def simple_example1():
    x = DifferentialState()
    z = IntermediateState()
    t =TIME() 
    f = Function()

    # Expression composition works
    z = 0.5 * x + 1.0

    f << exp(x) + t 
    f << exp(z+exp(z)) 

    # I decided to use properties on the function in place of the old style "get"
    # methods
    print("the dimension of f is {:d}".format(f.dim))
    print("f depends on  {:d}  states".format(f.nx))
    print("f depends on  {:d}  controls".format(f.nu))

    if f.isConvex():
        print("all components of function f are convex")

def simple_example2():

    A = DMatrix(3,3)
    b = DVector(3)
    x = DifferentialState("", 3, 1)
    f = Function()

    A.set_zero()
    A[0, 0] = 1.0
    A[1, 1] = 2.0
    A[2, 2] = 3.0

    b[0] = 1.0
    b[1] = 1.0
    b[2] = 1.0

    f << A * x + b

    x0 = DVector(3)
    dummy = DVector(3)

    x0.set_all(1.0)
    dummy.set_zero()

if __name__ == '__main__':
    simple_example1()
    simple_example2()
