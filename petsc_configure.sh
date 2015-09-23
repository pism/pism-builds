#!/bin/bash

./config/configure.py \
   --with-cc=icc --with-cxx=icpc --with-fc=ifort --with-f77=ifort \
   --with-blas-lapack-dir="/nasa/intel/Compiler/2015.0.090/composer_xe_2015.0.090/mkl/" \
   --with-mpi-lib="/nasa/sgi/mpt/2.12r16/lib/libmpi.so" \
   --with-mpi-include="/nasa/sgi/mpt/2.12r16/include" \
   --with-64-bit-indices \
   --known-mpi-shared-libraries=1 \
   --with-debugging=0 \
   --with-valgrind=0 \
   --with-x=0 \
   --with-ssl=0 \
   --with-batch=1  \
   --with-shared-libraries=1
