#!/bin/bash
#
# Usage: build [build_type]
#
# Where `build_type` can be one of either `Release` or `Debug` (default)

set -eu
source $(dirname $0)/env.sh

BUILD=${1:-Debug}

mkdir -p ${BUILDDIR}
cd ${BUILDDIR}

if [[ -f ${BASEDIR}/conanfile.txt ]]; then
  conan install ${BASEDIR} -if=${BUILDDIR} -pr=default --build=missing
fi

cmake -DCMAKE_CXX_COMPILER=${CLANG} \
      -DCMAKE_BUILD_TYPE=${BUILD} \
      ${UTILS} ..
cmake --build . --target all -- -j 6
