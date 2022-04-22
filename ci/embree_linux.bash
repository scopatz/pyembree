#!/bin/bash
set -xe

VERSION="2.17.7"
DEPS_FOLDER=~/embree

rm -rf /tmp/embree.tar.gz
rm -rf "${DEPS_FOLDER}"

wget -nv https://github.com/embree/embree/releases/download/v${VERSION}/embree-${VERSION}.x86_64.linux.tar.gz -O /tmp/embree.tar.gz
cd /tmp
tar -zxvf embree.tar.gz
rm -f embree.tar.gz

if [[ ! -d "${DEPS_FOLDER}" ]]; then
    mkdir -p "${DEPS_FOLDER}"
fi

mv "embree-${VERSION}.x86_64.linux" "${DEPS_FOLDER}"