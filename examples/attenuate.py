import time

import numpy as np
import matplotlib.pyplot as plt

from pyembree import rtcore_scene as rtcs
from pyembree.mesh_construction import TriangleMesh

N = (4*256)**2
R = 3
sigmas = [0.5, 2.0, 4.0]

def xplane(x):
    return [[[x, -1.0, -1.0],
             [x, -1.0, 1.0],
             [x, 1.0, -1.0]], 
            [[x, -1.0, 1.0],
             [x, 1.0, -1.0], 
             [x, 1.0, 1.0]]]


triangles = xplane(0.0) + xplane(1.0) + xplane(2.0) + xplane(3.0)
triangles = np.array(triangles, 'float32')

scene = rtcs.EmbreeScene()
mesh = TriangleMesh(scene, triangles)
xgrid = np.linspace(0.0, 3.0, 100)
tally = np.zeros(len(xgrid), dtype=int)

origins = np.zeros((N, 3), dtype='float64')
origins[:, 0] += 1e-8
dirs = np.zeros((N, 3))
dirs[:, 0] = 1.0

maxdist = np.empty(N, dtype='float32')
exists = np.arange(N)

def transport_region(r, origins, maxdist, exist):
    n = len(origins)
    u = np.random.random(n)
    dists = np.log(u) / (-sigmas[r])
    dists = np.asarray(dists, dtype='float32')

    t1 = time.time()
    intersects = scene.run(origins, dirs[:n], dists)
    t2 = time.time()
    print("Ran region {0} in {1:.3f} s".format(r+1, t2-t1))

    bi = intersects == -1
    maxdist[exist[bi]] = origins[bi, 0] + dists[bi]
    neworigins = np.asarray(triangles[intersects[~bi],0,:], dtype='float64')
    neworigins[:,1:] = 0.0
    exist = exist[~bi]
    return intersects, neworigins, exist

for r in range(R):
    intersects, origins, exists = transport_region(r, origins, maxdist, exists)

gi = intersects > -1
maxdist[exists] = triangles[intersects[gi],:,0]  # get x coord
#print(maxdist[maxdist > 1.0])

for i in range(len(xgrid)):
    tally[i] += (maxdist >= xgrid[i]).sum() 

plt.plot(xgrid, tally)
plt.xlabel('x [cm]')
plt.ylabel('flux')
plt.savefig('attenuate.png')

