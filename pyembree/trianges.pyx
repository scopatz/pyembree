cimport numpy as np
cimport rtcore as rtc 
cimport rtcore_ray as rtcr
cimport rtcore_scene as rtcs
cimport rtcore_geometry as rtcg
cimport rtcore_geometry_user as rtcgu
from rtcore cimport Vertex, Triangle, Vec3f
from libc.stdlib cimport malloc, free

ctypedef Vec3f (*renderPixelFunc)(float x, float y,
                const Vec3f &vx, const Vec3f &vy, const Vec3f &vz,
                const Vec3f &p)

def run_triangles():
    pass
    
cdef unsigned int addCube(rtcs.RTCScene scene_i):
    cdef unsigned int mesh = rtcg.rtcNewTriangleMesh(scene_i,
                rtcg.RTCGEOMETRY_STATIC, 12, 8, 1)
    cdef Vertex* vertices = <Vertex*> rtcg.rtcMapBuffer(scene_i, mesh, rtcg.RTC_VERTEX_BUFFER)
    vertices[0].x = -1
    vertices[0].y = -1
    vertices[0].z = -1
    
    vertices[1].x = -1
    vertices[1].y = -1
    vertices[1].z = +1
    
    vertices[2].x = -1
    vertices[2].y = +1
    vertices[2].z = -1
    
    vertices[3].x = -1
    vertices[3].y = +1
    vertices[3].z = +1
    
    vertices[4].x = +1
    vertices[4].y = -1
    vertices[4].z = -1
    
    vertices[5].x = +1
    vertices[5].y = -1
    vertices[5].z = +1
    
    vertices[6].x = +1
    vertices[6].y = +1
    vertices[6].z = -1
    
    vertices[7].x = +1
    vertices[7].y = +1
    vertices[7].z = +1
    
    rtcg.rtcUnmapBuffer(scene_i, mesh, rtcg.RTC_VERTEX_BUFFER)

    cdef Vec3f *colors = <Vec3f*> malloc(12*sizeof(Vec3f))

    cdef int tri = 0
    cdef Triangle* triangles = <Triangle*> rtcg.rtcMapBuffer(scene_i, mesh,
                rtcg.RTC_INDEX_BUFFER)

    # left side
    colors[tri].x = 1.0
    colors[tri].y = 0.0
    colors[tri].z = 0.0
    triangles[tri].v0 = 0
    triangles[tri].v1 = 2
    triangles[tri].v2 = 1
    tri += 1
    colors[tri].x = 1.0
    colors[tri].y = 0.0
    colors[tri].z = 0.0
    triangles[tri].v0 = 1
    triangles[tri].v1 = 2
    triangles[tri].v2 = 3
    tri += 1

    # right side
    colors[tri].x = 0.0
    colors[tri].y = 1.0
    colors[tri].z = 0.0
    triangles[tri].v0 = 4
    triangles[tri].v1 = 5
    triangles[tri].v2 = 6
    tri += 1
    colors[tri].x = 0.0
    colors[tri].y = 1.0
    colors[tri].z = 0.0
    triangles[tri].v0 = 5
    triangles[tri].v1 = 7
    triangles[tri].v2 = 6
    tri += 1

    # bottom side
    colors[tri].x = 0.5
    colors[tri].y = 0.5
    colors[tri].z = 0.5
    triangles[tri].v0 = 0
    triangles[tri].v1 = 1
    triangles[tri].v2 = 4
    tri += 1
    colors[tri].x = 0.5
    colors[tri].y = 0.5
    colors[tri].z = 0.5
    triangles[tri].v0 = 1
    triangles[tri].v1 = 5
    triangles[tri].v2 = 4
    tri += 1

    # top side
    colors[tri].x = 1.0
    colors[tri].y = 1.0
    colors[tri].z = 1.0
    triangles[tri].v0 = 2
    triangles[tri].v1 = 6
    triangles[tri].v2 = 3
    tri += 1
    colors[tri].x = 1.0
    colors[tri].y = 1.0
    colors[tri].z = 1.0
    triangles[tri].v0 = 3
    triangles[tri].v1 = 6
    triangles[tri].v2 = 7
    tri += 1

    # front side
    colors[tri].x = 0.0
    colors[tri].y = 0.0
    colors[tri].z = 1.0
    triangles[tri].v0 = 0
    triangles[tri].v1 = 4
    triangles[tri].v2 = 2
    tri += 1
    colors[tri].x = 0.0
    colors[tri].y = 0.0
    colors[tri].z = 1.0
    triangles[tri].v0 = 2
    triangles[tri].v1 = 4
    triangles[tri].v2 = 6
    tri += 1

    # back side
    colors[tri].x = 1.0
    colors[tri].y = 1.0
    colors[tri].z = 0.0
    triangles[tri].v0 = 1
    triangles[tri].v1 = 3
    triangles[tri].v2 = 5
    tri += 1
    colors[tri].x = 1.0
    colors[tri].y = 1.0
    colors[tri].z = 0.0
    triangles[tri].v0 = 3
    triangles[tri].v1 = 7
    triangles[tri].v2 = 5
    tri += 1

    rtcg.rtcUnmapBuffer(scene_i, mesh, rtcg.RTC_INDEX_BUFFER)

    return mesh
  
cdef unsigned int addGroundPlane (rtcs.RTCScene scene_i):
    cdef unsigned int mesh = rtcg.rtcNewTriangleMesh (scene_i,
            rtcg.RTC_GEOMETRY_STATIC, 2, 4, 1)

    cdef Vertex* vertices = <Vertex*> rtcg.rtcMapBuffer(scene_i, mesh, rtcg.RTC_VERTEX_BUFFER)
    vertices[0].x = -10
    vertices[0].y = -2
    vertices[0].z = -10
    
    vertices[1].x = -10
    vertices[1].y = -2
    vertices[1].z = +10
    
    vertices[2].x = +10
    vertices[2].y = -2
    vertices[2].z = -10
    
    vertices[3].x = +10
    vertices[3].y = -2
    vertices[3].z = +10
    rtcg.rtcUnmapBuffer(scene_i, mesh, rtcg.RTC_VERTEX_BUFFER)

    cdef Triangle* triangles = <Triangle*> rtcg.rtcMapBuffer(scene_i, mesh, rtcg.RTC_INDEX_BUFFER)
    triangles[0].v0 = 0
    triangles[0].v1 = 2
    triangles[0].v2 = 1
    triangles[1].v0 = 1
    triangles[1].v1 = 2
    triangles[1].v2 = 3
    rtcg.rtcUnmapBuffer(scene_i, mesh, rtcg.RTC_INDEX_BUFFER)

    return mesh
