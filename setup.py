#!/usr/bin/env python
import os

from setuptools import setup, find_packages

from Cython.Build import cythonize
from numpy import get_include


def ext_modules():
    """
    Generate a list of extension modules for pyembree.
    """
    # the current working directory
    cwd = os.path.abspath(os.path.expanduser(
        os.path.dirname(__file__)))

    if os.name == 'nt':
        # embree search locations on windows
        includes = [get_include(),
                    'c:/Program Files/Intel/Embree2/include',
                    os.path.join(cwd, 'embree2', 'include')]
        libraries = [
            'c:/Program Files/Intel/Embree2/lib',
            os.path.join(cwd, 'embree2', 'lib')]
    else:
        # embree search locations on posix
        includes = [get_include(),
                    '/opt/local/include',
                    os.path.expanduser('~/embree2/include')]
        libraries = ['/opt/local/lib',
                     os.path.expanduser('~/embree2/lib')]

    ext_modules = cythonize('pyembree/*.pyx', include_path=includes, language_level=2)
    for ext in ext_modules:
        ext.include_dirs = includes
        ext.library_dirs = libraries
        ext.libraries = ["embree"]

    return ext_modules


# rest of setup is specified in `pyproject.toml`
setup(ext_modules=ext_modules())
