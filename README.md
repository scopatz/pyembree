pyembree
========

Python Wrapper for Embree

Installation
------------

You can install pyembree (and embree) via the conda-forge package.

``` {.bash}
$ conda install -c conda-forge pyembree
```

Suppressing errors
------------------

Creating multiple scenes produces some harmless error messages: :: ERROR
CAUGHT IN EMBREE ERROR: Invalid operation ERROR MESSAGE: b\'already
initialized\'

These can be suppressed with:

``` {.python}
import logging
logging.getLogger('pyembree').disabled = True
```
