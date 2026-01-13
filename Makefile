.PHONY: up build run run-mpich run-openmpi all clean

# Run all (default target)
all: build

# Start containers
up:
	devcontainer up --workspace-folder ./builder
	devcontainer up --workspace-folder ./runner_mpich
	devcontainer up --workspace-folder ./runner_openmpi

# Build
build: up
	devcontainer exec --workspace-folder ./builder bash build.sh

# Run (both MPICH and OpenMPI)
run: build
	devcontainer exec --workspace-folder ./runner_mpich bash -c "bash build_mpiwrapper.sh && bash run_hello_mpi.sh"
	devcontainer exec --workspace-folder ./runner_openmpi bash -c "bash build_mpiwrapper.sh && bash run_hello_mpi.sh"

# Run (MPICH only)
run-mpich: build
	devcontainer exec --workspace-folder ./runner_mpich bash -c "bash build_mpiwrapper.sh && bash run_hello_mpi.sh"

# Run (OpenMPI only)
run-openmpi: build
	devcontainer exec --workspace-folder ./runner_openmpi bash -c "bash build_mpiwrapper.sh && bash run_hello_mpi.sh"

# Clean up (add actual cleanup commands if needed)
clean:
	rm -rf ./builder/MPItrampoline
	rm -rf ./builder/rsmpi
	rm -rf ./runner_mpich/hello_mpi
	rm -rf ./runner_mpich/MPIwrapper
	rm -rf ./runner_openmpi/hello_mpi
	rm -rf ./runner_openmpi/MPIwrapper
