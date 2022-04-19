# -*- coding: utf-8 -*-
from setuptools import setup

packages = \
['pyembree']

package_data = \
{'': ['*'], 'pyembree': ['embree2/*', 'embree2/lib/*']}

install_requires = \
['Cython>=0.29.28,<0.30.0',
 'Rtree>=1.0.0,<2.0.0',
 'numpy>=1.22.2,<2.0.0',
 'setuptools>=60.9.3,<61.0.0',
 'trimesh>=3.10.7,<4.0.0',
 'wheel>=0.37.1,<0.38.0']

setup_kwargs = {
    'name': 'pyembree',
    'version': '0.1.9',
    'description': 'Python wrapper for Intel Embree 2.17.7',
    'long_description': None,
    'author': 'Anthony Scopatz',
    'author_email': 'scopatz@gmail.com',
    'maintainer': None,
    'maintainer_email': None,
    'url': None,
    'packages': packages,
    'package_data': package_data,
    'install_requires': install_requires,
    'python_requires': '>=3.8,<4.0',
}
from build import *
build(setup_kwargs)

setup(**setup_kwargs)
