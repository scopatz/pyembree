from rtcore_ray cimport RTCRay

cdef enum:
    CALLBACK_TERMINATE = 0
    CALLBACK_CONTINUE = 1

cdef class RayCollisionCallback:
    # The function callback needs to return either CALLBACK_TERMINATE or
    # CALLBACK_CONTINUE.  CALLBACK_CONTINUE will keep it running, but
    # assumes that you have done something to the ray.  Otherwise it will
    # enter into an endless loop.
    cdef int callback(self, RTCRay &ray)

cdef class RayCollisionNull(RayCollisionCallback):
    pass
