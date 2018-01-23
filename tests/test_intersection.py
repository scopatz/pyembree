from unittest import TestCase
import numpy as np
from pyembree import rtcore as rtc
from pyembree import rtcore_scene as rtcs
from pyembree.mesh_construction import TriangleMesh
from pyembree.mesh_construction import ElementMesh


def xplane(x):
    return [[[x, -1.0, -1.0],
             [x, +1.0, -1.0],
             [x, -1.0, +1.0]],
            [[x, +1.0, -1.0],
             [x, +1.0, +1.0],
             [x, -1.0, +1.0]]]


def xplane_only_points(x):
    # Indices are [[0, 1, 2], [1, 3, 2]]
    return [[x, -1.0, -1.0],
            [x, +1.0, -1.0],
            [x, -1.0, +1.0],
            [x, +1.0, +1.0]]


def define_rays_origins_and_directions():
    N = 4
    origins = np.zeros((N, 3), dtype='float32')
    origins[:,0] = 0.1
    origins[0,1] = -0.2
    origins[1,1] = +0.2
    origins[2,1] = +0.3
    origins[3,1] = -8.2

    dirs = np.zeros((N, 3), dtype='float32')
    dirs[:, 0] = 1.0
    return origins, dirs


class TestPyEmbree(TestCase):
    def test_pyembree_should_be_able_to_display_embree_version(self):
        embreeDevice = rtc.EmbreeDevice()
        print(embreeDevice)

    def test_pyembree_should_be_able_to_create_a_scene(self):
        embreeDevice = rtc.EmbreeDevice()
        scene = rtcs.EmbreeScene(embreeDevice)

    def test_pyembree_should_be_able_to_create_several_scenes(self):
        embreeDevice = rtc.EmbreeDevice()
        scene1 = rtcs.EmbreeScene(embreeDevice)
        scene2 = rtcs.EmbreeScene(embreeDevice)

    def test_pyembree_should_be_able_to_create_a_device_if_not_provided(self):
        scene = rtcs.EmbreeScene()

class TestIntersectionTriangles(TestCase):

    def setUp(self):
        """Initialisation"""
        triangles = xplane(7.0)
        triangles = np.array(triangles, 'float32')

        self.embreeDevice = rtc.EmbreeDevice()
        self.scene = rtcs.EmbreeScene(self.embreeDevice)
        mesh = TriangleMesh(self.scene, triangles)

        origins, dirs = define_rays_origins_and_directions()
        self.origins = origins
        self.dirs = dirs

    def test_intersect_simple(self):
        res = self.scene.run(self.origins, self.dirs)
        self.assertTrue([0, 1, 1, -1], res)

    def test_intersect(self):
        res = self.scene.run(self.origins, self.dirs, output=1)

        self.assertTrue([0, 0, 0, -1], res['geomID'])

        ray_inter = res['geomID'] >= 0
        primID = res['primID'][ray_inter]
        u = res['u'][ray_inter]
        v = res['v'][ray_inter]
        tfar = res['tfar'][ray_inter]
        self.assertTrue([ 0, 1, 1], primID)
        self.assertTrue(np.allclose([6.9, 6.9, 6.9], tfar))
        self.assertTrue(np.allclose([0.4, 0.1, 0.15], u))
        self.assertTrue(np.allclose([0.5, 0.4, 0.35], v))


class TestIntersectionTrianglesFromIndices(TestCase):

    def setUp(self):
        """Initialisation"""
        points = xplane_only_points(7.0)
        points = np.array(points, 'float32')
        indices = np.array([[0, 1, 2], [1, 3, 2]], 'uint32')

        self.embreeDevice = rtc.EmbreeDevice()
        self.scene = rtcs.EmbreeScene(self.embreeDevice)
        mesh = TriangleMesh(self.scene, points, indices)

        origins, dirs = define_rays_origins_and_directions()
        self.origins = origins
        self.dirs = dirs

    def test_intersect_simple(self):
        res = self.scene.run(self.origins, self.dirs)
        self.assertTrue([0, 1, 1, -1], res)

    def test_intersect(self):
        res = self.scene.run(self.origins, self.dirs, output=1)

        self.assertTrue([0, 0, 0, -1], res['geomID'])

        ray_inter = res['geomID'] >= 0
        primID = res['primID'][ray_inter]
        u = res['u'][ray_inter]
        v = res['v'][ray_inter]
        tfar = res['tfar'][ray_inter]
        self.assertTrue([ 0, 1, 1], primID)
        self.assertTrue(np.allclose([6.9, 6.9, 6.9], tfar))
        self.assertTrue(np.allclose([0.4, 0.1, 0.15], u))
        self.assertTrue(np.allclose([0.5, 0.4, 0.35], v))


class TestIntersectionTetrahedron(TestCase):

    def setUp(self):
        """Initialisation"""
        vertices = [(0.0, 0.0, 0.0), (1.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0)]
        vertices = np.array(vertices, 'float32')
        indices = np.array([[0, 1, 2, 3]], 'uint32')
        self.embreeDevice = rtc.EmbreeDevice()
        self.scene = rtcs.EmbreeScene(self.embreeDevice)
        mesh = ElementMesh(self.scene, vertices, indices)

        N = 2
        self.origins = np.zeros((N, 3), dtype='float32')
        self.origins[0, :] = (-0.1, +0.1, +0.1)
        self.origins[1, :] = (-0.1, +0.2, +0.2)
        self.dirs = np.zeros((N, 3), dtype='float32')
        self.dirs[:, 0] = 1.0

    def test_intersect_simple(self):
        res = self.scene.run(self.origins, self.dirs)
        self.assertTrue([1, 1], res)

    def test_intersect(self):
        res = self.scene.run(self.origins, self.dirs, output=1)

        self.assertTrue([0, 0], res['geomID'])

        ray_inter = res['geomID'] >= 0
        primID = res['primID'][ray_inter]
        u = res['u'][ray_inter]
        v = res['v'][ray_inter]
        tfar = res['tfar'][ray_inter]
        self.assertTrue([0, 1], primID)
        self.assertTrue(np.allclose([0.1, 0.1], tfar))
        self.assertTrue(np.allclose([0.1, 0.2], u))
        self.assertTrue(np.allclose([0.1, 0.2], v))


if __name__ == '__main__':
    from unittest import main
    main()