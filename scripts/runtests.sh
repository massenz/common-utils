#!/bin/bash

#
# Copyright (c) 2020-2023 AlertAvert.com.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0
#
# Author: Marco Massenzio (marco@alertavert.com)
#

set -eu

if [[ -z ${COMMON_UTILS} || ! -d ${COMMON_UTILS} ]]; then
    echo "[ERROR] The \$UTILS_DIR env var must be defined and " \
         "point to the directory which contains the Common Utilities"
    exit 1
fi

source ${COMMON_UTILS}/utils.sh
source env.sh

verbose=""
memcheck=""
valgrind_bin="${BUILDDIR}/tests/bin/unit_tests"
source $(parse-args verbose- memcheck- valgrind_bin~ -- $@)


# Runs tests of the given type (unit, integration)
#
# Usage: run_tests type [args ... ]
function run_tests {
  local type=${1:-unit}
  local tests=${BUILDDIR}/tests/bin/${type}_tests
  shift 1

  if [[ -x ${tests} ]]; then
    msg "============ Running ${type} Tests ============="
    time ${tests} $@
    msg "------------ ${type} Tests Finished ------------"
  fi
}

function mem_check {
  if [[ ! -x ${valgrind_bin} ]]; then
    # Look for it in the bin dir
    if [[ -x "${BUILDDIR}/bin/${valgrind_bin}" ]]; then
      valgrind_bin="${BUILDDIR}/bin/${valgrind_bin}"
    else
      fatal "${valgrind_bin} does not exist or is non-executable"
    fi
  fi

  if which valgrind >/dev/null; then
    msg "============ Running Memory Leak Checks ============="
    valgrind --tool=memcheck --gen-suppressions=all \
      --leak-check=full \
      --leak-resolution=med \
      --track-origins=yes \
      --vgdb=no \
      ${valgrind_bin}
  else
    errmsg "Valgrind binary does not exist, install with
    sudo apt -y install linux-tools-$(uname -r)"
  fi
}


if [[ -n ${verbose} ]]; then
    export GLOG_v=2
    export GLOG_logtostderr=true
fi

cd ${BUILDDIR}
run_tests unit $@
run_tests integration $@

if [[ -n ${memcheck} ]]; then
  mem_check
fi

success "All tests passed"
