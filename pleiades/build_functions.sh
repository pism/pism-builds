
# Automate building PROJ.4, FFTW, PETSc, and PISM on pleiades.
#
# To use this script,
#
# - edit your .profile to load modules automatically
# - set PETSC_DIR and PETSC_ARCH in your .profile
# - edit LOCAL_LIB_DIR and PISM_DIR below
# - run this script

# directory to install libraries in
LOCAL_LIB_DIR=$HOME/local

# PISM installation directory
PISM_DIR=$HOME/pism

# No. of cores for make
N=8

export PETSC_DIR=$HOME/petsc

echo 'PETSC_DIR = ' ${PETSC_DIR}
echo 'PETSC_ARCH = ' ${PETSC_ARCH}

export MPICC_CC=icc
export MPICXX_CXX=icpc
#export CC=mpicc

# MPI_ROOT is set by the module system
MPI_INCLUDE="${MPI_ROOT}/include"
MPI_LIBRARY="${MPI_ROOT}/lib/libmpi.so"

# stop on error
set -e
# print commands before executing them
set -x


build_pism() {
    mkdir -p $PISM_DIR/sources
    cd $PISM_DIR/sources

    git clone --depth 1 -b dev https://github.com/pism/pism.git . || git pull

    mkdir -p build
    cd build
    rm -f CMakeCache.txt

    # use Intel's MPI compiler wrappers
    export CC=icc
    export CXX=icpc
    cmake -DMPI_C_INCLUDE_PATH=$MPI_INCLUDE \
          -DMPI_C_LIBRARIES=$MPI_LIBRARY \
          -DPETSC_EXECUTABLE_RUNS=YES \
	  -DCMAKE_FIND_ROOT_PATH="$LOCAL_LIB_DIR" \
          -DCMAKE_CXX_FLAGS="-std=c++11 -O3 -ipo -axCORE-AVX2 -xSSE4.2 -diag-disable=cpu-dispatch,10006,2102" \
          -DCMAKE_C_FLAGS="-std=c11 -O3 -ipo -axCORE-AVX2 -xSSE4.2 -diag-disable=cpu-dispatch,10006" \
          -DCMAKE_FIND_ROOT_PATH="$LOCAL_LIB_DIR/hdf5;$LOCAL_LIB_DIR/netcdf" \
          -DCMAKE_INSTALL_PREFIX=$PISM_DIR \
          -DPism_USE_PARALLEL_NETCDF4=YES \
          -DPism_USE_PROJ4=YES $PISM_DIR/sources
    make -j4 install
}

T="$(date +%s)"

build_all() {
#build_petsc
#build_proj4
#build_udunits2
build_pism
#build_cdo
#build_ncview
}

T="$(($(date +%s)-T))"
echo "Time in seconds: ${T}"

printf "Pretty format: %02d:%02d:%02d:%02d\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))"
