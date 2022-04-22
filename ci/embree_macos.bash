#!/bin/bash
set -xe

VERSION="2.17.7"

rm -rf /tmp/embree.tar.gz
rm -rf ~/embree

wget -nv https://github.com/embree/embree/releases/download/v${VERSION}/embree-${VERSION}.x86_64.macosx.tar.gz -O /tmp/embree.tar.gz
cd /tmp
tar -zxvf embree.tar.gz
rm -f embree.tar.gz

mv embree-${VERSION}.x86_64.macosx ~/embree