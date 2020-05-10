#!/bin/bash

set -eu
source $(dirname $0)/env.sh

# Runs tests of the given type (unit, integration)
#
# Usage: run_tests type [args ... ]
function run_tests {
    local type=${1:-unit}
	local tests=${BUILDDIR}/tests/bin/${type}_tests
	shift 1

	if [[ -x ${tests} ]]; then
	    echo "============ Running ${type} Tests =============" >&2
     	time ${tests} $@
	    echo "------------ ${type} Tests Finished ------------" >&2
    fi
}

if [[ ${1:-} == "-v" ]]; then
    export GLOG_v=2
    export GLOG_logtostderr=true
    shift 1
fi

cd ${BUILDDIR}
run_tests unit $@
run_tests integration $@
