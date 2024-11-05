#!/bin/bash
# Copyright (c) 2020-2024 AlertAvert.com.  All rights reserved.
# Author: Marco Massenzio (marco@alertavert.com)
#
# Usage: build [--debug] [-h]

set -eu

if [[ ${1:-} == "-h" ]]; then
  echo "Usage: build [--debug] [-h]"
  echo "Builds the project using CMake, with an optional --debug flag to build in Debug mode."
  exit 0
fi

# shellcheck disable=SC2155
declare -r COMMON_UTILS="$(realpath $0/..)"
declare -r UTILS="-DCOMMON_UTILS_DIR=${COMMON_UTILS}"
source "${COMMON_UTILS}"/utils.sh

if [[ ${1:-} == "--debug" ]]; then
  PRESET=conan-debug
  BUILD_TYPE=Debug
else
  PRESET=conan-release
  BUILD_TYPE=Release
fi

if [[ -f conanfile.txt ]]; then
    msg "Installing binary dependencies..."
    conan install . -pr=default \
        --build=missing -s build_type=${BUILD_TYPE}
    success "Dependencies installed"
fi

msg "Running CMake to configure the build"
cmake --preset ${PRESET} "${UTILS}"
success "CMake configuration complete"
msg "Building the project"
cmake --build  --preset ${PRESET} "${UTILS}" --target all -- -j 6
success "Build complete, targets available in $(realpath ./build/${BUILD_TYPE})"
