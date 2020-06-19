set -xe

curl -L -o embree.tar.gz https://github.com/embree/embree/releases/download/v2.17.5/embree-2.17.5.x86_64.linux.tar.gz

tar -zxvf embree.tar.gz
rm embree.tar.gz

cd embree-2.17.5.x86_64.linux
mv include/embree2 /usr/include
mv lib/* /usr/lib
