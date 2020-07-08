#!/bin/bash -l

. /home/jrmadsen/cron.d/functions.sh

COMMON_ARGS="--papi --python --likwid --mpi --cuda --cupti --nvtx --caliper --gotcha -SF -- -VV -- -DPYTHON_EXECUTABLE=$(which python) -G Ninja"

cleanup-timemory
git checkout master
git pull

export CC=$(which gcc)
export CXX=$(which g++)
python ./pyctest-runner.py --coverage --tools --mpip ${COMMON_ARGS}
submit-coverage
