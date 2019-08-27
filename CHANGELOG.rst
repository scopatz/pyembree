===================
pyembree Change Log
===================

.. current developments

v0.1.6
====================

**Changed:**

* Multiple ``TriangleMesh`` objects can now be added to a scene, and the scene is committed only as-needed.

**Authors:**

* Anthony Scopatz
* Matthew Turk



v0.1.5
====================

**Added:**

* Calling EmbreeScene.run with query = 'DISTANCE' returns an array with the 
  distance to the nearest hit, or tfar (default of 1e37) if there is no hit.
* Set tfar to the same value for all points by passing a number to the dists argument in EmbreeScene.run



v0.1.4
====================



v0.1.3
====================

**Changed:**

* Error logging now uses the `logging` module




v0.1.2
====================

**Fixed:**

* setup.py and rever.xsh fix




v0.1.1
====================

**Changed:**

* Moved ``trianges`` module to ``triangles``.


**Fixed:**

* Fixed issue where ``RTC_GEOMETRY_STATIC`` was called ``RTCGEOMETRY_STATIC``.
* Fixed attenuate example.
* Fixed build for recent versions of Cython.




