from rtcore_ray cimport RTCRay

# This is to make them accessible from Python
CALLBACK_TERMINATE = _CALLBACK_TERMINATE
CALLBACK_CONTINUE = _CALLBACK_CONTINUE

cdef class RayCollisionCallback:
    cdef int callback(self, RTCRay &ray):
        return CALLBACK_TERMINATE

cdef class PythonCallback(RayCollisionCallback):
    # This class lets you specify a python function that can modify in situ the
    # rays that are arriving.  Changes will be reflected.
    cdef public object callback_function
    def __init__(self, callback_function):
        self.callback_function = callback_function

    cdef int callback(self, RTCRay &ray):
        ray_info = dict(
            org = (ray.org[0], ray.org[1], ray.org[2]),
            dir = (ray.dir[0], ray.dir[1], ray.dir[2]),
            tnear = ray.tnear,
            tfar = ray.tfar,
            time = ray.time,
            mask = ray.mask,
            Ng = (ray.Ng[0], ray.Ng[1], ray.Ng[2]),
            u = ray.u,
            v = ray.v,
            geomID = ray.geomID,
            primID = ray.primID,
            instID = ray.instID
        )
        rv = self.callback_function(ray_info)
        # We now update the ray contents from the dictionary
        for i in range(3):
            ray.org[i] = ray_info['org'][i]
            ray.dir[i] = ray_info['dir'][i]
            ray.Ng[i] = ray_info['Ng'][i]
        ray.tnear = ray_info['tnear']
        ray.tfar = ray_info['tfar']
        ray.mask = ray_info['mask']
        ray.u = ray_info['u']
        ray.v = ray_info['v']
        ray.geomID = ray_info['geomID']
        ray.primID = ray_info['primID']
        ray.instID = ray_info['instID']
        if rv == _CALLBACK_CONTINUE:
            return _CALLBACK_CONTINUE
        return _CALLBACK_TERMINATE
