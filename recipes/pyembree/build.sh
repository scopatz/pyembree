#!/bin/bash
export LD_LIBRARY_PATH=$PREFIX/lib
export PATH=$PREFIX/bin:$PATH
export DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib/cyclus:$PREFIX/lib
export C_INCLUDE_PATH=$PREFIX/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=$PREFIX/include:$CPLUS_INCLUDE_PATH

python setup.py install --prefix=$PREFIX
