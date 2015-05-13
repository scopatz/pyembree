# rtcore.pxd wrapper

from libc.stdint ssize_t
cimport cython
cimport numpy as np

cdef extern from "rtcore.h":
    void rtcInit(const char* cfg = ?)
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
    ctypedef void* RTCErrorFunc(const RTCError code, const char* _str)
    void rtcSetErrorFunction(RTCErrorFunc func)

    ctypedef bool RTCMemoryMonitorFunc(const ssize_t _bytes, const bool post)
    void rtcSetMemoryMonitorFunction(RTCMemoryMonitorFunc func)
