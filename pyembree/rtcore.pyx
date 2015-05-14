cdef void print_error(RTCError code):
    if code == RTC_NO_ERROR:
        print "ERROR: No error"
    elif code == RTC_UNKNOWN_ERROR:
        print "ERROR: Unknown error"
    elif code == RTC_INVALID_ARGUMENT:
        print "ERROR: Invalid argument"
    elif code == RTC_INVALID_OPERATION:
        print "ERROR: Invalid operation"
    elif code == RTC_OUT_OF_MEMORY:
        print "ERROR: Out of memory"
    elif code == RTC_UNSUPPORTED_CPU:
        print "ERROR: Unsupported CPU"
    elif code == RTC_CANCELLED:
        print "ERROR: Cancelled"
    else:
        raise RuntimeError
