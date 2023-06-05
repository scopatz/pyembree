#!/usr/bin/env python
import os
import sys

from setuptools import setup

from Cython.Build import cythonize
from numpy import get_include

# the current working directory
_cwd = os.path.abspath(os.path.expanduser(os.path.dirname(__file__)))


def ext_modules():
    """
    Generate a list of extension modules for embreex.
    """

    if os.name == 'nt':
        # embree search locations on windows
        includes = [get_include(),
                    'c:/Program Files/Intel/Embree2/include',
                    os.path.join(_cwd, 'embree2', 'include')]
        libraries = [
            'c:/Program Files/Intel/Embree2/lib',
            os.path.join(_cwd, 'embree2', 'lib')]
    else:
        # embree search locations on posix
        includes = [get_include(),
                    '/opt/local/include',
                    os.path.join(_cwd, 'embree2', 'include')]
        libraries = ['/opt/local/lib',
                     os.path.join(_cwd, 'embree2', 'lib')]

    ext_modules = cythonize(
        'embreex/*.pyx',
        include_path=includes,
        language_level=2)
    for ext in ext_modules:
        ext.include_dirs = includes
        ext.library_dirs = libraries
        ext.libraries = ["embree"]

    return ext_modules


def load_pyproject() -> dict:
    """
    A hack for Python 3.6 to load data from `pyproject.toml`

    The rest of setup is specified in `pyproject.toml` but moving dependencies
    to `pyproject.toml` requires setuptools>61 which is only available on Python>3.7
    When you drop Python 3.6 you can delete this function.
    """
    # this hack is only needed on Python 3.6 and older
    if sys.version_info >= (3, 7):
        return {}

    # store loaded values from the toml
    values = {}
    import json

    # load the toml data with naive string wangling
    with open(os.path.join(_cwd, 'pyproject.toml'), 'r') as f:
        for line in f:
            if '=' not in line:
                continue
            split = [i.strip() for i in line.strip().split('=')]
            if split[0] in ('name', 'version', 'dependencies'):
                values[split[0]] = json.loads(split[1])
    values['install_requires'] = values.pop('dependencies')

    return values


try:
    with open(os.path.join(_cwd, 'README.md'), 'r') as _f:
        long_description = _f.read()
except BaseException:
    long_description = ''

setup(ext_modules=ext_modules(),
      long_description=long_description,
      long_description_content_type='text/markdown',
      **load_pyproject())
