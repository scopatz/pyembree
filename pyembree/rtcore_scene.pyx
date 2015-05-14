cimport cython
cimport numpy as np
cimport rtcore as rtc
cimport rtcore_ray as rtcr
cimport rtcore_geometry as rtcg

cdef class EmbreeScene:

    def __init__(self):
        self.scene_i = rtcNewScene(RTC_SCENE_STATIC, RTC_INTERSECT1)

    def run(self, np.ndarray[np.float64_t, ndim=2] vec_origins,
                  np.ndarray[np.float64_t, ndim=2] vec_directions):
        cdef int nv = vec_origins.shape[0]
        cdef int vo_i, vd_i, vd_step
        cdef np.ndarray[np.int32_t, ndim=1] intersect_ids
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
            ray.tfar = 1e38
            ray.geomID = rtcg.RTC_INVALID_GEOMETRY_ID
            ray.primID = rtcg.RTC_INVALID_GEOMETRY_ID
            ray.mask = -1
            ray.time = 0
            vd_i += vd_step

            rtcIntersect(self.scene_i, ray)
            intersect_ids[i] = ray.geomID

        return intersect_ids

    def __dealloc__(self):
        rtcDeleteScene(self.scene_i)
