#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# if MPItrampoline does not exist, clone it
if [ ! -d MPItrampoline ]; then
    git clone --depth 1 -b v5.5.0 https://github.com/eschnett/MPItrampoline.git
fi
# Build and install MPItrampoline
MPITRAMPOLINE_PREFIX=$HOME/mpitrampoline
cmake -S MPItrampoline -B MPItrampoline/build \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX=$MPITRAMPOLINE_PREFIX \
    -DMPIEXEC_EXECUTABLE=`which mpiexec`
cmake --build MPItrampoline/build
cmake --install MPItrampoline/build

# Build rsmpi using MPItrampoline as MPI library
if [ ! -d rsmpi ]; then
    git clone --depth 1 -b mpi-0.8.1 https://github.com/rsmpi/rsmpi.git
fi

# Apply patch for MPItrampoline compatibility
cd rsmpi
if [ -f "$SCRIPT_DIR/rsmpi-mpitrampoline.patch" ]; then
    # Check if patch is already applied by looking for the constructor function
    if ! grep -q "rsmpi_init_constants" mpi-sys/src/rsmpi.c 2>/dev/null; then
        echo "Applying MPItrampoline compatibility patch..."
        git apply "$SCRIPT_DIR/rsmpi-mpitrampoline.patch" || {
            echo "Patch failed, trying to apply with --3way..."
            git apply --3way "$SCRIPT_DIR/rsmpi-mpitrampoline.patch"
        }
    else
        echo "Patch already applied, skipping..."
    fi
fi

# Set MPICC to use MPItrampoline's mpicc
export MPICC=$MPITRAMPOLINE_PREFIX/bin/mpicc
# Add MPItrampoline's bin directory to PATH so mpicc can be found
export PATH=$MPITRAMPOLINE_PREFIX/bin:$PATH
# Add pkg-config path if MPItrampoline provides pkg-config files
if [ -d "$MPITRAMPOLINE_PREFIX/lib/pkgconfig" ]; then
    export PKG_CONFIG_PATH=$MPITRAMPOLINE_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH
fi
cargo build --release
cd -

cd $SCRIPT_DIR/hello_mpi
cargo build --release
cd -