from unittest import TestCase
import numpy as np
from pyembree import rtcore as rtc
from pyembree import rtcore_scene as rtcs
from pyembree.mesh_construction import TriangleMesh


def xplane(x):
    return [[[x, -1.0, -1.0],
             [x, +1.0, -1.0],
             [x, -1.0, +1.0]],
            [[x, +1.0, -1.0],
             [x, +1.0, +1.0],
             [x, -1.0, +1.0]]]


class TestIntersectionTriangles(TestCase):

    def setUp(self):
        """Initialisation des tests."""
        N = 4
        triangles = xplane(7.0)
        triangles = np.array(triangles, 'float32')

        self.embreeDevice = rtc.EmbreeDevice()
        self.scene = rtcs.EmbreeScene(self.embreeDevice)
        mesh = TriangleMesh(self.scene, triangles)

        origins = np.zeros((N, 3), dtype='float32')
        origins[:,0] = 0.1
        origins[0,1] = -0.2
        origins[1,1] = +0.2
        origins[2,1] = +0.3
        origins[3,1] = -8.2

        dirs = np.zeros((N, 3), dtype='float32')
        dirs[:, 0] = 1.0

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


if __name__ == '__main__':
    from unittest import main
    main()