#from distutils.core import setup
from setuptools import setup, find_packages
from distutils.extension import Extension

import numpy as np
from Cython.Build import cythonize


include_path = [np.get_include()]

extensions = [
    Extension("primes", ["primes.pyx"],
        include_dirs = [...],
        libraries = [...],
        library_dirs = [...]),
]

setup(
    name="pyembree",
    ext_modules=cythonize(extensions),
    packages=find_packages(),
)