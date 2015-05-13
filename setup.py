#!/usr/bin/env python

#from distutils.core import setup
from setuptools import setup, find_packages
from distutils.extension import Extension

import numpy as np
from Cython.Build import cythonize


include_path = [np.get_include()]

setup(
    name="pyembree",
    ext_modules=cythonize('pyembree/*.pyx'),
    packages=find_packages(),
    language='c++',
)