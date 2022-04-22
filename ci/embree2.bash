#!/bin/bash
set -xe

VERSION="2.17.7"

rm -rf /tmp/embree2.tar.gz
rm -rf ~/embree2

wget -nv https://github.com/embree/embree/releases/download/v${VERSION}/embree-${VERSION}.x86_64.linux.tar.gz -O /tmp/embree2.tar.gz
cd /tmp
tar -zxvf embree2.tar.gz
rm -f embree2.tar.gz

mv embree-${VERSION}.x86_64.linux ~/pyembree/embree2