#!/usr/bin/env python
import os

from setuptools import setup, find_packages

from Cython.Build import cythonize
from numpy import get_include

# the current working directory
cwd = os.path.abspath(os.path.expanduser(
    os.path.dirname(__file__)))

if os.name == 'nt':
    includes = [get_include(),
                'c:/Program Files/Intel/Embree2/include',
                os.path.join(cwd, 'embree2', 'include')]
    libraries = [
        'c:/Program Files/Intel/Embree2/lib',
        os.path.join(cwd, 'embree2', 'lib')]
else:

    includes = [get_include(),
                '/opt/local/include',
                os.path.expanduser('~/embree2/include')]
    libraries = ['/opt/local/lib',
                 os.path.expanduser('~/embree2/lib')]

"""
extensions = [
    Extension(
        'embree.wrapper',
        sources = ['embree/wrapper.pyx'],
        libraries=['embree4'],
        include_dirs=include,
        library_dirs=library
    )
]
"""


ext_modules = cythonize('pyembree/*.pyx',
                        language='c++',
                        include_path=includes)

for ext in ext_modules:
    ext.include_dirs = includes
    ext.library_dirs = libraries
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
