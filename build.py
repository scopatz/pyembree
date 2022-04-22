import os
import shutil
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
from setuptools import find_packages  # isort: skip
from setuptools.command.build_ext import build_ext  # isort: skip
from setuptools.extension import Extension  # isort: skip
from Cython.Build import cythonize  # isort: skip

cwd = os.path.abspath(os.path.expanduser(os.path.dirname(__file__)))

include = [
    np.get_include(),
    "/opt/local/include",
    os.path.expanduser("~/embree/include"),
]
library = [
    "/opt/local/lib",
    os.path.expanduser("~/embree/lib"),
    os.path.expanduser("~/embree/bin"),
]

if os.name == "nt":
    include = [
        np.get_include(),
        "C:/Program Files/Intel/Embree v2.17.7 x64/include",
        os.path.join(cwd, "embree"),
    ]
    library = [
        "C:/Program Files/Intel/Embree v2.17.7 x64/lib",
        os.path.join(cwd, "embree", "lib"),
        os.path.join(cwd, "embree", "bin"),
    ]

# include.extend(
#     np.get_include(),
# )


def build(setup_kwargs: Dict[str, Any]) -> None:
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

    setup_kwargs.update(
        {
            "name": "pyembree",
            "version": metadata.version("pyembree"),
            "ext_modules": ext_modules,
            "cmdclass": {"build_ext": build_ext},
            "zip_safe": False,
            "packages": find_packages(),
        }
    )
