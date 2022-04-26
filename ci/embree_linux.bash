#!/bin/bash
set -xe

VERSION="2.17.7"

rm -rf embree.tar.gz
rm -rf embree

wget -nv https://github.com/embree/embree/releases/download/v${VERSION}/embree-${VERSION}.x86_64.linux.tar.gz -O embree.tar.gz
tar -zxvf embree.tar.gz
rm -f embree.tar.gz

if [[ ! -d pyembree/embree ]]; then
    mkdir -p pyembree/embree
fi

# Rename unzipped folder for cdef extern statements
mv "embree-${VERSION}.x86_64.linux" embree

# It is recommended to build against tbb and tbbmalloc, which may improve
# the library's runtime performance. However, to be a 'manylinux' wheel, these
# must be removed for maximum portability.
#
# If building against tbb is desired, Intel only provides a symlink to embree in the
# tarball. Symlinks to the correct versions of the libraries must be made.
#
# Uncomment this code to build against tbb:
#
# cd embree/lib
# ln -s libtbb.so.2 libtbb.so
# ln -s libtbbmalloc.so.2 libtbbmalloc.so
# cd ../..

# pyembree looks for headers in embree subfolder
mv embree pyembree