from importlib import metadata

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
from Cython.Build import cythonize  # isort: skip

include_path = [
    np.get_include(),
]

ext_modules = cythonize(
    module_list="pyembree/*.pyx",
    language_level=3,
    include_path=include_path,
)

for ext in ext_modules:
    ext.include_dirs = include_path
    ext.libraries = [
        "pyembree/embree2/lib/embree",
        "pyembree/embree2/lib/tbb",
        "pyembree/embree2/lib/tbbmalloc",
    ]

setup(
    name="pyembree",
    version=metadata.version("pyembree"),
    ext_modules=ext_modules,
    zip_safe=False,
    packages=find_packages(),
    include_package_data=True,
    package_data={"pyembree": ["*.dll"]},
)
