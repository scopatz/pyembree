cimport cython
cimport numpy as np
import numpy as np
import logging
import numbers
cimport rtcore as rtc
cimport rtcore_ray as rtcr
cimport rtcore_geometry as rtcg


log = logging.getLogger('pyembree')

cdef void error_printer(const rtc.RTCError code, const char *_str):
    """
    error_printer function depends on embree version
    Embree 2.14.1
    -> cdef void error_printer(const rtc.RTCError code, const char *_str):
    Embree 2.17.1
    -> cdef void error_printer(void* userPtr, const rtc.RTCError code, const char *_str):
    """
    log.error("ERROR CAUGHT IN EMBREE")
    rtc.print_error(code)
    log.error("ERROR MESSAGE: %s" % _str)


cdef class EmbreeScene:
    def __init__(self, rtc.EmbreeDevice device=None, robust=False):
        if device is None:
            # We store the embree device inside EmbreeScene to avoid premature deletion
            self.device = rtc.EmbreeDevice()
            device = self.device
        flags = RTC_SCENE_STATIC
        if robust:
            # bitwise-or the robust flag
            flags |= RTC_SCENE_ROBUST
        rtc.rtcDeviceSetErrorFunction(device.device, error_printer)
        self.scene_i = rtcDeviceNewScene(device.device, flags, RTC_INTERSECT1)
        self.is_committed = 0

    def run(self, np.ndarray[np.float32_t, ndim=2] vec_origins,
                  np.ndarray[np.float32_t, ndim=2] vec_directions,
                  dists=None,query='INTERSECT',output=None):

        if self.is_committed == 0:
            rtcCommit(self.scene_i)
            self.is_committed = 1

        cdef int nv = vec_origins.shape[0]
        cdef int vo_i, vd_i, vd_step
        cdef np.ndarray[np.int32_t, ndim=1] intersect_ids
        cdef np.ndarray[np.float32_t, ndim=1] tfars
        cdef rayQueryType query_type

        if query == 'INTERSECT':
            query_type = intersect
        elif query == 'OCCLUDED':
            query_type = occluded
        elif query == 'DISTANCE':
            query_type = distance

        else:
            raise ValueError("Embree ray query type %s not recognized." 
                "\nAccepted types are (INTERSECT,OCCLUDED,DISTANCE)" % (query))

        if dists is None:
            tfars = np.empty(nv, 'float32')
            tfars.fill(1e37)
        elif isinstance(dists, numbers.Number):
            tfars = np.empty(nv, 'float32')
            tfars.fill(dists)
        else:
            tfars = dists

        if output:
            u = np.empty(nv, dtype="float32")
            v = np.empty(nv, dtype="float32")
            Ng = np.empty((nv, 3), dtype="float32")
            primID = np.empty(nv, dtype="int32")
            geomID = np.empty(nv, dtype="int32")
        else:
            intersect_ids = np.empty(nv, dtype="int32")

        cdef rtcr.RTCRay ray
        vd_i = 0
        vd_step = 1
        # If vec_directions is 1 long, we won't be updating it.
        if vec_directions.shape[0] == 1: vd_step = 0

        for i in range(nv):
            for j in range(3):
                ray.org[j] = vec_origins[i, j]
                ray.dir[j] = vec_directions[vd_i, j]
            ray.tnear = 0.0
            ray.tfar = tfars[i]
            ray.geomID = rtcg.RTC_INVALID_GEOMETRY_ID
            ray.primID = rtcg.RTC_INVALID_GEOMETRY_ID
            ray.instID = rtcg.RTC_INVALID_GEOMETRY_ID
            ray.mask = -1
            ray.time = 0
            vd_i += vd_step

            if query_type == intersect or query_type == distance:
                rtcIntersect(self.scene_i, ray)
                if not output:
                    if query_type == intersect:
                        intersect_ids[i] = ray.primID
                    else:
                        tfars[i] = ray.tfar
                else:
                    primID[i] = ray.primID
                    geomID[i] = ray.geomID
                    u[i] = ray.u
                    v[i] = ray.v
                    tfars[i] = ray.tfar
                    for j in range(3):
                        Ng[i, j] = ray.Ng[j]
            else:
                rtcOccluded(self.scene_i, ray)
                intersect_ids[i] = ray.geomID

        if output:
            return {'u':u, 'v':v, 'Ng': Ng, 'tfar': tfars, 'primID': primID, 'geomID': geomID}
        else:
            if query_type == distance:
                return tfars
            else:
                return intersect_ids

    def __dealloc__(self):
        rtcDeleteScene(self.scene_i)
