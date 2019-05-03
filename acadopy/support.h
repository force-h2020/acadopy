// Cython does not support the operator() use on the lhs and thus forces us to
// define some support code ... This is not a good solution and ideally we
// would eigency and only expose numpy arrays to users

void matrix_assign(ACADO::DMatrix& d, unsigned int row, unsigned int col, double value) {
    d(row, col) = value;
}

void vector_assign(ACADO::DVector& v, unsigned int index, double value){
    v(index) = value;
}
