#!/bin/bash
set -xe

VERSION="2.17.7"

rm -rf embree.tar.gz
rm -rf embree

wget -nv https://github.com/embree/embree/releases/download/v${VERSION}/embree-${VERSION}.x86_64.macosx.tar.gz -O embree.tar.gz
tar -zxvf embree.tar.gz
rm -f embree.tar.gz

if [[ ! -d pyembree/embree ]]; then
    mkdir -p pyembree/embree
fi

# Rename unzipped folder for cdef extern statements
mv "embree-${VERSION}.x86_64.macosx" embree

# pyembree looks for headers in embree subfolder
mv embree pyembree