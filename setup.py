# Requires MACOSX_DEPLOYMENT_TARGET=10.9
from setuptools import setup, Extension
from Cython.Build import cythonize

cython_ext = Extension(
    name='acadopy.api',
    sources=['acadopy/bindings.pyx'],
    libraries=['acado_toolkit_s'],
    language='c++',
    include_dirs=[
        '/usr/local/include/',
        '/usr/local/include/acado',
        '/usr/local/include/acado/external_packages/eigen3'
    ],
    library_dirs=[
        '/usr/local/lib'
    ],
)

setup(
    name='acadopy',
    packages=['acadopy'],
    license="BSD",
    version=0.1,
    setup_requires=['cython>=0.29.6'],
    ext_modules=cythonize([cython_ext]),
    zip_safe=False,
)
