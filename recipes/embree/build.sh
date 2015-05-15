#!/bin/bash
cd lib
ln -s libembree.so.* libembree.so
cd ..
cp -rv * "${PREFIX}"
