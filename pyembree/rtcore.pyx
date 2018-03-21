import logging


log = logging.getLogger('pyembree')

cdef void print_error(RTCError code):
    if code == RTC_NO_ERROR:
        log.error("ERROR: No error")
    elif code == RTC_UNKNOWN_ERROR:
        log.error("ERROR: Unknown error")
    elif code == RTC_INVALID_ARGUMENT:
        log.error("ERROR: Invalid argument")
    elif code == RTC_INVALID_OPERATION:
        log.error("ERROR: Invalid operation")
    elif code == RTC_OUT_OF_MEMORY:
        log.error("ERROR: Out of memory")
    elif code == RTC_UNSUPPORTED_CPU:
        log.error("ERROR: Unsupported CPU")
    elif code == RTC_CANCELLED:
        log.error("ERROR: Cancelled")
    else:
        raise RuntimeError


cdef class EmbreeDevice:
    def __init__(self):
        self.device = rtcNewDevice(NULL)

    def __dealloc__(self):
        rtcDeleteDevice(self.device)

    def __repr__(self):
        return 'Embree version:  {0}.{1}.{2}'.format(RTCORE_VERSION_MAJOR,
                                                     RTCORE_VERSION_MINOR,
                                                     RTCORE_VERSION_PATCH)
