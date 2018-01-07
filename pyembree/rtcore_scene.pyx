cimport cython
cimport numpy as np
import numpy as np
import logging
cimport rtcore as rtc
cimport rtcore_ray as rtcr
cimport rtcore_geometry as rtcg


log = logging.getLogger('pyembree')

cdef void error_printer(const rtc.RTCError code, const char *_str):
    log.error("ERROR CAUGHT IN EMBREE")
    rtc.print_error(code)
    log.error("ERROR MESSAGE: %s" % _str)

cdef class EmbreeScene:

    def __init__(self):
        rtc.rtcInit(NULL)
        rtc.rtcSetErrorFunction(error_printer)
        self.scene_i = rtcNewScene(RTC_SCENE_STATIC, RTC_INTERSECT1)

                  dists=None,query='INTERSECT'):
    def run(self, np.ndarray[np.float32_t, ndim=2] vec_origins,
                  np.ndarray[np.float32_t, ndim=2] vec_directions,
        cdef int nv = vec_origins.shape[0]
        cdef int vo_i, vd_i, vd_step
        cdef np.ndarray[np.int32_t, ndim=1] intersect_ids
        cdef np.ndarray[np.float32_t, ndim=1] tfars
        cdef rayQueryType query_type
        
        if query == 'INTERSECT':
            query_type = intersect
        elif query == 'OCCLUDED':
            query_type = occluded
        else:
            raise ValueError("Embree ray query type %s not recognized" % (query))
        
        if dists is None:
            tfars = np.empty(nv, 'float32')
            tfars.fill(1e37)
        else:
            tfars = dists
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
            #ray.tfar = 1e37
            ray.tfar = tfars[i]
            ray.geomID = rtcg.RTC_INVALID_GEOMETRY_ID
            ray.primID = rtcg.RTC_INVALID_GEOMETRY_ID
            ray.instID = rtcg.RTC_INVALID_GEOMETRY_ID
            ray.mask = -1
            ray.time = 0
            vd_i += vd_step

            if query_type == intersect:
                rtcIntersect(self.scene_i, ray)
                intersect_ids[i] = ray.primID
            else:
                rtcOccluded(self.scene_i, ray)
                intersect_ids[i] = ray.geomID

        return intersect_ids

    def __dealloc__(self):
        rtcDeleteScene(self.scene_i)
