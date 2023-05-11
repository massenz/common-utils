#!/bin/bash
#
# Copyright (c) 2022 AlertAvert.com.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0
#
# Author: Marco Massenzio (marco@alertavert.com)
#

#
# Usage: build [build_type]
#
# Where `build_type` can be one of either `Release` or `Debug` (default)

set -eu

if [[ -z ${UTILS_DIR} || ! -d ${UTILS_DIR} ]]; then
    echo "[ERROR] The \$UTILS_DIR env var must be defined and " \
         "point to the directory which contains the Common Utilities"
    exit 1
fi

source "${UTILS_DIR}"/utils
source env.sh

BUILD=${1:-Debug}

msg "Build folder in ${BUILDDIR}"
mkdir -p "${BUILDDIR}"
if [[ -f conanfile.txt ]]; then
    msg "Installing binary dependencies..."
    conan install . -if="${BUILDDIR}" -pr=default --build=missing
    success "Dependencies installed"
fi

UTILS="-DUTILS_DIR_DIR=${UTILS_DIR}"

cd "${BUILDDIR}"
cmake -DCMAKE_CXX_COMPILER="${CLANG}" \
      -DCMAKE_BUILD_TYPE="${BUILD}" \
      "${UTILS}" ..
cmake --build . --target all -- -j 6
success "Build complete"
