cp ../builder/hello_mpi/target/release/hello_mpi ./hello_mpi
env MPITRAMPOLINE_MPIEXEC=$HOME/mpiwrapper/bin/mpiwrapperexec \
    MPITRAMPOLINE_LIB=$HOME/mpiwrapper/lib/libmpiwrapper.so \
    mpiexec -n 4 ./hello_mpi