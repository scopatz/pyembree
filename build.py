import os
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

cwd = os.path.dirname(__file__)
package_dir = os.path.join(cwd, "pyembree")
dependencies_dir = os.path.join(cwd, "embree")

version_file = os.path.join(package_dir, "_version.py")

with open(version_file, mode="r") as fd:
    exec(fd.read())

include = [
    np.get_include(),
    os.path.join(dependencies_dir, "include", "embree2"),
]
library = [
    os.path.join(dependencies_dir, "lib"),
    os.path.join(dependencies_dir, "bin"),
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

with open("README.rst") as file_:
    readme = file_.read()


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
            "version": __version__,
            "ext_modules": ext_modules,
            "cmdclass": {"build_ext": build_ext},
            "zip_safe": False,
            "packages": find_packages(),
        }
    )
