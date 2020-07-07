from rtcore_ray cimport RTCRay

cdef enum:
    _CALLBACK_TERMINATE = 0
    _CALLBACK_CONTINUE = 1

cdef class RayCollisionCallback:
    # The function callback needs to return either _CALLBACK_TERMINATE or
    # _CALLBACK_CONTINUE.  _CALLBACK_CONTINUE will keep it running, but
    # assumes that you have done something to the ray.  Otherwise it will
    # enter into an endless loop.
    cdef int callback(self, RTCRay &ray)

cdef class RayCollisionNull(RayCollisionCallback):
    pass
