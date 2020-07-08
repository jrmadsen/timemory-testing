#!/bin/bash

WORKING_DIR=$(dirname ${BASH_SOURCE[0]})

module use /opt/modulefiles/compilers
module use /opt/modulefiles/profilers
module use /opt/modulefiles/tools
module use /opt/modulefiles/python
module use /opt/modulefiles/packages
module use /opt/modulefiles/intel

module load cuda/10.2
module load likwid
module load tau
module load anaconda
source activate timemory

: ${SPACK_COMPILER:="gcc@9.2.1"}
                            
spack load -r dyninst%${SPACK_COMPILER}
spack load -r mpich%${SPACK_COMPILER}
spack load -r papi@6.0.0.1%${SPACK_COMPILER}

: ${SOURCE_DIR:=$(realpath ${WORKING_DIR}/timemory-maeve)}
: ${BRANCH:=develop}

export SOURCE_DIR

if [ ! -d ${SOURCE_DIR} ]; then
    git clone -b ${BRANCH} https://github.com/NERSC/timemory.git ${SOURCE_DIR}
fi

cleanup-timemory()
{
    cd ${SOURCE_DIR}
    git checkout ${BRANCH}
    git pull
    git submodule update --recursive --init .
    rm -rf build-timemory/Linux
}

submit-coverage()
{
    lcov --directory . --capture --output-file coverage.info
    lcov --remove coverage.info '/usr/*' "${HOME}"'/.cache/*' '*/external/*' --output-file coverage.info
    lcov --list coverage.info
    bash <(curl -s https://codecov.io/bash) -f coverage.info || echo "Codecov did not collect coverage reports"
}
