curl -L -o embree.zip https://github.com/embree/embree/releases/download/v2.17.7/embree-2.17.7.x64.windows.zip
7z x embree.zip
del embree.zip

@REM Rename unzipped folder for cdef extern statements
ren embree-2.17.7.x64.windows embree

@REM pyembree looks for headers in embree subfolder
move /Y embree pyembree