#!/bin/bash

set -e
set -x
set -u

N=8

build_petsc() {
    # rm -rf $PETSC_DIR
    mkdir -p $PETSC_DIR
    cd $PETSC_DIR

    git clone --depth=1 -b maint https://gitlab.com/petsc/petsc.git . || git pull

    opt_flags="-g -O3 -axCORE-AVX2,AVX -xSSE4.2"

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
#PBS -l select=1:ncpus=1:model=bro
#PBS -q devel
#PBS -W group_list=s1878
#PBS -W block=true

. /usr/share/modules/init/bash

module purge
# module use -a /nasa/modulefiles/testing
module load comp-intel/2020.2.254 mpi-hpe/mpt.2.19
cd \$PBS_O_WORKDIR

mpiexec -np 1 ./conftest-$PETSC_ARCH
EOF

    # run conftest in an interactive job and wait for it to complete
    qsub script.queue

    ./reconfigure-$PETSC_ARCH.py

    make all
}

build_petsc
