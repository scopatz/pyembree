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

includes: List[str] = [
    np.get_include(),
]

libs: List[str] = [
    "embree",
    "tbb",
    "tbbmalloc",
]

if os.name == "nt":
    root = "C:/Program Files/Intel/Embree v2.17.7 x64"
    cwd = os.path.abspath(os.path.expanduser(os.path.dirname(__file__)))
    ext = ".dll"
else:
    root = "/opt/local"
    cwd = os.path.expanduser("~")
    ext = ".so"

if os.path.exists(root):
    # header files
    shutil.copytree(
        os.path.join(root, "include/embree2"),
        os.path.join(cwd, "pyembree/embree2"),
        dirs_exist_ok=True,
    )

    # static libraries
    shutil.copytree(
        os.path.join(root, "lib"),
        os.path.join(cwd, "pyembree/embree2/lib"),
        dirs_exist_ok=True,
    )

    # dynamic libraries
    for lib in libs:
        shutil.copy(
            os.path.join(root, "bin", lib + ext),
            os.path.join(cwd, "pyembree"),
        )


includes.extend(os.path.join(cwd, "pyembree/embree2"))

static_libdirs: List[str] = [os.path.join(cwd, "pyembree/embree2/lib")]


def build(setup_kwargs: Dict[str, Any]) -> None:
    ext_modules: List[Extension] = cythonize(
        module_list="pyembree/*.pyx",
        language_level=3,
        include_path=includes,
    )

    for ext in ext_modules:
        ext.include_dirs = includes
        ext.libraries = libs
        ext.library_dirs = static_libdirs

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
