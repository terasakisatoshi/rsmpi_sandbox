#!/bin/bash
set -e

# check if MPIwrapper exists
if [ ! -d ./MPIwrapper ]; then
    git clone https://github.com/eschnett/MPIwrapper.git
fi

cmake -S ./MPIwrapper -B ./MPIwrapper/build -DMPIEXEC_EXECUTABLE=`which mpiexec` -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=$HOME/mpiwrapper
cmake --build ./MPIwrapper/build
cmake --install ./MPIwrapper/build
