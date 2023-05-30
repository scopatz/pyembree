#!/usr/bin/env python

from setuptools import setup, find_packages

from Cython.Build import cythonize
import numpy as np

include_path = [np.get_include(), '/usr/include/embree2']

ext_modules = cythonize('pyembree/*.pyx',
                        language='c++',
                        include_path=include_path)
for ext in ext_modules:
    ext.include_dirs = include_path
    ext.libraries = ["embree"]

setup(
    name="pyembree",
    version='0.1.6',
    ext_modules=ext_modules,
    install_requires=['numpy'],
    zip_safe=False,
    install_requires=['numpy', 'cython', 'setuptools'],
    packages=find_packages(),
    package_data={'pyembree': ['*.pxd']}
)
