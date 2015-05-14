# rtcore.pxd wrapper

cimport cython
cimport numpy as np

cdef extern from "embree2/rtcore.h":
    void rtcInit(const char* cfg)
    void rtcExit()

    cdef enum RTCError:
        RTC_NO_ERROR 
        RTC_UNKNOWN_ERROR 
        RTC_INVALID_ARGUMENT 
        RTC_INVALID_OPERATION 
        RTC_OUT_OF_MEMORY 
        RTC_UNSUPPORTED_CPU 
        RTC_CANCELLED 

    RTCError rtcGetError()
    ctypedef void (*RTCErrorFunc)(const RTCError code, const char* _str)
    void rtcSetErrorFunction(RTCErrorFunc func)

    ctypedef bint RTCMemoryMonitorFunc(const ssize_t _bytes, const bint post)
    void rtcSetMemoryMonitorFunction(RTCMemoryMonitorFunc func)

cdef extern from "embree2/rtcore_ray.h":
    pass

cdef struct Vertex:
    float x, y, z, r

cdef struct Triangle:
    int v0, v1, v2

cdef struct Vec3f:
    float x, y, z

cdef void print_error(RTCError code)
