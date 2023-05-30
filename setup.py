#!/usr/bin/env python
import os

from setuptools import setup, find_packages

from Cython.Build import cythonize
import numpy as np

_cwd = os.path.abspath(os.path.expanduser(os.path.dirname(__file__)))

include_path = [np.get_include(),
                '/usr/include/embree2',
                os.path.join(_cwd, 'embree2', 'include'),
                os.path.join(os.path.expanduser('~/embree2'), 'include')]

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
    install_requires=["numpy"],
    zip_safe=False,
    packages=find_packages(),
    package_data={'pyembree': ['*.pxd']}
)
