from .utils import BaseAcadoTestCase

from acadopy.api import Expression, DifferentialState

class VariableTypesTestCase(BaseAcadoTestCase):

    def test_expression_init(self):

        e = Expression()
        self.assertIsInstance(e, Expression)
        self.assertEqual(e.dim, 0)
        self.assertEqual(e.num_rows, 0)
        self.assertEqual(e.num_cols, 0)

        e = Expression("name", 3, 1)
        self.assertIsInstance(e, Expression)
        self.assertEqual(e.dim, 3)
        self.assertEqual(e.num_rows, 3)
        self.assertEqual(e.num_cols, 1)

        e = Expression(2)
        self.assertIsInstance(e, Expression)
        self.assertEqual(e.dim, 1)
        self.assertEqual(e.num_rows, 1)
        self.assertEqual(e.num_cols, 1)

    def test_expression_print(self):

        e = Expression("name", 1, 1)
        print(e)

    def test_expression_neg(self):

        e = Expression()

        result  = -e

    def test_expression_add(self):

        x = DifferentialState()

        y = x + 0.5

        self.assertIsInstance(y, Expression)
        self.assertEqual(y.dim, 1)
        self.assertEqual(y.num_rows, 1)
        self.assertEqual(y.num_cols, 1)
        self.assertFalse(y.is_variable)

        y = 0.5 + x

        self.assertIsInstance(y, Expression)

    def test_expression_division(self):

        x = DifferentialState()
        z = DifferentialState()

        y = (0.5 + x) / 2.0
        self.assertIsInstance(y, Expression)

        y = (0.5 + x) / (z - 0.2)
        self.assertIsInstance(y, Expression)

        y = x / z
        self.assertIsInstance(y, Expression)

    def test_expression_mult(self):

        x = DifferentialState()

        y = x * 0.5

        self.assertIsInstance(y, Expression)

        y = 0.5 * x

        self.assertIsInstance(y, Expression)
