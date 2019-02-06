# Requires MACOSX_DEPLOYMENT_TARGET=10.9
from setuptools import setup, Extension
from Cython.Distutils import build_ext

import eigency

setup(
    name='acadopy',
    version=1.0,
    ext_modules=[
        Extension(
            name='acadopy',
            sources=['acadopy.pyx'],
            libraries=['acado_toolkit_s'],
            language='c++',
            include_dirs=[
                '/usr/local/include/acado/', 
                '/usr/local/include/acado/external_packages/eigen3/'
            ] + eigency.get_includes()
        )
    ],
    cmdclass={'build_ext': build_ext},
)
