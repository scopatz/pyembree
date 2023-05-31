#!/bin/bash
set -xe


# if embree2 exits exit early
if [ -d "/usr/include/embree2" ]; then
   exit 0;
fi

curl -L -o embree.tar.gz https://github.com/embree/embree/releases/download/v2.17.7/embree-2.17.7.x86_64.macosx.tar.gz

tar -zxvf embree.tar.gz
rm embree.tar.gz

cd embree-2.17.7.x86_64.macosx
mv include/embree2 /usr/include
mv lib/* /usr/lib

rm -rf embree-2.17*
