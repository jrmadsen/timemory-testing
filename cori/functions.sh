#!/bin/bash

WORKING_DIR=$(dirname ${BASH_SOURCE[0]})
export WORKING_DIR

module load git
module load python/3.7-anaconda-2019.10
module load cuda/10.2.89
module load likwid/5.0.0
module load tau
module load gperftools
module load cmake/3.14.4

pip install pybind11 --user
pip install pyctest --user

: ${TARGETS:="haswell knl"}
export TARGETS

: ${BRANCH:=develop}

for i in ${TARGETS}
do
    declare SOURCE_DIR=$(realpath ${WORKING_DIR}/timemory-${i})
    if [ ! -d $SOURCE_DIR ]; then
        git clone -b ${BRANCH} https://github.com/NERSC/timemory.git ${SOURCE_DIR}
    fi
done

cleanup_all_timemory()
{
    for i in ${TARGETS}
    do
        declare SOURCE_DIR=$(realpath ${WORKING_DIR}/timemory-${i})
        cd ${SOURCE_DIR}
        git checkout ${BRANCH}
        git pull
        git submodule update --recursive --init .
        rm -rf build-timemory/Linux
        cd ${WORKING_DIR}
    done
}

# clean up only target
cleanup_timemory()
{
    declare SOURCE_DIR=$(realpath ${WORKING_DIR}/timemory-${1})
    cd ${SOURCE_DIR}
    git checkout ${BRANCH}
    git pull
    git submodule update --recursive --init .
    rm -rf build-timemory/Linux
}