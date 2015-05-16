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

    def __init__(self, rtcs.EmbreeScene scene, 
                 np.ndarray vertices, 
                 np.ndarray indices = None):
        '''

        Constructs a triangular element mesh from a set of vertices and
        adds them to the scene. There are two different ways of 
        constructing the mesh:
        
        If "indices" is None, then "vertices" should be a num_triangles 
        by 3 by 3 array of floats, constructed so that (for example) 
        vertices[2][1][0] gives you the x-component of the 2nd vertex of 
        the 3rd triangle. In general, vertices may be duplicated when 
        constructing the mesh in this fashion. 
        
        Alternatively, you can also pass in an "indices" array. In that case,
        "indices" should be a num_triangles by 3 array of ints, and "vertices" 
        should be a num_vertices by 3 array of floats. These arrays should be 
        constructed so that indices[2][0] returns the index in "vertices" of 
        the first vertex of the third triangle, while vertices[4][1] returns
        the y-coordinate of the 5th vertex. Vertices can be shared when 
        constructing the mesh in this fashion, so that num_vertices can be 
        less than 3 times the number of triangles. 
        
        '''

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
                vertices[i*3 + j].y = tri_vertices[i,j,1]
                vertices[i*3 + j].z = tri_vertices[i,j,2]
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
        cdef int i
        cdef int nv = tri_vertices.shape[0]
        cdef int nt = tri_indices.shape[0]

        cdef unsigned int mesh = rtcg.rtcNewTriangleMesh(scene.scene_i,
                    rtcg.RTC_GEOMETRY_STATIC, nt, nv, 1) 
        
        cdef Vertex* vertices = <Vertex*> rtcg.rtcMapBuffer(scene.scene_i, mesh,
                        rtcg.RTC_VERTEX_BUFFER)

        for i in range(nv):
                vertices[i].x = tri_vertices[i, 0]
                vertices[i].y = tri_vertices[i, 1]
                vertices[i].z = tri_vertices[i, 2]
        rtcg.rtcUnmapBuffer(scene.scene_i, mesh, rtcg.RTC_VERTEX_BUFFER)

        cdef Triangle* triangles = <Triangle*> rtcg.rtcMapBuffer(scene.scene_i,
                        mesh, rtcg.RTC_INDEX_BUFFER)
        for i in range(nt):
            triangles[i].v0 = tri_indices[i][0]
            triangles[i].v1 = tri_indices[i][1]
            triangles[i].v2 = tri_indices[i][2]

        rtcg.rtcUnmapBuffer(scene.scene_i, mesh, rtcg.RTC_INDEX_BUFFER)
        self.vertices = vertices
        self.indices = triangles
        self.mesh = mesh

cdef class ElementMesh(TriangleMesh):
    # This takes
    def __init__(self, rtcs.EmbreeScene scene,
                 np.ndarray vertices, 
                 np.ndarray indices):
        # We need now to figure out if we've been handed quads or tetrahedra.
        # If it's quads, we can build the mesh slightly differently.
        # http://stackoverflow.com/questions/23723993/converting-quadriladerals-in-an-obj-file-into-triangles
        if indices.shape[1] == 8:
            self._build_from_quads(scene, vertices, indices)
        elif indices.shape[1] == 4:
            self._build_from_triangles(scene, vertices, indices)
        else:
            raise NotImplementedError

    cdef void _build_from_quads(self, rtcs.EmbreeScene scene,
                                np.ndarray quad_vertices, 
                                np.ndarray quad_indices):

        cdef int i, j
        cdef int nv = quad_vertices.shape[0]
        cdef int ne = quad_indices.shape[0]

        # There are six faces for every quad.  Each of those will be divided
        # into two triangles.
        cdef int nt = 6*2*ne

        cdef unsigned int mesh = rtcg.rtcNewTriangleMesh(scene.scene_i,
                    rtcg.RTC_GEOMETRY_STATIC, nt, nv, 1) 
        
        cdef Vertex* vertices = <Vertex*> rtcg.rtcMapBuffer(scene.scene_i, mesh,
                        rtcg.RTC_VERTEX_BUFFER)

        for i in range(nv):
            vertices[i].x = quad_vertices[i, 0]
            vertices[i].y = quad_vertices[i, 1]
            vertices[i].z = quad_vertices[i, 2]
        rtcg.rtcUnmapBuffer(scene.scene_i, mesh, rtcg.RTC_VERTEX_BUFFER)

        cdef Triangle* triangles = <Triangle*> rtcg.rtcMapBuffer(scene.scene_i,
                        mesh, rtcg.RTC_INDEX_BUFFER)
        for i in range(ne):
            j = 12*i
            # go over all the faces here
            # face is 0 1 2 3
            # triangles are 0 1 2 and 0 2 3
            triangles[j].v0 = quad_indices[i][0]
            triangles[j].v1 = quad_indices[i][1]
            triangles[j].v2 = quad_indices[i][2]
            triangles[j+1].v0 = quad_indices[i][0]
            triangles[j+1].v1 = quad_indices[i][2]
            triangles[j+1].v2 = quad_indices[i][3]
            # face is 4 5 6 7
            # triangles are 4 5 6 and 4 6 7
            triangles[j+2].v0 = quad_indices[i][4]
            triangles[j+2].v1 = quad_indices[i][5]
            triangles[j+2].v2 = quad_indices[i][6]
            triangles[j+3].v0 = quad_indices[i][4]
            triangles[j+3].v1 = quad_indices[i][6]
            triangles[j+3].v2 = quad_indices[i][7]
            # face is 0 1 5 4
            # triangles are 0 1 5 and 0 5 4
            triangles[j+4].v0 = quad_indices[i][0]
            triangles[j+4].v1 = quad_indices[i][1]
            triangles[j+4].v2 = quad_indices[i][5]
            triangles[j+5].v0 = quad_indices[i][0]
            triangles[j+5].v1 = quad_indices[i][5]
            triangles[j+5].v2 = quad_indices[i][4]
            # face is 1 2 6 5
            # triangles are 1 2 6 and 1 6 5
            triangles[j+6].v0 = quad_indices[i][1]
            triangles[j+6].v1 = quad_indices[i][2]
            triangles[j+6].v2 = quad_indices[i][6]
            triangles[j+7].v0 = quad_indices[i][1]
            triangles[j+7].v1 = quad_indices[i][6]
            triangles[j+7].v2 = quad_indices[i][5]
            # face is 0 3 7 4
            # triangles are 0 3 7 and 0 7 4
            triangles[j+8].v0 = quad_indices[i][0]
            triangles[j+8].v1 = quad_indices[i][3]
            triangles[j+8].v2 = quad_indices[i][7]
            triangles[j+9].v0 = quad_indices[i][0]
            triangles[j+9].v1 = quad_indices[i][7]
            triangles[j+9].v2 = quad_indices[i][4]
            # face is 3 2 6 7
            # triangles are 3 2 6 and 3 6 7
            triangles[j+10].v0 = quad_indices[i][3]
            triangles[j+10].v1 = quad_indices[i][2]
            triangles[j+10].v2 = quad_indices[i][6]
            triangles[j+11].v0 = quad_indices[i][3]
            triangles[j+11].v1 = quad_indices[i][6]
            triangles[j+11].v2 = quad_indices[i][7]

        rtcg.rtcUnmapBuffer(scene.scene_i, mesh, rtcg.RTC_INDEX_BUFFER)
        self.vertices = vertices
        self.indices = triangles
        self.mesh = mesh

    cdef void _build_from_triangles(self, rtcs.EmbreeScene scene,
                                    np.ndarray tetra_vertices, 
                                    np.ndarray tetra_indices):

        cdef int i, j
        cdef int nv = tetra_vertices.shape[0]
        cdef int ne = tetra_indices.shape[0]

        # There are four triangle faces for each tetrahedron.
        cdef int nt = 4*ne

        cdef unsigned int mesh = rtcg.rtcNewTriangleMesh(scene.scene_i,
                    rtcg.RTC_GEOMETRY_STATIC, nt, nv, 1) 
        
        cdef Vertex* vertices = <Vertex*> rtcg.rtcMapBuffer(scene.scene_i, mesh,
                        rtcg.RTC_VERTEX_BUFFER)

        for i in range(nv):
                vertices[i].x = tetra_vertices[i, 0]
                vertices[i].y = tetra_vertices[i, 1]
                vertices[i].z = tetra_vertices[i, 2]
        rtcg.rtcUnmapBuffer(scene.scene_i, mesh, rtcg.RTC_VERTEX_BUFFER)

        cdef Triangle* triangles = <Triangle*> rtcg.rtcMapBuffer(scene.scene_i,
                        mesh, rtcg.RTC_INDEX_BUFFER)
        for i in range(ne):
            j = 4*i
            # the triangles are: 
            # 0 1 2 
            # 0 1 3
            # 0 2 3
            # 1 2 3
            triangles[j].v0 = tetra_indices[i][0]
            triangles[j].v1 = tetra_indices[i][1]
            triangles[j].v2 = tetra_indices[i][2]
            triangles[j+1].v0 = tetra_indices[i][0]
            triangles[j+1].v1 = tetra_indices[i][1]
            triangles[j+1].v2 = tetra_indices[i][3]
            triangles[j+2].v0 = tetra_indices[i][0]
            triangles[j+2].v1 = tetra_indices[i][2]
            triangles[j+2].v2 = tetra_indices[i][3]
            triangles[j+3].v0 = tetra_indices[i][1]
            triangles[j+3].v1 = tetra_indices[i][2]
            triangles[j+3].v2 = tetra_indices[i][3]

        rtcg.rtcUnmapBuffer(scene.scene_i, mesh, rtcg.RTC_INDEX_BUFFER)
        self.vertices = vertices
        self.indices = triangles
        self.mesh = mesh
