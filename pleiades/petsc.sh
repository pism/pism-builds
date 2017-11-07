#!/bin/bash

set -e
set -x
set -u

N=8

build_petsc() {
    rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b maint https://bitbucket.org/petsc/petsc.git . || git pull

    opt_flags="-g -O3 -axCORE-AVX2,AVX -xSSE4.2"

    # Note: we use Intel compilers, disable Fortran, use 64-bit
    # indices, shared libraries, and no debugging.
    ./config/configure.py \
	--with-cc=icc \
	--known-mpi-shared-libraries=1 \
	--COPTFLAGS="${opt_flags}" \
	--with-cxx=icpc \
	--with-cpp=/usr/bin/cpp \
	--with-fc=0 \
	--with-vendor-compilers=intel \
	--with-gnu-compilers=0 \
	--with-blas-lapack-dir=${MKLROOT}/lib/intel64 \
        --with-64-bit-indices=1 \
        --with-debugging=0 \
        --with-valgrind=0 \
        --with-x=0 \
        --with-ssl=0 \
        --with-batch=1  \
        --with-shared-libraries=1

    cat > script.queue << EOF
#PBS -S /bin/bash
#PBS -l select=1:ncpus=1:model=bro:aoe=sles12
#PBS -l walltime=200
#PBS -W group_list=s1560
#PBS -m e

. /usr/share/modules/init/bash
module purge
module load comp-intel/2016.2.181
module load mpi-sgi/mpt
export PATH="$PATH:."
export MPI_GROUP_MAX=64
mpiexec -np 1 ./conftest-$PETSC_ARCH
EOF

    # run conftest in an interactive job and wait for it to complete
    qsub -I -q devel script.queue
    # read -p "Wait for the job to complete and press RETURN."

    ./reconfigure-$PETSC_ARCH.py

    make all
}

build_petsc
