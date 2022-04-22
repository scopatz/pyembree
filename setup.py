import os
from importlib import metadata
from typing import Any, Dict, List

import numpy as np

# setuptools must be imported before cython. setuptools overrides the
# distutils.extension.Extension class. If imported after, the isinstance check in
# distutils.command.check_extensions_list fails and setuptools gives the erroneous
# error:
#
# "error: each element of 'ext_modules' option must be an Extension instance or 2-tuple"
#
# ref: https://github.com/cython/cython/issues/4724
from setuptools import find_packages, setup  # isort: skip
from setuptools.command.build_ext import build_ext  # isort: skip
from setuptools.extension import Extension  # isort: skip
from Cython.Build import cythonize  # isort: skip

package_name = "pyembree"
cwd = os.path.dirname(__file__)
version_file = os.path.join(cwd, package_name, "_version.py")

with open(version_file, mode="r") as fd:
    exec(fd.read())

if os.name == "nt":
    root = "C:/Program Files/Intel/Embree v2.17.7 x64/include"
else:
    root = "/opt/local"

include = [
    np.get_include(),
    os.path.join(root, "include"),
    os.path.join(cwd, package_name, "embree", "include"),
]
library = [
    os.path.join(root, "lib"),
    os.path.join(root, "bin"),
    os.path.join(cwd, package_name, "embree", "lib"),
    os.path.join(cwd, package_name, "embree", "bin"),
]

ext_modules: List[Extension] = cythonize(
    module_list="pyembree/*.pyx",
    language_level=3,
    include_path=include,
)

for ext in ext_modules:
    ext.include_dirs = include
    ext.library_dirs = library
    ext.libraries = [
        "embree",
        "tbb",
        "tbbmalloc",
    ]

packages = ["pyembree"]

package_data = {
    "": ["*"],
    "pyembree": [
        "embree/bin/*",
        "embree/include/*",
        "embree/lib/*",
    ],
}

with open("README.rst") as file_:
    readme = file_.read()

install_requires = [
    "Cython>=0.29.28,<0.30.0",
    "Rtree>=1.0.0,<2.0.0",
    "numpy>=1.22.2,<2.0.0",
    "setuptools>=60.9.3,<61.0.0",
    "trimesh>=3.10.7,<4.0.0",
    "wheel>=0.37.1,<0.38.0",
]

setup_kwargs = {
    "name": "pyembree",
    "version": __version__,
    "description": "Python wrapper for Intel Embree 2.17.7",
    "long_description": readme,
    "author": "Anthony Scopatz",
    "author_email": "scopatz@gmail.com",
    "maintainer": "Adam Hendry",
    "maintainer_email": "adam.grant.hendry@gmail.com",
    "url": "https://github.com/adam-grant-hendry/pyembree",
    "ext_modules": ext_modules,
    "cmdclass": {"build_ext": build_ext},
    "zip_safe": False,
    "packages": find_packages(),
    "packages": packages,
    "package_data": package_data,
    "install_requires": install_requires,
    "python_requires": ">=3.8,<3.9",
    "classifiers": [
        "License :: OSI Approved :: BSD License",
        "Operating System :: POSIX :: Linux",
        "Operating System :: MacOS :: MacOS X",
        "Operating System :: Microsoft :: Windows :: Windows 10",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
    ],
}

setup(**setup_kwargs)
