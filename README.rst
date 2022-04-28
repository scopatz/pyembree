========
pyembree
========
Python Wrapper for Embree

Installation
------------
You can install pyembree (and embree) via ``pip``

.. code-block:: bash

    $ pip install pyembree

Suppressing Errors
------------------

Creating multiple scenes produces some harmless error messages:
::

    ERROR CAUGHT IN EMBREE
    ERROR: Invalid operation
    ERROR MESSAGE: b'already initialized'

These can be suppressed with:

.. code-block:: python

    import logging
    logging.getLogger('pyembree').disabled = True
