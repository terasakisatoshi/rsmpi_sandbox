devcontainer up --workspace-folder ./builder
devcontainer exec --workspace-folder ./builder bash build.sh

devcontainer up --workspace-folder ./runner_mpich
devcontainer exec --workspace-folder ./runner_mpich bash -c "bash build_mpiwrapper.sh && bash run_hello_mpi.sh"

devcontainer up --workspace-folder ./runner_openmpi
devcontainer exec --workspace-folder ./runner_openmpi bash -c "bash build_mpiwrapper.sh && bash run_hello_mpi.sh"

