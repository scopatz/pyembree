embreeX
========

A fork of [scopatz/pyembree](https://github.com/scopatz/pyembree) that is configured to
build wheels for Intel Mac, Windows, and Linux for Python 3.6 and newer. The name change
is to avoid confusion with the other forks and install methods available. 

The goal is to meet the upstream `trimesh[easy]` preferences for dependencies,
which are: "`easy` requirements should install without compiling anything on
Windows/Linux/Intel Mac for Python 3.6+ and have minimal dependencies."



## Install

The main goal of this fork is to provide wheels for the original project:
```
# will install an embree binding with only numpy as a dependency
pip install embreex
```

## Alternatives

The original project is [available on conda-forge](https://anaconda.org/conda-forge/pyembree/files) for many versons of Python. For wheel-based options currently on PyPi there are:
- https://pypi.org/project/pyembree/
  - https://github.com/adam-grant-hendry/pyembree
  - Currently set up with cibuildwheel as of writing with released wheels for Mac/Windows/Linux on Python 3.8
- https://pypi.org/project/embree/
  - A re-write to simplify the binding.
  - Wheels building.
