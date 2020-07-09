#!/bin/bash -le

WORKING_DIR=$(dirname ${BASH_SOURCE[0]})

. ${WORKING_DIR}/functions.sh

# choose the target platform
: ${TARGET:="knl"}

# allow dynamic linking
export CRAYPE_LINK_TYPE=dynamic

# load the required cross compiler craype
module unload craype-haswell
module load craype-mic-${TARGET}

# unload all programming environments
module unload PrgEnv-intel
module unload PrgEnv-gnu
module unload PrgEnv-cray

# command line arguments
ARG_PYTHON=" --python "
COMMON_ARGS=" --extra-optimizations --tools -SF "
CTEST_ARGS="-VV"
CMAKE_ARGS="-DPYTHON_EXECUTABLE=$(which python)"

# jobs to run, time in minutes
JOBS="32"
TIME="120"

: ${BRANCH:=develop}

# compiler versions testing

# compiler versions
# : ${CLANG_VERSIONS:="8.0.1 9.0.1 10.0.0"}
: ${GCC_VERSIONS:="6.1.0 7.3.0 8.3.0 9.2.0"}
: ${INTEL_VERSIONS:="16.0.3.210 17.0.2.174 18.0.3.222 19.0.3.199"}

# clean up timemory
cleanup_timemory ${TARGET}

# load LLVM programming environment
module unload PrgEnv-intel
module unload intel
module unload llvm
module load PrgEnv-gnu
module load gcc

# run for all llvm
for i in ${CLANG_VERSIONS}
do
    cleanup_timemory ${TARGET}
    module unload llvm/${i}
    export CC=$(which clang)
    export CXX=$(which clang++)
    if [ -z "${CC}" ]; then continue; fi
    if [ -z "${CXX}" ]; then continue; fi
    srun -n 1 -N 1 -q interactive -t ${TIME} -C ${TARGET} python ./pyctest-runner.py -j ${JOBS} ${COMMON_ARGS} ${ARG_PYTHON} -- ${CTEST_ARGS} -- ${CMAKE_ARGS} -DCMAKE_CXX_EXTENSIONS=ON
done

# load GNU programming environment
module unload PrgEnv-intel
module unload intel
module unload llvm
module load PrgEnv-gnu

# run for all gcc versions
for i in ${GCC_VERSIONS}
do
    cleanup_timemory ${TARGET}
    module unload gcc
    module load gcc/${i}
    export CC=$(which gcc)
    export CXX=$(which g++)

    if [ -z "${CC}" ]; then continue; fi
    if [ -z "${CXX}" ]; then continue; fi
    srun -n 1 -N 1 -q interactive -t ${TIME} -C ${TARGET} python ./pyctest-runner.py -j ${JOBS} ${COMMON_ARGS} ${ARG_PYTHON} -- ${CTEST_ARGS} -- ${CMAKE_ARGS}
done

# load Intel programming environment
module unload PrgEnv-gnu
module unload gcc
module unload llvm
module load PrgEnv-intel

for i in ${INTEL_VERSIONS}
do
    cleanup_timemory ${TARGET}
    module unload intel
    module load intel/${i}
    export CC=$(which icc)
    export CXX=$(which icpc)

    if [ -z "${CC}" ]; then continue; fi
    if [ -z "${CXX}" ]; then continue; fi
    srun -n 1 -N 1 -q interactive -t ${TIME} -C ${TARGET} python ./pyctest-runner.py -j ${JOBS} ${COMMON_ARGS} -- ${CTEST_ARGS} -- ${CMAKE_ARGS} -DCMAKE_CXX_EXTENSIONS=ON
done