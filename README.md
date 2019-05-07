# acadopy
Python bindings for the [acado.github.io](ACADO library), a toolkit for
automatic control and dynamic optimization.


## Installation
- Install ACADO for your system by following the instructions at
  http://acado.github.io/.
  * The `acadopy` package assumes that the header files get placed in
  `/usr/local/include/acado`, edit `setup.py` with the correct paths if this is
  not the case.
- Install the Python requirements found in `requirements.txt` with `pip` or otherwise.
  * `acadopy` requires GCC to be used, so you may need to
  set the environment variables `CC` and `CXX` accordingly.
- To install, run `python setup.py install` or `pip install .` from this directory.
- Tests can be run from the top level with `python setup.py test` or from the
  `tests/` directory with `unittest`/`pytest` (this will fail from the top-level
  as the compiled extension will not be found)
