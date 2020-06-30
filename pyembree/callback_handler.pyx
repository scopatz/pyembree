from rtcore_ray cimport RTCRay

cdef class RayCollisionCallback:
    cdef int callback(self, RTCRay &ray):
        return CALLBACK_TERMINATE
