#!/bin/bash -le

WORKING_DIR=$(dirname ${BASH_SOURCE[0]})

. ${WORKING_DIR}/functions.sh

COMMON_ARGS="--papi --python --likwid --mpi --mpip --cuda --cupti --nvtx --gotcha --dyninst --caliper --extra-optimizations --tools --profile cpu -SF "
CTEST_ARGS="-VV"
CMAKE_ARGS="-DPYTHON_EXECUTABLE=$(which python) -G Ninja"

: ${BRANCH:=develop}
: ${CLANG_VERSIONS:="6.0 7 8 9 10 11"}
: ${GCC_VERSIONS:="6 7 8 9 10"}

cleanup-timemory
git checkout ${BRANCH}
git pull

for i in ${CLANG_VERSIONS}
do
    cleanup-timemory
    export CC=$(which clang-${i})
    export CXX=$(which clang++-${i})
    if [ -z "${CC}" ]; then continue; fi
    if [ -z "${CXX}" ]; then continue; fi
    python ./pyctest-runner.py ${COMMON_ARGS} -- ${CTEST_ARGS} -- ${CMAKE_ARGS} -DCMAKE_CXX_EXTENSIONS=ON
done

for i in ${GCC_VERSIONS}
do
    cleanup-timemory
    export CC=$(which gcc-${i})
    export CXX=$(which g++-${i})
    if [ -z "${CC}" ]; then continue; fi
    if [ -z "${CXX}" ]; then continue; fi
    python ./pyctest-runner.py ${COMMON_ARGS} -- ${CTEST_ARGS} -- ${CMAKE_ARGS}
done
