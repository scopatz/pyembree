#!/bin/bash
set -xe


# if embree2 exits exit early
if [ -d "/usr/include/embree2" ]; then
   exit 0;
fi

curl -L -o embree.tar.gz https://github.com/embree/embree/releases/download/v2.17.7/embree-2.17.7.x86_64.linux.tar.gz
echo "2c4bdacd8f3c3480991b99e85b8f584975ac181373a75f3e9675bf7efae501fe  embree.tar.gz" | sha256sum --check

tar -zxvf embree.tar.gz
rm embree.tar.gz

cd embree-2.17.7.x86_64.linux
mv include/embree2 /usr/include
mv lib/* /usr/lib

rm -rf embree-2.17*
