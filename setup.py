# -*- coding: utf-8 -*-
from setuptools import setup

packages = \
['pyembree']

package_data = \
{'': ['*'], 'pyembree': ['embree2/bin/*', 'embree2/include/*', 'embree2/lib/*']}

install_requires = \
['Cython>=0.29.28,<0.30.0',
 'Rtree>=1.0.0,<2.0.0',
 'numpy>=1.22.2,<2.0.0',
 'setuptools>=60.9.3,<61.0.0',
 'trimesh>=3.10.7,<4.0.0',
 'wheel>=0.37.1,<0.38.0']

setup_kwargs = {
    'name': 'pyembree',
    'version': '0.2.0',
    'description': 'Python wrapper for Intel Embree 2.17.7',
    'long_description': "========\npyembree\n========\nPython Wrapper for Embree\n\nInstallation\n------------\nYou can install pyembree (and embree) via the conda-forge package.\n\n.. code-block:: bash\n\n    $ conda install -c conda-forge pyembree\n\n\n\nSuppressing errors\n------------------\n\nCreating multiple scenes produces some harmless error messages:\n::\n    ERROR CAUGHT IN EMBREE\n    ERROR: Invalid operation\n    ERROR MESSAGE: b'already initialized'\n\nThese can be suppressed with:\n\n.. code-block:: python\n\n    import logging\n    logging.getLogger('pyembree').disabled = True\n",
    'author': 'Anthony Scopatz',
    'author_email': 'scopatz@gmail.com',
    'maintainer': None,
    'maintainer_email': None,
    'url': 'https://github.com/adam-grant-hendry/pyembree',
    'packages': packages,
    'package_data': package_data,
    'install_requires': install_requires,
    'python_requires': '>=3.8,<3.9',
}
from build import *
build(setup_kwargs)

setup(**setup_kwargs)
