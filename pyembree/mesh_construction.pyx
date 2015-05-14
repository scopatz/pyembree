cimport numpy as np
cimport rtcore as rtc 
cimport rtcore_ray as rtcr
cimport rtcore_scene as rtcs
cimport rtcore_geometry as rtcg
cimport rtcore_geometry_user as rtcgu
from rtcore cimport Vertex, Triangle, Vec3f
from libc.stdlib cimport malloc, free

cdef class TriangleMesh:
    cdef Vertex* vertices
    cdef Triangle* indices
    cdef unsigned int mesh

    def __init__(self, rtcs.EmbreeScene scene, np.ndarray vertices, np.ndarray indices = None):
        if indices is None:
            self._build_from_flat(scene, vertices)
        else:
            self._build_from_indices(scene, vertices, indices)

    cdef void _build_from_flat(self, rtcs.EmbreeScene scene, np.ndarray tri_vertices):
        cdef int i, j
        cdef int nt = tri_vertices.shape[0]
        # In this scheme, we don't share any vertices.  This leads to cracks,
        # but also means we have exactly three times as many vertices as
        # triangles.
        cdef unsigned int mesh = rtcg.rtcNewTriangleMesh(scene.scene_i,
                    rtcg.RTC_GEOMETRY_STATIC, nt, nt*3, 1) 
        
        cdef Vertex* vertices = <Vertex*> rtcg.rtcMapBuffer(scene.scene_i, mesh,
                        rtcg.RTC_VERTEX_BUFFER)

        for i in range(nt):
            for j in range(3):
                vertices[i*3 + j].x = tri_vertices[i,j,0]
                vertices[i*3 + j].y = tri_vertices[i,j,0]
                vertices[i*3 + j].z = tri_vertices[i,j,0]
        rtcg.rtcUnmapBuffer(scene.scene_i, mesh, rtcg.RTC_VERTEX_BUFFER)

        cdef Triangle* triangles = <Triangle*> rtcg.rtcMapBuffer(scene.scene_i,
                        mesh, rtcg.RTC_INDEX_BUFFER)
        for i in range(nt):
            triangles[i].v0 = i*3 + 0
            triangles[i].v1 = i*3 + 1
            triangles[i].v2 = i*3 + 2

        rtcg.rtcUnmapBuffer(scene.scene_i, mesh, rtcg.RTC_INDEX_BUFFER)
        self.vertices = vertices
        self.indices = triangles
        self.mesh = mesh

    cdef void _build_from_indices(self, rtcs.EmbreeScene scene,
                                  np.ndarray tri_vertices,
                                  np.ndarray tri_indices):
        pass

cdef class ElementMesh(TriangleMesh):
    # This takes
    def __init__(self, np.ndarray vertices, np.ndarray indices):
        cdef int nv = vertices.shape[0]
        cdef int nt = indices.shape[0]
        # We need now to figure out if we've been handed quads or tetrahedra.
        # If it's quads, we can build the mesh slightly differently.
        # http://stackoverflow.com/questions/23723993/converting-quadriladerals-in-an-obj-file-into-triangles
        if indices.shape[1] == 8:
            self._build_from_quads(vertices, indices)
        elif indices.shape[1] == 4:
            self._build_from_triangles(vertices, indices)
        else:
            raise NotImplementedError

    cdef void _build_from_quads(self, np.ndarray vertices, np.ndarray indices):
        # There are six faces for every quad.  Each of those will be divided
        # into two triangles.
        pass

    cdef void _build_from_triangles(self, np.ndarray vertices, np.ndarray indices):
        pass
