#!/usr/bin/env python
import os

from numpy import get_include
from setuptools import find_packages, setup
from setuptools.extension import Extension
from Cython.Build import cythonize

# the current working directory
cwd = os.path.abspath(os.path.expanduser(
    os.path.dirname(__file__)))

include = [get_include(),
           '/opt/local/include',
           os.path.expanduser('~/embree4/include')]

library = ['/opt/local/lib',
           os.path.expanduser('~/embree4/lib')]

if os.name == 'nt':
    include = [
        'c:/Program Files/Intel/Embree4/include',
        os.path.join(cwd, 'embree4', 'include')]
    library = [
        'c:/Program Files/Intel/Embree4/lib',
        os.path.join(cwd, 'embree4', 'lib')]

extensions = [
    Extension(
        'pyembree',
        sources = ['pyembree/*.pyx'],
        libraries=['embree4'],
        language="c++",
        include_dirs=include,
        library_dirs=library
    )
]
 
ext_modules = cythonize('pyembree/*.pyx',
                        include_path=include)
for ext in ext_modules:
    ext.include_dirs = include
    ext.libraries = ["embree"]


with open(os.path.join(cwd, 'README.md'), 'r') as f:
    long_description = f.read()
__version__ = '0.0.1'


    
setup(
    name="pyembree",
    version=__version__,
    ext_modules=ext_modules,
    zip_safe=False,
    packages=find_packages(),
    package_data = {'pyembree': ['*.pxd']}
)
