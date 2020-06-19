#!/usr/bin/env python

from setuptools import setup, find_packages

from Cython.Build import cythonize

include_path = ['/usr/include/embree2']
try:
    import numpy as np
    include_path.append(np.get_include())
except ImportError:
    print('no numpy, install may fail!')


ext_modules = cythonize('pyembree/*.pyx', language='c++',
                        include_path=include_path,
                        library_path=['/usr/lib'])
for ext in ext_modules:
    ext.include_dirs = include_path
    ext.libraries = ["embree"]

setup(
    name="pyembree",
    version='0.1.6',
    ext_modules=ext_modules,
    zip_safe=False,
    install_requires=['numpy', 'cython', 'setuptools'],
    packages=find_packages(),
    package_data={'pyembree': ['*.pxd']}
)
