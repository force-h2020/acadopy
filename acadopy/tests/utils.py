import faulthandler
import unittest

from acadopy.api import clear_static_counters

faulthandler.enable()


class BaseAcadoTestCase(unittest.TestCase):

    def setUp(self):
        # clear up the acado static counters to prevernt any
        # interactions between previous code executed and the 
        # test cases
        clear_static_counters()